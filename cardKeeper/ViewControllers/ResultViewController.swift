//
//  ResultViewController.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 12/03/2023.
//

import UIKit

class ResultViewController: UIViewController
{
    @IBOutlet weak var imageView: UIImageView!
    
    var cardItem: CardItem?
    
    //MARK: - Life cycle

    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.imageView.image = self.cardItem?.image
    }
    
    //MARK: - Helpers
    
    private func saveItem()
    {
        self.cardItem?.save()
        self.navigationController?.dismiss(animated: true)
    }
    
    //MARK: - Actions
    
    @IBAction func savePressed(_ sender: Any)
    {
        let alertController = UIAlertController(title: "Save this card?", message: "Enter some card description", preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.placeholder = "Description"
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: {[weak self] _ in
            let text = alertController.textFields?.first?.text
            self?.cardItem?.title = text
            self?.cardItem?.createdAt = Date()
            self?.saveItem()
        }))
        self.present(alertController, animated: true)
    }
}
