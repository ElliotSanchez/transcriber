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
    
    var audioPlayer: AVAudioPlayer?
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    @IBAction func stopRecordingTapped(_ sender: Any) {
        audioRec?.stop()
        if sender is UIButton {
            (sender as! UIButton).isEnabled = false
            (sender as! UIButton).setTitle("Finished", for: .disabled)
        }
        
    }
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        recFileURL = Utilities.getAudioFileURL()
        // print(Utilities.getDocsDirectory().absoluteString)
        print("File URL is" + recFileURL.absoluteString)
        recordAudio()
    }
    
    func recordAudio() {
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        
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
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            recordingEnded(success: true)
        } else {
            recordingEnded(success: false)
        }
    }
    
    func recordingEnded(success: Bool) {
        audioRec?.stop()
        activityIndicator.stopAnimating()
        if success {
            do {
                // play and transcribe audio
                audioPlayer?.stop()
                audioPlayer = try AVAudioPlayer(contentsOf: recFileURL)
                print("Successfully ended recording and playing...")
                transcribeAudio()
            } catch let error {
                print(error)
            }
        } else {
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Transcribe
    func transcribeAudio() {
        self.textView.text = "Transcribing..."
        
        let recognizer = SFSpeechRecognizer()
        let request = SFSpeechURLRecognitionRequest(url: recFileURL)
        
        recognizer?.recognitionTask(with: request, resultHandler: {
            [unowned self] (result, error) in
            
            guard let result = result
            else {
                print("Error transcribing - \(error)")
                self.textView.text = "Error: \(error?.localizedDescription)"
                return
            }
            
            if result.isFinal {
                DispatchQueue.main.async {
                    self.textView.text = result.bestTranscription.formattedString
                    print("Transcription succesful")
                }
                
            }
        })
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
