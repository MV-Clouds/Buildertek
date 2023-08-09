@isTest
public  class SubContractOrderFromProjectClassTest {
    @isTest static void testmethod1(){

      

        Account account1 = new Account();
        account1.Name = 'test';
        account1.buildertek__Email_Address__c ='test@test.com';
        
        insert account1;
        Contact contact1 = new Contact(
            AccountId = account1.Id,
            LastName = 'LastName1',
            email='sagar@buildertek.com'
        );
        insert contact1;

        



        buildertek__Project__c project = new buildertek__Project__c(
            Name = 'Sample Project',
            buildertek__Account__c = account1.Id,
            buildertek__Project_Manager__c = UserInfo.getUserId(),
            Project_Tax_Rate__c = 10.5
        );
        insert project;
        buildertek__Purchase_Order__c purchaseOrder = new buildertek__Purchase_Order__c();
        purchaseOrder.buildertek__Contractor_Resource__c = contact1.Id;
        purchaseOrder.buildertek__Vendor__c = account1.Id;
        purchaseOrder.buildertek__Project__c = project.Id;
        purchaseOrder.buildertek__Ship_To_Address__c = account1.Id;
        insert purchaseOrder;

        buildertek__Purchase_Order__c purchaseOrder1 = new buildertek__Purchase_Order__c();
        purchaseOrder1.buildertek__Contractor_Resource__c = contact1.Id;
        purchaseOrder1.buildertek__Vendor__c = account1.Id;
        purchaseOrder1.buildertek__Project__c = project.Id;
        purchaseOrder1.buildertek__Ship_To_Address__c = account1.Id;
        insert purchaseOrder1;



        buildertek__Contract__c contra= new buildertek__Contract__c();
        contra.Name='Test';
        contra.buildertek__Contract_Start_Date__c=Date.today();
        contra.buildertek__Status__c='Draft';
        // contra.buildertek__Contract_Amount__c=0;
        // contra.buildertek__Purchase_Order__c=purchaseOrder.Id;

        insert contra;


        buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;

    
        
        List<buildertek__Budget__c> budgetList = new List<buildertek__Budget__c>();
	    buildertek__Budget__c budget = new buildertek__Budget__c();
	    budget.Name = 'Test Budget';
	    budget.buildertek__Project__c = proj.Id;
	    budget.buildertek__Type__c = 'Master';
	    budgetList.add(budget);
	    insert budgetList;
	    

        buildertek__Budget_Line_Group__c groupLine = new buildertek__Budget_Line_Group__c();
        groupLine.Name='test';
        insert groupLine;

        buildertek__Cost_Codes__c	 costCodes = new buildertek__Cost_Codes__c	();
        costCodes.Name='test';
        insert costCodes;

        List<String> budgetItem = new List<String>();

        buildertek__Budget_Item__c budget1Item = new buildertek__Budget_Item__c();
        budget1Item.Name='test';
        budget1Item.buildertek__Contractor__c=account1.Id;
        budget1Item.buildertek__Budget__c=budgetList[0].Id;
        budget1Item.buildertek__Group__c=groupLine.Id;
        budget1Item.buildertek__Description__c='Test';
        budget1Item.buildertek__Cost_Code__c=costCodes.Id;
        budget1Item.buildertek__Sub_Contract__c=contra.Id;
        budget1Item.buildertek__Purchase_Order__c=purchaseOrder.Id;

        insert budget1Item;
        budgetItem.add(budget1Item.Id);

        buildertek__Budget_Item__c budget2Item = new buildertek__Budget_Item__c();
        budget2Item.Name='test';
        budget2Item.buildertek__Contractor__c=account1.Id;
        budget2Item.buildertek__Budget__c=budgetList[0].Id;
        budget2Item.buildertek__Group__c=groupLine.Id;
        budget2Item.buildertek__Description__c='Test';
        budget2Item.buildertek__Cost_Code__c=costCodes.Id;
        budget2Item.buildertek__Sub_Contract__c=contra.Id;
        budget2Item.buildertek__Purchase_Order__c=purchaseOrder.Id;

        insert budget2Item;
        budgetItem.add(budget2Item.Id);


        buildertek__Contract_Item__c contractItem = new buildertek__Contract_Item__c();
        contractItem.Name='Test';
        contractItem.buildertek__Budget_Item__c=budget1Item.Id;
        contractItem.buildertek__Contract__c=contra.Id;
        contractItem.buildertek__Quantity__c=1;
        contractItem.buildertek__Unit_Price__c=4;
        insert contractItem;



       

      


    
        Test.startTest();

        SubContractOrderFromProjectClass subContract = new SubContractOrderFromProjectClass();
        // Message wrapper
        SubContractOrderFromProjectClass.MessageClass messageWrapper = new SubContractOrderFromProjectClass.MessageClass();
        messageWrapper.Status='Passed';
        messageWrapper.Message='Test';

        // Master Budget wrapper
        SubContractOrderFromProjectClass.MasterBudgetsClass masterBudget = new SubContractOrderFromProjectClass.MasterBudgetsClass();
        masterBudget.budgetRecord=budget1Item;
        masterBudget.budgetCheck=true;


        SubContractOrderFromProjectClass.getMasterBudgets(proj.Id);
        SubContractOrderFromProjectClass.findByName('test', proj.Id);
        SubContractOrderFromProjectClass.findByName1('test', proj.Id);
        SubContractOrderFromProjectClass.findByName2('test', proj.Id);

        SubContractOrderFromProjectClass.Innerclass Innerclass = new SubContractOrderFromProjectClass.Innerclass();
        Innerclass.POId=contra.Id;
        Innerclass.fileName='Test';
        Innerclass.fileContent='Test';

       String fname='test';
       String fcontent='Test';
       String POId=contra.Id;


        SubContractOrderFromProjectClass.createPO(budgetItem, proj.Id , '[{"fileName":"test" },{"fileContent":"fileContent"}]');
        // SubContractOrderFromProjectClass.createPO(budgetItem, proj.Id , '[{"fileName":"test" ;"fileContent":"fileContent"; "POId":"a1U1K000005QdsAUAS"} ]');
        // SubContractOrderFromProjectClass.createPO(budgetItem, proj.Id , '{"POId":'+contra.Id+',"fileName":"test", "fileContent":"fileContent"}');


        SubContractOrderFromProjectClass.sendMail(budgetItem,  '[{"fileName":"test" },{"fileContent":"fileContent"} ]');

        Test.stopTest();


    }

