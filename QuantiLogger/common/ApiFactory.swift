//
//  ApiFactory.swift
//  2N-mobile-communicator
//
//  Created by Martin Troup on 19/01/2018.
//  Copyright © 2018 quanti. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

/// A class that provides static methods that make API request/response communication easier.
class ApiFactory {
}

// MARK: - Set of static methods that enable building URLRequest instances.
extension ApiFactory {
	/// Method to build a specific URL request with URL parameters.
	///
	/// - Parameters:
	///   - baseUrl: Base URL of the request.
	///   - pathComponent: Specific path compoment that gets appended to the base URL.
	///   - method: HTTP method of the request.
	///   - params: Dictionary with parameters that should be added to the URL.
	/// - Returns: URLRequest instance if the method succeeds to create it, nil otherwise.
	static func buildRequest(baseUrl: URL, pathComponent: String, method: HttpMethod, withUrlParams params: [(String, String)]) -> URLRequest? {
		let urlRequest = buildRequest(baseUrl: baseUrl, pathComponent: pathComponent, method: method)

		guard var _urlRequest = urlRequest else {
			print("urlRequest is nil.")
			return nil
		}

		guard let _url = _urlRequest.url else {
			print("Could not get url property from urlRequest.")
			return nil
		}

		let urlComponents = URLComponents(url: _url, resolvingAgainstBaseURL: true)

		guard var _urlComponents = urlComponents else {
			print("Could not construct urlComponents based on url.")
			return nil
		}

		_urlComponents.queryItems = params.map { URLQueryItem(name: $0.0, value: $0.1) }

		_urlRequest.url = _urlComponents.url

		return _urlRequest
	}

	/// Method to build a specific URL request with JSON data within the body of the request.
	///
	/// - Parameters:
	///   - baseUrl: Base URL of the request.
	///   - pathComponent: Specific path compoment that gets appended to the base URL.
	///   - method: HTTP method of the request.
	///   - data: JSON data to be added to the body of the request.
	/// - Returns: URLRequest instance if the method succeeds to create it, nil otherwise.
	static func buildRequest(baseUrl: URL, pathComponent: String, method: HttpMethod, withJsonBody data: Data?) -> URLRequest? {
		let urlRequest = buildRequest(baseUrl: baseUrl, pathComponent: pathComponent, method: method)

		guard var _urlRequest = urlRequest else {
			print("urlRequest is nil.")
			return nil
		}

		_urlRequest.httpBody = data

		return _urlRequest
	}

	/// Method to build a specific URL request.
	///
	/// - Parameters:
	///   - baseUrl: Base URL of the request.
	///   - pathComponent: Specific path compoment that gets appended to the base URL.
	///   - method: HTTP method of the request.
	/// - Returns: URLRequest instance if the method succeeds to create it, nil otherwise.
	static func buildRequest(baseUrl: URL, pathComponent: String, method: HttpMethod) -> URLRequest? {
		let url = baseUrl.appendingPathComponent(pathComponent)

		var urlRequest = URLRequest(url: url)
		urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
		urlRequest.httpMethod = method.rawValue

		// Handling caches, Etag in our case
		urlRequest.cachePolicy = .useProtocolCachePolicy
		urlRequest.timeoutInterval = 60

		return urlRequest
	}
}

// MARK: - Set of static methods that enable sending requests and receiving appropriate responses on a specific API.
extension ApiFactory {

	/// Method to receive a response based on a provided URL request.
	///
	/// - Parameters:
	///   - request: URL request.
	///   - session: Session in which the request should be sent.
	/// - Returns: Data instance if received as a part of HTTP body, nil if not, ApiError instance otherwise.
	static func data(`for` request: URLRequest?, `in` session: URLSession) -> Observable<Data> {
		guard let _request = request else {
			return Observable.error(ApiError.invalidRequest)
		}

		print("\(_request.logDescription)")

		return session.rx.response(request: _request)
			.do(onNext: { (response, data) in
				print("\(response.logDescription) + data: \(data)")
			}, onError: { (error) in
				print("Error occured: \(error).")
			})
			.flatMap { (response, data) -> Observable<Data> in
				Observable.create { observer in
					switch response.statusCode {
					case 200..<300:
						observer.onNext(data)
						observer.onCompleted()
					case 400:
                        observer.onError(ApiError.badRequest)
					case 401:
						observer.onError(ApiError.unauthorized)
					case 404:
						observer.onError(ApiError.notFound)
					case 500..<600:
						observer.onError(ApiError.serverFailure)
					default:
						observer.onError(ApiError.unspecified(response.statusCode))
					}

					return Disposables.create()
				}
		}
	}

	/// Method to receive a response based on a provided URL request - used for no response body requests.
	///
	/// - Parameters:
	///   - request: URL request.
	///   - session: Session in which the request should be sent.
	/// - Returns: .completed if request success, ApiError otherwise.
	static func noData(`for` request: URLRequest?, `in` session: URLSession) -> Observable<Void> {
		data(for: request, in: session).flatMap { _ in Observable.just(()) }
	}

	/// Method to receive a JSON response based on a provided URL request.
	///
	/// - Parameters:
	///   - request: URL request.
	///   - session: Session in which the request should be sent.
	/// - Returns: JSON data if received and parsed successfully, ApiError instance otherwise.
	static func json<T: JSONParseable>(`for` request: URLRequest?, `in` session: URLSession) -> Observable<T> {
		data(for: request, in: session)
			.flatMap { data -> Observable<T> in
				Observable.create { observer in
					do {
						let json = try JSONSerialization.jsonObject(with: data, options: [])

						if let _parsedObject = T.parse(from: json) as? T {
							observer.onNext(_parsedObject)
							observer.onCompleted()
						} else {
							observer.onError(ApiError.parsingJsonFailure)
						}
					} catch {
						observer.onError(ApiError.parsingJsonFailure)
					}

					return Disposables.create()
				}
		}
	}
}
