//
//  DateExtension.swift
//  VirtualTourist
//
//  Created by Abdullah on 2/15/17.
//  Copyright © 2017 Abdullah. All rights reserved.
//

import Foundation

extension Date {
    func toString() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.string(from: self)
    }
}
