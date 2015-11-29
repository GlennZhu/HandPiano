//
//  HandPianoViewController.swift
//  HandPiano
//
//  Created by Ziliang Zhu on 11/28/15.
//  Copyright © 2015 Austurela. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class HandPianoViewController: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate {
    
    private let manager = CMMotionManager()
    
    @IBOutlet var currentKeyIndex: UILabel!

    @IBOutlet var currentKeyName: UILabel!
    
    private var audioPlayer = AVAudioPlayer()
    
    private struct Const {
        static let PropertyListKeyNumberKey = "Configuration.KeyNumber"
        static let PropertyListStartingKeyIndexKey = "Configuration.StartingKeyIndex"
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private var keyNumber: Int {
        get {
            return defaults.objectForKey(Const.PropertyListKeyNumberKey) as? Int ?? 88
        }
    }
    
    private var startingKeyIndex: Int {
        get {
            return defaults.objectForKey(Const.PropertyListStartingKeyIndexKey) as? Int ?? 1
        }
    }
    
    var primitiveKeyIndexToName = [Int: String]()
    
    var soundRecorder: AVAudioRecorder!
    var soundPlayer:AVAudioPlayer!
    
    let fileName = "demo.caf"
    let audioSession = AVAudioSession.sharedInstance()
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var playButton: UIButton!
    
    @IBAction func recordSound(sender: UIButton) {
        if (sender.titleLabel?.text == "Record"){
            
            soundRecorder.record()
            
            sender.setTitle("Stop", forState: .Normal)
            playButton.enabled = false
        } else {
            soundRecorder.stop()
            sender.setTitle("Record", forState: .Normal)
        }
    }
    
    @IBAction func playSound(sender: UIButton) {
        if (sender.titleLabel?.text == "Play"){
            recordButton.enabled = false
            sender.setTitle("Stop", forState: .Normal)
            preparePlayer()
            
            soundPlayer.play()
        } else {
            soundPlayer.stop()
            recordButton.enabled = true
            sender.setTitle("Play", forState: .Normal)
        }
    }
    
    func getCacheDirectory() -> NSURL {
        let cacheURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0]
        return cacheURL
    }
    
    func getFileURL() -> NSURL {
        let filePath = getCacheDirectory().URLByAppendingPathComponent(fileName)
        return filePath
    }
    
    func setupRecorder() {
        let recordSettings = [
            AVSampleRateKey : NSNumber(float: Float(44100.0)),
            AVFormatIDKey : NSNumber(int: Int32(kAudioFormatMPEG4AAC)),
            AVNumberOfChannelsKey : NSNumber(int: 1),
            AVEncoderAudioQualityKey : NSNumber(int: Int32(AVAudioQuality.Medium.rawValue))
        ]
        
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try soundRecorder = AVAudioRecorder(URL: getFileURL(), settings: recordSettings)
            soundRecorder.delegate = self
            soundRecorder.prepareToRecord()
            try audioSession.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker)
        } catch {
            print(error)
        }
    }
    
    func preparePlayer() {

        do {
            soundPlayer = try AVAudioPlayer(contentsOfURL: getFileURL())
            soundPlayer.delegate = self
            soundPlayer.prepareToPlay()
            soundPlayer.volume = 1.0
        } catch {
            print(error)
        }
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
        playButton.enabled = true
        recordButton.setTitle("Record", forState: .Normal)
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder, error: NSError?) {
        print("Error while recording audio \(error!.localizedDescription)")
    }
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.enabled = true
        playButton.setTitle("Play", forState: .Normal)
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer, error: NSError?) {
        print("Error while playing audio \(error!.localizedDescription)")
    }
    
    // get magnitude of vector via Pythagorean theorem
    func magnitudeFromAttitude(attitude: CMAttitude) -> Double {
        return sqrt(pow(attitude.roll, 2) + pow(attitude.yaw, 2) + pow(attitude.pitch, 2))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let queue: NSOperationQueue = NSOperationQueue.mainQueue()
        
        // initial configuration

        
        // trigger values - a gap so there isn't a flicker zone
        let showPromptTrigger = 1.0
        let showAnswerTrigger = 0.8
        var initialAttitude: CMAttitude?
        
        if manager.accelerometerAvailable {
            manager.deviceMotionUpdateInterval = 0.01
            manager.startDeviceMotionUpdatesToQueue(queue, withHandler: { [weak self ] (data: CMDeviceMotion?, error: NSError?) -> Void in
                if let motionData = data {
                    let rotation = atan2(motionData.gravity.x, motionData.gravity.y)
                    let transformedRotation = rotation < 0 ? -rotation : M_PI * 2 - rotation
                    let keyIndex = self?.rotationToKey(transformedRotation)
                    self?.currentKeyIndex.text = keyIndex?.description
                    self?.currentKeyName.text = self!.keyIndexToName(keyIndex!)
                    
                    if motionData.userAcceleration.x > 2.5 {
                        self!.tabBarController?.selectedIndex = 1
                    } else if motionData.userAcceleration.x < -2.5 {
                        self!.tabBarController?.selectedIndex = 0
                    }
                    
                    if let initAttitude = initialAttitude {
                        // translate the attitude
                        motionData.attitude.multiplyByInverseOfAttitude(initAttitude)
                        // calculate magnitude of the change from our initial attitude
                        let magnitude = self!.magnitudeFromAttitude(motionData.attitude) ?? 0
                        // show the prompt
                        if magnitude > showPromptTrigger {
                            self!.view.backgroundColor = UIColor.purpleColor()
                        }
                        // hide the prompt
                        if magnitude < showAnswerTrigger {
                            self!.view.backgroundColor = UIColor.orangeColor()
                        }
                    } else {
                        initialAttitude = self!.manager.deviceMotion?.attitude
                    }
                }
            })
        }
        
        primitiveKeyIndexToName[0] = "C"
        primitiveKeyIndexToName[1] = "C#"
        primitiveKeyIndexToName[2] = "D"
        primitiveKeyIndexToName[3] = "D#"
        primitiveKeyIndexToName[4] = "E"
        primitiveKeyIndexToName[5] = "F"
        primitiveKeyIndexToName[6] = "F#"
        primitiveKeyIndexToName[7] = "G"
        primitiveKeyIndexToName[8] = "G#"
        primitiveKeyIndexToName[9] = "A"
        primitiveKeyIndexToName[10] = "A#"
        primitiveKeyIndexToName[11] = "B"
        
        setupRecorder()
    }
    
    @IBAction func play(sender: UIButton) {
        let fileToPlay = currentKeyIndex.text
        let pianoSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fileToPlay, ofType: "mp3")!)
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOfURL: pianoSound, fileTypeHint: nil)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch {
            print(error)
        }
    }
    
    private func rotationToKey(rotation: Double) -> Int {
        let max = M_PI * 2
        let averageWidth = max / Double(keyNumber)
        
        let result = Int(Double(startingKeyIndex) + floor(rotation / averageWidth))
        if (result > 88) {
            return 88
        } else if (result < 1) {
            return 1
        } else {
            return result
        }
    }
    
    private func keyIndexToName(index: Int) -> String {
        if (index < 1) {
            return "A1"
        } else if (index > 88) {
            return "C5"
        } else {
            let scaleIndex = (index + 8) / 12
            if let keyName = primitiveKeyIndexToName[(index - 4) % 12] {
                return keyName + scaleIndex.description
            } else {
                return "Error"
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
