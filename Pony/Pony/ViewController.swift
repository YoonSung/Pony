    import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var totalDeposit: CountingLabel!
    @IBOutlet weak var spendingMoneyOfYesterdayLabel: CountingLabel!
    @IBOutlet weak var remainingMoneyOfTodayLabel: CountingLabel!
    
    var shopNameTextField: UITextField?
    var spentMoneyTextField: UITextField?

    func getDeposit() -> Deposit {
        do {
            return try DepositRepository.get()
        } catch let error {
            fatalError("\(error)")
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        DepositRepository.initialize()
        updateView(from: 0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func paste() {
        if let copied = UIPasteboard.general.string,
           !copied.isEmpty,
           let parseResult = SMSMessageParser.parse(smsMessage: copied) {
            self.spend(at: parseResult.shopName, amounts: parseResult.spentMoney)
        } else {
            alert(message: "No card use sms found")
         }
    }

    @IBAction func input() {
        let alertController = UIAlertController(
                title: "Spent Money",
                message: nil,
                preferredStyle: .alert)
        alertController.addTextField(configurationHandler: shopNameTextField)
        alertController.addTextField(configurationHandler: spentMoneyTextField)

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Submit", style: .default, handler: self.okHandler))
        self.present(alertController, animated: true)
    }

    func shopNameTextField(_ textField: UITextField) {
        shopNameTextField = textField
        shopNameTextField?.placeholder = "shop name"
        shopNameTextField?.borderStyle = .roundedRect
        shopNameTextField?.layer.borderColor = UIColor.white.cgColor
        setPadding(shopNameTextField)
    }

    func spentMoneyTextField(_ textField: UITextField) {
        spentMoneyTextField = textField
        spentMoneyTextField?.placeholder = "cost"
        spentMoneyTextField?.borderStyle = .roundedRect
        spentMoneyTextField?.layer.borderColor = UIColor.white.cgColor
        setPadding(spentMoneyTextField)

        spentMoneyTextField?.keyboardType = .numberPad
        spentMoneyTextField?.delegate = self
    }

    // 닫히지 않게끔
    func okHandler(alert: UIAlertAction) {
        if let shopName = shopNameTextField?.text,
           let spentMoneyString = spentMoneyTextField?.text,
            let spentMoney = Float(spentMoneyString),
           !shopName.isEmpty && spentMoney != 0 {
            spend(at: shopName, amounts: spentMoney)
        } else {
            self.alert(message: "input all field!")
        }
    }

    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        if string.count == 0 {
            return true
        }

        let currentText = textField.text ?? ""
        let replacementText = (currentText as NSString).replacingCharacters(in: range, with: string)

        return isValidDouble(at: replacementText , maxDecimalPlaces: 2)
    }

    private func spend(at shopName: String, amounts spentMoney: Float) {
        let deposit = getDeposit()
        deposit.spend(at: shopName, amounts: spentMoney)
        do {
            try DepositRepository.update(deposit: deposit)
            updateView()
        } catch let error {
            alert(message: "\(error)")
        }
    }

    private func updateView() {
        updateView(from: nil)
    }

    private func updateView(from: Float?) {
        let deposit = getDeposit()
        countLabel(at: totalDeposit, to: deposit.totalRemaining)
        countLabel(at: spendingMoneyOfYesterdayLabel, to: deposit.spendingMoneyOfYesterday)
        countLabel(at: remainingMoneyOfTodayLabel, to: deposit.remainingMoneyOfToday, useCurrencyCode: false)
    }

    private func alert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(alert, animated: true, completion: nil)
    }

    private func setPadding(_ textField: UITextField?) {
        if let tf = textField {
            let paddingView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: 8, height: 10))
            tf.leftView = paddingView;
            tf.leftViewMode = .always;
            tf.rightView = paddingView;
            tf.rightViewMode = .always;
        }
    }

    private func countLabel(at label: CountingLabel, from: Float? = nil, to endPoint: Float, useCurrencyCode: Bool = true) {
        let floatValue: Float;
        if let f = from {
            floatValue = f
        } else {
            floatValue = label.getCountingValue()
        }

        label.count(fromValue: floatValue,
                to: endPoint,
                withDuration: 1,
                andAnimationType: CountingLabel.CounterAnimationType.EaseOut,
                andCounterType: CountingLabel.CounterType.Int,
                useCurrencyCode: useCurrencyCode)
    }

    private func isValidDouble(at text: String, maxDecimalPlaces: Int) -> Bool {
        let formatter = NumberFormatter()
        formatter.allowsFloats = true
        let decimalSeparator = formatter.decimalSeparator ?? "."

        if formatter.number(from: text) != nil {
            let split = text.components(separatedBy: decimalSeparator)
            let digits = split.count == 2 ? split.last ?? "" : ""
            return digits.count <= maxDecimalPlaces
        }
        return false
    }
}
