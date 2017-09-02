import Vapor
import Fluent
import AuthProvider
import FluentProvider
import HTTP
import Sessions
import Node


final class ChatAppController {
    
    var wrongLogin: Bool = false
    var drop: Droplet? = nil
    
    func addRoutes(drop: Droplet) {
      
        self.drop = drop
//        
//        let memory = MemorySessions()
//        let sessionsMiddleware = SessionsMiddleware(memory)
//        let persistMiddleware = PersistMiddleware(ChatUser.self)
//        let passwordMiddleware = PasswordAuthenticationMiddleware(ChatUser.self)
//
//        let authed = drop.grouped([sessionsMiddleware, persistMiddleware, passwordMiddleware])
        //authed.get("chat/index", handler: indexView)

        let basic = drop.grouped("chat")
        basic.get("/login", handler: loginView)
        basic.get("/index", handler: indexView)

        
        //basic.post(handler: addAcronym)
        basic.get("/register", handler: registerView)
        basic.post("/register", handler: register)
        basic.get("/login", handler: loginView)
        basic.post("/login", handler: login)
        basic.get("/logout", handler: logout)

    }
    

    func indexView(request: Request) throws -> ResponseRepresentable {

       
    
        let user = request.auth.authenticated(ChatUser.self)
        
        var logginIn:Bool = true
        var userNode: Node = nil
        if user != nil {
            let node: Node = Node(emptyContext)
            print("user id is \(user!.id ?? "")")

            let nodeContext : Context = node.context
            
            
            
            userNode = try user.makeNode(in: nil)
            
        }else{
            userNode = nil
            logginIn = false
        }
        
        let parameters = try Node(node: [
            "authenticated": logginIn,
            "user": userNode ,
            "wrongpassword": false
            ])
            
        
        
        return try drop!.view.make("index", parameters)
        
    
    }
    
    /*
    func addAcronym(request: Request) throws -> ResponseRepresentable {
        
        guard let short = request.data["short"]?.string, let long = request.data["long"]?.string else {
            throw Abort.badRequest
        }
        
        let user = try request.auth.user() as! TILUser
        
        var acronym = Acronym(short: short, long: long, tiluserId: user.id)
        try acronym.save()
        
        return Response(redirect: "/til")
    }
    
    func deleteAcronym(request: Request, acronym: Acronym) throws -> ResponseRepresentable {
        try acronym.delete()
        return Response(redirect: "/til")
    }
    */
    func registerView(request: Request) throws -> ResponseRepresentable {
        return try self.drop!.view.make("register")
    }
    
 
    func register(request: Request) throws -> ResponseRepresentable {
        
        guard let email = request.formURLEncoded?["email"]?.string,
            let password = request.formURLEncoded?["password"]?.string,
            let name = request.formURLEncoded?["name"]?.string else {
                return "Missing email, password, or name"
        }
        let newUser = try ChatUser.register(name: name, username:name, email: email, rawPassword: password)
        
        //let hashedPassword = try ChatUser.passwordHasher.make(password)

        request.auth.authenticate(newUser)
        
        //let credentials = UsernamePassword(username: email, password: password)
        
        let passwordCredentials = Password(username: email.lowercased(), password: password)

        do {
            let user = try ChatUser.authenticate(passwordCredentials)
            request.auth.authenticate(user)
            print("succes creating user, or something")
            
            let userLoggedIn = request.auth.authenticated(ChatUser.self)
            
            return Response(redirect: "/chat/index")
        }
        catch {
            print("failure creating user, or something")

            return Response(redirect: "/chat/index")

        }
    }
    
    func loginView(request: Request) throws -> ResponseRepresentable {
        return try self.drop!.view.make("login")
    }
    
    
    func login(request: Request) throws -> ResponseRepresentable {
        guard let email = request.formURLEncoded?["email"]?.string,
            let password = request.formURLEncoded?["password"]?.string  else {
                //return "Missing email or password"
                return Response(redirect: "/chat")
        }
        let passwordCredentials = Password(username: email.lowercased(), password: password)

        do {
            let user = try ChatUser.authenticate(passwordCredentials)
            try request.auth.authenticate(user)
            
            //to check if we have an authenticated user now
            let userLoggedIn = request.auth.authenticated(ChatUser.self)
            return Response(redirect: "/chat/index")
           
        } catch {
            //return e.description
            self.wrongLogin = true
            return Response(redirect: "/chat")
        }
        
    }
    
    func logout(request: Request) throws -> ResponseRepresentable {
        
        //let user = request.auth.authenticated(ChatUser.self)
        try request.auth.unauthenticate()
        
        //try request.auth.logout()
        return Response(redirect: "/chat/index")
    }
 

    
    
}
