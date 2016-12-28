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
        self.tappedRow = -1
        
        super.init()
        self.view.delegate = self
        self.view.dataSource = self
        self.delegate = nil
    }
    
    public func update(board: Board) {
        let needReload = (self.board == nil)
        self.board = board
        let count = self.board!.quoteCount
        for i in 0 ... count {
            let cell = self.view.cellForRow(at: IndexPath(row: i, section: 0)) as? BoardViewCell
            cell?.setQuote(board.getQuote(index: i)!)
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
        return board.quoteCount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "boardViewCell", for: indexPath) as! BoardViewCell
        
        guard let board = self.board else {
            return cell
        }
        let quote = board.getQuote(index: (indexPath as NSIndexPath).row)!
        cell.setQuote(quote)
        cell.delegate = self
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let cell = self.view.cellForRow(at: indexPath) as? BoardViewCell else {
            return nil
        }
        return [cell.takerButtonAction!, cell.makerButtonAction!]
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
    fileprivate var tappedRow: Int
    var delegate: BoardViewDelegate?
}

