//
//  MainViewController.swift
//  Jinstagram
//
//  Created by 박진서 on 2021/02/19.
//

import UIKit
import Firebase

class MainViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference()
    
    //Story CollectionView
    var StoryModels: [StoryModel] = []
    
    
    //UserModel
    var userModel = UserModel()
    
    
    //Main TableView
    var ContentModels: [ContentModel] = []
    
    
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        
        //UserModel 에 정보 집어넣기
        ref.child("Users").observeSingleEvent( of: DataEventType.value) { (DataSnapshot) in
            for items in DataSnapshot.children.allObjects as! [DataSnapshot] {
                let values = items.value as! [String: Any]
                if values["uid"] as! String == self.uid! {
                    self.userModel.id = values["id"] as? String
                    self.userModel.email = Auth.auth().currentUser?.email
                    self.userModel.uid = values["uid"] as? String
                }
            }
            
            //내 스토리 올리기
            let myStoryModel = StoryModel()
            myStoryModel.id = self.userModel.id
            myStoryModel.uid = self.userModel.uid
            
            self.StoryModels.append(myStoryModel)
            
            self.collectionView.reloadData()
        }
        
        getContents()


    }
    
    @IBAction func addContent_Btn(_ sender: Any) {
        let addContentVC = self.storyboard?.instantiateViewController(identifier: "AddContentViewController") as! AddContentViewController
        
        addContentVC.mainVC = self
        addContentVC.myInfo = self.userModel
        
        addContentVC.modalPresentationStyle = .fullScreen
        self.present(addContentVC, animated: true, completion: nil)
    }
    
    func getContents() {
        ref.child("Users").child(uid!).child("MyContents").observeSingleEvent( of: DataEventType.value) { (DataSnapshot) in
            for items in DataSnapshot.children.allObjects as! [DataSnapshot] {
                let values = items.value as! [String: Any]
                let content = ContentModel()
                                
                URLSession.shared.dataTask(with: URL(string: values["ImageUrl"] as! String)!) { (data, response, error ) in
                    DispatchQueue.main.async {
                        content.image = UIImage(data: data!)
                        content.contentUid = values["uid"] as? String
                        content.owner = self.userModel
                        content.text = values["ContentText"] as? String
                        
                        //모델에 넣어주기
                        self.ContentModels.append(content)
                        self.tableView.reloadData()
                    }
                }.resume()


            }
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return StoryModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoryCell", for: indexPath) as! StoryCell
        cell.imageView.layer.cornerRadius = cell.imageView.frame.size.width / 2
        cell.imageView.clipsToBounds = true
        cell.label_id.text = StoryModels[indexPath.row].id

        
        return cell
    }
    
}

extension MainViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height: CGFloat = CGFloat(90)
        let width: CGFloat = CGFloat(78)
        
        return CGSize(width: width, height: height)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContentModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell") as! MainCell
        cell.content_profileImage.layer.cornerRadius = cell.content_profileImage.frame.size.width / 2
        cell.content_id.text = ContentModels[indexPath.row].owner?.id
        cell.content_mainImage.image = ContentModels[indexPath.row].image
        cell.content_text.text = ContentModels[indexPath.row].text
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(540)
    }
    
    
}


class StoryCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label_id: UILabel!
    
    
}

class MainCell: UITableViewCell {
    @IBOutlet weak var content_profileImage: UIImageView!
    @IBOutlet weak var content_id: UILabel!
    @IBOutlet weak var content_mainImage: UIImageView!
    
    @IBOutlet weak var content_heart: UIButton!
    @IBOutlet weak var content_comments: UIButton!
    @IBOutlet weak var content_message: UIButton!
    @IBOutlet weak var content_text: UILabel!
    
}
