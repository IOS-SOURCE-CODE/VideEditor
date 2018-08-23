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
    
    var playerController: AVPlayerViewController!
    
    @IBAction func exportMergedVideo(_ sender: Any) {
        
        
        
    }
    
    
    fileprivate func mergeTwoVideosToOneVideo() {
        let urlVideo1 = Bundle.main.url(forResource: "movie1", withExtension: "mov")
        let urlVideo2 = Bundle.main.url(forResource: "movie2", withExtension: "mov")
        
        let avVideo1 = AVAsset(url: urlVideo1!)
        let avVideo2 = AVAsset(url: urlVideo2!)
        
        videoManager.doMerge(arrayVideos: [avVideo1, avVideo2]) { [weak self] (url, error) in
            
            guard let `self` = self else { return }
            
            self.openPreviewScreen(url!)
            
        }
    }
    
    @IBAction func doMergeVideo(_ sender: Any) {
        
        
//        mergeTwoVideosToOneVideo()
        
        
        let videoURL = Bundle.main.url(forResource: "movie1", withExtension: "mov")!
        let sourceAsset = AVURLAsset(url: videoURL, options: nil)
        let length =  CMTime(seconds: sourceAsset.duration.seconds, preferredTimescale: sourceAsset.duration.timescale)
        
        
      
        
        let path = NSTemporaryDirectory().appending("sliptVideo.mov")
        let outputURL = URL.init(fileURLWithPath: path)
        
        FileManager.default.removeItemIfExisted(videoURL)
        
        let start = 1.0
        
        let end = length.seconds / 2
        
        
        if let exportSession = AVAssetExportSession(asset: sourceAsset, presetName: AVAssetExportPresetHighestQuality) {
            
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileType.mp4
            exportSession.shouldOptimizeForNetworkUse = true
            
            let startTime = CMTime(seconds: Double(start), preferredTimescale: sourceAsset.duration.timescale)
            var endTime = CMTime(seconds: Double(end), preferredTimescale: sourceAsset.duration.timescale)
            
            if endTime > length {
                endTime = length
            }
            
            let timeRange = CMTimeRange(start: startTime, end: endTime)
            
            exportSession.timeRange = timeRange
            
            /// try to export the file and handle the status cases
            exportSession.exportAsynchronously(completionHandler: {
                switch exportSession.status {
                case .failed:
                    if let _error = exportSession.error {
                        debugPrint(_error)
                    }
                    
                case .cancelled:
                    if let _error = exportSession.error {
                        debugPrint(_error)
                    }
                    
                default:
                    print("finished")
            
                }
            })
        
        }
    }
    
    
    fileprivate func openPreviewScreen(_ videoURL:URL) -> Void {
        let player = AVPlayer(url: videoURL)
        
        playerController.player = player
        
        self.present(self.playerController, animated: true, completion: {
            player.play()
        })
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        videoManager = VideoManager()
        
        playerController = AVPlayerViewController()
        
        
    }
    

}
