//
//  Group.swift
//  ChatServerProject
//
//  Created by Filip Davidse on 03-06-17.
//
//

import Vapor
import Fluent
import HTTP
import VaporValidation
import PostgreSQLProvider




final class Group: Model {
    
    var exists: Bool = false
    var id: Node?
    var name: Valid<NameValidator>
    
    
    init(name: String) throws {
        self.name = try name.validated()
    }
    
    init(node: Node, in context: Context) throws {
        id = node["id"]
        let nameString = try node.extract("name") as String
        name = try nameString.validated()
    }
    
    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            "id": id,
            "name": name.value,
            ])
    }
    
    static func addGroup(name: String) throws -> Group {
        var newGroup = try Group(name: name)
        try newGroup.save()
        return newGroup
        
    }
    
    static func prepare(_ database: Database) throws {
        try database.create("groups") { users in
            users.id()
            users.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("groups")
    }
    
    /// Initializes the Post from the
    /// database row
    init(row: Row) throws {
        name = try row.get("content")
    }

    
    // Serializes the Post to the database
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("content", content)
        return row
    }

}

extension Group {
    func tilusers() throws -> [TILUser] {
        let tilusers: Siblings<TILUser> = try siblings()
        return try tilusers.all()
    }
    
    func messagesFor(group: Group?) throws -> [Message] {
        let messages = try Message.all()
        
        var messagesForGroup : [Message] = []
        for message in messages {
            if try message.group()?.id == group?.id {
                messagesForGroup.append(message)
            }
        }
        
        return messagesForGroup
        
    }
}
