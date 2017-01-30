//
//  ValueActionSettingCell.swift
//  zai
//
//  Created by Kyota Watanabe on 1/12/17.
//  Copyright © 2017 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit


protocol ValueActionSettingDelegate {
    func action(cell: ValueActionSettingCell, actionName: String)
}


class ValueActionSettingCell : UITableViewCell {
    
    @IBAction func pushActionButton(_ sender: Any) {
        self.delegate?.action(cell: self, actionName: self.actionButton.titleLabel!.text!)
    }
    
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var delegate: ValueActionSettingDelegate?
}
