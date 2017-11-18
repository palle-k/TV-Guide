
import Foundation
import UIKit
import Moya

class ProgramOverviewTableViewController: UITableViewController {
    
    private let programs: [String : Double] = ["ProSieben" : 1,
                                            "SAT.1" : 2,
                                            "kabel eins" : 3,
                                            "Sixx" : 4,
                                            "ProSiebenMaxx" : 5,
                                            "SAT.1 Gold" : 6,
                                            "kabel eins Doku" : 7]
    
    public var channel: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        channel = "SAT.1"
        
        self.title = channel
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 42
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "", for: indexPath) as! CurrentTableViewCell
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        //need: image, title, time
        var data: Data?
        let provider = MoyaProvider<EPGService>(plugins: [NetworkLoggerPlugin(verbose: true)])
        provider.request(
            .now(
                selection: "{data{id,type,title,tvChannelName,startTime,endTime,genres{type,title,subType},images{url}}}",
                limit: 1.0,
                sortby: "",
                sortascending: false,
                channelid: 1
            )
        ){
            switch $0 {
            case let .success(moyaResponse):
                print(String(data: moyaResponse.data, encoding: .utf8) ?? "")
                data = moyaResponse.data
                
            case let .failure(error):
                print(error)
            }
        }
        guard let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [String : Any],
                let title = json?["title"] as? String else {
            return cell
        }
        
        return cell
    }
}
