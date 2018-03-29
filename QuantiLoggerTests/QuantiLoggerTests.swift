//
//  QuantiLoggerTests.swift
//  QuantiLoggerTests
//
//  Created by Martin Troup on 25.10.16.
//  Copyright © 2016 quanti. All rights reserved.
//

import XCTest
@testable import QuantiLogger

class QuantiLoggerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInicializationOfFileLogger() {
        // Set default values for all Logger properties and store them to UserDefaults
        let fileLoggerManager = FileLoggerManager.shared
        fileLoggerManager.resetPropertiesToDefaultValues()

        if let _currentLogFileNumber = UserDefaults.standard.object(forKey: QuantiLoggerConstants.UserDefaultsKeys.currentLogFileNumber) as? Int {
            XCTAssertEqual(0, _currentLogFileNumber)
        } else {
            XCTFail()
        }

        if let _dateTimeOfLastLog = UserDefaults.standard.object(forKey: QuantiLoggerConstants.UserDefaultsKeys.dateOfLastLog) as? Date {
            XCTAssertNotNil(_dateTimeOfLastLog.toFullDateString().range(of: "^\\d{4}-\\d{2}-\\d{2}$", options: .regularExpression))
        } else {
            XCTFail()
        }

        if let _numOfLogFiles = UserDefaults.standard.object(forKey: QuantiLoggerConstants.UserDefaultsKeys.numOfLogFiles) as? Int {
            XCTAssertEqual(4, _numOfLogFiles)
        } else {
            XCTFail()
        }
    }

    func testLogger() {
        let fileLoggerManager = FileLoggerManager.shared
        fileLoggerManager.resetPropertiesToDefaultValues()

        guard fileLoggerManager.logDirUrl != nil, let _currentLogFileUrl = fileLoggerManager.currentLogFileUrl else {
            XCTFail("Failed to set log directory or current log file")
            return
        }
        
        // Set Console logger and File logger
        let logManager = LogManager.shared
        logManager.removeAllLoggers()
        
        let consoleLogger = ConsoleLogger()
        consoleLogger.levels = [.warn, .error]
        logManager.add(consoleLogger)
        
        let fileLogger = FileLogger()
        fileLogger.levels = [.error, .info]
        logManager.add(fileLogger)
        
        // Should be displayed in console + written to file
        QLog("Error message", onLevel: .error)
        // Should be displayed in console + NOT written to file
        QLog("Warning message", onLevel: .warn)
        // Should NOT be displayed in console + written to file
        QLog("Info message", onLevel: .info)

        logManager.waitForLogingJobsToFinish()

		// Archived log files check
		let url = fileLogger.archivedLogFilesUrl
		XCTAssertNotNil(url)
		do {
			let reachable = try url!.checkResourceIsReachable()
			XCTAssertTrue(reachable)
		} catch {
			XCTFail("Archived log files url is invalid.")
		}

        // Check if logs were correctly written in the log file
        let contentOfLogFile = fileLoggerManager.readingContentFromLogFile(at: _currentLogFileUrl)
        
        guard let _contentOfLogFile = contentOfLogFile else {
            XCTFail("Log file is empty even though it should not be!")
            return
        }
        
        let linesOfContent = _contentOfLogFile.components(separatedBy: .newlines)
        XCTAssertEqual(QuantiLoggerConstants.FileLogger.logFileRecordSeparator, linesOfContent[0])
        XCTAssertNotNil(linesOfContent[1].range(of: "^\\[ERROR \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}]$", options: .regularExpression))
        XCTAssertNotNil(linesOfContent[2].range(of: "^Error message$", options: .regularExpression))
        XCTAssertEqual(linesOfContent[3], "")
        XCTAssertEqual(QuantiLoggerConstants.FileLogger.logFileRecordSeparator, linesOfContent[4])
        XCTAssertNotNil(linesOfContent[5].range(of: "^\\[INFO \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}]$", options: .regularExpression))
        XCTAssertNotNil(linesOfContent[6].range(of: "^Info message$", options: .regularExpression))
    
        
        // Delete the log file
        fileLoggerManager.deleteLogFile(at: _currentLogFileUrl)
    }

    func testParsingOfLogFile() {
        let fileLoggerManager = FileLoggerManager.shared
        fileLoggerManager.resetPropertiesToDefaultValues()
        
        guard fileLoggerManager.logDirUrl != nil, let _currentLogFileUrl = fileLoggerManager.currentLogFileUrl else {
            XCTFail("Failed to set log directory or current log file")
            return
        }

        // Set Console logger and File logger
        let logManager = LogManager.shared
        logManager.removeAllLoggers()
        
        let fileLogger = FileLogger()
        fileLogger.levels = [.error, .warn]
        logManager.add(fileLogger)
        
        QLog("Error message", onLevel: .error)
        QLog("Warning message\nThis is test!", onLevel: .warn)

        logManager.waitForLogingJobsToFinish()
        
        let logFileRecords = fileLoggerManager.gettingRecordsFromLogFile(at: _currentLogFileUrl)
        
        guard let _logFileRecords = logFileRecords else {
            XCTFail("No log file records were parsed from the log file even though there should be 2 of them.")
            return
        }
        
        XCTAssertEqual(2, _logFileRecords.count)
        
        XCTAssertNotNil(_logFileRecords[0].header.range(of: "^\\[ERROR \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}]$", options: .regularExpression))
        XCTAssertNotNil(_logFileRecords[0].body.range(of: "^Error message\n$", options: .regularExpression))
        
        XCTAssertNotNil(_logFileRecords[1].header.range(of: "^\\[WARNING \\d{4}-\\d{2}-\\d{2} \\d{2}:\\d{2}:\\d{2}]$", options: .regularExpression))
        XCTAssertNotNil(_logFileRecords[1].body.range(of: "^Warning message\nThis is test!\n$", options: .regularExpression))

        // Delete the log file
        fileLoggerManager.deleteLogFile(at: _currentLogFileUrl)
    }

//    func testMultipleFileLoging() {
//        let logManager = LogManager.shared
//        logManager.removeAllLoggers()
//
//        let fileLogger = FileLogger()
//        fileLogger.levels = [.error, .warn]
//        fileLogger.numOfLogFiles = 4
//        logManager.add(fileLogger)
//
//
//        QLog("Error message 4", onLevel: .error)
//    }
}
