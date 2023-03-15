//
//  MainViewController.swift
//  cardKeeper
//
//  Created by Елизавета Хворост on 10/03/2023.
//

import UIKit

class MainViewController: UIViewController
{
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var emptyLabel: UILabel!
    
    private let refreshControl = UIRefreshControl()
    private let itemOffset: CGFloat = 16
    private var dataSource = CardDataSource()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.navigationItem.title = "Card Keeper"
        self.refreshControl.tintColor = UIColor(named: "mainTextColor")
        self.refreshControl.addTarget(self, action: #selector(updateView), for: .valueChanged)
        self.collectionView.addSubview(self.refreshControl)
        self.collectionView.register(UINib(nibName: "CardCollectionViewCell", bundle: nil),
                                     forCellWithReuseIdentifier: "CardCollectionViewCell")
        self.collectionView.register(UINib(nibName: "HeaderCollectionView", bundle: nil), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "HeaderCollectionView")
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        self.updateView()
    }
    
    @objc private func updateView()
    {
        self.dataSource.update { [weak self] in
            self?.collectionView.reloadData()
            self?.emptyLabel.isHidden = self?.dataSource.hasItems == true
            self?.refreshControl.endRefreshing()
        }
    }
}

extension MainViewController: UICollectionViewDataSource
{
    func numberOfSections(in collectionView: UICollectionView) -> Int
    {
        return self.dataSource.sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.dataSource.sections[section].items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CardCollectionViewCell", for: indexPath) as! CardCollectionViewCell
        let item = self.dataSource.sections[indexPath.section].items[indexPath.row]
        cell.imageView.image = item.image
        cell.descriptionLabel.text = item.title
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView
    {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HeaderCollectionView", for: indexPath) as! HeaderCollectionView
        header.titleLabel.text = self.dataSource.sections[indexPath.section].title
        return header
    }
}

extension MainViewController: UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize
    {
        return CGSize(width: collectionView.bounds.width, height: 64)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        let item = self.dataSource.sections[indexPath.section].items[indexPath.row]
        if let navVC = self.storyboard?.instantiateViewController(withIdentifier: "CardNavigationController") as? UINavigationController, let firstVC = navVC.viewControllers.first as? CardViewController
        {
            firstVC.cardItem = item
            firstVC.delegate = self
            self.present(navVC, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: collectionView.bounds.width - 2 * self.itemOffset, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets
    {
        return UIEdgeInsets(top: 0, left: self.itemOffset, bottom: 0, right: self.itemOffset)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat
    {
        return self.itemOffset
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat
    {
        return self.itemOffset
    }
}

extension MainViewController: CardViewControllerDelegate
{
    func cardWasUpdated()
    {
        self.updateView()
    }
}

