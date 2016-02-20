//
//  Package.swift
//  OSULogger
//
//  Created by William Dillon on 2016-02-18.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

import PackageDescription

var package = Package(name: "OSULogger")

// MARK: Custom configuration

// Only include the JSON library if the user desires JSON serialization
package.dependencies = [Package.Dependency.Package(url: "https://github.com/hpux735/PMJSON.git", majorVersion: 0, minor: 9)]
