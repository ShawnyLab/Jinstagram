//
//  ProfileEditViewController.swift
//  Jinstagram
//
//  Created by 박진서 on 2021/02/23.
//

import UIKit
import Firebase

class ProfileEditViewController: UIViewController {
    
    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    var userModel = UserModel()
    
    var topVC: UIViewController?

    @IBOutlet weak var name_Btn: UIButton!
    @IBOutlet weak var userId_Btn: UIButton!
    @IBOutlet weak var profileText_Btn: UIButton!
    @IBOutlet weak var profile_image: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profile_image.layer.cornerRadius = profile_image.frame.size.width / 2
        let name = NSAttributedString(string: "\(userModel.name!)")
        name_Btn.setAttributedTitle(name, for: .normal)
        let id = NSAttributedString(string: "\(userModel.id!)")
        userId_Btn.setAttributedTitle(id, for: .normal)
        
        if userModel.profileText != nil {
            let profileText = NSAttributedString(string: "\(userModel.profileText!)")
            profileText_Btn.setAttributedTitle(profileText, for: .normal)
        } else {
            let profileText = NSAttributedString(string: "")
            profileText_Btn.setAttributedTitle(profileText, for: .normal)
        }
    }
    
    @IBAction func name_Clicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(identifier: "NameEditViewController") as! NameEditViewController
        VC.modalPresentationStyle = .fullScreen
        VC.userModel = self.userModel
        VC.topVC = self
        self.present(VC, animated: true, completion: nil)
    }
    
    @IBAction func userId_Clicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(identifier: "IdEditViewController") as! IdEditViewController
        VC.modalPresentationStyle = .fullScreen
        VC.userModel = self.userModel
        VC.topVC = self
        self.present(VC, animated: true, completion: nil)
    }
    
    @IBAction func profileText_Clicked(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(identifier: "TextEditViewController") as! TextEditViewController
        VC.modalPresentationStyle = .fullScreen
        VC.userModel = self.userModel
        VC.topVC = self
        self.present(VC, animated: true, completion: nil)
    }
    
    @IBAction func done_Clicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel_Clicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
