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
            self.priceLabel.textColor = UIColor(red: 0.5, green: 0.8, blue: 0.5, alpha: 1.0)
            self.amountLabel.textColor = UIColor(red: 0.5, green: 0.8, blue: 0.5, alpha: 1.0)
        } else if quote.type == Quote.QuoteType.BID {
            self.priceLabel.textColor = UIColor(red: 0.8, green: 0.5, blue: 0.5, alpha: 1.0)
            self.amountLabel.textColor = UIColor(red: 0.8, green: 0.5, blue: 0.5, alpha: 1.0)
        }
    }
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var orderButton: UIButton!

}
