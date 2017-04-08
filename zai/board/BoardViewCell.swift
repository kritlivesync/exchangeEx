//
//  BoardViewCell.swift
//  zai
//
//  Created by Kyota Watanabe on 12/7/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//


import Foundation
import UIKit


protocol BoardViewCellDelegate {
    func pushedMakerButton(quote: Quote, cell: BoardViewCell)
    func pushedTakerButton(quote: Quote, cell: BoardViewCell)
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
            self.priceLabel.text = "-"
            self.amountLabel.text = "-"
            self.amountBarConstraint.constant = 0
            self.makerButtonAction = nil
            self.takerButtonAction = nil
            return
        }
        
        self.priceLabel.text = formatValue(Int(quote.price))
        self.amountLabel.text = formatValue(quote.amount)
        if quote.type == Quote.QuoteType.ASK {
            let color = Color.askQuoteColor
            self.priceLabel.textColor = color
            self.amountBar.backgroundColor = color
            self.takerButtonAction = UITableViewRowAction(style: .normal, title: LabelResource.buy) { (_, _) in
                self.delegate?.pushedTakerButton(quote: self.quote!, cell: self)
            }
            self.takerButtonAction?.backgroundColor = Color.takerButtonColor
        } else if quote.type == Quote.QuoteType.BID {
            let color = Color.bidQuoteColor
            self.priceLabel.textColor = color
            self.amountBar.backgroundColor = color
            self.takerButtonAction = UITableViewRowAction(style: .normal, title: LabelResource.sell) { (_, _) in
                self.delegate?.pushedTakerButton(quote: self.quote!, cell: self)
            }
            self.takerButtonAction?.backgroundColor = Color.takerButtonColor
        }
        var barWidth = CGFloat(quote.amount * 50.0)
        barWidth = min(barWidth, self.amountLabel.layer.bounds.width)
        self.amountBarConstraint.constant = barWidth
        
        self.quote = quote
        
        self.makerButtonAction = UITableViewRowAction(style: .normal, title: LabelResource.make) { (_, _) in
            self.delegate?.pushedMakerButton(quote: self.quote!, cell: self)
        }
        self.makerButtonAction?.backgroundColor = Color.makerButtonColor
    }
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var amountBar: UILabel!
    @IBOutlet weak var amountBarConstraint: NSLayoutConstraint!
    @IBOutlet weak var activeIndicator: UIActivityIndicatorView!
    var quote: Quote?
    var delegate: BoardViewCellDelegate?
    var takerButtonAction: UITableViewRowAction?
    var makerButtonAction: UITableViewRowAction?
}
