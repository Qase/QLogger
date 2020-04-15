//
//  JSONSerializable.swift
//  ciggy-time
//
//  Created by Martin Troup on 22/03/2017.
//  Copyright © 2017 ciggytime.com. All rights reserved.
//

import Foundation
import RxSwift

protocol JSONRepresentable {
    var jsonRepresentation: AnyObject { get }
}

protocol JSONSerializable: JSONRepresentable {}

extension JSONSerializable {
    var jsonRepresentation: AnyObject {
        var representation = [String: AnyObject]()

        for case let (label?, value) in Mirror(reflecting: self).children {
            let unwrappedInnerValue = unwrapInner(any: value)

			switch unwrappedInnerValue {
			case let unwrappedInnerValue as JSONRepresentable:
				representation[label] = unwrappedInnerValue.jsonRepresentation
			case let unwrappedInnerValue as AnyObject:
				representation[label] = unwrappedInnerValue
			default:
				// Ignore any unserializable properties
				break
			}
        }

        return representation as AnyObject
    }

    // Lets assume that there is an object (in this case any) that is of type Optional<CustomStruct> and CustomStruct implements CustomProtocol. Test "Any as CustomProtocol" will fail for variable of type Any that holds value of Optional<CustomStruct> even, by logic, it should not. For this reason I call this function that will do following: Any that holds Optional<CustomStruct> -> Optional<Any> that holds CustomStruct. Test "Optional<Any> as CustomProtocol" with Optional<Any> holding CustomStruct value will now succeed.
    private func unwrapInner(any: Any) -> Any? {
        let reflectedAny = Mirror(reflecting: any)
        if reflectedAny.displayStyle != .optional {
            return any
        }

        if reflectedAny.children.count == 0 {
            return nil
        }

        let (_, unwrapedInnerAny) = reflectedAny.children.first!

        return unwrapedInnerAny

    }
}

extension JSONSerializable {
	var jsonData: Data? {
		do {
			return try JSONSerialization.data(withJSONObject: jsonRepresentation, options: [])
		} catch {
			print("\(#function) - could not perform JSON serialization on jsonRepresentation.")
			return nil
		}
	}

	var jsonString: String? {
		guard let _jsonData = jsonData else { return nil }

		return String(data: _jsonData, encoding: .utf8)
    }
}

// Default implementation of JSONRepresentation within JSONSerializable only enables to serialize
// JSONSerializable instances or AnyObject instances such as Int, Double, Float, Array, Dictionary and so on...
// Considering Array, it only enables to serialize basic arrays such as [Int], [Double], [Float]... but IT DOES NOT
// enables to serialize [JSONSerializable]. This method does so!
extension Array: JSONSerializable {
	var jsonRepresentation: AnyObject {
		self.map { (element) -> AnyObject in
			if let _element = element as? JSONRepresentable {
				return _element.jsonRepresentation
			}

			return element as AnyObject
			} as AnyObject
	}
}

// Default implementation of JSONRepresentation within JSONSerializable only enables to serialize
// JSONSerializable instances or AnyObject instances such as Int, Double, Float, Array, Dictionary and so on...
// Considering Dictionary, it only enables to serialize basic dictionaries such as [AnyHashable: Int], [AnyHashable: Double],
// [AnyHashable: Float]... but IT DOES NOT enables to serialize [AnyHashable: JSONSerializable]. This method does so!
extension Dictionary: JSONSerializable {
	var jsonRepresentation: AnyObject {
		let ret = self.reduce([AnyHashable: AnyObject]()) { (aggregate, keyValue) in
			var _aggregate = aggregate

			if let _value = keyValue.value as? JSONRepresentable {
				_aggregate[keyValue.key] = _value.jsonRepresentation
			} else {
				_aggregate[keyValue.key] = keyValue.value as AnyObject
			}

			return _aggregate
		}

		return ret as AnyObject
	}
}
