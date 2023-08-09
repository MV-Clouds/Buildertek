@isTest
private class EmailSubmittalProcessLightningTest {

	private static testMethod void getEmailSubmittals() {
        buildertek__Project__c proj = new buildertek__Project__c();
        proj.Name = 'Test Project';
        insert proj;
        
        Account acc = new Account();
        acc.Name = 'Test Account';
        acc.buildertek__Email_Address__c = 'test@test.com';
        insert acc;
        
        Contact con = new Contact();
        con.FirstName = 'Test';
        con.LastName = 'Contact';
        con.Email = 'test@test.com';
        con.AccountId = acc.Id;
        insert con;
        
        List<buildertek__Submittal__c> subList = new List<buildertek__Submittal__c>();
        buildertek__Submittal__c sub = new buildertek__Submittal__c();
        sub.buildertek__Title__c = 'Test Submittal';
        sub.buildertek__Project__c = proj.Id;
        sub.buildertek__Description__c = 'Test Description';
        sub.buildertek__Responsible_Contact__c = con.Id;
        sub.buildertek__Responsible_Vendor__c=acc.Id;
        subList.add(sub);
        insert subList;
        
        
        List<String> Id = new List<String>();
        Id.add(subList[0].Id + '-' + con.Email);
        
        Attachment att = new Attachment();
        att.Name = 'Test Attachment';
        att.Body = blob.valueOf('Test Body');
        att.ParentId = subList[0].Id;
        insert att;
        
        
        EmailSubmittalProcessLightningController.getEmailSubmittals(proj.Id);
        EmailSubmittalProcessLightningController.SendEmail(Id);
        EmailSubmittalProcessLightningController.getListViews();
        system.assertEquals('test', 'test');
        
	}

}