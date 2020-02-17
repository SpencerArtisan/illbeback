//
//  EventView.swift
//  illbeback
//
//  Created by Spencer Ward on 14/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class EventView: UIView {
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var when: UILabel!
    
    var mapController: MapController!
    fileprivate var event: Flag?
    fileprivate var normalColor: UIColor?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadXib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadXib()
    }
    
    @IBAction func goto(_ sender: AnyObject) {
        print("go to \(event!.summary())")
        mapController.centerMap(event!.location())
    }
    
    func setEvent(_ event: Flag) {
        self.event = event
        title.text = " \(event.summary())"
        when.text = formatWhen(event)
        colorIfSoon()
    }
    
    fileprivate func formatWhen(_ event: Flag) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        
        if event.daysToGo() == 0 {
            return "today"
        } else if event.daysToGo() == 1 {
            return "tomorrow"
        } else if event.daysToGo() < 7 {
            return formatter.string(from: event.when()! as Date)
        } else {
            let formatter2 = DateFormatter()
            formatter2.dateFormat = "d MMM"
            return "\(formatter.string(from: event.when()! as Date))\r\n\(formatter2.string(from: event.when()! as Date))"
        }
    }
    
    fileprivate func colorIfSoon() {
        if event?.daysToGo() < 6 {
            normalColor = when.backgroundColor
            when.backgroundColor = UIColor.red.withAlphaComponent(0.86)
        } else {
            if normalColor != nil {
                when.backgroundColor = normalColor
            }
        }
    }
    
    fileprivate func loadXib() {
        containerView = (Bundle.main.loadNibNamed("Event", owner: self, options: nil)?[0] as! UIView)
        
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["containerView": containerView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[containerView]|", options: [], metrics: nil, views: views))
    }
}
