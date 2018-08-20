//
//  TrimeVideoPreviewViewController.swift
//  VideoEditor
//
//  Created by seyha on 20/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import PryntTrimmerView
import AVKit

class TrimeVideoPreviewViewController: UIViewController {
    
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

    
        let trimmerView = TrimmerView()
        let videoCropView = VideoCropView()
        
        
        trimmerView.frame = CGRect(x: 0, y: view.frame.height - 250 , width: view.bounds.width, height: 200)
        
        videoCropView.frame = CGRect(x: 0, y: 250 , width: view.bounds.width, height: 300)
        
        view.addSubview(trimmerView)
        view.addSubview(videoCropView)
        
        
        let url = Bundle.main.url(forResource: "movie1", withExtension: "mov")!
        
        let avAsset = AVAsset(url: url)
        
        trimmerView.asset = avAsset
        videoCropView.asset = avAsset
//        trimmerView.delegate = self
        
        trimmerView.handleColor = UIColor.white
        trimmerView.mainColor = UIColor.orange
        trimmerView.positionBarColor = UIColor.white
        
    }
}
