//
//  ZaiAnalyticsClient.swift
//  zai
//
//  Created by Kyota Watanabe on 10/30/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation


import SocketIO


protocol ZaiAnalyticsDelegate {
    func recievedBuySignal()
    func recievedSellSignal()
}


class ZaiAnalyticsClient {
    init() {
        self.connect()
    }
    
    private func connect() {
        self.socketIo = SocketIOClient(socketURL: URL(string: "http://192.168.11.11:6665")!, config: [.log(true)])
        //self.socketIo = SocketIOClient(socketURL: URL(string: "https://zai-analytics.herokuapp.com/")!, config: [.log(true)])
        self.socketIo.joinNamespace("/signals")
        self.socketIo.on("connect", callback: self.onConnect)
        self.socketIo.on("close", callback: self.onClose)
        self.socketIo.on("error", callback: self.onError)
        self.socketIo.on("buy", callback: onBuySignal)
        self.socketIo.on("sell", callback: onSellSignal)
        self.socketIo.connect()
    }
    
    private func onConnect(data: Array<Any>, ack: SocketAckEmitter) {
        print("connected to zai-analytic")
        print(getNow())
    }
    
    private func onClose(data: Array<Any>, ack: SocketAckEmitter) {
        print("conenction to zai-analytic closed")
        print(getNow())
        self.connect()
    }
    
    private func onError(data: Array<Any>, ack: SocketAckEmitter) {
        print("error occurred on conenction to zai-analytic")
        print(getNow())
        self.connect()
    }
    
    private func onBuySignal(data: Array<Any>, ack: SocketAckEmitter) {
        print(getNow())
        if let d = self.delegate {
            d.recievedBuySignal()
        }
    }
    
    private func onSellSignal(data: Array<Any>, ack: SocketAckEmitter) {
        print(getNow)
        if let d = self.delegate {
            d.recievedSellSignal()
        }
    }
    
    var socketIo: SocketIOClient! = nil
    var delegate: ZaiAnalyticsDelegate? = nil
}
