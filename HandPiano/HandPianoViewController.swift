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

class HandPianoViewController: UIViewController {
    
    private let manager = CMMotionManager()
    
    @IBOutlet var currentKeyIndex: UILabel!

    @IBOutlet var currentKeyName: UILabel!
    
    var audioPlayer = AVAudioPlayer()
    
    let keyNumber = 50, startingKeyIndex = 37
    
    var primitiveKeyIndexToName = [Int: String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if manager.accelerometerAvailable {
            let queue: NSOperationQueue = NSOperationQueue.mainQueue()
        
            manager.deviceMotionUpdateInterval = 0.01
            manager.startDeviceMotionUpdatesToQueue(queue, withHandler: { [weak self ] (data: CMDeviceMotion?, error: NSError?) -> Void in
                if let motionData = data {
                    let rotation = atan2(motionData.gravity.x, motionData.gravity.y)
                    let transformedRotation = rotation < 0 ? -rotation : M_PI * 2 - rotation
                    let keyIndex = self?.rotationToKey(transformedRotation)
                    self?.currentKeyIndex.text = keyIndex?.description
                    self?.currentKeyName.text = self!.keyIndexToName(keyIndex!)
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
        
        return Int(Double(startingKeyIndex) + floor(rotation / averageWidth))
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
