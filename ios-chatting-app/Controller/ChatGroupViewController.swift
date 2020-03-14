//
//  ChatGroupViewController.swift
//  ios-chatting-app
//
//  Created by shin seunghyun on 2020/03/14.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import UIKit
import Firebase

class ChatGroupViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().reference().child("users").observeSingleEvent(of: DataEventType.value) { (snapshot) in
            
            
            let dictionary = snapshot.value as! [String : AnyObject]
            print(dictionary.count)
            
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
