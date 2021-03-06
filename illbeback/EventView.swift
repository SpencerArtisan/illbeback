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
    
    var mapController: MapController!
    private var event: Flag?
    private var normalColor: UIColor?
    
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
        mapController.centerMap(event!.location())
    }
    
    func setEvent(event: Flag) {
        self.event = event
        title.text = " \(event.summary())"
        when.text = formatWhen(event)
        colorIfSoon()
    }
    
    private func formatWhen(event: Flag) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "EEE"
        
        if event.daysToGo() == 0 {
            return "today"
        } else if event.daysToGo() == 1 {
            return "tomorrow"
        } else if event.daysToGo() < 7 {
            return formatter.stringFromDate(event.when()!)
        } else {
            let formatter2 = NSDateFormatter()
            formatter2.dateFormat = "d MMM"
            return "\(formatter.stringFromDate(event.when()!))\r\n\(formatter2.stringFromDate(event.when()!))"
        }
    }
    
    private func colorIfSoon() {
        if event?.daysToGo() < 2 {
            normalColor = when.backgroundColor
            when.backgroundColor = UIColor.redColor().colorWithAlphaComponent(0.86)
        } else {
            if normalColor != nil {
                when.backgroundColor = normalColor
            }
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