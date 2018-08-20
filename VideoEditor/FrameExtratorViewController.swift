//
//  FrameExtratorViewController.swift
//  VideoEditor
//
//  Created by seyha on 20/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import AVKit



class FrameExtratorViewController: UIViewController {

    @IBOutlet weak var frameImageView: UIImageView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let url = Bundle.main.url(forResource: "movie1", withExtension: "mov")!

        DispatchQueue.global(qos: .background).async {
            let image = self.imageFromVideo(url: url, at: 0)
            
            DispatchQueue.main.async {
                self.frameImageView.image = image
            }
        }
        
    }
}


extension FrameExtratorViewController {
    
    func imageFromVideo(url: URL, at time: TimeInterval) -> UIImage? {
        
        let asset = AVURLAsset(url: url)
        
        let assetIG = AVAssetImageGenerator(asset: asset)
        assetIG.appliesPreferredTrackTransform = true
        assetIG.apertureMode = AVAssetImageGeneratorApertureMode.encodedPixels
        
        let cmTime = CMTime(seconds: time, preferredTimescale: 60)
        let thumbnailImageRef: CGImage
        do {
            thumbnailImageRef = try assetIG.copyCGImage(at: cmTime, actualTime: nil)
        } catch let error {
            print("Error: \(error)")
            return nil
        }
        
        return UIImage(cgImage: thumbnailImageRef)
    }
}
