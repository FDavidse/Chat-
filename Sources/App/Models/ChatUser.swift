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
import VaporValidation
import Validation
import AuthProvider
import BCrypt
import Node

 
final class ChatUser: Model {
    
    
    let storage = Storage()

    var name: String
    var username: String
    var email: String
    var password: String
    
    init(name: String, username: String, email: String, rawPassword: String) throws {
        self.name = name
        self.username = username
        self.email = email
        self.password = rawPassword
    }
    
    init(node: Node) throws {
        self.name = try node.get("name")
        self.username = try node.get("username")
        self.email = try node.get("email")
        self.password = try node.get("password")

    }
    
    init(row: Row) throws {
        self.name = try row.get("name")
        self.username = try row.get("username")
        self.email = try row.get("email")
        self.password = try row.get("password")

    }
    
    
    
    static func register(name: String, username: String, email: String, rawPassword: String) throws -> ChatUser {
        var newUser = try ChatUser(name: name, username: username, email: email, rawPassword: rawPassword)
        if try ChatUser.makeQuery().filter("email", newUser.email).first() == nil {
            try newUser.save()
            return newUser
        } else {
//            throw Error, wrong error here
            throw AuthenticationError.invalidCredentials
        }
    }
    
}


extension ChatUser: NodeRepresentable {
    func makeNode(in context: Context?) throws -> Node {
        var node = Node(context)
        try node.set("name", name)
        try node.set("username", username)
        try node.set("email", email)
        try node.set("password", password)
        
        return node
    }
}



extension ChatUser: RowRepresentable {
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        try row.set("username", username)
        try row.set("email", email)
        try row.set("password", password)

        return row
    }
}

extension ChatUser: Parameterizable { }





// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension ChatUser: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(
            name: json.get("name"),
            username: json.get("username"),
            email: json.get("email"),
            rawPassword: json.get("password")

        )
    }
    
}


extension ChatUser: JSONRepresentable {
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        try json.set("username", username)
        try json.set("email", email)
        try json.set("password", password)
        
        return json
    }
}

extension ChatUser: ResponseRepresentable {
    
}

// MARK: HTTP

// This allows Post models to be returned
// directly in route closures


extension ChatUser: SessionPersistable {}

extension ChatUser: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (groups) in
            groups.id()
            groups.string("name")
            groups.string("username")
            groups.string("email")
            groups.string("password")

        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension ChatUser: TokenAuthenticatable {
    // the token model that should be queried
    // to authenticate this user
    public typealias TokenType = Token
}


extension Request {

    func user() throws -> ChatUser {
        return try auth.assertAuthenticated()

    }
	
}

extension ChatUser: PasswordAuthenticatable {
    
    
    
}


extension ChatUser {
    
    func allUsers() throws -> [ChatUser] {
        let users = try ChatUser.all()
        return users
    }
    
}

extension ChatUser {
    
    func userForId(userid: Identifier) throws -> ChatUser {
        let user = try ChatUser.find(userid)
        return user!
    }
    
}

extension ChatUser {

    func userGroups() throws -> [Group] {
        let userGroups = try Group.all()
        return userGroups
    }
    
}

extension ChatUser {
    var groups: Siblings<ChatUser, Group, Pivot<ChatUser, Group>> {
        return siblings()
    }
}

protocol PasswordHasherVerifier: PasswordVerifier, HashProtocol {}

extension BCryptHasher: PasswordHasherVerifier {}


//extension TILUser: Authenticator {
//    
//    static func authenticate(credentials: Credentials) throws -> User {
//        var user: TILUser?
//        
//        switch credentials {
//        case let credentials as UsernamePassword:
//            let fetchedUser = try TILUser.query()
//                .filter("email", credentials.username)
//                .first()
//            if let password = fetchedUser?.password,
//                password != "",
//                (try? BCrypt.verify(password: credentials.password, matchesHash: password)) == true {
//                user = fetchedUser
//            }
//        case let credentials as Identifier:
//            user = try TILUser.find(credentials.id)
//        default:
//            throw UnsupportedCredentialsError()
//        }
//        
//        if let user = user {
//            return user
//        } else {
//            throw IncorrectCredentialsError()
//        }
//        
//    }
//    
//    static func register(credentials: Credentials) throws -> User {
//        throw Abort.badRequest
//    }
//    
//    
//}
//

