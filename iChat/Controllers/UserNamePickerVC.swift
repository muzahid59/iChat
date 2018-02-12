//
//  UserNamePickerVC.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/12/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import UIKit

class UserNamePickerVC: UIViewController, UITextFieldDelegate {

    // MARK: Constants
    let segueIdentifier = "UserNameToPassword"
    
    // MARK: Outlets
    @IBOutlet weak var textFieldUserName: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    var userName: String?
    var email: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldUserName.becomeFirstResponder()
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
        if !(textFieldUserName.text?.isEmpty ?? false) {
            self.performSegue(withIdentifier: segueIdentifier, sender: textFieldUserName)
            
        }
        
    }
    
    @IBAction func alreadyHaveAccountButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK:- UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !(textField.text?.isEmpty ?? false) {
            self.performSegue(withIdentifier: segueIdentifier, sender: textField)
            
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let textField = sender as? UITextField {
            if let destination = segue.destination as? PasswordViewController {
                destination.userName = textField.text
                destination.email = self.email
            }
        }
    }
    
 

}
