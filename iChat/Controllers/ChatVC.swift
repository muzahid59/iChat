//
//  ChatVC.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/5/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import UIKit
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth
import JSQMessagesViewController
import Photos
import ImageIO

final class ChatVC: JSQMessagesViewController {
    
    // channel properties
    private lazy var channelRef: DatabaseReference? = {
        var ref: DatabaseReference? = nil
        if let fromContact = Session.loggedUser, let receiver = self.receiver {
            let newRef = Channel.createChannel(from: fromContact, to: receiver)
            return newRef
        }
        return nil
    }()
    
    var receiver: Contact? {
        didSet {
            title = receiver?.displayName
            if let id = receiver?.uid {
                senderId = id
            }
            
        }
    }
    
    // message DB connection
    private lazy var messageRef: DatabaseReference? = DBRef.message.ref
    private var newMessageHandle: DatabaseHandle?
    private var updatedMessageRefHandle: DatabaseHandle?
    
    // message typing DB connection
    private lazy var userIsTypingRef: DatabaseReference = self.channelRef!.child(DBRef.typingIndicator.rawValue).child(self.senderId)
    private lazy var userTypingQuery: DatabaseQuery = self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
    
    // Storage connection
    private lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://ichat-7223f.appspot.com/")
    
    // photo properties
    private let imageURLNotSetKey = "NOTSET"
    private var photoMessageMap = [String : JSQPhotoMediaItem]()
    
    // typing properties
    private var localTyping: Bool = false
    var isTyping: Bool {
        get {
            return self.localTyping
        }
        set {
            self.localTyping = newValue
            userIsTypingRef.setValue(newValue)
        }
    }
    
