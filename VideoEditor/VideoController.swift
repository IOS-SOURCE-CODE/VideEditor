//
//  VideoController.swift
//  VideoEditor
//
//  Created by seyha on 20/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import AVKit

class VideoController: UIViewController {
    
    
    var videoManager: VideoManager!
    
    @IBAction func exportMergedVideo(_ sender: Any) {
        
        
        
    }
    
    
    @IBAction func doMergeVideo(_ sender: Any) {
        
        
        let urlVideo1 = Bundle.main.url(forResource: "movie1", withExtension: "mov")
        let urlVideo2 = Bundle.main.url(forResource: "movie2", withExtension: "mov")
        
        let avVideo1 = AVAsset(url: urlVideo1!)
        let avVideo2 = AVAsset(url: urlVideo2!)
        
        videoManager.doMerge(arrayVideos: [avVideo1, avVideo2]) { (url, error) in
            
            debugPrint("after merge ===> \n ", url)
            
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoManager = VideoManager()
        
       
        
        
    }
    

}
