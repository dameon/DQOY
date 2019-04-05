//
//  DQOYVideo.swift
//  DQOY
//
//  Created by Huynh Danh on 10/24/16.
//  Copyright © 2016 Dameon Bryant. All rights reserved.
//

import Foundation

class DQOYVideo {
    
    var videoId: String!
    var title: String!
    var imageUrl: String!
    var highImageUrl: String!
    
    init?(dict: [String: AnyObject]) {
        guard let id = dict["id"] as? [String: AnyObject],
            let videoId = id["videoId"] as? String else {
                return nil
        }
        
        guard let snippet = dict["snippet"] as? [String: AnyObject] else {
            return nil
        }
        
        guard let title = snippet["title"] as? String else {
            return nil
        }
        
        guard let thumbnails = snippet["thumbnails"] as? [String: AnyObject],
            let defaultThumbnail = thumbnails["default"] as? [String: AnyObject],
            let imageUrl = defaultThumbnail["url"] as? String else {
                return nil
        }
        
        if let highThumbnail = thumbnails["high"] as? [String: AnyObject], let highImageUrl = highThumbnail["url"] as? String {
            self.highImageUrl = highImageUrl
        }
        
        self.videoId = videoId
        self.title = title
        self.imageUrl = imageUrl
    }
    
    class func getAllVideos(dicts: [[String: AnyObject]]) -> [DQOYVideo] {
        var videos: [DQOYVideo] = []
        for dict in dicts {
            if let video = DQOYVideo(dict: dict) {
                videos.append(video)
            }
        }
        return videos
    }
}
