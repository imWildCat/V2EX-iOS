import Quick
import Nimble

class TopicServiceSpec: QuickSpec {
    override func spec() {
        describe("Topic Serivce") {
            
            it("could load from tabs") {
                TopicSerivce.getList(tabSlug: "all", response: nil)
            }
            
        }
    }
}
