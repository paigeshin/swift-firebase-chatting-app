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

    var destinationRoom: String?
    var uid: String?
    @IBOutlet weak var textFieldMessage: UITextField!
    @IBOutlet weak var buttonSend: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uid = Auth.auth().currentUser?.uid
//        tableView.delegate = self
//        tableView.dataSource = self
        
        Database.database().reference().child("users").observeSingleEvent(of: DataEventType.value) { (snapshot) in
                
            let dictionary = snapshot.value as! [String : AnyObject]
            print(dictionary.count)
            
        }
        
        buttonSend.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
    }
    
    @objc func sendMessage(){
        
        let value: Dictionary<String, Any> = [
            "uid": uid!,
            "message": textFieldMessage.text!,
            "timestamp": ServerValue.timestamp()
        ]
        
        Database.database().reference().child("chatrooms").child(destinationRoom!).child("comments").childByAutoId().setValue(value){(error, ref) in
            self.textFieldMessage!.text = ""
        }
        
    }
    
}

//extension ChatGroupViewController : UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        <#code#>
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        <#code#>
//    }
//
//
//
//
//}
