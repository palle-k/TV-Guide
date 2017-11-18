
import UIKit
import Moya
import Foundation

class ProgramInfoTableViewController: UITableViewController {
    
    private let startTimeHour: Int = 9
    private let startTimeMinute: Int = 36
    private let endTimeHour: Int = 9
    private let endTimeMinute: Int = 37
    private var timer: Timer?
    
    @IBOutlet weak var timeProgressView: UIProgressView!
    @IBOutlet weak var timeLabel: UILabel!
    
    private func JSONResponseDataFormatter(_ data: Data) -> Data {
        do {
            let dataAsJSON = try JSONSerialization.jsonObject(with: data)
            let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
            return prettyData
        } catch {
            return data
        }
    }
    
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
        timer  = Timer.scheduledTimer(timeInterval: 10,
                                      target: self,
                                      selector: #selector(self.updateTimeProgressView),
                                      userInfo: nil,
                                      repeats: true)
        updateTimeProgressView()
        

        let provider = MoyaProvider<EPGService>()
        
        provider.request(.epg(key: "13cf7f8f841768c2666b183a5621ff01",
                              selection: "{data{id,type,title,tvChannelName,startTime,endTime,genres{type,title,subType},images{url}}}",
                              limit: 10,
                              sortby: "title",
                              sortascending: false,
                              channelid: 1,
                              ids: "",
                              from: "2017-11-18",
                              to: "2017-11-18",
                              showrunning: true
                        ),
                         completion: {
                            result in
                            print(result)
                            
        })
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


