//
// Created by Rhyno.j on 7/1/18.
// Copyright (c) 2018 org.rbgroup. All rights reserved.
//

import Foundation
import SwiftyPlistManager

class Deposit {
    var spendingMoneyOfToday: Float
    var spendingMoneyOfYesterday: Float
    var remainingMoneyOfToday: Float {
        get {
            return startingDepositOfToday - spendingMoneyOfToday
        }
    }
    let startingDepositOfToday: Float
    var totalRemaining: Float

    init(spendingMoneyOfYesterday: Float, startingDepositOfToday: Float, spendingMoneyOfToday: Float, totalRemaining: Float) {
        self.spendingMoneyOfYesterday = spendingMoneyOfYesterday
        self.spendingMoneyOfToday = spendingMoneyOfToday
        self.startingDepositOfToday = startingDepositOfToday
        self.totalRemaining = totalRemaining
    }

    func spend(at: String, amounts: Float) {
        guard amounts != 0 else {
            return
        }
        spendingMoneyOfToday += amounts
        totalRemaining -= amounts
    }
}

class DepositRepository {
    class func initialize() {
        SwiftyPlistManager.shared.start(plistNames: [PLIST_FILENAME], logging: true)
    }

    private static let PLIST_FILENAME = "data"
    private static let KEY_TOTAL_DEPOSIT = "totalDeposit"
    private static let KEY_LAST_DATE = "lastDate"
    private static let KEY_SPENDING_MONEY_OF_TODAY = "spendingMoneyOfToday"
    private static let KEY_SPENDING_MONEY_OF_YESTERDAY = "spendingMoneyOfYesterday"
    private static let KEY_STARTING_DEPOSIT_OF_TODAY = "startingDepositOfToday"

    private static let DEFAULT_DAILY_DEPOSIT_VALUE: Float = 25000

    enum PersistenceError: Error {
        case unexpectedError(message: String)
    }

    static func updateTotalAmounts(amount: Float) throws {
        try saveOrUpdate(amount, forKey: KEY_TOTAL_DEPOSIT)
    }

    static func updateSpendingMoneyOfToday(amount: Float) throws {
        try saveOrUpdate(amount, forKey: KEY_SPENDING_MONEY_OF_TODAY)
    }

    static func update(deposit: Deposit) throws {
        try updateSpendingMoneyOfToday(amount: deposit.spendingMoneyOfToday)
        try updateTotalAmounts(amount: deposit.totalRemaining)
    }

    static func get() throws -> Deposit {
        let deposit = try _getOrInit()
        return deposit
    }

    /* ----------------------------------------------
    ---- private
    -------------------------------------------------*/

    private static func _getOrInit() throws -> Deposit {
        let spendingMoneyOfToday: Float
        let spendingMoneyOfYesterday: Float
        let totalRemainingMoney: Float
        let startingDepositOfToday: Float
        let passedDay = getPassedDay()
        let needTobeSave: Bool

        if passedDay != 0 {
            let _spendingMoneyOfToday = getOrDefault(defaultValue: DEFAULT_DAILY_DEPOSIT_VALUE, forKey: KEY_SPENDING_MONEY_OF_TODAY)

            spendingMoneyOfToday = 0
            totalRemainingMoney = getOrDefault(defaultValue: 0, forKey: KEY_TOTAL_DEPOSIT)
                    + (Float(passedDay - 1) * DEFAULT_DAILY_DEPOSIT_VALUE)
                    - _spendingMoneyOfToday
            spendingMoneyOfYesterday = _spendingMoneyOfToday
            startingDepositOfToday = DEFAULT_DAILY_DEPOSIT_VALUE
            needTobeSave = true
        } else {
            spendingMoneyOfToday = getOrDefault(defaultValue: DEFAULT_DAILY_DEPOSIT_VALUE, forKey: KEY_SPENDING_MONEY_OF_TODAY)
            totalRemainingMoney = getOrDefault(defaultValue: 0, forKey: KEY_TOTAL_DEPOSIT)
            spendingMoneyOfYesterday = getOrDefault(defaultValue: 0, forKey: KEY_SPENDING_MONEY_OF_YESTERDAY)
            startingDepositOfToday = getOrDefault(defaultValue: DEFAULT_DAILY_DEPOSIT_VALUE, forKey: KEY_STARTING_DEPOSIT_OF_TODAY)
            needTobeSave = false
        }

        let deposit = Deposit(spendingMoneyOfYesterday: spendingMoneyOfYesterday,
                startingDepositOfToday: startingDepositOfToday,
                spendingMoneyOfToday: spendingMoneyOfToday,
                totalRemaining: totalRemainingMoney)
        if (needTobeSave) {
            try update(deposit: deposit)
            try saveOrUpdate(Date(), forKey: KEY_LAST_DATE)
        }

        return deposit
    }

    private static func getPassedDay() -> Int {
        let lastDate = removeTime(getOrDefault(forKey: KEY_LAST_DATE))
        let todayDate = removeTime(Date())
        print(lastDate)
        print("======")
        print(todayDate)
        if let passedDay = Calendar.current.dateComponents([.day], from: lastDate, to: todayDate).day {
            return passedDay
        } else {
            return 0
        }
    }

    private static func removeTime(_ date: Date) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")
        dateFormatter.dateFormat = "yyyyMMdd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let stringValue = dateFormatter.string(from: date)
        if let convertedDate = dateFormatter.date(from: stringValue) {
            return convertedDate
        }
        return date
    }

    private static func getOrDefault(defaultValue: Float, forKey: String) -> Float {
        if let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: forKey,
                fromPlistWithName: PLIST_FILENAME),
           let value = fetchedValue as? Float {
            return value
        } else {
            return defaultValue
        }
    }

    private static func getOrDefault(defaultValue: String, forKey: String) -> String {
        if let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: forKey,
                fromPlistWithName: PLIST_FILENAME),
           let value = fetchedValue as? String {
            return value
        } else {
            return defaultValue
        }
    }

    private static func getOrDefault(forKey: String) -> Date {
        if let fetchedValue = SwiftyPlistManager.shared.fetchValue(for: forKey, fromPlistWithName: PLIST_FILENAME),
           let value = fetchedValue as? Date {
            return value
        } else {
            return Date()
        }
    }

    private static func saveOrUpdate(_ value: Any, forKey: String) throws {
        var error: PersistenceError?
        SwiftyPlistManager.shared.save(value, forKey: forKey, toPlistWithName: PLIST_FILENAME) { (err) in
            if let e = err {
                error = PersistenceError.unexpectedError(message: "\(e)")
            }
        }
        if let err = error {
            throw err
        }
    }
}
