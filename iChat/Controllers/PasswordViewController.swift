//
//  PasswordViewController.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/12/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import UIKit
import Firebase

class PasswordViewController: UIViewController, UITextFieldDelegate {

    // MARK: Constants
    let segueIdentifier = "userNameToPassword"
    
    // MARK: Outlets
    @IBOutlet weak var textFieldPassword: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    var email: String?
    var userName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldPassword.becomeFirstResponder()
        self.navigationItem.setHidesBackButton(true, animated: false)
       addTapGesture()
    }
    
    func addTapGesture() {
        let tap: UITapGestureRecognizer =     UITapGestureRecognizer(target: self, action:    #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    // MARK:- Action
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        
        guard let email = email, let password = textFieldPassword.text, let displayName = userName else { return }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: {[weak self] (user, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                print("signup successfull")
                guard let user = user else { return }
                
                let changeReq = user.createProfileChangeRequest()
                changeReq.displayName = displayName
                changeReq.commitChanges(completion: { (error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        print("display name update successfull")
                        self?.createContact(user: user)
                        self?.dismiss(animated: true, completion: nil)
                    }
                })
            }
        
        })
    }
    
    func createContact(user: User) {
        let contact: Contact = user.asContact()
        contact.saveIntoFireDB()
    }
    
    
    @IBAction func alreadyHaveAccountButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return false
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
