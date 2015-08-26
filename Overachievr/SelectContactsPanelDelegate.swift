//
//  SelectContactsPanelDelegate.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/23/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit

extension MainContainerVC: SelectContactsPanelDelegate  {

    func setAssigneeButtonTapped(sourceView: UIView, selectContactsPanelExpanded: Bool) {
        //toggleSelectContactsPanel(!selectContactsPanelExpanded)
        
    }
    
    func setupSelectContactsPanelContainer(){
        let panelWidth: CGFloat = CGRectGetWidth(self.view.frame) - selectContactsPanelOffset
        selectContactsPanelCV.frame = CGRectMake(0, self.view.frame.origin.y, panelWidth, self.view.frame.size.height)
        selectContactsPanelCV.backgroundColor = UIColor.redColor()
        //selectContactsPanelCV.addSubview(self.tableView)
        
        self.view.addSubview(selectContactsPanelCV)
    }
    
    func toggleSelectContactsPanel(shouldExpand: Bool){
        if shouldExpand {
            setupSelectContactsPanelContainer()
            shiftMainContainer(targetPosition: selectContactsPanelOffset)
            println("set Assignee Button tapped")
        } else {
            let position = CGRectGetWidth(self.view.frame)
            shiftMainContainer(targetPosition: position) { finished in
                self.selectContactsPanelCV.subviews.map({ $0.removeFromSuperview() })
                self.selectContactsPanelCV.removeFromSuperview()
            }
        }
    }
    
    func shiftMainContainer(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: UIViewAnimationOptions.CurveEaseInOut, animations: {
            self.view.frame.origin.x = targetPosition
            }, completion: completion)
    }

}
