//
//  LoginViewController.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/5/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import UIKit
import FirebaseAuth

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    // MARK: Constants
    let loginToList = "SignUpToContacts"
    
    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
       Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                
                let contact = Contact(user: user!)
                App.shared.loggedUser = contact
                
                self.performSegue(withIdentifier: self.loginToList, sender: nil)
            }
        }
    }
    
    // MARK: Actions
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        guard let email = textFieldLoginEmail.text, let password = textFieldLoginPassword.text else { return  }
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print("login failed...")
            } else {
                print("signin success...")
                 self.performSegue(withIdentifier: self.loginToList, sender: nil)
            }
        }
        
    }
    
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "LoginToSignUp", sender: self)
    }
    
}



