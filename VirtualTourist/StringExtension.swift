//
//  StringExtension.swift
//  VirtualTourist
//
//  Created by Abdullah on 2/15/17.
//  Copyright © 2017 Abdullah. All rights reserved.
//

import Foundation

extension String {
    func trim() -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
    func isBlank () -> Bool {
        return self.trim().isEmpty
    }

    func toDate() -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy h:mm a"
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"
        return formatter.date(from: self)
    }
}
