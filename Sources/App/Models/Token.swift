import Vapor
import FluentProvider
import AuthProvider

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
        self.userId = try node.get("userId")

    }

    
    init(row: Row) throws {
        self.token = try row.get("token")
        self.userId = try row.get("userId")

    }
    
    
    func makeNode(context: Context) throws -> Node {
        var node = Node(context)
        try node.set("token", token)
        try node.set("userId", userId)

        return node
        
    }

    
    
}

extension Token: RowRepresentable {
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("token", token)
        try row.set("userId", userId)

        return row
    }
}


extension Token: Preparation {
    
    static func prepare(_ database: Database) throws {
        try database.create(self, closure: { (tokens) in
            tokens.id()
            tokens.string("token")
            tokens.string("userId")
            tokens.parent(ChatUser.self)
            
        })
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }

}

extension Request {
    func tokenUser() throws -> ChatUser {
        return try auth.assertAuthenticated()
    }
}


