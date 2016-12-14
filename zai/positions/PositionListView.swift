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


@objc protocol PositionListViewDelegate {
    func didSelectPosition(_ position: Position)
}


class PositionListView : NSObject, UITableViewDelegate, UITableViewDataSource, FundDelegate, BitCoinDelegate {
    
    init(view: UITableView, trader: Trader) {
        self.trader = trader
        self.positions = trader.getActivePositions()
        self.view = view
        self.tappedRow = -1
        
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
        let c = self.positions.count
        return c
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "positionListViewCell", for: indexPath) as! PositionListViewCell
        cell.setPosition(self.positions[(indexPath as NSIndexPath).row] as? Position, btcPrice: self.btcPrice)
        cell.closeButton.addTarget(self, action: #selector(PositionListView.pushCloseButton(_:event:)), for: .touchUpInside)
        
        if indexPath.row % 2 == 0 {
            cell.backgroundColor = UIColor.white
        } else {
            cell.backgroundColor = UIColor(red: 0.93, green: 0.93, blue: 0.96, alpha: 1.0)
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tappedRow = (indexPath as NSIndexPath).row
        if self.delegate != nil {
            self.delegate!.didSelectPosition(self.positions[(indexPath as NSIndexPath).row] as! Position)
        }
    }
    
    func pushCloseButton(_ sender: AnyObject, event: UIEvent?) {
        var row = -1
        for touch in (event?.allTouches)! {
            let point = touch.location(in: self.view)
            row = (self.view.indexPathForRow(at: point)! as NSIndexPath).row
        }
        if 0 <= row && row < self.positions.count {
            let position = self.positions[row]
            let balance = position.balance
            let btcFundAmount = self.btcFund
            let amount = min(balance, btcFundAmount)
            if amount < 0.0001 {
                position.close()
                self.positions.remove(at: row)
                DispatchQueue.main.async {
                    self.reloadData()
                }
            } else {
                position.unwind(amount, price: nil) { err in
                    if let _ = err {
                        return
                    } else {
                        if btcFundAmount < balance {
                            position.close()
                        }
                        self.positions.remove(at: row)
                        DispatchQueue.main.async {
                            self.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    // FundDelegate
    func recievedMarketCapitalization(jpy: Int) {
        return
    }
    
    func recievedJpyFund(jpy: Int) {
        return
    }
    
    func recievedBtcFund(btc: Double) {
        self.btcFund = btc
    }
    
    // BitCoinDelegate
    func recievedJpyPrice(price: Int) {
        self.btcPrice = price
        self.reloadData()
    }
    
    internal func reloadData() {
        self.positions = trader.getActivePositions()
        self.view.reloadData()
    }
    
    internal func startWatch() {
        self.fund.delegate = self
        self.bitcoin.delegate = self
    }
    
    internal func stopWatch() {
        self.fund.delegate = nil
        self.bitcoin.delegate = nil
    }
    
    
    internal var delegate: PositionListViewDelegate? = nil
    fileprivate var positions: [Position]
    fileprivate let view: UITableView
    fileprivate var tappedRow: Int
    fileprivate var btcPrice: Int = -1
    fileprivate var btcFund: Double = 0.0
    
    var trader: Trader! = nil
    var fund: Fund! = nil
    var bitcoin: BitCoin! = nil
    
    
}
