//
//  FBUserExtras.swift
//  iChat
//
//  Created by Muzahidul Islam on 2/12/18.
//  Copyright © 2018 Muzahidul Islam. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

extension User {
    func asContact() -> Contact {
        return Contact(user: self)
    }
    
    func update(displayName: String? = nil, photoUrl: String? = nil, completion: @escaping (_ error: Error?)->Void) {
        
        let changeReq = createProfileChangeRequest()
        if let name = displayName {
            changeReq.displayName = name
        }
        if let urlStr = photoUrl, let photURL = URL(string: urlStr) {
            changeReq.photoURL = photURL
        }
        
        changeReq.commitChanges(completion: { (error) in
            completion(error)
        })
    }
}

extension DataSnapshot {
    func asContact() -> Contact {
        return Contact(snapshot: self)
    }
}

extension StorageReference {
    func fetchImageDataAtURL(photoURL: String, completion:((UIImage?)->Void)?) {
        
        print(#function)
        
        
        self.getData(maxSize: Int64.max) { [weak self] (data, error) in
            if let error = error {
                print("Error downloading image data", error.localizedDescription)
                completion?(nil)
                
            }
            self?.getMetadata(completion: { (metadata, metaDataErr) in
                if let error = metaDataErr {
                    print("Error downloading meta data", error.localizedDescription)
                    completion?(nil)
                    
                }
                if metadata?.contentType == "image.gif" {
                    // TODO:
                    print("image.gif not handled yet")
                    completion?(nil)
                } else {
                    if let imageData = data {
                        print("image found")
                        completion?(UIImage(data: imageData))
                        // mediaItem.image =
                        
                    } else {
                        print("image data not found")
                        completion?(nil)
                    }
                }
                
            })
            
        }
    }
}
