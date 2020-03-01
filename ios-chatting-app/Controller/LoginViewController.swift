//
//  LoginViewController.swift
//  ios-chatting-app
//
//  Created by shin seunghyun on 2020/03/01.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signInButton: UIButton!
    
    let remoteConfig = RemoteConfig.remoteConfig()
    var color: String!
    
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
        loginButton.backgroundColor = UIColor(hex: color)
        signInButton.backgroundColor = UIColor(hex: color)

        // Do any additional setup after loading the view.
    }
    

    @IBAction func loginButtonPressed(_ sender: UIButton) {
        
    }
    
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        let view = self.storyboard?.instantiateViewController(identifier: "SignUpViewController") as! SignUpViewController
        self.present(view, animated: true, completion: nil)
    }
    
}
