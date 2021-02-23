//
//  TextEditViewController.swift
//  Jinstagram
//
//  Created by 박진서 on 2021/02/23.
//

import UIKit
import Firebase

class TextEditViewController: UIViewController {

    var userModel = UserModel()
    var topVC: UIViewController?
    
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference()
    
    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.text = userModel.profileText
    }
    
    @IBAction func done_Clicked(_ sender: Any) {
        ref.child("Users").child(uid!).child("profileText").setValue(textField.text)
        userModel.profileText = textField.text
        let profileVC = topVC as! ProfileEditViewController
        let text = NSAttributedString(string: "\(userModel.profileText!)")
        profileVC.profileText_Btn.setAttributedTitle(text, for: .normal)
        profileVC.userModel = userModel
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancel_Clicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
