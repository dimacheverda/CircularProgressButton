//
//  ViewController.swift
//  CircularProgressButton
//
//  Created by Dima Cheverda on 2/21/15.
//  Copyright (c) 2015 Dima Cheverda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

  let button: CircularProgressButton = {
    let buttonFrame = CGRect(x: 0, y: 0, width: 250, height: 100)
    let button = CircularProgressButton(frame: buttonFrame, cornerRadius: 20)
    button.setTitle("Upload", forState: .Normal)
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.yellowColor()
    
    button.center = view.center
    button.addTarget(self, action: "buttonClicked", forControlEvents: .TouchUpInside)
    view.addSubview(button)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func buttonClicked() {
    println()
  }
  
  @IBAction func plusPressed(sender: AnyObject) {
    button.progress += 0.1
  }
  
  @IBAction func minusPressed(sender: AnyObject) {
    button.progress -= 0.1
  }

}

