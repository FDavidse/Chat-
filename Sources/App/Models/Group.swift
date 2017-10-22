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
import FluentProvider
import VaporValidation
import PostgreSQLProvider


final class Group: Model {
    

    var name: String
    let storage = Storage()
    var id: Identifier?
    
    init(name: String) {
        self.name = name
    }
    
    init(row: Row) throws {
        self.name = try row.get("name")
    }
    
    init(node: Node) throws {
        self.name = try node.get("name")
    }

   static func addGroup(name: String) throws -> Group {
        let newGroup = Group(name: name)
        try newGroup.save()
        return newGroup
        
    }
    
    static func groupFor(name : String) throws -> Group {
        let groups = try Group.makeQuery().filter("name", .equals, name)
        
        let group = try groups.first()
        
        if let foundGroup = group {
            return foundGroup
        } else {
            throw Abort.badRequest
        }
    }

    
}

//extension Group: NodeInitializable {
//    convenience init(node: Node) throws {
//        self.name = try node.get("name")
//    }
//}


extension Group: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("name", name)
        return node
    }
}

extension Group: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        return json
    }
}

extension Group: ResponseRepresentable {
    
}

extension Group: RowRepresentable {
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        return row
    }
}

extension Group: Parameterizable { }


extension Group: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (group) in
            group.id()
            group.string("name")
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}


extension Group {
    var users: Siblings<Group, ChatUser, Pivot<Group, ChatUser>> {
        return siblings()
    }
}

extension Group {

    var messages: Children<Group, Message> {
        
        return children()

    }

}

