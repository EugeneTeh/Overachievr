//
//  MainCenterVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/21/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit


class MainCenterVC: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.clearColor()
        
        let blurEffect = UIBlurEffect(style: .Light)
        let blurPanelView: UIVisualEffectView = UIVisualEffectView(effect: blurEffect)
        blurPanelView.frame = self.view.bounds
        self.view.addSubview(blurPanelView)
        
        let vibrancyEffect = UIVibrancyEffect(forBlurEffect: blurEffect)
        let vibrancyView = UIVisualEffectView(effect: vibrancyEffect)
        vibrancyView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        //vibrancyView.contentView.addSubview(<#view: UIView#>)
        blurPanelView.contentView.addSubview(vibrancyView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sidePanelDidSelectButtonAtIndex(index: Int) {
        
    }
    

    // MARK: - Navigation

    

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}
