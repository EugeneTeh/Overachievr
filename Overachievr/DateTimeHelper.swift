//
//  DateTimeHelper.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/6/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import Foundation

extension NSDate {

    func formattedDateTimeToString (format: String) -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.stringFromDate(self)
    }
}

