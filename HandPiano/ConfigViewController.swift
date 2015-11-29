//
//  ConfigViewController.swift
//  HandPiano
//
//  Created by Ziliang Zhu on 11/28/15.
//  Copyright © 2015 Austurela. All rights reserved.
//

import UIKit

class ConfigViewController: UIViewController {

    @IBOutlet var keyNumberLabel: UILabel!
    
    @IBOutlet var startingKeyIndexLabel: UILabel!
    
    private struct Const {
        static let PropertyListKeyNumberKey = "Configuration.KeyNumber"
        static let PropertyListStartingKeyIndexKey = "Configuration.StartingKeyIndex"
    }
    
    private let defaults = NSUserDefaults.standardUserDefaults()
    
    private var keyNumber: Int {
        get {
            return defaults.objectForKey(Const.PropertyListKeyNumberKey) as? Int ?? 88
        }
        set {
            defaults.setObject(newValue, forKey: Const.PropertyListKeyNumberKey)
        }
    }
    
    private var startingKeyIndex: Int {
        get {
            return defaults.objectForKey(Const.PropertyListStartingKeyIndexKey) as? Int ?? 1
        }
        set {
            defaults.setObject(newValue, forKey: Const.PropertyListStartingKeyIndexKey)
        }
    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func keyNumberChanged(sender: UISlider) {
        let currentValue = Int(sender.value)
        
        keyNumberLabel.text = "\(currentValue)"
        keyNumber = currentValue
    }

    @IBAction func startingKeyIndexChanged(sender: UISlider) {
        let currentValue = Int(sender.value)
        
        startingKeyIndexLabel.text = "\(currentValue)"
        startingKeyIndex = currentValue
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
