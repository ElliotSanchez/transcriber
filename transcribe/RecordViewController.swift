//
//  RecordViewController.swift
//  transcribe
//
//  Created by hostname on 11/21/16.
//  Copyright © 2016 notungood. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class RecordViewController: UIViewController, AVAudioRecorderDelegate {

    var audioRec: AVAudioRecorder?
    var recFileURL: URL!
    var textFileURL: URL!
    
    var audioPlayer: AVAudioPlayer?
    var utilitiesObject = Utilities()
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var textView: UITextView!
    
    // On initial load of view, function gets unique URLs derived from current time and starts recoring
    override func viewDidLoad() {
        super.viewDidLoad()

        recFileURL = utilitiesObject.getAudioFileURL()
        textFileURL = utilitiesObject.getTextFileURL()
        // print(Utilities.getDocsDirectory().absoluteString)
        print("File URL is" + recFileURL.absoluteString)
        
        // Starts recording immediate upon load of view
        recordAudio()
    }
    
    // Button that stops recording is disabled after tapped
    @IBAction func stopRecordingTapped(_ sender: Any) {
        // Stop recording
        audioRec?.stop()
        
        // Disable button. Specifies "as UIButton" here because it was created with sender as "Any", which can't be passeed to .isEnabled or .setTitle
        if sender is UIButton {
            (sender as! UIButton).isEnabled = false
            (sender as! UIButton).setTitle("Finished", for: .disabled)
        }
        
    }
    
    // Called form viewDidLoad, creates audio session and records
    func recordAudio() {
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        self.textView.text = "Recording..."
        
        let session = AVAudioSession.sharedInstance()
        
        do {
            try session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: .defaultToSpeaker)
            try session.setActive(true)
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 44100,
                AVNumberOfChannelsKey: 2,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            audioRec = try AVAudioRecorder(url: recFileURL, settings: settings)
            audioRec?.delegate = self
            audioRec?.record()
            print("Started recording...")
        } catch let error {
            print("Failed recording - \(error)")
            recordingEnded(success: false)
        }
    }
    
    // Called by system on completion of recording,
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            recordingEnded(success: true)
        } else {
            recordingEnded(success: false)
        }
    }
    
    // Calls the player and transcription when recording ends, as triggered by audioRecorderDidFinishRecording above
    func recordingEnded(success: Bool) {
        // Redundant call to stop recording out of extra precaution(?)
        audioRec?.stop()
        activityIndicator.stopAnimating()
        
        if success {
            do {
                // play and transcribe audio
                audioPlayer?.stop()
                audioPlayer = try AVAudioPlayer(contentsOf: recFileURL)
                audioPlayer?.play()
                print("Successfully ended recording and playing...")
                
                // calls transcription without arguments because all files are based on timestamped URLs generated as class level variables each time the view is loaded. This approach won't allow for the recording screen to begin a second recording unless rebuilt in future versions.
                transcribeAudio()
            } catch let error {
                print(error)
            }
        } else {
            
        }
    }

    // MARK: - Transcription
    func transcribeAudio() {
        // Update text where transcription will go to indicate transcription has begun to user
        self.textView.text = "Playing and transcribing audio..."
        
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: recFileURL)
        
        recognizer?.recognitionTask(with: request, resultHandler: {
            [weak self] (result, error) in
            
            guard let result = result
            else {
                print("Error transcribing - \(error)")
                self?.textView.text = "Error: \(error?.localizedDescription)"
                return
            }
            
            if result.isFinal {
                // All work to update UI upon completed transcription contained in this async block
                DispatchQueue.main.async {
                    let text = result.bestTranscription.formattedString
                    
                    // Rewritten from "self!" in original code because user may have already tapped to back out of the screen by the time transcription job is done (making it nil), so the self referred to here is an optional
                    self?.textView.text = text
                    print("Transcription succesful: \(text)")
                    do {
                        try text.write(to: (self?.textFileURL)!, atomically: true, encoding: String.Encoding.utf8)
                    } catch {
                        print("Error: \(error)")
                    }
                    
                }
                
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
