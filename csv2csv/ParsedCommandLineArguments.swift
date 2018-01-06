/*
 * ParsedCommandLineArguments.swift
 * csv2csv
 *
 * Created by François Lamboley on 1/6/18.
 * Copyright © 2018 Frizlab. All rights reserved.
 */

import Foundation



struct ParsedCommandLineArguments {
	
	enum Error : Swift.Error {
		case missingArgumentForOption(String)
		case unknownOption(String)
		case missingInputFile
		case tooManyArgs
		
		case version
		case help
	}
	
	let inputFile: String
	let outputFile: String
	
	let inputSeparator: String
	let outputSeparator: String
	
	init(args: [String]) throws {
		var inputSeparatorBuilding: String?
		var outputSeparatorBuilding: String?

		let noArgsOptionsHandlers = [
			CommandLineOption(longName: "help",    shortName: "h"): { () -> Void in throw Error.help },
			CommandLineOption(longName: "version", shortName: "v"): { () -> Void in throw Error.version }
		]
		let argsOptionsHandlers = [
			CommandLineOption(longName: "input-separator",  shortName: "i"): { (_ arg: String) -> Void in inputSeparatorBuilding  = arg },
			CommandLineOption(longName: "output-separator", shortName: "o"): { (_ arg: String) -> Void in outputSeparatorBuilding = arg }
		]
		
		let delta: Int
		do {
			delta = try CommandLineOption.parse(arguments: args, noArgOptions: noArgsOptionsHandlers, argOptions: argsOptionsHandlers)
		} catch let error as CommandLineOption.ParseError {
			switch error {
			case .unknownLongOption(let option): throw Error.unknownOption(option)
			case .unknownShortOption(let coption): throw Error.unknownOption(String(coption))
			case .noArgForLongOption(let option): throw Error.missingArgumentForOption(option)
			case .noArgForShortOption(let coption): throw Error.missingArgumentForOption(String(coption))
			}
		} catch let error as Error {
			throw error
		} catch {
			fatalError()
		}
		var remainingArgs = args.dropFirst(delta)
		
		let isep = inputSeparatorBuilding ?? ";"
		inputSeparator = isep
		outputSeparator = outputSeparatorBuilding ?? (isep != "," ? "," : ";")
		
		guard let i = remainingArgs.first else {throw Error.missingInputFile}
		inputFile = i; remainingArgs.removeFirst()
		
		if let o = remainingArgs.first {outputFile = o; remainingArgs.removeFirst()}
		else                           {outputFile = "-"}
		
		guard remainingArgs.isEmpty else {throw Error.tooManyArgs}
	}
	
}
