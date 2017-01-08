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


protocol BoardViewDelegate {
    func orderSell(quote: Quote)
    func orderBuy(quote: Quote)
}


class BoardView : NSObject, UITableViewDelegate, UITableViewDataSource, BoardViewCellDelegate {
    
    init(view: UITableView) {
        self.view = view
        self.view.tableFooterView = UIView()
        self.view.contentInset = UIEdgeInsetsMake(-1.0, 0.0, 0.0, 0.0);
        
        super.init()
        self.view.delegate = self
        self.view.dataSource = self
        self.delegate = nil
    }
    
    public func update(board: Board) {
        let needReload = (self.board == nil)
        self.board = board
        let count = self.board!.quoteCount
        for i in 0 ..< count {
            let cell = self.view.cellForRow(at: IndexPath(row: i + 1, section: 0)) as? BoardViewCell
            cell?.setQuote(board.getQuote(index: i))
        }
        if needReload {
            self.reloadData()
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let board = self.board else {
            return 0
        }
        return board.quoteCount + 1 // + header
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 20.0
        } else {
            return 45.0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "boardViewCell", for: indexPath) as! BoardViewCell
        let row = indexPath.row
        if row == 0 {
            cell.setQuote(nil)
        } else {
            guard let board = self.board else {
                cell.setQuote(nil)
                return cell
            }
            let quote = board.getQuote(index: (indexPath as NSIndexPath).row - 1)!
            cell.setQuote(quote)
            cell.delegate = self
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let cell = self.view.cellForRow(at: indexPath) as? BoardViewCell else {
            return nil
        }
        var actions = [UITableViewRowAction]()
        
        if let action = cell.makerButtonAction {
            actions.append(action)
        }
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
    
    // BoardViewCellDelegate
    func pushedMakerButton(quote: Quote) {
        if quote.type == Quote.QuoteType.ASK {
            self.delegate?.orderSell(quote: quote)
        } else if quote.type == Quote.QuoteType.BID {
            self.delegate?.orderBuy(quote: quote)
        }
    }
    
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
    
    fileprivate var board: Board?
    fileprivate let view: UITableView
    var delegate: BoardViewDelegate?
}

