public class Sharer {
    private var root: Firebase
    
    init() {
        root = Firebase(url:"https://illbeback.firebaseio.com/")
    }
    
    func share(from: String, to: String, memory: String, imageUrl: NSURL?) {
        storeImage(imageUrl)
        
        var givenMemoriesRoot = root.childByAppendingPath("users/" + to + "/given")
        var given = ["from": from, "memory": memory]
        var newNode = givenMemoriesRoot.childByAutoId()
        newNode.setValue(given)
    }
    
    func retrieve(to: String, callback: (from: String, memory: String) -> ()) {
        var givenMemoriesRoot = root.childByAppendingPath("users/" + to + "/given")
        givenMemoriesRoot.observeSingleEventOfType(.Value, withBlock: {
            snapshot in
                var givenMemories = snapshot.children
                while let given: FDataSnapshot = givenMemories.nextObject() as? FDataSnapshot {
                    var from = given.value["from"] as String
                    var memory = given.value["memory"] as String
                    callback(from: from, memory: memory)
                }
        })
    }
    
    
    private func storeImage(imageUrl: NSURL?) {
        if (imageUrl != nil) {
            let transferManager = AWSS3TransferManager.defaultS3TransferManager()
            let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        
            uploadRequest1.bucket = "illbebackapp"
            uploadRequest1.key =  "my-image"
            uploadRequest1.body = imageUrl
            
        
            let task = transferManager.upload(uploadRequest1)
            task.continueWithBlock { (task) -> AnyObject! in
                if task.error != nil {
                    println("Error: \(task.error)")
                } else {
                    println("Upload successful")
                }
                return nil
            }
        }
    }
}

