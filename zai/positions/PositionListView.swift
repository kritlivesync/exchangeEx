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


class PositionListView : NSObject, UITableViewDelegate, UITableViewDataSource, BitCoinDelegate, PositionListViewCellDelegate {
    
    init(view: UITableView, trader: Trader) {
        self.trader = trader
        self.positions = [Position]()
        self.view = view
        self.view.tableFooterView = UIView()
        self.view.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0);
        
        super.init()
        self.updatePositionList()
        self.view.delegate = self
        self.view.dataSource = self
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.positions.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "positionListViewCell", for: indexPath) as! PositionListViewCell
        let row = indexPath.row
        let position = self.positions[row]
        cell.setPosition(position, btcJpyPrice: self.btcPrice)
        cell.delegate = self
        
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
    
    // MonitorableDelegate
    func getDelegateName() -> String {
        return "PositionListView"
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
            self.updatePositionList()
            if let index = self.view.indexPath(for: cell) {
                self.view.deleteRows(at: [index], with: UITableViewRowAnimation.fade)
            }
        }
    }
    
    func pushedEditButton(cell: PositionListViewCell, position: Position) {
        if cell.activeIndicator.isAnimating {
            return
        }
        self.delegate?.editPosition(position: position)
    }
    
    func pushedUnwindButton(cell: PositionListViewCell, position: Position, rate: Double) {
        if cell.activeIndicator.isAnimating {
            return
        }
        cell.activeIndicator.startAnimating()
        
        if let index = self.view.indexPath(for: cell) {
            self.view.reloadRows(at: [index], with: UITableViewRowAnimation.right)
        }
        var amount = position.balance * rate
        amount = max(amount, self.trader.exchange.api.orderUnit(currencyPair: position.currencyPair))
        self.trader.exchange.api.getTicker(currencyPair: position.currencyPair) { (err, tick) in
            self.trader.unwindPosition(id: position.id, price: tick.bid, amount: amount) { (err, _) in
                if err != nil {
                    position.open()
                }
                cell.setPosition(position, btcJpyPrice: self.btcPrice)
                cell.activeIndicator.stopAnimating()
            }
        }
    }
    
    func addPosition(position: Position) {
        self.updatePositionList()
        let row = self.view.numberOfRows(inSection: 0)
        let index = IndexPath(row: row, section: 0)
        self.view.insertRows(at: [index], with: UITableViewRowAnimation.bottom)
    }
    
    func updatePositionList() {
        self.positions.removeAll()
        for pos in self.trader.allPositions {
            if !pos.isDelete && !pos.isOpening {
                self.positions.append(pos)
            }
        }
    }
    
    internal func reloadData() {
        self.updatePositionList()
        self.view.reloadData()
    }
    
    internal func startWatch() {
        let api = self.trader.exchange.api
        self.bitcoin = BitCoin(api: api)
        let interval = getPositionsConfig().positionUpdateIntervalType
        self.bitcoin.monitoringInterval = interval
        self.bitcoin.delegate = self
        self.reloadData()
    }
    
    internal func stopWatch() {
        self.bitcoin.delegate = nil
        self.bitcoin = nil
    }
    
    
    fileprivate var positions: [Position]
    fileprivate let view: UITableView
    fileprivate var btcPrice: Int = -1
    
    var trader: Trader! = nil
    var bitcoin: BitCoin! = nil
    var delegate: PositionListViewDelegate?
}
