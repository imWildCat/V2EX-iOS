import Quick
import Nimble

class TopicSpec: QuickSpec {
    override func spec() {
        var topicModel: Topic!
        
        describe("a topic") {
            beforeEach {
                topicModel = Topic(id: 1, title: "测试话题的标题")
            }
            
            it("should have propreties related to topics of V2EX") {
                expect(topicModel.id).to(equal(1))
                expect(topicModel.title).to(equal("测试话题的标题"))
            }
        }
    }
}