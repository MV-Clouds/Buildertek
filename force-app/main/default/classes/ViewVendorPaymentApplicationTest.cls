@isTest
public class ViewVendorPaymentApplicationTest {
    
	 @TestSetup
    static void viewVendor() {
        Id pId = [select id from profile where name='Partner Community User'].id;

        Account acc = new Account();
        acc.name = 'Test Account';
        insert acc;

        Contact con = new Contact();
        con.FirstName = 'First';
        con.LastName = 'Test';
        con.AccountId = acc.Id;
        insert con;

        User user = new User();
        user.alias = 'test123';
        user.email = 'test123@noemail.com';
        user.emailencodingkey = 'UTF-8';
        user.lastname = 'Testing';
        user.languagelocalekey = 'en_US';
        user.localesidkey = 'en_US';
        user.profileid = pId;
        user.ContactId = con.Id;
        user.country = 'United States';
        user.IsActive = true;
        user.timezonesidkey = 'America/Los_Angeles';
        user.username = 'tester@noemail.com';
        insert user;

        Id pId1 = [select id from profile where name='System Administrator'].id;

        User user1 = new User();
        user1.alias = 'test1234';
        user1.email = 'test1234@noemail.com';
        user1.emailencodingkey = 'UTF-8';
        user1.lastname = 'Testing';
        user1.languagelocalekey = 'en_US';
        user1.localesidkey = 'en_US';
        user1.profileid = pId1;
        user1.country = 'United States';
        user1.IsActive = true;
        user1.timezonesidkey = 'America/Los_Angeles';
        user1.username = 'tester1@noemail.com';
        insert user1;
        
        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'Project test';
        insert project;
        
        buildertek__Admin_Interface_Node_Configuration__c admin = new buildertek__Admin_Interface_Node_Configuration__c();
        admin.buildertek__Default_Account_for_SOV__c = acc.Id;
        admin.Name = 'SOV Configuration';
        insert admin;
        
        buildertek__Schedule_of_Values__c stndSOV = new buildertek__Schedule_of_Values__c();
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'buildertek__Schedule_of_Values__c' AND Name = 'Vendor'];
        stndSOV.Name = 'Test';
        stndSOV.buildertek__Status__c='Company Approved';
        stndSOV.buildertek__Project__c = project.Id;
        stndSOV.RecordType = rt;
       // stndSOV.recordtype.name = 'Standard';
        insert stndSOV;   

