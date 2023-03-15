//
//  CropViewController.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 12/03/2023.
//

import UIKit
import PhotosUI

class CropViewController: UIViewController
{
    @IBOutlet weak var imageView: UIImageView!
    
    var cropView: ACBCropView?
    
    var cardItem: CardItem?
    
    //MARK: - Life cycle

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.title = "Crop"
        self.imageView.image = self.cardItem?.image
        self.cropView = ACBCropView(self.imageView, expandedCrop: false)
    }
    
    //MARK: - Actions
    
    @IBAction func cropPressed(_ sender: Any)
    {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController
        {
            self.cardItem?.image = self.cropView?.croppedImage()
            vc.cardItem = self.cardItem
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
