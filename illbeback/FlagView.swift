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
    
    var mapController: MapController!
    fileprivate var flag: Flag?
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
        print("go to \(flag!.summary())")
        mapController.centerMap(flag!.location())
    }
    
    func setFlag(_ flag: Flag) {
        self.flag = flag
        titleView.text = " \(flag.summary())"
        colorByCategory()
    }
    
    fileprivate func colorByCategory() {
        typeView.image = CategoryController.getImageForCategory(self.flag!.type())
        bkgView.backgroundColor = CategoryController.getColorForCategory(self.flag!.type()).withAlphaComponent(0.8)
    }
    
    fileprivate func loadXib() {
        containerView = Bundle.main.loadNibNamed("FlagView", owner: self, options: nil)?[0] as! UIView
        
        self.addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let views = ["containerView": containerView]
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[containerView]|", options: [], metrics: nil, views: views))
        self.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[containerView]|", options: [], metrics: nil, views: views))
    }
}
