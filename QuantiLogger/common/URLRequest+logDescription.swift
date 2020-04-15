//
//  URLRequest+logDescription.swift
//  2N-mobile-communicator
//
//  Created by Martin Troup on 19/01/2018.
//  Copyright © 2018 quanti. All rights reserved.
//

import Foundation

extension URLRequest {
	var logDescription: String {
		"Request: {url: \(url?.description ?? "nil"), method: \(httpMethod?.description ?? "nil"), headersFields: \(allHTTPHeaderFields?.description ?? "nil")}"
	}
}
