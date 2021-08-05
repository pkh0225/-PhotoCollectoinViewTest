//
//  Request.swift
//  pkh0225
//
//  Created by pkh on 2021/07/11.
//

import Foundation



struct Request {
    static let API_URL: String = "https://api.unsplash.com/photos"
    static let API_SEARCH_URL: String = "https://api.unsplash.com/search/photos"
    static let API_KEY: String = "yyHAzdGjqPFqdUDTebz2aae4T8GCC1rZPa2536j0OVo"

    private static var URLCache: NSCache<NSString, AnyObject>?

    static let per_page: Int = 30


    static func getPhotos(query: String = "", pageIndex: Int, completion: @escaping ([String:Any]?, Error?) -> Void) -> URLSessionDataTask? {
        
        var urlComponent: URLComponents?
        if query.isValid {
            urlComponent = URLComponents(string: "\(API_SEARCH_URL)")
        }
        else {
            urlComponent = URLComponents(string: "\(API_URL)")
        }

        urlComponent?.queryItems = [
            URLQueryItem(name: "page", value: "\(pageIndex)"),
            URLQueryItem(name: "per_page", value: "\(per_page)"),
            URLQueryItem(name: "client_id", value: API_KEY)
        ]

        if query.isValid {
            urlComponent?.queryItems?.append(URLQueryItem(name: "query", value: query))
        }

        guard let url = urlComponent?.url else {
            assertionFailure("URL Failure")
            return nil
        }
//        print(url)

        if let data = getMemoryCaach(urlString: url.absoluteString) {
//            print("cache url: \(urlString)")
            completion(data, nil)
            return nil
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.timeoutInterval = TimeInterval(10)

        let task = URLSession.shared.dataTask(with: urlRequest) { data, response, error in
            if let _ = error {
//                print("iamge download error: " + error.localizedDescription + "\n")
                return
            }
            else if let response = response as? HTTPURLResponse {
                if response.statusCode == 200, let data = data, let json = try? JSONSerialization.jsonObject(with: data) {

                    var dic = [String: Any]()
                    if let jsonArray = json as? [[String: Any]] {
                        //                    print("json is array", jsonArray)
                        dic = ["dataList": jsonArray]
                    }
                    else if let jsonDictionary  = json as? [String: Any] {
                        //                    print("json is jsonDictionary ", jsonDictionary)
                        dic = jsonDictionary
                    }

                    completion(dic, error)

                    self.saveMemoryCache(urlString: url.absoluteString, dic: dic)
                }
                else {
                    print("response.statusCode: \(response.statusCode)")
                }
            }

        }
        task.resume()

        return task
    }

    static func getMemoryCaach(urlString: String?) -> [String: Any]? {
        guard let urlString = urlString, urlString.isValid else { return  nil }
        return Self.URLCache?.object(forKey: urlString as NSString) as? [String: Any]
    }

    static func saveMemoryCache(urlString: String?, dic: [String: Any]?) {
        guard let urlString = urlString, let dic = dic else { return }
        if Self.URLCache == nil {
            Self.URLCache = NSCache<NSString, AnyObject>()
            Self.URLCache?.countLimit = 100
            Self.URLCache?.totalCostLimit = 50 * 1024 * 1024;
        }
        if Self.URLCache?.object(forKey: urlString as NSString) == nil {
            Self.URLCache?.setObject(dic as AnyObject, forKey: urlString as NSString)
        }
    }

    static func momoryCacheClear() {
        Self.URLCache?.removeAllObjects()
    }


}
