//
//  dViewController.swift
//  Jinstagram
//
//  Created by 박진서 on 2021/02/19.
//

import UIKit

class UserModel {
    var id: String?
    var profileText: String?
    var profileImage: String?
    var uid: String?
    var email: String?
    var name: String?
    var followers: Int?
    var followings: Int?
    var followerList: [String] = []
    var followingList: [String] = []
}

class ContentModel {
    var image: UIImage?
    var contentUid: String?
    var text: String?
    var owner: UserModel?    // 이글을 쓴 사람
    var comments: Dictionary<String, String>?
}

class StoryModel {
    var id: String?
    var image: String?
    var uid: String?
}
