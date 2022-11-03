//
//  DateTableViewCell.swift
//  DCACalculator
//
//  Created by Edgar on 02.11.22.
//

import UIKit

class DateTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthsAgoLabel: UILabel!
    
    func configure(with monthInfo: MonthInfo, index: Int, isSelected: Bool) {
        self.dateLabel.text = monthInfo.date.MMYYFormat()
        self.accessoryType = isSelected ? .checkmark : .none
        
        if index == 0 {
            self.monthsAgoLabel.text = "Just Invested"
        } else if index == 1 {
            self.monthsAgoLabel.text = "1 month ago"
        } else if index > 1 {
            self.monthsAgoLabel.text = "\(index) months ago"
        }
    }

}
