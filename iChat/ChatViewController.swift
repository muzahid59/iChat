//
//  ChatViewController.swift
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

final class ChatViewController: JSQMessagesViewController {
    
    // channel properties
    var channelRef: DatabaseReference?
    var channel: Channel? {
        didSet {
            title = channel?.name
        }
    }
    
    // message DB connection
    private lazy var messageRef: DatabaseReference = self.channelRef!.child("message")
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
        self.senderId = Auth.auth().currentUser?.uid
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        observeMessages()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }

    
    // MARK:- Observe Messages
    private func observeMessages() {
        print(#function)
        messageRef = channelRef!.child("messages")
        let messageQuery = messageRef.queryLimited(toLast: 20)
        
        // new message addition handle
        newMessageHandle = messageQuery.observe(.childAdded, with: { (snapshot) in
            if let messageData = snapshot.value as? Dictionary<String, String> {
                if let id = messageData["senderId"], let name = messageData["senderName"], let text = messageData["text"] as? String, text.count > 0 {
                    self.addMessage(withId: id, name: name, text: text)
                    self.finishReceivingMessage()
                } else if let id = messageData["senderId"], let photoURL = messageData["photoURL"]  {
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
        updatedMessageRefHandle = messageRef.observe(.childChanged, with: {[weak self] (snapshot) in
            if let messageData = snapshot.value as? Dictionary<String, String> {
                let key = snapshot.key
                if let photoURL = messageData["photoURL"] {
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
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "photoURL": imageURLNotSetKey,
            "senderId": senderId
        ]
        itemRef.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        return itemRef.key
    }
    
    
    private func setImageURL(urlString: String, forPhotoMessageWithKey key: String) {
        let itemRef = messageRef.child(key)
        itemRef.updateChildValues(["photoURL": urlString])
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
        return nil
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
        if let refHandle = newMessageHandle {
            messageRef.removeObserver(withHandle: refHandle)
        }
        if let refHandle = updatedMessageRefHandle {
            messageRef.removeObserver(withHandle: refHandle)
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

extension ChatViewController {
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        let itemRef = messageRef.childByAutoId()
        let messageItem = [
            "senderId" : senderId,
            "senderName" : senderDisplayName,
            "text" : text
        ]
        itemRef.setValue(messageItem)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        isTyping = false
    }
}


// MARK:- didPressAccessoryButton

extension ChatViewController {
    
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

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
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

extension ChatViewController {
    
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





