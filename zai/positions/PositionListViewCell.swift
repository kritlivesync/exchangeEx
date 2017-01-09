//
//  PositionListViewCell.swift
//  zai
//
//  Created by 渡部郷太 on 9/8/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol PositionListViewCellDelegate {
    func pushedDeleteButton(cell: PositionListViewCell, position: Position)
    func pushedEditButton(cell: PositionListViewCell, position: Position)
    func pushedUnwindButton(cell: PositionListViewCell, position: Position, rate: Double)
}

class PositionListViewCell : UITableViewCell {
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.selectionStyle = UITableViewCellSelectionStyle.none
    }
    
    func setPosition(_ position: Position?, btcJpyPrice: Int) {
        guard let p = position else {
            let fontName = self.priceLabel.font.fontName
            let fontSize = CGFloat(17.0)
            self.priceLabel.text = "取得価格"
            self.priceLabel.textColor = UIColor.black
            self.priceLabel.font = UIFont(name: fontName, size: fontSize)
            self.amountLabel.text = "数量"
            self.amountLabel.textColor = UIColor.black
            self.amountLabel.font = UIFont(name: fontName, size: fontSize)
            self.balanceLabel.text = "(残高)"
            self.balanceLabel.textColor = UIColor.black
            self.balanceLabel.font = UIFont(name: fontName, size: fontSize)
            self.profitLabel.text = "損益"
            self.profitLabel.textColor = UIColor.black
            self.profitLabel.font = UIFont(name: fontName, size: fontSize)
            self.statusLabel.text = "状態"
            self.statusLabel.textColor = UIColor.black
            self.statusLabel.font = UIFont(name: fontName, size: fontSize)
            self.deleteAction = nil
            self.unwind100Action = nil
            self.unwind50Action = nil
            self.unwind20Action = nil
            self.editingAction = nil
            return
        }
        self.position = p
        
        self.priceLabel.text = formatValue(Int(p.price))
        self.amountLabel.text = formatValue(p.amount)
        self.balanceLabel.text = "(" + formatValue(p.balance) + ")"
        self.updateProfit(btcJpyPrice: btcJpyPrice)
        
        let status = PositionState(rawValue: p.status.intValue)!
        self.statusLabel.text = status.toString()
        
        self.deleteAction = nil
        self.unwind100Action = nil
        self.unwind50Action = nil
        self.unwind20Action = nil
        self.editingAction = nil
        if status.isDelete == false {
            self.deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
                self.delegate?.pushedDeleteButton(cell: self, position: self.position!)
            }
            self.deleteAction?.backgroundColor = UIColor.red
        }
        
        /*
         if status.isOpen || status.isWaiting {
         self.editingAction = UITableViewRowAction(style: .normal, title: "Edit") { (_, _) in
         self.delegate?.pushedEditButton(cell: self, position: self.position!)
         }
         self.editingAction?.backgroundColor = Color.keyColor
         }
         */
        
        if status.isOpen {
            self.unwind100Action = UITableViewRowAction(style: .normal, title: "Unwind\n(100%)") { (_, _) in
                self.delegate?.pushedUnwindButton(cell: self, position: self.position!, rate: 1.0)
            }
            self.unwind100Action?.backgroundColor = Color.unwind100Color
            self.unwind50Action = UITableViewRowAction(style: .normal, title: "Unwind\n(50%)") { (_, _) in
                self.delegate?.pushedUnwindButton(cell: self, position: self.position!, rate: 0.5)
            }
            self.unwind50Action?.backgroundColor = Color.unwind50Color
            self.unwind20Action = UITableViewRowAction(style: .normal, title: "Unwind\n(20%)") { (_, _) in
                self.delegate?.pushedUnwindButton(cell: self, position: self.position!, rate: 0.2)
            }
            self.unwind20Action?.backgroundColor = Color.unwind20Color
        }
        
        if status.isClosed {
            self.backgroundColor = Color.closedPositionColor
        } else {
            self.backgroundColor = UIColor.white
        }
    }
    
    func updateProfit(btcJpyPrice: Int) {
        guard let position = self.position else {
            self.profitLabel.text = "-"
            return
        }
        if btcJpyPrice < 0 {
            self.profitLabel.text = "-"
            return
        }
        
        let profit = Int(position.profit + (Double(btcJpyPrice) - position.price) * position.balance)
        let desc = formatValue(profit)
        self.profitLabel.text = (profit < 0) ? "" + desc : "+" + desc
        if profit < 0 {
            self.profitLabel.textColor = Color.askQuoteColor
        } else {
            self.profitLabel.textColor = Color.bidQuoteColor
        }
    }
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    var deleteAction: UITableViewRowAction?
    var editingAction: UITableViewRowAction?
    var unwind100Action: UITableViewRowAction?
    var unwind50Action: UITableViewRowAction?
    var unwind20Action: UITableViewRowAction?
    var position: Position?
    var delegate: PositionListViewCellDelegate?
}
