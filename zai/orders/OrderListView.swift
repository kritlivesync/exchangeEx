//
//  OrderListView.swift
//  zai
//
//  Created by 渡部郷太 on 12/24/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


class OrderListView : NSObject, UITableViewDelegate, UITableViewDataSource, ActiveOrderDelegate {
    
    init(view: UITableView, trader: Trader) {
        self.trader = trader
        self.orders = [ActiveOrder]()
        self.view = view
        self.view.tableFooterView = UIView()
        self.tappedRow = -1
        
        super.init()
        self.view.delegate = self
        self.view.dataSource = self
        self.orderMonitor = ActiveOrderMonitor(currencyPair: .BTC_JPY, api: self.trader.account.privateApi)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.orders.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "orderListViewCell", for: indexPath) as! OrderListViewCell
        cell.setOrder(order: self.orders[(indexPath as NSIndexPath).row])
        cell.cancelButton.addTarget(self, action: #selector(OrderListView.pushCancelButton(_:event:)), for: .touchUpInside)
        return cell
    }
    
    func pushCancelButton(_ sender: AnyObject, event: UIEvent?) {
        var row = -1
        for touch in (event?.allTouches)! {
            let point = touch.location(in: self.view)
            row = (self.view.indexPathForRow(at: point)! as NSIndexPath).row
        }
        
        if 0 <= row && row < self.orders.count {
            let order = self.orders[row]
            let repository = OrderRepository.getInstance()
            let api = self.trader.account.privateApi
            if let buyOrder = repository.findBuyOrderByOrderId(orderId: order.id, api: api!) {
                buyOrder.cancel() { err in
                    if err == nil {
                        repository.delete(buyOrder)
                    }
                }
            } else if let sellOrder = repository.findSellOrderByOrderId(orderId: order.id, api: api!) {
                sellOrder.cancel() { err in
                    if err == nil {
                        repository.delete(sellOrder)
                    }
                }
            } else {
                api!.cancelOrder(Int(order.id)!) { _ in }
            }
            
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
    

    internal var delegate: PositionListViewDelegate? = nil
    fileprivate var orders: [ActiveOrder]
    fileprivate let view: UITableView
    fileprivate var tappedRow: Int
    
    var trader: Trader! = nil
    var orderMonitor: ActiveOrderMonitor?
}
