//
//  NameEditViewController.swift
//  Jinstagram
//
//  Created by 박진서 on 2021/02/23.
//

import UIKit
import Firebase

class NameEditViewController: UIViewController {

    var userModel = UserModel()
    var topVC: UIViewController?
    
    let ref = Database.database().reference()
    let uid = Auth.auth().currentUser?.uid
    
    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        textField.text = userModel.name
    }

    @IBAction func done_Clicked(_ sender: Any) {
        
        if textField.text == nil {
            //아무것도 안쳤을 때
            
            return
        } else {
            ref.child("Users").child(uid!).child("name").setValue(textField.text)
            userModel.name = textField.text
            let name = NSAttributedString(string: "\(textField.text!)")
            let profileVC = topVC as! ProfileEditViewController
            profileVC.name_Btn.setAttributedTitle(name, for: .normal)
            profileVC.userModel = userModel
            self.dismiss(animated: true, completion: nil)
        }

    }
    
    @IBAction func cancel_Clicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
