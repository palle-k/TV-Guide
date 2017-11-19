
import Moya

enum EPGService {
    case epg(
		selection: String,
		limit: Double,
		sortBy: String,
		sortAscending: Bool,
		channelId: Int,
		ids: String,
		from: String,
		to: String,
		showrunning: Bool
	)
    case now(
		selection: String,
		limit: Double,
		sortBy: String,
		sortAscending: Bool,
		channelId: Double
	)
}

extension EPGService: TargetType {
    var baseURL: URL {
        return URL(string: "https://hackatum.7tv.de")!
    }
    
    var parameterEncoding: Moya.ParameterEncoding {
        return JSONEncoding.default
    }
    
    var path: String {
        switch self {
        case .epg:
            return "/api/v1/epg"
        case .now:
            return "/api/v1/epg/now"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
		return Data()
    }
    
    var task: Task {
		switch self {
        case let .epg(selection, limit, sortBy, sortAscending, channelId, ids, from, to, showrunning):
                return Task.requestParameters(
                    parameters: [
                        "selection": selection,
//                        "limit": limit,
//                        "sortBy": sortBy,
//                        "sortAscending": sortAscending,
                        "channelId": channelId,
//                        "ids": ids,
//                        "from": from,
//                        "to": to,
//                        "showrunning": showrunning,
                        "api_key": "13cf7f8f841768c2666b183a5621ff01"
                    ],
                    encoding: URLEncoding.queryString
                )
        case let .now(selection, limit, sortBy, sortAscending, channelId):
                return Task.requestParameters(
                    parameters: [
                        "selection": selection,
                        "api_key": "13cf7f8f841768c2666b183a5621ff01"
                    ],
                    encoding: URLEncoding.queryString
                )
        }
    }
    
    var headers: [String : String]? {
        return [
			"key" : "13cf7f8f841768c2666b183a5621ff01"
		]
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

fileprivate struct Request: Codable {
	var selection: String
//    var skip: Double
	var limit: Double
	var sortedBy: String
	var sortAscending: Bool
//    var brand: String
	var channelId: Double
//    var search: String
	var ids: String?
	var from: String?
	var to: String?
	var showrunning: Bool?
	
	private enum CodingKeys: String, CodingKey {
		case selection, /*skip,*/ limit, sortedBy, sortAscending, /*brand,*/ channelId, /*search,*/ ids, from, to, showrunning
	}
}
