@isTest
public class Test_CloneBOM {
    @isTest
    static void testMethod1(){ 
        List<Account> listOfVendors = new List<Account>();

        Account acc1 = new Account();
        acc1.buildertek__BT_Account_Type__c = 'Vendor';
        acc1.name = 'Test Vendor 1';
        listOfVendors.add(acc1);
        insert listOfVendors;

        buildertek__budget__c budget = new buildertek__budget__c();
        budget.name = 'New Budget';
        insert budget;

        buildertek__Project__c buildertekProjectRef = Buildertek_UtilityClass.Project();

        buildertek__Product_Type__c pdType1 = new buildertek__Product_Type__c();
        pdType1.Name = 'CounterTop';
        insert pdType1;
        
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.name = 'Test Product 1';
        prod1.ProductCode = 'complete';
        prod1.buildertek__Vendor__c = acc1.Id;
        prod1.IsActive = true;
        prod1.family = 'None';
        prod1.StockKeepingUnit = '2';
        prodList.add(prod1);

        Product2 prod2 = new Product2();
        prod2.name = 'Test Product 2';
        prod2.ProductCode = 'workers_Comp';
        prod2.IsActive = true;
        prod2.buildertek__Vendor__c = acc1.Id;
        prod2.family = 'None';
        prodList.add(prod2);

        Product2 prod3 = new Product2();
        prod3.name = 'Test Product 3';
        prod3.ProductCode = 'general_Liability';
        prod3.IsActive = true;
        prod3.buildertek__Vendor__c = acc1.Id;
        prod3.family = 'None';
        prodList.add(prod3);

        Product2 prod4 = new Product2();
        prod4.name = 'Test Product 4';
        prod4.ProductCode = '69201198';
        prod4.IsActive = true;
        prod4.buildertek__Vendor__c = acc1.Id;
        prod4.family = 'None';
        prodList.add(prod4);
        insert prodList;

        Pricebook2 standardPricebook = new Pricebook2( Id = Test.getStandardPricebookId(),IsActive = true);
        update standardPricebook;

        List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        PricebookEntry wcPBEntry = new PricebookEntry(
        Pricebook2Id = standardPricebook.Id,
        Product2Id = prod2.Id,
        UnitPrice = 1020,
        IsActive = true
        );
        pricebookEntryList.add(wcPBEntry);

        PricebookEntry glProductPBEntry = new PricebookEntry(
        Pricebook2Id = standardPricebook.Id,
        Product2Id = prod3.Id,
        UnitPrice = 1020,
        IsActive = true
        );
        pricebookEntryList.add(glProductPBEntry);

        PricebookEntry texturaProductPBEntry = new PricebookEntry(
        Pricebook2Id = standardPricebook.Id,
        Product2Id = prod4.Id,
        UnitPrice = 1020,
        IsActive = true
        );
        pricebookEntryList.add(texturaProductPBEntry);

        PricebookEntry completeProductPBEntry = new PricebookEntry(
        Pricebook2Id = standardPricebook.Id,
        Product2Id = prod1.Id,
        UnitPrice = 1020,
        IsActive = true
        );
        pricebookEntryList.add(completeProductPBEntry);
        insert pricebookEntryList;

        buildertek__Project_Takeoff__c  projectTakeOff = new buildertek__Project_Takeoff__c ();
        projectTakeOff.buildertek__Project__c = buildertekProjectRef.Id;
        projectTakeOff.buildertek__Name__c = 'Test Takeoff';
        insert projectTakeOff;

        List<buildertek__Project_Takeoff_Lines__c> takeOffLines = new List<buildertek__Project_Takeoff_Lines__c>();
        buildertek__Project_Takeoff_Lines__c projectTakeOffLines = new buildertek__Project_Takeoff_Lines__c();
        projectTakeOffLines.buildertek__Project_Takeoff__c  = projectTakeOff.Id;
        projectTakeOffLines.buildertek__TL_SERVICE_CATEGORY__c = 'Complete';
        projectTakeOffLines.buildertek__TL_SERVICE_CATEGORY__c = 'Fab & Install';
        projectTakeOffLines.buildertek__Product_Code__c = 'complete';
        projectTakeOffLines.buildertek__Price_Book__c = standardPricebook.Id;
        projectTakeOffLines.buildertek__Product_Type__c = pdType1.Id;

        takeOffLines.add(projectTakeOffLines);

        buildertek__Project_Takeoff_Lines__c projectTakeOffLinesWC = new buildertek__Project_Takeoff_Lines__c();
        projectTakeOffLinesWC.buildertek__Project_Takeoff__c  = projectTakeOff.Id;
        projectTakeOffLinesWC.buildertek__TL_SERVICE_CATEGORY__c = 'Work Comp';
        projectTakeOffLinesWC.buildertek__Product_Code__c = 'workers_Comp';
        projectTakeOffLinesWC.buildertek__Price_Book__c = standardPricebook.Id;

        takeOffLines.add(projectTakeOffLinesWC);

        buildertek__Project_Takeoff_Lines__c projectTakeOffLinesGL = new buildertek__Project_Takeoff_Lines__c();
        projectTakeOffLinesGL.buildertek__Project_Takeoff__c  = projectTakeOff.Id;
        projectTakeOffLinesGL.buildertek__TL_SERVICE_CATEGORY__c = 'Insurance';
        projectTakeOffLinesGL.buildertek__Product_Code__c = 'general_Liability';
        projectTakeOffLinesGL.buildertek__Price_Book__c = standardPricebook.Id;

        takeOffLines.add(projectTakeOffLinesGL);

        buildertek__Project_Takeoff_Lines__c projectTakeOffLinesTextura = new buildertek__Project_Takeoff_Lines__c();
        projectTakeOffLinesTextura.buildertek__Project_Takeoff__c  = projectTakeOff.Id;
        projectTakeOffLinesTextura.buildertek__TL_SERVICE_CATEGORY__c = 'Insurance';
        projectTakeOffLinesTextura.buildertek__Product_Code__c = '69201198';
        projectTakeOffLinesTextura.buildertek__Price_Book__c = standardPricebook.Id;

        takeOffLines.add(projectTakeOffLinesTextura);

        insert takeOffLines;

        //Create BOM
        buildertek__Project_Selection_Sheet_Takeoff__c billOfMeterial = new buildertek__Project_Selection_Sheet_Takeoff__c();
        billOfMeterial.buildertek__Project__c = buildertekProjectRef.Id;
        billOfMeterial.buildertek__Takeoff__c = projectTakeOff.Id;
        insert billOfMeterial;

        buildertek__Project_Selection_Sheet_Takeoff__c billOfMeterial2 = new buildertek__Project_Selection_Sheet_Takeoff__c();
        billOfMeterial2.buildertek__Project__c = buildertekProjectRef.Id;
        billOfMeterial2.buildertek__Takeoff__c = projectTakeOff.Id;
        insert billOfMeterial2;

        //Create BOM Lines
        List<buildertek__Select_Sheet__c> bomLines = new List<buildertek__Select_Sheet__c>();
        buildertek__Select_Sheet__c bomLine1 = new buildertek__Select_Sheet__c();
        bomLine1.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine1.buildertek__Product__c = prod1.Id;
        bomLine1.buildertek__Vendor__c = acc1.Id;
        bomLine1.buildertek__Takeoff_Line__c = projectTakeOffLines.Id;
        bomLines.add(bomLine1);

        buildertek__Select_Sheet__c bomLine2 = new buildertek__Select_Sheet__c();
        bomLine2.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine2.buildertek__Product__c = prod2.Id;
        bomLine2.buildertek__Takeoff_Line__c = projectTakeOffLinesWC.Id;
        bomLines.add(bomLine2);

        buildertek__Select_Sheet__c bomLine3 = new buildertek__Select_Sheet__c();
        bomLine3.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine3.buildertek__Product__c = prod3.Id;
        bomLine3.buildertek__Vendor__c = acc1.Id;
        bomLine3.buildertek__Takeoff_Line__c = projectTakeOffLinesGL.Id;
        bomLines.add(bomLine3);

        buildertek__Select_Sheet__c bomLine4 = new buildertek__Select_Sheet__c();
        bomLine4.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine4.buildertek__Product__c = prod4.Id;
        bomLine4.buildertek__Vendor__c = acc1.Id;
        bomLine4.buildertek__Takeoff_Line__c = projectTakeOffLinesTextura.Id;
        bomLines.add(bomLine4);
        insert bomLines;

        List<List<String>> stringList = new List<List<String>>();
        List<String> IdList = new List<String>();
        IdList.add(billOfMeterial.Id);
        IdList.add(bomLine1.Id);
        IdList.add(bomLine2.Id);
        stringList.add(IdList);
        
        List<List<String>> newstringList = new List<List<String>>();
        List<String> newIdList = new List<String>();
        newIdList.add(projectTakeOff.Id);
        newIdList.add(billOfMeterial.Id);
        newIdList.add(billOfMeterial2.Id);
        newstringList.add(newIdList);
        Test.startTest();
        CloneBOMLines.cloneBOMLine(stringList);
        CloneBOM.cloneBOMLine(newstringList);
        CloneBOM.getCurrentVersion(billOfMeterial.Id);
        Test.stopTest();
    }   
}