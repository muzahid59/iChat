//
//  LandingViewController.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/10/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import UIKit
import Firebase

class LandingViewController: UIViewController {

    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var listenerHanlde: AuthStateDidChangeListenerHandle?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.startAnimating()
        listenerHanlde = Auth.auth().addStateDidChangeListener {[weak self] (auth, user) in
            DispatchQueue.main.async {
                self?.spinner.stopAnimating()
                if user != nil {
                    Session.loggedUser = user?.asContact()
                    Route.setAppTabBarAsRoot()
                } else {
                    Route.setLoginVCAsRoot()
                }
            }
            
        }
        // Do any additional setup after loading the view.
    }
    
    deinit {
        if let listenerHanlde = self.listenerHanlde {
            Auth.auth().removeStateDidChangeListener(listenerHanlde)
        }
        print("Landing deinit")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
