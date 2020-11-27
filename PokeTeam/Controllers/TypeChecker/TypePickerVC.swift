//
//  TypePickerVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 11/27/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class TypePickerVC: UIViewController {

    let reuseIdentifier = "TypePickerCell"
    
    var allTypes = [String]()
    var selectedTypeSlot: Int = 0
    var delegate: TypeCheckerVC?
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = createLayout()
    }
    
    // MARK: - Navigation

     @IBAction func closeButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
     }
}

extension TypePickerVC {
    func createLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                             heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                              heightDimension: .absolute(40))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        let spacing = CGFloat(10)
        group.interItemSpacing = .fixed(spacing)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = spacing
        section.contentInsets = NSDirectionalEdgeInsets(top: 20, leading: 20, bottom: 0, trailing: 20)

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
}

extension TypePickerVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allTypes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TypePickerCell
        
        cell.setTypeInfo(to: allTypes[indexPath.row])
        cell.backgroundColor = UIColor(named: allTypes[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedTypeName = allTypes[indexPath.row]
        print("Selected \(selectedTypeName)")
        
        self.dismiss(animated: true) { [weak self] in
            if self?.selectedTypeSlot == 1 {
                self?.delegate?.type1 = PokemonType(rawValue: selectedTypeName) ?? .none
            } else if self?.selectedTypeSlot == 2 {
                self?.delegate?.type2 = PokemonType(rawValue: selectedTypeName) ?? .none
            }
        }
    }
}
