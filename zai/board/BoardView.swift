//
//  PositionListView.swift
//  zai
//
//  Created by Kyota Watanabe on 9/4/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit

import ZaifSwift


protocol BoardViewDelegate {
    func orderSell(quote: Quote, bestBid: Quote, bestAsk: Quote, callback: @escaping () -> Void)
    func orderBuy(quote: Quote, bestBid: Quote, bestAsk: Quote, callback: @escaping () -> Void)
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
        guard let prevBoard = self.board else {
            self.board = board
            self.reloadData()
            let mid = (board.quoteCount / 2)
            self.view.scrollToRow(at: IndexPath(row: mid, section: 0), at: UITableViewScrollPosition.middle, animated: true)
            return
        }
        
        self.board = board
        
        if prevBoard.quoteCount != board.quoteCount {
            self.reloadData()
            let mid = (board.quoteCount / 2)
            self.view.scrollToRow(at: IndexPath(row: mid, section: 0), at: UITableViewScrollPosition.middle, animated: true)
            return
        }

        for i in 0 ..< self.board!.quoteCount {
            let cell = self.view.cellForRow(at: IndexPath(row: i, section: 0)) as? BoardViewCell
            cell?.setQuote(board.getQuote(index: i))
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
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45.0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "boardViewCell", for: indexPath) as! BoardViewCell
        let row = indexPath.row
        guard let board = self.board else {
            cell.setQuote(nil)
            return cell
        }
        let quote = board.getQuote(index: row)!
        cell.setQuote(quote)
        cell.delegate = self
        
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
    func pushedMakerButton(quote: Quote, cell: BoardViewCell) {
        if cell.activeIndicator.isAnimating {
            return
        }
        guard let board = self.board else {
            return
        }
        guard let bestBid = board.getBestBid() else {
            return
        }
        guard let bestAsk = board.getBestAsk() else {
            return
        }
        cell.activeIndicator.startAnimating()
        if quote.type == Quote.QuoteType.ASK {
            self.delegate?.orderSell(quote: quote, bestBid: bestBid, bestAsk: bestAsk) {
                DispatchQueue.main.async {
                    cell.activeIndicator.stopAnimating()
                }
            }
        } else if quote.type == Quote.QuoteType.BID {
            self.delegate?.orderBuy(quote: quote, bestBid: bestBid, bestAsk: bestAsk) {
                DispatchQueue.main.async {
                    cell.activeIndicator.stopAnimating()
                }
            }
        }
    }
    
    func pushedTakerButton(quote: Quote, cell: BoardViewCell) {
        if cell.activeIndicator.isAnimating {
            return
        }
        guard let board = self.board else {
            return
        }
        guard let bestBid = board.getBestBid() else {
            return
        }
        guard let bestAsk = board.getBestAsk() else {
            return
        }
        cell.activeIndicator.startAnimating()
        if quote.type == Quote.QuoteType.ASK {
            self.delegate?.orderBuy(quote: quote, bestBid: bestBid, bestAsk: bestAsk) {
                DispatchQueue.main.async {
                    cell.activeIndicator.stopAnimating()
                }
            }
        } else if quote.type == Quote.QuoteType.BID {
            self.delegate?.orderSell(quote: quote, bestBid: bestBid, bestAsk: bestAsk) {
                DispatchQueue.main.async {
                    cell.activeIndicator.stopAnimating()
                }
            }
        }
    }
    
    internal func reloadData() {
        self.view.reloadData()
    }
    
    fileprivate var board: Board?
    fileprivate let view: UITableView
    var delegate: BoardViewDelegate?
}