    @isTest static void testmethod2(){
        try{

        Account account1 = new Account();
        account1.Name = 'test';
        account1.buildertek__Email_Address__c ='test@test.com';

        
        insert account1;
        Contact contact1 = new Contact(
            AccountId = account1.Id,
            LastName = 'LastName1',
            email='sagar@buildertek.com'
        );
        insert contact1;

        buildertek__Contract__c contra= new buildertek__Contract__c();
        contra.Name='Test';
        contra.buildertek__Contract_Start_Date__c=Date.today();
        contra.buildertek__Status__c='Draft';
        insert contra;



        buildertek__Project__c project = new buildertek__Project__c(
            Name = 'Sample Project',
            buildertek__Account__c = account1.Id,
            buildertek__Project_Manager__c = UserInfo.getUserId(),
            Project_Tax_Rate__c = 10.5
        );
        insert project;
        List<String> purchaseList = new List<String> ();

        buildertek__Purchase_Order__c purchaseOrder = new buildertek__Purchase_Order__c();
        purchaseOrder.buildertek__Contractor_Resource__c = contact1.Id;
        purchaseOrder.buildertek__Vendor__c = account1.Id;
        purchaseOrder.buildertek__Project__c = project.Id;
        purchaseOrder.buildertek__Ship_To_Address__c = account1.Id;
        purchaseOrder.buildertek__Status__c='Ordered';
        purchaseOrder.buildertek__Sub_Contract__c=contra.Id;

        insert purchaseOrder;
        purchaseList.add(purchaseOrder.Id);

        buildertek__Purchase_Order__c purchaseOrder1 = new buildertek__Purchase_Order__c();
        purchaseOrder1.buildertek__Contractor_Resource__c = contact1.Id;
        purchaseOrder1.buildertek__Vendor__c = account1.Id;
        purchaseOrder1.buildertek__Project__c = project.Id;
        purchaseOrder1.buildertek__Ship_To_Address__c = account1.Id;
        purchaseOrder1.buildertek__Status__c='Ordered';
        purchaseOrder1.buildertek__Sub_Contract__c=contra.Id;

        insert purchaseOrder1;
        purchaseList.add(purchaseOrder1.Id);

        


        buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;

    
        
        List<buildertek__Budget__c> budgetList = new List<buildertek__Budget__c>();
	    buildertek__Budget__c budget = new buildertek__Budget__c();
	    budget.Name = 'Test Budget';
	    budget.buildertek__Project__c = proj.Id;
	    budget.buildertek__Type__c = 'Master';
	    budgetList.add(budget);
	    insert budgetList;
	    

        buildertek__Budget_Line_Group__c groupLine = new buildertek__Budget_Line_Group__c();
        groupLine.Name='test';
        insert groupLine;

        buildertek__Cost_Codes__c	 costCodes = new buildertek__Cost_Codes__c	();
        costCodes.Name='test';
        insert costCodes;

       


        Test.startTest();

        SubContractOrderFromProjectClass.sendMail(purchaseList,  '[{"fileName":"test" },{"fileContent":"fileContent"}]');



      
        Test.stopTest();
        }catch(Exception e){
            System.debug(e.getLineNumber());
            System.debug(e.getMessage());


        }

    }
    @isTest static void testmethod3(){

      

        Account account1 = new Account();
        account1.Name = 'test';
        account1.buildertek__Email_Address__c ='test@test.com';
        
        insert account1;
        Contact contact1 = new Contact(
            AccountId = account1.Id,
            LastName = 'LastName1',
            email='sagar@buildertek.com'
        );
        insert contact1;

        



        buildertek__Project__c project = new buildertek__Project__c(
            Name = 'Sample Project',
            buildertek__Account__c = account1.Id,
            buildertek__Project_Manager__c = UserInfo.getUserId(),
            Project_Tax_Rate__c = 10.5
        );
        insert project;
        buildertek__Purchase_Order__c purchaseOrder = new buildertek__Purchase_Order__c();
        purchaseOrder.buildertek__Contractor_Resource__c = contact1.Id;
        purchaseOrder.buildertek__Vendor__c = account1.Id;
        purchaseOrder.buildertek__Project__c = project.Id;
        purchaseOrder.buildertek__Ship_To_Address__c = account1.Id;
        insert purchaseOrder;

        buildertek__Purchase_Order__c purchaseOrder1 = new buildertek__Purchase_Order__c();
        purchaseOrder1.buildertek__Contractor_Resource__c = contact1.Id;
        purchaseOrder1.buildertek__Vendor__c = account1.Id;
        purchaseOrder1.buildertek__Project__c = project.Id;
        purchaseOrder1.buildertek__Ship_To_Address__c = account1.Id;
        insert purchaseOrder1;



        buildertek__Contract__c contra= new buildertek__Contract__c();
        contra.Name='Test';
        contra.buildertek__Contract_Start_Date__c=Date.today();
        contra.buildertek__Status__c='Draft';
        // contra.buildertek__Contract_Amount__c=0;
        // contra.buildertek__Purchase_Order__c=purchaseOrder.Id;

        insert contra;


        buildertek__Project__c proj = new buildertek__Project__c();
	    proj.Name = 'Test Project';
	    insert proj;

    
        
        List<buildertek__Budget__c> budgetList = new List<buildertek__Budget__c>();
	    buildertek__Budget__c budget = new buildertek__Budget__c();
	    budget.Name = 'Test Budget';
	    budget.buildertek__Project__c = proj.Id;
	    budget.buildertek__Type__c = 'Master';
	    budgetList.add(budget);
	    insert budgetList;
	    

        buildertek__Budget_Line_Group__c groupLine = new buildertek__Budget_Line_Group__c();
        groupLine.Name='test';
        insert groupLine;

        buildertek__Cost_Codes__c	 costCodes = new buildertek__Cost_Codes__c	();
        costCodes.Name='test';
        insert costCodes;

        List<String> budgetItem = new List<String>();

        buildertek__Budget_Item__c budget1Item = new buildertek__Budget_Item__c();
        budget1Item.Name='test';
        budget1Item.buildertek__Contractor__c=account1.Id;
        budget1Item.buildertek__Budget__c=budgetList[0].Id;
        budget1Item.buildertek__Group__c=groupLine.Id;
        budget1Item.buildertek__Description__c='Test';
        budget1Item.buildertek__Cost_Code__c=costCodes.Id;
        budget1Item.buildertek__Sub_Contract__c=contra.Id;
        budget1Item.buildertek__Purchase_Order__c=purchaseOrder.Id;

        insert budget1Item;
        budgetItem.add(budget1Item.Id);

        buildertek__Budget_Item__c budget2Item = new buildertek__Budget_Item__c();
        budget2Item.Name='test';
        budget2Item.buildertek__Contractor__c=account1.Id;
        budget2Item.buildertek__Budget__c=budgetList[0].Id;
        budget2Item.buildertek__Group__c=groupLine.Id;
        budget2Item.buildertek__Description__c='Test';
        budget2Item.buildertek__Cost_Code__c=costCodes.Id;
        budget2Item.buildertek__Sub_Contract__c=contra.Id;
        budget2Item.buildertek__Purchase_Order__c=purchaseOrder.Id;

        insert budget2Item;
        budgetItem.add(budget2Item.Id);


        buildertek__Contract_Item__c contractItem = new buildertek__Contract_Item__c();
        contractItem.Name='Test';
        contractItem.buildertek__Budget_Item__c=budget1Item.Id;
        contractItem.buildertek__Contract__c=contra.Id;
        contractItem.buildertek__Quantity__c=1;
        contractItem.buildertek__Unit_Price__c=4;
        insert contractItem;



       

      


    
        Test.startTest();

        SubContractOrderFromProjectClass subContract = new SubContractOrderFromProjectClass();
        // Message wrapper
        SubContractOrderFromProjectClass.MessageClass messageWrapper = new SubContractOrderFromProjectClass.MessageClass();
        messageWrapper.Status='Passed';
        messageWrapper.Message='Test';

        // Master Budget wrapper
        SubContractOrderFromProjectClass.MasterBudgetsClass masterBudget = new SubContractOrderFromProjectClass.MasterBudgetsClass();
        masterBudget.budgetRecord=budget1Item;
        masterBudget.budgetCheck=true;


        SubContractOrderFromProjectClass.getMasterBudgets(proj.Id);
        SubContractOrderFromProjectClass.findByName('test', proj.Id);
        SubContractOrderFromProjectClass.findByName1('test', proj.Id);
        SubContractOrderFromProjectClass.findByName2('test', proj.Id);

        SubContractOrderFromProjectClass.Innerclass Innerclass = new SubContractOrderFromProjectClass.Innerclass();
        Innerclass.POId=contra.Id;
        Innerclass.fileName='Test';
        Innerclass.fileContent='Test';

       String fname='test';
       String fcontent='Test';
       String POId=contra.Id;


        // SubContractOrderFromProjectClass.createPO(budgetItem, proj.Id , '[{"fileName":"test" },{"fileContent":"fileContent"},{"POId":"a1U1K000005QdsAUAS"} ]');
        // SubContractOrderFromProjectClass.createPO(budgetItem, proj.Id , '[{"fileName":"test" ;"fileContent":"fileContent"; "POId":"a1U1K000005QdsAUAS"} ]');
        // SubContractOrderFromProjectClass.createPO(budgetItem, proj.Id , '[{"POId":'+contra.Id+',"fileName":"test", "fileContent":"fileContent"}, {"fileName":"test"}]');
        SubContractOrderFromProjectClass.createPO(budgetItem, proj.Id , '[{"fileName":"test" , "fileContent":"fileContent" ,"POId":"'+contra.Id+'"},{"fileContent":"fileContent", "fileName":"test"}]');

        Test.stopTest();


    }

  
}