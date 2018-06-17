//
// Created by Rhyno.j on 6/15/18.
// Copyright (c) 2018 org.rbgroup. All rights reserved.
//

import UIKit

//https://www.youtube.com/watch?v=Wz6-IQV_qDw
class CountingLabel: UILabel {

    let counterVelocity: Float = 3.0

    enum CounterAnimationType {
        case Linear     // f(x) = x
        case EaseIn     // f(x) = x^3
        case EaseOut    // f(x) = (1-x)^3
    }

    enum CounterType {
        case Int
        case Float
    }

    var startNumber: Float = 0.0
    var endNumber: Float = 0.0

    var progress: TimeInterval!
    var duration: TimeInterval!
    var lastUpdate: TimeInterval!

    var timer: Timer?

    var counterAnimationType: CounterAnimationType!
    var counterType: CounterType!

    var currentCounterValue: Float {
        if progress > duration {
            return endNumber
        }

        let percentage = Float(progress / duration)
        let update = updateCounter(counterValue: percentage)

        return startNumber + (update * (endNumber - startNumber))
    }


    func count(fromValue: Float, to toValue: Float,
               withDuration duration: TimeInterval,
               andAnimationType animationType: CounterAnimationType,
               andCounterType counterType: CounterType) {
        self.startNumber = fromValue
        self.endNumber = toValue
        self.duration = duration
        self.counterAnimationType = animationType
        self.counterType = counterType
        self.progress = 0
        self.lastUpdate = Date.timeIntervalSinceReferenceDate

        invalidateTimer()

        if (duration == 0) {
            updateText(value: toValue)
            return
        }

        timer = Timer.scheduledTimer(timeInterval: 0.01, target: self,
                selector: #selector(updateValue),
                userInfo: nil, repeats: true)
    }

    @objc func updateValue() {
        let now = Date.timeIntervalSinceReferenceDate
        progress = progress + (now - lastUpdate)
        lastUpdate = now

        if (progress >= duration) {
            invalidateTimer()
            progress = duration
        }

        // update text in label
        updateText(value: currentCounterValue)
    }

    func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }

    func updateText(value: Float) {
        let formatter = NumberFormatter()
        formatter.usesGroupingSeparator = true
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "ko_KO")
        formatter.positivePrefix = ""
        formatter.negativeSuffix = ""
        formatter.minimumFractionDigits = 0

        switch counterType! {
        case .Int:
            self.text = formatter.string(for: value)
        case .Float:
            self.text = formatter.string(for: String(format: "%.2f", value))
        }
    }

    func updateCounter(counterValue: Float) -> Float {
        switch counterAnimationType! {
        case .Linear:
             return counterValue
        case .EaseIn:
             return powf(counterValue, 3)
        case .EaseOut:
             return powf(1.0 - counterValue, 3)
        }
    }
}