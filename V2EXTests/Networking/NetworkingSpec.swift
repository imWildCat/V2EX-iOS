import Quick
import Nimble

class NetworkingSpec: QuickSpec {
    override func spec() {
        describe("Networking class") {
            it("should request with cookies") {
                let req = Networking.get("https://v2ex.com/sad")
            }
        }
    }
}
