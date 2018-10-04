//
//  Helpers.swift
//  touch-face
//
//  Created by James Ullom on 9/26/18.
//  Copyright © 2018 Hammer of the Gods Software. All rights reserved.
//

import Foundation

let NEW_UUID = UUID(uuidString: "99999999-9999-9999-9999-999999999999")
let DATE_DEFAULT_FORMAT = "yyyy-MM-dd HH:mm:ss +zzzz"
let CELL_TIMESTAMP_FORMAT = "MM/dd/yyyy  h:mm:ss a"

// Extend String class to more easily support placing strings in SQLite parameters
extension String {
    
    func asUTF8() -> UnsafePointer<Int8>? {
        return NSString(string: self).utf8String
    }
    
}

// Global function to convert UTC dates to the Local datetime for display
func UTCToLocal(date:String, fromFormat: String, toFormat: String) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = fromFormat
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    
    let dt = dateFormatter.date(from: date)
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.dateFormat = toFormat
    
    return dateFormatter.string(from: dt!)
}

// Global function to convert Local dates to the UTC datetime for display
func localToUTC(date:String, fromFormat: String, toFormat: String) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = fromFormat
    dateFormatter.calendar = NSCalendar.current
    dateFormatter.timeZone = TimeZone.current
    dateFormatter.date
    
    let dt = dateFormatter.date(from: date)
    dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
    dateFormatter.dateFormat = toFormat
    
    return dateFormatter.string(from: dt!)
}

