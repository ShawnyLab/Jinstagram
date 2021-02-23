//
//  ProfileViewController.swift
//  Jinstagram
//
//  Created by 박진서 on 2021/02/21.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference()
    
    @IBOutlet weak var content_count: UILabel!
    @IBOutlet weak var followers_count: UILabel!
    @IBOutlet weak var following_count: UILabel!
    @IBOutlet weak var profile_Image: UIImageView!
    @IBOutlet weak var name_text: UILabel!
    @IBOutlet weak var profile_text: UILabel!
    @IBOutlet weak var profile_Id: UILabel!
    
    @IBOutlet weak var edit_Btn: UIButton!
    @IBOutlet weak var saved_Btn: UIButton!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    //게시물 ( content )
    var contentModels: [ContentModel] = []
    var userModel = UserModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profile_Image.layer.cornerRadius = profile_Image.frame.size.width / 2
        
        edit_Btn.layer.borderWidth = 1
        edit_Btn.layer.cornerRadius = 5
        edit_Btn.layer.borderColor = UIColor.label.cgColor
        saved_Btn.layer.borderWidth = 1
        saved_Btn.layer.cornerRadius = 5
        saved_Btn.layer.borderColor = UIColor.label.cgColor
        
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
                    
                    if self.userModel.profileImage != nil {
                        URLSession.shared.dataTask(with: URL(string: self.userModel.profileImage!)!) { (data, response, error ) in
                            DispatchQueue.main.async {
                                self.profile_Image.image = UIImage(data: data!)
                            }
                        }.resume()
                    }
                }
                
                //화면에 적용
                self.followers_count.text = "\(self.userModel.followers ?? 0)"
                self.following_count.text = "\(self.userModel.followings ?? 0)"
                self.name_text.text = self.userModel.name
                self.profile_text.text = self.userModel.profileText
                self.profile_Id.text =
                    self.userModel.id
            }          
        }
        
    }
    
    @IBAction func ProfileEdit_Btn(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(identifier: "ProfileEditViewController") as! ProfileEditViewController
        VC.modalPresentationStyle = .fullScreen
        VC.topVC = self
        VC.userModel = self.userModel
        self.present(VC, animated: true, completion: nil)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return contentModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfileCollectionViewCell", for: indexPath) as! ProfileCollectionViewCell
        
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

extension ProfileViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width / 3 - 1
        let height = width
        
        return CGSize(width: width, height: height)
    }
}

class ProfileCollectionViewCell: UICollectionViewCell {
    
}
