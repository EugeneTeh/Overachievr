//
//  UIColorHelper.swift
//  Overachievr
//
//  Created by Eugene Teh on 9/13/15.
//  Copyright (c) 2015 Overachievr. All rights reserved.
//

import UIKit

extension UIColor
{
    convenience init(red: Int, green: Int, blue: Int)
    {
        let newRed = CGFloat(red)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: 1.0)
    }
}