//
//  ChatUser.swift
//  ChatServerProject
//
//  Created by Filip Davidse on 03-06-17.
//
//

import Vapor
import FluentProvider
import HTTP

final class ChatUser: Model {
    
    let storage = Storage()

    var name: String
    var email: String
    var password: String
    
    init(name: String, email: String, rawPassword: String) throws {
        self.name = name
        self.email = email
        self.password = rawPassword
    }
    
    init(node: Node) throws {
        self.name = try node.get("name")
        self.email = try node.get("email")
        self.password = try node.get("password")

    }
    
    init(row: Row) throws {
        self.name = try row.get("name")
        self.email = try row.get("email")
        self.password = try row.get("password")

    }
    
    func makeNode(context: Context) throws -> Node {
        var node = Node(context)
        try node.set("name", name)
        try node.set("email", email)
        try node.set("password", password)

        return node

    }
    
    static func prepare(_ database: Database) throws {
        try database.create("tilusers") { users in
            users.id()
            users.string("name")
            users.string("email")
            users.string("password")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete("tilusers")
    }
    
    static func register(name: String, email: String, rawPassword: String) throws -> TILUser {
        var newUser = try TILUser(name: name, email: email, rawPassword: rawPassword)
        if try TILUser.query().filter("email", newUser.email.value).first() == nil {
            try newUser.save()
            return newUser
        } else {
            throw AccountTakenError()
        }
    }
    
}

extension TILUser {
    func acronyms() throws -> [Acronym] {
        return try children(nil, Acronym.self).all()
    }
    
    func groups() throws -> [Group] {
        let groups: Siblings<Group> = try siblings()
        return try groups.all()
    }
    
    func messages() throws -> [Message] {
        return try children(nil, Message.self).all()
    }
    
    
}

extension TILUser: Authenticator {
    
    static func authenticate(credentials: Credentials) throws -> User {
        var user: TILUser?
        
        switch credentials {
        case let credentials as UsernamePassword:
            let fetchedUser = try TILUser.query()
                .filter("email", credentials.username)
                .first()
            if let password = fetchedUser?.password,
                password != "",
                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
                user = fetchedUser
            }
        case let credentials as Identifier:
            user = try TILUser.find(credentials.id)
        default:
            throw UnsupportedCredentialsError()
        }
        
        if let user = user {
            return user
        } else {
            throw IncorrectCredentialsError()
        }
        
    }
    
    static func register(credentials: Credentials) throws -> User {
        throw Abort.badRequest
    }
    
    
}


