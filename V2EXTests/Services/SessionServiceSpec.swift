import Quick
import Nimble

class SessionServiceSpec: QuickSpec {
    override func spec() {
        describe("Session Serivce") {
            
            it("could get once code") {
                SessionService.newSessionForm({ (error, onceCode) -> Void in
                    println(onceCode)
                })
            }
            
        }
    }
}
