//
//  ContactsTableViewController.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/11/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ContactsVC: UITableViewController {
    
    enum Section: Int {
        case currentChannelsSection = 0
    }
    // MARK: Properties
    var senderDisplayName: String?
    var newChannelTextField: UITextField?
    
    private var contacts: [Contact] = []
    
    private lazy var contactRef: DatabaseReference = Database.database().reference().child(DBRef.contact.rawValue)
    
    private var contactRefHandle: DatabaseHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationItem.title = Session.loggedUser?.displayName
       // self.navigationItem.setHidesBackButton(true, animated: false)
        observeContacts()
    }
    
    deinit {
        print(#function, "contact vc")
        if let refHandle = contactRefHandle {
            contactRef.removeObserver(withHandle: refHandle)
        }
    }
    // MARK:- FireBase Related Methods
    
    private func observeContacts() {
        contactRefHandle = contactRef.observe(.childAdded, with: { (snapshot) in
            let contact = snapshot.asContact()
            if contact.uid != Session.loggedUser?.uid {
                self.contacts.append(contact)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        })
    }
    

    
    // MARK:- Action
    
    @IBAction func logoutDidPress(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            Route.setLoginVCAsRoot()
        } catch  {
            print("signout error")
        }
    }
    
    
    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // 2
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .currentChannelsSection:
                return contacts.count
            }
        } else {
            return 0
        }
    }
    
    // 3
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "ExistingChannel"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
            cell.textLabel?.text = contacts[(indexPath as NSIndexPath).row].displayName
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == Section.currentChannelsSection.rawValue {
            
            var contact = self.contacts[indexPath.row]
            
            if let fromContact = Session.loggedUser {
                
                if let channelRef: DatabaseReference = DBRef.channel.ref {
                    let newRef = self.createChannel(from: fromContact, to: contact)
                    Session.loggedUser?.ref = newRef
                    contact.ref = newRef
                    self.performSegue(withIdentifier: "ShowChat", sender: contact)
                }
                
            }
        }
    }
    
    func createChannel(from: Contact, to: Contact) -> DatabaseReference? {
        if let channelRef: DatabaseReference = DBRef.channel.ref {
            
            let key = String((from.uid + to.uid).sorted())
            
            let newRef = channelRef.child(key)
            
            newRef.setValue([
                "name" : "anonymous",
                "members" : [from.uid, to.uid]
                ])
            return newRef
        }
        
        return nil
    }
    
    
    // MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let contact = sender as? Contact {
            if let chatViewController = segue.destination as?  ChatViewController {
                chatViewController.channelRef = contact.ref
                chatViewController.sender = contact
                chatViewController.senderDisplayName = contact.displayName
            }
        }
        
//        if let channel = sender as? Channel {
//            if let chatViewController = segue.destination as?  ChatViewController {
//                chatViewController.senderDisplayName = senderDisplayName
//                chatViewController.channel = channel
//                chatViewController.channelRef = channelRef.child(channel.id)
//            }
//        }
    
    }
}
