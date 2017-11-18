
import Foundation
import Moya

enum EPGService {
    case epg(
        key: String,
        selection: String,
        limit: Double,
        sortby: String,
        sortascending: Bool,
        channelid: Double,
        ids: String,
        from: String,
        to: String,
        showrunning: Bool
        )
    case now(
        key: String,
        selection: String,
        limit: Double,
        sortby: String,
        sortascending: Bool,
        channelid: Double
        )
}

extension EPGService: TargetType {
    var baseURL: URL {
        return URL(string: "https://hackatum.7tv.de/api-docs")!
    }
    
    var path: String {
        switch self {
        case .epg(key: _, selection: _, limit: _, sortby: _, sortascending: _, channelid: _, ids: _, from: _, to: _, showrunning: _):
            return "/epg"
        case .now(key: _, selection: _, limit: _, sortby: _, sortascending: _, channelid: _):
            return "/now"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        switch self {
        case .epg(_, let selection, let limit, let sortby, let sortascending, let channelid, let ids, let from, let to, let showrunning):
            return
                """
                {
                "selection": \(selection),
                "skip": 0.0,
                "limit": \(limit),
                "sortBy": \(sortby),
                "sortAscending": \(sortascending),
                "brand": "",
                "channelId": \(channelid),
                "search": "",
                "ids": \(ids),
                "from": \(from),
                "to": \(to),
                "showrunning": \(showrunning)
                }
""".utf8Encoded
        case .now(_, let selection, let limit, let sortby, let sortascending, let channelid):
            return
                """
                    {
                    "selection": \(selection),
                    "skip": 0.0,
                    "limit": \(limit),
                    "sortBy": \(sortby),
                    "sortAscending": \(sortascending),
                    "brand": "",
                    "channelId": \(channelid)
                    }
                    """.utf8Encoded
        }
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return ["Content-type": "application/json"]
    }
}

private extension String {
    var urlEscaped: String {
        return addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
    
    var utf8Encoded: Data {
        return data(using: .utf8)!
    }
}
