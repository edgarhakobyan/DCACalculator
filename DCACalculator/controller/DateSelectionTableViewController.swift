//
//  DateSelectionTableViewController.swift
//  DCACalculator
//
//  Created by Edgar on 02.11.22.
//

import UIKit

class DateSelectionTableViewController: UITableViewController {
    
    var timeSeriesMonthlyAdjusted: TimeSeriesMonthlyAdjusted?
    var didSelectDate: ( (Int) -> Void )?
    var currentSelectedIndex: Int?
    private var monthInfos: [MonthInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let monthInfos = timeSeriesMonthlyAdjusted?.getMonthInfos() {
            self.monthInfos = monthInfos
        }
        
        title = "Select date"
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return monthInfos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell", for: indexPath) as? DateTableViewCell {
            let monthInfo = monthInfos[indexPath.row]
            let isSelected = currentSelectedIndex == indexPath.row
            cell.configure(with: monthInfo, index: indexPath.row, isSelected: isSelected)
            return cell
        }
        return UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didSelectDate?(indexPath.row)
    }

}
