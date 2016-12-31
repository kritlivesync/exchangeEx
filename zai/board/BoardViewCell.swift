//
//  BoardViewCell.swift
//  zai
//
//  Created by 渡部郷太 on 12/7/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//


import Foundation
import UIKit


protocol BoardViewCellDelegate {
    func pushedMakerButton(quote: Quote)
    func pushedTakerButton(quote: Quote)
}


class BoardViewCell : UITableViewCell {
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    func setQuote(_ quote: Quote?) {
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        guard let quote = quote else {
            let fontName = self.priceLabel.font.fontName
            let fontSize = CGFloat(17.0)
            self.priceLabel.text = "気配値"
            self.priceLabel.font = UIFont(name: fontName, size: fontSize)
            self.priceLabel.textColor = UIColor.black
            self.amountLabel.text = "気配数量"
            self.amountLabel.font = UIFont(name: fontName, size: fontSize)
            self.amountLabel.textColor = UIColor.black
            self.amountBarConstraint.constant = 0
            self.makerButtonAction = nil
            self.takerButtonAction = nil
            return
        }
        
        self.priceLabel.text = Int(quote.price).description
        self.amountLabel.text = quote.amount.description
        if quote.type == Quote.QuoteType.ASK {
            let color = Color.askQuoteColor
            self.priceLabel.textColor = color
            self.amountBar.backgroundColor = color
        } else if quote.type == Quote.QuoteType.BID {
            let color = Color.bidQuoteColor
            self.priceLabel.textColor = color
            self.amountBar.backgroundColor = color
        }
        var barWidth = CGFloat(quote.amount * 50.0)
        barWidth = min(barWidth, self.amountLabel.layer.bounds.width)
        self.amountBarConstraint.constant = barWidth
        
        self.quote = quote
        
        self.makerButtonAction = UITableViewRowAction(style: .normal, title: "Make") { (_, _) in
            self.delegate?.pushedMakerButton(quote: self.quote!)
        }
        self.makerButtonAction?.backgroundColor = Color.makerButtonColor
        
        self.takerButtonAction = UITableViewRowAction(style: .normal, title: "Take") { (_, _) in
            self.delegate?.pushedTakerButton(quote: self.quote!)
        }
        self.takerButtonAction?.backgroundColor = Color.takerButtonColor
    }
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountBar: UILabel!
    @IBOutlet weak var amountBarConstraint: NSLayoutConstraint!
    var quote: Quote?
    var delegate: BoardViewCellDelegate?
    var takerButtonAction: UITableViewRowAction?
    var makerButtonAction: UITableViewRowAction?
}
