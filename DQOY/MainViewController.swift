//
//  MainViewController.swift
//  DQOY
//
//  Created by Huynh Danh on 10/24/16.
//  Copyright © 2016 Dameon Bryant. All rights reserved.
//

import UIKit
import SDWebImage
import youtube_ios_player_helper

class MainViewController: UIViewController {
    
    var videos: [DQOYVideo] = []
    var playerView: YTPlayerView!
    var selectedItem: Int!
    
    var nextPageToken: String?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    func loadData() {
        var urlString = "https://www.googleapis.com/youtube/v3/search?key=AIzaSyDw0Hb57KudSutuPjHDTeuqJ8bUvZRmj0Y&channelId=UCf_lvAV5BNWvIxtK-y_BL3Q&part=snippet,id&order=date&maxResults=20"
        if let token = nextPageToken, videos.count != 0 {
            urlString += "&pageToken=\(token)"
        } else if nextPageToken == nil && videos.count != 0 {
            return
        }
        print("urlString: \(urlString)")
        DQOYClient.shared().getAllVideos(urlString: urlString) { (videos, nextPageToken, error) in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            self.nextPageToken = nextPageToken
            print("nextPageToken: \(nextPageToken)")
            
            DispatchQueue.global(qos: .default).async(execute: {
                DispatchQueue.main.async(execute: {
                    self.videos.append(contentsOf: videos)
                    self.collectionView.reloadData()
                })
            })
        }
    }
    
    @IBAction func didLongPress(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let location = sender.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: location) {
                selectedItem = indexPath.item
                playerView = YTPlayerView()
                
                let playerVars = ["controls": 0, "playsinline": 1, "showinfo": 0]
                playerView.delegate = self
                playerView.load(withVideoId: videos[indexPath.item].videoId, playerVars: playerVars)
                
                collectionView.reloadData()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            if identifier == "ShowPlayer" {
                if let video = sender as? DQOYVideo {
                    let playerVC = segue.destination as! PlayerViewController
                    playerVC.video = video
                }
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
        
        let video = videos[indexPath.item]
        cell.videoThumbnail.sd_setImage(with: URL(string: video.highImageUrl))
        
        if cell.playerView != nil {
            cell.playerView.removeFromSuperview()
            cell.playerView = nil
        }
        
        if playerView != nil, let selectedItem = selectedItem, selectedItem == indexPath.item {
            playerView.isUserInteractionEnabled = false
            playerView.translatesAutoresizingMaskIntoConstraints = false
            cell.playerView = playerView
            cell.addSubview(playerView)
            
            // add constraints
            let topConstraint = NSLayoutConstraint(item: playerView, attribute: .top, relatedBy: .equal, toItem: cell, attribute: .top, multiplier: 1.0, constant: 0.0)
            let bottomConstraint = NSLayoutConstraint(item: playerView, attribute: .bottom, relatedBy: .equal, toItem: cell, attribute: .bottom, multiplier: 1.0, constant: 0.0)
            let leftConstraint = NSLayoutConstraint(item: playerView, attribute: .left, relatedBy: .equal, toItem: cell, attribute: .left, multiplier: 1.0, constant: 0.0)
            let rightConstraint = NSLayoutConstraint(item: playerView, attribute: .right, relatedBy: .equal, toItem: cell, attribute: .right, multiplier: 1.0, constant: 0.0)
            cell.addConstraint(topConstraint)
            cell.addConstraint(bottomConstraint)
            cell.addConstraint(leftConstraint)
            cell.addConstraint(rightConstraint)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        if let selectedItem = self.selectedItem,
            selectedItem == indexPath.item && self.playerView != nil {
            self.playerView.stopVideo()
            self.playerView = nil
            self.selectedItem = nil
            
            collectionView.reloadData()
        } else {
            let video = self.videos[indexPath.item]
            performSegue(withIdentifier: "ShowPlayer", sender: video)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 3
        return CGSize(width: width, height: width * 9 / 12)
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let selectedItem = selectedItem, selectedItem == indexPath.item {
            if let playerView = playerView {
                if playerView.playerState() == .playing {
                    self.playerView.pauseVideo()
                } else if playerView.playerState() == .buffering || playerView.playerState() == .ended {
                    self.playerView.stopVideo()
                    self.playerView = nil
                    self.selectedItem = nil
                }
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if let selectedItem = selectedItem, selectedItem == indexPath.item {
            if let playerView = playerView, playerView.playerState() == .paused {
                self.playerView.playVideo()
            }
        }
        
        if indexPath.item == self.videos.count - 1 {
            loadData()
        }
    }
}

extension MainViewController: YTPlayerViewDelegate {
    
    func playerViewDidBecomeReady(_ playerView: YTPlayerView) {
        playerView.playVideo()
    }
}
