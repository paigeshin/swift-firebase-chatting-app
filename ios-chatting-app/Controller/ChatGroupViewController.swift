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
    
    var databaseRef: DatabaseReference?
    var observe: UInt?
    var comments: [ChatModel.Comment] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.delegate = self
        tableView.dataSource = self
        
        let alert: UIAlertController = UIAlertController(title: "ChatGroupViewController", message: "Right", preferredStyle: .alert)
        let action: UIAlertAction = UIAlertAction(title: "ChatGroupViewController", style: .default, handler: nil)
        alert.addAction(action)
         present(alert, animated: true, completion: nil)
        
        uid = Auth.auth().currentUser?.uid

        Database.database().reference().child("users").observeSingleEvent(of: DataEventType.value) { (snapshot) in
                
            let dictionary = snapshot.value as! [String : AnyObject]
            print(dictionary.count)
            
        }
        
        buttonSend.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        getMessageList()
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
    
    func getMessageList() {
        
        databaseRef = Database.database().reference().child("chatrooms").child(self.destinationRoom!).child("comments")
        
        observe = databaseRef?.observe(DataEventType.value, with: { (snapshot) in
            self.comments.removeAll()
            
            var readUserDic: Dictionary<String, AnyObject> = [:]
            
            print("snapshot: \(snapshot)")
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                let key = item.key as String
                
                let comment = ChatModel.Comment(JSON: item.value as! [String : AnyObject]) //일단 값을 집어 넣을 comment
                let comment_modify = ChatModel.Comment(JSON: item.value as! [String : AnyObject]) //비교해줄 comment, 이 값을 토대로 update 시켜줌
                comment_modify?.readUsers[self.uid!] = true
                readUserDic[key] = comment_modify?.toJSON() as! NSDictionary //Firebase가 NSDictionary만 지원한다.
                print("readUserDic: \(readUserDic[key])" )
                self.comments.append(comment!)
            }
            
            if self.comments.count > 0 {
                let nsDic = readUserDic as NSDictionary
                
                //유저의 커멘트가 uid를 가지고 있다면 업데이트 시킨다. 예전에는 uid가 있던 없던간에 다 update 시켜버림
                snapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any], withCompletionBlock: {(error, reference) in
                    
                    print("Updated Value : \(reference)")
                    
                    self.tableView.reloadData()
                    
                    if self.comments.count > 0 {
                        self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                    }
                })
                
            }
            
            
            
            
        })
        
        
        
    }
    
}

extension ChatGroupViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
        cell.labelMessage.text = self.comments[indexPath.row].message
        cell.labelMessage.numberOfLines = 0
        
        if let time = self.comments[indexPath.row].timestamp {
            cell.myTimestamp.text = time.toDayTime
        }
        
        return cell
        
    }




}

