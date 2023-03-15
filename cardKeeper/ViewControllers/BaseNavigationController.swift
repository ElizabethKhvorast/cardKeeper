//
//  BaseNavigationController.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 15/03/2023.
//

import UIKit

class BaseNavigationController: UINavigationController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let titleFontAttrs = [ NSAttributedString.Key.font: UIFont(name: "Ubuntu-Bold", size: 20)!, NSAttributedString.Key.foregroundColor: UIColor(named: "mainTextColor")!]
        let barButtonFontAttrs = [ NSAttributedString.Key.font: UIFont(name: "Ubuntu-Bold", size: 14)! ]

        UINavigationBar.appearance().tintColor = UIColor(named: "secondaryTextColor")
        
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(named: "mainBackground")
        appearance.titleTextAttributes = titleFontAttrs
        appearance.largeTitleTextAttributes = titleFontAttrs // If your app supports largeNavBarTitle
        appearance.shadowImage = UIImage()
        appearance.shadowColor = .clear

        UINavigationBar.appearance().isTranslucent = true

        appearance.buttonAppearance.normal.titleTextAttributes = barButtonFontAttrs
        appearance.buttonAppearance.highlighted.titleTextAttributes = barButtonFontAttrs

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
