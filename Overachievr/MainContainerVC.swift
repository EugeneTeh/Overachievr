//
//  MainContainerVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/21/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit

protocol CreateTaskPanelDelegate {
    func createTaskButtonTapped(sourceView: UIView, createTaskPanelExpanded: Bool)
    func keyboardShown(frame: CGRect)
}

protocol LeftMenuPanelDelegate {
    func leftMenuPanelButtonTapped(sourceView:UIView, leftMenuPanelExpanded: Bool)
}

@IBDesignable
class MainContainerVC: UIViewController {
    
    var createTaskPanelDelegate: CreateTaskPanelDelegate?
    var createTaskPanelExpanded: Bool = false
    
    var leftMenuPanelDelegate: LeftMenuPanelDelegate?
    var leftMenuPanelExpanded: Bool = false
    
    let selectContactsPanelOffset: CGFloat = 120
    let selectContactsPanelTopInset: CGFloat = 68.0
    let selectContactsPanelCV: UIView = UIView()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //createTaskPanelDelegate = CreateTaskPanelVC()
        //leftMenuPanelDelegate = LeftMenuPanelTVC()
        
        
        addLeftMenuPanelGestureRecognizers()
        addCreateTaskPanelGestureRecognizers()
        
        let keyboardHelper = KeyboardHelper()
        keyboardHelper.registerForKeyboardNotifications(self)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func leftMenuPanelTapped(sender: AnyObject) {
        leftMenuPanelDelegate?.leftMenuPanelButtonTapped(self.view, leftMenuPanelExpanded: leftMenuPanelExpanded)
        leftMenuPanelExpanded = !leftMenuPanelExpanded
    }
    
    @IBAction func createTaskButtonTapped(sender: AnyObject) {
        createTaskPanelDelegate?.createTaskButtonTapped(self.view, createTaskPanelExpanded: createTaskPanelExpanded)
        createTaskPanelExpanded = !createTaskPanelExpanded
        
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboard = KeyboardNotification(notification)
        let keyboardFrame = keyboard.frameEndForView(self.view)
        createTaskPanelDelegate?.keyboardShown(keyboardFrame)
    }
    


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}

