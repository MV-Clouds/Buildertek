@isTest
public with sharing class POPageControllerTest {
    @TestSetup
    static void POpage1() {

        Id pId = [select id from profile where name='System Administrator'].id;

        User user = new User();
        user.alias = 'test123';
        user.email = 'test123@noemail.com';
        user.emailencodingkey = 'UTF-8';
        user.lastname = 'Testing';
        user.languagelocalekey = 'en_US';
        user.localesidkey = 'en_US';
        user.profileid = pId;
        user.country = 'United States';
        user.IsActive = true;
        user.timezonesidkey = 'America/Los_Angeles';
        user.username = 'tester@noemail.com';
        insert user;

        Account ac = new Account();
        ac.Name = 'Test';
        insert ac;

        Product2 product = new 	Product2();
        product.Name = 'testing';
        product.ProductCode = '123';
        insert product;

        buildertek__Purchase_Order__c po = new buildertek__Purchase_Order__c();
        po.buildertek__Vendor__c = ac.Id;
        po.buildertek__Status__c = 'Open';
        insert po;

        buildertek__Purchase_Order__c po1 = new buildertek__Purchase_Order__c();
        po1.buildertek__Vendor__c = ac.Id;
        po1.buildertek__Status__c = 'Paid';
        insert po1;

        buildertek__Purchase_Order_Item__c POItem = new buildertek__Purchase_Order_Item__c();
        POItem.Name = 'Test';
        POItem.buildertek__Purchase_Order__c = po.Id;
        POItem.buildertek__Product__c = product.Id;
        insert POItem;

        System.runAs(new User(Id=UserInfo.getUserId())){
            EmailTemplate et = new EmailTemplate(); 
            et.isActive = true; 
            et.Name = 'Purchase Order Template'; 
            et.DeveloperName = 'Test_Template'; 
            et.TemplateType = 'text';
            et.Subject = 'Test Subject';
            et.FolderId = UserInfo.getUserId(); 
            et.htmlvalue = 'TextArea';
            et.Body = 'test'; 
            insert et; 
        }

    }
    @isTest
    static void MSAForm2(){

        List<buildertek__Purchase_Order__c> poList = new List<buildertek__Purchase_Order__c>();
        buildertek__Purchase_Order__c po = [SELECT Id,Name FROM buildertek__Purchase_Order__c WHERE buildertek__Status__c = 'Open' LIMIT 1 ];
        poList.add(po);

        List<String> budgetIds = new List<String>{po.Id};

        POPageController.getMasterBudgets(po.Id,10,20,'abc','abcd','abc','sfg','asds','asvf');
        POPageController.getMasterBudgets(po.Id,10,20,'','abcd','abc','sfg','asds','asvf');
        POPageController.getMasterBudgets(po.Id,10,20,'','abcd','','sfg','asds','asvf');
        POPageController.getMasterBudgets(po.Id,10,20,'','t','','','1','');

        POPageController.findByName('t',po.Id,1,20);
        POPageController.findByName2('t','sfdd',po.Id,1,20);
        POPageController.getPORecListDetails(po.Id);
        POPageController.sendMail(budgetIds,'');
    }

    @isTest
    static void testMedhod2(){

        buildertek__Purchase_Order__c po = [SELECT Id, Name, buildertek__Vendor__c FROM buildertek__Purchase_Order__c WHERE buildertek__Status__c = 'Open' LIMIT 1 ];
        buildertek__Purchase_Order_Item__c poLine = [SELECT Id, Name FROM buildertek__Purchase_Order_Item__c LIMIT 1];

        List<String> poLineIdList = new List<String>{poLine.Id};

        POPageController.getMasterBudgets(po.Id,10,20,'','','','','1','');
        POPageController.getMasterBudgets(po.Id,10,20,'','t','','','','');
        POPageController.getMasterBudgets(po.Id,1,20,'','','','','','');
        POPageController.getContactName(po.buildertek__Vendor__c);
        POPageController.updatePOLines(poLineIdList, 20);
        

    }
}