import Quick
import Nimble

class YTKKeyValueStoreSpec: QuickSpec {
    
    let dbName = "v2ex_tests.db"
    let tableName = "test_table"
    
    override func spec() {
        describe("a db for test") {
            var store: YTKKeyValueStore!
            
            beforeEach {
                store = YTKKeyValueStore(DBWithName: self.dbName)
                store.createTableWithName(self.tableName)
            }
            
            it("could put a string") {
                store.putString("This is a string", withId: "string_key", intoTable: self.tableName)
            }
            
            it("could get a string") {
                let ret = store.getStringById("string_key", fromTable: self.tableName)
                expect(ret).to(equal("This is a string"))
            }
            
            it("could put a json") {
                let json = ["this is a key": "this is a value", "this is the next key": "this is the next value"]
                store.putObject(json, withId: "json_key", intoTable: self.tableName)
            }
            
            it("could get a json") {
                let json = ["this is a key": "this is a value", "this is the next key": "this is the next value"]
                let jsonGot = store.getObjectById("json_key", fromTable: self.tableName) as [String : String]
                expect(jsonGot).to(equal(json))
            }
            
        }
    }
}
