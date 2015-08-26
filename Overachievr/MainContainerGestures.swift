//
//  MainContainerGestures.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/24/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit

extension MainContainerVC {
    
    func addCreateTaskPanelGestureRecognizers() {
        let hideCreateTaskPanelGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleCreateTaskPanelSwipeDown:")
        hideCreateTaskPanelGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        self.view.addGestureRecognizer(hideCreateTaskPanelGestureRecognizer)
    }

    func handleCreateTaskPanelSwipeDown(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == UISwipeGestureRecognizerDirection.Down {
            if createTaskPanelExpanded {
                createTaskPanelDelegate?.createTaskButtonTapped(self.view, createTaskPanelExpanded: createTaskPanelExpanded)
                createTaskPanelExpanded = false
            }
        }
    }
    
    func addLeftMenuPanelGestureRecognizers() {
        let hideLeftMenuPanelGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleLeftMenuPanelSwipeLeft:")
        hideLeftMenuPanelGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hideLeftMenuPanelGestureRecognizer)
    }
    
    func handleLeftMenuPanelSwipeLeft(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == UISwipeGestureRecognizerDirection.Left {
            
        }
    }
    
}