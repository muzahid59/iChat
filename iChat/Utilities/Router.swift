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
        let tabbarController = UITabBarController()
        tabbarController.tabBar.barTintColor = appBGColor
        tabbarController.tabBar.tintColor = .white
    
        let storyboard = UIStoryboard.storyBoard(storyBoard: .Main)
        
        //  UITableViewController
        let contactsVC: ContactsVC =  storyboard.instantiateViewController(withIdentifier: ContactsVC.storyboardIdentifier) as! ContactsVC
        
        contactsVC.tabBarItem.selectedImage = UIImage(named: "chat_selected")
        contactsVC.tabBarItem.image = UIImage(named: "chat_deselected")
        contactsVC.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
        
        let profileVC = storyboard.instantiateViewController(withIdentifier: ProfileVC.storyboardIdentifier) as! ProfileVC
        
        profileVC.tabBarItem.selectedImage = UIImage(named: "profile_selected")
        profileVC.tabBarItem.image = UIImage(named: "profile_deselected")
        profileVC.tabBarItem.imageInsets = UIEdgeInsets(top: 5, left: 0, bottom: -5, right: 0)
       
        let viewControllers = [
            contactsVC,
            profileVC
        ]
        
        tabbarController.viewControllers = viewControllers.map {
            UINavigationController(rootViewController: $0)
        }
        
        switchRootViewController(viewController: tabbarController, animated: true, completion: {
            appDelegate.tabBarController = tabbarController
        })
        
    }
    
    static func setLoginVCAsRoot() {
        print(#function)
        let loginVC = UIStoryboard.storyBoard(storyBoard: .Main).instantiateViewController(withIdentifier: LoginViewController.storyboardIdentifier) as! LoginViewController
        switchRootViewController(viewController: loginVC, animated: true, completion: nil)
    }
    
    static func switchRootViewController(viewController: UIViewController, animated: Bool, completion:(() -> Void)?) {
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
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                
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
