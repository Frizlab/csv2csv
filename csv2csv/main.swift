/*
 * main.swift
 * csv2csv
 *
 * Created by François Lamboley on 1/6/18.
 * Copyright © 2018 Frizlab. All rights reserved.
 */

import Foundation



let progVersion = "1.0"

enum ExitCodes : Int32, Error {
	case noError = 0
	case syntaxError = 1
	case ioError = 2
	case invalidUTF8 = 3
	case invalidCSV = 4

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
	/* Let's open the input file */
	let ifh: FileHandle
	if parsedArguments.inputFile == "-" {ifh = FileHandle.standardInput}
	else {
		guard let fh = FileHandle(forReadingAtPath: parsedArguments.inputFile) else {
			printError(programName: progName, errorMessage: "cannot open file at path \(parsedArguments.inputFile)", stream: &stderrStream)
			throw ExitCodes.ioError
		}
		ifh = fh
	}
	/* Let's read the file */
	let data = ifh.readDataToEndOfFile()
	ifh.closeFile()
	guard let stringInput = String(data: data, encoding: .utf8) else {
		printError(programName: progName, errorMessage: "invalid utf8 for file at path \(parsedArguments.inputFile)", stream: &stderrStream)
		throw ExitCodes.invalidUTF8
	}
	/* Let's parse the file */
	let parser = CSVParser(source: stringInput, startOffset: 0, separator: parsedArguments.inputSeparator, hasHeader: false, fieldNames: nil)
	guard let parsedRows = parser.arrayOfParsedRows() else {
		printError(programName: progName, errorMessage: "invalid csv for file at path \(parsedArguments.inputFile)", stream: &stderrStream)
		throw ExitCodes.invalidCSV
	}
	let numberOfColumns = parsedRows.reduce(0, { max($0, $1.count) })
	/* Let's open the output file */
	let ofh: FileHandle
	if parsedArguments.outputFile == "-" {ofh = FileHandle.standardOutput}
	else {
		_ = try? FileManager.default.removeItem(atPath: parsedArguments.outputFile)
		guard FileManager.default.createFile(atPath: parsedArguments.outputFile, contents: nil, attributes: nil) else {
			printError(programName: progName, errorMessage: "cannot create file at path \(parsedArguments.outputFile)", stream: &stderrStream)
			throw ExitCodes.ioError
		}
		guard let fh = FileHandle(forWritingAtPath: parsedArguments.outputFile) else {
			printError(programName: progName, errorMessage: "cannot open file at path \(parsedArguments.outputFile)", stream: &stderrStream)
			throw ExitCodes.ioError
		}
		ofh = fh
	}
	/* Let's write the result to the output */
	for row in parsedRows {
		var first = true
		for i in 1...numberOfColumns {
			if !first {ofh.write(Data(parsedArguments.outputSeparator.utf8))}
			first = false
			
			let v = row[CSVParser.defaultHeaderPrefix + String(i)] ?? ""
			ofh.write(Data(v.csvCellValueWithSeparator(parsedArguments.outputSeparator).utf8))
		}
		ofh.write(Data("\r\n".utf8))
	}
	ofh.closeFile()
} catch let error as ParsedCommandLineArguments.Error {
	switch error {
	case .help:                            usage(programName: progName, stream: &stdinStream);                                                    exit(ExitCodes.noError.rawValue)
	case .version:                         print("version: \(progVersion)");                                                                      exit(ExitCodes.noError.rawValue)
	case .missingArgumentForOption(let o): printError(programName: progName, errorMessage: "missing arg for option \(o)", stream: &stderrStream); exit(ExitCodes.syntaxError.rawValue)
	case .unknownOption(let o):            printError(programName: progName, errorMessage: "unknown option \(o)", stream: &stderrStream);         exit(ExitCodes.syntaxError.rawValue)
	case .missingInputFile:                printError(programName: progName, errorMessage: "no input file", stream: &stderrStream);               exit(ExitCodes.syntaxError.rawValue)
	case .tooManyArgs:                     printError(programName: progName, errorMessage: "stray args", stream: &stderrStream);                  exit(ExitCodes.syntaxError.rawValue)
	}
} catch let error as ExitCodes {
	exit(error.rawValue)
} catch {
	exit(ExitCodes.unknownError.rawValue)
}
