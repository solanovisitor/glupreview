//
//  UserModel.swift
//  Advanced SwiftUI
//
//  Created by Hassan Bhatti on 08/10/2021.
//

import Foundation
class UserModel: NSObject, NSCoding {
    var uid : String?
    var name : String?
    var bio : String?
    var userSince : String?
    var numberOfCertificates : String?
    var proMember : Bool?
    var twitterHandle : Bool?
    var website : String?
    var profileImage : String?
    
    init(_ dic : [String:Any]) {
        uid = dic["uid"] as? String
        name = dic["name"] as? String
        bio = dic["bio"] as? String
        userSince = dic["userSince"] as? String
        numberOfCertificates = dic["numberOfCertificates"] as? String
        proMember = dic["proMember"] as? String == "0" ? false : true
        twitterHandle = dic["twitterHandle"] as? String == "0" ? false : true
        website = dic["uid"] as? String
        profileImage = dic["profileImage"] as? String
    }
    override init() {}
    required convenience init(coder aDecoder: NSCoder) {
        self.init()
        uid = aDecoder.decodeObject(forKey: "uid") as? String
        name = aDecoder.decodeObject(forKey: "name") as? String
        bio = aDecoder.decodeObject(forKey: "bio") as? String
        userSince = aDecoder.decodeObject(forKey: "userSince") as? String
        numberOfCertificates = aDecoder.decodeObject(forKey: "numberOfCertificates") as? String
        proMember = aDecoder.decodeBool(forKey: "proMember")
        twitterHandle = aDecoder.decodeBool(forKey: "twitterHandle")
        website = aDecoder.decodeObject(forKey: "website") as? String
        profileImage = aDecoder.decodeObject(forKey: "profileImage") as? String
    }
    func encode(with aCoder: NSCoder) {
        aCoder.encode(uid, forKey: "uid")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(bio, forKey: "bio")
        aCoder.encode(userSince, forKey: "userSince")
        aCoder.encode(numberOfCertificates, forKey: "numberOfCertificates")
        aCoder.encode(proMember, forKey: "proMember")
        aCoder.encode(twitterHandle, forKey: "twitterHandle")
        aCoder.encode(website, forKey: "website")
        aCoder.encode(profileImage, forKey: "profileImage")
    }
}
