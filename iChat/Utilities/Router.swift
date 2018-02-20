//
//  NavigationHelper.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/13/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import Foundation
import UIKit

struct Route {
    
    static func setAppTabBarAsRoot() {
        print(#function)
        
        let tabBarController: UITabBarController = {
            let tabController = UITabBarController()
            tabController.tabBar.barTintColor = appBGColor
            tabController.tabBar.tintColor = .white
            return tabController
        }()
        
        let storyboard = UIStoryboard.storyBoard(storyBoard: .Main)
        
        let contactsVC: ChatHomeVC = {
            let contactsVC: ChatHomeVC =  storyboard.instantiateViewController(withIdentifier: ChatHomeVC.storyboardIdentifier) as! ChatHomeVC
            
            contactsVC.tabBarItem.selectedImage = UIImage(named: "chat_selected")
            contactsVC.tabBarItem.image = UIImage(named: "chat_deselected")
            contactsVC.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            return contactsVC
        }()
        
        let profileVC: ProfileVC = {
            let profileVC = storyboard.instantiateViewController(withIdentifier: ProfileVC.storyboardIdentifier) as! ProfileVC
            
            profileVC.tabBarItem.selectedImage = UIImage(named: "profile_selected")
            profileVC.tabBarItem.image = UIImage(named: "profile_deselected")
            profileVC.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
            return profileVC
        }()
        
        let viewControllers = [
            contactsVC,
            profileVC
        ]
        
        tabBarController.viewControllers = viewControllers.map {
            UINavigationController(rootViewController: $0)
        }
        
        switchRootViewController(viewController: tabBarController,
                                 animated: true,
                                 completion: {
                                    appDelegate.tabBarController = tabBarController
        })
        
    }
    
    static func setLoginVCAsRoot() {
        print(#function)
        let loginVC = UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: LoginVC.storyboardIdentifier) as! LoginVC
        switchRootViewController(viewController: loginVC, animated: true, completion: nil)
    }
    
    static func switchRootViewController(viewController: UIViewController,
                                         animated: Bool,
                                         options: UIViewAnimationOptions = .transitionCrossDissolve,
                                         completion:(() -> Void)?) {
        
        print(#function)
        
        guard let window = appDelegate.window else {
            print("Appdelegate window not found")
            return
        }
        
        if !animated {
            window.rootViewController = viewController
            window.makeKeyAndVisible()
            completion?()
        } else {
            UIView.transition(with: window, duration: 0.5, options: options, animations: {
                
                let oldState: Bool = UIView.areAnimationsEnabled
                UIView.setAnimationsEnabled(false)
                window.rootViewController = viewController
                UIView.setAnimationsEnabled(oldState)
            }, completion: { (finish) in
                completion?()
            })
        }
    }
    
}
