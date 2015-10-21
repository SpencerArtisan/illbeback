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
    
    func share(from: String, to: String, memory: Memory, onComplete: () -> Void, onError: () -> Void) {
        let photos = PhotoAlbum().photos(memory)
        print("Uploading \(photos.count) photos")
        var leftToUpload = photos.count
        if (photos.count > 0) {
            for photo in photos {
                let key = (photo.imagePath as NSString).lastPathComponent
                print("    Uploading photo \(key)")
                uploadImage(photo.imagePath, key: key, onComplete: {
                    leftToUpload--
                    print("    Uploaded photo '\(photo.imagePath)'.  \(leftToUpload) left")
                    if (leftToUpload == 0) {
                        self.uploadMemory(from, to: to, memory: memory)
                        onComplete()
                        return
                    }
                }, onError: {
                    onError()
                    return
                })
            }
        } else {
            self.uploadMemory(from, to: to, memory: memory)
            onComplete()
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
                            print("All shared photos downloaded.  Notifying observers...")
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
        
        print("Downloading shared images for memory \(memory.id)")
        var leftToDownload = imageUrls.count
        
        for imageUrl in imageUrls {
            print("    Check for image with key \(imageUrl.lastPathComponent)")
        
            let readRequest : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
            readRequest.bucket = BUCKET
            readRequest.key =  imageUrl.lastPathComponent!
            readRequest.downloadingFileURL = imageUrl
        
            let task = transferManager.download(readRequest)
            task.continueWithBlock { (task) -> AnyObject! in
                if task.error != nil {
                    print("    No image with key \(imageUrl.lastPathComponent!)")
                } else {
                    print("    Image downloaded \(imageUrl.lastPathComponent!)")
                }
                leftToDownload--
                print("    \(leftToDownload) left to check for")
                if (leftToDownload == 0) {
                    onComplete()
                }
                return nil
            }
        }
    }
    
    private func uploadImage(imagePath: String?, key: String, onComplete: () -> Void, onError: () -> Void) {
        let uploadRequest : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = BUCKET
        uploadRequest.key = key
        uploadRequest.body = NSURL(fileURLWithPath: imagePath!)
        uploadRequest.ACL = AWSS3ObjectCannedACL.AuthenticatedRead
            
        let task = transferManager.upload(uploadRequest)
        task.continueWithBlock { (task) -> AnyObject! in
            if task.error != nil {
                print("    Umage upload FAILED! \(key)")
                onError()
            } else {
                print("    Image uploaded \(key)")
                onComplete()
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

