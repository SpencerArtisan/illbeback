//
//  EventView.swift
//  illbeback
//
//  Created by Spencer Ward on 14/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class EventView: UIView {
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var when: UILabel!
    
    var memories: MemoriesController!
    private var event: Memory?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    @IBAction func goto(sender: AnyObject) {
        print("go to \(event!.summary())")
        memories.centerMap(event!.location)
    }
    
    func setEvent(event: Memory) {
        self.event = event
        title.text = " \(event.summary())"
        when.text = formatWhen(event)
    }
    
    private func formatWhen(event: Memory) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE"
        
        if event.daysToGo() == 0 {
            return "today"
        } else if event.daysToGo() == 1 {
            return "tomorrow"
        } else if event.daysToGo() < 7 {
            return formatter.stringFromDate(event.when!)
        } else if event.daysToGo() < 14 {
            return "next\r\n\(formatter.stringFromDate(event.when!))"
        } else {
            let formatter2 = NSDateFormatter()
            formatter2.dateFormat = "d MMM"
            return "\(formatter.stringFromDate(event.when!))\r\n\(formatter2.stringFromDate(event.when!))"
        }
    
    }
    
    private func loadXib() {
        containerView = NSBundle.mainBundle().loadNibNamed("Event", owner: self, options: nil)[0] as! UIView
        
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["containerView": containerView]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[containerView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[containerView]|", options: [], metrics: nil, views: views))
    }
}