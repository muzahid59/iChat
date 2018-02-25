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
    
    enum SegueIdentifier: String {
        case ShowChat
        case HomePresentFriends
    }
    
    let showChat = "ShowChat"
    // MARK: Properties
    var senderDisplayName: String?
    var newChannelTextField: UITextField?
    
    private var contacts: [Contact] = []
    private var channels: [Channel] = []
    private lazy var channelRef: DatabaseReference? = DBRef.channel.ref
    
    private var channelRefHandle: DatabaseHandle?
    
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
        
        observeChannel()
    }
    
    deinit {
        print(#function, "contact vc")
        if let refHandle = channelRefHandle {
            channelRef?.removeObserver(withHandle: refHandle)
        }
    }
    
    // MARK:- FireBase Related Methods
    private func observeChannel() {
        guard let uid = Session.loggedUser?.uid else {
            return
        }
        channelRefHandle =  channelRef?.observe(.value, with: { (snapshot) in
            
            guard snapshot.hasChildren() else { return }
            
            for rest in (snapshot.children.allObjects as? [DataSnapshot])! {
                
                guard let value = rest.value as? [String: Any], let senderId = value[Channel.Fields.senderId] as? String, let receiverId = value[Channel.Fields.receiverId] as? String else {
                    print("snap data problem")
                    return
                }
                guard  (uid == senderId) || (uid == receiverId) else { return }
                
                if self.channels.contains(where: {$0.id == rest.key}){
                    for (index, channel) in self.channels.enumerated() {
                        if channel.id == rest.key {
                            self.channels[index] = Channel(snapshot: rest)
                            break
                        }
                    }
                } else {
                    let channel = Channel(snapshot: rest)
                    self.channels.append(channel)
                }
                
               // println(rest.value)
            }
//            for value in values {
//                if let senderId = value[Channel.Fields.senderId] as? String, let receiverId = value[Channel.Fields.receiverId] as? String {
//                    if (uid == senderId) || (uid == receiverId) {
//                        if self.channels.contains(where: {$0.id == value.key}){
//                            for (index, channel) in self.channels.enumerated() {
//                                if channel.id == value.key {
//                                    self.channels[index] = Channel(snapshot: value)
//                                    break
//                                }
//                            }
//                        } else {
//                            let channel = Channel(snapshot: value)
//                            self.channels.append(channel)
//                        }
//                    }
//                }
//            }
            
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        })
        channelRefHandle =  channelRef?.queryOrdered(byChild: Channel.Fields.receiverId).queryEqual(toValue: uid).observe(.childChanged, with: { (snapshot) in
            
            if self.channels.contains(where: {$0.id == snapshot.key}){
                for (index, channel) in self.channels.enumerated() {
                    if channel.id == snapshot.key {
                        self.channels[index] = Channel(snapshot: snapshot)
                        break
                    }
                }
            } else {
                let channel = Channel(snapshot: snapshot)
                self.channels.append(channel)
            }
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
        })
        
    }
    
    // MARK:- Action
    
    @IBAction func newChatButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: "HomePresentFriends", sender: self)
    }
 
    // MARK: UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let currentSection: Section = Section(rawValue: section) {
            switch currentSection {
            case .currentChannelsSection:
                return channels.count
            }
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "ChatHomeCell"
        let cell: ChatHomeCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! ChatHomeCell
        
        if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
            cell.displayNameLabel.text = channels[(indexPath as NSIndexPath).row].senderDisplayName
            var channel =  channels[indexPath.row]
            
            var text: String? = channel.lastMessage
            
            if channel.id == Session.loggedUser?.uid {
                text = "You " + (channel.lastMessage ?? "")
            }
            cell.lastMessageLabel.text = channels[(indexPath as NSIndexPath).row].lastMessage
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.section == Section.currentChannelsSection.rawValue {
            let channel = self.channels[indexPath.row]
            if Session.loggedUser != nil {
                self.performSegue(withIdentifier: SegueIdentifier.ShowChat.rawValue, sender: channel)
            }
        }
    }
    
    // MARK:- Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == SegueIdentifier.HomePresentFriends.rawValue {
            if let friendVC = (segue.destination as? UINavigationController)?.viewControllers.first as? FriendsVC {
                friendVC.didFinish = { [weak self] contact in
                    self?.dismiss(animated: false, completion: {
                        self?.performSegue(withIdentifier: SegueIdentifier.ShowChat.rawValue, sender: contact)
                    })
                }
            }
            
        } else if segue.identifier == SegueIdentifier.ShowChat.rawValue {
            
            if let chatViewController = segue.destination as?  ChatVC {
                
                var toContact: Contact?
                
                if let channel = sender as? Channel {
                    toContact = Contact(uid: channel.senderId!)
                    toContact?.displayName = channel.senderDisplayName
                } else if let contact = sender as? Contact {
                    toContact = contact
                }
                
                chatViewController.toContact = toContact
                chatViewController.senderDisplayName = toContact?.displayName
            }
            
            
        }
        
    }
}
