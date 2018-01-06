/*
 * main.swift
 * csv2csv
 *
 * Created by François Lamboley on 1/6/18.
 * Copyright © 2018 Frizlab. All rights reserved.
 */

import Foundation



func usage<TargetStream : TextOutputStream>(program_name: String, stream: inout TargetStream) {
	print("""
		Usage: \(program_name) [options ...] input_file [output_file]
		
		input_file can be "-" to represent stdin.
		If output_file is given, outputs the result to the given file. Can be \
		the same as input_file. If "-" or omitted, the program will output on \
		stdout.
		
		Options:
		   --help: Show this message and exit
		   --version: Show the version and exit
		   --input-separator sep: The separator to use when reading the file. \
		Defaults to ";" (we assume the file is ill-formatted)
		   --output-separator sep: The separator to use when writing the \
		converted file. Defaults to ",", unless input-separator is ",", in which \
		case it defaults to ";"
		""", to: &stream
	)
}

usage(program_name: CommandLine.arguments[0], stream: &stderrStream)
