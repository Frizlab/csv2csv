/*
 * CommandLineOptionParser.swift
 * csv2csv
 *
 * Created by François Lamboley on 1/6/18.
 * Copyright © 2018 Frizlab. All rights reserved.
 */

import Foundation



struct CommandLineOption : Hashable, Equatable {
	
	enum ParseError : Error {
		case noArgForLongOption(String)
		case noArgForShortOption(Character)
		
		case unknownLongOption(String)
		case unknownShortOption(Character)
	}
	static func parse(arguments: [String], noArgOptions: [CommandLineOption: () throws -> Void], argOptions: [CommandLineOption: (_ arg: String) throws -> Void]) throws -> Int {
		var i = 0
		while i < arguments.count {
			let arg = arguments[i]
			
			if arg == "--" {
				/* Signal for end of options */
				return i + 1
				
			} else if arg.hasPrefix("--") {
				/* We got a long option */
				let optionName = String(arg.dropFirst(2))
				let commandLineOption = CommandLineOption(longName: optionName, shortName: nil)
				if let handler = noArgOptions[commandLineOption] {
					try handler()
				} else if let handler = argOptions[commandLineOption] {
					i += 1
					guard i < arguments.count else {throw ParseError.noArgForLongOption(optionName)}
					try handler(arguments[i])
				} else {
					throw ParseError.unknownLongOption(optionName)
				}
				
			} else if arg.hasPrefix("-") {
				/* We got a short option */
				var curChars = arg.dropFirst()
				for c in curChars {
					curChars.removeFirst()
					let commandLineOption = CommandLineOption(longName: nil, shortName: c)
					if let handler = noArgOptions[commandLineOption] {
						try handler()
					} else if let handler = argOptions[commandLineOption] {
						if !curChars.isEmpty {
							try handler(String(curChars))
							break
						} else {
							i += 1
							guard i < arguments.count else {throw ParseError.noArgForShortOption(c)}
							try handler(arguments[i])
						}
					} else {
						throw ParseError.unknownShortOption(c)
					}
				}
				
			} else {
				/* Not an option */
				return i
			}
			
			i += 1
		}
		return i
	}
	
	let longName: String?
	let shortName: Character? /* "-" is invalid, of course */
	
	let hashValue = 0 /* 😱 But yes. We assume we won't have many options in the options dictionaries 🤷‍♂️ */
	static func ==(lhs: CommandLineOption, rhs: CommandLineOption) -> Bool {
		return
			(lhs.shortName != nil && rhs.shortName != nil && lhs.shortName == rhs.shortName) ||
			(lhs.longName  != nil && rhs.longName  != nil && lhs.longName  == rhs.longName)
	}
	
}
