//
//  Date+Extensions.swift
//  DCACalculator
//
//  Created by Edgar on 02.11.22.
//

import Foundation

extension Date {
    func MMYYFormat() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM yyyy"
        return dateFormatter.string(from: self)
    }
}
