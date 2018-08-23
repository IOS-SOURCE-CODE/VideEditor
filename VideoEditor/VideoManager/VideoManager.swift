//
//  VideoManager.swift
//  VideoEditor
//
//  Created by seyha on 20/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import AVKit

typealias Completion = (URL?, Error?) -> Void

protocol VideoManagable {
    func doMerge(arrayVideos:[AVAsset], animation: Bool, completion: @escaping Completion)
}

class VideoManager  {
    
    let defaultSize = CGSize(width: 1920, height: 1080)
    var imageDuration = 5.0 
   
     func doMerge(arrayVideos:[AVAsset], animation: Bool = false, completion: @escaping Completion) {
        
        var insertTime = kCMTimeZero
        var arrayLayerInstruction: [AVMutableVideoCompositionLayerInstruction] = []
        var outSize = CGSize.init(width: 0, height: 0)
        
        // Step 1 : Calculate output size of video
        _ = arrayVideos.map { videoAsset in
            
            let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]
            
            let assetInfo = orientationFromTransform(transform: videoTrack.preferredTransform)
            
            var videoSize = videoTrack.naturalSize
            
            if assetInfo.isPortrait == true {
                videoSize.width = videoTrack.naturalSize.height
                videoSize.height = videoTrack.naturalSize.width
            }
            
            if videoSize.height > outSize.height {
                outSize = videoSize
            }
        }
        
        if outSize.width == 0 || outSize.height == 0 {
            outSize = defaultSize
            
        }
        
        
        // Step2 - Get Audio track
        let silenceUrl = Bundle.main.url(forResource: "creativeminds", withExtension: "mp3")
        let silenceAVAsset = AVAsset(url: silenceUrl!)
        let silenceSoundTrack = silenceAVAsset.tracks(withMediaType: AVMediaType.audio).first
        
        
        let mixComposition = AVMutableComposition()
        
        for videoAsset in arrayVideos {
            
            guard let videoTrack = videoAsset.tracks(withMediaType: AVMediaType.video).first else { continue }
            
            var audioTrack: AVAssetTrack?
            if videoAsset.tracks(withMediaType: AVMediaType.audio).count > 0 {
                audioTrack = videoAsset.tracks(withMediaType: AVMediaType.audio).first
                
                
            } else {
                audioTrack = silenceSoundTrack
            }
            
            let videoCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            
            let audioCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
            
            do {
                
                let startTime = kCMTimeZero
                let duration = videoAsset.duration
                
                try videoCompositionTrack?.insertTimeRange(CMTimeRange(start: startTime, duration: duration), of: videoTrack, at: insertTime)
                
                try audioCompositionTrack?.insertTimeRange(CMTimeRange(start: startTime, duration: duration), of: audioTrack!, at: insertTime)
                
                let layerInstruction = videoCompositionInstructionForTrack(track: videoCompositionTrack!, asset: videoAsset, standardSize: outSize, atTime: insertTime)
                
                // Hide video track before changing to new track
                let endTime = CMTimeAdd(insertTime, duration)
                let timeScale = videoAsset.duration.timescale
                let durationAnimation = CMTime.init(seconds: 1, preferredTimescale: timeScale)
                
                layerInstruction.setOpacityRamp(fromStartOpacity: 1.0, toEndOpacity: 0.0, timeRange: CMTimeRange.init(start: endTime, duration: durationAnimation))
                
                arrayLayerInstruction.append(layerInstruction)
                
                // Increase the insert time
                insertTime = CMTimeAdd(insertTime, duration)
                
            } catch {
                print("Cannot load track from avvsset")
            }
            
        }
        
        
        // Export to file
        let path = NSTemporaryDirectory().appending("mergedVideo.mp4")
        let exportURL = URL.init(fileURLWithPath: path)
        
        exportMergeVideo(insertTime:insertTime, mixComposition: mixComposition, exportURL: exportURL, outSize: outSize, arrayLayerInstruction: arrayLayerInstruction, completion: completion)
    }
    
}



extension VideoManager: VideoCompositionInstruction, VideoManagerOutputable {
    
}