    // jsqbubble properties
    lazy var outGoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutGoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    
    var messages: [JSQMessage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         self.navigationItem.setHidesBackButton(false, animated: false)
        
        self.senderId = Session.loggedUser?.uid
        self.senderDisplayName = Session.loggedUser?.displayName
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 40.0, height: 40.0)
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 40.0, height: 40.0)
        
       // observeMessages()
        observerMessage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         appDelegate.tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    // MARK:- Observe Messages
    
    private func observerMessage() {
        print(#function)
        // messageRef = channelRef!.child("messages")
        let messageQuery = messageRef?.queryLimited(toLast: 20)
        
        // new message addition handle
        newMessageHandle = messageQuery?.queryOrdered(byChild: Message.Fields.channelId).queryEqual(toValue: channelRef?.key).observe(.childAdded, with: { (snapshot) in
            if let messageData = snapshot.value as? [String : Any] {
                if let text = messageData[Message.Fields.text] as? String, text.count > 0, let senderId = messageData[Message.Fields.senderId] as? String, let displyaName = self.receiver?.displayName {
                    
                    self.addMessage(withId: senderId, name: displyaName, text: text)
                    self.finishReceivingMessage()
                    
                }
                else if let id = messageData[Message.Fields.senderId] as? String, let photoURL = messageData[Message.Fields.photoUrl] as? String  {
                    if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
                        self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
                        if photoURL.hasPrefix("gs://") {
                            self.fetchImageDataAtURL(photoURL: photoURL, forMediaItem: mediaItem, clearPhotoMessageMapOnSuccessForKey: nil)
                        }
                        
                    }
                    
                }
            } else {
                print("message data not found")
            }
        })
        
        // update message handle
        updatedMessageRefHandle = messageRef?.observe(.childChanged, with: {[weak self] (snapshot) in
            if let messageData = snapshot.value as? Dictionary<String, String> {
                let key = snapshot.key
                if let photoURL = messageData[Message.Fields.photoUrl] {
                    if let mediaItem = self?.photoMessageMap[key] {
                        self?.fetchImageDataAtURL(photoURL: photoURL, forMediaItem: mediaItem, clearPhotoMessageMapOnSuccessForKey: key)
                    }
                }
            } else {
                print("update message data not found")
            }
        })
        
        
    }
    
    
    // MARK:- Observer Typing

    private func observeTyping() {
        let typingIndicatorRef = self.channelRef?.child("typingIndicator")
        let userTypingRef = typingIndicatorRef?.child(senderId)
        userTypingRef?.onDisconnectRemoveValue()
        
        userTypingQuery.observe(.value) { (snapshot) in
            if snapshot.childrenCount == 1 && self.isTyping {
                print("self typing...")
                return
            }
            self.showTypingIndicator = snapshot.childrenCount > 0
            self.scrollToBottom(animated: true)
        }
    }


    
    // MARK:- Add Message
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    
    // MARK:- PhotoMessage Methods

    /// Send Photo message, with dummy url
    private func sendPhotoMessage() -> String? {
        
        let itemRef = messageRef?.childByAutoId()
        let messageItem = [
            Message.Fields.photoUrl     : imageURLNotSetKey,
            Message.Fields.senderId     : senderId,
            Message.Fields.channelId    : channelRef?.key
        ]
        itemRef?.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        return itemRef?.key
    }
    
    
    private func setImageURL(urlString: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef?.child(key)
        itemRef?.updateChildValues([Message.Fields.photoUrl: urlString])
    }

    private func fetchImageDataAtURL(photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearPhotoMessageMapOnSuccessForKey key: String?) {
        
        print(#function)
        
        let storageRef = Storage.storage().reference(forURL: photoURL)
        
        storageRef.getData(maxSize: Int64.max) {[weak self] (data, error) in
            if let error = error {
                print("Error downloading image data", error.localizedDescription)
                return
            }
            storageRef.getMetadata(completion: { (metadata, metaDataErr) in
                if let error = metaDataErr {
                    print("Error downloading meta data", error.localizedDescription)
                    return
                }
                if metadata?.contentType == "image.gif" {
                    // TODO:
                } else {
                    if let imageData = data {
                        mediaItem.image = UIImage(data: imageData)
                    } else {
                        print("image data not found")
                    }
                }
                
                self?.collectionView.reloadData()
                
                guard let mapKey = key else {
                    return
                }
                self?.photoMessageMap.removeValue(forKey: mapKey)
            })
            
        }
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        print(#function)
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            if mediaItem.image == nil {
                photoMessageMap[key] = mediaItem
            }
            collectionView.reloadData()
        }
    }
    
    
    // MARK:- JSQAvatar Disable

    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = messages[indexPath.item]
        let avatar = message.senderId == senderId ? "avatar_outgoing" : "avatar_incoming"
       
        return JSQMessagesAvatarImage(placeholder: UIImage(named: avatar))
    }

    
    // MARK:- JSQBubble Setup
    
    private func setupOutGoingBubble() -> JSQMessagesBubbleImage {
        return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }

    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        
        return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImage(with: appBGColor)
    }

    
    // MARK:- JSQBubbleImageDataSource
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item]
        if senderId == message.senderId {
            return self.outGoingBubbleImageView
        } else {
            return self.incomingBubbleImageView
        }
    }
    
    
    // MARK:- Composing Message

    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        isTyping = !textView.text.isEmpty
    }

    
    // MARK:- Deinit

    deinit {
        print(#function, "chat vc")
        if let refHandle = newMessageHandle {
            messageRef?.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updatedMessageRefHandle {
            messageRef?.removeObserver(withHandle: refHandle)
        }
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



// MARK:- Send Button Did Press

extension ChatVC {
    
    fileprivate func updateChannelLastMessage(_ text: String!, _ senderId: String!) {
        // fire db message set values
        
        self.channelRef?.setValue([
            Channel.Fields.lastMessage : text,
            Channel.Fields.senderId : senderId,
            Channel.Fields.receiverId : receiver?.uid
            ])
    }
    
    fileprivate func createNewFireDBMessage(_ text: String!, _ senderId: String!) {
        
        let itemRef = messageRef?.childByAutoId() // create new message
        
        let messageItem = [
            Message.Fields.senderId : senderId,
            Message.Fields.text : text,
            Message.Fields.channelId : channelRef?.key
        ]
        itemRef?.setValue(messageItem)
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        
        createNewFireDBMessage(text, senderId)
        updateChannelLastMessage(text, senderId)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        isTyping = false
    }
}


// MARK:- didPressAccessoryButton

extension ChatVC {
    
    override func didPressAccessoryButton(_ sender: UIButton!) {
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
    
}


// MARK:- UIImagePickerControllerDelegate

extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        if let photoReferenceUrl = info[UIImagePickerControllerImageURL] as? URL {
            // handling picking photo from PhotoLibrary
            let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
            let asset = assets.firstObject
            
            if let key = sendPhotoMessage() {
                asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
                    let imageUrl = contentEditingInput?.fullSizeImageURL
                    
                    let path = "\(Auth.auth().currentUser!.uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
                    
                    self.storageRef.child(path).putFile(from: imageUrl!, metadata: nil, completion: { (metaData, error) in
                        if let error = error {
                            print("fail to save image into db", error.localizedDescription)
                            return
                        } else {
                            self.setImageURL(urlString: self.storageRef.child((metaData?.path)!).description, forPhotoMessageWithKey: key)
                        }
                    })
                })
            }
        } else {
            // picking image from camera
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage
            if let key = sendPhotoMessage() {
                let imageData = UIImageJPEGRepresentation(image, 0.5)
                let imagePath = Auth.auth().currentUser!.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                storageRef.child(imagePath).putData(imageData!, metadata: metadata, completion: { (metadata, error) in
                    if let error = error {
                        print("Error uploading photo: \(error)")
                        return
                    }
                    self.setImageURL(urlString: self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
                })
                
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK:- JSQDataSource

extension ChatVC {
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
            return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
//    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = super.collectionView.cellForItem(at: indexPath) as! JSQMessagesCollectionViewCell
//        let message = messages[indexPath.item]
//        if senderId == message.senderId {
//            cell.textView.textColor = .white
//        } else {
//            cell.textView.textColor = .black
//        }
//        return cell
//    }
}





