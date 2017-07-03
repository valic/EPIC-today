//
//  ErrorSubview.swift
//  EPIC today
//
//  Created by Mialin Valentin on 30.06.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import UIKit

extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = 0.0
        rotateAnimation.toValue = CGFloat(Float.pi * 2)
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount=Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
}

@IBDesignable class ErrorSubview: UIView {
    var view:UIView!
    
    @IBOutlet weak var errorStringLabel: UILabel!
    @IBOutlet weak var reloadPressed: UIButton!
    var degree = CGFloat(Float.pi/10)
    
    
    func loadViewFromNib() -> UIView {
        
        let nib = UINib(nibName: "ErrorSubview", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
    }
    @IBAction func rotate(_ sender: UIButton) {
        sender.rotate360Degrees()
    }
    
    func xibSetup() {
        view = loadViewFromNib()
        view.frame = bounds
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        
        addSubview(view)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        xibSetup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        xibSetup()
    }
}
