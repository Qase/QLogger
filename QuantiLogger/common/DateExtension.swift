//
//  DateExtension.swift
//  QuantiLogger
//
//  Created by Martin Troup on 26.10.16.
//  Copyright © 2016 quanti. All rights reserved.
//

import Foundation

extension Date {

    /// Method to return String in format: "yyyy-MM-dd HH:mm:ss" from Date instance.
    ///
    /// - Returns: String
    public func toFullDateTimeString() -> String {
        DateHelper.toFullDateTimeString(from: self)
    }

    /// Method to return String in format: "yyyy-MM-dd" from Date instance.
    ///
    /// - Returns: String
    public func toFullDateString() -> String {
        DateHelper.toFullDateString(from: self)
    }
}
