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

/*
 "//": "The underlying database technology to use.",
 "//": "memory: SQLite in-memory DB.",
 "//": "sqlite: Persisted SQLite DB (configure with sqlite.json)",
 "//": "Other drivers are available through Vapor providers",
 "//": "https://github.com/search?q=topic:vapor-provider+topic:database",
 //"driver": "memory",
*/



final class Group: Model {
    

    var name: String
    let storage = Storage()
    
    init(name: String) {
        self.name = name
    }
    
    init(row: Row) throws {
        self.name = try row.get("name")
    }
    
    init(node: Node) throws {
        self.name = try node.get("name")
    }

    
    func makeNode(in context: Context) throws -> Node {
        var node = Node(context)
        try node.set("name", name)
        
        return node
    }

    
    static func addGroup(name: String) throws -> Group {
        let newGroup = try Group(name: name)
        try newGroup.save()
        return newGroup
        
    }
    
}

//extension Group: NodeInitializable {
//    convenience init(node: Node) throws {
//        self.name = try node.get("name")
//    }
//}


//extension Group: NodeRepresentable {
//    func makeNode(in context: Context) throws -> Node {
//        var node = Node(context)
//        try node.set("name", name)
//
//        return node
//    }
//}

extension Group: RowRepresentable {
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        return row
    }
}

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


//extension Group {
//    func tilusers() throws -> [TILUser] {
//        let tilusers: Siblings<TILUser> = try siblings()
//        return try tilusers.all()
//    }
//    
//    func messagesFor(group: Group?) throws -> [Message] {
//        let messages = try Message.all()
//        
//        var messagesForGroup : [Message] = []
//        for message in messages {
//            if try message.group()?.id == group?.id {
//                messagesForGroup.append(message)
//            }
//        }
//        
//        return messagesForGroup
//        
//    }
//}
