//
//  CalculatorTableViewController.swift
//  DCACalculator
//
//  Created by Edgar on 01.11.22.
//

import UIKit

class CalculatorTableViewController: UITableViewController {
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var currencyLabels: [UILabel]!
    @IBOutlet weak var investmentCurrencyLabel: UILabel!
    
    var asset: Asset?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
    }

    private func setupView() {
        self.symbolLabel.text = asset?.searchResult.symbol
        self.nameLabel.text = asset?.searchResult.name
        self.currencyLabels.forEach { label in
            label.text = asset?.searchResult.currency.addBrackets()
        }
        self.investmentCurrencyLabel.text = asset?.searchResult.currency
    }
}
