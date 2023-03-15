//
//  ACBCropView.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 12/03/2023.
//

import Foundation
import AVFoundation
import UIKit

class ACBCropView: UIView
{
    weak private var imageView: UIImageView?
    
    let topLeftView = UIView.cropGestureView()
    let topRightView = UIView.cropGestureView()
    let bottomLeftView = UIView.cropGestureView()
    let bottomRightView = UIView.cropGestureView()
    
    let topView = UIView.cropGestureView()
    let bottomView = UIView.cropGestureView()
    let rightView = UIView.cropGestureView()
    let leftView = UIView.cropGestureView()
    
    private var rectanleFeature: ACBRectangleFeature!
    private let zoomView = ACBZoomView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
    
    var imageRect: CGRect {
        get{
            if let capturedImageView = self.imageView, let image = capturedImageView.image
            {
                return AVMakeRect(aspectRatio: image.size, insideRect: capturedImageView.bounds)
            }
            return self.bounds
        }
    }
    
    //MARK: Life Cycle
    
    deinit
    {
        debugPrint("Deinit ACBCropView")
    }
    
    init(_ parentImageView: UIImageView, expandedCrop: Bool = false)
    {
        super.init(frame: parentImageView.bounds)
        self.backgroundColor = UIColor.clear
        self.imageView = parentImageView
        parentImageView.addSubview(self)
        self.isUserInteractionEnabled = true
        if let image = self.imageView?.image
        {
            self.addSubview(self.topView)
            self.addSubview(self.bottomView)
            self.addSubview(self.leftView)
            self.addSubview(self.rightView)
            self.addSubview(self.topLeftView)
            self.addSubview(self.topRightView)
            self.addSubview(self.bottomRightView)
            self.addSubview(self.bottomLeftView)
            self.setupGestures()
            self.zoomView.isHidden = true
            self.addSubview(self.zoomView)
            
            if expandedCrop
            {
                self.rectanleFeature = ACBRectangleFeature(image: image, expanded: true)
                self.updatePositions()
            }
            else if let finalImage = CIImage(image: image)
            {
                let imageSize = finalImage.extent.size
                ACBVisionRectangleDetector.rectangle(forImage: finalImage, orientation: .up) { [weak self] (rectangle) in
                    guard let wself = self else {
                        return
                    }
                    if let finalRectangle = rectangle
                    {
                        wself.rectanleFeature = ACBRectangleFeature(tLeft: finalRectangle.topLeft,
                                                          tRight: finalRectangle.topRight,
                                                          bLeft: finalRectangle.bottomLeft,
                                                          bRight: finalRectangle.bottomRight,
                                                          tSize: imageSize,
                                                          tCorrect: true)
                    }
                    else
                    {
                        wself.rectanleFeature = ACBRectangleFeature(image: image, expanded: true)
                    }
                    DispatchQueue.main.async {
                        wself.updatePositions()
                    }
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews()
    {
        super.layoutSubviews()
        self.updatePositions()
    }
    
    //MARK: Draw
    
    override func draw(_ rect: CGRect)
    {
        if let _ = self.rectanleFeature
        {
            UIColor(red: 1, green: 1, blue: 1, alpha: 0.2).setFill()
            UIRectFill(self.imageRect)
            UIColor(white: 1, alpha: 0.5).setStroke()
            //cut rectangular area
            if let context = UIGraphicsGetCurrentContext()
            {
                context.setBlendMode(.clear)
                let path = self.getCroppedPath()
                path.fill()
                context.setBlendMode(.normal)
                path.stroke()
            }
        }
    }
    
    //MARK: Helpers
    
    func hideCrop()
    {
        self.rectanleFeature = nil
        self.topView.isHidden = true
        self.bottomView.isHidden = true
        self.leftView.isHidden = true
        self.rightView.isHidden = true
        self.topLeftView.isHidden = true
        self.topRightView.isHidden = true
        self.bottomRightView.isHidden = true
        self.bottomLeftView.isHidden = true
        self.zoomView.isHidden = true
        self.setNeedsDisplay()
    }
    
    func expandCrop()
    {
        if let image = self.imageView?.image
        {
            self.rectanleFeature = ACBRectangleFeature(image: image, expanded: true)
            self.updatePositions()
            self.setNeedsDisplay()
        }
    }
    
    func rotateCrop(prevRect: CGRect, prevSize: CGSize)
    {
        var tLeft = CGPoint(x: self.topLeftView.center.x - prevRect.origin.x, y: self.topLeftView.center.y - prevRect.origin.y)
        var tRight = CGPoint(x: self.topRightView.center.x - prevRect.origin.x, y: self.topRightView.center.y - prevRect.origin.y)
        var bLeft = CGPoint(x: self.bottomLeftView.center.x - prevRect.origin.x, y: self.bottomLeftView.center.y - prevRect.origin.y)
        var bRight = CGPoint(x: self.bottomRightView.center.x - prevRect.origin.x, y: self.bottomRightView.center.y - prevRect.origin.y)
        var scale = prevSize.width / prevRect.size.width
        
        tLeft.x *= scale
        tLeft.y *= scale
        
        tRight.x *= scale
        tRight.y *= scale
        
        bLeft.x *= scale
        bLeft.y *= scale
        
        bRight.x *= scale
        bRight.y *= scale
        
        let topLeft = CGPoint(x: prevSize.height - bLeft.y, y: bLeft.x)
        let topRight = CGPoint(x: prevSize.height - tLeft.y, y: tLeft.x)
        let bottomRight = CGPoint(x: prevSize.height - tRight.y, y: tRight.x)
        let bottomLeft = CGPoint(x: prevSize.height - bRight.y, y: bRight.x)
        let offset = self.imageRect.origin
        
        if let newSize = self.imageView?.image?.size
        {
            scale = newSize.width / self.imageRect.width
        }
        
        tLeft.x = topLeft.x / scale + offset.x
        tLeft.y = topLeft.y / scale + offset.y
        
        tRight.x = topRight.x / scale + offset.x
        tRight.y = topRight.y / scale + offset.y
        
        bLeft.x = bottomLeft.x / scale + offset.x
        bLeft.y = bottomLeft.y / scale + offset.y
        
        bRight.x = bottomRight.x / scale + offset.x
        bRight.y = bottomRight.y / scale + offset.y
        
        self.topLeftView.center = tLeft
        self.topRightView.center = tRight
        self.bottomRightView.center = bRight
        self.bottomLeftView.center = bLeft
        self.updateEdgeViewsPositions()
        
        self.setNeedsDisplay()
    }
        
    func croppedImage() -> UIImage?
    {
        if let image = self.imageView?.image, let _ = self.rectanleFeature
        {
            let offset = self.imageRect.origin
            var tLeft = CGPoint(x: self.topLeftView.center.x - offset.x, y: self.topLeftView.center.y - offset.y)
            var tRight = CGPoint(x: self.topRightView.center.x - offset.x, y: self.topRightView.center.y - offset.y)
            var bLeft = CGPoint(x: self.bottomLeftView.center.x - offset.x, y: self.bottomLeftView.center.y - offset.y)
            var bRight = CGPoint(x: self.bottomRightView.center.x - offset.x, y: self.bottomRightView.center.y - offset.y)
            let scale = image.size.width / self.imageRect.size.width
            
            tLeft.x *= scale
            tLeft.y *= scale
            
            tRight.x *= scale
            tRight.y *= scale
            
            bLeft.x *= scale
            bLeft.y *= scale
            
            bRight.x *= scale
            bRight.y *= scale
            
            return image.crop(tLeft, tRight, bRight, bLeft)
        }
        
        return nil
    }
    
    fileprivate func getCroppedPath(_ converted: Bool = false) -> UIBezierPath
    {
        if converted
        {
            guard let image = self.imageView?.image else {
                return UIBezierPath()
            }
            
            let offset = self.imageRect.origin
            var tLeft = CGPoint(x: self.topLeftView.center.x - offset.x, y: self.topLeftView.center.y - offset.y)
            var tRight = CGPoint(x: self.topRightView.center.x - offset.x, y: self.topRightView.center.y - offset.y)
            var bLeft = CGPoint(x: self.bottomLeftView.center.x - offset.x, y: self.bottomLeftView.center.y - offset.y)
            var bRight = CGPoint(x: self.bottomRightView.center.x - offset.x, y: self.bottomRightView.center.y - offset.y)
            let scale = image.size.width / self.imageRect.size.width
            
            tLeft.x *= scale
            tLeft.y *= scale
            
            tRight.x *= scale
            tRight.y *= scale
            
            bLeft.x *= scale
            bLeft.y *= scale
            
            bRight.x *= scale
            bRight.y *= scale
            
            let path = UIBezierPath()
            path.move(to: tLeft)
            path.addLine(to: tRight)
            path.addLine(to: bRight)
            path.addLine(to: bLeft)
            path.close()
            
            return path
        }
        else
        {
            let path = UIBezierPath()
            path.move(to: self.topLeftView.center)
            path.addLine(to: self.topRightView.center)
            path.addLine(to: self.bottomRightView.center)
            path.addLine(to: self.bottomLeftView.center)
            path.close()
            
            return path
        }
    }
    
    func updatePositions()
    {
        guard let capturedImageView = self.imageView else {
            return
        }
        
        self.frame = capturedImageView.bounds
        if let image = self.imageView?.image, self.rectanleFeature != nil
        {
            let offset = self.imageRect.origin
            let resizedFeature = self.rectanleFeature.convertTo(imageRect.size, orientation: image.imageOrientation)
            self.topLeftView.center =  CGPoint(x: resizedFeature.topLeft.x + offset.x, y: resizedFeature.topLeft.y + offset.y)
            self.topRightView.center = CGPoint(x: resizedFeature.topRight.x + offset.x, y: resizedFeature.topRight.y + offset.y)
            self.bottomRightView.center = CGPoint(x: resizedFeature.bottomRight.x + offset.x, y: resizedFeature.bottomRight.y + offset.y)
            self.bottomLeftView.center = CGPoint(x: resizedFeature.bottomLeft.x + offset.x, y: resizedFeature.bottomLeft.y + offset.y)
            self.updateEdgeViewsPositions()
        }
    }
    
    private func updateEdgeViewsPositions()
    {
        self.topView.center = CGPoint(x: (self.topLeftView.center.x + self.topRightView.center.x) * 0.5, y: (self.topLeftView.center.y + self.topRightView.center.y) * 0.5)
        self.bottomView.center = CGPoint(x: (self.bottomLeftView.center.x + self.bottomRightView.center.x) * 0.5, y: (self.bottomLeftView.center.y + self.bottomRightView.center.y) * 0.5)
        self.rightView.center = CGPoint(x: (self.topRightView.center.x + self.bottomRightView.center.x) * 0.5, y: (self.topRightView.center.y + self.bottomRightView.center.y) * 0.5)
        self.leftView.center = CGPoint(x: (self.bottomLeftView.center.x + self.topLeftView.center.x) * 0.5, y: (self.bottomLeftView.center.y + self.topLeftView.center.y) * 0.5)
    }
    
    fileprivate func setupGestures()
    {
        let topLeftGesture = UIPanGestureRecognizer(target: self, action: #selector(ACBCropView.processGesture(gesture:)))
        topLeftGesture.maximumNumberOfTouches = 1
        self.topLeftView.addGestureRecognizer(topLeftGesture)
        
        let topRightGesture = UIPanGestureRecognizer(target: self, action: #selector(ACBCropView.processGesture(gesture:)))
        topRightGesture.maximumNumberOfTouches = 1
        self.topRightView.addGestureRecognizer(topRightGesture)
        
        let bottomLeftGesture = UIPanGestureRecognizer(target: self, action: #selector(ACBCropView.processGesture(gesture:)))
        bottomLeftGesture.maximumNumberOfTouches = 1
        self.bottomLeftView.addGestureRecognizer(bottomLeftGesture)
        
        let bottomRightGesture = UIPanGestureRecognizer(target: self, action: #selector(ACBCropView.processGesture(gesture:)))
        bottomRightGesture.maximumNumberOfTouches = 1
        self.bottomRightView.addGestureRecognizer(bottomRightGesture)
        
        //edge gestures
        let topGesture = UIPanGestureRecognizer(target: self, action: #selector(ACBCropView.processEdgeGesture(gesture:)))
        topGesture.maximumNumberOfTouches = 1
        self.topView.addGestureRecognizer(topGesture)
        
        let bottomGesture = UIPanGestureRecognizer(target: self, action: #selector(ACBCropView.processEdgeGesture(gesture:)))
        bottomGesture.maximumNumberOfTouches = 1
        self.bottomView.addGestureRecognizer(bottomGesture)
        
        let rightGesture = UIPanGestureRecognizer(target: self, action: #selector(ACBCropView.processEdgeGesture(gesture:)))
        rightGesture.maximumNumberOfTouches = 1
        self.rightView.addGestureRecognizer(rightGesture)
        
        let leftGesture = UIPanGestureRecognizer(target: self, action: #selector(ACBCropView.processEdgeGesture(gesture:)))
        leftGesture.maximumNumberOfTouches = 1
        self.leftView.addGestureRecognizer(leftGesture)
    }
    
    private func getLinesFor(_ view: UIView) -> [ACBLine]
    {
        var lines = [ACBLine]()
        if view == self.topLeftView
        {
            lines.append(ACBLine(p1: self.bottomLeftView.center, p2: self.topRightView.center))
            lines.append(ACBLine(p1: self.bottomRightView.center, p2: self.topRightView.center))
            lines.append(ACBLine(p1: self.bottomLeftView.center, p2: self.bottomRightView.center))
        }
        else if view == self.topRightView
        {
            lines.append(ACBLine(p1: self.topLeftView.center, p2: self.bottomLeftView.center))
            lines.append(ACBLine(p1: self.bottomLeftView.center, p2: self.bottomRightView.center))
            lines.append(ACBLine(p1: self.topLeftView.center, p2: self.bottomRightView.center))
        }
        else if view == self.bottomRightView
        {
            lines.append(ACBLine(p1: self.topRightView.center, p2: self.bottomLeftView.center))
            lines.append(ACBLine(p1: self.topRightView.center, p2: self.topLeftView.center))
            lines.append(ACBLine(p1: self.topLeftView.center, p2: self.bottomLeftView.center))
        }
        else if view == self.bottomLeftView
        {
            lines.append(ACBLine(p1: self.topRightView.center, p2: self.topLeftView.center))
            lines.append(ACBLine(p1: self.bottomRightView.center, p2: self.topRightView.center))
            lines.append(ACBLine(p1: self.bottomRightView.center, p2: self.topLeftView.center))
        }
        return lines
    }
    
    @objc private func processGesture(gesture: UIPanGestureRecognizer)
    {
        guard gesture.state != .ended else {
            self.zoomView.isHidden = true
            self.zoomView.image = nil
            self.zoomView.setNeedsDisplay()
            return
        }
        
        if let touchedView = gesture.view
        {
            let point = gesture.location(in: self)
            let rectForImage = self.imageRect
            if rectForImage.contains(point) && !ACBLineEquations.intersect(point: point, lines: self.getLinesFor(touchedView))
            {
                var scaleFactor: CGFloat = 2.5
                if let currentImageSize = self.imageView?.image?.size, currentImageSize.width / self.imageRect.width < 3
                {
                    scaleFactor = 6
                }
                let pointInImage = CGPoint(x: point.x - rectForImage.origin.x, y: point.y - rectForImage.origin.y)
                if let zoomImage = self.imageView?.image?.scaledImage(atPoint: pointInImage, scaleFactor: scaleFactor, targetSize: self.imageRect.size)
                {
                    self.zoomView.isHidden = false
                    self.zoomView.image = zoomImage
                    self.zoomView.center = CGPoint(x: point.x, y: point.y - 50)
                    self.zoomView.setNeedsDisplay()
                }
                else
                {
                    self.zoomView.isHidden = true
                    self.zoomView.image = nil
                    self.zoomView.setNeedsDisplay()
                }
                touchedView.center = point
                self.updateEdgeViewsPositions()
                self.setNeedsDisplay(rectForImage)
            }
            else
            {
                self.zoomView.isHidden = true
                self.zoomView.image = nil
                self.zoomView.setNeedsDisplay()
            }
        }
    }
    
    @objc private func processEdgeGesture(gesture: UIPanGestureRecognizer)
    {
        if let tochedView = gesture.view
        {
            let point = gesture.location(in: self)
            if self.imageRect.contains(point)
            {
                if self.topView == tochedView
                {
                    let deltaY = point.y - self.topView.center.y
                    let newTopLeftPoint = CGPoint(x: self.topLeftView.center.x, y: self.topLeftView.center.y + deltaY)
                    let newTopRightPoint = CGPoint(x: self.topRightView.center.x, y: self.topRightView.center.y + deltaY)
                    if self.imageRect.contains(newTopLeftPoint) && self.imageRect.contains(newTopRightPoint)
                    {
                        self.topView.center = CGPoint(x: self.topView.center.x, y: point.y)
                        self.topRightView.center = newTopRightPoint
                        self.topLeftView.center = newTopLeftPoint
                        self.updateEdgeViewsPositions()
                        self.setNeedsDisplay(self.imageRect)
                    }
                }
                else if self.bottomView == tochedView
                {
                    let deltaY = point.y - self.bottomView.center.y
                    let newBotLeftPoint = CGPoint(x: self.bottomLeftView.center.x, y: self.bottomLeftView.center.y + deltaY)
                    let newBotRightPoint = CGPoint(x: self.bottomRightView.center.x, y: self.bottomRightView.center.y + deltaY)
                    if self.imageRect.contains(newBotLeftPoint) && self.imageRect.contains(newBotRightPoint)
                    {
                        self.bottomView.center = CGPoint(x: self.bottomView.center.x, y: point.y)
                        self.bottomRightView.center = newBotRightPoint
                        self.bottomLeftView.center = newBotLeftPoint
                        self.updateEdgeViewsPositions()
                        self.setNeedsDisplay(self.imageRect)
                    }
                }
                else if self.rightView == tochedView
                {
                    let deltaX = point.x - self.rightView.center.x
                    let newTopPoint = CGPoint(x: self.topRightView.center.x + deltaX, y: self.topRightView.center.y)
                    let newBottomPoint = CGPoint(x: self.bottomRightView.center.x + deltaX, y: self.bottomRightView.center.y)
                    if self.imageRect.contains(newTopPoint) && self.imageRect.contains(newBottomPoint)
                    {
                        self.rightView.center = CGPoint(x: point.x, y: self.rightView.center.y)
                        self.topRightView.center = newTopPoint
                        self.bottomRightView.center = newBottomPoint
                        self.updateEdgeViewsPositions()
                        self.setNeedsDisplay(self.imageRect)
                    }
                }
                else if self.leftView == tochedView
                {
                    let deltaX = point.x - self.leftView.center.x
                    let newTopPoint = CGPoint(x: self.topLeftView.center.x + deltaX, y: self.topLeftView.center.y)
                    let newBottomPoint = CGPoint(x: self.bottomLeftView.center.x + deltaX, y: self.bottomLeftView.center.y)
                    if self.imageRect.contains(newTopPoint) && self.imageRect.contains(newBottomPoint)
                    {
                        self.leftView.center = CGPoint(x: point.x, y: self.leftView.center.y)
                        self.topLeftView.center = newTopPoint
                        self.bottomLeftView.center = newBottomPoint
                        self.updateEdgeViewsPositions()
                        self.setNeedsDisplay(self.imageRect)
                    }
                }
            }
        }
    }
}
