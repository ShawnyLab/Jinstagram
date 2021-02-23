//
//  ViewController.swift
//  Jinstagram
//
//  Created by 박진서 on 2021/02/19.
//

import UIKit
import Firebase

class ViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var password: UITextField!
    
    var VC: UIViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func signin_btn(_ sender: Any) {

        
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, error) in
            
            if user != nil {
                self.VC = self.storyboard?.instantiateViewController(identifier: "TabBarController") as! UITabBarController
                self.VC?.modalPresentationStyle = .fullScreen
                self.present(self.VC!, animated: true, completion: nil)
            }
        }

    }
    
    @IBAction func signup_btn(_ sender: Any) {
        let VC = self.storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        VC.modalPresentationStyle = .fullScreen
        
        self.present(VC, animated: true, completion: nil)
    }
    
    @IBAction func temp_btn(_ sender: Any) {
        Auth.auth().signIn(withEmail: "tomatosale7774@gmail.com", password: "qowo1gkrsus") { (user, error) in
            
        }
        VC = self.storyboard?.instantiateViewController(identifier: "TabBarController") as! UITabBarController
        VC?.modalPresentationStyle = .fullScreen
        self.present(VC!, animated: true, completion: nil)
    }
    
}

