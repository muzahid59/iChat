//
//  FriendsVC.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/21/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class FriendsVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var contacts: [Contact] = []
    private lazy var contactRef: DatabaseReference? = DBRef.contact.ref 
    private var contactRefHandle: DatabaseHandle?
    
    public var didFinish: ((Contact) -> Void)?

    var selectedRow: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UINib(nibName: "FriendsCell", bundle: nil), forCellReuseIdentifier: "FriendsCell")
        tableView.tableFooterView = UIView()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeContacts()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let refhandler = contactRefHandle {
            contactRef?.removeObserver(withHandle: refhandler)
        }
    }
    // MARK:- FireBase Related Methods
    
    private func observeContacts() {
        contactRefHandle = contactRef?.observe(.childAdded, with: { (snapshot) in
            let contact = snapshot.asContact()
            if contact.uid != Session.loggedUser?.uid {
                self.contacts.append(contact)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            
        })
    }
    
    @IBAction func doneButtonDidPressed(_ sender: Any) {
        if let row = selectedRow {
            didFinish?(contacts[row])
        }
//        dismiss(animated: true, completion: nil)
    }
    deinit {
        
        print("Friends ", #function)
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

extension FriendsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { // 2
        return contacts.count
    }
    
    // 3
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseIdentifier = "FriendsCell"
        let cell: FriendsCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! FriendsCell
        cell.displayNameLabel.text = contacts[indexPath.row].displayName
        cell.selectedButton.isSelected = indexPath.row == selectedRow
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        tableView.reloadData()
      //  doneButtonDidPressed(self)
    }
}
