//
//  CreateTaskPanelVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/23/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit

protocol CreateTaskPanelDelegate {
    
}

class CreateTaskPanelVC: UIViewController {
    
    var delegate: CreateTaskPanelDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
