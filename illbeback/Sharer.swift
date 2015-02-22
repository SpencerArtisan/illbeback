public class Sharer {
    private var root: Firebase
    private let BUCKET = "illbebackappus"
    private var transferManager: AWSS3TransferManager
    
    init() {
        root = Firebase(url:"https://illbeback.firebaseio.com/")
        transferManager = AWSS3TransferManager.defaultS3TransferManager()
    }
    
    func share(from: String, to: String, memory: String, imageUrl: NSURL?) {
        var memoryId = Memory(memoryString: memory).getId()
        if (PhotoAlbum().photoExists(memoryId)) {
            uploadImage(imageUrl, key: imageKey(memory))
        }
        uploadMemory(from, to: to, memory: memory)
    }
    
    func retrieveShares(to: String, callback: (from: String, memory: String) -> ()) {
        shareRoot(to).observeSingleEventOfType(.Value, withBlock: {
            snapshot in
                var givenMemories = snapshot.children
                while let given: FDataSnapshot = givenMemories.nextObject() as? FDataSnapshot {
                    var from = given.value["from"] as String
                    var memory = given.value["memory"] as String
                    self.downloadImage(memory, key: self.imageKey(memory))
                    callback(from: from, memory: memory)
                }
                self.shareRoot(to).removeValue()
        })
    }
    
    private func downloadImage(memoryString: String, key: String) {
        // todo -tidy
        var memoryId = Memory(memoryString: memoryString).getId()
        let photoAlbum = PhotoAlbum()
        var imageUrl = photoAlbum.getMemoryImageUrl(memoryId)
        photoAlbum.delete(memoryId)
        println("** AWS OP: Downloading image to: " + imageUrl.absoluteString!)
        
        let readRequest : AWSS3TransferManagerDownloadRequest = AWSS3TransferManagerDownloadRequest()
        readRequest.bucket = BUCKET
        readRequest.key =  key
        readRequest.downloadingFileURL = imageUrl
        
        var task = transferManager.download(readRequest)
        monitorAsyncTask(task, type: "Download")
    }
    
    private func uploadImage(imageUrl: NSURL?, key: String) {
        println("** AWS OP: Uploading image from: " + imageUrl!.absoluteString!)

        let uploadRequest : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        uploadRequest.bucket = BUCKET
        uploadRequest.key = key
        uploadRequest.body = imageUrl
        uploadRequest.ACL = AWSS3ObjectCannedACL.AuthenticatedRead
            
        let task = transferManager.upload(uploadRequest)
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
    
    private func uploadMemory(from: String, to: String, memory: String) {
        println("** FIREBASE OP: Uploading memory " + memory)
        var newNode = shareRoot(to).childByAutoId()
        newNode.setValue(["from": from, "memory": memory])
    }
    
    private func shareRoot(to: String) -> Firebase {
        return root.childByAppendingPath("users/" + to + "/given")
    }
    
    private func imageKey(memory: String) -> String {
        return Memory(memoryString: memory).getId()
    }
}

