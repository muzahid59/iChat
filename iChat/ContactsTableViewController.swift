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

class ContactsTableViewController: UITableViewController {
    
    // MARK: Properties
    var senderDisplayName: String?
    var newChannelTextField: UITextField?
    
    private var contacts: [Contact] = []
    
    private lazy var contactRef: DatabaseReference = Database.database().reference().child(DBRef.contact.rawValue)
    
    private var contactRefHandle: DatabaseHandle?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contact"
        observeContacts()
    }
    
    deinit {
        if let refHandle = contactRefHandle {
            contactRef.removeObserver(withHandle: refHandle)
        }
    }
    // MARK:- FireBase Related Methods
    
    private func observeContacts() {
        contactRefHandle = contactRef.observe(.childAdded, with: { (snapshot) in
            let contact = Contact(snapshot: snapshot)
            self.contacts.append(contact)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    
    
    // MARK:- Action
    
    @IBAction func createChannel(_ sender: Any) {
//        guard let channelName = newChannelTextField?.text, channelName.count > 0 else { return }
//        let newChannelRef = self.channelRef.childByAutoId()
//        let channelItem = [
//            "name": channelName
//        ]
//        newChannelRef.setValue(channelItem)
    }
    
    @IBAction func logoutDidPress(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            self.navigationController?.popViewController(animated: true)
        } catch  {
            print("signout error")
        }
    }
    
    
    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2 // 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // 2
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .createNewChannelSection:
                return 1
            case .currentChannelsSection:
                return contacts.count
            }
        } else {
            return 0
        }
    }
    
    // 3
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue ? "NewChannel" : "ExistingChannel"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        
        if (indexPath as NSIndexPath).section == Section.createNewChannelSection.rawValue {
            if let createNewChannelCell = cell as? CreateChannelCell {
                newChannelTextField = createNewChannelCell.newChannelNameField
            }
        } else if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
            cell.textLabel?.text = contacts[(indexPath as NSIndexPath).row].displayName
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == Section.currentChannelsSection.rawValue {
            
            let contact = self.contacts[indexPath.row]
            
            if let fromContact = App.shared.loggedUser {
                
                if let channelRef: DatabaseReference = DBRef.channel.ref {
                    let newRef = self.createChannel(from: fromContact, to: contact)
                    App.shared.loggedUser?.ref = newRef
                    contact.ref = newRef
                    self.performSegue(withIdentifier: "ShowChannel", sender: contact)
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
