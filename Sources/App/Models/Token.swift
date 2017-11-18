import Vapor
import FluentProvider
import AuthProvider
import Foundation

final class Token: Model {
    
    let storage = Storage()

    let token: String
    let userId: Identifier
    
    var user: Parent<Token, ChatUser> {
        return parent(id: userId)
        
    }
    
    init(token: String, userId: Identifier) throws {
        self.token = token
        self.userId = userId
    }
    
    init(node: Node) throws {
        self.token = try node.get("token")
        self.userId = try node.get("chat_user_id")

    }

    
    init(row: Row) throws {
        self.token = try row.get("token")
        self.userId = try row.get("chat_user_id")

    }
    
    
    func makeNode(context: Context) throws -> Node {
        var node = Node(context)
        try node.set("token", token)
        try node.set("chat_user_id", userId)

        return node
        
    }
    
    static func setTokenfor(user: ChatUser) throws -> Token {
        
        
        //generate unique string
        let uuid = UUID().uuidString
        
        let token = try Token.init(token: uuid, userId: user.id!)
        
        do {
            try token.save()
        } catch {
            print("saving token failed")
            
        }
        
        return token
        
    }

    
    
}

extension Token: RowRepresentable {
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("token", token)
        try row.set("chat_user_id", userId)

        return row
    }
}


extension Token: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (tokens) in
            tokens.id()
            tokens.string("token")
            tokens.foreignKey("chat_user_id", references: "id", on: ChatUser.self)
            tokens.parent(ChatUser.self)
            
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }

}

// MARK: JSON

// How the model converts from / to JSON.
// For example when:
//     - Creating a new Post (POST /posts)
//     - Fetching a post (GET /posts, GET /posts/:id)
//
extension Token: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(token: json.get("token"), userId: json.get("chat_user_id"))
    }
}
extension Token: JSONRepresentable {
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", self.id)
        try json.set("id_key", self.idKey)
        try json.set("token", token)
        try json.set("chat_user_id", userId)
        
        return json
    }
}


extension Token: ResponseRepresentable { }


extension Request {
    func tokenUser() throws -> ChatUser {
        return try auth.assertAuthenticated()
    }
}


