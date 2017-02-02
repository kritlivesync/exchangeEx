//
//  PositionsViewController.swift
//  zai
//
//  Created by Kyota Watanabe on 9/4/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit



class PositionsViewController : UIViewController, UITextFieldDelegate, PositionFundViewDelegate, PositionEditDelegate, PositionCreateDelegate, PositionListViewDelegate, AppBackgroundDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = Color.keyColor
        
        self.positionsHeaderLabel.backgroundColor = Color.keyColor2
        
        self.totalProfit.text = "-"
        self.priceAverage.text = "-"
        self.btcFund.text = "-"
        
        self.addPositionButton.tintColor = Color.antiKeyColor
        
        self.positionListView = PositionListView(view: self.tableView)
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
        let account = getAccount()
        self.trader = account!.activeExchange.trader
        
        self.positionListView.delegate = self
        self.positionListView.startWatch(trader: self.trader)
        self.positionListView.reloadData()
        
        if self.positionFundView == nil {
            self.positionFundView = PositionFundView(trader: self.trader)
            self.positionFundView.monitoringInterval = getAppConfig().footerUpdateIntervalType
            self.positionFundView.delegate = self
        }
        self.trader.startWatch()
    }
    
    fileprivate func stop() {
        self.positionListView.stopWatch()
        self.positionListView.delegate = nil
        
        if self.positionFundView != nil {
            self.positionFundView.delegate = nil
            self.positionFundView = nil
        }
    }
    
    @IBAction func pushAddPositionButton(_ sender: Any) {
        let addPositionController = PositionCreateViewController(trader: self.trader)
        addPositionController.delegate = self
        self.present(addPositionController.controller, animated: true, completion: nil)
    }
    
    // MonitorableDelegate
    func getDelegateName() -> String {
        return "PositionsViewController"
    }
    
    // PositionFundViewDelegate
    func recievedTotalProfit(profit: String) {
        DispatchQueue.main.async {
            self.totalProfit.text = profit
        }
    }
    
    func recievedPriceAverage(average: String) {
        DispatchQueue.main.async {
            self.priceAverage.text = average
        }
    }
    
    func recievedBtcFund(btc: String) {
        DispatchQueue.main.async {
            self.btcFund.text = btc
        }
    }
    
    // PositionCreateDelegate
    func createOk(position: Position) {
        self.trader.addPosition(position)
        self.positionListView.addPosition(position: position)
    }
    
    func createCancel() {
        print("Creating position cancelled")
    }
    
    // PositionEditDelegate
    func editOk(position: Position) {
        
    }
    
    func editCancel() {
        print("Editing position cancelled")
    }
    
    // PositionListViewDelegate
    func editPosition(position: Position) {
        let editPositionController = PositionEditViewController(trader: self.trader, position: position)
        editPositionController.delegate = self
        self.present(editPositionController.controller, animated: true, completion: nil)
    }
    
    func error(error: ZaiError) {
        let errorView = createErrorModal(title: error.errorType.toString(), message: error.message)
        self.present(errorView, animated: false, completion: nil)
    }
    
    // AppBackgroundDelegate
    func applicationDidBecomeActive(_ application: UIApplication) {
        self.start()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        self.stop()
    }
    
    @IBAction func pushSettingsButton(_ sender: Any) {
        let storyboard: UIStoryboard = self.storyboard!
        let settings = storyboard.instantiateViewController(withIdentifier: "settingsViewController") as! UINavigationController
        self.present(settings, animated: true, completion: nil)
    }
    
    var trader: Trader!
    
    var positionListView: PositionListView! = nil
    var positionFundView: PositionFundView! = nil
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var positionsHeaderLabel: UILabel!
    
    @IBOutlet weak var totalProfit: UILabel!
    @IBOutlet weak var priceAverage: UILabel!
    @IBOutlet weak var btcFund: UILabel!
    @IBOutlet weak var addPositionButton: UIBarButtonItem!
}
