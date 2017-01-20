//
//  ValueActionSettingCell.swift
//  zai
//
//  Created by 渡部郷太 on 1/12/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol ValueActionSettingDelegate {
    func action(actionName: String)
}


class ValueActionSettingCell : UITableViewCell {
    
    @IBAction func pushActionButton(_ sender: Any) {
        self.delegate?.action(actionName: self.actionButton.titleLabel!.text!)
    }
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var delegate: ValueActionSettingDelegate?
}
