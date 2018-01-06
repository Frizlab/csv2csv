/*
 * main.swift
 * csv2csv
 *
 * Created by François Lamboley on 1/6/18.
 * Copyright © 2018 Frizlab. All rights reserved.
 */

import Foundation



let progVersion = "1.0"

enum ExitCodes : Int32 {
	case noError = 0
	case syntaxError = 1
	
	case unknownError = 255
}

func usage<TargetStream : TextOutputStream>(programName: String, stream: inout TargetStream) {
	print("""
		Usage: \(programName) [options ...] input_file [output_file]
		
		input_file can be "-" to represent stdin.
		If output_file is given, outputs the result to the given file. Can be \
		the same as input_file. If "-" or omitted, the program will output on \
		stdout.
		
		Options:
		   -h --help: Show this message and exit
		   -v --version: Show the version and exit
		   -i --input-separator sep: The separator to use when reading the file. \
		Defaults to ";" (we assume the file is ill-formatted)
		   -o --output-separator sep: The separator to use when writing the \
		converted file. Defaults to ",", unless input-separator is ",", in which \
		case it defaults to ";"
		""", to: &stream
	)
}

func printError<TargetStream : TextOutputStream>(programName: String, errorMessage: String, stream: inout TargetStream) {
	print("\(progName): \(errorMessage)", to: &stream)
}

let progName = CommandLine.arguments[0]

do {
	let parsedArguments = try ParsedCommandLineArguments(args: Array(CommandLine.arguments.dropFirst()))
	print(parsedArguments)
} catch let error as ParsedCommandLineArguments.Error {
	switch error {
	case .help:                            usage(programName: progName, stream: &stdinStream);                                                    exit(ExitCodes.noError.rawValue)
	case .version:                         print("version: \(progVersion)");                                                                      exit(ExitCodes.noError.rawValue)
	case .missingArgumentForOption(let o): printError(programName: progName, errorMessage: "missing arg for option \(o)", stream: &stderrStream); exit(ExitCodes.syntaxError.rawValue)
	case .unknownOption(let o):            printError(programName: progName, errorMessage: "unknown option \(o)", stream: &stderrStream);         exit(ExitCodes.syntaxError.rawValue)
	case .missingInputFile:                printError(programName: progName, errorMessage: "no input file", stream: &stderrStream);               exit(ExitCodes.syntaxError.rawValue)
	case .tooManyArgs:                     printError(programName: progName, errorMessage: "stray args", stream: &stderrStream);                  exit(ExitCodes.syntaxError.rawValue)
	}
} catch {
	exit(ExitCodes.unknownError.rawValue)
}
