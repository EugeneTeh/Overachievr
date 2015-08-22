//
//  MainContainerVC.swift
//  Overachievr
//
//  Created by Eugene Teh on 8/21/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit

class MainContainerVC: UIViewController {
    
    let mainContainerExpandOffset: CGFloat = 120
    let panelTableViewTopInset: CGFloat = 68.0
    let panelContainerView: UIView = UIView()
    var panelTableViewController: LeftMenuPanelTVC?
    var panelExpanded: Bool = false


    override func viewDidLoad() {
        super.viewDidLoad()
        
        addPanelGestureRecognizers()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sidePanelDidSelectButtonAtIndex(index: Int) {
        
    }
    
    @IBAction func leftMenuPanelTapped(sender: AnyObject) {
        togglePanel(!panelExpanded)

    }
    
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }


}

extension MainContainerVC: LeftMenuPanelDelegate {
    // MARK: - Side Panel
    func setupSidePanelContainer(originView: UIView){
        let panelWidth = CGRectGetWidth(self.view.frame) - self.mainContainerExpandOffset
        panelContainerView.frame = CGRectMake(-panelWidth, originView.frame.origin.y, panelWidth, originView.frame.size.height)
        //panelContainerView.clipsToBounds = false

        panelContainerView.layer.shadowOpacity = 0.5
        panelContainerView.layer.shadowOffset = CGSize(width: 0.8, height: 0.8)
        
        setupSidePanel()
        
        panelContainerView.addSubview(panelTableViewController!.tableView)
        originView.addSubview(panelContainerView)
    }
    
    func setupSidePanel() {
        if panelTableViewController == nil {
            panelTableViewController = LeftMenuPanelTVC()
            
            panelTableViewController!.delegate = self
            panelTableViewController!.tableView.frame = panelContainerView.bounds
            //panelTableViewController.tableView.clipsToBounds = false
            panelTableViewController!.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
            //panelTableViewController!.tableView.backgroundColor = UIColor.clearColor()
            panelTableViewController!.tableView.scrollsToTop = false
            panelTableViewController!.tableView.contentInset = UIEdgeInsetsMake(panelTableViewTopInset, 0, 0, 0)
        
            panelTableViewController!.tableView.reloadData()
        }
        
    }
    
    func addPanelGestureRecognizers() {
        let hidePanelGestureRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleSwipeToLeft:")
        hidePanelGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Left
        self.view.addGestureRecognizer(hidePanelGestureRecognizer)
    }
    
    func handleSwipeToLeft(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == UISwipeGestureRecognizerDirection.Left {
            if panelExpanded {
                togglePanel(!panelExpanded)
            }
        }
    }
    
    @IBAction func handleLeftEdgePan(gesture: UIScreenEdgePanGestureRecognizer) {
        println("Left edge touched")
        let translation: CGPoint = gesture.translationInView(self.view)
        let width: CGFloat = CGRectGetWidth(self.view.frame) - self.mainContainerExpandOffset
        let percentage = max(gesture.translationInView(self.view).x, 0) / width
        
        if panelExpanded == false {
            switch gesture.state {
            case UIGestureRecognizerState.Began:
                println("Begin pan")
                
                setupSidePanelContainer(self.view)
            case UIGestureRecognizerState.Changed:
                println("Update frame")
                
                panelContainerView.frame = CGRectMake(translation.x/3, 0, width, self.view.frame.height)
            default:
                println("Pan end")
                
            }
        }
    }

    
    
    func togglePanel(shouldExpand: Bool){
        if shouldExpand {
            setupSidePanelContainer(self.view)
            shiftMainView(targetPosition: 0 )
            panelExpanded = true
        } else {
            shiftMainView(targetPosition: 0) { finished in
                self.panelContainerView.removeFromSuperview()
                self.panelTableViewController!.view.removeFromSuperview()
                self.panelTableViewController = nil
            }
            panelExpanded = false
        }
    }
    
    func shiftMainView(#targetPosition: CGFloat, completion: ((Bool) -> Void)! = nil) {
        UIView.animateWithDuration(0.2, animations: {
            self.panelContainerView.frame.origin.x = targetPosition
        }, completion: completion)
    }
    
    
    func leftMenuPanelDidSelectRow(indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            
            Authentication().resetLogin()
        }
    }

}


