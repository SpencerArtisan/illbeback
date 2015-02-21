//
//  Sharer.swift
//  illbeback
//
//  Created by Spencer Ward on 21/02/2015.
//  Copyright (c) 2015 Spencer Ward. All rights reserved.
//



public class Sharer {
    private var root: Firebase
    
    init() {
        root = Firebase(url:"https://illbeback.firebaseio.com/")
    }
    
    func share(from: String, to: String, memory: String) {
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
}

