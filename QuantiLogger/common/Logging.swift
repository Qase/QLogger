//
//  QuantiBaseLogger.swift
//  QuantiLogger
//
//  Created by Martin Troup on 25.10.16.
//  Copyright © 2016 quanti. All rights reserved.
//

import Foundation

public protocol Logging {
	var levels: [Level] { get set }
    func configure()
    func log(_ message: String, onLevel level: Level)
}

extension Logging {
    public func configure() {}

    public func messageHeader(forLevel level: Level) -> String {
        "[\(level.rawValue) \(Date().toFullDateTimeString())]"
    }

    func doesLog(forLevel level: Level) -> Bool {
        levels.contains(level)
    }
}
