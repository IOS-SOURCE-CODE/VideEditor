//
//  AudioKitViewController.swift
//  VideoEditor
//
//  Created by seyha on 21/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import SoundWave
import AVKit

class AudioKitViewController: UIViewController {

    fileprivate func audioVisualizationViewSetup() {
        let audioVisualizationView = AudioVisualizationView()
        view.addSubview(audioVisualizationView)
        audioVisualizationView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 100)
        
        
        audioVisualizationView.meteringLevelBarWidth = 5.0
        audioVisualizationView.meteringLevelBarInterItem = 1.0
        audioVisualizationView.meteringLevelBarCornerRadius = 0.0
        
        
        audioVisualizationView.gradientStartColor = UIColor.white
        audioVisualizationView.gradientEndColor = UIColor.blue
        
        audioVisualizationView.audioVisualizationMode = .read
        audioVisualizationView.meteringLevels = [0.1, 0.67, 0.13, 0.78, 0.31]
        audioVisualizationView.play(for: 50.0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
//        let composition = AVMutableComposition()
//        let audioCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
        

        let audioUrl = Bundle.main.url(forResource: "creativeminds", withExtension: "mp3")!
        
        let avAsset = AVAsset(url: audioUrl)
        let avPlayerItem = AVPlayerItem(asset: avAsset)
        

        let fadeTime = CMTime(value: 15, timescale: 1)
        let fadeInStartTime = kCMTimeZero
        let duration = avAsset.duration
        let fadeOutStartTime = CMTimeSubtract(duration, fadeTime)


        let fadeInRange = CMTimeRangeMake(fadeInStartTime, fadeTime)
        let fadeOutRange = CMTimeRangeMake(fadeOutStartTime, fadeTime)
        

        let parameter = AVMutableAudioMixInputParameters()
        parameter.trackID = avAsset.unusedTrackID()

        parameter.setVolumeRamp(fromStartVolume: 0.0, toEndVolume: 1.0, timeRange: fadeInRange)
        parameter.setVolumeRamp(fromStartVolume: 0.1, toEndVolume: 0.0, timeRange: fadeOutRange)
        
      

        let audioMix = AVMutableAudioMix()
        audioMix.inputParameters = [parameter]
        
        

       avPlayerItem.audioMix = audioMix
        
       
        
        let path = NSTemporaryDirectory().appending("audioEditing.mov")
        let exportURL = URL.init(fileURLWithPath: path)

        FileManager.default.removeItemIfExisted(exportURL)

        let exporter = AVAssetExportSession(asset: avPlayerItem.asset, presetName: AVAssetExportPresetHighestQuality)

        exporter?.outputURL = exportURL
        exporter?.audioMix = audioMix
        exporter?.outputFileType = AVFileType.mp4
        exporter?.shouldOptimizeForNetworkUse = true


        if exporter?.status == AVAssetExportSessionStatus.completed {
            print("Exported file: \(exportURL)")

        }
        else if exporter?.status == AVAssetExportSessionStatus.failed {
            print("Error Exported file: \(exportURL)")
        }

        exporter?.exportAsynchronously(completionHandler: {
            debugPrint("after export audio ", exportURL)
        })

        
        
        let player = AVPlayer(playerItem: avPlayerItem)
        let playerLayer =  AVPlayerLayer(player: player)
        view.layer.addSublayer(playerLayer)
        
//        player.play()
        

        
        
    }

    

}








