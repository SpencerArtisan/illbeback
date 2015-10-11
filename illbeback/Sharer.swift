public class Sharer {
    private var root: Firebase
    private let BUCKET = "illbebackappus"
    private var transferManager: AWSS3TransferManager
    private var memoryAlbum: MemoryAlbum
    
    init(memoryAlbum: MemoryAlbum) {
        self.memoryAlbum = memoryAlbum
        root = Firebase(url:"https://illbeback.firebaseio.com/")
        transferManager = AWSS3TransferManager.defaultS3TransferManager()
    }
    
    func share(from: String, to: String, memory: Memory) {
        let photos = PhotoAlbum().photos(memory)
        if (photos.count > 0) {
            for photo in photos {
                uploadImage(photo.imagePath, key: photo.imagePath, onComplete: {
                    print("Shared photo uploaded.  Uploading memory details...")
                    self.uploadMemory(from, to: to, memory: memory)
                })
            }
        } else {
            self.uploadMemory(from, to: to, memory: memory)            
        }
    }
    
    func retrieveShares(to: String, callback: (from: String, memory: Memory) -> ()) {
        shareRoot(to).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
                let givenMemories = snapshot.children
                var receivedIds:[String] = []
            
                while let given: FDataSnapshot = givenMemories.nextObject() as? FDataSnapshot {
                    let from = given.value["from"] as! String
                    let memoryString = given.value["memory"] as! String
                    let memory = Memory(memoryString: memoryString)
                    if (self.memoryAlbum.contains(memory) || receivedIds.filter({$0 == memory.id}).count > 0) {
                        print("Already have memory \(memory.type). Ignoring share")
                    } else {
                        receivedIds.append(memory.id)
                        memory.recentShare = true
                        print("Received memory \(memoryString)")
                        self.downloadImages(memory, onComplete: {
                            print("Shared photos downloaded.  Notifying observers...")
                            callback(from: from, memory: memory)
                        })
                    }
                }
                self.shareRoot(to).removeValue()
        })
    }
    
    private func downloadImages(memory: Memory, onComplete: () -> Void) {
        // todo -tidy
        let photoAlbum = PhotoAlbum()
        let imageUrls = photoAlbum.getMemoryImageUrls(memory.id)
        
        for imageUrl in imageUrls {
            print("AWS OP: Downloading image to: " + imageUrl.absoluteString)
        
            let readRequest : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
            readRequest.bucket = BUCKET
            readRequest.key =  imageUrl.absoluteString
            readRequest.downloadingFileURL = imageUrl
        
            let task = transferManager.download(readRequest)
            task.continueWithBlock { (task) -> AnyObject! in
                onComplete()
                return nil
            }
            monitorAsyncTask(task, type: "Download")
        }
    }
    
    private func uploadImage(imagePath: String?, key: String, onComplete: () -> Void) {
        print("AWS OP: Uploading image from: " + imagePath!)

        let uploadRequest : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = BUCKET
        uploadRequest.key = key
        uploadRequest.body = NSURL(fileURLWithPath: imagePath!)
        uploadRequest.ACL = AWSS3ObjectCannedACL.AuthenticatedRead
            
        let task = transferManager.upload(uploadRequest)
        task.continueWithBlock { (task) -> AnyObject! in
            onComplete()
            return nil
        }
        monitorAsyncTask(task, type: "Upload")
    }
    
    private func monitorAsyncTask(task: BFTask, type: String) {
        task.continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                print("** AWS ERROR: " + type + " error: \(task.error)")
            } else {
                print("** AWS SUCCESS: " + type)
            }
            return nil
        }
    }
    
    private func uploadMemory(from: String, to: String, memory: Memory) {
        print("FIREBASE OP: Uploading memory " + memory.asString())
        let newNode = shareRoot(to).childByAutoId()
        newNode.setValue(["from": from, "memory": memory.asString()])
    }
    
    private func shareRoot(to: String) -> Firebase {
        return root.childByAppendingPath("users/" + to + "/given")
    }

}

