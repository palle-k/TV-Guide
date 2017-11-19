
import Foundation
import UIKit
import Moya
import Alamofire

struct Response<DataItem: Codable>: Codable {
    var status: Int
    var response: [String: [DataItem]]
}

struct Show: Codable {
    var id: String
    var type: String
    var title: String
    var startTime: Double
    var endTime: Double
    var tvChannelName: String
    var pictureURL: String
}

let formatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "yyyy-MM-dd"
    return f
}()

let clockFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateFormat = "HH:mm"
    return f
}()

class ProgramOverviewTableViewController: UITableViewController {
    
    @IBOutlet var showTableView: UITableView!
    private let programs: [String : Double] = ["ProSieben" : 1,
                                            "SAT.1" : 2,
                                            "kabel eins" : 3,
                                            "Sixx" : 4,
                                            "ProSiebenMaxx" : 5,
                                            "SAT.1 Gold" : 6,
                                            "kabel eins Doku" : 7]
    
    public var channel: String!
    
    private var cellData: [Show] = []
    
    private var provider = MoyaProvider<EPGService>(plugins: [NetworkLoggerPlugin(cURL: true)])
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channel = "ProSiebenMaxx"
        
        self.title = channel
        
        guard let channelId = programs[channel] else {
            return
        }
        
        provider.request(
            .epg(
                selection: "{data{id,type,title,tvChannelName,startTime,endTime,genres{type,title,subType},images{url}}}",
                limit: 10,
                sortBy: "startTime",
                sortAscending: true,
                channelId: channelId,
                ids: "",
                from: formatter.string(from: Date()),
                to: formatter.string(from: Date(timeIntervalSinceNow: 12*60*60)),
                showrunning: false
        )) { result in
            switch result {
            case .success(let response):
                let coder = JSONDecoder()
                guard let response = try? coder.decode(Response<Show>.self, from: response.data) else {
                    return
                }
                self.cellData = response.response["data", default: []]
                self.tableView.reloadData()

            case .failure(let error):
                print(error)
                return
            }
        }
        
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cellData.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let startTimeSeconds = cellData[indexPath.row].startTime
        let endTimeSeconds = cellData[indexPath.row].endTime
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentProgramCell", for: indexPath) as! CurrentTableViewCell
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingProgramCell", for: indexPath) as! UpcomingTableViewCell
            
            cell.tvShowTitleLabel?.text = cellData[indexPath.row].title + cellData[indexPath.row].tvChannelName
            cell.tvShowTimeLabel?.text = clockFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(startTimeSeconds))) + " - " + clockFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(endTimeSeconds)))
            
            return cell
        }
    }
}
