//
//  VideoManager.swift
//  VideoEditor
//
//  Created by seyha on 20/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import AVKit


protocol VideoManagable {
    
}

class VideoManager {
    
    let defaultSize = CGSize(width: 1920, height: 1080)
    
    typealias Completion = (URL?, Error?) -> Void
    
    
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
        let silenceUrl = Bundle.main.url(forResource: "silence", withExtension: "mp3")
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
        
        // Main video composition instruction
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, insertTime)
        mainInstruction.layerInstructions = arrayLayerInstruction
        
        // Main video composition
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = outSize
        
        // Export to file
        let path = NSTemporaryDirectory().appending("mergedVideo.mp4")
        let exportURL = URL.init(fileURLWithPath: path)
        
        
        // Remove file if existed
        FileManager.default.removeItemIfExisted(exportURL)
        
        
        // Save file to temp
        exportMergeVideo(mixComposition: mixComposition, exportURL: exportURL, mainComposition: mainComposition, completion: completion)
        
    }
    
    
    fileprivate func exportMergeVideo(mixComposition: AVMutableComposition, exportURL: URL, mainComposition: AVMutableVideoComposition, completion: @escaping Completion) {
        
        // Init exporter
        let exporter = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
        exporter?.outputURL = exportURL
        exporter?.outputFileType = AVFileType.mp4
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.videoComposition = mainComposition
        
        // Do export
        exporter?.exportAsynchronously(completionHandler: {
            DispatchQueue.main.async {
                self.exportDidFinish(exporter: exporter, videoURL: exportURL, completion: completion)
            }
        })
    }
    
    fileprivate func exportDidFinish(exporter:AVAssetExportSession?, videoURL:URL, completion:@escaping Completion) -> Void {
        if exporter?.status == AVAssetExportSessionStatus.completed {
            print("Exported file: \(videoURL.absoluteString)")
            completion(videoURL,nil)
        }
        else if exporter?.status == AVAssetExportSessionStatus.failed {
            completion(videoURL,exporter?.error)
        }
    }
}



extension VideoManager {
    
    fileprivate func videoCompositionInstructionForTrack(track: AVCompositionTrack, asset: AVAsset, standardSize:CGSize, atTime: CMTime) -> AVMutableVideoCompositionLayerInstruction {
        
        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: track)
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform: transform)
        
        var aspectFillRatio:CGFloat = 1
        if assetTrack.naturalSize.height < assetTrack.naturalSize.width {
            aspectFillRatio = standardSize.height / assetTrack.naturalSize.height
        }
        else {
            aspectFillRatio = standardSize.width / assetTrack.naturalSize.width
        }
        
        if assetInfo.isPortrait {
            let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)
            
            let posX = standardSize.width/2 - (assetTrack.naturalSize.height * aspectFillRatio)/2
            let posY = standardSize.height/2 - (assetTrack.naturalSize.width * aspectFillRatio)/2
            let moveFactor = CGAffineTransform(translationX: posX, y: posY)
            
            instruction.setTransform(assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(moveFactor), at: atTime)
            
        } else {
            let scaleFactor = CGAffineTransform(scaleX: aspectFillRatio, y: aspectFillRatio)
            
            let posX = standardSize.width/2 - (assetTrack.naturalSize.width * aspectFillRatio)/2
            let posY = standardSize.height/2 - (assetTrack.naturalSize.height * aspectFillRatio)/2
            let moveFactor = CGAffineTransform(translationX: posX, y: posY)
            
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(moveFactor)
            
            if assetInfo.orientation == .down {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                concat = fixUpsideDown.concatenating(scaleFactor).concatenating(moveFactor)
            }
            
            instruction.setTransform(concat, at: atTime)
        }
        return instruction
    }
    
    fileprivate func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImageOrientation, isPortrait: Bool) {
        
        var assetOrientation = UIImageOrientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
}





extension FileManager {
    func removeItemIfExisted(_ url:URL) -> Void {
        if FileManager.default.fileExists(atPath: url.path) {
            do {
                try FileManager.default.removeItem(atPath: url.path)
            }
            catch {
                print("Failed to delete file")
            }
        }
    }
}







