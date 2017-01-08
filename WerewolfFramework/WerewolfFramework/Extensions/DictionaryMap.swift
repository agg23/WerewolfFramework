//
//  DictionaryMap.swift
//  WerewolfFramework
//
//  Created by Adam Gastineau on 1/8/17.
//  Copyright © 2017 Adam Gastineau. All rights reserved.
//

import Foundation

extension Dictionary {
	public func map<T: Hashable, U>( transform: (Key, Value) -> (T, U)) -> [T: U] {
		var result: [T: U] = [:]
		for (key, value) in self {
			let (transformedKey, transformedValue) = transform(key, value)
			result[transformedKey] = transformedValue
		}
		return result
	}
	
	public func map<T: Hashable, U>( transform: (Key, Value) throws -> (T, U)) rethrows -> [T: U] {
		var result: [T: U] = [:]
		for (key, value) in self {
			let (transformedKey, transformedValue) = try transform(key, value)
			result[transformedKey] = transformedValue
		}
		return result
	}
}
