//
//  ErrorSubview.swift
//  EPIC today
//
//  Created by Mialin Valentin on 30.06.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import UIKit



@IBDesignable class ErrorSubview: UIView {
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
    
    var view:UIView!

    @IBOutlet weak var errorStringLabel: UILabel!
    @IBOutlet weak var reloadPressed: UIButton!

    
    func loadViewFromNib() -> UIView {
        

        let nib = UINib(nibName: "ErrorSubview", bundle: nil)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        
        return view
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
