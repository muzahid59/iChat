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

class ChatHomeVC: UITableViewController {
    
    enum Section: Int {
        case currentChannelsSection = 0
    }
    // MARK: Properties
    var senderDisplayName: String?
    var newChannelTextField: UITextField?
    
    private var contacts: [Contact] = []
    private var channels: [Channel] = []
    private lazy var contactRef: DatabaseReference = Database.database().reference().child(DBRef.contact.rawValue)
    
    private var contactRefHandle: DatabaseHandle?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
       // appDelegate.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationItem.title = Session.loggedUser?.displayName
        
        tableView.register(UINib(nibName: "ChatHomeCell", bundle: nil), forCellReuseIdentifier: "ChatHomeCell")
        tableView.tableFooterView = UIView()
        
     //   observeContacts()
        observeChannel()
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
    
    private func observeChannel() {
        guard let uid = Session.loggedUser?.uid else {
            return
        }
        let channelRef = DBRef.channel.ref
        channelRef?.queryOrdered(byChild: Channel.Fields.receiverId).queryEqual(toValue: uid).observe(.childAdded, with: { (snapshot) in
            let channel = Channel(snapshot: snapshot)
            self.channels.append(channel)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            if let value = snapshot.value as? [String : Any] {
                print("last message",value[Channel.Fields.lastMessage] as? String)
            }
            
        })
       
    }
    
    

    
    // MARK:- Action
    
    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1 // 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // 2
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .currentChannelsSection:
                return channels.count
            }
        } else {
            return 0
        }
    }
    
    // 3
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "ChatHomeCell"
        let cell: ChatHomeCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ChatHomeCell
        
        if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
           // cell.displayNameLabel.text = contacts[(indexPath as NSIndexPath).row].displayName
            cell.lastMessageLabel.text = channels[(indexPath as NSIndexPath).row].lastMessage
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == Section.currentChannelsSection.rawValue {
            
            var toContact = self.contacts[indexPath.row]
            
            if let fromContact = Session.loggedUser {
                
                if let channelRef: DatabaseReference = DBRef.channel.ref {
                    
                    self.performSegue(withIdentifier: "ShowChat", sender: toContact)
                }
                
            }
        }
    }
    
    // MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let contact = sender as? Contact {
            if let chatViewController = segue.destination as?  ChatVC {
              //  chatViewController.channelRef = contact.channelRef
                chatViewController.receiver = contact
                chatViewController.senderDisplayName = contact.displayName
            }
        }
        
    }
}
