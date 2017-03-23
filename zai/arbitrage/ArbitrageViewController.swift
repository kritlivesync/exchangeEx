//
//  File.swift
//  zai
//
//  Created by 渡部郷太 on 3/11/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


class ArbitrageController : UIViewController, AppBackgroundDelegate, ArbitrageViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
        
        self.arbitrageView = ArbitrageView(view: self.tableView)
        self.arbitrageView.delegate2 = self
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.start()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.stop()
    }
    
    fileprivate func start() {
        setBackgroundDelegate(delegate: self)
        let bitFlayer = getAccount()!.getExchange(exchangeName: "bitFlyer")!
        let zaif = getAccount()!.getExchange(exchangeName: "Zaif")!
        self.arbitrageView.start(leftExchange: bitFlayer, rightExchange: zaif)
        
        if let trader = getAccount()?.activeExchange.trader {
            trader.stopWatch()
        }
    }
    
    fileprivate func stop() {
        self.arbitrageView.stop()
    }
    
    // AppBackgroundDelegate
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.start()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.stop()
    }
    
    // ArbitrageViewDelegate
    func orderArbitrage(buyQuote: Quote, buyExchange: Exchange, sellQuote: Quote, sellExchange: Exchange, amount: Double) {
        let rule = getAppConfig().unwindingRuleType
        sellExchange.trader.ruledUnwindPosition(price: sellQuote.price, amount: amount, marketPrice: sellQuote.price, rule: rule) { (err, position, orderedAmount) in
            if let e = err {
                let errorView = createErrorModal(message: e.message)
                //self.present(errorView, animated: false, completion: nil)
            } else {
                buyExchange.trader.createLongPosition(.BTC_JPY, price: buyQuote.price, amount: orderedAmount) { (err, position) in
                    if let e = err {
                        print(e.message)
                        let errorView = createErrorModal(title: e.errorType.toString(), message: e.message)
                        //self.present(errorView, animated: false, completion: nil)
                    }
                }
            }
        }
    }
    
    var arbitrageView: ArbitrageView!
    
    @IBOutlet weak var tableView: UITableView!
}
