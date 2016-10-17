//
//  TraderViewCell.swift
//  zai
//
//  Created by 渡部郷太 on 8/26/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


class TraderViewCell : UITableViewCell {
    
    func setTrader(_ trader: Trader?) {
        if let t = trader {
            var totalProfit = 0.0
            for position in t.positions {
                totalProfit += (position as! PositionProtocol).profit
            }
            self.nameLabel.text = t.name
            self.performanceLabel.text = totalProfit.description
            self.activePositionLabel.text = t.positions.count.description
            self.stateLabel.text = "Active"
        } else {
            self.nameLabel.text = "-"
            self.performanceLabel.text = "-"
            self.activePositionLabel.text = "-"
            self.stateLabel.text = "-"
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var performanceLabel: UILabel!
    @IBOutlet weak var activePositionLabel: UILabel!
    @IBOutlet weak var stateLabel: UILabel!
}
