import Quick
import Nimble
import Alamofire

class AlamofireSpec: QuickSpec {
    override func spec() {
        
        describe("alamofire") {
            
            /**
            *  It might depend on you IP.
            */
            
            it("could get html form v2ex") {
                
                waitUntil(timeout: 30) { done in
//                    let request = Alamofire.request(.GET, "https://v2ex.com")
//                        .responseString { (_, _, string, _) in
//                            expect(string).to(contain("<title>V2EX</title>"))
//                            done()
//                    }
                }
    
            }
           
        }
        
    }
}
