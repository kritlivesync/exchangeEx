//
//  PositionListView.swift
//  zai
//
//  Created by 渡部郷太 on 9/4/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit

import ZaifSwift


protocol PositionListViewDelegate {
    func editPosition(position: Position)
}


class PositionListView : NSObject, UITableViewDelegate, UITableViewDataSource, FundDelegate, BitCoinDelegate, PositionListViewCellDelegate {
    
    init(view: UITableView, trader: Trader) {
        self.trader = trader
        self.positions = trader.activePositions
        self.view = view
        self.view.tableFooterView = UIView()
        self.view.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0);

        self.fund = Fund(api: trader.account.privateApi)
        self.bitcoin = BitCoin()
        
        super.init()
        self.view.delegate = self
        self.view.dataSource = self
        self.startWatch()
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.positions.count + 1 // + header
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 70.0
        } else {
            return 70.0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "positionListViewCell", for: indexPath) as! PositionListViewCell
        let row = indexPath.row
        if row == 0 {
            cell.setPosition(nil, btcJpyPrice: self.btcPrice)
        } else {
            let position = self.positions[row - 1]
            cell.setPosition(position, btcJpyPrice: self.btcPrice)
            cell.delegate = self
        }
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let cell = self.view.cellForRow(at: indexPath) as? PositionListViewCell else {
            return nil
        }
        cell.setPosition(cell.position, btcJpyPrice: self.btcPrice)
        var actions = [UITableViewRowAction]()
        if let delete = cell.deleteAction {
            actions.append(delete)
        }
        if let unwind = cell.unwind100Action {
            actions.append(unwind)
        }
        if let unwind = cell.unwind50Action {
            actions.append(unwind)
        }
        if let unwind = cell.unwind20Action {
            actions.append(unwind)
        }
        if let edit = cell.editingAction {
            actions.append(edit)
        }
        if actions.count == 0 {
            let empty = UITableViewRowAction(style: .normal, title: nil) { (_, _) in }
            empty.backgroundColor = UIColor.white
            return [empty]
        } else {
            return actions
        }
    }
    
    // FundDelegate    
    func recievedBtcFund(btc: Double) {
        self.btcFund = btc
    }
    
    // BitCoinDelegate
    func recievedJpyPrice(price: Int) {
        self.btcPrice = price
        for cell in self.view.visibleCells {
            let c = cell as! PositionListViewCell
            c.setPosition(c.position, btcJpyPrice: self.btcPrice)
        }
    }
    
    // PositionListViewCellDelegate
    func pushedDeleteButton(cell: PositionListViewCell, position: Position) {
        if self.trader.deletePosition(id: position.id) {
            self.positions = self.trader.allPositions
            if let index = self.view.indexPath(for: cell) {
                self.view.deleteRows(at: [index], with: UITableViewRowAnimation.fade)
            }
        }
    }
    
    func pushedEditButton(cell: PositionListViewCell, position: Position) {
        self.delegate?.editPosition(position: position)
    }
    
    func pushedUnwindButton(cell: PositionListViewCell, position: Position, rate: Double) {
        if let index = self.view.indexPath(for: cell) {
            self.view.reloadRows(at: [index], with: UITableViewRowAnimation.right)
        }
        let amount = position.balance * rate
        self.trader.unwindPosition(id: position.id, price: nil, amount: amount) { (err, _) in
            if err != nil {
                position.open()
            }
            cell.setPosition(position, btcJpyPrice: self.btcPrice)
        }
    }
    
    func addPosition(position: Position) {
        self.positions = self.trader.allPositions
        let row = self.view.numberOfRows(inSection: 0)
        let index = IndexPath(row: row, section: 0)
        self.view.insertRows(at: [index], with: UITableViewRowAnimation.bottom)
    }
    
    internal func reloadData() {
        self.positions = trader.allPositions
        self.view.reloadData()
    }
    
    internal func startWatch() {
        self.fund.delegate = self
        self.bitcoin.delegate = self
        self.reloadData()
    }
    
    internal func stopWatch() {
        self.fund.delegate = nil
        self.bitcoin.delegate = nil
    }
    
    
    fileprivate var positions: [Position]
    fileprivate let view: UITableView
    fileprivate var btcPrice: Int = -1
    fileprivate var btcFund: Double = 0.0
    
    var trader: Trader! = nil
    var fund: Fund! = nil
    var bitcoin: BitCoin! = nil
    var delegate: PositionListViewDelegate?
}
