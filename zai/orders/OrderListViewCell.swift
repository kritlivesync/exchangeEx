//
//  OrderListViewCell.swift
//  zai
//
//  Created by 渡部郷太 on 12/24/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit

class OrderListViewCell : UITableViewCell {
    
    internal func setOrder(order: ActiveOrder) {
        self.orderTimeLabel.text = formatDate(timestamp: Int64(order.timestamp))
        self.orderPriceLabel.text = formatValue(order.price)
        self.orderAmountLabel.text = formatValue(order.amount)
        
        if order.action == "bid" {
            let color = UIColor(red: 0.7, green: 0.4, blue: 0.4, alpha: 1.0)
            self.orderTimeLabel.textColor = color
            self.orderPriceLabel.textColor = color
            self.orderAmountLabel.textColor = color
        } else if order.action == "ask" {
            let color = UIColor(red: 0.4, green: 0.7, blue: 0.4, alpha: 1.0)
            self.orderTimeLabel.textColor = color
            self.orderPriceLabel.textColor = color
            self.orderAmountLabel.textColor = color
        }
    }
    
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var orderAmountLabel: UILabel!
    @IBOutlet weak var orderPriceLabel: UILabel!
    @IBOutlet weak var orderTimeLabel: UILabel!
}