        buildertek__Schedule_of_Value_Lines__c line = new buildertek__Schedule_of_Value_Lines__c();
        line.buildertek__Schedule_of_Values__c = stndSOV.Id;
        line.buildertek__Description_of_Work__c = 'test';
        line.buildertek__Status__c = 'Approved';
        insert line;
    }
	@isTest
    static void viewVendor1() {
        
        buildertek__Admin_Interface_Node_Configuration__c admin = new buildertek__Admin_Interface_Node_Configuration__c();
        admin = [select Id, Name FROM buildertek__Admin_Interface_Node_Configuration__c LIMIT 1];
        
        buildertek__Schedule_of_Values__c value = new buildertek__Schedule_of_Values__c();
        value = [select Id, Name, buildertek__Status__c, buildertek__Project__c, recordtype.name from buildertek__Schedule_of_Values__c LIMIT 1];
        System.debug('value-------->>>>>>>>>>>>>>>'+value);
        
        List<buildertek__Schedule_of_Value_Lines__c> lastSOV = new List<buildertek__Schedule_of_Value_Lines__c>();
        lastSOV = [SELECT Id,Name,buildertek__Item__c,buildertek__Vendor_Scheduled_Value__c, buildertek__Status__c, buildertek__Schedule_of_Values__c,
                    buildertek__Scheduled_Value__c,buildertek__Description_of_Work__c,buildertek__Schedule_of_Values__r.buildertek__Vendor__c 
                    FROM buildertek__Schedule_of_Value_Lines__c WHERE buildertek__Schedule_of_Values__c =: value.Id];
                
		ListView lv=new ListView();
        lv=[SELECT Id, Name, DeveloperName, NamespacePrefix, SobjectType, IsSoqlCompatible, CreatedDate, CreatedBy.Name, LastModifiedDate, LastModifiedBy.Name, LastViewedDate, LastReferencedDate FROM ListView WHERE SobjectType = 'buildertek__Schedule_of_Values__c' and Name='All'];

        Account acc = [SELECT Id, Name FROM Account LIMIT 1];

        buildertek__Schedule_of_Values__c schedule = new buildertek__Schedule_of_Values__c();
        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'buildertek__Schedule_of_Values__c' AND Name = 'Vendor'];
        schedule.Name = 'Test data';
        schedule.buildertek__Status__c='Company Approved';
        schedule.buildertek__Project__c = value.buildertek__Project__c;
        schedule.RecordTypeId = rt.Id;
        insert schedule;   
        
        List<String> myStrings = new List<String>();
        for (buildertek__Schedule_of_Value_Lines__c sovLine : lastSOV) {
            myStrings.add(sovLine.Id);
        }
        Date dToday = Date.today();

        Test.startTest();

        ViewVendorPaymentApplicationController.getcurrency();
        ViewVendorPaymentApplicationController.getCommUser();
        ViewVendorPaymentApplicationController.getUser();
        ViewVendorPaymentApplicationController.createSheetLines(lastSOV,value.Id,'abc');
        ViewVendorPaymentApplicationController.getListViews();
        ViewVendorPaymentApplicationController.getSovLines(value.Id);
        ViewVendorPaymentApplicationController.submitSOVForView(value.Id,dToday);
        ViewVendorPaymentApplicationController.isSovSubmitted(value.id);
        ViewVendorPaymentApplicationController.getSOVName(value.id);
        ViewVendorPaymentApplicationController.getSovType(value.id);
        ViewVendorPaymentApplicationController.getSOVs(schedule.id);
        ViewVendorPaymentApplicationController.getSovforCurrency(value.id);
        ViewVendorPaymentApplicationController.getSOVlineslistbyType(value.id,'All');
        ViewVendorPaymentApplicationController.getSOVlineslistbyType(value.id,'done');
        ViewVendorPaymentApplicationController.createSOVLines(myStrings,value.id);
        ViewVendorPaymentApplicationController.delSlctRec(myStrings,lastSOV[0].id);
        ViewVendorPaymentApplicationController.deletesheetline(myStrings,value.id);

        user usr = [SELECT Id, FirstName, LastName, Username, Email, ContactId, AccountId FROM User WHERE email =: 'test123@noemail.com'];
        System.runAs(usr) {
            ViewVendorPaymentApplicationController.createSheetLines(lastSOV,value.Id,acc.Id);
        }

        Test.stopTest();

    }

    @isTest
    static void viewVendor2(){

        Account acc = [SELECT Id, Name FROM Account LIMIT 1];

        RecordType rt = [SELECT Id FROM RecordType WHERE sObjectType = 'buildertek__Schedule_of_Values__c' AND Name = 'Vendor'];
        buildertek__Schedule_of_Values__c schedule = new buildertek__Schedule_of_Values__c();
        schedule.Name = 'Test data';
        schedule.buildertek__Status__c='Company Approved';
        schedule.RecordTypeId = rt.Id;
        insert schedule;  

        buildertek__Schedule_of_Value_Lines__c line = new buildertek__Schedule_of_Value_Lines__c();
        line.buildertek__Schedule_of_Values__c = schedule.Id;
        line.buildertek__Description_of_Work__c = 'test';
        line.buildertek__Status__c = 'Approved';
        line.buildertek__Item__c = '23';
        insert line;

        List<String> myStrings = new List<String>{schedule.Id};

        ViewVendorPaymentApplicationController.getSOVs(schedule.id);
        ViewVendorPaymentApplicationController.createSOVLines(myStrings,schedule.id);

    }
}