//
//  TextSettingCell.swift
//  zai
//
//  Created by 渡部郷太 on 2/12/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import UIKit


protocol TextSettingCellDelegate {
    func shouldChangeCharactersIn(existingString: String, addedString: String, range: NSRange) -> Bool
}

class TextSettingCell : UITableViewCell {

    @IBOutlet weak var textField: UITextField!
    
    var delegate: TextSettingCellDelegate?
    
}
