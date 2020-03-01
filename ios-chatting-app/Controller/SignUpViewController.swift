//
//  SignUpViewController.swift
//  ios-chatting-app
//
//  Created by shin seunghyun on 2020/03/01.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import UIKit
import Firebase
import TextFieldEffects
import FirebaseAuth

class SignUpViewController: UIViewController {
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var nameTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (make) in
            make.right.top.left.equalTo(view)
            make.height.equalTo(20)
        }
        
        //Remote Config를 이용해서 테마 변경
        color = remoteConfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color)
        signUpButton.backgroundColor = UIColor(hex: color)
        cancelButton.backgroundColor = UIColor(hex: color)

        
    }
    
    @IBAction func registerButtonPressed(_ sender: UIButton) {
        
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!){(user, error) in
            let uid = user?.user.uid
            Database.database().reference().child("users").child(uid!).setValue([
                    "name": self.nameTextField.text!
                ])
        }
        
    }
    

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
