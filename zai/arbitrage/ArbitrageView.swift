//
//  ArbitrageView.swift
//  zai
//
//  Created by 渡部郷太 on 3/11/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol ArbitrageViewDelegate {
    func orderArbitrage(buyQuote: Quote, buyExchange: Exchange, sellQuote: Quote, sellExchange: Exchange, amount: Double)
}


class ArbitrageView : Monitorable, UITableViewDelegate, UITableViewDataSource, BoardDelegate, ArbitrageCellDelegate, MonitorableDelegate {
    
    init(view: UITableView) {
        self.view = view
        self.view.tableFooterView = UIView()
        self.view.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0);
        self.view.isScrollEnabled = false
        self.view.bounces = false
        
        super.init(target: "ArbitrageView")
        self.delegate = self
    
        self.view.delegate = self
        self.view.dataSource = self
    }
    
    public func start(leftExchange: Exchange, rightExchange: Exchange) {
        self.leftExchange = leftExchange
        self.rightExchange = rightExchange
        self.leftExchange.startWatch()
        self.rightExchange.startWatch()
        self.leftExchange.trader.startWatch()
        self.rightExchange.trader.startWatch()
        
        let currencyPair = ApiCurrencyPair(rawValue: leftExchange.currencyPair)!
        if self.leftBoard == nil {
            self.leftBoard = BoardMonitor(currencyPair: currencyPair, api: leftExchange.api, sender: "left")
            self.leftBoard.updateInterval = UpdateInterval.realTime
            self.leftBoard.delegate = self
        }
        if self.rightBoard == nil {
            self.rightBoard = BoardMonitor(currencyPair: currencyPair, api: rightExchange.api, sender: "right")
            self.rightBoard.updateInterval = UpdateInterval.realTime
            self.rightBoard.delegate = self
        }
    }
    
    public func stop() {
        self.leftExchange.stopWatch()
        self.rightExchange.stopWatch()
        self.leftExchange.trader.stopWatch()
        self.rightExchange.trader.stopWatch()
        if self.leftBoard != nil {
            self.leftBoard.delegate = nil
            self.leftBoard = nil
        }
        if self.rightBoard != nil {
            self.rightBoard.delegate = nil
            self.rightBoard = nil
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 6
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0, 1, 2, 3:
            return 35.0
        case 4, 5:
            return 70.0
        default:
            return 0.0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoValueCell", for: indexPath) as! TwoValueCell
            cell.setValues(leftValue: self.leftExchange.name, rightValue: self.rightExchange.name)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoValueCell", for: indexPath) as! TwoValueCell
            self.setJpyCell(cell: cell)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoValueCell", for: indexPath) as! TwoValueCell
            self.setBtcCell(cell: cell)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoValueCell", for: indexPath) as! TwoValueCell
            self.setCommissionCell(cell: cell)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: "arbitrageCell", for: indexPath) as! ArbitrageCell
            cell.setQuotes(leftQuote: nil, rightQuote: nil, isLeftToRight: true)
            cell.delegate = self
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "arbitrageCell", for: indexPath) as! ArbitrageCell
            cell.setQuotes(leftQuote: nil, rightQuote: nil, isLeftToRight: false)
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
            
        }
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        switch indexPath.row {
        case 0, 1, 2, 3:
            return nil
        case 4, 5:
            guard let cell = self.view.cellForRow(at: indexPath) as? ArbitrageCell else {
                return nil
            }
            var actions = [UITableViewRowAction]()
            if let action = cell.arbitrageButtonAction {
                actions.append(action)
            }
            if actions.count == 0 {
                let empty = UITableViewRowAction(style: .normal, title: nil) { (_, _) in }
                empty.backgroundColor = UIColor.white
                return [empty]
            } else {
                return actions
            }
        default:
            return nil
        }
    }
    
    // BoardDelegate
    func recievedBoard(err: ZaiErrorType?, board: Board?, sender: Any?) {
        guard let side = sender as? String else {
            return
        }
        guard let leftToRightCell = self.view.cellForRow(at: IndexPath(row: 4, section: 0)) as? ArbitrageCell else {
            return
        }
        guard let rightToLeftCell = self.view.cellForRow(at: IndexPath(row: 5, section: 0)) as? ArbitrageCell else {
            return
        }
        if err != nil {
            leftToRightCell.setQuotes(leftQuote: nil, rightQuote: nil, isLeftToRight: false)
            rightToLeftCell.setQuotes(leftQuote: nil, rightQuote: nil, isLeftToRight: false)
            return
        }
        let bestBid = board?.getBestBid()
        let bestAsk = board?.getBestAsk()
        
        if side == "left" {
            let rightBidQuote = leftToRightCell.rightQuote
            let rightAskQuote = rightToLeftCell.rightQuote
            leftToRightCell.setQuotes(leftQuote: bestAsk, rightQuote: rightBidQuote, isLeftToRight: true)
            rightToLeftCell.setQuotes(leftQuote: bestBid, rightQuote: rightAskQuote, isLeftToRight: false)
        } else {
            let leftAskQuote = leftToRightCell.leftQuote
            let leftBidQuote = rightToLeftCell.leftQuote
            leftToRightCell.setQuotes(leftQuote: leftAskQuote, rightQuote: bestBid, isLeftToRight: true)
            rightToLeftCell.setQuotes(leftQuote: leftBidQuote, rightQuote: bestAsk, isLeftToRight: false)
        }
        
        if let cell = self.view.cellForRow(at: IndexPath(row: 1, section: 0)) as? TwoValueCell {
            self.setJpyCell(cell: cell)
        }
        if let cell = self.view.cellForRow(at: IndexPath(row: 2, section: 0)) as? TwoValueCell {
            self.setBtcCell(cell: cell)
        }
        if let cell = self.view.cellForRow(at: IndexPath(row: 3, section: 0)) as? TwoValueCell {
            self.setCommissionCell(cell: cell)
        }
    }
    
    override func monitor() {
        guard let leftToRightCell = self.view.cellForRow(at: IndexPath(row: 4, section: 0)) as? ArbitrageCell else {
            return
        }
        guard let rightToLeftCell = self.view.cellForRow(at: IndexPath(row: 5, section: 0)) as? ArbitrageCell else {
            return
        }
        
        if self.isAuto {
            if leftToRightCell.priceDifferentials >= 10 {
                guard let buyQuote = leftToRightCell.leftQuote else {
                    return
                }
                guard let sellQuote = leftToRightCell.rightQuote else {
                    return
                }
                self.delegate2?.orderArbitrage(buyQuote: buyQuote, buyExchange: self.leftExchange, sellQuote: sellQuote, sellExchange: self.rightExchange, amount: leftToRightCell.transferAmount)
            }
            if rightToLeftCell.priceDifferentials >= 10 {
                guard let buyQuote = rightToLeftCell.rightQuote else {
                    return
                }
                guard let sellQuote = rightToLeftCell.leftQuote else {
                    return
                }
                self.delegate2?.orderArbitrage(buyQuote: buyQuote, buyExchange: self.rightExchange, sellQuote: sellQuote, sellExchange: self.leftExchange, amount: rightToLeftCell.transferAmount)
            }
        }
    }
    
    // ArbitrageCellDelegate
    func pushedArbitrageButton(leftQuote: Quote, rightQuote: Quote, amount: Double, isLeftToRight: Bool) {
        if isLeftToRight {
            self.delegate2?.orderArbitrage(buyQuote: leftQuote, buyExchange: self.leftExchange, sellQuote: rightQuote, sellExchange: self.rightExchange, amount: amount)
        } else {
            self.delegate2?.orderArbitrage(buyQuote: rightQuote, buyExchange: self.rightExchange, sellQuote: leftQuote, sellExchange: self.leftExchange, amount: amount)
        }
    }
    
    internal func reloadData() {
        self.view.reloadData()
    }
    
    fileprivate func setJpyCell(cell: TwoValueCell) {
        let leftJpy = formatValue(self.leftExchange.trader.jpyAvalilable) + "¥"
        let rightJpy = formatValue(self.rightExchange.trader.jpyAvalilable) + "¥"
        cell.setValues(leftValue: leftJpy, rightValue: rightJpy)
    }
    
    fileprivate func setBtcCell(cell: TwoValueCell) {
        let leftBtc = formatValue(self.leftExchange.trader.btcAvailable) + "Ƀ"
        let rightBtc = formatValue(self.rightExchange.trader.btcAvailable) + "Ƀ"
        cell.setValues(leftValue: leftBtc, rightValue: rightBtc)
    }
    
    fileprivate func setCommissionCell(cell: TwoValueCell) {
        let leftCommission = formatValue(self.leftExchange.commission) + "%"
        let rightCommission = formatValue(self.rightExchange.commission) + "%"
        cell.setValues(leftValue: leftCommission, rightValue: rightCommission)
    }

    fileprivate let view: UITableView
    fileprivate var leftExchange: Exchange!
    fileprivate var rightExchange: Exchange!
    fileprivate var leftBoard: BoardMonitor!
    fileprivate var rightBoard: BoardMonitor!
    fileprivate var isAuto = false
    
    var delegate2: ArbitrageViewDelegate?
}
