//
//  PlayerViewController.swift
//  DQOY
//
//  Created by Huynh Danh on 10/24/16.
//  Copyright © 2016 Dameon Bryant. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class PlayerViewController: UIViewController {
    
    var video: DQOYVideo!
    
    @IBOutlet weak var playerView: YTPlayerView!
    
    @IBAction func back(_ sender: AnyObject) {
        navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let video = video {
            let playerVars = ["controls": 1, "playsinline": 1, "showinfo": 0, "fs": 0]
            playerView.load(withVideoId: video.videoId, playerVars: playerVars)
            playerView.webView?.backgroundColor = UIColor.clear
            playerView.webView?.isOpaque = false
            playerView.delegate = self
            
            navigationItem.title = video.title
        }
    }
}

extension PlayerViewController: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }
    
}
