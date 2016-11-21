//
//  Utilities.swift
//  transcribe
//
//  Created by hostname on 11/21/16.
//  Copyright © 2016 notungood. All rights reserved.
//

import Foundation

class Utilities {
    
    static func getDocsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirectory = paths[0]
        return docsDirectory
    }
    
    static func getAudioFileURL() -> URL? {
        do {
            let audioURL = try getDocsDirectory().appendingPathComponent(getDateAndTime() + ".m4a")
            return audioURL
        } catch _ {
            return nil
        }
    }
    
    static func getDateAndTime() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd-HH-mm-ss"
        
        let timeString = formatter.string(from: date)
        return timeString
    }
    
}
