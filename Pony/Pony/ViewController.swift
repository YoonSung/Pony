import UIKit


class ViewController: UIViewController {
    @IBOutlet weak var totalDeposit: CountingLabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        totalDeposit.count(fromValue: 0, to: 5000000, withDuration: 5,
                andAnimationType: CountingLabel.CounterAnimationType.EaseOut,
        andCounterType: CountingLabel.CounterType.Int)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
