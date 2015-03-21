import Quick
import Nimble

class UserSpec: QuickSpec {
    override func spec() {
        var user: User!
        
        describe("a user with convenience initializer") {
            beforeEach {
                user = User(name: "Livid")
            }
            
            it ("should have correct propreties") {
                expect(user.name).to(equal("Livid"))
                expect(user.avatarURI).to(equal(""))
                expect(user.website).to(beNil())
                expect(user.twitter).to(beNil())
                expect(user.github).to(beNil())
                expect(user.createdAt).to(beNil())
            }
        }
        
        describe("a user with initializer") {
            beforeEach {
                user = User(
                    name: "Livid",
                    avatarURI: "//cdn.v2ex.com/avatar/c4ca/4238/1_large.png?m=1401650222",
                    website: "http://livid.v2ex.com/",
                    twitter: "Livid",
                    github: "livid",
                    createdAt: "2010-04-25"
                )
            }
            
            it ("should have correct propreties") {
                expect(user.name).to(equal("Livid"))
                expect(user.avatarURI).to(equal("//cdn.v2ex.com/avatar/c4ca/4238/1_large.png?m=1401650222"))
                expect(user.website).to(equal("http://livid.v2ex.com/"))
                expect(user.twitter).to(equal("Livid"))
                expect(user.github).to(equal("livid"))
                expect(user.createdAt).to(equal("2010-04-25"))
            }
        }
    }
}
