//
//  ViewController.swift
//  transcribe
//
//  Created by hostname on 11/19/16.
//  Copyright © 2016 notungood. All rights reserved.
//

import UIKit
import AVFoundation
import Speech

class ViewController: UIViewController {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var grantAccessButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func grantAccessClicked(_ sender: Any) {
        requestRecordPermissions()
    }
    
    // Calls requestTranscribePermissions once microhpone access is granted
    func requestRecordPermissions() {
        AVAudioSession.sharedInstance().requestRecordPermission() {
            [unowned self] allowed in
            DispatchQueue.main.async {
                if allowed {
                    self.requestTranscribePermissions() // on success gets next permission 
                } else {
                    self.showError()
                }
            }
        }
    }
    
    func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization() {
            [unowned self] authStatus in
            DispatchQueue.main.async {
                if authStatus == .authorized {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.showError()
                }
            }
        }
    }
    
    func showError() {
        self.label.text = "You have previously denied permissions. Please update the permissions in settings and restart the app."
        self.disableButton()
    }
    
    func disableButton() {
        self.grantAccessButton.isEnabled = false
        UIView.animate(withDuration: 1.0) {
            self.grantAccessButton.alpha = 0.3
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

