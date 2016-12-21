//
//  FlagRepository.swift
//  illbeback
//
//  Created by Spencer Ward on 04/12/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation
import CoreData

class FlagRepository : NSObject {
    fileprivate var _flags = [Flag]()
    fileprivate var _mutex = pthread_mutex_t()
    
    override init() {
        super.init()
        Utils.addObserver(self, selector: #selector(FlagRepository.onFlagChanged), event: "FlagChanged")
        Utils.addObserver(self, selector: #selector(FlagRepository.onFlagChanged), event: "InviteeChanged")
    }
    
    func onFlagChanged(_ note: Notification) {
        print("Flag change")
        let flag = note.userInfo!["flag"] as! Flag
        save(flag)
    }
    
    func flags() -> [Flag] {
        return _flags.filter {$0.state() != .Dead}
    }
    
    func receive(_ from: String, to: String, flag: Flag, onNew: (_ newFlag: Flag) -> (), onUpdate: (_ updatedFlag: Flag) -> (), onAck: (_ ackedFlag: Flag?) -> ()) {
        do {
            var originalFlag = find(flag.id())
            
            if originalFlag == nil {
                // todo - better handing for declining deleted flags
                if !isDecline(from, flag: flag) {
                    print("Receiving new flag from \(from) to \(to)")
                    Utils.notifyObservers("FlagReceiving", properties: ["flag": flag, "from": from])
                    try flag.receivingNew(from)
                    onNew(flag)
                    originalFlag = flag
                } else {
                    onAck(nil)
                }
            } else if !isAck(from, flag: flag) {
                print("Receiving updated flag from \(from) to \(to)")
                originalFlag!.receivingUpdate(from, flag: flag)
                Utils.notifyObservers("FlagReceiving", properties: ["flag": flag, "from": from])
                onUpdate(originalFlag!)
            }
            
            if originalFlag != nil {
                if isAck(from, flag: flag) {
                    let invitee = originalFlag!.findInvitee(from)
                    if invitee != nil {
                        let inviteeState = flag.findInvitee(from)!.state()
                        
                        if inviteeState == .Accepting {
                            invitee!.acceptSuccess()
                            onAck(originalFlag!)
                        } else if inviteeState == .Declining {
                            invitee!.declineSuccess()
                            onAck(originalFlag!)
                        }
                    } else {
                        onAck(nil)
                    }
                } else {
                    let invitee = originalFlag!.findInvitee(to)
                    if invitee != nil {
                        invitee!.inviteSuccess()
                    }
                }
                Utils.notifyObservers("InviteeChanged", properties: ["flag": originalFlag!])
            }
        } catch {
            print("** Failed to receive flag: \(flag)")
        }
    }
    
    fileprivate func isAck(_ from: String, flag: Flag) -> Bool {
        let inviteeState = flag.findInvitee(from)?.state()
        return inviteeState != nil && (inviteeState! == .Accepting || inviteeState! == .Declining)
    }
    
    fileprivate func isDecline(_ from: String, flag: Flag) -> Bool {
        let inviteeState = flag.findInvitee(from)?.state()
        return inviteeState != nil && inviteeState! == .Declining
    }
    
    func create(_ flag: Flag) {
        add(flag)
        save(flag)
    }
    
    fileprivate func add(_ flag: Flag) {
        if (find(flag.id()) != nil) {
            print("Duplicate flag added to repo: \(flag.encode())")
            _flags.removeObject(flag)
        } else {
            print("Adding flag to repo: \(flag.encode())")
        }
        
        _flags.append(flag)
        Utils.notifyObservers("FlagAdded", properties: ["flag": flag])
    }
    
    func remove(_ flag: Flag) {
        print("Removing \(flag.type()) from repo")
        _flags.removeObject(flag)
        Utils.notifyObservers("FlagRemoved", properties: ["flag": flag])
        unsave(flag)
    }
    
    func removeAll() {
        flags().forEach { remove($0) }
    }
    
    func find(_ id: String) -> Flag? {
        return flags().filter {$0.id() == id}.first
    }
    
    func events() -> [Flag] {
        let all = flags().filter {$0.when() != nil }
        return all.sorted {$0.daysToGo() < $1.daysToGo()}
    }
    
    func new() -> [Flag] {
        return flags().filter {$0.state() == FlagState.ReceivedNew || $0.state() == FlagState.ReceivedUpdate}
    }
    
    func imminentEvents() -> [Flag] {
        let imminent = flags().filter {$0.when() != nil && $0.daysToGo() < 6 && $0.daysToGo() >= 0}
        return imminent.sorted {$0.daysToGo() < $1.daysToGo()}
    }
    
    func purge() {
        _flags.filter({self.isPurgable($0)}).forEach {self.remove($0)}
    }
    
    fileprivate func isPurgable(_ flag: Flag) -> Bool {
        return flag.isPast() || flag.state() == .Dead
    }

    func read() {
        readFromCoreData()
        if _flags.count == 0 {
            print("No flags found in core data. Reading from file instead")
            readFromFile()
        }
    }
    
    func readFromFile() {
        let path = filePath()
        let fileManager = FileManager.default
        if (!(fileManager.fileExists(atPath: path))) {
            let bundle : NSString = Bundle.main.path(forResource: "memories", ofType: "plist")! as NSString
            do {
                try fileManager.copyItem(atPath: bundle as String, toPath: path)
            } catch {
                print("Failed to read local flag store")
            }
        }
        
        let props = NSDictionary(contentsOfFile: path)?.mutableCopy() as! NSDictionary
        
        let encodedFlags = (props.value(forKey: "Memories") ?? []) as! [String]
        encodedFlags.map {encodedFlag in Flag.decode(encodedFlag)}
                    .forEach {flag in
                        if !self.isPurgable(flag) { self.create(flag) }
                    }
    }
    
    func readFromCoreData () {
        //create a fetch request, telling it about the entity
        let fetchRequest: NSFetchRequest<FlagEntity> = FlagEntity.fetchRequest()
        
        do {
            //go get the results
            let searchResults = try getContext().fetch(fetchRequest)
            
            //I like to check the size of the returned results!
            print ("num of results = \(searchResults.count)")
            
            //You need to convert to NSManagedObject to use 'for' loops
            for entity in searchResults as [NSManagedObject] {
                //get the Key Value pairs (although there may be a better way to do that...
                let encoded = entity.value(forKey: "encoded") as! String
                print("Read: " + encoded)
                let flag = Flag.decode(encoded)
                if !isPurgable(flag) {
                    self.add(flag)
                }
            }
        } catch {
            print("Error with request: \(error)")
        }
    }

    func unsave(_ flag: Flag) {
        let context = getContext()
        do {
            let searchResults = try read(id: flag.id(), context: context)
            for entity in searchResults as [NSManagedObject] {
                print("Delete \(flag.encode())")
                context.delete(entity)
            }
            try context.save()
        }
        catch {
                print("Error with request: \(error)")
        }
    }
    
    fileprivate func read(id: String, context: NSManagedObjectContext) throws -> [FlagEntity] {
        let fetchRequest: NSFetchRequest<FlagEntity> = FlagEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id)
        return try context.fetch(fetchRequest)
    }
    
    func save(_ flag: Flag) {
        print("Saving \(flag)")
        let context = getContext()
        
        do {
            var searchResults = try read(id: flag.id(), context: context)
            if searchResults.count > 0 {
                print ("Found \(searchResults.count) flags with duplicate ids")
                let toAmend = searchResults.remove(at: 0)
                for entity in searchResults as [NSManagedObject] {
                    print("Deleting duplicate")
                    context.delete(entity)
                }
                print("Amend existing flag")
                toAmend.setValue(flag.encode(), forKey: "encoded")
            } else {
                print("Insert new flag")
                let entity =  NSEntityDescription.entity(forEntityName: "FlagEntity", in: context)
                let obj = NSManagedObject(entity: entity!, insertInto: context)
                obj.setValue(flag.encode(), forKey: "encoded")
                obj.setValue(flag.id(), forKey: "id")
            }
            try context.save()
        } catch {
            print("Error with request: \(error)")
        }
    }
    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    fileprivate func filePath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let path = paths[0] as NSString
        return path.appendingPathComponent("memories.plist")
    }
    
//    internal func slowsync<R>(_ f: () -> R) -> R {
//        pthread_mutex_lock(&_mutex)
//        let r = f()
//        pthread_mutex_unlock(&_mutex)
//        return r
//    }
}
