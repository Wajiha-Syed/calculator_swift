import UIKit

class ViewController: UIViewController {
  override var prefersHomeIndicatorAutoHidden: Bool {
     return false
   }
    var history: [String] = SharedData.history
    
 let buttonTitles = [
  "C", "<-", "%", "÷",
  "7", "8", "9", "×",
  "4", "5", "6", "-",
  "1", "2", "3", "+",
  "0", ".", "T", "="
 ]
  
 var buttons: [UIButton] = []
 let buttonWidth: CGFloat = 80
 let buttonHeight: CGFloat = 80
 let buttonSpacing: CGFloat = 15
 let horizontalMargin: CGFloat = 20
 let bottomMargin: CGFloat = 120
 var inputTextView: UITextView!
 let operatorSymbols = Set(["+", "÷", "×", "-", "="])
 let graySymbols = Set(["C", "<-", "%"])
 var firstOperand: Double? = nil
 var secondOperand: Double? = nil
 var currentOperator: String? = nil
 var isTypingNumber = false
    
  override func viewDidLoad() {
    super.viewDidLoad()
    self.view.backgroundColor = .white
    createButtons()
    setupTextView()
    createHistoryButton()
      
      history = SharedData.history
  }

  @objc private func historyButtonTapped() {
    let historyVC = HistoryViewController()
    historyVC.history = history
    self.present(historyVC, animated: true, completion: nil)
  }

