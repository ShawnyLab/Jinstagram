//
//  FriendSearchViewController.swift
//  Jinstagram
//
//  Created by 박진서 on 2021/02/21.
//

import UIKit
import Firebase

class FriendSearchViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference()
    
    //유저목록
    var userList: [UserModel] = []
    var userModel = UserModel()
    
    //버튼들
    @IBOutlet weak var button_container: UIView!
    @IBOutlet weak var famous_btn: UIButton!
    @IBOutlet weak var auth_btn: UIButton!
    @IBOutlet weak var tag_btn: UIButton!
    @IBOutlet weak var place_btn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        //버튼 크기적용
        let width = UIScreen.main.bounds.width / 4
        let height = button_container.frame.size.height
        
        famous_btn.frame = CGRect(x: 0, y: 0, width: width, height: height)
        auth_btn.frame = CGRect(x: width, y: 0, width: width, height: height)
        tag_btn.frame = CGRect(x: width * 2, y: 0, width: width, height: height)
        place_btn.frame = CGRect(x: width * 3, y: 0, width: width, height: height)
        
        //UserList 에 모든 인원 정보 담기
        ref.child("Users").observeSingleEvent(of: DataEventType.value) { (DataSnapshot) in
            for items in DataSnapshot.children.allObjects as! [DataSnapshot] {
                let values = items.value as! [String: Any]
                
                if values["uid"] as? String == self.uid {
                    continue
                } else {
                    let user = UserModel()
                    user.id = values["id"] as? String
                    user.uid = values["uid"] as? String
                    user.profileText = values["profileText"] as? String
                    user.profileImage = values["profileImage"] as? String
                    
                    self.userList.append(user)
                }
            }
            self.tableView.reloadData()
        }
        
        //파이어베이스에서 사용자 정보 받아오기
        ref.child("Users").observeSingleEvent(of: DataEventType.value) { (DataSnapshot) in
            for items in DataSnapshot.children.allObjects as! [DataSnapshot]{
                let values = items.value as! [String: Any]
                if values["uid"] as! String == self.uid! {
                    self.userModel.uid = values["uid"] as? String
                    self.userModel.id = values["id"] as? String
                    self.userModel.name = values["name"] as? String
                    self.userModel.email = values["email"] as? String
                    self.userModel.profileImage = values["profileImage"] as? String
                    self.userModel.profileText = values["profileText"] as? String
                    self.userModel.followers = values["followers"] as? Int
                    self.userModel.followings = values["followings"] as? Int
                    
                    if values["followerList"] != nil {
                        let val = values["followerList"] as? [String: Any]
                        for ids in val! {
                            self.userModel.followerList.append(ids.key)
                        }
                    }
                    if values["followingList"] != nil {
                        let val = values["followingList"] as? [String: Any]
                        for ids in val! {
                            self.userModel.followingList.append(ids.key)
                        }
                    }
                    self.userModel.profileImage = values["profileImage"] as? String
                }
            }
        }
        
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchFriendCell") as! SearchFriendCell
        cell.cell_image.layer.cornerRadius = cell.cell_image.frame.size.width / 2
        
        cell.label_id.text = userList[indexPath.row].id
        cell.label_profile_text.text = userList[indexPath.row].profileText
        
        cell.mainButtonClickHandler = {
            let VC = self.storyboard?.instantiateViewController(identifier: "OtherProfileViewController") as! OtherProfileViewController
            VC.uid = self.userList[indexPath.row].uid
            VC.mainUserModel = self.userModel
            VC.topVC = self
            VC.modalPresentationStyle = .fullScreen
            self.present(VC, animated: true, completion: nil)
            
        }
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(75)
    }
}

class SearchFriendCell: UITableViewCell {
    @IBOutlet weak var cell_image: UIImageView!
    @IBOutlet weak var label_id: UILabel!
    @IBOutlet weak var label_profile_text: UILabel!
    var mainButtonClickHandler: (() -> Void)?
    
    @IBAction func mainBtn_Clicked(_ sender: Any) {
        mainButtonClickHandler?()
    }
    
}
