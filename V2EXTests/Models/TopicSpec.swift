import Quick
import Nimble

class TopicSpec: QuickSpec {
    override func spec() {
        var topicModel: Topic!
        
        describe("a topic") {
            beforeEach {
                topicModel = Topic(id: "1", title: "测试话题的标题",
                                   node: Node(name: "问与答", slug: "qna"),
                                   author: User(name: "DemoUser"))
            }
            
            it("should have propreties related to topics of V2EX") {
                expect(topicModel.title).to(equal("测试话题的标题"))
            }
        }
    }
}