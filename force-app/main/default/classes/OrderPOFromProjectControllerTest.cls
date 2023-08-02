@isTest
private class OrderPOFromProjectControllerTest {
    @TestSetup
    static void makeData(){
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

        Product2 product = new 	Product2();
        product.Name = 'testing';
        product.ProductCode = '123';
        insert product;


        Contact c =new Contact();
        c.firstName='fname';
        c.lastName='lname';
        c.Email='test@gmail.com';
        insert c;

        buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;

        Account currAccount = new Account(Name = 'Test', buildertek__Email_Address__c='test@gmail.com');
        insert currAccount; 

        buildertek__Change_Order__c co=new buildertek__Change_Order__c();
        co.name='test';
        insert co;

        buildertek__Purchase_Order__c po=new buildertek__Purchase_Order__c();
        po.buildertek__Change_Order__c=co.Id;
        po.buildertek__Vendor__c = currAccount.id;
        po.buildertek__Project__c=proj.Id;
        po.buildertek__Status__c = 'Paid';
        po.buildertek__Phase__c='Project Kickoff Meeting';
        insert po;

        buildertek__ConfirmationPageSiteURL__c tokenCustomSetting = new buildertek__ConfirmationPageSiteURL__c();         
        tokenCustomSetting.Name = 'Siteurl';        
        tokenCustomSetting.buildertek__SiteURL__c = 'https://builderteklightning-developer-edition.na75.force.com/';        
        insert tokenCustomSetting;

        buildertek__Purchase_Order_Item__c POItem = new buildertek__Purchase_Order_Item__c();
        POItem.Name = 'Test';
        POItem.buildertek__Purchase_Order__c = po.Id;
        POItem.buildertek__Quantity__c=1;
        POItem.buildertek__Unit_Price__c=1000;
        POItem.buildertek__Description__c='test';
        POItem.buildertek__Tax__c=100;
        POItem.buildertek__Product__c=product.id;
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
    public static void testMethod1(){
        buildertek__Project__c proj =[Select Id , name From buildertek__Project__c LIMIT 1];
        buildertek__Purchase_Order__c po=[Select buildertek__Change_Order__c ,buildertek__Vendor__c FROM buildertek__Purchase_Order__c limit 1];
        List<String> budgetIds= new List<String>();
        budgetIds.add(po.Id);

        buildertek__Purchase_Order_Item__c arItem=[Select Id , name , buildertek__Purchase_Order__c From buildertek__Purchase_Order_Item__c LIMIT 1];
        List<String> poItem = new List<String>();
        poItem.add(arItem.Id);

        Test.startTest();
        OrderPOFromProjectController.getPORecListDetails(proj.Id);
        OrderPOFromProjectController.sendMail(budgetIds , '[{"fileName":"Test" , "fileContent":"test" , "POId":"'+po.Id+'"}]');
        OrderPOFromProjectController.updatePOLines(poItem , 100);
        Test.stopTest();
    }

    @isTest
    public static void testMethod2(){
        buildertek__Project__c proj =[Select Id , name From buildertek__Project__c LIMIT 1];
        buildertek__Purchase_Order__c po=[Select buildertek__Change_Order__c ,buildertek__Vendor__c FROM buildertek__Purchase_Order__c LIMIT 1];

        Test.startTest();
        OrderPOFromProjectController.getMasterBudgets( proj.Id, 1, 2, ' ' , 'Test' ,'Test' , 'Test' ,'Test' , 'Test');
        
        OrderPOFromProjectController.POLinesWrapper poLineWrapper = new OrderPOFromProjectController.POLinesWrapper();
        poLineWrapper.Name='test';
        poLineWrapper.Description='test Description';
        poLineWrapper.RecordId=proj.Id;
        poLineWrapper.PurchaseOrder='test';
        poLineWrapper.Quantity=20;
        poLineWrapper.UnitCost=10;
        poLineWrapper.TotalCost=5;
        poLineWrapper.TaxRate=28;
        poLineWrapper.TotalPrice=32;
        poLineWrapper.Name='test';
        poLineWrapper.expanded=true;
        poLineWrapper.PORow=true;
        poLineWrapper.coastType='test';
        poLineWrapper.coastValue=33;
        poLineWrapper.ProductCode='test';
        poLineWrapper.groupName='test';
        poLineWrapper.poLineCheck=false;
        
        OrderPOFromProjectController.POInnerClass poWrapper = new OrderPOFromProjectController.POInnerClass();
        poWrapper.poCheck=true;
        poWrapper.poRecord=po;
        Test.stopTest();
    }

    @isTest
    static void testMedhod3(){

        buildertek__Purchase_Order__c po = [SELECT Id, Name, buildertek__Vendor__c FROM buildertek__Purchase_Order__c  LIMIT 1 ];
        buildertek__Purchase_Order_Item__c poLine = [SELECT Id, Name FROM buildertek__Purchase_Order_Item__c LIMIT 1];
        buildertek__Project__c proj =[Select Id , name From buildertek__Project__c LIMIT 1];
        List<String> poLineIdList = new List<String>{poLine.Id};
        OrderPOFromProjectController.getMasterBudgets(proj.Id,1,20,'','Test','','','','');
        
    }

    @isTest
    static void testMedhod4(){
        buildertek__Purchase_Order__c po = [SELECT Id, Name, buildertek__Vendor__c FROM buildertek__Purchase_Order__c  LIMIT 1 ];
        buildertek__Purchase_Order_Item__c poLine = [SELECT Id, Name FROM buildertek__Purchase_Order_Item__c LIMIT 1];
        List<String> poLineIdList = new List<String>{poLine.Id};
        OrderPOFromProjectController.getMasterBudgets(po.Id,1,20,'','','','','','');
    }

    @isTest
    static void testMedhod5(){
        buildertek__Purchase_Order__c po = [SELECT Id, Name, buildertek__Vendor__c FROM buildertek__Purchase_Order__c  LIMIT 1 ];
        buildertek__Purchase_Order_Item__c poLine = [SELECT Id, Name FROM buildertek__Purchase_Order_Item__c LIMIT 1];
        buildertek__Project__c proj =[Select Id , name From buildertek__Project__c LIMIT 1];
        List<String> poLineIdList = new List<String>{poLine.Id};
        OrderPOFromProjectController.getMasterBudgets(proj.Id,1,20,'','','','','','');

    }


   
   
}