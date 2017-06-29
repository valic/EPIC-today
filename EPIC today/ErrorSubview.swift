//
//  ErrorSubview.swift
//  EPIC today
//
//  Created by Mialin Valentin on 30.06.17.
//  Copyright © 2017 Mialin Valentin. All rights reserved.
//

import UIKit

class ErrorSubview: UIView {

    var id:Int?
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet var errorStringLabel: UILabel!
    
    @IBAction func reloadButton(_ sender: Any) {
    }
    
    

}
