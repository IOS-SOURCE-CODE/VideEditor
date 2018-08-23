//
//  FDWaveformViewController.swift
//  VideoEditor
//
//  Created by seyha on 21/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import UIKit
import FDWaveformView

class FDWaveformViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let waveForm = FDWaveformView()
        
        
        let thisBundle = Bundle(for: type(of: self))
        let url = thisBundle.url(forResource: "creativeminds", withExtension: "mp3")
        waveForm.audioURL = url
        
        
        
    }

}
