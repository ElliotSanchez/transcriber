//
//  Utilities.swift
//  transcribe
//
//  Created by hostname on 11/21/16.
//  Copyright © 2016 notungood. All rights reserved.
//

import Foundation

class Utilities {
    
    var dateTime = Date()
    let date = Date()
    let formatter = DateFormatter()
    var timeString: String!
    
    init() {
        formatter.dateFormat = "yyyy-mm-dd-HH-mm-ss"
        timeString = formatter.string(from: date)
    }
    
    func getDocsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docsDirectory = paths[0]
        return docsDirectory
    }
    
    func getAudioFileURL() -> URL? {
        let audioURL = getDocsDirectory().appendingPathComponent(getDateAndTime() + ".m4a")
        return audioURL
    }
    
    func getTextFileURL() -> URL? {
        let textURL = getDocsDirectory().appendingPathComponent(getDateAndTime() + ".txt")
        return textURL
    }
    
    func getDateAndTime() -> String {
        return timeString
    }
    
}
