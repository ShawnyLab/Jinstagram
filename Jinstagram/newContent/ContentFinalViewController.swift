//
//  ContentFinalViewController.swift
//  Jinstagram
//
//  Created by 박진서 on 2021/02/22.
//

import UIKit
import Firebase

class ContentFinalViewController: UIViewController {
    
    var beforeVC: UIViewController?
    var mainVC: UIViewController?
    var myInfo = UserModel()
    
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference().child("Users")

    
    var image: UIImage?
    @IBOutlet weak var content_image: UIImageView!
    @IBOutlet weak var contentText: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        content_image.image = image
    }
    
    @IBAction func back_Btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func share_Btn(_ sender: Any) {
        let topVC = mainVC as! MainViewController
        
        
        //Firebase에 집어넣기
        let image = self.image?.jpegData(compressionQuality: 0.1)
        let Cuid = self.ref.child(self.uid!).child("MyContents").childByAutoId().key
        let imageRef = Storage.storage().reference().child("UserContents").child(uid!).child("Contents").child(Cuid!)
        imageRef.putData(image!, metadata: nil) { (StorageMetadata, Error) in
            imageRef.downloadURL { (url, error) in
                self.ref.child(self.uid!).child("MyContents").child(Cuid!).setValue(["uid": Cuid!, "ImageUrl": url?.absoluteString])
                self.ref.child(self.uid!).child("MyContents").child(Cuid!).child("ContentText").setValue(self.contentText.text)
                
            }
            
            //ContentModel 에 집어넣기
            
            let content = ContentModel()
            content.text = self.contentText.text
            content.contentUid = Cuid
            content.image = self.image
            content.owner = self.myInfo
            topVC.ContentModels.append(content)
            
            topVC.tableView.reloadData()
        }
        
        self.dismiss(animated: true, completion: nil)
        self.beforeVC?.dismiss(animated: true, completion: nil)
    }
    
}
