//
//  AbilityDetailVC.swift
//  PokeTeam
//
//  Created by Jon Duenas on 8/13/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit
import Combine
import CoreData

class AbilityDetailVC: UIViewController {
    
    var coreDataStack: CoreDataStack!
    var backgroundDataManager: DataManager!
    var apiService: APIService!
    
    var abilityManagedObjectID: NSManagedObjectID?
    var abilityDetails: AbilityDetails?
    var abilityName: String?
    var abilityData: AbilityData?
    var abilityDescription: String?
    var indicatorView = UIActivityIndicatorView()
    var subscriptions: Set<AnyCancellable> = []

    @IBOutlet weak var abilityHeaderLabel: UILabel!
    @IBOutlet weak var abilityDescriptionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if coreDataStack == nil {
            print("Initializing new CoreDataStack")
            coreDataStack = CoreDataStack()
        }
        
        if backgroundDataManager == nil {
            print("Initializing new DataManager")
            let backgroundContext = coreDataStack.newDerivedContext()
            backgroundDataManager = DataManager(managedObjectContext: backgroundContext, coreDataStack: coreDataStack)
        }
        
        if apiService == nil {
            print("Initializing new APIService")
            apiService = APIService()
        }
        
        if let abilityName = abilityName {
            let fetchedAbilityArray = backgroundDataManager.getFromCoreData(entity: AbilityDetails.self, predicate: NSPredicate(format: "name == %@", abilityName)) as! [AbilityDetails]
            abilityDetails = fetchedAbilityArray[0]
        } else {
            print("abilityName is nill")
        }
        
//        if let abilityObjectID = abilityManagedObjectID {
//            ability = backgroundDataManager.managedObjectContext.object(with: abilityObjectID) as? AbilityMO
//            print(ability?.name)
//            print(ability?.isHidden)
//            print(ability?.urlString)
//        }
        
        initializeActivityIndicator()
        
        if shouldUpdateDetails() {
            print("Fetching ability details")
            fetchAbilityDetails()
        } else {
            print("Ability details already present.")
            showAbilityDetails()
        }
    }
    
    private func initializeActivityIndicator() {
        indicatorView = self.view.activityIndicator(style: .large, frame: self.view.frame, center: CGPoint(x: self.view.frame.width / 2, y: 100))
        view.addSubview(indicatorView)
    }
    
    private func shouldUpdateDetails() -> Bool {
        return abilityDetails?.abilityDescription == nil || abilityDetails?.abilityDescription == ""
    }
    
    private func fetchAbilityDetails() {
        guard let abilityURLString = abilityDetails?.urlString else {
            print("Error finding ability.urlString")
            return
        }
        
        guard let abilityURL = URL(string: abilityURLString) else {
            print("Error creating ability URL")
            return
        }

        setState(loading: true)

        apiService.fetch(type: AbilityData.self, from: abilityURL)
            .sink(receiveCompletion: { results in
                switch results {
                case .finished:
                    break
                case .failure(let error):
                    print(error)
                }
            },
                  receiveValue: { (abilityData) in
                    guard let objectID = self.abilityDetails?.objectID else { return }
                    self.backgroundDataManager.addAbilityDescription(to: objectID, with: abilityData)
                    self.coreDataStack.saveContext(self.backgroundDataManager.managedObjectContext)
                    
                    if let updatedAbility = self.backgroundDataManager.getFromCoreData(entity: AbilityDetails.self, predicate: NSPredicate(format: "name == %@", abilityData.name)) as? [AbilityDetails] {
                        self.abilityDetails = updatedAbility[0]
                    }
                    
                    DispatchQueue.main.async {
                        self.showAbilityDetails()
                        self.setState(loading: false)
                    }
            })
            .store(in: &subscriptions)
    }
    
    private func showAbilityDetails() {
        abilityHeaderLabel.text = abilityDetails?.name?.formatAbilityName()
        abilityDescriptionLabel.text = abilityDetails?.abilityDescription
    }
    
    private func setState(loading: Bool) {
        if loading {
            indicatorView.startAnimating()
            abilityHeaderLabel.isHidden = true
            abilityDescriptionLabel.isHidden = true
        } else {
            indicatorView.stopAnimating()
            abilityHeaderLabel.isHidden = false
            abilityDescriptionLabel.isHidden = false
        }
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
