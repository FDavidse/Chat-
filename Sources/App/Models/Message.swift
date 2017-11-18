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
import Foundation

final class Message: Model {
   
    var messagetext: String
    let groupId: Identifier
    let userId: Identifier
    let storage = Storage()
    var username: String = ""
    var created: Date
    
    init(messagetext: String, groupId: Identifier, userId: Identifier, username: String, creationDate: Date) throws {
        self.messagetext = messagetext
        self.groupId = groupId
        self.userId = userId
        self.username = username
        self.created = creationDate
    }
    
    init(row: Row) throws {
        self.messagetext = try row.get("messagetext")
        self.groupId = try row.get("group_id")
        self.userId = try row.get("user_id")
        self.username = try row.get("username")

        let createdTime: Double = try row.get("created")
        self.created = Date(timeIntervalSince1970: createdTime)
        
    }
    
    init(node: Node) throws {
        self.messagetext = try node.get("messagetext")
        self.groupId = try node.get("group_id")
        self.userId = try node.get("user_id")
        self.username = try node.get("username")
        self.created = try node.get("created")

    }
    
    
    
    static func addMessage(text: String, group: Group?, user: ChatUser?, userName: String, date:Date) throws -> Message {

        let newMessage = try Message(messagetext: text, groupId: (group?.id)!, userId: (user?.id)!, username: userName, creationDate: date)
        try newMessage.save()
        return newMessage
    }
    
    
    
}


extension Message: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            messagetext: json.get("messagetext"),
            groupId: json.get("group_id"),
            userId: json.get("user_id"),
            username: json.get("username"),
            creationDate: json.get("created")
        )

    }
    
}


extension Message: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("messagetext", messagetext)
        try json.set("group_id", groupId)
        try json.set("user_id", userId)
        try json.set("username", username)
        try json.set("created", created)

        return json
    }
}

extension Message: ResponseRepresentable { }

extension Message: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("messagetext", messagetext)
        try node.set("group_id", groupId)
        try node.set("user_id", userId)
        try node.set("username", username)
        
        let dateFormatter = DateFormatter()
//        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .full
        let createdDate = dateFormatter.string(from: created)
        try node.set("created", createdDate)
       
        return node
    }
}


extension Message: RowRepresentable {
    func makeRow() throws -> Row {
        let createdTime = created.timeIntervalSince1970
        
        var row = Row()
        try row.set("messagetext", messagetext)
        try row.set("group_id", groupId)
        try row.set("user_id", userId)
        try row.set("username", username)
        try row.set("created", createdTime)

        return row
    }
}

extension Message: Parameterizable { }


extension Message: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (group) in
            group.id()
            group.string("messagetext")
            group.string("username")
            group.foreignKey("group_id", references: "id", on: Group.self)
            group.foreignKey("user_id", references: "id", on: ChatUser.self)
            group.parent(Group.self)
            group.parent(ChatUser.self)
            group.double("created")
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


extension Message {
    

    var owner: Parent<Message, Group> {
        return parent(id: groupId)
    }
    

    var author: Parent<Message, ChatUser> {
        return parent(id: userId)
    }
    
}

