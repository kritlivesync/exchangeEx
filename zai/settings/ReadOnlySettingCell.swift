//
//  ReadOnlySettingCell.swift
//  zai
//
//  Created by 渡部郷太 on 1/11/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


class ReadOnlySettingCell : UITableViewCell {
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
}
