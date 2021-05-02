//
//  DateExtensions.swift
//  EveningReading
//
//  Created by Chris Hodge on 5/2/21.
//

import Foundation
import UIKit
import SwiftUI

extension Date {

    func timeRemaining() -> String {
        let date = NSDate()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .month, .year, .day], from: date as Date)
        let currentDate = calendar.date(from: components)
        let expiringTime = self.addingTimeInterval(64800)
        let CompetitionDayDifference = calendar.dateComponents([.day, .hour, .minute], from: currentDate!, to: expiringTime)
        let hoursLeft = CompetitionDayDifference.hour
        let minutesLeft = CompetitionDayDifference.minute
        var remaining = (hoursLeft ?? 0) > 0 ? "\(hoursLeft ?? 0) Hrs, " : ""
        remaining = remaining + "\(minutesLeft ?? 0) Mins"
        if remaining.hasPrefix("-") {
            remaining = "Now"
        }
        return remaining
    }
    
    func percentRemaining() -> CGFloat {
        let date = NSDate()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .month, .year, .day], from: date as Date)
        let currentDate = calendar.date(from: components)
        let expiringTime = self.addingTimeInterval(64800)
        let elapsed = expiringTime.timeIntervalSince(currentDate!)
        let percent = ((elapsed / 64800) * 10).rounded(.towardZero) / 10
        let percentWidth = (235.0 * percent).rounded(.towardZero)
        return 235.0 - CGFloat(percentWidth)
    }
    
}
