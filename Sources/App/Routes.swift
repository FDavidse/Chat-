import Vapor
import AuthProvider
import FluentProvider
import HTTP
import Sessions


extension Droplet {
    
    func setupRoutes() throws {
        get("hello") { req in
            var json = JSON()
            try json.set("hello", "world")
            return json
        }

        get("plaintext") { req in
            print("trying to get plaintext")
            let user = req.auth.authenticated(ChatUser.self)
            let userOhter = try req.user()
            if user != nil {
                print("user name is \(user!.name)")
            }
            
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
        
        authed.get("plaintext2") { req in
            print("trying to get plaintext")
            let user = req.auth.authenticated(ChatUser.self)
            let userOhter = try req.user()
            if user != nil {
                print("user name is \(user!.name)")
            }
            
            if let user3 = try ChatUser.find(1) {
                req.auth.authenticate(user3)
            }
            
            print(req.auth.header)
            print(req.auth.header?.basic)
            
            
            let user4 = try req.auth.assertAuthenticated(ChatUser.self)
            
            return "Hello, world!"
        }

      
    }
    
    func addMiddleWarePassword () throws {
        let passwordMiddleware = PasswordAuthenticationMiddleware(ChatUser.self)
        
        
        let authedPassword = try self.grouped(passwordMiddleware)
        
        
        authedPassword.get("metoo") { req in
            //return the authenticated user
            return try req.auth.assertAuthenticated(ChatUser.self)
            
        }
        
              
    }

    func addMiddleWareAuth () throws {
        
        let memory = MemorySessions()
        let sessionsMiddleware = SessionsMiddleware(memory)
        
        let persistMiddleware = PersistMiddleware(ChatUser.self)
        
        let passwordMiddleware = PasswordAuthenticationMiddleware(ChatUser.self)
        
        let authed = self.grouped([sessionsMiddleware, persistMiddleware, passwordMiddleware])
        
                
    }
    
}
