//
//  UIImage+Extension.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 10/03/2023.
//

import UIKit

extension UIImage
{
    func fixedOrientation() -> UIImage?
    {
        guard imageOrientation != UIImage.Orientation.up else
        {
            return self.copy() as? UIImage
        }
        
        guard let cgImage = self.cgImage else
        {
            return nil
        }
        
        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else
        {
            return nil
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
            break
        case .up, .upMirrored:
            break
        @unknown default:
            break
        }
        
        //Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            break
        }
        
        ctx.concatenate(transform)
        
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }
        
        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
    
    private func cartesianForPoint(point:CGPoint, extent: CGRect) -> CGPoint
    {
        return CGPoint(x: point.x,y: extent.height - point.y)
    }
    
    func crop(_ tLeft: CGPoint,_ tRight: CGPoint,_ bRight: CGPoint,_ bLeft: CGPoint) -> UIImage?
    {
        if let coreGraphicsImage = self.cgImage
        {
            var ciImage = CIImage(cgImage: coreGraphicsImage)
            let topLeftInput = CIVector(cgPoint: self.imageOrientation == .up ? self.cartesianForPoint(point: tLeft, extent: ciImage.extent) : CGPoint(x: tRight.y, y: tRight.x))
            let topRighttInput = CIVector(cgPoint: self.imageOrientation == .up ? self.cartesianForPoint(point: tRight, extent: ciImage.extent) : CGPoint(x: bRight.y, y: bRight.x))
            let bottomRightInput = CIVector(cgPoint: self.imageOrientation == .up ? self.cartesianForPoint(point: bRight, extent: ciImage.extent) : CGPoint(x: bLeft.y, y: bLeft.x))
            let bottomLeftInput = CIVector(cgPoint: self.imageOrientation == .up ? self.cartesianForPoint(point: bLeft, extent: ciImage.extent) : CGPoint(x: tLeft.y, y: tLeft.x))
            let parameters: [String : Any] = ["inputTopLeft" : topLeftInput,
                                              "inputTopRight" : topRighttInput,
                                              "inputBottomRight" : bottomRightInput,
                                              "inputBottomLeft" : bottomLeftInput]
            ciImage = ciImage.applyingFilter("CIPerspectiveCorrection", parameters: parameters)
            let context = CIContext(options: [CIContextOption.workingColorSpace : NSNull()])
            if let output = context.createCGImage(ciImage, from: ciImage.extent)
            {
                return UIImage(cgImage: output, scale: self.scale, orientation: self.imageOrientation)
            }
        }
        return nil
    }
    
    func scaledImage(atPoint point: CGPoint, scaleFactor: CGFloat, targetSize size: CGSize) -> UIImage?
    {
        guard let cgImage = self.cgImage else {
            return nil
        }
        
        let scaledPoint = CGPoint(x: point.x * (self.size.width / size.width), y: point.y * (self.size.height / size.height))
        let scaledSize = CGSize(width: size.width / scaleFactor, height: size.height / scaleFactor)
        let midX = scaledPoint.x - scaledSize.width / 2.0
        let midY = scaledPoint.y - scaledSize.height / 2.0
        let newRect = CGRect(x: midX, y: midY, width: scaledSize.width, height: scaledSize.height)
        guard let croppedImage = cgImage.cropping(to: newRect) else {
            return nil
        }
        return UIImage(cgImage: croppedImage)
    }
}
