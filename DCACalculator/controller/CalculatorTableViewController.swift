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
    @IBOutlet weak var initialInvestmentAmountTextField: UITextField!
    @IBOutlet weak var monthlyAverageAmountTextField: UITextField!
    @IBOutlet weak var initialDateTextField: UITextField!
    
    var asset: Asset?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupTextFields()
    }

    private func setupView() {
        self.symbolLabel.text = asset?.searchResult.symbol
        self.nameLabel.text = asset?.searchResult.name
        self.currencyLabels.forEach { label in
            label.text = asset?.searchResult.currency.addBrackets()
        }
        self.investmentCurrencyLabel.text = asset?.searchResult.currency
    }
    
    private func setupTextFields() {
        self.initialInvestmentAmountTextField.addDoneButton()
        self.monthlyAverageAmountTextField.addDoneButton()
        self.initialDateTextField.delegate = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToDateView"),
           let destinationVC = segue.destination as? DateSelectionTableViewController {
            destinationVC.timeSeriesMonthlyAdjusted = asset?.timeSeriesMonthlyAdjusted
        }
    }
}

extension CalculatorTableViewController: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if (initialDateTextField == textField) {
            performSegue(withIdentifier: "segueToDateView", sender: nil)
            return false
        }
        return true
    }
}
