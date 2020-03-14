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

    var users: [String: AnyObject]? //유저 정보를 담음.  Key - UserInfo 이런 식으로 담겨져 있음.
    
    var peopleCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        tableView.delegate = self
        tableView.dataSource = self
        
        
        uid = Auth.auth().currentUser?.uid

        //유저 몇명있는지 확인 및 유저 정보 가져오기
        Database.database().reference().child("users").observeSingleEvent(of: DataEventType.value) { (snapshot) in
                
            self.users = snapshot.value as! [String : AnyObject] //Json 형태로 값을 담아줌.
            
            
        }
        
        buttonSend.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        getMessageList()
    }
    
    @objc func sendMessage(){
        
        let value: Dictionary<String, Any> = [
            "uid": uid!,
            "message": textFieldMessage.text!,
            "timestamp": ServerValue.timestamp(),
            "imageUrl": users![uid!]!["profileImageUrl"] as! String
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
                
                //유저의 커멘트들이 나의 uid를 가지고 있지 않다면 업데이트 시켜줌
                if !((self.comments.last?.readUsers.keys.contains(self.uid!))!) {
                  
                    snapshot.ref.updateChildValues(nsDic as! [AnyHashable : Any], withCompletionBlock: {(error, reference) in
                        
                        print("Updated Value : \(reference)")
                        
                        self.tableView.reloadData()
                        
                        if self.comments.count > 0 {
                            self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                        }
                    })
                } else {
                    

                    self.tableView.reloadData()
                    
                    if self.comments.count > 0 {
                        self.tableView.scrollToRow(at: IndexPath(item: self.comments.count - 1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                    }
                    
                }
                
            }

        })
        
        
        
    }
    
    func setReadCount(label: UILabel?, position: Int?){
        let readCounter = self.comments[position!].readUsers.count //db에서 불러온 값
        
        //People count가 nil일 때만 값을 불러옴. - 서버 과부하를 막아줌. (읽은 사람)
        if(peopleCount == nil){
            
            Database.database().reference().child("chatrooms").child(destinationRoom!).child("users").observeSingleEvent(of: DataEventType.value, with: {(snapshot) in
                
                let dictionary = snapshot.value as! [String: Any]
                self.peopleCount = dictionary.count
                let noReadCount = self.peopleCount! - readCounter //전체 db dictionary count - db에서 불러온 값의 유저 count
                
                if(noReadCount > 0){
                    label?.isHidden = false
                    label!.text = String(noReadCount)
                } else {
                    label?.isHidden = true
                }
                
            })
            
            //People count가 nil이 아니면 그냥 연산만 해준다.
        } else {
            
            let noReadCount = peopleCount! - readCounter //전체 db dictionary count - db에서 불러온 값의 유저 count
            
            if(noReadCount > 0){
                label?.isHidden = false
                label!.text = String(noReadCount)
            } else {
                label?.isHidden = true
            }
            
        }
        
    }
    
}

extension ChatGroupViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //말풍선 적용
        if self.comments[indexPath.row].uid == uid {
            let view = tableView.dequeueReusableCell(withIdentifier: "MyMessageCell", for: indexPath) as! MyMessageCell
            view.labelMessage!.text = self.comments[indexPath.row].message
            view.labelMessage.numberOfLines = 0 //여러줄로 나눠줄 수 있음
            
            if let time: Int = self.comments[indexPath.row].timestamp {
                print(time)
                view.myTimestamp.text = time.toDayTime
            }
            
            setReadCount(label: view.labelReadCounter, position: indexPath.row)
            
            return view
        } else {
            let destinationUser = users![self.comments[indexPath.row].uid!] //유저 정보 가져오기 위해서 각각 comment에 달려있는 uid를 가져옴. 밑에는 여러 value들이 달려있다. ex) profileImageUrl
            let view = tableView.dequeueReusableCell(withIdentifier: "DestinationMessageCell", for: indexPath) as! DestinationMessageCell
            view.labelName.text = destinationUser!["name"] as! String
            view.labelMessage.text = self.comments[indexPath.row].message
            view.labelMessage.numberOfLines = 0 //여러줄로 나눠줄 수 있음
            
            if let time: Int = self.comments[indexPath.row].timestamp {
                view.destinationTimestamp.text = time.toDayTime
            }
            
            let imageUrl = self.comments[indexPath.row].imageUrl
            let url = URL(string: imageUrl!)
            
            URLSession.shared.dataTask(with: url!, completionHandler: {(data, response, error) in
                DispatchQueue.main.async {
                    if let imageData = data {
                        view.imageViewProfile!.image = UIImage(data: imageData)
                    }
                    
                    view.imageViewProfile?.layer.cornerRadius = view.imageViewProfile.frame.width / 2
                    view.imageViewProfile.clipsToBounds = true
                }
            }).resume()
            
            setReadCount(label: view.destinationLabelReadCounter, position: indexPath.row)
            
            return view
        }

        
    }




}

