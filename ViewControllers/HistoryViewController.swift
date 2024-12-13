import UIKit

class HistoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    var history: [String] = []
    let tableView = UITableView()
    let titleLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white

        titleLabel.text = "History"
        titleLabel.textColor = .orange
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(titleLabel)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HistoryCell")
        self.view.addSubview(tableView)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 30),
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])

        let imageView = UIImageView(image: UIImage(named: "Grabber"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 5),
            imageView.widthAnchor.constraint(equalToConstant: 200)
        ])
        
        loadHistory()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath)
        cell.textLabel?.text = history[indexPath.row]
        return cell
    }

    func appendToHistory(_ result: String) {
        history.append(result)
        saveHistory()
        tableView.reloadData()
    }

    func loadHistory() {
        if let historyData = UserDefaults.standard.array(forKey: "HISTORY_LIST") as? [String] {
            history = historyData
        }
    }

    func saveHistory() {
        UserDefaults.standard.set(history, forKey: "HISTORY_LIST")
    }

    func performCalculation(_ expression: String) {
        let components = expression.split(separator: " ")
        var result: Double = 0
        var currentExpression = ""
        var lastOperator = ""

        for (index, element) in components.enumerated() {
            if let number = Double(element) {
                if index == 0 {
                    result = number
                    currentExpression = "\(number)"
                } else {
                    result = calculate(result: result, number: number, operatorSymbol: lastOperator)
                    appendToHistory("\(currentExpression) \(lastOperator) \(number) = \(formatResult(result))")
                    currentExpression = "\(formatResult(result))"
                }
            } else {
                lastOperator = String(element)
            }
        }
    }

    private func calculate(result: Double, number: Double, operatorSymbol: String) -> Double {
        switch operatorSymbol {
        case "+":
            return result + number
        case "-":
            return result - number
        case "×", "*":
            return result * number
        case "÷", "/":
            return number != 0 ? result / number : 0
        default:
            return result
        }
    }

    private func formatResult(_ result: Double) -> String {
        return result.truncatingRemainder(dividingBy: 1) == 0 ? String(format: "%.0f", result) : String(result)
    }
}
