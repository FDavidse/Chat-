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
    let groupId: Identifier
    let userId: Identifier
    let storage = Storage()
    var username: String = ""
    
    init(messagetext: String, groupId: Identifier, userId: Identifier) throws {
        self.messagetext = messagetext
        self.groupId = groupId
        self.userId = userId
    }
    
    init(row: Row) throws {
        self.messagetext = try row.get("messagetext")
        self.groupId = try row.get("group_id")
        self.userId = try row.get("user_id")

    }
    
    init(node: Node) throws {
        self.messagetext = try node.get("messagetext")
        self.groupId = try node.get("group_id")
        self.userId = try node.get("user_id")

    }
    
    
    
    static func addMessage(text: String, group: Group?, user: ChatUser?) throws -> Message {
        
        let newMessage = try Message(messagetext: text, groupId: (group?.id)!, userId: (user?.id)!)
        try newMessage.save()
        return newMessage
    }
    
    
    
}


extension Message: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            messagetext: json.get("messagetext"),
            groupId: json.get("group_id"),
            userId: json.get("user_id")
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

        return json
    }
}

extension Message: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("messagetext", messagetext)
        try node.set("group_id", groupId)
        try node.set("user_id", userId)
        try node.set("username", username)
        
        return node
    }
}


extension Message: RowRepresentable {
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("messagetext", messagetext)
        try row.set("group_id", groupId)
        try row.set("user_id", userId)
        try row.set("username", username)

        return row
    }
}

extension Message: Parameterizable { }


extension Message: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (group) in
            group.id()
            group.string("messagetext")
            group.foreignKey("group_id", references: "id", on: Group.self)
            group.foreignKey("user_id", references: "id", on: ChatUser.self)
            group.parent(Group.self)
            group.parent(ChatUser.self)
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

