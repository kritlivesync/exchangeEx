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


class ArbitrageView : NSObject, UITableViewDelegate, UITableViewDataSource, BoardDelegate, ArbitrageCellDelegate {
    
    init(view: UITableView) {
        self.view = view
        self.view.tableFooterView = UIView()
        self.view.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0);
        self.view.isScrollEnabled = false
        self.view.bounces = false
        
        super.init()
    
        self.view.delegate = self
        self.view.dataSource = self
    }
    
    public func start(leftExchange: Exchange, rightExchange: Exchange) {
        self.leftExchange = leftExchange
        self.rightExchange = rightExchange
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
        return 5
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0, 1, 2:
            return 35.0
        case 3, 4:
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
            let leftJpy = formatValue(self.leftExchange.trader.jpyAvalilable) + "¥"
            let rightJpy = formatValue(self.rightExchange.trader.jpyAvalilable) + "¥"
            cell.setValues(leftValue: leftJpy, rightValue: rightJpy)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "twoValueCell", for: indexPath) as! TwoValueCell
            let leftBtc = formatValue(self.leftExchange.trader.btcAvailable) + "Ƀ"
            let rightBtc = formatValue(self.rightExchange.trader.btcAvailable) + "Ƀ"
            cell.setValues(leftValue: leftBtc, rightValue: rightBtc)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "arbitrageCell", for: indexPath) as! ArbitrageCell
            cell.setQuotes(leftQuote: nil, rightQuote: nil, isLeftToRight: true)
            cell.delegate = self
            return cell
        case 4:
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
        case 0, 1, 2:
            return nil
        case 3, 4:
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
        guard let leftToRightCell = self.view.cellForRow(at: IndexPath(row: 3, section: 0)) as? ArbitrageCell else {
            return
        }
        guard let rightToLeftCell = self.view.cellForRow(at: IndexPath(row: 4, section: 0)) as? ArbitrageCell else {
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
    }
    
    // ArbitrageCellDelegate
    func pushedArbitrageButton(leftQuote: Quote, rightQuote: Quote, amount: Double, isLeftToRight: Bool) {
        if isLeftToRight {
            self.delegate?.orderArbitrage(buyQuote: leftQuote, buyExchange: self.leftExchange, sellQuote: rightQuote, sellExchange: self.rightExchange, amount: amount)
        } else {
            self.delegate?.orderArbitrage(buyQuote: rightQuote, buyExchange: self.rightExchange, sellQuote: leftQuote, sellExchange: self.leftExchange, amount: amount)
        }
    }
    
    internal func reloadData() {
        self.view.reloadData()
    }

    fileprivate let view: UITableView
    fileprivate var leftExchange: Exchange!
    fileprivate var rightExchange: Exchange!
    fileprivate var leftBoard: BoardMonitor!
    fileprivate var rightBoard: BoardMonitor!
    var delegate: ArbitrageViewDelegate?
}
