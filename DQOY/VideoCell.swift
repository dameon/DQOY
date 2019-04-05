//
//  VideoCell.swift
//  DQOY
//
//  Created by Dameon Bryant on 10/18/16.
//  Copyright © 2016 Dameon Bryant. All rights reserved.
//

import UIKit
import youtube_ios_player_helper

class VideoCell: UICollectionViewCell {
    
    @IBOutlet weak var videoThumbnail: UIImageView!
    var playerView: YTPlayerView!
}
