//
//  HTTPURLResponse+logDescription.swift
//  2N-mobile-communicator
//
//  Created by Martin Troup on 19/01/2018.
//  Copyright © 2018 quanti. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
	var logDescription: String {
		"Response: {url: \(url?.description ?? "nil"), statusCode: \(statusCode), headersFields: \(allHeaderFields)}"
	}
}
