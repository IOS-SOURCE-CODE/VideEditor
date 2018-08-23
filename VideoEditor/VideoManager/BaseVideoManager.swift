//
//  BaseVideoManager.swift
//  VideoEditor
//
//  Created by seyha on 22/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import AVKit


protocol VideoManagerOutputable {
    func exportDidFinish(exporter:AVAssetExportSession?, videoURL:URL, completion:@escaping Completion)
    func exportMergeVideo(insertTime:CMTime, mixComposition: AVMutableComposition, exportURL: URL, outSize: CGSize,arrayLayerInstruction: [AVMutableVideoCompositionLayerInstruction], completion: @escaping Completion)
}



extension VideoManagerOutputable {
    
    func exportDidFinish(exporter:AVAssetExportSession?, videoURL:URL, completion:@escaping Completion) {
        
        if exporter?.status == AVAssetExportSessionStatus.completed {
            print("Exported file: \(videoURL.absoluteString)")
            completion(videoURL,nil)
        }
        else if exporter?.status == AVAssetExportSessionStatus.failed {
            completion(videoURL,exporter?.error)
        }
    }
    
    func exportMergeVideo(insertTime:CMTime, mixComposition: AVMutableComposition, exportURL: URL, outSize: CGSize,arrayLayerInstruction: [AVMutableVideoCompositionLayerInstruction], completion: @escaping Completion) {
        
        // Main video composition instruction
        let mainInstruction = AVMutableVideoCompositionInstruction()
        mainInstruction.timeRange = CMTimeRangeMake(kCMTimeZero, insertTime)
        mainInstruction.layerInstructions = arrayLayerInstruction
        
        // Main video composition
        let mainComposition = AVMutableVideoComposition()
        mainComposition.instructions = [mainInstruction]
        mainComposition.frameDuration = CMTimeMake(1, 30)
        mainComposition.renderSize = outSize
        
        
        // Remove file if existed
        FileManager.default.removeItemIfExisted(exportURL)
        
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
}

