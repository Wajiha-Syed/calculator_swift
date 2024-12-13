import UIKit

class TableViewController: UIViewController, UITextFieldDelegate {
    var number: Int?
    var table: [String] = []
    var numberTextField: UITextField!
    var rangeTextField: UITextField!
    var generateButton: UIButton!
    var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupTitleLabel()
        setupInputFields()
        setupTableView()
        let imageView = UIImageView(image: UIImage(named: "Grabber"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(imageView)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 5),
            imageView.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    // Title label setup
    private func setupTitleLabel() {
        let titleLabel = UILabel()
        titleLabel.text = "Table Calculator"
        titleLabel.textColor = .orange
        titleLabel.font = UIFont.boldSystemFont(ofSize: 24)
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 60),
            titleLabel.centerXAnchor.constraint(equalTo: self.view.centerXAnchor)
        ])
    }

    // Input fields setup
    private func setupInputFields() {
        numberTextField = UITextField()
        numberTextField.translatesAutoresizingMaskIntoConstraints = false
        numberTextField.placeholder = "Enter Number"
        numberTextField.borderStyle = .roundedRect
        numberTextField.backgroundColor = .white
        numberTextField.borderStyle = .line
        numberTextField.textColor = .black
        numberTextField.keyboardType = .numberPad
        numberTextField.delegate = self  // Set the delegate to self

        rangeTextField = UITextField()
        rangeTextField.translatesAutoresizingMaskIntoConstraints = false
        rangeTextField.placeholder = "Enter Range"
        rangeTextField.backgroundColor = .white
        rangeTextField.borderStyle = .line
        rangeTextField.textColor = .black
        rangeTextField.keyboardType = .numberPad
        rangeTextField.delegate = self  // Set the delegate to self

        generateButton = UIButton(type: .system)
        generateButton.translatesAutoresizingMaskIntoConstraints = false
        generateButton.setTitle("Generate Table", for: .normal)
        generateButton.backgroundColor = .orange
        generateButton.setTitleColor(.white, for: .normal)
        generateButton.layer.cornerRadius = 8
        generateButton.addTarget(self, action: #selector(generateTable), for: .touchUpInside)

        self.view.addSubview(numberTextField)
        self.view.addSubview(rangeTextField)
        self.view.addSubview(generateButton)

        NSLayoutConstraint.activate([
            numberTextField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 120),
            numberTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            numberTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),

            rangeTextField.topAnchor.constraint(equalTo: numberTextField.bottomAnchor, constant: 20),
            rangeTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
            rangeTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),

            generateButton.topAnchor.constraint(equalTo: rangeTextField.bottomAnchor, constant: 20),
            generateButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            generateButton.heightAnchor.constraint(equalToConstant: 44),
            generateButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 110),
            generateButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -110)
        ])
    }

    // Table view setup
    private func setupTableView() {
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .white
        tableView.separatorColor = .black
        self.view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: generateButton.bottomAnchor, constant: 20),
            tableView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }

    // Handle table generation
    @objc private func generateTable() {
        guard let numberText = numberTextField.text, let number = Int(numberText),
              let rangeText = rangeTextField.text, let range = Int(rangeText), range > 0 else {
            showErrorAlert()
            return
        }

        table = (1...range).map { "\(number) x \($0) = \(number * $0)" }
        tableView.reloadData()
        let tableHistory = "Table of \(number)\n" + table.joined(separator: "\n")
        SharedData.history.append(tableHistory)
    }

    // Show error alert if inputs are invalid
    private func showErrorAlert() {
        let alert = UIAlertController(title: "Error", message: "Please enter valid number and range.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    // UITextFieldDelegate method to limit character input to 5
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        return newText.count <= 5 // Limit to 5 characters
    }
}

extension TableViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return table.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = table[indexPath.row]
        cell.textLabel?.textColor = .black
        cell.backgroundColor = .white
        return cell
    }
}
