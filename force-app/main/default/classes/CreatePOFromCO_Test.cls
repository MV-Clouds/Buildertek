@isTest
private class CreatePOFromCO_Test 
{
    @TestSetup
    static void createTestData()
    {
        buildertek__Project__c buildertekProjectRef = Buildertek_UtilityClass.Project();

        buildertek__Change_Order__c changeOrder = new buildertek__Change_Order__c();
        changeOrder.buildertek__Type__c = 'Vendor';
        changeOrder.Name = 'Test Change Order';
        changeOrder.buildertek__Status__c = 'Pending';
        changeOrder.buildertek__Project__c	 = buildertekProjectRef.Id;
        insert changeOrder;

        List<Account> listOfVendors = new List<Account>();

        Account acc1 = new Account();
        acc1.buildertek__BT_Account_Type__c = 'Vendor';
        acc1.name = 'Test Vendor 1';
        listOfVendors.add(acc1);

        Account acc2 = new Account();
        acc2.buildertek__BT_Account_Type__c = 'Vendor';
        acc2.name = 'Test Vendor 2';
        listOfVendors.add(acc2);

        Account acc3 = new Account();
        acc3.buildertek__BT_Account_Type__c = 'Vendor';
        acc3.name = 'Test Vendor 3';
        listOfVendors.add(acc3);

        insert listOfVendors;
    }

    @isTest
    static void testScenario1()
    {
        buildertek__Change_Order__c changeOrder =   [Select Id, Name, 
                                                    buildertek__Project__c,
                                                    buildertek__Budget__c,
                                                    buildertek__Customer_Account__c,
                                                    buildertek__Type__c, 
                                                    buildertek__Status__c,                                              
                                                    buildertek__Vendor__c ,
                                                    buildertek__Due_Date__c,
                                                    buildertek__Total_Amount_Tax__c
                                                    from buildertek__Change_Order__c];
        Test.startTest();
        CreatePOFromCO.ResponseBase responseBaseObj = CreatePOFromCO.CreatePOMethod(changeOrder.Id);
        // System.assertEquals('Please create atleast one Change Order Lines.', responseBaseObj.strMessage );
        Test.stopTest();
    }

    @isTest
    static void testScenario2()
    {
        buildertek__Change_Order__c changeOrder =   [Select Id, Name, 
                                                    buildertek__Project__c,
                                                    buildertek__Budget__c,
                                                    buildertek__Customer_Account__c,
                                                    buildertek__Type__c, 
                                                    buildertek__Status__c,
                                                    buildertek__Vendor__c ,
                                                    buildertek__Due_Date__c,
                                                    buildertek__Total_Amount_Tax__c
                                                    from buildertek__Change_Order__c];
        
        List<buildertek__Change_Order_Item__c> COLineItems = new List<buildertek__Change_Order_Item__c>();

        buildertek__Change_Order_Item__c COL1 = new buildertek__Change_Order_Item__c();
        COL1.buildertek__Change_Order__c = changeOrder.Id;
        COLineItems.add(COL1);

        insert COLineItems;

        Test.startTest();
        CreatePOFromCO.ResponseBase responseBaseObj = CreatePOFromCO.CreatePOMethod(changeOrder.Id);
        // System.assertEquals('Please Choose Vendor either for this Change Order or for all the Change Order Lines.', responseBaseObj.strMessage );
        Test.stopTest();
    }

    @isTest
    static void testScenario3()
    {
        List<Account> vendorList = [Select id,name,buildertek__BT_Account_Type__c from Account];
        buildertek__Change_Order__c changeOrder =   [
            Select
            Id,
            Name,
            buildertek__Project__c,
            buildertek__Budget__c,
            buildertek__Customer_Account__c,
            buildertek__Type__c,
            buildertek__Status__c,
            buildertek__Vendor__c ,
            buildertek__Due_Date__c,
            buildertek__Total_Amount_Tax__c
            from buildertek__Change_Order__c
        ];
        changeOrder.buildertek__Vendor__c = vendorList[0].Id;
        changeOrder.buildertek__Type__c = 'Customer';

        update changeOrder;

        List<buildertek__Change_Order_Item__c> COLineItems = new List<buildertek__Change_Order_Item__c>();

        buildertek__Change_Order_Item__c COL1 = new buildertek__Change_Order_Item__c();
        COL1.buildertek__Change_Order__c = changeOrder.Id;
        // COL1.buildertek__Vendor__c = vendorList[0].Id;
        COLineItems.add(COL1);

        insert COLineItems;

        Test.startTest();
        CreatePOFromCO.ResponseBase responseBaseObj = CreatePOFromCO.CreatePOMethod(changeOrder.Id);
        // System.assertEquals('Success', responseBaseObj.strMessage );
        Test.stopTest();
    }

    @isTest
    static void testScenario4()
    {
        List<Account> vendorList = [Select id,name,buildertek__BT_Account_Type__c from Account];
        buildertek__Change_Order__c changeOrder =   [Select Id, Name,
                                                    buildertek__Project__c,
                                                    buildertek__Budget__c,
                                                    buildertek__Customer_Account__c,
                                                    buildertek__Type__c,
                                                    buildertek__Status__c,
                                                    buildertek__Vendor__c ,
                                                    buildertek__Due_Date__c,
                                                    buildertek__Total_Amount_Tax__c
                                                    from buildertek__Change_Order__c];
        changeOrder.buildertek__Vendor__c = vendorList[0].Id;
        update changeOrder;

        List<buildertek__Change_Order_Item__c> COLineItems = new List<buildertek__Change_Order_Item__c>();

        buildertek__Change_Order_Item__c COL1 = new buildertek__Change_Order_Item__c();
        COL1.buildertek__Change_Order__c = changeOrder.Id;
        COL1.buildertek__Vendor__c = vendorList[1].Id;
        COLineItems.add(COL1);

        buildertek__Change_Order_Item__c COL2 = new buildertek__Change_Order_Item__c();
        COL2.buildertek__Change_Order__c = changeOrder.Id;
        COL2.buildertek__Vendor__c = vendorList[1].Id;
        COLineItems.add(COL2);

        buildertek__Change_Order_Item__c COL3 = new buildertek__Change_Order_Item__c();
        COL3.buildertek__Change_Order__c = changeOrder.Id;
        COL3.buildertek__Vendor__c = vendorList[2].Id;
        COLineItems.add(COL3);

        insert COLineItems;

        Test.startTest();
        CreatePOFromCO.ResponseBase responseBaseObj = CreatePOFromCO.CreatePOMethod(changeOrder.Id);
        // System.assertEquals('Success', responseBaseObj.strMessage );
        Test.stopTest();
    }

    @isTest
    static void testRsponseStructure() {

        CreatePOFromCO.ResponseBase rb = new CreatePOFromCO.ResponseBase();
        rb.isSuccess = true;
        rb.strMessage = '123';
        rb.strRecordId = '123';
    }
}