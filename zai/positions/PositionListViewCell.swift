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
    
    func setPosition(_ position: Position?, btcPrice: Int) {
        if let p = position {
            self.priceLabel.text = Int(p.price).description
            self.amountLabel.text = formatValue(p.balance)
            if btcPrice < 0 {
                self.profitLabel.text = "-"
            } else {
                let profit = Int(p.profit + (Double(btcPrice) - p.price) * p.balance)
                let desc = formatValue(profit)
                self.profitLabel.text = (profit < 0) ? "" + desc : "+" + desc
                if profit < 0 {
                    self.profitLabel.textColor = UIColor.red
                } else {
                    self.profitLabel.textColor = UIColor.black
                }
            }
        }
    }
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!

}
