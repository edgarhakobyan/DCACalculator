//
//  Double+Extensions.swift
//  DCACalculator
//
//  Created by Edgar on 04.11.22.
//

import Foundation

extension Double {
    var stringValue: String {
        return String(describing: self)
    }
    
    var twoDecimalPlaceString: String {
        return String(format: "%.2f", self)
    }
}
