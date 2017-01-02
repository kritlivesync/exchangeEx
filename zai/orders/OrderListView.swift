//
//  OrderListView.swift
//  zai
//
//  Created by 渡部郷太 on 12/24/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


class OrderListView : NSObject, UITableViewDelegate, UITableViewDataSource, ActiveOrderDelegate, OrderListViewCellDelegate {
    
    init(view: UITableView, trader: Trader) {
        self.trader = trader
        self.orders = [ActiveOrder]()
        self.view = view
        self.view.tableFooterView = UIView()
        self.tappedRow = -1
        
        super.init()
        self.view.delegate = self
        self.view.dataSource = self
        self.orderMonitor = ActiveOrderMonitor(currencyPair: .BTC_JPY, api: self.trader.account.activeExchange.api)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orders.count + 1 // + header
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 20.0
        } else {
            return 70.0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderListViewCell", for: indexPath) as! OrderListViewCell
        let row = indexPath.row
        if row == 0 {
            cell.setOrder(order: nil)
        } else {
            let order = self.orders[row - 1]
            cell.setOrder(order: order)
            cell.delegate = self
        }

        return cell
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let cell = self.view.cellForRow(at: indexPath) as? OrderListViewCell else {
            return nil
        }
        var actions = [UITableViewRowAction]()
        if let action = cell.cancelAction {
            actions.append(action)
        }
        if actions.count == 0 {
            let empty = UITableViewRowAction(style: .normal, title: nil) { (_, _) in }
            empty.backgroundColor = UIColor.white
            return [empty]
        } else {
            return actions
        }
    }
    
    func pushedCancelButton(cell _: UITableViewCell, order: ActiveOrder) {
        let repository = OrderRepository.getInstance()
        let api = self.trader.account.activeExchange.api
        if let buyOrder = repository.findBuyOrderByOrderId(orderId: order.id, api: api) {
            buyOrder.cancel() { err in
                if err == nil {
                    repository.delete(buyOrder)
                }
            }
        } else if let sellOrder = repository.findSellOrderByOrderId(orderId: order.id, api: api) {
            sellOrder.cancel() { err in
                if err == nil {
                    repository.delete(sellOrder)
                }
            }
        } else {
            api.cancelOrder(order: order) { _ in }
        }
    }
    
    internal func reloadData() {
        self.view.reloadData()
    }
    
    internal func startWatch() {
        self.orderMonitor?.delegate = self
    }
    
    internal func stopWatch() {
        self.orderMonitor?.delegate = nil
    }
    
    // ActiveOrderDelegate
    func revievedActiveOrders(activeOrders: [String: ActiveOrder]) {
        self.orders.removeAll()
        for (_, order) in activeOrders {
            self.orders.append(order)
        }
        self.orders = self.orders.sorted{ $0.timestamp < $1.timestamp }
        DispatchQueue.main.async {
            self.reloadData()
        }
    }
    
    fileprivate var orders: [ActiveOrder]
    fileprivate let view: UITableView
    fileprivate var tappedRow: Int
    
    var trader: Trader! = nil
    var orderMonitor: ActiveOrderMonitor?
}
