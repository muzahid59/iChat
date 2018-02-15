//
//  EmailVC.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/12/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import UIKit

class EmailVC: UIViewController, UITextFieldDelegate {

    // MARK: Constants
    let segueIdentifier = "EmailToUserName"
    
    // MARK: Outlets
    @IBOutlet weak var textFieldLoginEmail: UITextField!
    @IBOutlet weak var continueButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldLoginEmail.becomeFirstResponder()
        addTapGesture()
        // Do any additional setup after loading the view.
    }

    func addTapGesture() {
        let tap: UITapGestureRecognizer =     UITapGestureRecognizer(target: self, action:    #selector(dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK:- Action
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        if !(textFieldLoginEmail.text?.isEmpty ?? false) {
            self.performSegue(withIdentifier: segueIdentifier, sender: textFieldLoginEmail)
            
        }
    }
    
    @IBAction func alreadyHaveAccountButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK:- UITextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !(textField.text?.isEmpty ?? false) {
            self.performSegue(withIdentifier: segueIdentifier, sender: textField)
            return true
        }
        return false
    }
    


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let textField = sender as? UITextField {
            if let destination = segue.destination as? UserNameVC {
                destination.email = textField.text
            }
        }
    }
 

}
