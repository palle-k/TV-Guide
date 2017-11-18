
import UIKit

class ProgramInfoTableViewController: UITableViewController {
    
    private let startTimeHour: Int = 7
    private let startTimeMinute: Int = 50
    private let endTimeHour: Int = 7
    private let endTimeMinute: Int = 51
    private var timer: Timer?
    
    
    
    @IBOutlet weak var timeProgressView: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        self.tableView.estimatedRowHeight = 80
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        guard let start = createDate(hour: startTimeHour, minute: startTimeMinute),
            let end = createDate(hour: endTimeHour, minute: endTimeMinute) else {
                return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        let startString = dateFormatter.string(from: start)
        let endString = dateFormatter.string(from: end)
        
        timeLabel.text = startString + " - " + endString
        timer  = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(self.updateTimeProgressView), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    @objc private func updateTimeProgressView() {
        let now = Date()
   
        guard let startTime = createDate(hour: startTimeHour, minute: startTimeMinute),
            let endTime = createDate(hour: endTimeHour, minute: endTimeMinute) else {
                return
        }
        
        if  now < endTime && now > startTime {
            let duration = endTime.timeIntervalSince(startTime)
            let progress = now.timeIntervalSince(startTime)
            timeProgressView.setProgress((Float) (progress / duration), animated: false)
        } else {
            timeProgressView.progress = 0
        }
    }

    private func createDate(hour: Int, minute: Int) -> Date? {
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        let now = Date()
        dateComponents.year = calendar.component(.year, from: now)
        dateComponents.month = calendar.component(.month, from: now)
        dateComponents.day = calendar.component(.day, from: now)
        dateComponents.hour = hour
        dateComponents.minute = minute
        return Calendar.current.date(from: dateComponents)
    }
    
}


