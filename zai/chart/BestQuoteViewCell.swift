//
//  BestQuoteViewCell.swift
//  zai
//
//  Created by 渡部郷太 on 1/10/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol BestQuoteViewCellDelegate {
    func pushedTakerButton(quote: Quote)
}


class BestQuoteViewCell : UITableViewCell {
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    func setQuote(quote: Quote?) {
        self.selectionStyle = UITableViewCellSelectionStyle.none
        
        guard let q = quote else {
            self.priceLabel.text = "-"
            self.amountLabel.text = "-"
            return
        }
        
        self.quote = q
        
        self.priceLabel.text = formatValue(Int(q.price))
        self.amountLabel.text = formatValue(q.amount)
        switch q.type {
        case .ASK:
            self.quoteTypeLabel.text = "ベストアスク"
            self.takerButtonAction = UITableViewRowAction(style: .normal, title: "買う", handler: self.take)
            self.takerButtonAction!.backgroundColor = Color.keyColor
        case .BID:
            self.quoteTypeLabel.text = "ベストビッド"
            self.takerButtonAction = UITableViewRowAction(style: .normal, title: "売る", handler: self.take)
            self.takerButtonAction!.backgroundColor = Color.antiKeyColor2
        }
    }
    
    fileprivate func take(_ : UITableViewRowAction, _ : IndexPath) {
        self.delegate?.pushedTakerButton(quote: self.quote!)
    }
    
    var takerButtonAction: UITableViewRowAction?
    var quote: Quote?
    var delegate: BestQuoteViewCellDelegate?
    
    @IBOutlet weak var quoteTypeLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
}
