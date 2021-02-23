//
//  IdEditViewController.swift
//  Jinstagram
//
//  Created by 박진서 on 2021/02/23.
//

import UIKit
import Firebase

class IdEditViewController: UIViewController {

    var userModel = UserModel()
    var topVC: UIViewController?
    
    let uid = Auth.auth().currentUser?.uid
    let ref = Database.database().reference()
    
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.text = userModel.id
        desLabel.text = "대부분의 경우 이후 14일 동안 사용자 이름을 다시 \n \(String(describing: userModel.id!))(으)로 변경할 수 있습니다."
    }
    
    @IBAction func done_Clicked(_ sender: Any) {
        
        if textField.text == nil {
            return
        } else {
            ref.child("Users").child(uid!).child("id").setValue(textField.text)
            userModel.id = textField.text
            let profileVC = topVC as! ProfileEditViewController
            let id = NSAttributedString(string: "\(userModel.id!)")
            profileVC.userId_Btn.setAttributedTitle(id, for: .normal)
            profileVC.userModel = userModel
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel_Clicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}
