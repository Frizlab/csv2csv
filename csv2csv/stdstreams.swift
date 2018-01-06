/*
 * stdstreams.swift
 * Localizer
 *
 * From https://stackoverflow.com/a/25226794/1152894
 *
 * Created by François Lamboley on 1/6/18.
 * Copyright © 2018 Frizlab. All rights reserved.
 */

import Foundation



class FileHandleOutputStream : TextOutputStream {
	
	let fileHandle: FileHandle
	
	init(fh: FileHandle) {
		fileHandle = fh
	}
	
	func write(_ string: String) {
		fileHandle.write(Data(string.utf8))
	}
	
}

var stdinStream  = FileHandleOutputStream(fh: FileHandle.standardInput)
var stderrStream = FileHandleOutputStream(fh: FileHandle.standardError)
