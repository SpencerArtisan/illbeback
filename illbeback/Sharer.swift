public class Sharer {
    private var root: Firebase
    private let BUCKET = "illbebackappus"
    private var transferManager: AWSS3TransferManager
    
    init() {
        root = Firebase(url:"https://illbeback.firebaseio.com/")
        transferManager = AWSS3TransferManager.defaultS3TransferManager()
    }
    
    func share(from: String, to: String, memory: Memory, imageUrl: NSURL?) {
        if (PhotoAlbum().photoExists(memory.id)) {
            uploadImage(imageUrl, key: imageKey(memory), onComplete: {
                println("Shared photo uploaded.  Uploading memory details...")
                self.uploadMemory(from, to: to, memory: memory)
            })
        }
    }
    
    func retrieveShares(to: String, callback: (from: String, memory: Memory) -> ()) {
        shareRoot(to).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
                var givenMemories = snapshot.children
                while let given: FDataSnapshot = givenMemories.nextObject() as? FDataSnapshot {
                    var from = given.value["from"] as! String
                    var memoryString = given.value["memory"] as! String
                    var memory = Memory(memoryString: memoryString)
                    memory.recentShare = true
                    var key = self.imageKey(memory)
                    self.downloadImage(memory, key: key, onComplete: {
                        println("Shared photo downloaded.  Notifying observers...")
                        callback(from: from, memory: memory)
                    })
                }
                self.shareRoot(to).removeValue()
        })
    }
    
    private func downloadImage(memory: Memory, key: String, onComplete: () -> Void) {
        // todo -tidy
        let photoAlbum = PhotoAlbum()
        var imageUrl = photoAlbum.getMemoryImageUrl(memory.id)
        photoAlbum.delete(memory.id)
        println("** AWS OP: Downloading image to: " + imageUrl.absoluteString!)
        
        let readRequest : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
        readRequest.bucket = BUCKET
        readRequest.key =  key
        readRequest.downloadingFileURL = imageUrl
        
        var task = transferManager.download(readRequest)
        task.continueWithBlock { (task) -> AnyObject! in
            onComplete()
            return nil
        }
        monitorAsyncTask(task, type: "Download")
    }
    
    private func uploadImage(imageUrl: NSURL?, key: String, onComplete: () -> Void) {
        println("** AWS OP: Uploading image from: " + imageUrl!.absoluteString!)

        let uploadRequest : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = BUCKET
        uploadRequest.key = key
        uploadRequest.body = imageUrl
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
                println("** AWS ERROR: " + type + " error: \(task.error)")
            } else {
                println("** AWS SUCCESS: " + type)
            }
            return nil
        }
    }
    
    private func uploadMemory(from: String, to: String, memory: Memory) {
        println("** FIREBASE OP: Uploading memory " + memory.asString())
        var newNode = shareRoot(to).childByAutoId()
        newNode.setValue(["from": from, "memory": memory.asString()])
    }
    
    private func shareRoot(to: String) -> Firebase {
        return root.childByAppendingPath("users/" + to + "/given")
    }
    
    private func imageKey(memory: Memory) -> String {
        return memory.id
    }
}

