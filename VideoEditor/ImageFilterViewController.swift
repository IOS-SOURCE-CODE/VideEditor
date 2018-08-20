//
//  ImageFilterViewController.swift
//  VideoEditor
//
//  Created by Hiem Seyha on 8/17/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import AssetsLibrary

class ImageFilterViewController: UIViewController {
  @IBOutlet weak var myImage: UIImageView!
  
  
  @IBOutlet weak var slider: UISlider!
  
  
  
  var context: CIContext!
  var filter: CIFilter!
  var beginImage: CIImage!
  var orientation: UIImageOrientation = .up
  
  
  
  @IBAction func sliderChange(_ sender: UISlider) {
    
    
    let sliderValue = sender.value

    let outputImage = self.oldPhoto(img: beginImage, withAmount: sliderValue)

    let cgimg = context.createCGImage(outputImage, from: outputImage.extent)

    let newImage = UIImage(cgImage: cgimg!, scale: 1, orientation: orientation)
//    self.myImage.image = newImage
    
    
    
  }
  
  
  
  
    override func viewDidLoad() {
        super.viewDidLoad()

      
      beginImage = CIImage(image: #imageLiteral(resourceName: "screen"))
      
      
      context = CIContext(options:nil)
     
      
    }

  func oldPhoto(img: CIImage, withAmount intensity: Float) -> CIImage {
    
    // 1
    let sepia = CIFilter(name:"CISepiaTone")
    sepia?.setValue(img, forKey:kCIInputImageKey)
    sepia?.setValue(intensity, forKey:"inputIntensity")
    
    // 2
    let random = CIFilter(name:"CIRandomGenerator")
    
    // 3
    let lighten = CIFilter(name:"CIColorControls")
    lighten?.setValue(random?.outputImage, forKey:kCIInputImageKey)
    lighten?.setValue(1 - intensity, forKey:"inputBrightness")
    lighten?.setValue(0, forKey:"inputSaturation")
    
    // 4
    let croppedImage = lighten?.outputImage?.cropped(to: beginImage.extent)
    
    // 5
    let composite = CIFilter(name:"CIHardLightBlendMode")
    composite?.setValue(sepia?.outputImage, forKey:kCIInputImageKey)
    composite?.setValue(croppedImage, forKey:kCIInputBackgroundImageKey)
    
    // 6
    let vignette = CIFilter(name:"CIVignette")
    vignette?.setValue(composite?.outputImage, forKey:kCIInputImageKey)
    vignette?.setValue(intensity * 2, forKey:"inputIntensity")
    vignette?.setValue(intensity * 30, forKey:"inputRadius")
    
    // 7
    return vignette!.outputImage!
  }

}
