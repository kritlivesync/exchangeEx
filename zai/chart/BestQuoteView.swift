//
//  BestQuoteView.swift
//  zai
//
//  Created by 渡部郷太 on 1/10/17.
//  Copyright © 2017 watanabe kyota. All rights reserved.
//

import Foundation
import UIKit


protocol BestQuoteViewDelegate {
    func orderSell(quote: Quote)
    func orderBuy(quote: Quote)
}


class BestQuoteView : NSObject, UITableViewDelegate, UITableViewDataSource, BestQuoteViewCellDelegate {
    
    init(view: UITableView) {
        self.view = view
        self.view.tableFooterView = UIView()
        self.view.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0);
        self.view.isScrollEnabled = false
        self.view.bounces = false
        
        super.init()
        self.view.delegate = self
        self.view.dataSource = self
        self.delegate = nil
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70.0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bestQuoteViewCell", for: indexPath) as! BestQuoteViewCell
        cell.setQuote(quote: nil)
        return cell
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let cell = self.view.cellForRow(at: indexPath) as? BestQuoteViewCell else {
            return nil
        }
        var actions = [UITableViewRowAction]()
        
        if let action = cell.takerButtonAction {
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
    
    func setBestAsk(quote: Quote) {
        guard let cell = self.view.cellForRow(at: IndexPath(row: 0, section: 0)) as? BestQuoteViewCell else {
            return
        }
        cell.setQuote(quote: quote)
        cell.delegate = self
    }
    
    func setBestBid(quote: Quote) {
        guard let cell = self.view.cellForRow(at: IndexPath(row: 1, section: 0)) as? BestQuoteViewCell else {
            return
        }
        cell.setQuote(quote: quote)
        cell.delegate = self
    }
    
    // BestQuoteViewCellDelegate
    func pushedTakerButton(quote: Quote) {
        if quote.type == Quote.QuoteType.ASK {
            self.delegate?.orderBuy(quote: quote)
        } else if quote.type == Quote.QuoteType.BID {
            self.delegate?.orderSell(quote: quote)
        }
    }
    
    internal func reloadData() {
        self.view.reloadData()
    }
    
    fileprivate let view: UITableView
    var delegate: BestQuoteViewDelegate?
}
