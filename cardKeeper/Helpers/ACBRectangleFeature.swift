//
//  ACBRectangleFeature.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 10/03/2023.
//

import Foundation
import UIKit

class ACBRectangleFeature
{
    let isCorrect: Bool
    let topLeft: CGPoint
    let topRight: CGPoint
    let bottomLeft: CGPoint
    let bottomRight: CGPoint
    private let size: CGSize
    
    deinit
    {
        debugPrint("Deinit rectFeature")
    }
    
    init(image: UIImage, expanded: Bool)
    {
        var options = [CIDetectorAccuracy : CIDetectorAccuracyHigh,
                       CIDetectorMinFeatureSize : NSNumber(value: 0.2)] as [String : Any]
        options[CIDetectorMaxFeatureCount] = NSNumber(value: 10)
        if expanded == false, let cgImage = image.cgImage, let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: options)
        {
            let capturedImage = CIImage(cgImage: cgImage)
            let features = detector.features(in: capturedImage) as! [CIRectangleFeature]
            if let bigRect = ACBRectangleFeature.biggestRectangle(from: features)
            {
                var points = [bigRect.topLeft, bigRect.bottomLeft, bigRect.topRight, bigRect.bottomRight]
                var min = points[0]
                var max = min
                for eachPoint in points
                {
                    min.x = fmin(eachPoint.x, min.x)
                    min.y = fmin(eachPoint.y, min.y)
                    max.x = fmax(eachPoint.x, max.x)
                    max.y = fmax(eachPoint.y, max.y)
                }
                let center = CGPoint(x: 0.5 * (min.x + max.x), y: 0.5 * (min.y + max.y))
                points.sort(by: {ACBRectangleFeature.angleFromPoint($0, center: center) > ACBRectangleFeature.angleFromPoint($1, center: center)})
                self.topLeft = points[3]
                self.topRight = points[2]
                self.bottomRight = points[1]
                self.bottomLeft = points[0]
                self.size = image.size
                self.isCorrect = true
            }
            else
            {
                self.topLeft = CGPoint(x: 1, y: 1)
                self.topRight = CGPoint(x: image.size.width - 1, y: 1)
                self.bottomLeft = CGPoint(x: 1, y: image.size.height - 1)
                self.bottomRight = CGPoint(x: image.size.width - 1, y: image.size.height - 1)
                self.size = image.size
                self.isCorrect = false
            }
        }
        else
        {
            self.topLeft = CGPoint(x: 1, y: 1)
            self.topRight = CGPoint(x: image.size.width - 1, y: 1)
            self.bottomLeft = CGPoint(x: 1, y: image.size.height - 1)
            self.bottomRight = CGPoint(x: image.size.width - 1, y: image.size.height - 1)
            self.size = image.size
            self.isCorrect = false
        }
    }
        
    init(tLeft: CGPoint, tRight: CGPoint, bLeft: CGPoint, bRight: CGPoint, tSize: CGSize, tCorrect: Bool = false)
    {
        self.topLeft = tLeft
        self.topRight = tRight
        self.bottomLeft = bLeft
        self.bottomRight = bRight
        self.size = tSize
        self.isCorrect = tCorrect
    }
    
    func convertTo(_ newSize: CGSize, orientation: UIImage.Orientation) -> ACBRectangleFeature
    {
        let width = Int(self.size.width)
        if width == 0
        {
            return self
        }
        
        let scale = newSize.width / self.size.width
        
        var newTopLeft = CGPoint(x: self.bottomLeft.x * scale, y: (self.size.height - self.bottomLeft.y) * scale)
        var newTopRight = CGPoint(x: self.bottomRight.x * scale, y: (self.size.height - self.bottomRight.y) * scale)
        var newBottomRight = CGPoint(x: self.topRight.x * scale, y: (self.size.height - self.topRight.y) * scale)
        var newBottomLeft = CGPoint(x: self.topLeft.x * scale, y: (self.size.height - self.topLeft.y) * scale)
        
        if orientation == .right && self.isCorrect
        {
            newTopLeft = CGPoint(x: self.topLeft.y * scale, y: self.topLeft.x * scale)
            newTopRight = CGPoint(x: self.bottomLeft.y * scale, y: self.bottomLeft.x * scale)
            newBottomRight = CGPoint(x: self.bottomRight.y * scale, y: self.bottomRight.x * scale)
            newBottomLeft = CGPoint(x: self.topRight.y * scale, y: self.topRight.x * scale)
        }
        
        return ACBRectangleFeature(tLeft: newTopLeft, tRight: newTopRight, bLeft: newBottomLeft, bRight: newBottomRight, tSize: newSize)
    }
    
    class func angleFromPoint(_ point: CGPoint, center: CGPoint) -> CGFloat
    {
        let theta = Double(atan2(point.y - center.y, point.x - center.x))
        let angle = fmod(Double.pi - Double.pi * 0.25 + Double(theta), 2 * Double.pi)
        
        return CGFloat(angle)
    }
    
    fileprivate class func biggestRectangle(from rectangles: [CIRectangleFeature]) -> CIRectangleFeature?
    {
        if rectangles.count == 1
        {
            return rectangles.first
        }
        else if rectangles.count > 0
        {
            let halfPerimiterValue: Float = 0
            var biggestRectangle = rectangles.first
            for eachRectangle in rectangles
            {
                let p1 = eachRectangle.topLeft
                let p2 = eachRectangle.topRight
                let width = hypotf(Float(p1.x - p2.x), Float(p1.y - p2.y))
                let p3 = eachRectangle.bottomLeft
                let height = hypotf(Float(p1.x - p3.x), Float(p1.y - p3.y))
                let currentHalfPerimeter = height + width
                if halfPerimiterValue < currentHalfPerimeter
                {
                    biggestRectangle = eachRectangle
                }
            }
            return biggestRectangle
        }
        return nil
    }
}
