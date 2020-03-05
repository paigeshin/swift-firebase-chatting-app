//
//  ChatModel.swift
//  ios-chatting-app
//
//  Created by shin seunghyun on 2020/03/04.
//  Copyright © 2020 shin seunghyun. All rights reserved.
//

import ObjectMapper //json mapping

import Foundation


class ChatModel: Mappable {
    
    public var users: Dictionary<String, Bool> = [:] //채팅방에 참여한 사람들
    public var comments: Dictionary<String, Comment> = [:] //채팅방의 대화내용
    
    required init?(map: Map){}
    
    func mapping(map: Map){
        users <- map["users"]
        comments <- map["comments"]
    }
    
    public class Comment : Mappable {
        public var uid: String?
        public var message: String?
        
        required init?(map: Map){}
        
        func mapping(map: Map){
            uid <- map["uid"]
            message <- map["message"]
        }
        
    }
    
}
