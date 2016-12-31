//
//  OrderListViewCell.swift
//  zai
//
//  Created by 渡部郷太 on 12/24/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol OrderListViewCellDelegate {
    func pushedCancelButton(cell: UITableViewCell, order: ActiveOrder)
}


class OrderListViewCell : UITableViewCell {
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    internal func setOrder(order: ActiveOrder?) {
        guard let order = order else {
            let fontName = self.orderTimeLabel.font.fontName
            let fontSize = CGFloat(17.0)
            self.orderTimeLabel.text = "注文日時"
            self.orderTimeLabel.font = UIFont(name: fontName, size: fontSize)
            self.orderTimeLabel.textColor = UIColor.black
            self.orderPriceLabel.text = "価格"
            self.orderPriceLabel.font = UIFont(name: fontName, size: fontSize)
            self.orderPriceLabel.textColor = UIColor.black
            self.orderAmountLabel.text = "数量"
            self.orderAmountLabel.font = UIFont(name: fontName, size: fontSize)
            self.orderAmountLabel.textColor = UIColor.black
            self.cancelAction = nil
            return
        }
        self.order = order
        
        self.orderTimeLabel.text = formatDate(timestamp: Int64(order.timestamp))
        self.orderPriceLabel.text = formatValue(Int(order.price))
        self.orderAmountLabel.text = formatValue(order.amount)
        
        if order.action == "bid" {
            self.orderTimeLabel.textColor = Color.bidQuoteColor
            self.orderPriceLabel.textColor = Color.bidQuoteColor
            self.orderAmountLabel.textColor = Color.bidQuoteColor
        } else if order.action == "ask" {
            self.orderTimeLabel.textColor = Color.askQuoteColor
            self.orderPriceLabel.textColor = Color.askQuoteColor
            self.orderAmountLabel.textColor = Color.askQuoteColor
        }
        
        self.cancelAction = UITableViewRowAction(style: .normal, title: "取消し") { (_, _) in
            self.delegate?.pushedCancelButton(cell: self, order: self.order!)
        }
        self.cancelAction?.backgroundColor = UIColor.red
    }
    
    @IBOutlet weak var orderAmountLabel: UILabel!
    @IBOutlet weak var orderPriceLabel: UILabel!
    @IBOutlet weak var orderTimeLabel: UILabel!
    var order: ActiveOrder?
    var cancelAction: UITableViewRowAction?
    var delegate: OrderListViewCellDelegate?
}
