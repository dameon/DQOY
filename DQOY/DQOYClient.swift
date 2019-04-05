//
//  DQOYClient.swift
//  DQOY
//
//  Created by Huynh Danh on 10/24/16.
//  Copyright © 2016 Dameon Bryant. All rights reserved.
//

import Foundation

class DQOYClient {
    
    let sharedSession = URLSession.shared
    
    func getAllVideos(urlString: String, completion: @escaping (_ videos: [DQOYVideo], _ nextPageToken: String?, _ error: NSError?) -> Void) {
        taskForGETMethod(urlString: urlString) { (result, error) in
            
            func sendError(message: String) {
                let error = NSError(domain: "DQOYClient.getAllVideos", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
                completion([], nil, error)
            }
            
            if let error = error {
                sendError(message: error.localizedDescription)
                return
            }
            
            guard let dict = result as? [String: AnyObject] else {
                sendError(message: "Could not parse the result!")
                return
            }
            
            guard let items = dict["items"] as? [[String: AnyObject]] else {
                sendError(message: "Could not find the 'items' key in dictionary!")
                return
            }
            
            let nextPageToken = dict["nextPageToken"] as? String
            
            completion(DQOYVideo.getAllVideos(dicts: items), nextPageToken, nil)
        }
    }
    
    func taskForGETMethod(urlString: String, completion: @escaping (_ result: Any?, _ error: NSError?) -> Void) {
        guard let url = URL(string: urlString) else {
            let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "URL is invalid!"])
            completion(nil, error)
            return
        }
        let request = URLRequest(url: url)
        let task = sharedSession.dataTask(with: request) { (data, response, error) in
            
            func sendError(message: String) {
                let error = NSError(domain: "DQOYClient.taskForGETMethod", code: 0, userInfo: [NSLocalizedDescriptionKey: message])
                completion(nil, error)
            }
            
            if let error = error {
                sendError(message: error.localizedDescription)
                return
            }
            
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError(message: "statusCode != 2xx")
                return
            }
            
            guard let data = data else {
                sendError(message: "No data!")
                return
            }
            
            var parsedResult: Any!
            
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
            } catch let error as NSError {
                sendError(message: error.localizedDescription)
                return
            }
            
            completion(parsedResult, nil)
        }
        task.resume()
    }
    
    class func shared() -> DQOYClient {
        struct Singleton {
            static var shared = DQOYClient()
        }
        return Singleton.shared
    }
}
