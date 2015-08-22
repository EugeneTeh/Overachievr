//
//  CreateTaskPanelDelegate.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/23/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit

extension MainContainerVC: UITextFieldDelegate {

    func setupCreateTaskPanelContainer(sourceView: UIView){
        let panelHeight = CGRectGetHeight(self.view.frame) * 0.25
        let panelY = panelHeight + CGRectGetHeight(self.view.frame)
        
        createTaskPanelCV.frame = CGRectMake(-sourceView.frame.origin.x, panelY, sourceView.frame.size.width, panelHeight)
        createTaskPanelCV.backgroundColor = UIColor.clearColor()
        //panelContainerView.clipsToBounds = false
        
        createTaskTextField = UITextField(frame: CGRect(
            x: CGRectGetWidth(createTaskPanelCV.frame) * 0.05,
            y: 5,
            width: CGRectGetWidth(createTaskPanelCV.frame) * 0.9,
            height: CGRectGetHeight(createTaskPanelCV.frame) * 0.8))
        
        createTaskTextField!.placeholder = "What would you like done?"
        createTaskTextField!.becomeFirstResponder()
        createTaskTextField!.contentVerticalAlignment = UIControlContentVerticalAlignment.Top
        createTaskTextField!.backgroundColor = UIColor.clearColor()
        
        createTaskPanelCV.addSubview(createTaskTextField!)
        
        createTaskPanelCV.layer.shadowOpacity = 0.5
        createTaskPanelCV.layer.shadowOffset = CGSize(width: 0.8, height: 0.8)
        
        //createTaskPanelCV.addSubview()
        sourceView.addSubview(createTaskPanelCV)
    }
    
    
    func toggleCreateTaskPanel(shouldExpand: Bool){
        if shouldExpand {
            setupCreateTaskPanelContainer(self.view)

            let position = (CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.view.frame) * 0.25) - keyboardFrame.height
            shiftCreateTaskPanel(targetPosition: position )
            createTaskPanelExpanded = true
        } else {
            shiftMainView(targetPosition: 0) { finished in
                self.createTaskPanelCV.removeFromSuperview()
                self.createTaskTextField?.removeFromSuperview()
            }
            
            createTaskPanelExpanded = false
        }
    }
    
    func shiftCreateTaskPanel(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.createTaskPanelCV.frame.origin.y = targetPosition
        }, completion: completion)
    }
    
    func registerForKeyboardNotifications() {
        let notificationCenter = NSNotificationCenter.defaultCenter()
        notificationCenter.addObserver(self,
            selector: "keyboardWillShow:",
            name: UIKeyboardWillShowNotification,
            object: nil)
        
        /*
        notificationCenter.addObserver(self,
            selector: "keyboardWillBeHidden:",
            name: UIKeyboardWillHideNotification,
            object: nil)
        */
    }
    
    func keyboardWillShow(notification: NSNotification) {
        let keyboard = KeyboardNotification(notification)
        keyboardFrame = keyboard.frameEndForView(self.view)
    }
    
    
    func addCreateTaskPanelGestureRecognizers() {
        let hideCreateTaskPanelGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleCreateTaskPanelSwipeDown:")
        hideCreateTaskPanelGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(hideCreateTaskPanelGestureRecognizer)
    }
    
    func handleCreateTaskPanelSwipeDown(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == UISwipeGestureRecognizerDirection.Down {
            if createTaskPanelExpanded {
                toggleCreateTaskPanel(!createTaskPanelExpanded)
            }
        }
    }

}
