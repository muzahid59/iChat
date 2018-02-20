//
//  ProfileVC.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/13/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

class ProfileVC: UIViewController {

    @IBOutlet weak var profilePic: UIImageView! {
        didSet {
            profilePicDidChange = true
        }
    }
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var displayNameField: UITextField!
    
    // Storage connection
    private lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://ichat-7223f.appspot.com/")
    
//    private var profilePicRef: DatabaseReference?
//    private var profileRefPicHandle: DatabaseHandle?
//
    private var nameDidChange: Bool = false {
        didSet {
           updateButton?.isEnabled = nameDidChange || profilePicDidChange
        }
    }
    private var profilePicDidChange: Bool = false {
        didSet {
           updateButton?.isEnabled = nameDidChange || profilePicDidChange
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        displayNameField.text = Session.loggedUser?.displayName
        profilePic.setImage(url: Auth.auth().currentUser?.photoURL)
        displayNameField.addTarget(self, action: #selector(testDidChange(_:)), for: .editingChanged)
        
    }
    
    @objc func testDidChange(_ textField: UITextField) {
        self.nameDidChange = true
    }

    @IBAction func editDidPressed(_ sender: Any) {
       
        presentImagePicker()
    }
    
    func updateUserInfo() {
        guard let image = profilePic.image, let displayName = displayNameField.text, displayName.count > 0 else {
            return
        }
        
        if profilePicDidChange && nameDidChange {
            updaloadImageInfoFireDB(image: image, completion: { (photoUrl) in
                if let urlStr = photoUrl {
                    
                    if let user = Auth.auth().currentUser {
                        user.update(photoUrl: urlStr, completion: { (error) in
                            Session.loggedUser = user.asContact()
                        })
                    }
                  self.updateContactPhotoUrl(urlString: urlStr)
                }
                
            })
            if let user = Auth.auth().currentUser {
                user.update(displayName: displayName, completion: { (error) in
                    Session.loggedUser = user.asContact()
                    self.updateContactDisplayName(name: displayName)
                })
            }
           
            
        } else if profilePicDidChange {
            updaloadImageInfoFireDB(image: image, completion: { (photoUrl) in
                if let urlStr = photoUrl {
                    
                    if let user = Auth.auth().currentUser {
                        user.update(photoUrl: urlStr, completion: { (error) in
                            Session.loggedUser = user.asContact()
                        })
                    }
                    self.updateContactPhotoUrl(urlString: urlStr)
                }
                
            })
            
        } else if nameDidChange {
            if let user = Auth.auth().currentUser {
                user.update(displayName: displayName, completion: { (error) in
                    Session.loggedUser = user.asContact()
                    self.updateContactDisplayName(name: displayName)
                })
            }
        }
       
    }
    
    
    
    @IBAction func saveButtonAction(_ sender: Any) {
        updateUserInfo()
        
    }
    
    @IBAction func logoutButtonAction(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            Route.setLoginVCAsRoot()
        } catch  {
            print("signout error")
        }
    }
    
    
    
    
    private func updateContactDisplayName(name: String) {
        
        let contactRef = DBRef.contact.ref
        let contactUid = Session.loggedUser?.uid
        if let id = contactUid {
            contactRef?.child(id).updateChildValues([Contact.fields.displayName: name])
        }
        
    }
    
    private func updaloadImageInfoFireDB(image: UIImage, completion: ((_ photoUrl:String?)->Void)?) {
        
        let imageData = UIImageJPEGRepresentation(image, 0.5)
        let imagePath = Auth.auth().currentUser!.uid + "/profile_pic.jpg"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        storageRef.child(imagePath).putData(imageData!, metadata: metadata, completion: { (metadata, error) in
            if let error = error {
                print("Error uploading photo: \(error)")
                completion?(nil)
            }
            completion?(metadata?.downloadURL()?.absoluteString)
           // self.updateContactPhotoUrl(urlString: self.storageRef.child((metadata?.path)!).description)
           
        })
    }
    
    private func updateContactPhotoUrl(urlString: String) {
        
        let contactRef = DBRef.contact.ref
        let contactUid = Session.loggedUser?.uid
        if let id = contactUid {
        contactRef?.child(id).updateChildValues([Contact.fields.photoUrl: urlString])
        }
       
    }
    
    
    func presentImagePicker()  {
        let picker = UIImagePickerController()
        picker.delegate = self
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = UIImagePickerControllerSourceType.camera
        } else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)  {
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        } else {
            return
        }
        present(picker, animated: true, completion: nil)
    }
    
    deinit {
//        if let refHandle = profileRefPicHandle {
//            profilePicRef?.removeObserver(withHandle: refHandle)
//        }
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


// MARK:- UITextField Delegate
extension ProfileVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


// MARK:- UIImagePicker Delegate

extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        if let photoReferenceUrl = info[UIImagePickerControllerImageURL] as? URL {
            // handling picking photo from PhotoLibrary
            
        } else {
            // picking image from camera
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            self.profilePic.image = image
            profilePicDidChange = true
            
            }
        }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
