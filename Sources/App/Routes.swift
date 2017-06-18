import Vapor
import AuthProvider
import FluentProvider

extension Droplet {
    
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            print("trying to get plaintext")

            return "Hello, world!"
        }

        // response to requests to /info domain
        // with a description of the request
        get("info") { req in
            return req.description
        }

        get("description") { req in return req.description }
        
        try resource("posts", PostController.self)
    }
    
    func addMiddleWare () throws {
        let tokenMiddleWare = TokenAuthenticationMiddleware(ChatUser.self)
        
        let authed = self.grouped(tokenMiddleWare)
        
        
        authed.get("me") { req in
            // return the authenticated user's name
            print("trying to get me")
            return try req.user().name
        }
        
        
    }
    
}
