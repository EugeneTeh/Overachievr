//
//  LeftMenuPanelDelegate.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/23/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit

extension MainContainerVC: LeftMenuPanelDelegate {

    func setupLeftMenuPanelContainer(sourceView: UIView){
        let panelWidth = CGRectGetWidth(self.view.frame) - self.mainContainerLeftPanelOffset
        leftMenuPanelCV.frame = CGRectMake(-panelWidth, sourceView.frame.origin.y, panelWidth, sourceView.frame.size.height)
        //panelContainerView.clipsToBounds = false
        
        leftMenuPanelCV.layer.shadowOpacity = 0.5
        leftMenuPanelCV.layer.shadowOffset = CGSize(width: 0.8, height: 0.8)
        
        setupSidePanel()
        
        leftMenuPanelCV.addSubview(leftMenuPanelTVC!.tableView)
        sourceView.addSubview(leftMenuPanelCV)
    }
    
    func setupSidePanel() {
        if leftMenuPanelTVC == nil {
            leftMenuPanelTVC = LeftMenuPanelTVC()
            
            leftMenuPanelTVC!.delegate = self
            leftMenuPanelTVC!.tableView.frame = leftMenuPanelCV.bounds
            //leftMenuPanelTVC.tableView.clipsToBounds = false
            leftMenuPanelTVC!.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            //leftMenuPanelTVC!.tableView.backgroundColor = UIColor.clearColor()
            leftMenuPanelTVC!.tableView.scrollsToTop = false
            leftMenuPanelTVC!.tableView.contentInset = UIEdgeInsetsMake(panelTableViewTopInset, 0, 0, 0)
            
            leftMenuPanelTVC!.tableView.reloadData()
        }
        
    }
    
    func addLeftMenuPanelGestureRecognizers() {
        let hideLeftMenuPanelGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleLeftMenuPanelSwipeLeft:")
        hideLeftMenuPanelGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideLeftMenuPanelGestureRecognizer)
    }
    
    func handleLeftMenuPanelSwipeLeft(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == UISwipeGestureRecognizerDirection.Left {
            if leftMenuPanelExpanded {
                toggleLeftMenuPanel(!leftMenuPanelExpanded)
            }
        }
    }
    
    // Not working yet
    @IBAction func handleLeftEdgePan(gesture: UIScreenEdgePanGestureRecognizer) {
        println("Left edge touched")
        let translation: CGPoint = gesture.translationInView(self.view)
        let width: CGFloat = CGRectGetWidth(self.view.frame) - self.mainContainerLeftPanelOffset
        let percentage = max(gesture.translationInView(self.view).x, 0) / width
        
        if leftMenuPanelExpanded == false {
            switch gesture.state {
            case UIGestureRecognizerState.Began:
                println("Begin pan")
                
                setupLeftMenuPanelContainer(self.view)
            case UIGestureRecognizerState.Changed:
                println("Update frame")
                
                leftMenuPanelCV.frame = CGRectMake(translation.x/3, 0, width, self.view.frame.height)
            default:
                println("Pan end")
                
            }
        }
    }
    
    func toggleLeftMenuPanel(shouldExpand: Bool){
        if shouldExpand {
            setupLeftMenuPanelContainer(self.view)
            shiftMainView(targetPosition: CGRectGetWidth(self.view.frame) - mainContainerLeftPanelOffset )
            leftMenuPanelExpanded = true
        } else {
            shiftMainView(targetPosition: 0) { finished in
                self.leftMenuPanelCV.removeFromSuperview()
                self.leftMenuPanelTVC!.view.removeFromSuperview()
                self.leftMenuPanelTVC = nil
            }
            leftMenuPanelExpanded = false
        }
    }
    
    
    func shiftMainView(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.frame.origin.x = targetPosition
            }, completion: completion)
    }
    
    func leftMenuPanelDidSelectRow(indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            
            Authentication().resetLogin()
        }
    }


}
