//
//  StringExtension.swift
//  OSULogger
//
//  Created by Orlando Bassotto on 2015-02-20.
//  Copyright © 2015-2016 Oregon State University (CEOAS). All rights reserved.
//  Read LICENSE in the top level directory for further licensing information.
//

import Foundation

extension String {
    func stringByPadding(width: Int, pad: String) -> String {
#if os(OSX) || os(iOS) || os(watchOS) || os(tvOS)
        return stringByPaddingToLength(width, withString: pad, startingAtIndex: 0)
#else
        let length = self.characters.count

        guard length <= width else {
            return self
        }

        var result = self
        for _ in 1...(width - length) {
            result += pad
        }

        return result
#endif
    }
}
