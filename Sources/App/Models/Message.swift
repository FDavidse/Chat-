//
//  Message.swift
//  ChatServerProject
//
//  Created by Filip Davidse on 03-06-17.
//
//

import Vapor
import Fluent
import FluentProvider
import HTTP

final class Message: Model {
   
    var messagetext: String
    var author: Identifier?
    var chatuserid: Node?
    var chatgroupid: Node?
    
    let storage = Storage()

    
    init(messagetext: String, author: ChatUser, chatuserid: Node? = nil, chatgroupid: Node? = nil) throws {
        self.messagetext = messagetext
        self.author = author.id
        self.chatuserid = chatuserid
        self.chatgroupid = chatgroupid
        print("adding new message with id \(String(describing: self.id)), text: \(messagetext), tiluserid: \(String(describing: self.chatuserid)), chatgroup id: \(String(describing: self.chatgroupid))")
        
    }
    
    init(row: Row) throws {
        self.messagetext = try row.get("messagetext")
        self.author = try row.get(ChatUser.foreignIdKey)
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
    
    
    
//    static func addMessage(text: String, user: ChatUser?, group: Group?) throws -> Message {
//        
//        var newMessage = try Message(messagetext: text, chatuserid: user, chatgroupid: group)
//        try newMessage.save()
//        return newMessage
//    }
//    
    
    
}


extension Message: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            messagetext: json.get("messagetext"),
            author: json.get("chatuser"),
            chatuserid: json.get("chatuserid"),
            chatgroupid: json.get("chatgroupid")
        )

    }
    
}


extension Message: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("messagetext", messagetext)
        try json.set("chatuserid", chatuserid)
        try json.set("chatgroupid", chatgroupid)
        
        return json
    }
}

extension Message: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("messagetext", messagetext)
        try node.set(ChatUser.foreignIdKey, author)
        try node.set("chatuserid", chatuserid)
        try node.set("chatgroupid", chatgroupid)
        
        return node
    }
}


extension Message: RowRepresentable {
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("messagetext", messagetext)
        try row.set(ChatUser.foreignIdKey, author)
        try row.set("chatuserid", chatuserid)
        try row.set("chatgroupid", chatgroupid)

        return row
    }
}

extension Message: Parameterizable { }


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

extension Message {

    func allMessages() throws -> [Message] {
        let messages = try Message.all()
        return messages
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

