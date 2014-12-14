import Quick
import Nimble

class UserSpec: QuickSpec {
    override func spec() {
        var user: User!
        
        describe("a user with convenience initializer") {
            beforeEach {
                user = User(id: 1, username: "Livid")
            }
            
            it ("should have correct propreties") {
                expect(user.id).to(equal(1))
                expect(user.username).to(equal("Livid"))
                expect(user.avatar).to(beNil())
                expect(user.website).to(beNil())
                expect(user.twitter).to(beNil())
                expect(user.github).to(beNil())
                expect(user.created_at).to(beNil())
            }
        }
        
        describe("a user with initializer") {
            beforeEach {
                user = User(
                    id: 1,
                    username: "Livid",
                    avatar: "//cdn.v2ex.com/avatar/c4ca/4238/1_large.png?m=1401650222",
                    website: "http://livid.v2ex.com/",
                    twitter: "Livid",
                    github: "livid",
                    created_at: 1272203146
                )
            }
            
            it ("should have correct propreties") {
                expect(user.id).to(equal(1))
                expect(user.username).to(equal("Livid"))
                expect(user.avatar).to(equal("//cdn.v2ex.com/avatar/c4ca/4238/1_large.png?m=1401650222"))
                expect(user.website).to(equal("http://livid.v2ex.com/"))
                expect(user.twitter).to(equal("Livid"))
                expect(user.github).to(equal("livid"))
                expect(user.created_at).to(equal(1272203146))
            }
        }
    }
}
