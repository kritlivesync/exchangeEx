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


class BoardView : NSObject, UITableViewDelegate, UITableViewDataSource {
    
    init(view: UITableView, board: Board) {
        self.board = board
        self.view = view
        self.tappedRow = -1
        
        super.init()
        self.view.delegate = self
        self.view.dataSource = self
        self.delegate = nil
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.board.quoteCount
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "boardViewCell", for: indexPath) as! BoardViewCell
        let quote = self.board.getQuote(index: (indexPath as NSIndexPath).row)!
        cell.setQuote(quote)
        if quote.type == Quote.QuoteType.ASK {
            cell.takerButton.addTarget(self, action: #selector(BoardView.pushBuyOrder(_:event:)), for: .touchUpInside)
            cell.makerButton.addTarget(self, action: #selector(BoardView.pushSellOrder(_:event:)), for: .touchUpInside)
        } else if quote.type == Quote.QuoteType.BID {
            cell.takerButton.addTarget(self, action: #selector(BoardView.pushSellOrder(_:event:)), for: .touchUpInside)
            cell.makerButton.addTarget(self, action: #selector(BoardView.pushBuyOrder(_:event:)), for: .touchUpInside)
        }
        return cell
    }
    
    func pushBuyOrder(_ sender: AnyObject, event: UIEvent?) {
        var row = -1
        for touch in (event?.allTouches)! {
            let point = touch.location(in: self.view)
            row = (self.view.indexPathForRow(at: point)! as NSIndexPath).row
        }
        if 0 <= row && row < self.board.quoteCount {
            let quote = self.board.getQuote(index: row)!
            if let d = self.delegate {
                d.orderBuy(quote: quote)
            }
        }
    }
    
    func pushSellOrder(_ sender: AnyObject, event: UIEvent?) {
        var row = -1
        for touch in (event?.allTouches)! {
            let point = touch.location(in: self.view)
            row = (self.view.indexPathForRow(at: point)! as NSIndexPath).row
        }
        if 0 <= row && row < self.board.quoteCount {
            let quote = self.board.getQuote(index: row)!
            if let d = self.delegate {
                d.orderSell(quote: quote)
            }
        }
    }
    
    internal func reloadData() {
        self.view.reloadData()
    }
    
    fileprivate let board: Board
    fileprivate let view: UITableView
    fileprivate var tappedRow: Int
    var delegate: BoardViewDelegate?
}

