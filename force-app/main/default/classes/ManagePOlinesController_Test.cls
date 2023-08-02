@isTest
public with sharing class ManagePOlinesController_Test 
{
    @TestSetup
    static void createTestData()
    {

        List<Account> listOfVendors = new List<Account>();

        Account acc1 = new Account();
        acc1.buildertek__BT_Account_Type__c = 'Vendor';
        acc1.name = 'Test Vendor 1';
        listOfVendors.add(acc1);
        insert listOfVendors;

        buildertek__Project__c buildertekProjectRef = Buildertek_UtilityClass.Project();

        
        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.name = 'Test Product 1';
        prod1.ProductCode = 'complete';
        prod1.buildertek__Vendor__c = acc1.Id;
        prod1.IsActive = true;
        prodList.add(prod1);

        Product2 prod2 = new Product2();
        prod2.name = 'Test Product 2';
        prod2.ProductCode = 'workers_Comp';
        prod2.IsActive = true;
        prod2.buildertek__Vendor__c = acc1.Id;
        prodList.add(prod2);

        Product2 prod3 = new Product2();
        prod3.name = 'Test Product 3';
        prod3.ProductCode = 'general_Liability';
        prod3.IsActive = true;
        prod3.buildertek__Vendor__c = acc1.Id;
        prodList.add(prod3);

        Product2 prod4 = new Product2();
        prod4.name = 'Test Product 4';
        prod4.ProductCode = '69201198';
        prod4.IsActive = true;
        prod4.buildertek__Vendor__c = acc1.Id;
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
      //  projectTakeOffLines.buildertek__TL_SERVICE_CATEGORY__c = 'Complete';
        projectTakeOffLines.buildertek__TL_SERVICE_CATEGORY__c = 'Fab & Install';
        projectTakeOffLines.buildertek__Product_Code__c = 'complete';
        projectTakeOffLines.buildertek__Price_Book__c = standardPricebook.Id;

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


        // Pricebook2 standardPricebook = new Pricebook2(
        // Id = Test.getStandardPricebookId(),
        // IsActive = true
        // );
        // update standardPricebook;

        // List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        // PricebookEntry pbe = new PricebookEntry(
        // Pricebook2Id = standardPricebook.Id,
        // Product2Id = prod1.Id,
        // UnitPrice = 1020,
        // IsActive = true
        // );
        // pricebookEntryList.add(pbe);

        Test.startTest();
        // PricebookEntry pb1 = new PricebookEntry(
        // Pricebook2Id = standardPricebook.Id,
        // Product2Id = prod2.Id,
        // UnitPrice = 1020,
        // IsActive = true
        // );
        // pricebookEntryList.add(pb1);
        // Insert pricebookEntryList;

        // Pricebook2 StdPriceBook = new Pricebook2();
        // StdPriceBook.Name = 'Test Procebook1';
        // StdPriceBook.IsActive = true;
        // //StdPriceBook.IsStandard = true;
        // insert StdPriceBook;

        // PricebookEntry customPrice = new PricebookEntry(
        //     Pricebook2Id = StdPriceBook.Id, Product2Id = prod1.Id,
        //     UnitPrice = 12000, IsActive = true);
        // insert customPrice;

        buildertek__BOM_Line_Setting__c settingsList = new buildertek__BOM_Line_Setting__c();
        settingsList.buildertek__BOM_Line_Filter_Fields__c = '[{"value":"buildertek__Build_Phase__c","label":"Build Phase"},{"value":"buildertek__Vendor__c","label":"Vendor"},{"value":"buildertek__Trade_Type__c","label":"Trade Type"},{"value":"buildertek__Category__c","label":"Category"},{"value":"buildertek__Product_Type__c","label":"Product Type"},{"value":"Name","label":"Name"},{"value":"buildertek__Takeoff_Line__c","label":"Takeoff Line"},{"value":"buildertek__Description__c","label":"Description"}]';
        settingsList.buildertek__BOM_Line_Selected_Fileds__c = '[{"value":"Name","label":"Name"},{"value":"buildertek__Category__c","label":"Category"},{"value":"buildertek__Takeoff_Line__c","label":"Takeoff Line"},{"value":"buildertek__Product_Code_SKU__c","label":"Product Code/SKU"},{"value":"buildertek__Product_Type__c","label":"Product Type"},{"value":"buildertek__Record_Type__c","label":"Record Type"},{"value":"buildertek__Edge__c","label":"Edge"},{"value":"buildertek__Quantity__c","label":"Quantity"},{"value":"buildertek__BL_UNIT_COST__c","label":"Unit Cost"},{"value":"buildertek__Extended_Cost__c","label":"Extended Cost"}]';
        settingsList.buildertek__BOM_Line_Selected_Fileds__c = '[{"value":"Name","label":"Name"},{"value":"buildertek__Category__c","label":"Category"},{"value":"buildertek__Takeoff_Line__c","label":"Takeoff Line"},{"value":"buildertek__Product_Code_SKU__c","label":"Product Code/SKU"},{"value":"buildertek__Product_Type__c","label":"Product Type"},{"value":"buildertek__Record_Type__c","label":"Record Type"},{"value":"buildertek__Edge__c","label":"Edge"},{"value":"buildertek__Quantity__c","label":"Quantity"},{"value":"buildertek__BL_UNIT_COST__c","label":"Unit Cost"},{"value":"buildertek__Extended_Cost__c","label":"Extended Cost"}]';
        insert settingsList;

        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = new buildertek__Admin_Interface_Node_Configuration__c();
        adminInterfaceNodeConfigurations.Name = 'BOM Settings';
        insert adminInterfaceNodeConfigurations;

        billOfMeterial.buildertek__Fabrication_Install_Rate__c = '[{\"singleExtendedCostVal\":\"\",\"proposalAmountVal\":null,\"productRate\":null,\"percentageVal\":null,\"installCostVal\":null,\"extendedCostVal\":null,\"denominatorVal\":null,\"bomLineId\":\"'+bomLine1.Id+'\",\"adjustedCost\":\"500\"}]';
        billOfMeterial.buildertek__Workers_Comp__c = '[{\"singleExtendedCostVal\":\"\",\"proposalAmountVal\":null,\"productRate\":\"0.2\",\"percentageVal\":null,\"installCostVal\":\"3900.00\",\"extendedCostVal\":\"7.80\",\"denominatorVal\":\"100\",\"bomLineId\":\"'+bomLine2.Id+'\",\"adjustedCost\":null}]';
        billOfMeterial.buildertek__General_Liability_Insurance_Long__c = '[{\"singleExtendedCostVal\":null,\"proposalAmountVal\":\"20834.00\",\"productRate\":\"1.01\",\"percentageVal\":null,\"installCostVal\":null,\"extendedCostVal\":\"21.04\",\"denominatorVal\":\"1000\",\"bomLineId\":\"'+bomLine3.Id+'\",\"adjustedCost\":null}]';
        billOfMeterial.buildertek__Textura_Fee__c = '[{\"singleExtendedCostVal\":null,\"proposalAmountVal\":\"20834.00\",\"productRate\":\"0.0022\",\"percentageVal\":null,\"installCostVal\":null,\"extendedCostVal\":500,\"denominatorVal\":null,\"bomLineId\":\"'+bomLine4.Id+'\",\"adjustedCost\":null}]';
        billOfMeterial.buildertek__Fabrication_Labor_Mark_up_LongText__c = '[{\"singleExtendedCostVal\":\"\",\"proposalAmountVal\":null,\"productRate\":null,\"percentageVal\":\"0.1\",\"installCostVal\":null,\"extendedCostVal\":null,\"denominatorVal\":null,\"bomLineId\":\"'+bomLine1.Id+'\",\"adjustedCost\":null}]';
        update billOfMeterial;
        Test.stopTest();
    }
    @isTest
    static void testManagePOlinesController1()
    {
        List<buildertek__Project_Selection_Sheet_Takeoff__c> bomRecords = new List<buildertek__Project_Selection_Sheet_Takeoff__c>();
        buildertek__Project_Selection_Sheet_Takeoff__c bomRecord = [Select Id, Name, buildertek__Project__r.Name from buildertek__Project_Selection_Sheet_Takeoff__c LIMIT 1];
        bomRecords.add(bomRecord);
        List<Product2> productList = [SELECT Id,Name,StockKeepingUnit,buildertek__Vendor__c,buildertek__Vendor__r.Name FROM Product2 ];
        List<buildertek__Select_Sheet__c> bomLines = [Select Id,Name,buildertek__Vendor__c,buildertek__Product__c,buildertek__Product__r.buildertek__Vendor__c,buildertek__Product__r.Name FROM buildertek__Select_Sheet__c];


        Test.startTest();
        ManagePOlinesController.getVendors(bomLines[0].Id);
        ManagePOlinesController.getProject(bomRecord.Id);
        ManagePOlinesController.getAllCountryList();
        ManagePOlinesController.updateBomRecords(bomRecords);
        ManagePOlinesController.getBTAdminRecorDetails(bomRecord.Id);
        ManagePOlinesController.checkFabricationTaxes();
        ManagePOlinesController.deleteBOMLine(bomLines[0].Id);
        ManagePOlinesController.getDropDown('buildertek__Select_Sheet__c','Name');
        ManagePOlinesController.getBOMLineFiledNameAndApi();
        ManagePOlinesController.getTakeOffLinesData();

        System.assert(bomRecord != null);
        Test.stopTest();
        
        //ManagePOlinesController.getprovendors(bomRecord.Id);
        
    }

    @isTest
    static void testManagePOlinesController2()
    {
        List<buildertek__Project_Selection_Sheet_Takeoff__c> bomRecords = new List<buildertek__Project_Selection_Sheet_Takeoff__c>();
        buildertek__Project_Selection_Sheet_Takeoff__c bomRecord = [Select Id, Name,buildertek__Fabrication_Labor_Mark_up_LongText__c, buildertek__General_Liability_Insurance_Long__c,buildertek__Textura_Fee__c, buildertek__Project__r.Name,buildertek__Fabrication_Install_Rate__c,buildertek__Workers_Comp__c from buildertek__Project_Selection_Sheet_Takeoff__c LIMIT 1];
        bomRecords.add(bomRecord);
        List<buildertek__Select_Sheet__c> bomLines = [Select id,name,buildertek__Selection_Sheet_Takeoff__r.buildertek__Project__c,buildertek__Quantity__c FROM buildertek__Select_Sheet__c ];

        Test.startTest();
        ManagePOlinesController.getProductOptionLines(1,1,bomRecord.Id,'Test Vendor 1','','','','','',false,'');
        List<String> selectedIds = new List<String>();
        selectedIds.add(STring.valueOf(bomLines[0].Id));
        selectedIds.add(STring.valueOf(bomLines[1].Id));
        selectedIds.add(STring.valueOf(bomLines[2].Id));
        String message = ManagePOlinesController.createPO(selectedIds,'');
        System.debug('#@#@message--'+message);
        ManagePOlinesController.deleteOptionLine('','',bomLines[0].Id);
        ManagePOlinesController.getproductCodes(bomRecord.Id);
        ManagePOlinesController.getExtendedCosts(bomRecord.Id);
        ManagePOlinesController.getBomLineDetails(bomRecord.Id);
        ManagePOlinesController.calculateOCIP_CCIP(JSON.serialize(bomRecords));
        ManagePOlinesController.getprovendors(bomRecord.Id);
        // ManagePOlinesController.getBomLineDetails(bomRecord.Id);

        System.assert(bomRecord != null);
        Test.stopTest();
    }


    @isTest
    static void testManagePOlinesController3()
    {
        List<buildertek__Project_Selection_Sheet_Takeoff__c> bomRecords = new List<buildertek__Project_Selection_Sheet_Takeoff__c>();
        buildertek__Project_Selection_Sheet_Takeoff__c bomRecord = [Select Id, Name,buildertek__Fabrication_Labor_Mark_up_LongText__c, buildertek__General_Liability_Insurance_Long__c,buildertek__Textura_Fee__c, buildertek__Project__r.Name,buildertek__Fabrication_Install_Rate__c,buildertek__Workers_Comp__c from buildertek__Project_Selection_Sheet_Takeoff__c LIMIT 1];
        bomRecords.add(bomRecord);
        List<buildertek__Select_Sheet__c> bomLines = [Select id,name,buildertek__Product__c,buildertek__Selection_Sheet_Takeoff__r.buildertek__Project__c,buildertek__Quantity__c FROM buildertek__Select_Sheet__c ];
        String str = '{"a131K000008jGKBQA2":["11.5","Base"],"a131K000008jGKCQA2":["11.5","Base"]}';
        Test.startTest();
        ManagePOlinesController.createNewOptionLine(bomLines[0].buildertek__Product__c,bomLines[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Project__c,bomLines[0].Id);
        ManagePOlinesController.createQuoteMethod(bomRecord.Id,str);
        System.assert(bomRecord != null);
        Test.stopTest();
    }
}