//
//  ArbitrageCell.swift
//  zai
//
//  Created by 渡部郷太 on 3/11/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol ArbitrageCellDelegate {
    func pushedArbitrageButton(leftQuote: Quote, rightQuote: Quote, amount: Double, isLeftToRight: Bool)
}


class ArbitrageCell : UITableViewCell {
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    func setQuotes(leftQuote: Quote?, rightQuote: Quote?, isLeftToRight: Bool) {
        if isLeftToRight {
            self.transferDirectionLabel.text = "----->"
        } else {
            self.transferDirectionLabel.text = "<-----"
        }
        
        self.leftQuote = leftQuote
        self.rightQuote = rightQuote
        
        if leftQuote == nil || rightQuote == nil {
            self.leftPriceLabel.text = "-"
            self.leftAmountLabel.text = "-"
            self.rightPriceLabel.text = "-"
            self.rightAmountLabel.text = "-"
            self.priceDifferentialsLabel.text = "-"
            self.transferAmountLabel.text = "-"
            self.arbitrageButtonAction = nil
            return
        }
        
        self.leftPriceLabel.text = formatValue(Int(leftQuote!.price))
        self.leftAmountLabel.text = formatValue(leftQuote!.amount)
        self.rightPriceLabel.text = formatValue(Int(rightQuote!.price))
        self.rightAmountLabel.text = formatValue(rightQuote!.amount)
        self.isLeftToRight = isLeftToRight
        self.leftQuote = leftQuote
        self.rightQuote = rightQuote
        self.transferAmount = min(rightQuote!.amount, leftQuote!.amount)
        self.transferAmountLabel.text = formatValue(self.transferAmount) + "Ƀ"
        
        if isLeftToRight {
            self.priceDifferentials = rightQuote!.price - leftQuote!.price
            self.priceDifferentialsLabel.text = formatValue(Int(self.priceDifferentials)) + "¥"
            self.transferAmount = min(rightQuote!.amount, leftQuote!.amount)
        } else {
            self.priceDifferentials = leftQuote!.price - rightQuote!.price
            self.priceDifferentialsLabel.text = formatValue(Int(self.priceDifferentials)) + "¥"
        }
        
        if self.priceDifferentials > 0 {
            self.priceDifferentialsLabel.text = "+" + self.priceDifferentialsLabel.text!
            self.priceDifferentialsLabel.textColor = Color.bidQuoteColor
        } else if self.priceDifferentials < 0 {
            self.priceDifferentialsLabel.textColor = Color.askQuoteColor
        } else {
            self.priceDifferentialsLabel.textColor = UIColor.black
        }
        
        self.arbitrageButtonAction = UITableViewRowAction(style: .normal, title: "\(LabelResource.argitrage)", handler: self.arbitrage)
    }
    
    fileprivate func arbitrage(_ : UITableViewRowAction, _ : IndexPath) {
        self.delegate?.pushedArbitrageButton(leftQuote: self.leftQuote, rightQuote: self.rightQuote, amount: self.transferAmount, isLeftToRight: self.isLeftToRight)
    }

    var isLeftToRight = false
    var priceDifferentials = 0.0
    var transferAmount = 0.0
    var leftQuote: Quote!
    var rightQuote: Quote!
    var arbitrageButtonAction: UITableViewRowAction?
    var delegate: ArbitrageCellDelegate?
    
    @IBOutlet weak var leftPriceLabel: UILabel!
    @IBOutlet weak var leftAmountLabel: UILabel!
    @IBOutlet weak var rightPriceLabel: UILabel!
    @IBOutlet weak var rightAmountLabel: UILabel!
    @IBOutlet weak var priceDifferentialsLabel: UILabel!
    @IBOutlet weak var transferAmountLabel: UILabel!
    @IBOutlet weak var transferDirectionLabel: UILabel!

}
