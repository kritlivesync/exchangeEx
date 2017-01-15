//
//  VariableSettingCell.swift
//  zai
//
//  Created by 渡部郷太 on 1/14/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol VariableSettingCellDelegate {
    func touchesEnded(name: String, value: String)
}


class VariableSettingCell : UITableViewCell {
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
    }
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        self.delegate?.touchesEnded(name: self.nameLabel.text!, value: self.valueLabel.text!)
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    
    var delegate: VariableSettingCellDelegate?

}
