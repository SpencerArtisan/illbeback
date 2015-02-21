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
        var givenMemories = root.childByAppendingPath("users/" + to + "/given")
        var given = ["from": from, "memory": memory]
        var newNode = givenMemories.childByAutoId()
        newNode.setValue(given)
    }
    
    func retrieve(callback: (String) -> ()) {
//        root.observeEventType(.Value, withBlock: {
//            snapshot in
//                var data = snapshot.value as String
//                callback(data)
//        })
    }
}

