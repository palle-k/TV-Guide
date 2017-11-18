
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
        
        loadCurrentProgram()
    }
    
    private func loadCurrentProgram() {
        guard let channel = channel,
            let chId = programs[channel] else {
            return
        }
        
        let provider = MoyaProvider<EPGService>(plugins: [NetworkLoggerPlugin(verbose: true)])
        provider.request(
            .now(
                selection: "{data{id,type,title,tvChannelName,startTime,endTime,genres{type,title,subType},images{url}}}",
                limit: 1.0,
                sortby: "startTime",
                sortascending: true,
                channelid: chId
            )
        ){
            switch $0 {
            case let .success(moyaResponse):
                print(String(data: moyaResponse.data, encoding: .utf8) ?? "")
            case let .failure(error):
                print(error)
            }
        }
    }
}
