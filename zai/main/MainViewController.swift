//
//  MainViewController.swift
//  zai
//
//  Created by 渡部郷太 on 6/25/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift

class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.fundView = FundView(account: self.account)
        self.traderView = TraderView(view: self.traderTableView, traderName: Config.activeTrader, api: self.account.privateApi)
        self.traderTableView.delegate = self.traderView
        self.traderTableView.dataSource = self.traderView
        
        self.fundView.createMarketCapitalizationView() { err, data in
            self.marketCapitalization.text = data
            dispatch_async(dispatch_get_main_queue()) {
                self.marketCapitalization.setNeedsDisplay()
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        switch segue.identifier! {
        case self.selectTraderSegue:
            let destController = segue.destinationViewController as! SelectTraderViewController
            destController.account = account!
        default: break
        }
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesEnded(touches, withEvent: event)
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            switch tag {
            case self.selectTraderLabelTag:
                self.performSegueWithIdentifier(self.selectTraderSegue, sender: self)
            default:
                break
            }
        }
    }
    
    internal var account: Account!
    private var fundView: FundView!
    private var traderView: TraderView!
    
    private let selectTraderLabelTag = 0
    private let selectTraderSegue = "selectTraderSegue"
    
    @IBOutlet weak var marketCapitalization: UILabel!
    @IBOutlet weak var traderTableView: UITableView!

}