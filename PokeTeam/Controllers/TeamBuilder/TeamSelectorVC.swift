//
//  TeamSelectorVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 11/16/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import CoreData

private let reuseIdentifier = "TeamCollectionCell"
//private let segueIdentifier = "detailSegue"

class TeamSelectorVC: UIViewController {
    let simpleOver = SimpleOver()
    var teamsArray = [TeamMO]()
    var coreDataStack: CoreDataStack!
    var dataManager: DataManager!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var refreshBarButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.delegate = self
        setupCustomNavController()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        loadSavedTeams()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //loadSavedTeams()
    }
    
    func setupCustomNavController() {
        let customNavVC = navigationController as! CustomNavVC
        navigationItem.title = "TEAM BUILDER"
        
        customNavVC.setupColorBlock(bottomColor: #colorLiteral(red: 0.768627451, green: 0.1568627451, blue: 0.2078431373, alpha: 1), topColor: #colorLiteral(red: 0.8509803922, green: 0.2196078431, blue: 0.2666666667, alpha: 1), fillScreen: true)
    }
    
    private func loadSavedTeams() {
        print("attempting load of teams")
        
        let request: NSFetchRequest<TeamMO> = TeamMO.fetchRequest()
        
        do {
            if !teamsArray.isEmpty {
                teamsArray = [TeamMO]()
            }
            
            teamsArray = try coreDataStack.mainContext.fetch(request)
            if teamsArray.count > 0 {
                print("Found \(teamsArray.count) stored teams")
                print("team 1: \(teamsArray[0])")
            }
        } catch {
            print("Team fetch failed: \(error)")
        }
        
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    @IBAction func refreshButtonTapped(_ sender: Any) {
        
        loadSavedTeams()
    }
}

extension TeamSelectorVC: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return teamsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! TeamCollectionCell
        
        // Configure the cell
        cell.setTeamInfo(teamsArray[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("Selected \(indexPath.item)")
    }
}

extension TeamSelectorVC: UIViewControllerTransitioningDelegate, UINavigationControllerDelegate {
    
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        simpleOver.popStyle = (operation == .pop)
        return simpleOver
    }
}
