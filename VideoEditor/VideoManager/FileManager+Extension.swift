//
//  FileManager+Extension.swift
//  VideoEditor
//
//  Created by seyha on 22/08/18.
//  Copyright © 2018 seyha. All rights reserved.
//

import Foundation


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
