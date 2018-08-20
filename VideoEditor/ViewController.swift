//
//  ViewController.swift
//  VideoEditor
//
//  Created by Hiem Seyha on 8/17/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class ViewController: UIViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let videoURL = URL(string: "https://clips.vorwaerts-gmbh.de/big_buck_bunny.mp4")
    let player = AVPlayer(url: videoURL!)
    let playerLayer = AVPlayerLayer(player: player)
    playerLayer.frame =  self.view.bounds
    
    
    view.layer.addSublayer(playerLayer)
    
    player.play()
    
    
    let subtitle = CATextLayer()
    subtitle.string = "Subtitle Video"
    subtitle.frame = view.bounds
    subtitle.foregroundColor = UIColor.red.cgColor
    subtitle.backgroundColor = UIColor.clear.cgColor
    subtitle.alignmentMode = kCAAlignmentCenter
    
    playerLayer.addSublayer(subtitle)
    
    
  }
  
  
}



