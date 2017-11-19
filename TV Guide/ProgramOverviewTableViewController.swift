
import Foundation
import UIKit
import Moya
import Alamofire
import SDWebImage

struct Response<DataItem: Codable>: Codable {
    var status: Int
    var response: [String: [DataItem]]
}

struct ShowImage: Codable {
	let url: URL
}

struct Show: Codable {
    var id: String
    var type: String
    var title: String?
	var description: String?
    var startTime: Int
    var endTime: Int
    var tvChannelName: String
	var images: [ShowImage]?
	var genres: [[String: String]]
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
    private let programs: [String : Int] = [
		"ProSieben" : 1,
		"SAT.1" : 2,
		"kabel eins" : 3,
		"Sixx" : 4,
		"ProSiebenMaxx" : 5,
		"SAT.1 Gold" : 6,
		"kabel eins Doku" : 7
	]
    
    public var channel: String!
    
    private var cellData: [Show] = []
    
    private var provider = MoyaProvider<EPGService>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channel = "ProSieben"
        
        self.title = channel
        
        guard let channelId = programs[channel] else {
            return
        }
        
        provider.request(
            .epg(
                selection: "{data{id,type,title,description,tvChannelName,startTime,endTime,genres{title},images{url}}}",
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
//				print(String(data: response.data, encoding: .utf8)!)
                let coder = JSONDecoder()
				let res: Response<Show>
				do {
					res = try coder.decode(Response<Show>.self, from: response.data)
				} catch let error {
					print(error)
					return
				}
				self.cellData = res.response["data", default: []].sorted(by: {$0.startTime < $1.startTime})
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
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		
		if  segue.identifier == "presentInfoView",
			let index = self.tableView.indexPathForSelectedRow?.row,
			let destination = segue.destination as? ProgramInfoTableViewController {
			
			let show = cellData[index]
			destination.show = show
		}
	}
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let startTimeSeconds = cellData[indexPath.row].startTime
        let endTimeSeconds = cellData[indexPath.row].endTime
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentProgramCell", for: indexPath) as! CurrentTableViewCell
            cell.tvShowImageView.sd_setImage(with: cellData[indexPath.row].images?.first?.url, completed: nil)
			
			cell.tvShowTitleLabel?.text = cellData[indexPath.row].title ?? "No Title Available"
			cell.tvShowTimeLabel?.text = clockFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(startTimeSeconds))) + " - " + clockFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(endTimeSeconds)))
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "UpcomingProgramCell", for: indexPath) as! UpcomingTableViewCell
			
			cell.tvShowImageView.sd_setImage(with: cellData[indexPath.row].images?.first?.url, completed: nil)
			
            cell.tvShowTitleLabel?.text = cellData[indexPath.row].title ?? "No Title Available"
            cell.tvShowTimeLabel?.text = clockFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(startTimeSeconds))) + " - " + clockFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(endTimeSeconds)))
            
            return cell
        }
    }
}
