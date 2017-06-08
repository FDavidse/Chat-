//
//  Message.swift
//  ChatServerProject
//
//  Created by Filip Davidse on 03-06-17.
//
//

import Vapor
import FluentProvider
import HTTP

final class Message: Model {
   
    var username: String? = nil //doesn't go in the database
    var messagetext: String
    var chatuserid: Node?
    var chatgroupid: Node?
    
    let storage = Storage()

    
    init(messagetext: String, chatuserid: Node? = nil, chatgroupid: Node? = nil) throws {
        self.messagetext = messagetext
        self.chatuserid = chatuserid
        self.chatgroupid = chatgroupid
        print("adding new message with id \(String(describing: self.id)), text: \(messagetext), tiluserid: \(String(describing: self.chatuserid)), chatgroup id: \(String(describing: self.chatgroupid))")
        
        self.username = "default"
    }
    
    init(row: Row) throws {
        self.messagetext = try row.get("messagetext")
        self.chatuserid = try row.get("chatuserid")
        self.chatgroupid = try row.get("chatgroupid")

    }

    
    init(messagetext: String) throws {
        self.messagetext = messagetext
    }
    
    init(node: Node) throws {
        self.messagetext = try node.get("messagetext")
        self.chatuserid = try node.get("tiluser_id")
        self.chatgroupid = try node.get("chatgroupid")
        
    }
    
    func makeNode(in context: Context) throws -> Node {
        var node = Node(context)
        try node.set("messagetext", messagetext)
        try node.set("chatuserid", chatuserid)
        try node.set("chatgroupid", chatgroupid)

        return node
    }
    
    
    static func addMessage(text: String, user: ChatUser?, group: Group?) throws -> Message {
        var newMessage = try Message(messagetext: text, tiluserId: user?.id, chatgroupid: group?.id)
        try newMessage.save()
        return newMessage
    }
    
    
    
}


extension Message: RowRepresentable {
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("messagetext", messagetext)
        try row.set("chatuserid", chatuserid)
        try row.set("chatgroupid", chatgroupid)

        return row
    }
}

extension Message: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (group) in
            group.id()
            group.string("messagetext")
            group.string("chatuserid")
            group.string("chatgroupid")

        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


//extension Message {
//    func group() throws -> Group? {
//        return try parent(chatgroupid, nil, Message.self).get()
//    }
//    
//    func tiluser() throws -> ChatUser? {
//        return try parent(tiluserId, nil, TILUser.self).get()
//    }
//    
//}

