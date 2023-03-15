//
//  UIView+Extensions.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 12/03/2023.
//

import UIKit

extension UIView
{
    private static let gestureDiameter: CGFloat = 100
    private static let visibleDiameter: CGFloat = 30
    
    class func cropGestureView() -> UIView
    {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.gestureDiameter, height: self.gestureDiameter))
        view.backgroundColor = UIColor.clear
        view.isUserInteractionEnabled = true
        let visibleView = UIView(frame: CGRect(x: 0, y: 0, width: self.visibleDiameter, height: self.visibleDiameter))
        visibleView.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
        visibleView.alpha = 1
        visibleView.layer.cornerRadius = 0.5 * self.visibleDiameter
        visibleView.isUserInteractionEnabled = true
        visibleView.layer.borderWidth = 0.5
        visibleView.layer.borderColor = UIColor(white: 1, alpha: 1).cgColor
        view.addSubview(visibleView)
        visibleView.center = view.center
        return view
    }
}
