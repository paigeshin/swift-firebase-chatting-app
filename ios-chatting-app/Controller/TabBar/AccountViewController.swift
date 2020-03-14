//
//  AccountViewController.swift
//  ios-chatting-app
//
//  Created by shin seunghyun on 2020/03/14.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import UIKit
import Firebase

class AccountViewController: UIViewController {

    @IBOutlet var conditionsCommentButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        conditionsCommentButton.addTarget(self, action: #selector(showAlert), for: .touchUpInside)
        
    }
    
    @objc func showAlert(){
        
        let alertController = UIAlertController(title: "상태 메세지", message: nil, preferredStyle: UIAlertController.Style.alert)
        alertController.addTextField { (textfield) in
            textfield.placeholder = "상태메세지를 입력해주세요"
        }
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let textfield = alertController.textFields?.first {
                let dic = ["comment":textfield.text!]
                let uid = Auth.auth().currentUser?.uid
                Database.database().reference().child("users").child(uid!).updateChildValues(dic)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "취소", style: .cancel, handler: { (action) in
            

            
        }))
        present(alertController, animated: true, completion: nil)
    }



}
