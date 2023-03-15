//
//  ACBZoomView.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 12/03/2023.
//

import UIKit

class ACBZoomView: UIView
{
    var image: UIImage?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.clipsToBounds = true
        self.backgroundColor = UIColor.clear
        self.layer.cornerRadius = frame.height * 0.5
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.white.cgColor
        
        let plusLabel = UILabel(frame: CGRect.zero)
        plusLabel.textColor = UIColor.white
        plusLabel.font = UIFont(name: "Ubuntu-Light", size: 36)
        plusLabel.text = "+"
        plusLabel.sizeToFit()
        plusLabel.textAlignment = .center
        plusLabel.center = CGPoint(x: self.bounds.width * 0.5, y: self.bounds.height * 0.5)
        self.addSubview(plusLabel)
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect)
    {
        self.image?.draw(in: rect)
    }
}
