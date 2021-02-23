//
//  SignUpViewController.swift
//  Jinstagram
//
//  Created by 박진서 on 2021/02/21.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var id: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()


    }
    
    @IBAction func signup_Btn(_ sender: Any) {
        Auth.auth().createUser(withEmail: email.text!, password: password.text!) { (User, error) in
            let uid = User?.user.uid
            
            Database.database().reference().child("Users").child(uid!).setValue(["uid" : uid! , "name" : "이름", "id" : self.id.text!, "email" : self.email.text!, "followers" : 0, "followings" : 0])
        }
    }
    
    @IBAction func cancel_Btn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
