//
//  BoardViewCell.swift
//  zai
//
//  Created by 渡部郷太 on 12/7/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//


import Foundation
import UIKit


class BoardViewCell : UITableViewCell {
    
    func setQuote(_ quote: Quote) {
        self.priceLabel.text = quote.price.description
        self.amountLabel.text = quote.amount.description
        if quote.type == Quote.QuoteType.ASK {
            let color = UIColor(red: 0.4, green: 0.7, blue: 0.4, alpha: 1.0)
            self.priceLabel.textColor = color
            self.amountBar.backgroundColor = color
            //self.amountLabel.textColor = color
        } else if quote.type == Quote.QuoteType.BID {
            let color = UIColor(red: 0.7, green: 0.4, blue: 0.4, alpha: 1.0)
            self.priceLabel.textColor = color
            self.amountBar.backgroundColor = color
            //self.amountLabel.textColor = color
        }
        var barWidth = CGFloat(quote.amount * 50.0)
        barWidth = min(barWidth, self.amountLabel.layer.bounds.width)
        self.amountBarConstraint.constant = barWidth
    }
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var takerButton: UIButton!
    @IBOutlet weak var makerButton: UIButton!
    @IBOutlet weak var amountBar: UILabel!
    @IBOutlet weak var amountBarConstraint: NSLayoutConstraint!
}
