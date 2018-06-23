//
// Created by Rhyno.j on 6/17/18.
// Copyright (c) 2018 org.rbgroup. All rights reserved.
//

import XCTest
@testable import Pony

class SMSMessageParserTests: XCTestCase {

    func testParse_KB() {
        let sms =
"""
[Web발신]
KB국민카드 2*5*
정*욱님
03/25 09:30
2,200원
미니스톱판교점
누적 97,440원
"""
        let parseResult = SMSMessageParser.parse(smsMessage: sms)
        XCTAssertEqual("[Web발신]", parseResult?.header)
        XCTAssertEqual("KB국민카드", parseResult?.card)
        XCTAssertEqual("정*욱님", parseResult?.userName)
        XCTAssertEqual("03/25", parseResult?.date)
        XCTAssertEqual("09:30", parseResult?.time)
        XCTAssertEqual(2200, parseResult?.spentMoney)
        XCTAssertEqual("미니스톱판교점", parseResult?.shopName)
        XCTAssertEqual(97440, parseResult?.accumulatedSpendMoney)
    }

    func testParse_Hyandai() {
        let sms =
"""
[Web발신]
[현대카드]-승인
김재*님
1,500원(일시불)
마노핀익스프레스신림
누적:354,220원
"""
        let parseResult = SMSMessageParser.parse(smsMessage: sms)
        XCTAssertEqual("[Web발신]", parseResult?.header)
        XCTAssertEqual("현대카드", parseResult?.card)
        XCTAssertEqual("김재*님", parseResult?.userName)
        XCTAssertEqual(1500, parseResult?.spentMoney)
        XCTAssertEqual("마노핀익스프레스신림", parseResult?.shopName)
        XCTAssertEqual(354220, parseResult?.accumulatedSpendMoney)
    }

    func testParse_Samsung() {
        let sms =
"""
[Web발신]
삼성4525승인 정*성
107,737원 일시불
06/22 17:47 삼성화재해상
누적504,671원
"""
        let parseResult = SMSMessageParser.parse(smsMessage: sms)
        XCTAssertEqual("[Web발신]", parseResult?.header)
        XCTAssertEqual("삼성", parseResult?.card)
        XCTAssertEqual("정*성", parseResult?.userName)
        XCTAssertEqual("06/22", parseResult?.date)
        XCTAssertEqual("17:47", parseResult?.time)
        XCTAssertEqual(107737, parseResult?.spentMoney)
        XCTAssertEqual("삼성화재해상", parseResult?.shopName)
        XCTAssertEqual(504671, parseResult?.accumulatedSpendMoney)
    }

    func testParse_Hana() {
        let sms =
"""
[Web발신]
하나(6*8*)김*호님 04/06 15:26 씨유판교 일시불/3,500원/누적-4,645원
"""
        let parseResult = SMSMessageParser.parse(smsMessage: sms)
        XCTAssertEqual("[Web발신]", parseResult?.header)
        XCTAssertEqual("하나", parseResult?.card)
        XCTAssertEqual("김*호님", parseResult?.userName)
        XCTAssertEqual("04/06", parseResult?.date)
        XCTAssertEqual("15:26", parseResult?.time)
        XCTAssertEqual(3500, parseResult?.spentMoney)
        XCTAssertEqual("씨유판교", parseResult?.shopName)
        XCTAssertEqual(4645, parseResult?.accumulatedSpendMoney)
    }

    func testParse_Shinhan() {
        let sms =
"""
[Web발신]
[신한체크승인] 정*성(6327) 06/17 13:38 3,900원 이디야상현점 잔액18,543원
"""
        let parseResult = SMSMessageParser.parse(smsMessage: sms)
        XCTAssertEqual("[Web발신]", parseResult?.header)
        XCTAssertEqual("신한체크", parseResult?.card)
        XCTAssertEqual("정*성", parseResult?.userName)
        XCTAssertEqual("06/17", parseResult?.date)
        XCTAssertEqual("13:38", parseResult?.time)
        XCTAssertEqual(3900, parseResult?.spentMoney)
        XCTAssertEqual("이디야상현점", parseResult?.shopName)
        XCTAssertEqual(18543, parseResult?.remainedMoney)
    }
}