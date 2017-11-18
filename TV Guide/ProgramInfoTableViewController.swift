
import UIKit

class ProgramInfoTableViewController: UITableViewController {
    
    private let startTimeHour: Int = 1
    private let startTimeMinute: Int = 0
    private let endTimeHour: Int = 23
    private let endTimeMinute: Int = 0
    
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
        
        updateTimeProgressView()
    }
    
    private func updateTimeProgressView() {
        let now = Date()
   
        guard let startTime = createDate(hour: startTimeHour, minute: startTimeMinute),
            let endTime = createDate(hour: endTimeHour, minute: endTimeMinute) else {
                return
        }
        
        if  now < endTime && now > startTime {
            let duration = endTime.timeIntervalSince(startTime)
            let progress = now.timeIntervalSince(startTime)
            timeProgressView.setProgress((Float) (progress / duration), animated: false)
            
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


