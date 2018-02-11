//
//  ChannelListViewController.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/5/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

enum Section: Int {
    case createNewChannelSection = 0
    case currentChannelsSection
}

class ChannelListViewController: UITableViewController {
    
    // MARK: Properties
    var senderDisplayName: String?
    var newChannelTextField: UITextField?
    private var channels: [Channel] = []
    
    private lazy var channelRef: DatabaseReference = Database.database().reference().child("channel")
    private var channelRefHandle: DatabaseHandle?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "RIC"
        observerChannels()
    }
    
    deinit {
        if let refHandle = channelRefHandle {
            channelRef.removeObserver(withHandle: refHandle)
        }
    }
    // MARK:- FireBase Related Methods

    private func observerChannels() {
        channelRefHandle = channelRef.observe(.childAdded, with: { (snapshot) in
            if let channelData = snapshot.value as? Dictionary<String, Any> {
                let id = snapshot.key
                if let name = channelData["name"] as? String, name.count > 0 {
                    self.channels.append(Channel(id: id, name: name))
                    self.tableView.reloadData()
                } else {
                    print("could not decode channel data")
                }
                
            }
        })
    }

    
    
    // MARK:- Action
    
    @IBAction func createChannel(_ sender: Any) {
        guard let channelName = newChannelTextField?.text, channelName.count > 0 else { return }
            let newChannelRef = self.channelRef.childByAutoId()
            let channelItem = [
                "name": channelName
                                ]
        newChannelRef.setValue(channelItem)
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
                return channels.count
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
            cell.textLabel?.text = channels[(indexPath as NSIndexPath).row].name
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == Section.currentChannelsSection.rawValue {
            let channel = self.channels[indexPath.row]
            self.performSegue(withIdentifier: "ShowChannel", sender: channel)
        }
    }
    
    
    // MARK:- Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let channel = sender as? Channel {
            if let chatViewController = segue.destination as?  ChatViewController {
                chatViewController.senderDisplayName = senderDisplayName
                chatViewController.channel = channel
                chatViewController.channelRef = channelRef.child(channel.id)
            }
        }
    }

    
}
