@isTest 
public class CheckInTriggerTest {
    @testSetup
    static void setupMethod(){
        Account acc = new Account();
        acc.Name = 'Test 1';
        insert acc; 
        
        buildertek__Project__c project = new buildertek__Project__c();
        project.buildertek__Account__c = acc.Id;
        project.buildertek__Geolocation__Latitude__s = 39.0162;
        project.buildertek__Geolocation__Longitude__s = -94.26;
        insert project;
         
        Test.setMock(HttpCalloutMock.class, new RestMock());
        Test.startTest();
        buildertek__Check_In__c checkIn = new buildertek__Check_In__c();
        checkIn.Name = 'Test 1';
        checkIn.buildertek__Project__c = project.Id;
        insert checkIn;
        Test.stopTest();
    }
    
    @isTest
    static void testMethod1(){
        delete [Select Id FROM buildertek__Check_In__c LIMIT 1]; 
    }
    
    private class RestMock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String fullJson = '{"coord":{"lon":-94.26,"lat":39.0162},"weather":[{"id":800,"main":"Clear","description":"clear sky","icon":"01n"}],"base":"stations","main":{"temp":271.19,"feels_like":267.07,"temp_min":270.93,"temp_max":271.48,"pressure":1025,"humidity":80},"visibility":10000,"wind":{"speed":2.16,"deg":145},"clouds":{"all":1},"dt":1614685542,"sys":{"type":1,"id":4794,"country":"US","sunrise":1614689273,"sunset":1614730241},"timezone":-21600,"id":4377664,"name":"Blue Springs","cod":200}';
            
            HTTPResponse res = new HTTPResponse();
            res.setHeader('Content-Type', 'text/json');
            res.setBody(fullJson);
            res.setStatusCode(200);
            res.setStatus('OK');
            return res;
        }
    }
}