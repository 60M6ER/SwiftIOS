//
//  ViewController.swift
//  FirstStoryboard
//
//  Created by Борис Ларионов on 20.03.2026.
//

import UIKit

class ViewController: UIViewController {
    
    private var historyText: String = ""
    private var mainText: String = ""
    private var firstNumber: Double? = nil
    private var secondNumber: Double? = nil
    private var result: Double = 0
    private var isMainTextEmpty: Bool {
        return mainText.isEmpty
    }
    
    private var lastClickEqual: Bool = false
    private var currentOperation: Operation? = nil
    
    @IBOutlet weak var historyLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    
    @IBOutlet weak var resetButton: UIButton!
    
    private enum Operation: String {
        case plus = "+"
        case minus = "-"
        case multiply = "x"
        case divide = "/"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }

    // MARK: Main update UI
    private func updateUI() {
        historyLabel.text = historyText
        mainLabel.text = mainText
        if (isMainTextEmpty || lastClickEqual) {
            resetButton.titleLabel?.text = "AC"
        } else {
            resetButton.titleLabel?.text = "C"
        }
    }
    
    // MARK: Clear all data ito memory of App
    private func clearMemory() {
        historyText = ""
        mainText = ""
        firstNumber = nil
        secondNumber = nil
        result = 0
        currentOperation = nil
        lastClickEqual = false
        updateUI()
    }
    
    // MARK: Clean current input text
    private func clearMainText() {
        mainText = ""
        updateUI()
    }
    
    // MARK: Add value into main text
    private func addNumberToMainLabel(_ number: String) {
        mainText.append(number)
        updateUI()
    }
    
    // MARK: formatter numbers for display
    private func formatNumber(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 10
        formatter.minimumIntegerDigits = 1
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
    
    // MARK: Calculator
    private func calculate() {
        guard let currentOperation, let firstNumber, let secondNumber else { return }
        
        switch currentOperation {
        case .plus:
            result = firstNumber + secondNumber
        case .minus:
            result = firstNumber - secondNumber
        case .multiply:
            result = firstNumber * secondNumber
        case .divide:
            result = firstNumber / secondNumber
        }
    }
    
    
    @IBAction func resetClick(_ sender: UIButton) {
        if (isMainTextEmpty || lastClickEqual) {
            self.clearMemory()
        } else {
            self.clearMainText()
        }
    }
    
    @IBAction func clickNumberButton(_ sender: UIButton) {
        if lastClickEqual {
            self.clearMemory()
            lastClickEqual = false
        }
        if let number = sender.titleLabel?.text {
            if number == "." {
                if mainText.contains(".") || mainText.contains(",") { return }
            }
            self.addNumberToMainLabel(number)
        }
    }
    
    @IBAction func clickOperationButton(_ sender: UIButton) {
        
        if firstNumber == nil && mainText == "" {
            return
        }
        if lastClickEqual {
            firstNumber = result
            currentOperation = nil
            mainText = ""
        }
        lastClickEqual = false
        
        guard let operation = Operation(rawValue: sender.titleLabel?.text ?? "") else { return }
        
        if firstNumber == nil {
            firstNumber = Double(mainText) ?? 0
            mainText = ""
            historyText = formatNumber(firstNumber!) + operation.rawValue
        } else {
            if mainText != "" {
                secondNumber = Double(mainText) ?? 0
                mainText = ""
                calculate()
                firstNumber = result
            }
            historyText = formatNumber(firstNumber!) + operation.rawValue
        }
        currentOperation = operation
        updateUI()
    }
    
    
    @IBAction func clicEqual(_ sender: Any) {
        if firstNumber == nil || currentOperation == nil {
            return
        }
        if mainText != "" && !lastClickEqual {
            secondNumber = Double(mainText) ?? 0
            historyText = formatNumber(firstNumber!) + currentOperation!.rawValue + formatNumber(secondNumber!)
            calculate()
            firstNumber = result
            mainText = formatNumber(result)
        } else {
            if secondNumber != nil {
                calculate()
                historyText = formatNumber(firstNumber!) + currentOperation!.rawValue + formatNumber(secondNumber!)
                firstNumber = result
                mainText = formatNumber(result)
            }
        }
        lastClickEqual = true
        updateUI()
    }
    
    
    @IBAction func ClickPlusMinus(_ sender: Any) {
        if (mainText == "") {
            mainText.append("-")
        } else if (mainText == "-") {
            mainText = ""
        } else {
            let number = Double(mainText) ?? 0
            mainText = formatNumber(-number)
        }
        updateUI()
    }
    
    @IBAction func clickPercent(_ sender: Any) {
        if (firstNumber != nil || currentOperation != nil || mainText != "") {
            if let numeber = Double(mainText) {
                switch currentOperation {
                case .plus, .minus:
                    secondNumber = firstNumber! * numeber / 100
                case .multiply, .divide:
                    secondNumber = numeber / 100
                default:
                    break
                }
                historyText = formatNumber(firstNumber!) + currentOperation!.rawValue + formatNumber(secondNumber!)
                calculate()
                mainText = formatNumber(result)
                lastClickEqual = true
                updateUI()
            }
        }
    }
}

