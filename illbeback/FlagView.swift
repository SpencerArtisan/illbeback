//
//  EventView.swift
//  illbeback
//
//  Created by Spencer Ward on 14/11/2015.
//  Copyright © 2015 Spencer Ward. All rights reserved.
//

import Foundation

class FlagView: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet weak var typeView: UIImageView!
    @IBOutlet weak var titleView: UILabel!
    @IBOutlet weak var bkgView: UILabel!
    
    var memories: MemoriesController!
    private var memory: Memory?
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
        print("go to \(memory!.summary())")
        memories.centerMap(memory!.location)
    }
    
    func setMemory(memory: Memory) {
        self.memory = memory
        titleView.text = " \(memory.summary())"
        colorByCategory()
    }
    
    private func colorByCategory() {
        typeView.image = CategoryController.getImageForCategory(self.memory!.type)
        bkgView.backgroundColor = CategoryController.getColorForCategory(self.memory!.type).colorWithAlphaComponent(0.8)
    }
    
    private func loadXib() {
        containerView = NSBundle.mainBundle().loadNibNamed("FlagView", owner: self, options: nil)[0] as! UIView
        
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["containerView": containerView]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[containerView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[containerView]|", options: [], metrics: nil, views: views))
    }
}