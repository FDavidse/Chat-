import Vapor
import Fluent
import AuthProvider
import FluentProvider
import HTTP
import Sessions


final class ChatAppController {
    
    var wrongLogin: Bool = false
    var drop: Droplet? = nil
    
    func addRoutes(drop: Droplet) {
      
        self.drop = drop
        
        let memory = MemorySessions()
        let sessionsMiddleware = SessionsMiddleware(memory)
        
        let persistMiddleware = PersistMiddleware(ChatUser.self)
        
        let passwordMiddleware = PasswordAuthenticationMiddleware(ChatUser.self)
        
        let authed = drop.grouped([sessionsMiddleware, persistMiddleware, passwordMiddleware])
        
        authed.get("meuser") { req in
            // return the authenticated user
            return try req.auth.assertAuthenticated(ChatUser.self)
        }

        
        
        
        let basic = drop.grouped("chat")
        basic.get("index", handler: indexView)
        //basic.post(handler: addAcronym)
        basic.get("register", handler: registerView)
        basic.post("register", handler: register)
//        basic.get("login", handler: loginView)
//        basic.post("login", handler: login)
//        basic.get("logout", handler: logout)

    }
    

    func indexView(request: Request) throws -> ResponseRepresentable {

        //let user = try request.auth.assertAuthenticated(ChatUser.self)
        
        let user = request.auth.authenticated(ChatUser.self)
        
//        if user != nil {
//            self.wrongLogin = false
//        }
//        
        let parameters = try Node(node: [
            "authenticated": false,
            "user": user.makeNode(in: nil) ,
            "wrongpassword": self.wrongLogin
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
        _ = try ChatUser.register(name: name, username:name, email: email, rawPassword: password)
        
        let hashedPassword = try ChatUser.passwordHasher.make(password)

        
        //let credentials = UsernamePassword(username: email, password: password)
        
        let passwordCredentials = Password(username: name.lowercased(), password: password)

        do {
            let user = try ChatUser.authenticate(passwordCredentials)
            request.auth.authenticate(user)
            print("succes creating user, or something")
            return Response(redirect: "/chat/index")
        }
        catch {
            print("failure creating user, or something")

            return Response(redirect: "/chat/index")

        }


        
        
    }
    /*
    func loginView(request: Request) throws -> ResponseRepresentable {
        return try drop.view.make("login")
    }
    
    func login(request: Request) throws -> ResponseRepresentable {
        guard let email = request.formURLEncoded?["email"]?.string,
            let password = request.formURLEncoded?["password"]?.string  else {
                //return "Missing email or password"
                self.wrongLogin = true
                return Response(redirect: "/til")
                
        }
        let credential = UsernamePassword(username: email, password: password)
        do {
            try request.auth.login(credential)
            return Response(redirect: "/til")
        } catch let e as TurnstileError {
            //return e.description
            self.wrongLogin = true
            return Response(redirect: "/til")
            
        }
        
        
    }
    
    func logout(request: Request) throws -> ResponseRepresentable {
        try request.auth.logout()
        return Response(redirect: "/til")
    }
 
 */
    
    
}
