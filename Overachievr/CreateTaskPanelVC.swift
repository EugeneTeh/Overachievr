//
//  CreateTaskPanelDelegate.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/23/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit

protocol SelectContactsPanelDelegate {
    func setAssigneeButtonTapped(sourceView: UIView, selectContactsPanelExpanded: Bool)
}

class CreateTaskPanelVC: UIViewController {

    var selectContactsPanelDelegate: SelectContactsPanelDelegate?
    var selectContactsPanelExpanded: Bool = false

    var keyboardFrame: CGRect = CGRectZero
    
    let createTaskPanelCV: UIView = UIView()
    var createTaskTextField: CreateTaskTextField?
    var setAssigneeButton: UIButton = UIButton()
    var setDueDateButton: UIButton = UIButton()
    var sendTaskButton: UIButton = UIButton()
    
    func createTaskButtonTapped(sourceView: UIView, createTaskPanelExpanded: Bool) {
        toggleCreateTaskPanel(sourceView, shouldExpand: !createTaskPanelExpanded)
    }

    func setupCreateTaskPanelContainer(sourceView: UIView){
        let panelHeight = CGRectGetHeight(UIScreen.mainScreen().bounds) * 0.25
        let panelY = panelHeight + CGRectGetHeight(UIScreen.mainScreen().bounds)
        
        createTaskPanelCV.frame = CGRectMake(-sourceView.frame.origin.x, panelY, sourceView.frame.size.width, panelHeight)
        createTaskPanelCV.backgroundColor = UIColor.whiteColor()
        createTaskPanelCV.layer.shadowOpacity = 0.5
        createTaskPanelCV.layer.shadowOffset = CGSize(width: 0.8, height: 0.8)
        
        setupCreateTaskTextField()
        setupCreateTaskIcons()
        
        selectContactsPanelDelegate = MainContainerVC()
        
        createTaskPanelCV.addSubview(createTaskTextField!)
        createTaskPanelCV.addSubview(setAssigneeButton)
        createTaskPanelCV.addSubview(setDueDateButton)
        createTaskPanelCV.addSubview(sendTaskButton)
        sourceView.addSubview(createTaskPanelCV)
    }
    
    func setupCreateTaskTextField() {
        createTaskTextField = CreateTaskTextField(frame: createTaskPanelCV.bounds)

        createTaskTextField!.contentVerticalAlignment = UIControlContentVerticalAlignment.Top
        createTaskTextField!.becomeFirstResponder()
        createTaskTextField!.placeholder = "What would you like done?"
        
        createTaskTextField!.backgroundColor = UIColor.clearColor()
    }
    
    func setupCreateTaskIcons() {
        let setAssigneeImage = UIImage(named: "button_addAssignee.pdf")
        let setDueDateImage = UIImage(named: "button_setDueDate.pdf")
        let sendTaskImage = UIImage(named: "button_sendTask.pdf")
        
        setAssigneeButton.setImage(setAssigneeImage, forState: UIControlState.Normal)
        setDueDateButton.setImage(setDueDateImage, forState: UIControlState.Normal)
        sendTaskButton.setImage(sendTaskImage, forState: UIControlState.Normal)

        setAssigneeButton.frame = CGRect(x: CGRectGetWidth(createTaskPanelCV.frame) * 0.9, y: CGRectGetHeight(createTaskPanelCV.frame) * 0.05, width: 32, height: 32)
        setDueDateButton.frame = CGRect(x: CGRectGetWidth(createTaskPanelCV.frame) * 0.89, y: CGRectGetHeight(createTaskPanelCV.frame) * 0.43, width: 32, height: 32)
        sendTaskButton.frame = CGRect(x: CGRectGetWidth(createTaskPanelCV.frame) * 0.895, y: CGRectGetHeight(createTaskPanelCV.frame) * 0.8, width: 32, height: 32)
        
        setAssigneeButton.addTarget(self, action: "setAssigneeButtonTapped:", forControlEvents: .TouchUpInside)
    }
    
    
    func toggleCreateTaskPanel(sourceView: UIView, shouldExpand: Bool){
        if shouldExpand {
            setupCreateTaskPanelContainer(sourceView)
            let position = (CGRectGetHeight(sourceView.frame) - CGRectGetHeight(sourceView.frame) * 0.25) - keyboardFrame.height
            shiftCreateTaskPanel(targetPosition: position )
        } else {
            createTaskTextField!.resignFirstResponder()
            let position = (CGRectGetHeight(sourceView.frame) + CGRectGetHeight(sourceView.frame) * 0.25) + keyboardFrame.height
            shiftCreateTaskPanel(targetPosition: position) { finished in
                self.createTaskPanelCV.removeFromSuperview()
                self.createTaskTextField?.removeFromSuperview()
            }
        }
    }
    
    func shiftCreateTaskPanel(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.createTaskPanelCV.frame.origin.y = targetPosition
        }, completion: completion)
    }
    
    func keyboardShown(frame: CGRect) {
        keyboardFrame = frame
    }

}

@IBDesignable
class CreateTaskTextField: UITextField {
    @IBInspectable var insetX: CGFloat = 10
    @IBInspectable var insetY: CGFloat = 10

    
    // placeholder position
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , insetX , insetY)
    }
    
    // text position
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , insetX , insetY)
    }
}
