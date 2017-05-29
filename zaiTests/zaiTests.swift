//
//  zaiTests.swift
//  zaiTests
//
//  Created by Kyota Watanabe on 8/18/16.
//  Copyright © 2016 Kyota Watanabe. All rights reserved.
//

import XCTest
@testable import zai

class zaiTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testBollinger() {
        var bollinger = Bollinger(size:20)
        for i in [2, 4, 6, 8, 10] {
            bollinger.add(sample: Double(i))
        }
        let sd = 2.0 * sqrt(2.0)
        let ave = 6.0
        XCTAssertEqual(bollinger.sd, sd)
        
        XCTAssertEqual(bollinger.getSigmaLower(level: 1), ave - sd)
        XCTAssertEqual(bollinger.getSigmaLower(level: 2), ave - sd * 2.0)
        XCTAssertEqual(bollinger.getSigmaLower(level: 3), ave - sd * 3.0)
        XCTAssertEqual(bollinger.getSigmaUpper(level: 1), ave + sd)
        XCTAssertEqual(bollinger.getSigmaUpper(level: 2), ave + sd * 2.0)
        XCTAssertEqual(bollinger.getSigmaUpper(level: 3), ave + sd * 3.0)
        
        bollinger.clear()
        
        for i in [1, 2, 3, 4, 5] {
            bollinger.add(sample: Double(i))
        }
        XCTAssertEqual(bollinger.sd, sqrt(2.0))
        
        bollinger.clear()
        
        for i in [-5, -3, -1, -1, 1, 2, 7] {
            bollinger.add(sample: Double(i))
        }
        
        
        
    }
    
}
