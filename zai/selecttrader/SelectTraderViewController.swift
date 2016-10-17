//
//  File.swift
//  zai
//
//  Created by 渡部郷太 on 8/27/16.
//  Copyright © 2016 watanabe kyota. All rights reserved.
//

import Foundation

import ZaifSwift


@objc protocol SelectTraderViewDelegate {
    func setCurrentTrader(_ traderName: String)
}


class SelectTraderViewController: UIViewController, TraderListViewDelegate, TraderMenuViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.currentTraderName == nil {
            self.currentTraderName = Config.currentTraderName
        }
        
        self.traderListView = TraderListView(view: self.tableView, api: self.account.privateApi)
        self.traderListView.delegate = self
        self.traderListView.reloadTraders(self.currentTraderName!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case self.newTraderSegue:
                let destController = segue.destination as! NewTraderViewController
                destController.account = self.account!
            case self.traderMenuSegue:
                let destController = segue.destination as! TraderMenuViewController
                destController.trader = self.selectedTrader
                destController.delegate = self
            default: break
            }
        }
    }
    
    // TraderListViewDelegate
    func didSelectTrader(_ trader: Trader) {
        self.selectedTrader = trader
        self.performSegue(withIdentifier: self.traderMenuSegue, sender: self)
    }
    
    // TraderMenuViewDelegate
    func didSelectActivate(_ trader: Trader) {
        self.currentTraderName = trader.name
        Config.SetCurrentTraderName(trader.name)
        Config.save()
        self.traderListView.reloadTraders(self.currentTraderName!)
        self.traderListView.reloadData()
        if self.delegate != nil {
            self.delegate!.setCurrentTrader(self.currentTraderName!)
        }
    }
    
    func didSelectDeactivate(_ trader: Trader) {
        if self.currentTraderName == trader.name {
            self.currentTraderName = ""
            Config.SetCurrentTraderName("")
            Config.save()
            self.traderListView.reloadTraders(self.currentTraderName!)
            self.traderListView.reloadData()
            if self.delegate != nil {
                self.delegate!.setCurrentTrader(self.currentTraderName!)
            }
        }
    }
    
    func didSelectShowPositions(_ trader: Trader) {
    }
    
    func didSelectDelete(_ trader: Trader) {
        self.didSelectDeactivate(trader)
        TraderRepository.getInstance().delete(trader)
        self.traderListView.reloadTraders(self.currentTraderName!)
        self.traderListView.reloadData()
    }
    
    @IBAction func unwindToSelect(_ segue: UIStoryboardSegue) {}
    
    @IBAction func unwindToTraderList(_ segue: UIStoryboardSegue) {}
    
    internal var account: Account!
    internal var traderListView: TraderListView!
    fileprivate var currentTraderName: String? = nil
    
    fileprivate var selectedTrader: Trader? = nil
    
    internal var delegate: SelectTraderViewDelegate? = nil
    
    fileprivate let newTraderSegue = "newTraderSegue"
    fileprivate let traderMenuSegue = "traderMenuSegue"

    @IBOutlet weak var tableView: UITableView!

}

