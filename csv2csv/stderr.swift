/*
 * stderr.swift
 * Localizer
 *
 * From https://stackoverflow.com/a/25226794/1152894
 *
 * Created by François Lamboley on 1/6/18.
 * Copyright © 2018 Frizlab. All rights reserved.
 */

import Foundation



class StandardErrorOutputStream : TextOutputStream {
	
	func write(_ string: String) {
		FileHandle.standardError.write(Data(string.utf8))
	}
	
}

var stderrStream = StandardErrorOutputStream()