  private func createHistoryButton() {
      let historyButton = UIButton()
      historyButton.translatesAutoresizingMaskIntoConstraints = false
      historyButton.setTitle("History", for: .normal)
      historyButton.setTitleColor(.white, for: .normal)
      historyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
      historyButton.backgroundColor = UIColor.orange
      historyButton.layer.cornerRadius = 20
      historyButton.addTarget(self, action: #selector(historyButtonTapped), for: .touchUpInside)
      view.addSubview(historyButton)
      NSLayoutConstraint.activate([
        historyButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
        historyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        historyButton.widthAnchor.constraint(equalToConstant: 100),
        historyButton.heightAnchor.constraint(equalToConstant: 40)
      ])
    }

 private func setupTextView() {
  inputTextView = UITextView()
  inputTextView.translatesAutoresizingMaskIntoConstraints = false
  inputTextView.backgroundColor = .white
  inputTextView.textColor = .black
  inputTextView.font = UIFont.boldSystemFont(ofSize: 40)
  inputTextView.textAlignment = .right
  inputTextView.isScrollEnabled = true
  inputTextView.text = "0"
  view.addSubview(inputTextView)
   NSLayoutConstraint.activate([
    inputTextView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(buttonHeight * 6 + buttonSpacing * 7 + bottomMargin - 120)),
      inputTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: horizontalMargin),
      inputTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -horizontalMargin),
      inputTextView.heightAnchor.constraint(equalToConstant: 120)
     ])
 }

 func createButtons() {
  let columns = 4
  for (index, title) in buttonTitles.enumerated() {
   let row = index / columns
   let col = index % columns
   let button = UIButton()
   button.translatesAutoresizingMaskIntoConstraints = false
   button.setTitle(title, for: .normal)
   button.titleLabel?.font = UIFont.systemFont(ofSize: 40)
   if operatorSymbols.contains(title) {
    button.backgroundColor = UIColor.orange
   } else if graySymbols.contains(title) {
    button.backgroundColor = UIColor.darkGray
   } else {
    button.backgroundColor = UIColor(white: 0.2, alpha: 1.0)
   }
   button.layer.cornerRadius = 40
   button.setTitleColor(.white, for: .normal)
   button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
   self.view.addSubview(button)
   let topConstant = CGFloat((4 - 1 - row)) * (buttonHeight + buttonSpacing)
   let leadingConstant = CGFloat(col) * (buttonWidth + buttonSpacing) + horizontalMargin
    NSLayoutConstraint.activate([
        button.widthAnchor.constraint(equalToConstant: buttonWidth),
        button.heightAnchor.constraint(equalToConstant: buttonHeight),
        button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(topConstant + bottomMargin)),
        button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leadingConstant)
       ])
  }
 }

  @objc private func buttonTapped(_ sender: UIButton) {
    guard let title = sender.title(for: .normal) else { return }
    if title == "History" {
      historyButtonTapped()
    } else if title == "T" {
      navigateToTableViewController()
    } else if operatorSymbols.contains(title) || title == "C" || title == "%" {
      handleOperatorInput(title)
    } else if title == "<-" {
      handleBackspace()
    }
    else {
      handleNumberInput(title)
    }
  }
    private func navigateToTableViewController() {
        let tableVC = TableViewController()

        if let currentText = inputTextView.text, let number = Int(currentText) {
            tableVC.number = number
        } else {
            let alert = UIAlertController(title: "Invalid Input", message: "Please enter a valid number.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return
        }
        self.present(tableVC, animated: true, completion: nil)
    }

    private func handleOperatorInput(_ operatorSymbol: String) {
        if operatorSymbol == "C" {
            inputTextView.text = "0"
            firstOperand = nil
            secondOperand = nil
            currentOperator = nil
            isTypingNumber = false
            return
        }

        if operatorSymbol == "<-" {
            handleBackspace()
        }

        if operatorSymbol == "=" {
            if let first = firstOperand,
                let second = Double(inputTextView.text?.split(separator: " ").last ?? ""),
                let op = currentOperator {
                let result = performOperation(first: first, second: second, operator: op)
                let formattedResult = formatResult(result)
                inputTextView.text = formattedResult
                let historyEntry = "\(formatResult(first)) \(op) \(formatResult(second)) = \(formattedResult)"
                history.append(historyEntry)
                SharedData.history.append(historyEntry)
                firstOperand = result
                secondOperand = nil
                currentOperator = nil
                isTypingNumber = false
            }
            return
        }

        // Handle operator press when there's an existing number in the text field
        if let currentText = inputTextView.text, let currentNumber = Double(currentText.split(separator: " ").last ?? "") {
            if let op = currentOperator {
                secondOperand = currentNumber
                if let first = firstOperand {
                    // Calculate the result so far
                    let result = performOperation(first: first, second: currentNumber, operator: op)
                    firstOperand = result
                    inputTextView.text = formatResult(result)

                    // Now update the history with the full equation (first operand, operator, second operand)
                    let currentHistoryEntry = "\(formatResult(first)) \(op) \(formatResult(secondOperand ?? 0)) = \(formatResult(result))"
                    history.append(currentHistoryEntry)
                    SharedData.history.append(currentHistoryEntry)

                    // After the second operand, the current operation will be displayed correctly
                    currentOperator = nil
                }
            } else {
                firstOperand = currentNumber
            }

            // Append the operator to the current expression
            let currentOperation = "\(formatResult(firstOperand ?? 0)) \(operatorSymbol) "
            inputTextView.text = currentOperation
            currentOperator = operatorSymbol
            isTypingNumber = false
        } else if operatorSymbol == "-" && inputTextView.text == "0" {
            inputTextView.text = "-"
        }
    }

  private func handleNumberInput(_ number: String) {
    if isTypingNumber {
     inputTextView.text = (inputTextView.text ?? "") + number
    } else {
     inputTextView.text = (inputTextView.text ?? "") + number
     isTypingNumber = true
    }
   }
    
  
 private func handleBackspace() {
  if let currentText = inputTextView.text, !currentText.isEmpty {
   inputTextView.text = String(currentText.dropLast())
   if inputTextView.text?.isEmpty ?? true {
    inputTextView.text = "0"
   }
  } else {
   inputTextView.text = "0"
  }
 }
   
 private func performOperation(first: Double, second: Double, operator op: String) -> Double {
  switch op {
  case "+":
   return first + second
  case "-":
   return first - second
  case "×":
   return first * second
  case "÷":
   return second != 0 ? first / second : 0
  case "%":
      return second != 0 ? first.truncatingRemainder(dividingBy: second) : 0
  default:
   return 0
  }
 }
  
 private func formatResult(_ result: Double) -> String {
  if result.truncatingRemainder(dividingBy: 1) == 0 {
   return String(format: "%.0f", result)
  } else {
   return String(result)
  }
 }
}
