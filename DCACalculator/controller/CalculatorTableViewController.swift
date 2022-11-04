//
//  CalculatorTableViewController.swift
//  DCACalculator
//
//  Created by Edgar on 01.11.22.
//

import UIKit
import Combine

class CalculatorTableViewController: UITableViewController {
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet var currencyLabels: [UILabel]!
    @IBOutlet weak var investmentCurrencyLabel: UILabel!
    @IBOutlet weak var initialInvestmentAmountTextField: UITextField!
    @IBOutlet weak var monthlyAverageAmountTextField: UITextField!
    @IBOutlet weak var initialDateTextField: UITextField!
    @IBOutlet weak var dateSlider: UISlider!
    @IBOutlet weak var currentValueLabel: UILabel!
    @IBOutlet weak var investmentAmountLabel: UILabel!
    @IBOutlet weak var gainLabel: UILabel!
    @IBOutlet weak var yieldLabel: UILabel!
    @IBOutlet weak var annualReturnLabel: UILabel!
    
    var asset: Asset?
    
    @Published private var currentInitialDateIndex: Int?
    @Published private var initialInvestmentAmount: Int?
    @Published private var monthlyAverageAmount: Int?
    
    private var subscribers = Set<AnyCancellable>()
    private let dcaService = DCAService()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupTextFields()
        setupDateSlider()
        observeForm()
        resetViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        initialInvestmentAmountTextField.becomeFirstResponder()
    }
    
    @IBAction func sliderDidChange(_ sender: UISlider) {
        currentInitialDateIndex = Int(sender.value)
    }

    private func setupView() {
        navigationItem.title = asset?.searchResult.symbol
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
    
    private func setupDateSlider() {
        if let count = asset?.timeSeriesMonthlyAdjusted.getMonthInfos().count {
            let dateSliderSize = count - 1
            dateSlider.maximumValue = dateSliderSize.floatValue
        }
    }
    
    private func resetViews() {
        currentValueLabel.text = "0.00"
        investmentAmountLabel.text = "0.00"
        gainLabel.text = "-"
        yieldLabel.text = "-"
        annualReturnLabel.text = "-"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "segueToDateView"),
           let destinationVC = segue.destination as? DateSelectionTableViewController {
            destinationVC.timeSeriesMonthlyAdjusted = asset?.timeSeriesMonthlyAdjusted
            destinationVC.currentSelectedIndex = currentInitialDateIndex
            destinationVC.didSelectDate = { [weak self] index in
                self?.handleDateSelection(index: index)
            }
        }
    }
    
    private func handleDateSelection(index: Int) {
        guard navigationController?.visibleViewController is DateSelectionTableViewController else { return }
        navigationController?.popViewController(animated: true)
        if let dateString = asset?.timeSeriesMonthlyAdjusted.getMonthInfos()[index].date.MMYYFormat() {
            initialDateTextField.text = dateString
            currentInitialDateIndex = index
        }
    }
    
    private func observeForm() {
        $currentInitialDateIndex.sink { [weak self] (index) in
            guard let index = index else { return }
            self?.dateSlider.value = index.floatValue
            
            if let dateString = self?.asset?.timeSeriesMonthlyAdjusted.getMonthInfos()[index].date.MMYYFormat() {
                self?.initialDateTextField.text = dateString
            }
            
        }.store(in: &subscribers)
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: initialInvestmentAmountTextField).compactMap({
            ($0.object as? UITextField)?.text
        }).sink { [weak self] text in
            self?.initialInvestmentAmount = Int(text) ?? 0
        }.store(in: &subscribers)
        
        NotificationCenter.default.publisher(for: UITextField.textDidChangeNotification, object: monthlyAverageAmountTextField).compactMap { notification in
            var text = ""
            if let textField = notification.object as? UITextField {
                text = textField.text ?? ""
            }
            return text
        }.sink { [weak self] text in
            self?.monthlyAverageAmount = Int(text) ?? 0
        }.store(in: &subscribers)
        
        Publishers.CombineLatest3($currentInitialDateIndex, $initialInvestmentAmount, $monthlyAverageAmount).sink { [weak self] (currentInitialDateIndex, initialInvestmentAmount, monthlyAverageAmount) in
            
            guard let asset = self?.asset,
                  let initialInvestmentAmount = initialInvestmentAmount,
                  let monthlyAverageAmount = monthlyAverageAmount,
                  let currentInitialDateIndex = currentInitialDateIndex else { return }
            
            let result = self?.dcaService.calculate(asset: asset, initialInvestmentAmount: initialInvestmentAmount.doubleValue, monthlyDollarCostAmount: monthlyAverageAmount.doubleValue, initialDateInvestmentIndex: currentInitialDateIndex)
            
            let isProfitable = result?.isProfitable == true
            let gainSymbol = isProfitable ? "+" : ""
            
            self?.currentValueLabel.backgroundColor = isProfitable ? .themeGreenShade : .themeRedShade
            self?.currentValueLabel.text = result?.currentValue.currencyFormat
            self?.investmentAmountLabel.text = result?.investmentAmount.toCurrencyFormat(hasDecimalPlaces: false)
            self?.gainLabel.text = result?.gain.toCurrencyFormat(hasDollarSymbol: false, hasDecimalPlaces: false).prefix(with: gainSymbol)
            self?.yieldLabel.text = result?.yield.percentageFormat.prefix(with: gainSymbol).addBrackets()
            self?.yieldLabel.textColor = isProfitable ? .systemGreen : .systemRed
            self?.annualReturnLabel.text = result?.annualReturn.percentageFormat
            self?.annualReturnLabel.textColor = isProfitable ? .systemGreen : .systemRed
            
        }.store(in: &subscribers)
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
