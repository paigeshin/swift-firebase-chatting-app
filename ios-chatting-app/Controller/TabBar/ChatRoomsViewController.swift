//
//  ChatRoomsViewController.swift
//  ios-chatting-app
//
//  Created by shin seunghyun on 2020/03/05.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import UIKit
import Firebase
import SnapKit

class ChatRoomsViewController: UIViewController {

    var uid: String!
    var chatrooms: [ChatModel]! = []
    var destionationUsers: [String] = [] //Destionation User들을 담은 어레이
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        uid = Auth.auth().currentUser?.uid
        getChatroomsList()
        
        
    }
    
    func getChatroomsList(){
        
        Database.database().reference().child("chatrooms").queryOrdered(byChild: "users/"+uid).queryEqual(toValue: true).observeSingleEvent(of: DataEventType.value) { (snapshot) in
            
            self.chatrooms.removeAll()
            
            for item in snapshot.children.allObjects as! [DataSnapshot] {
                if let chatroomic = item.value as? [String:AnyObject]{
                    let chatModel = ChatModel(JSON: chatroomic)
                    self.chatrooms.append(chatModel!)
                }
            }
            
            self.tableView.reloadData()
        }
        
    }
    
}

extension ChatRoomsViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatrooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RowCell", for: indexPath) as! CustomCell
        
        var destionationUid : String?
        
        //상대방 uid를 찾음
        for item in chatrooms[indexPath.row].users {
            
            if item.key != self.uid {
                destionationUid = item.key
                destionationUsers.append(destionationUid!)
            }

        }
   
        //상대방 uid를 찾아서 정보를 가져옴
        Database.database().reference().child("users").child(destionationUid!).observeSingleEvent(of: DataEventType.value) { (snapshot) in
            
            let userModel = UserModel()
            let fChild = snapshot
            let dictionary = fChild.value as! [String : Any]
            userModel.profileImageUrl = dictionary[K.Firebase.UserDatabase.profileImageURL] as? String
            userModel.userName = dictionary[K.Firebase.UserDatabase.name] as? String
            userModel.uid = dictionary[K.Firebase.UserDatabase.uid] as? String
            
            
            cell.labelTitle.text = userModel.userName
            let url = URL(string: userModel.profileImageUrl!)
            
            cell.imageView?.snp.makeConstraints({ (make) in
                make.width.height.equalTo(50)
            })
            
            URLSession.shared.dataTask(with: url!) { (data, response, error) in
                DispatchQueue.main.sync {
                    cell.imageView!.image = UIImage(data: data!)
                    cell.imageView!.layer.cornerRadius = (cell.imageView?.frame.width)! / 2
                    cell.imageView!.layer.masksToBounds = true
                }
            }.resume()
            
            let lastMessageKey = self.chatrooms[indexPath.row].comments.keys.sorted(){$0 > $1} //sorting 오름차순으로 가져옴
            cell.labelLastMessage.text = self.chatrooms[indexPath.row].comments[lastMessageKey[0]]?.message //0번이 가장 최근 메시지임. (채팅방 last message)
            let unixTime = self.chatrooms[indexPath.row].comments[lastMessageKey[0]]?.timestamp //Comment 내부에 timestamp가 있음
            cell.labelTimestamp.text = unixTime?.toDayTime
            
        }
        
        //ChatRoomViewController imageview
        
        return cell
    }
 
    override func viewDidDisappear(_ animated: Bool) {
        viewDidLoad()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let destionationUid = destionationUsers[indexPath.row]
        let view = self.storyboard?.instantiateViewController(identifier: "ChatViewController") as! ChatViewController
        view.destinationUid = destionationUid
        self.navigationController?.pushViewController(view, animated: true)
    }
    
}

class CustomCell: UITableViewCell {

    @IBOutlet weak var labelLastMessage: UILabel!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var labelTimestamp: UILabel!
    
}

