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
    func pushedUnwindButton(cell: PositionListViewCell, position: Position)
}

class PositionListViewCell : UITableViewCell {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func setPosition(_ position: Position?, btcJpyPrice: Int) {
        self.selectionStyle = UITableViewCellSelectionStyle.none
        if let p = position {
            self.position = p
            
            self.priceLabel.text = formatValue(Int(p.price))
            self.amountLabel.text = formatValue(p.balance)
            self.updateProfit(btcJpyPrice: btcJpyPrice)
            
            let status = PositionState(rawValue: p.status.intValue)!
            self.statusLabel.text = status.toString()
            
            self.deleteAction = nil
            self.unwindAction = nil
            self.editingAction = nil
            if status.isOpen || status.isClosed || status.isWaiting {
                self.deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (_, _) in
                    self.delegate?.pushedDeleteButton(cell: self, position: self.position!)
                }
                self.deleteAction?.backgroundColor = Color.keyColor
            }
            
            if status.isOpen || status.isWaiting {
                self.editingAction = UITableViewRowAction(style: .normal, title: "Edit") { (_, _) in
                    self.delegate?.pushedEditButton(cell: self, position: self.position!)
                }
                self.editingAction?.backgroundColor = Color.keyColor
            }
            
            if status.isOpen {
                self.unwindAction = UITableViewRowAction(style: .normal, title: "Unwind") { (_, _) in
                    self.delegate?.pushedUnwindButton(cell: self, position: self.position!)
                }
                self.unwindAction?.backgroundColor = Color.keyColor
            }
            
            if status.isClosed {
                self.backgroundColor = Color.closedPositionColor
            } else {
                self.backgroundColor = UIColor.white
            }
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
            self.profitLabel.textColor = UIColor.red
        } else {
            self.profitLabel.textColor = UIColor.black
        }
    }
    
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var profitLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    var deleteAction: UITableViewRowAction?
    var editingAction: UITableViewRowAction?
    var unwindAction: UITableViewRowAction?
    var position: Position?
    var delegate: PositionListViewCellDelegate?
}
