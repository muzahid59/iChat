//
//  SignUpVC.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/10/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import UIKit
import Firebase

class SignUpVC: UIViewController {
    
    // MARK: Constants
    let signUpToList = "SignUpToContacts"
    
    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var textFieldLoginPassword: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: Actions
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        guard let email = textFieldLoginEmail.text, let password = textFieldLoginPassword.text else { return  }
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if error != nil {
                print("login failed...")
            } else {
                print("signin success...")
                self.performSegue(withIdentifier: self.signUpToList, sender: self)
            }
        }
        
    }
    
    @IBAction func signUpDidTouch(_ sender: AnyObject) {
        guard let email = textFieldLoginEmail.text, let password = textFieldLoginPassword.text else { return }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
            if error == nil {
                
                if let userDisplaName = user?.displayName {
                    
                    self.loginDidTouch(self)
                    
                } else {
                    self.presentDisplayNamePickerAlert(completion: { (name) in
                        if let name = name, let user = user {
                            let changeReq = user.createProfileChangeRequest()
                            changeReq.displayName = name
                            changeReq.commitChanges(completion: { (error) in
                                if let error = error {
                                    print(error.localizedDescription)
                                } else {
                                    self.createContact(user: user)
                                    self.loginDidTouch(self)
                                }
                            })
                        }
                    })
                }
                
            }
        })
    }
    
    
    func createContact(user: User) {
        let contact: Contact = Contact(user: user)
        contact.saveIntoFireDB()
    }
    
    
    func presentDisplayNamePickerAlert(completion: @escaping ((String?) -> Void)) {
        
        let alert = UIAlertController(title: nil, message: "Enter Display Name", preferredStyle: .alert)
        
        let updateAction = UIAlertAction(title: "Update", style: .default) { (action) in
            
            let nameField = alert.textFields![0]
            completion(nameField.text)
        }
        alert.addTextField { (displayNameField) in
            displayNameField.placeholder = "Display name"
        }
        
        alert.addAction(updateAction)
        present(alert, animated: true, completion: nil)
    }
    
}


