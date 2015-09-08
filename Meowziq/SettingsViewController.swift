//
//  SettingsViewController.swift
//  Meowziq
//
//  Created by Seiji Kohyama on 2015/04/07.
//  Copyright (c) 2015年 FaithCreates Inc. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var apiServerURLLabel: UILabel!
    @IBOutlet weak var apiServerURLTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        apiServerURLTextField.text = APIClient.apiServerURL
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func saveAPIServerURL(sender: AnyObject) {
        APIClient.apiServerURL = apiServerURLTextField.text!
    }
}