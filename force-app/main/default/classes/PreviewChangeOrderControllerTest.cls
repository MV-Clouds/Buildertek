@isTest
public class PreviewChangeOrderControllerTest {
    
    static testMethod void testGetTemplates() {
        User u;
        
        Account a = new Account(Name='ApexHours');
        insert a;
        
        User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

        System.runAs (thisUser) {
                // Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
                // UserRole r = [SELECT Id FROM UserRole WHERE Name='CEO'];
                
                // User usr = new User(alias = 'apexs', email='test@test.com', 
                // emailencodingkey='UTF-8', lastname='Hours', 
                // languagelocalekey='en_US', 
                // localesidkey='en_US', profileid = p.Id, userroleid = r.Id,
                // username='test@testhours.com');
                // insert usr;
                // Create test data
                Contact testContact = new Contact(LastName='test',Email = 'test@test.com');
                insert testContact;

                // Create test data
                EmailTemplate testTemplate = new EmailTemplate(DeveloperName = 'DevNameTest', Name='TestNameTemp' ,IsActive=true ,TemplateType='custom' ,FolderId = UserInfo.getUserId());
                insert testTemplate;
                
                buildertek__Change_Order__c testCO = new buildertek__Change_Order__c();
                insert testCO;
                List<String> to = new List<String>();
                List<String> cc = new List<String>();

                to.add('test@test.com');
                cc.add('test123@test.com');


                
                // Call the method to test
                List<EmailTemplate> templates = PreviewChangeOrderController.getTemplates();
                String templateBody = PreviewChangeOrderController.getChangeOrderLines(testCO.Id, testTemplate.Id);

                PreviewChangeOrderController.sendProposal('test',testCO.Id,testTemplate.Id , to , cc ,'test');

                
                // Verify the result
                System.assertEquals(1, templates.size());
                System.assertNotEquals(null, templateBody);
        }
    }
    
//     static testMethod void testGetChangeOrderLines() {
//         // Create test data
//         Contact testContact = new Contact(LastName='test',Email = 'test@test.com');
//         insert testContact;
//         buildertek__Change_Order__c testCO = new buildertek__Change_Order__c();
//         insert testCO;
//         EmailTemplate testTemplate = new EmailTemplate(Name = 'Test Template123', FolderId = UserInfo.getUserId());
//         insert testTemplate;
        
//         // Call the method to test
//         String templateBody = PreviewChangeOrderController.getChangeOrderLines(testCO.Id, testTemplate.Id);
        
//         // Verify the result
//         System.assertNotEquals(null, templateBody);
//     }
    
//     static testMethod void testSetAttachmentBody() {
//         // Create test data
//         buildertek__Change_Order__c testCO = new buildertek__Change_Order__c();
//         insert testCO;
//         EmailTemplate testTemplate = new EmailTemplate(Name = 'Test Template', FolderId = UserInfo.getUserId());
//         insert testTemplate;
        
//         // Call the method to test
//         // Blob attachmentBody = PreviewChangeOrderController.setAttachmentBody(testCO.Id, testTemplate.Id, '');
        
//         // Verify the result
//         System.assertNotEquals(null, attachmentBody);
//     }
    
//     static testMethod void testSavedFile() {
//         // Create test data
//         // buildertek__Change_Order__c testCO = new buildertek__Change_Order__c(Subdivison_Name__c = 'Test Subdivision', Lot__c = 'Test Lot', Name = 'Test CO');
//         insert testCO;
//         EmailTemplate testTemplate = new EmailTemplate(Name = 'Test Template', FolderId = UserInfo.getUserId());
//         insert testTemplate;
        
//         // Call the method to test
//         // String message = PreviewChangeOrderController.savedFile(testCO.Id, testTemplate.Id);
        
//         // Verify the result
//         System.assertEquals('saved', message);
//     }
}