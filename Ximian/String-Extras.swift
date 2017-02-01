//
//  String-Extras.swift
//  Swift Tools
//
//  Created by Fahim Farook on 23/7/14.
//  Copyright (c) 2014 RookSoft Pte. Ltd. All rights reserved.
//

import AppKit

extension String {
	func positionOf(sub:String)->Int {
		var pos = -1
		if let range = range(of:sub) {
			if !range.isEmpty {
				pos = characters.distance(from:startIndex, to:range.lowerBound)
			}
		}
		return pos
	}
	
	func subString(start:Int, length:Int = -1)->String {
		var len = length
		if len == -1 {
			len = characters.count - start
		}
		let st = characters.index(startIndex, offsetBy:start)
		let en = characters.index(st, offsetBy:len)
		let range = st ..< en
		return substring(with:range)
	}

	func range()->Range<String.Index> {
		return Range<String.Index>(startIndex ..< endIndex)
	}
}

