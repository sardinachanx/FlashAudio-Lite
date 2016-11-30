//
//  TimeFormatter.swift
//  FlashAudio
//
//  Created by Serena Chan on 5/6/2016.
//  Copyright © 2016 Serena Chan. All rights reserved.
//

import Foundation

class TimeFormatter{
    static func currentTimeToLong() -> Int64{
        //get current time
        let current = NSDate()
        //get time as a double number (seconds since 2001)
        let time = current.timeIntervalSinceReferenceDate
        //get time as long number (milliseconds)
        return Int64(time * 1000)
    }
    
    static func currentTimeLongToDate(long: Int64) -> NSDate{
        let date = NSDate(timeIntervalSinceReferenceDate: Double(long) / 1000.0)
        return date;
    }
}