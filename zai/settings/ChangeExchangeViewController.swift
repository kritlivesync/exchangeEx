//
//  ChangeExchangeViewController.swift
//  zai
//
//  Created by 渡部郷太 on 2/22/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol ChangeExchangeDelegate {
    func saved(exchange: String)
}


class ChangeExchangeViewController : UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.tableFooterView = UIView()
        
        self.exchanges = [String]()
        
        let account = getAccount()!
        for exchange in account.exchanges {
            let name = (exchange as! Exchange).name
            self.exchanges.append(name)
        }
        self.originalExchange = account.activeExchangeName
        self.selectedExchange = account.activeExchangeName
    }
    
    public override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    public override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let exchange = self.exchanges[indexPath.row]
        cell.textLabel?.text = exchange
        if exchange == self.selectedExchange {
            cell.accessoryType = UITableViewCellAccessoryType.checkmark
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: UITableViewScrollPosition.none)
        }
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        return cell
    }
    
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) else {
            return
        }
        cell.accessoryType = UITableViewCellAccessoryType.checkmark
        self.selectedExchange = self.exchanges[indexPath.row]
    }
    
    public override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        guard let cell = self.tableView.cellForRow(at: indexPath) else {
            return
        }
        cell.accessoryType = UITableViewCellAccessoryType.none
    }
    
    @IBAction func pushSaveButton(_ sender: Any) {
        let account = getAccount()!
        account.setActiveExchange(exchangeName: self.selectedExchange)
        account.activeExchange.validateApiKey() { _ in }
        account.activeExchange.startWatch()
        self.delegate?.saved(exchange: self.selectedExchange)
    }

    var exchanges: [String]!
    var originalExchange: String!
    var selectedExchange: String!
    var delegate: ChangeExchangeDelegate?
}
