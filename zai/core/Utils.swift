//
//  Utils.swift
//  zai
//
//  Created by Kyota Watanabe on 10/30/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import Foundation
import UIKit


func getNow() -> String {
    let now = NSDate()
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    return formatter.string(from: now as Date)
}

func formatValue(_ value: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = NumberFormatter.Style.decimal
    formatter.groupingSeparator = ","
    formatter.groupingSize = 3
    formatter.maximumFractionDigits = 2
    return formatter.string(from: NSNumber(value: value))!
}

func formatValue(_ value: Double, digit: Int=5) -> String {
    let format = "%." + digit.description + "f"
    return NSString(format: format as NSString, value) as String
}

func formatDate(timestamp: Int64) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    return formatter.string(from: date)
}

func formatHms(timestamp: Int64) -> String {
    let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss"
    return formatter.string(from: date)
}

func timestamp(date: String = "") -> Int64 {
    if date == "" {
        return Int64(Double(Date().timeIntervalSince1970) * 1000.0)
    }
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(identifier: "GMT")
    formatter.calendar = Calendar(identifier: Calendar.Identifier.gregorian)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    let nsdate = formatter.date(from: date) as NSDate?
    return Int64(nsdate!.timeIntervalSince1970)
}

