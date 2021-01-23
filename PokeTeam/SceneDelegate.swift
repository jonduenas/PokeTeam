//
//  SceneDelegate.swift
//  PokeTeam
//
//  Created by Jon Duenas on 7/31/20.
//  Copyright © 2020 Jon Duenas. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: windowScene)
        
        let coreDataStack = CoreDataStack()
        let dataManager = DataManager(managedObjectContext: coreDataStack.newDerivedContext(), coreDataStack: coreDataStack)
        
        let tabController = CustomTabController()
        
        // Setup View Controllers
        // Pokedex
        let pokedexVC = UIStoryboard(name: "Pokedex", bundle: .main).instantiateViewController(identifier: "PokedexVC") { coder in
            PokedexVC(coder: coder, coreDataStack: coreDataStack, dataManager: dataManager)
        }
        let pokedexNav = CustomNavVC(rootViewController: pokedexVC)
        
        let pokedexTabImage = UIImage(systemName: "book.fill")
        let pokedexTabBarItem = UITabBarItem(title: "Pokedex", image: pokedexTabImage, selectedImage: nil)
        pokedexNav.tabBarItem = pokedexTabBarItem
        
        // Team Builder
        let teamBuilderVC = UIStoryboard(name: "TeamBuilder", bundle: .main).instantiateViewController(identifier: "TeamBuilderVC") { coder in
            TeamBuilderVC(coder: coder, coreDataStack: coreDataStack, dataManager: dataManager)
        }
        let teamBuilderNav = CustomNavVC(rootViewController: teamBuilderVC)
        
        let teamTabImage = UIImage(systemName: "shield.lefthalf.fill")
        let teamTabBarItem = UITabBarItem(title: "Team Builder", image: teamTabImage, selectedImage: nil)
        teamBuilderNav.tabBarItem = teamTabBarItem
        
        // Type Checker
        let typeCheckerVC = UIStoryboard(name: "TypeChecker", bundle: .main).instantiateViewController(identifier: "TypeCheckerVC") { coder in
            TypeCheckerVC(coder: coder, coreDataStack: coreDataStack, dataManager: dataManager)
        }
        let typeCheckerNav = CustomNavVC(rootViewController: typeCheckerVC)
        
        let typeTabImage = UIImage(systemName: "gauge")
        let typeTabBarItem = UITabBarItem(title: "Type Checker", image: typeTabImage, selectedImage: nil)
        typeCheckerNav.tabBarItem = typeTabBarItem
        
        // Add View Controllers to Tab Controller
        let controllers = [pokedexNav, teamBuilderNav, typeCheckerNav]
        tabController.setViewControllers(controllers, animated: false)
        
        window.rootViewController = tabController
        window.makeKeyAndVisible()
        self.window = window
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        // Save changes in the application's managed object context when the application transitions to the background.
//        coreDataStack.saveContext()
    }


}

