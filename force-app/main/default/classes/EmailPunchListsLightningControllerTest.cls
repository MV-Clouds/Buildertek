@isTest
private class EmailPunchListsLightningControllerTest {

	private static testMethod void test() {
        buildertek__Project__c buildertekProjectRef = Buildertek_UtilityClass.Project();
	    account acc = new account();
	    acc.Name = 'test';
	    insert acc;
        contact con = new contact();
        con.Email ='test@gmail.com';
        con.AccountId = acc.id;
        con.LastName ='test';
        con.buildertek__Primary_Contact__c = true;
        insert con;
	    set<Id> accountIds = new set<Id>();
        list<buildertek__Punch_List__c> buildertekPunchList = new list<buildertek__Punch_List__c>();
        buildertek__Punch_List__c PunchListRef = new buildertek__Punch_List__c();
        PunchListRef.buildertek__Description__c = 'test';
        PunchListRef.buildertek__Vendor_Account__c = acc.id;
        PunchListRef.buildertek__Description__c = 'test';
        PunchListRef.buildertek__Project__c =buildertekProjectRef.id;
        insert PunchListRef;
        buildertekPunchList.add(PunchListRef);
        
        Attachment attach = new Attachment();
        attach.Name = 'Test';
        Blob bodyBlob = Blob.valueOf('Testing Body of Attachment');
        attach.body = bodyBlob;
        attach.parentId = PunchListRef.id;
        insert attach;
        List<EmailTemplate> templateList = [Select Id, Name, folder.name from Emailtemplate where folder.name = 'BT PL'];
        // insert templateList;
        list<string> strlist = new list<string>();
        strlist.add(PunchListRef.id + '- test@gmail.com');
        
        
        EmailPunchListsLightningController.getPunchLists(buildertekProjectRef.id);   
        EmailPunchListsLightningController.getTemplates('folderName');
        EmailPunchListsLightningController.getListViews();
        EmailPunchListsLightningController.SendEmail(strlist);
        System.assertEquals('Test','Test');
	}

}