//
//  Package.swift
//  OSULogger
//
//  Created by William Dillon on 2016-02-18.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

import PackageDescription

let package = Package(
    name: "OSULogger",
    dependencies: [
        .Package(url: "ssh://git@git.cs.savantsystems.com:7999/rpesavant/pmjson.git", majorVersion: 2)
   ]
)

package.exclude = ["Tests"]

// Build dynamic library

let dylib = Product(name: "OSULogger", type: .Library(.Dynamic), modules: "OSULogger")

products.append(dylib)
