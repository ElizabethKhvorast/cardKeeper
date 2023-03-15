//
//  ACBLineEquations.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 10/03/2023.
//

import Foundation
import UIKit

class ACBLineEquations
{
    class func intersect(point: CGPoint, lines: [ACBLine]) -> Bool
    {
        for eachLine in lines
        {
            if eachLine.intersect(point: point)
            {
                return true
            }
        }
        
        return false
    }
}

struct ACBLine
{
    let p1: CGPoint
    let p2: CGPoint
    
    func intersect(point: CGPoint) -> Bool
    {        
        let equation = Int((point.x - p1.x) * (p2.y - p1.y) - (point.y - p1.y) * (p2.x - p1.x))
        if equation >= 0
        {
            return false
        }
        
        return true
    }
}
