//
//  ACBVisionRectangleDetector.swift
//  Acubiz
//  cardKeeper
//
//  Created by Елизавета Хворост on 10/03/2023.
//

import Vision
import Foundation
import CoreImage

struct ACBVisionRectangleDetector
{
    static func rectangle(forImage image: CIImage, orientation: CGImagePropertyOrientation, completion: @escaping ((ACBQuadrilateral?) -> Void))
    {
        let imageRequestHandler = VNImageRequestHandler(ciImage: image, orientation: orientation, options: [:])
        let rectangleDetectionRequest: VNDetectRectanglesRequest = {
            let rectDetectRequest = VNDetectRectanglesRequest(completionHandler: { (request, error) in
                guard error == nil, let results = request.results as? [VNRectangleObservation], !results.isEmpty else {
                    completion(nil)
                    return
                }
                let quads: [ACBQuadrilateral] = results.map({ observation in
                    return ACBQuadrilateral(topLeft: observation.topLeft,
                                            topRight: observation.topRight,
                                            bottomRight: observation.bottomRight,
                                            bottomLeft: observation.bottomLeft)
                })
                guard let biggest = results.count > 1 ? quads.biggest() : quads.first else
                {
                    return
                }
                let transform = CGAffineTransform.identity.scaledBy(x: image.extent.size.width,
                                                                    y: image.extent.size.height)
                let finalRectangle = biggest.applying(transform)
                
                var points = [finalRectangle.topLeft, finalRectangle.bottomLeft, finalRectangle.topRight, finalRectangle.bottomRight]
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
                let sortedRectangle = ACBQuadrilateral(topLeft: points[3], topRight: points[2], bottomRight: points[1], bottomLeft: points[0])
                completion(sortedRectangle)
            })
            rectDetectRequest.minimumAspectRatio = VNAspectRatio(0.2)
            rectDetectRequest.maximumAspectRatio = VNAspectRatio(1.0)
            rectDetectRequest.minimumSize = Float(0.2)
            rectDetectRequest.maximumObservations = 20
            return rectDetectRequest
        }()
        DispatchQueue.global(qos: .userInitiated).async {
            do
            {
                try imageRequestHandler.perform([rectangleDetectionRequest])
            }
            catch
            {
                completion(nil)
            }
        }
    }
}

