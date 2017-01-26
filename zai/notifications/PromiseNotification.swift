//
//  PromiseNotification.swift
//  zai
//
//  Created by 渡部郷太 on 1/26/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UserNotifications


class PromiseNotification : NSObject, UNUserNotificationCenterDelegate, PositionDelegate {
    
    override init() {
        super.init()
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert], completionHandler: { (granted, error) in
        })
        center.delegate = self
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Swift.Void) {
        completionHandler(.alert)
    }
    
    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Swift.Void) {
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
    }
    
    public func add(promisedOrder: PromisedOrder, exchange: Exchange) {
        let content = UNMutableNotificationContent()
        if promisedOrder.action == "bid" {
            content.title = "買い注文が約定しました"
        } else if promisedOrder.action == "ask" {
            content.title = "売り注文が約定しました"
        } else {
            return
        }
        let exchangeName = "取引所: \(exchange.name)"
        let currencyPair = exchange.displayCurrencyPair
        let price = "価格: \(formatValue(Int(promisedOrder.price)))¥"
        let amount = "数量: \(promisedOrder.newlyPromisedAmount)Ƀ"
        let sum = "合計金額: \(formatValue(Int(promisedOrder.price * promisedOrder.newlyPromisedAmount)))"
        
        content.subtitle = exchangeName + "(\(currencyPair))"
        content.body = price + "\n" + amount + "\n" + sum

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
        let request = UNNotificationRequest(identifier: "promised",
                                            content: content,
                                            trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    // PositionDelegate
    func opendPosition(position: Position, promisedOrder: PromisedOrder) {
        self.add(promisedOrder: promisedOrder, exchange: position.trader!.exchange)
    }
    
    func unwindPosition(position: Position, promisedOrder: PromisedOrder) {
        self.add(promisedOrder: promisedOrder, exchange: position.trader!.exchange)
    }
    
    func closedPosition(position: Position ,promisedOrder: PromisedOrder?) {
        if let order = promisedOrder {
            self.add(promisedOrder: order, exchange: position.trader!.exchange)
        }
    }
}
