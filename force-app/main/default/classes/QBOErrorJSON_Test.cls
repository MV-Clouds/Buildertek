@isTest
public class QBOErrorJSON_Test {
    @isTest
    static void parseTest() {
        String json = '{ "Fault": { "Error": [ { "Message": "ErrorMessage1", "Detail": "ErrorDetail1", "code": "ErrorCode1", "element": "ErrorElement1" }, { "Message": "ErrorMessage2", "Detail": "ErrorDetail2", "code": "ErrorCode2", "element": "ErrorElement2" } ], "type": "FaultType1" }, "time": "2023-01-15T12:34:56Z" }';

        QBOErrorJSON errorJSON = QBOErrorJSON.parse(json);
        System.assertNotEquals(null, errorJSON);
    }

}