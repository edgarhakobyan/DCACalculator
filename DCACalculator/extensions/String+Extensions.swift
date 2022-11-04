//
//  String+Extensions.swift
//  DCACalculator
//
//  Created by Edgar on 01.11.22.
//

import Foundation

extension String {
    func addBrackets() -> String {
        return "(\(self))"
    }
    
    func convertToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.date(from: self)
    }
    
    func prefix(with text: String) -> String {
        return "\(text)\(self)"
    }
}
