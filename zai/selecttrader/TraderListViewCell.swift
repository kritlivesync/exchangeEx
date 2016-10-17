//
//  TraderListViewCell.swift
//  zai
//
//  Created by 渡部郷太 on 8/27/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


class TraderListViewCell : UITableViewCell {
    
    func setTrader(_ trader: Trader?) {
        if let t = trader {
            self.nameLabel.text = t.name
            self.typeLabel.text = "Manual"
            var totalProfit = 0.0
            for position in t.positions {
                totalProfit += (position as! PositionProtocol).profit
            }
            self.performanceLabel.text = totalProfit.description
            self.activePositionLabel.text = t.positions.count.description
        } else {
            self.nameLabel.text = "-"
            self.typeLabel.text = "-"
            self.performanceLabel.text = "-"
            self.activePositionLabel.text = "-"
        }
    }
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var performanceLabel: UILabel!
    @IBOutlet weak var activePositionLabel: UILabel!

}
