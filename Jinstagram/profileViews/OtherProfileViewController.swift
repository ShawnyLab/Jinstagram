//
//  OtherProfileViewController.swift
//  Jinstagram
//
//  Created by 박진서 on 2021/02/23.
//

import UIKit
import Firebase

class OtherProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var uid: String?
    let ref = Database.database().reference()
    var topVC: UIViewController?
    var mainUserModel = UserModel()
    
    var amIfollowing = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var profile_Image: UIImageView!
    @IBOutlet weak var follow_Btn: UIButton!
    @IBOutlet weak var message_Btn: UIButton!
    @IBOutlet weak var followers_count: UILabel!
    @IBOutlet weak var following_count: UILabel!
    @IBOutlet weak var name_text: UILabel!
    @IBOutlet weak var profile_text: UILabel!
    @IBOutlet weak var profile_id: UILabel!
    @IBOutlet weak var content_count: UILabel!
    
    
    //게시물 ( content )
    var contentModels: [ContentModel] = []
    var userModel = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profile_Image.layer.cornerRadius = profile_Image.frame.size.width / 2
        
        follow_Btn.layer.borderWidth = 1
        follow_Btn.layer.cornerRadius = 5
        follow_Btn.layer.borderColor = UIColor.label.cgColor
        message_Btn.layer.borderWidth = 1
        message_Btn.layer.cornerRadius = 5
        message_Btn.layer.borderColor = UIColor.label.cgColor
        
        //파이어베이스 데이터베이스에서 컨텐츠 가져오기
        ref.child("Users").child(uid!).child("MyContents").observeSingleEvent(of: DataEventType.value) { (DataSnapshot) in
            for items in DataSnapshot.children.allObjects as! [DataSnapshot] {
                let values = items.value as! [String: Any]
                let content = ContentModel()
                
                URLSession.shared.dataTask(with: URL(string: values["ImageUrl"] as! String)!) { (data, response, error ) in
                    DispatchQueue.main.async {
                        content.image = UIImage(data: data!)
                        content.contentUid = values["uid"] as? String
                        content.text = values["ContentText"] as? String
                        
                        //모델에 넣어주기
                        self.contentModels.append(content)
                        self.content_count.text = "\(self.contentModels.count)"
                        self.collectionView.reloadData()
                    }
                }.resume()


            }
        }
        
        //파이어베이스에서 사용자 정보 받아오기
        ref.child("Users").observe(DataEventType.value) { (DataSnapshot) in
            for items in DataSnapshot.children.allObjects as! [DataSnapshot]{
                let values = items.value as! [String: Any]
                
                if values["uid"] as! String == self.uid! {
                    
                    self.userModel.id = values["id"] as? String
                    self.userModel.name = values["name"] as? String
                    self.userModel.email = values["email"] as? String
                    self.userModel.profileImage = values["profileImage"] as? String
                    self.userModel.profileText = values["profileText"] as? String
                    self.userModel.followers = values["followers"] as? Int
                    self.userModel.followings = values["followings"] as? Int
                    
                    if self.userModel.profileImage != nil {
                        URLSession.shared.dataTask(with: URL(string: self.userModel.profileImage!)!) { (data, response, error ) in
                            DispatchQueue.main.async {
                                self.profile_Image.image = UIImage(data: data!)
                            }
                        }.resume()
                    }
                    
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
                }
                
                //화면에 적용
                self.followers_count.text = "\(self.userModel.followers ?? 0)"
                self.following_count.text = "\(self.userModel.followings ?? 0)"
                self.name_text.text = self.userModel.name
                self.profile_text.text = self.userModel.profileText
                self.profile_id.text =
                    self.userModel.id    
            }
            
        }
        //팔로잉 중인가 아닌가?
        if mainUserModel.followingList.contains(uid!) {
            amIfollowing = true
        }
        
        if amIfollowing == true {
            let text = NSAttributedString(string: "팔로잉")
            follow_Btn.setAttributedTitle(text, for: .normal)
        }
        
        
    }
    
    @IBAction func follow_Clicked(_ sender: Any) {
        
        let friendSearchVC = topVC as! FriendSearchViewController
        
        var count = 0
        var acount = 0

        if amIfollowing == true {
            
            for uids in mainUserModel.followingList {
                if uids == uid {
                    amIfollowing = true
                    break
                } else {
                    count += 1
                }
            }
            
            for uids in userModel.followerList {
                if uids == mainUserModel.uid {
                    break
                } else {
                    acount += 1
                }
            }
            let text = NSAttributedString(string: "팔로우")
            follow_Btn.setAttributedTitle(text, for: .normal)
            
            //mainUser 의 팔로잉 1 감소 및 uid 제거
            //1. 모델에서 제거
            mainUserModel.followingList.remove(at: count)
            mainUserModel.followings! -= 1
            //2. FB에서 제거
            ref.child("Users").child(mainUserModel.uid!).child("followingList").child(uid!).removeValue()
            ref.child("Users").child(mainUserModel.uid!).child("followings").setValue(mainUserModel.followings)
   
            //팔로우 당한 user의 팔로워 1 감소 및 uid 제거
            //1. 모델에서 제거
            userModel.followerList.remove(at: acount)
            userModel.followers! -= 1
            //2. FB에서 제거
            ref.child("Users").child(uid!).child("followerList").child(mainUserModel.uid!).removeValue()
            ref.child("Users").child(uid!).child("followers").setValue(userModel.followers!)

            friendSearchVC.userModel = mainUserModel
            amIfollowing = false
        } else {
            let text = NSAttributedString(string: "팔로잉")
            follow_Btn.setAttributedTitle(text, for: .normal)

            
            //mainUser 의 팔로잉 1 추가 및 uid 추가
            
            //1. 모델에 추가
            mainUserModel.followingList.append(uid!)
            mainUserModel.followings! += 1
            //2.FB에 추가
            ref.child("Users").child(mainUserModel.uid!).child("followingList").child(uid!).setValue(["uid": uid!])
            ref.child("Users").child(mainUserModel.uid!).child("followings").setValue(mainUserModel.followings)
            
            //팔로우 당한 user의 팔로워 1 추가 및 uid 추가
            //1. 모델에 추가
            userModel.followerList.append(mainUserModel.uid!)
            userModel.followers! += 1
            //2. FB에 추가
            ref.child("Users").child(uid!).child("followerList").child(mainUserModel.uid!).setValue(["uid": mainUserModel.uid!])
            ref.child("Users").child(uid!).child("followers").setValue(userModel.followers)
            
            
            
            friendSearchVC.userModel = mainUserModel
            amIfollowing = true
        }
    }
    
    @IBAction func cancel_Btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OtherProfileCollectionViewCell", for: indexPath) as! OtherProfileCollectionViewCell
        let imageForCell = squareImage(at: contentModels[indexPath.row].image!, length: UIScreen.main.bounds.width / 3 - 1)
        let imageView = UIImageView(image: imageForCell)
        cell.addSubview(imageView)
        return cell
    }
    
    func squareImage(at image: UIImage, length: CGFloat = 100) -> UIImage? {
        let originWidth = image.size.width
        let originHeight = image.size.height
        var resizedWidth = length
        var resizedHeight = length
        
        UIGraphicsBeginImageContext(CGSize(width: length, height: length))
        UIColor.black.set()
        UIRectFill(CGRect(x: 0, y: 0, width: length, height: length))
        
        let sizeRatio = length / max(originWidth, originHeight)
        if originWidth > originHeight {
            resizedWidth = length
            resizedHeight = originHeight * sizeRatio
        } else {
            resizedWidth = originWidth * sizeRatio
            resizedHeight = length
        }
        image.draw(in: CGRect(x: length / 2 - resizedWidth / 2, y: length / 2 - resizedHeight / 2, width: resizedWidth, height: resizedHeight))
        
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }

}

extension OtherProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3 - 1
        let height = width
        
        return CGSize(width: width, height: height)
    }
}

class OtherProfileCollectionViewCell: UICollectionViewCell {
    
}
