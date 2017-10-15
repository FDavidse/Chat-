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
    let storage = Storage()

    
    init(messagetext: String, groupId: Identifier) throws {
        self.messagetext = messagetext
        self.groupId = groupId
        
    }
    
    init(row: Row) throws {
        self.messagetext = try row.get("messagetext")
        self.groupId = try row.get("group_id")
        

    }

    
//    init(messagetext: String) throws {
//        self.messagetext = messagetext
//    }
    
    init(node: Node) throws {
        self.messagetext = try node.get("messagetext")
        self.groupId = try node.get("group_id")
        
    }
    
    
    
    static func addMessage(text: String, group: Group?) throws -> Message {
        
        let newMessage = try Message(messagetext: text, groupId: (group?.id)!)
        try newMessage.save()
        return newMessage
    }
    
    
    
}


extension Message: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            messagetext: json.get("messagetext"),
            groupId: json.get("group_id")
        )

    }
    
}


extension Message: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("messagetext", messagetext)
        try json.set("group_id", groupId)
        
        return json
    }
}

extension Message: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("messagetext", messagetext)
        try node.set("group_id", groupId)
        return node
    }
}


extension Message: RowRepresentable {
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("messagetext", messagetext)
        try row.set("group_id", groupId)
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
            group.parent(Group.self)
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
    
//    func group() throws -> Group? {
//        return try parent(chatgroupid, nil, Message.self).get()
//    }
    
//    func tiluser() throws -> ChatUser? {
//        return try parent(tiluserId, nil, TILUser.self).get()
//    }
    
}

