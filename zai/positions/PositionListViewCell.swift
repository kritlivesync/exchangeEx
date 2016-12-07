//
//  PositionListViewCell.swift
//  zai
//
//  Created by 渡部郷太 on 9/8/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


class PositionListViewCell : UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setPosition(_ position: Position?) {
        if let p = position {
            self.priceLabel.text = p.price.description
            self.amountLabel.text = p.balance.description
        }
    }
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
}
