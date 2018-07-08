//
// Created by Rhyno.j on 6/17/18.
// Copyright (c) 2018 org.rbgroup. All rights reserved.
//

import Foundation

/*
https://github.com/kakao/credit-card-sms-parser
https://github.com/kakao/credit-card-sms-parser/blob/master/lib/credit_card_sms_parser.rb
https://github.com/kakao/credit-card-sms-parser/blob/master/test/test_credit_card_sms_parser.rb

https://developer.apple.com/documentation/foundation/nsregularexpression
*/
class SMSMessageParser {

    // 순차적으로 처리해야하므로 ParserResult 쪽으로 이동시켜야함)
    enum RuleKey: Int {
        case header
        case card
        case bank
        case userName
        case accumulatedSpendMoney
        case remainedMoney
        case date
        case time
        case exclusion
        case type
        case spentMoney
        case shopName
    }

    public class ParseResult {
        let header: String?
        let card: String?
        let bank: String?
        let userName: String?
        let accumulatedSpendMoney: Float?
        let remainedMoney: Float?
        let date: String?
        let time: String?
        let exclusion: String?
        let type: String?
        let shopName: String
        let spentMoney: Float
        // TODO let category: Category

        init?(_ map: [RuleKey: String]) {
            guard let shopName = map[.shopName],
                  let spentMoney = map[.spentMoney]
                          .map({$0.replacingOccurrences(of: ",", with: "")
                                  .replacingOccurrences(of: "원", with: "")})
                          .flatMap({Float($0)}) else {
                return nil
            }

            self.header = map[.header]
            self.userName = map[.userName]
                    .map{$0.replacingOccurrences(of: "(\\([\\d]{2,}\\))", with: "", options: .regularExpression)}
            self.accumulatedSpendMoney = map[.accumulatedSpendMoney]
                    .map{$0.replacingOccurrences(of: "누적", with: "")
                                .replacingOccurrences(of: ":", with: "")
                                .replacingOccurrences(of: " ", with: "")
                                .replacingOccurrences(of: ",", with: "")
                                .replacingOccurrences(of: "원", with: "")
                    }.flatMap({Float($0)})
            self.remainedMoney = map[.remainedMoney]
                    .map{$0.replacingOccurrences(of: "잔액", with: "")
                            .replacingOccurrences(of: ":", with: "")
                            .replacingOccurrences(of: " ", with: "")
                            .replacingOccurrences(of: ",", with: "")
                            .replacingOccurrences(of: "원", with: "")
                    }.flatMap({Float($0)})
            self.date = map[.date]
            self.time = map[.time]
            self.card = map[.card]
                    .map{$0.replacingOccurrences(of: "[", with: "")
                            .replacingOccurrences(of: "]", with: "")
                            .replacingOccurrences(of: "-", with: "")
                            .replacingOccurrences(of: "승인", with: "")
                            .replacingOccurrences(of: " ", with: "")
                            .replacingOccurrences(of: "[\\d,\\*]{3,}", with: "", options: .regularExpression)
                    }
            self.bank = map[.bank]
            self.exclusion = map[.exclusion]
            self.type = map[.type]
            self.shopName = shopName
            self.spentMoney = spentMoney
        }
    }

    private static let rules: [RuleKey: [String]] = [
        .header: ["\\[Web발신\\]", "\\(Web발신\\)", "체크카드출금"],
        .card: ["((\\[)?([\\w,\\p{Hangul}]){3,}(\\])?){1,}\\s?([\\(,\\[]?([\\d,\\*]{3,})[\\),\\]]?)?(-?승인)?", "\\S+카드"],
        .bank: ["\\S+은행", "KEB하나"],
        .userName: ["[[\\u3131-\\uD79D],\\*]+님?(\\([\\d]{2,}\\))?"],
        .accumulatedSpendMoney: ["누적[\\s,:]?[\\d,\\,]+원?"],
        .remainedMoney: ["잔액[\\d,\\,]+원?"],
        .date: ["\\d\\d\\/\\d\\d"],
        .time: ["\\d\\d:\\d\\d"],
        .exclusion: ["([\\d][\\*]){2,}", "-?승인"],
        .type: ["사용", "일시불", "취소", "승인"],
        .spentMoney: ["[\\d,\\,]+원?"],
        .shopName: ["\\(주\\)\\p{Hangul}+", "주식회사\\p{Hangul}+", "^[\\p{Hangul}\\u3000]+( +[\\p{Hangul}\\u3000]+)*?$", "[0-9A-Za-z\\p{Hangul}]+"]
    ]

    public static func parse(smsMessage msg: String) -> ParseResult? {
        var message = msg
        var valueByRuleKey: [RuleKey: String] = [:]
        rules.keys.sorted(by: { $0.rawValue < $1.rawValue }).forEach {
            if let string = findString(by: $0, message) {
                valueByRuleKey.updateValue(string, forKey: $0)
                message = message.replacingOccurrences(of: string, with: " ")
            }
        }

        return ParseResult(valueByRuleKey)
    }

    private static func findString(by: RuleKey, _ text: String) -> String? {
        return find(by: by, text).map {
            String(text[$0])
        }
    }

    private static func find(by: RuleKey, _ text: String) -> Range<String.Index>? {
        return rules[by]?.flatMap {
            find(pattern: $0, text)
        }.first
    }

    private static func find(pattern: String, _ text: String) -> [Range<String.Index>] {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
            let nsString = text as NSString
            let matches = regex.matches(in: text, options: [], range: NSMakeRange(0, nsString.length))
            return matches.compactMap {
                return Range($0.range, in: text)
            }
        } catch let error as NSError {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
