import Foundation
class Network {
    static var headerUserAgent: String?
    static func urlRequestWithURL(_ url: URL?) -> URLRequest? {
        guard let url = url else {
            return nil
        }
        var urlRequest = URLRequest(url: url)
        if let headerUserAgent = Network.headerUserAgent {
            urlRequest.setValue(headerUserAgent, forHTTPHeaderField: "User-Agent")
        }
        return urlRequest
    }
    static func urlRequestWithString(_ string: String?) -> URLRequest? {
        guard let str = string else {
            return nil
        }
        if str.count == 0 {
            return nil
        }
        let url = URL(string: str)
        return Network.urlRequestWithURL(url)
    }
}
