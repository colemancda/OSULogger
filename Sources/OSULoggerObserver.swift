//
//  OSULoggerObserver.swift
//  OSULogger
//
//  Created by Orlando Bassotto on 2016-02-22.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

public protocol OSULoggerObserver {
    func log(event: OSULogger.Event)
}
