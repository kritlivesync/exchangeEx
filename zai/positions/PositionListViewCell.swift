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
    
    func setPosition(position: Position?, btcJpyPrice: Double) {
        if let p = position {
            self.orderActionLabel.text = p.type
            let gain = (btcJpyPrice - p.cost) * p.balance
            self.marketPriceLabel.text = Int(p.balance * btcJpyPrice).description + ("(" + gain.description + ")")
            self.profitLabel.text = p.profit.description
            self.balanceLabel.text = p.balance.description
        } else {
            self.orderActionLabel.text = "-"
            self.marketPriceLabel.text = "-"
            self.profitLabel.text = "-"
            self.balanceLabel.text = "-"
        }
    }
    
    @IBOutlet weak var orderActionLabel: UILabel!
    @IBOutlet weak var marketPriceLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
}