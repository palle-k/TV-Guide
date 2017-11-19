
import UIKit
import Moya
import Foundation

class ProgramInfoTableViewController: UITableViewController {
    
    // MOCK DATA
    private let startTimeHour: Int = 2
    private let startTimeMinute: Int = 00
    private let endTimeHour: Int = 10
    private let endTimeMinute: Int = 00
    
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
        timeLabel.text = dateFormatter.string(from: start) + " - " + dateFormatter.string(from: end)
        timer  = Timer.scheduledTimer(timeInterval: 10,
                                      target: self,
                                      selector: #selector(self.updateTimeProgressView),
                                      userInfo: nil,
                                      repeats: true)
        updateTimeProgressView()
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
        
        if  now <= endTime && now >= startTime {
            let duration = endTime.timeIntervalSince(startTime)
            let progress = now.timeIntervalSince(startTime)
            timeProgressView.setProgress((Float) (progress / duration), animated: true)
        } else if now > endTime {
            timeProgressView.setProgress(1, animated: true)
        } else if now < startTime {
            timeProgressView.setProgress(0, animated: true)
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


