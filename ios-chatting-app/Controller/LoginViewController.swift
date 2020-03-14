//
//  LoginViewController.swift
//  ios-chatting-app
//
//  Created by shin seunghyun on 2020/03/01.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import TextFieldEffects
import FirebaseRemoteConfig

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (make) in
            make.right.top.left.equalTo(view)
            if(UIScreen.main.nativeBounds.height == 236) {
                make.height.equalTo(40)
            } else {
                make.height.equalTo(20)
            }
            make.height.equalTo(20)
        }
        
        //Remote Config를 이용해서 테마 변경
        color = remoteConfig["splash_background"].stringValue
        statusBar.backgroundColor = UIColor(hex: color)
        loginButton.backgroundColor = UIColor(hex: color)
        signInButton.backgroundColor = UIColor(hex: color)
        
//        try! Auth.auth().signOut()
        
        //Login Success
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                let view = self.storyboard?.instantiateViewController(identifier: "MainViewTabBarController") as! UITabBarController
                self.present(view, animated: true, completion: nil)
                //token 받아오는 코드 작성
                let uid = Auth.auth().currentUser?.uid

                if let token = Messaging.messaging().fcmToken {
                    Database.database().reference().child("users").child(uid!).updateChildValues(["pushToken": token])
                }
                
                
            }
        }
    }
    

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (result, error) in
            if error != nil {
                let alert = UIAlertController(title: "Error", message: error.debugDescription, preferredStyle: .alert)
                let action = UIAlertAction(title: "확인", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
        }
        
    }
    
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        let view = self.storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        self.present(view, animated: true, completion: nil)
    }
    
}
