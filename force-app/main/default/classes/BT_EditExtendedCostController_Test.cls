@isTest
public with sharing class BT_EditExtendedCostController_Test {
    @TestSetup
    static void createTestData() {

        List<Account> listOfVendors = new List<Account>();

        Account acc1 = new Account();
        acc1.buildertek__BT_Account_Type__c = 'Vendor';
        acc1.name = 'Test Vendor 1';
        listOfVendors.add(acc1);
        insert listOfVendors;

        buildertek__Project__c buildertekProjectRef = Buildertek_UtilityClass.Project();

        buildertek__Project_Takeoff__c  projectTakeOff = new buildertek__Project_Takeoff__c ();
        projectTakeOff.buildertek__Project__c = buildertekProjectRef.Id;
        projectTakeOff.buildertek__Name__c = 'Test Takeoff';
        insert projectTakeOff;

        List<buildertek__Project_Takeoff_Lines__c> takeOffLines = new List<buildertek__Project_Takeoff_Lines__c>();
        buildertek__Project_Takeoff_Lines__c projectTakeOffLines = new buildertek__Project_Takeoff_Lines__c();
        projectTakeOffLines.buildertek__Project_Takeoff__c  = projectTakeOff.Id;
       // projectTakeOffLines.buildertek__TL_SERVICE_CATEGORY__c = 'Complete';
       projectTakeOffLines.buildertek__TL_SERVICE_CATEGORY__c = 'Fab & Install';
        takeOffLines.add(projectTakeOffLines);

        buildertek__Project_Takeoff_Lines__c projectTakeOffLines2 = new buildertek__Project_Takeoff_Lines__c();
        projectTakeOffLines2.buildertek__Project_Takeoff__c  = projectTakeOff.Id;
        projectTakeOffLines2.buildertek__TL_SERVICE_CATEGORY__c = 'Install';
        takeOffLines.add(projectTakeOffLines2);

        buildertek__Project_Takeoff_Lines__c projectTakeOffLines3 = new buildertek__Project_Takeoff_Lines__c();
        projectTakeOffLines3.buildertek__Project_Takeoff__c  = projectTakeOff.Id;
        projectTakeOffLines3.buildertek__TL_SERVICE_CATEGORY__c = 'Ins';
        takeOffLines.add(projectTakeOffLines3);

        buildertek__Project_Takeoff_Lines__c projectTakeOffLines4 = new buildertek__Project_Takeoff_Lines__c();
        projectTakeOffLines4.buildertek__Project_Takeoff__c  = projectTakeOff.Id;
        projectTakeOffLines4.buildertek__TL_SERVICE_CATEGORY__c = 'Fab';
        takeOffLines.add(projectTakeOffLines4);


        buildertek__Project_Takeoff_Lines__c projectTakeOffLines5 = new buildertek__Project_Takeoff_Lines__c();
        projectTakeOffLines5.buildertek__Project_Takeoff__c  = projectTakeOff.Id;
        projectTakeOffLines5.buildertek__TL_SERVICE_CATEGORY__c = 'Edge';
        takeOffLines.add(projectTakeOffLines5);

        buildertek__Project_Takeoff_Lines__c projectTakeOffLines6 = new buildertek__Project_Takeoff_Lines__c();
        projectTakeOffLines6.buildertek__Project_Takeoff__c  = projectTakeOff.Id;
        projectTakeOffLines6.buildertek__TL_SERVICE_CATEGORY__c = 'Option';
        takeOffLines.add(projectTakeOffLines6);

        buildertek__Project_Takeoff_Lines__c projectTakeOffLines7 = new buildertek__Project_Takeoff_Lines__c();
        projectTakeOffLines7.buildertek__Project_Takeoff__c  = projectTakeOff.Id;
        projectTakeOffLines7.buildertek__TL_SERVICE_CATEGORY__c = 'Misc';
        takeOffLines.add(projectTakeOffLines7);

        buildertek__Project_Takeoff_Lines__c projectTakeOffLines8 = new buildertek__Project_Takeoff_Lines__c();
        projectTakeOffLines8.buildertek__Project_Takeoff__c  = projectTakeOff.Id;
        projectTakeOffLines8.buildertek__TL_SERVICE_CATEGORY__c = 'Slab - Quartz';// 'Slab'
        takeOffLines.add(projectTakeOffLines8);

        insert takeOffLines;

        List<Product2> prodList = new List<Product2>();
        Product2 prod1 = new Product2();
        prod1.name = 'Test Product 1';
        prod1.ProductCode = 'TestCode';
        prod1.buildertek__Vendor__c = acc1.Id;
        prod1.IsActive = true;

        Product2 prod2 = new Product2();
        prod2.name = 'Test Product 1';
        prod2.ProductCode = 'TestCode2';
        prod2.IsActive = true;
        prod2.buildertek__Vendor__c = acc1.Id;
        prodList.add(prod1);
        prodList.add(prod2);
        insert prodList;

        buildertek__Project_Selection_Sheet_Takeoff__c billOfMeterial = new buildertek__Project_Selection_Sheet_Takeoff__c();
        billOfMeterial.buildertek__Project__c = buildertekProjectRef.Id;
        insert billOfMeterial;

        List<buildertek__Select_Sheet__c> bomLines = new List<buildertek__Select_Sheet__c>();
        buildertek__Select_Sheet__c bomLine1 = new buildertek__Select_Sheet__c();
        bomLine1.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine1.buildertek__Product__c = prod1.Id;
        bomLine1.buildertek__Vendor__c = acc1.Id;
        bomLine1.buildertek__Quantity__c = 2;
        bomLine1.buildertek__Takeoff_Line__c  = projectTakeOffLines.Id;
        bomLines.add(bomLine1);

        buildertek__Select_Sheet__c bomLine2 = new buildertek__Select_Sheet__c();
        bomLine2.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine2.buildertek__Product__c = prod1.Id;
        bomLine2.buildertek__Takeoff_Line__c  = projectTakeOffLines2.Id;
        bomLine2.buildertek__Quantity__c = 2;
        bomLines.add(bomLine2);

        buildertek__Select_Sheet__c bomLine3 = new buildertek__Select_Sheet__c();
        bomLine3.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine3.buildertek__Product__c = prod1.Id;
        bomLine3.buildertek__Vendor__c = acc1.Id;
        bomLine3.buildertek__Takeoff_Line__c  = projectTakeOffLines3.Id;
        bomLine3.buildertek__Quantity__c = 2;
        bomLines.add(bomLine3);

        buildertek__Select_Sheet__c bomLine4 = new buildertek__Select_Sheet__c();
        bomLine4.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine4.buildertek__Product__c = prod1.Id;
        bomLine4.buildertek__Vendor__c = acc1.Id;
        bomLine4.buildertek__Takeoff_Line__c  = projectTakeOffLines4.Id;
        bomLine4.buildertek__Quantity__c = 2;
        bomLines.add(bomLine4);

        buildertek__Select_Sheet__c bomLine5 = new buildertek__Select_Sheet__c();
        bomLine5.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine5.buildertek__Product__c = prod1.Id;
        bomLine5.buildertek__Vendor__c = acc1.Id;
        bomLine5.buildertek__Takeoff_Line__c  = projectTakeOffLines5.Id;
        bomLine5.buildertek__Quantity__c = 2;
        bomLines.add(bomLine5);

        buildertek__Select_Sheet__c bomLine6 = new buildertek__Select_Sheet__c();
        bomLine6.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine6.buildertek__Product__c = prod1.Id;
        bomLine6.buildertek__Vendor__c = acc1.Id;
        bomLine6.buildertek__Takeoff_Line__c  = projectTakeOffLines6.Id;
        bomLine6.buildertek__Quantity__c = 2;
        bomLines.add(bomLine6);

        buildertek__Select_Sheet__c bomLine7 = new buildertek__Select_Sheet__c();
        bomLine7.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine7.buildertek__Product__c = prod1.Id;
        bomLine7.buildertek__Vendor__c = acc1.Id;
        bomLine7.buildertek__Takeoff_Line__c  = projectTakeOffLines7.Id;
        bomLine7.buildertek__Quantity__c = 2;
        bomLines.add(bomLine7);

        buildertek__Select_Sheet__c bomLine8 = new buildertek__Select_Sheet__c();
        bomLine8.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine8.buildertek__Product__c = prod1.Id;
        bomLine8.buildertek__Vendor__c = acc1.Id;
        bomLine8.buildertek__Takeoff_Line__c  = projectTakeOffLines8.Id;
        bomLine8.buildertek__Quantity__c = 2;
        bomLines.add(bomLine8);

        buildertek__Select_Sheet__c bomLine9 = new buildertek__Select_Sheet__c();
        bomLine9.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine9.buildertek__Product__c = prod1.Id;
        bomLine9.buildertek__Vendor__c = acc1.Id;
        bomLine9.buildertek__Takeoff_Line__c  = projectTakeOffLines4.Id;
        bomLine9.buildertek__Quantity__c = 2;
        bomLines.add(bomLine9);

        buildertek__Select_Sheet__c bomLine10 = new buildertek__Select_Sheet__c();
        bomLine10.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine10.buildertek__Product__c = prod1.Id;
        bomLine10.buildertek__Vendor__c = acc1.Id;
        bomLine10.buildertek__Takeoff_Line__c  = projectTakeOffLines4.Id;
        bomLine10.buildertek__Quantity__c = 2;
        bomLines.add(bomLine10);

        buildertek__Select_Sheet__c bomLine11 = new buildertek__Select_Sheet__c();
        bomLine11.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine11.buildertek__Product__c = prod1.Id;
        bomLine11.buildertek__Vendor__c = acc1.Id;
        bomLine11.buildertek__Takeoff_Line__c  = projectTakeOffLines4.Id;
        bomLine11.buildertek__Quantity__c = 2;
        bomLines.add(bomLine11);

        buildertek__Select_Sheet__c bomLine12 = new buildertek__Select_Sheet__c();
        bomLine12.buildertek__Selection_Sheet_Takeoff__c = billOfMeterial.Id;
        bomLine12.buildertek__Product__c = prod1.Id;
        bomLine12.buildertek__Vendor__c = acc1.Id;
        bomLine12.buildertek__Takeoff_Line__c  = projectTakeOffLines4.Id;
        bomLine12.buildertek__Quantity__c = 2;
        bomLines.add(bomLine12);


        insert bomLines;


        //    Pricebook2 standardPricebook = new Pricebook2(
        //   Id = Test.getStandardPricebookId(),
        //   IsActive = true
        //     );
        //     update standardPricebook;

        //     List<PricebookEntry> pricebookEntryList = new List<PricebookEntry>();
        //     PricebookEntry pbe = new PricebookEntry(
        //     Pricebook2Id = standardPricebook.Id,
        //     Product2Id = prod1.Id,
        //     UnitPrice = 1020,
        //     IsActive = true
        //     );
        //     pricebookEntryList.add(pbe);

        Test.startTest();
        billOfMeterial.buildertek__Fabrication_Install_Rate__c = '[{"singleExtendedCostVal":"200","productRate":"100","percentageVal":null,"extendedCostVal":"1400.00","bomLineId":"'+bomLine1.Id+'"}]';
        billOfMeterial.buildertek__Install_Only__c = '[{"singleExtendedCostVal":"200","productRate":"100","percentageVal":null,"extendedCostVal":"1400.00","bomLineId":"'+bomLine2.Id+'"}]';
        billOfMeterial.buildertek__Mark_Up_Non_Slab_or_Labor__c = '[{"singleExtendedCostVal":"200","productRate":"100","percentageVal":null,"extendedCostVal":"1400.00","bomLineId":"'+bomLine3.Id+'"}]';
        billOfMeterial.buildertek__Fab_Only_Rate__c = '[{"singleExtendedCostVal":"200","productRate":"100","percentageVal":10,"extendedCostVal":"1400.00","bomLineId":"'+bomLine4.Id+'"}]';
        billOfMeterial.buildertek__Edge__c = '[{"singleExtendedCostVal":"200","productRate":"100","percentageVal":null,"extendedCostVal":"1400.00","bomLineId":"'+bomLine5.Id+'"}]';
        billOfMeterial.buildertek__Options_Rate__c = '[{"singleExtendedCostVal":"200","productRate":"100","percentageVal":null,"extendedCostVal":"1400.00","bomLineId":"'+bomLine6.Id+'"}]';
        billOfMeterial.buildertek__Miscellaneous_Rates__c = '[{"singleExtendedCostVal":"200","productRate":"100","percentageVal":null,"extendedCostVal":"1400.00","bomLineId":"'+bomLine7.Id+'"}]';
        billOfMeterial.buildertek__Slab_Discount_Rate_LongText__c = '[{"singleExtendedCostVal":"200","productRate":"100","percentageVal":null,"extendedCostVal":"1400.00","bomLineId":"'+bomLine8.Id+'"}]';
        billOfMeterial.buildertek__Fabrication_Labor_Mark_up_LongText__c = '[{"singleExtendedCostVal":"200","productRate":"100","percentageVal":null,"extendedCostVal":"1400.00","bomLineId":"'+bomLine9.Id+'"}]';
        billOfMeterial.buildertek__Workers_Comp__c = '[{"singleExtendedCostVal":"200","productRate":"100","deNominatorVal":"100","percentageVal":null,"extendedCostVal":"1400.00","bomLineId":"'+bomLine10.Id+'"}]';
        billOfMeterial.buildertek__General_Liability_Insurance_Long__c = '[{"singleExtendedCostVal":"200","productRate":"100","deNominatorVal":"100","percentageVal":null,"extendedCostVal":"1400.00","bomLineId":"'+bomLine11.Id+'"}]';
        billOfMeterial.buildertek__Textura_Fee__c = '[{"singleExtendedCostVal":"200","productRate":"100","deNominatorVal":"100","percentageVal":null,"extendedCostVal":"1400.00","bomLineId":"'+bomLine12.Id+'"}]';
        billOfMeterial.buildertek__OCIP_CCIP__c = 1000;


        update billOfMeterial;
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

        // buildertek__BOM_Line_Setting__c settingsList = new buildertek__BOM_Line_Setting__c();
        // settingsList.buildertek__BOM_Line_Filter_Fields__c = '[{"value":"buildertek__Build_Phase__c","label":"Build Phase"},{"value":"buildertek__Vendor__c","label":"Vendor"},{"value":"buildertek__Trade_Type__c","label":"Trade Type"},{"value":"buildertek__Category__c","label":"Category"},{"value":"buildertek__Product_Type__c","label":"Product Type"},{"value":"Name","label":"Name"},{"value":"buildertek__Takeoff_Line__c","label":"Takeoff Line"},{"value":"buildertek__Description__c","label":"Description"}]';
        // settingsList.buildertek__BOM_Line_Selected_Fileds__c = '[{"value":"Name","label":"Name"},{"value":"buildertek__Category__c","label":"Category"},{"value":"buildertek__Takeoff_Line__c","label":"Takeoff Line"},{"value":"buildertek__Product_Code_SKU__c","label":"Product Code/SKU"},{"value":"buildertek__Product_Type__c","label":"Product Type"},{"value":"buildertek__Record_Type__c","label":"Record Type"},{"value":"buildertek__Edge__c","label":"Edge"},{"value":"buildertek__Quantity__c","label":"Quantity"},{"value":"buildertek__BL_UNIT_COST__c","label":"Unit Cost"},{"value":"buildertek__Extended_Cost__c","label":"Extended Cost"}]';
        // settingsList.buildertek__BOM_Line_Selected_Fileds__c = '[{"value":"Name","label":"Name"},{"value":"buildertek__Category__c","label":"Category"},{"value":"buildertek__Takeoff_Line__c","label":"Takeoff Line"},{"value":"buildertek__Product_Code_SKU__c","label":"Product Code/SKU"},{"value":"buildertek__Product_Type__c","label":"Product Type"},{"value":"buildertek__Record_Type__c","label":"Record Type"},{"value":"buildertek__Edge__c","label":"Edge"},{"value":"buildertek__Quantity__c","label":"Quantity"},{"value":"buildertek__BL_UNIT_COST__c","label":"Unit Cost"},{"value":"buildertek__Extended_Cost__c","label":"Extended Cost"}]';
        // insert settingsList;

        // buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = new buildertek__Admin_Interface_Node_Configuration__c();
        // adminInterfaceNodeConfigurations.Name = 'BOM Settings';
        // insert adminInterfaceNodeConfigurations;
        BT_EditExtendedCostController.getOCIPVal(String.valueOf(billOfMeterial.Id));
        /**
         * Coverage increasing logic
         */

        String[] values = new String[]{
            'Id', 'Adjusted Price', 'Percentage To Apply', 'Extended Cost', 'Single Extended Cost',
            'Install Cost', 'Rate', 'Denominator Rate', 'Value', 'Proposal Amount', 'extendedCostVal'
        };
        Object[] fieldWrapsList = new Object[]{};
        List<ManagePOlinesController.fieldWrap> fieldWraps = new List<ManagePOlinesController.fieldWrap>();

        for(String api : values) {
            ManagePOlinesController.fieldWrap fw = new ManagePOlinesController.fieldWrap();
            fw.label = api;
            fw.value = '"{}"';
            fieldWraps.add(fw);
        }
        for(Integer i = 0; i < 3; i++) {
            fieldWrapsList.add(JSON.deserializeUntyped(JSON.serialize(fieldWraps)));
        }

        List<buildertek.ManagePOlinesController.ExtendedCostWrap> costWraps =
            new List<buildertek.ManagePOlinesController.ExtendedCostWrap>();
            costWraps.add(new buildertek.ManagePOlinesController.ExtendedCostWrap());

        BT_EditExtendedCostController.getOCIPValue(String.valueOf(billOfMeterial.Id), costWraps, '123');
        BT_EditExtendedCostController.getExtendedCostFromDB(String.valueOf(billOfMeterial.Id), null, Decimal.valueof(7));
        BT_EditExtendedCostController.getTypePickListValFromBOM();
        // BT_EditExtendedCostController.saveData(
        //     JSON.serialize(fieldWrapsList), 'buildertek__Workers_Comp__c', String.valueOf(billOfMeterial.Id)
        // );
        // BT_EditExtendedCostController.saveData(
        //     JSON.serialize(fieldWrapsList), 'buildertek__Workers_Comp__c', String.valueOf(billOfMeterial.Id)
        // );


        Test.stopTest();
    }

    @isTest
    static void testGetData() {

        List<buildertek__Project_Selection_Sheet_Takeoff__c> selectionSheetTakeOff =
            [
                Select
                	Id,buildertek__Fabrication_Install_Rate__c,buildertek__Install_Only__c,
                	buildertek__Mark_Up_Non_Slab_or_Labor__c,buildertek__Fab_Only_Rate__c,
                	buildertek__Edge__c,buildertek__Miscellaneous_Rates__c,buildertek__Workers_Comp__c,
                	buildertek__Options_Rate__c
                FROM
                	buildertek__Project_Selection_Sheet_Takeoff__c
                LIMIT 1
            ];

        Test.startTest();
        List<List<BT_EditExtendedCostController.fieldWrap>> getData1 =
            BT_EditExtendedCostController.getData(selectionSheetTakeOff[0].Id, 'buildertek__Fabrication_Install_Rate__c');
        List<List<BT_EditExtendedCostController.fieldWrap>> getData2 =
            BT_EditExtendedCostController.getData(selectionSheetTakeOff[0].Id, 'buildertek__Install_Only__c');
        List<List<BT_EditExtendedCostController.fieldWrap>> getData3 =
            BT_EditExtendedCostController.getData(selectionSheetTakeOff[0].Id, 'buildertek__Mark_Up_Non_Slab_or_Labor__c');
        List<List<BT_EditExtendedCostController.fieldWrap>> getData4 =
            BT_EditExtendedCostController.getData(selectionSheetTakeOff[0].Id, 'buildertek__Fab_Only_Rate__c');
        List<List<BT_EditExtendedCostController.fieldWrap>> getData5 =
            BT_EditExtendedCostController.getData(selectionSheetTakeOff[0].Id, 'buildertek__Edge__c');
        List<List<BT_EditExtendedCostController.fieldWrap>> getData6 =
            BT_EditExtendedCostController.getData(selectionSheetTakeOff[0].Id, 'buildertek__Options_Rate__c');
        List<List<BT_EditExtendedCostController.fieldWrap>> getData7 =
            BT_EditExtendedCostController.getData(selectionSheetTakeOff[0].Id, 'buildertek__Miscellaneous_Rates__c');
        List<List<BT_EditExtendedCostController.fieldWrap>> getData8 =
            BT_EditExtendedCostController.getData(selectionSheetTakeOff[0].Id, 'buildertek__Slab_Discount_Rate_LongText__c');
        List<List<BT_EditExtendedCostController.fieldWrap>> getData9 =
            BT_EditExtendedCostController.getData(selectionSheetTakeOff[0].Id, 'buildertek__Fabrication_Labor_Mark_up_LongText__c');
        List<List<BT_EditExtendedCostController.fieldWrap>> getData10 =
            BT_EditExtendedCostController.getData(selectionSheetTakeOff[0].Id, 'buildertek__Workers_Comp__c');
        List<List<BT_EditExtendedCostController.fieldWrap>> getData11 =
            BT_EditExtendedCostController.getData(selectionSheetTakeOff[0].Id, 'buildertek__General_Liability_Insurance_Long__c');
        List<List<BT_EditExtendedCostController.fieldWrap>> getData12 =
            BT_EditExtendedCostController.getData(selectionSheetTakeOff[0].Id, 'buildertek__Textura_Fee__c');

        List<buildertek__Select_Sheet__c> bomLines = [Select Id,Name,buildertek__Vendor__c,buildertek__Product__c,buildertek__Product__r.buildertek__Vendor__c,buildertek__Product__r.Name FROM buildertek__Select_Sheet__c];

        String jsonStr = '[[{\"label\":\"Id\",\"value\":\"'+bomLines[0].Id+'\"},{\"label\":\"SingleExtendedCost\",\"value\":\"\"},{\"label\":\"PriceBookName\",\"value\":\"TestAlgoPriceBook2\"},{\"label\":\"ProductCode\",\"value\":\"69200134\"},{\"label\":\"TakeOffLine\",\"value\":\"TOL-011768\"},{\"label\":\"Name\",\"value\":\"TestAlgoworksCompleteproduct\"},{\"label\":\"ListPrice\",\"value\":\"300.00\"},{\"label\":\"AdjustedPrice\",\"value\":\"500\"},{\"label\":\"Quantity\",\"value\":\"8\"},{\"label\":\"SqFt\"},{\"label\":\"UOM\",\"value\":\"None\"},{\"label\":\"ServiceCategory\",\"value\":\"Fab & Install\"}]]';
        //jsonStr = JSON.serialize(jsonStr);
        BT_EditExtendedCostController.AuraResponse saveData1 = BT_EditExtendedCostController.saveData(jsonStr, 'buildertek__Fabrication_Install_Rate__c', selectionSheetTakeOff[0].Id);

        jsonStr = '[[{\"label\":\"Id\",\"value\":\"'+bomLines[1].Id+'\"},{\"label\":\"SingleExtendedCost\",\"value\":\"\"},{\"label\":\"PriceBookName\",\"value\":\"TestAlgoPriceBook2\"},{\"label\":\"ProductCode\",\"value\":\"69200134\"},{\"label\":\"TakeOffLine\",\"value\":\"TOL-011768\"},{\"label\":\"Name\",\"value\":\"TestAlgoworksCompleteproduct\"},{\"label\":\"ListPrice\",\"value\":\"300.00\"},{\"label\":\"AdjustedPrice\",\"value\":\"500\"},{\"label\":\"Quantity\",\"value\":\"8\"},{\"label\":\"SqFt\"},{\"label\":\"UOM\",\"value\":\"None\"},{\"label\":\"ServiceCategory\",\"value\":\"Fab & Install\"}]]';
        BT_EditExtendedCostController.AuraResponse saveData2 = BT_EditExtendedCostController.saveData(jsonStr, 'buildertek__Install_Only__c', selectionSheetTakeOff[0].Id);

        jsonStr = '[[{\"label\":\"Id\",\"value\":\"'+bomLines[2].Id+'\"},{\"label\":\"SingleExtendedCost\",\"value\":\"\"},{\"label\":\"PriceBookName\",\"value\":\"TestAlgoPriceBook2\"},{\"label\":\"ProductCode\",\"value\":\"69200134\"},{\"label\":\"TakeOffLine\",\"value\":\"TOL-011768\"},{\"label\":\"Name\",\"value\":\"TestAlgoworksCompleteproduct\"},{\"label\":\"ListPrice\",\"value\":\"300.00\"},{\"label\":\"AdjustedPrice\",\"value\":\"500\"},{\"label\":\"Quantity\",\"value\":\"8\"},{\"label\":\"SqFt\"},{\"label\":\"UOM\",\"value\":\"None\"},{\"label\":\"ServiceCategory\",\"value\":\"Fab & Install\"}]]';
        BT_EditExtendedCostController.AuraResponse saveData3 =
            BT_EditExtendedCostController.saveData(selectionSheetTakeOff[0].buildertek__Mark_Up_Non_Slab_or_Labor__c, 'buildertek__Mark_Up_Non_Slab_or_Labor__c', selectionSheetTakeOff[0].Id);

        jsonStr = '[[{\"label\":\"Id\",\"value\":\"'+bomLines[3].Id+'\"},{\"label\":\"SingleExtendedCost\",\"value\":\"\"},{\"label\":\"PriceBookName\",\"value\":\"TestAlgoPriceBook2\"},{\"label\":\"ProductCode\",\"value\":\"69200134\"},{\"label\":\"TakeOffLine\",\"value\":\"TOL-011768\"},{\"label\":\"Name\",\"value\":\"TestAlgoworksCompleteproduct\"},{\"label\":\"ListPrice\",\"value\":\"300.00\"},{\"label\":\"AdjustedPrice\",\"value\":\"500\"},{\"label\":\"Quantity\",\"value\":\"8\"},{\"label\":\"SqFt\"},{\"label\":\"UOM\",\"value\":\"None\"},{\"label\":\"ServiceCategory\",\"value\":\"Fab & Install\"}]]';
        BT_EditExtendedCostController.AuraResponse saveData4 =
            BT_EditExtendedCostController.saveData(selectionSheetTakeOff[0].buildertek__Fab_Only_Rate__c, 'buildertek__Fab_Only_Rate__c', selectionSheetTakeOff[0].Id);

        jsonStr = '[[{\"label\":\"Id\",\"value\":\"'+bomLines[3].Id+'\"},{\"label\":\"SingleExtendedCost\",\"value\":\"\"},{\"label\":\"PriceBookName\",\"value\":\"TestAlgoPriceBook2\"},{\"label\":\"ProductCode\",\"value\":\"69200134\"},{\"label\":\"TakeOffLine\",\"value\":\"TOL-011768\"},{\"label\":\"Name\",\"value\":\"TestAlgoworksCompleteproduct\"},{\"label\":\"ListPrice\",\"value\":\"300.00\"},{\"label\":\"AdjustedPrice\",\"value\":\"500\"},{\"label\":\"Quantity\",\"value\":\"8\"},{\"label\":\"SqFt\"},{\"label\":\"UOM\",\"value\":\"None\"},{\"label\":\"ServiceCategory\",\"value\":\"Fab & Install\"}]]';
        BT_EditExtendedCostController.AuraResponse saveData5 =
            BT_EditExtendedCostController.saveData(selectionSheetTakeOff[0].buildertek__Edge__c, 'buildertek__Edge__c', selectionSheetTakeOff[0].Id);

        jsonStr = '[[{\"label\":\"Id\",\"value\":\"'+bomLines[3].Id+'\"},{\"label\":\"SingleExtendedCost\",\"value\":\"\"},{\"label\":\"PriceBookName\",\"value\":\"TestAlgoPriceBook2\"},{\"label\":\"ProductCode\",\"value\":\"69200134\"},{\"label\":\"TakeOffLine\",\"value\":\"TOL-011768\"},{\"label\":\"Name\",\"value\":\"TestAlgoworksCompleteproduct\"},{\"label\":\"ListPrice\",\"value\":\"300.00\"},{\"label\":\"AdjustedPrice\",\"value\":\"500\"},{\"label\":\"Quantity\",\"value\":\"8\"},{\"label\":\"SqFt\"},{\"label\":\"UOM\",\"value\":\"None\"},{\"label\":\"ServiceCategory\",\"value\":\"Fab & Install\"}]]';
        BT_EditExtendedCostController.AuraResponse saveData6 =
            BT_EditExtendedCostController.saveData(selectionSheetTakeOff[0].buildertek__Options_Rate__c, 'buildertek__Fabrication_Install_Rate__c', selectionSheetTakeOff[0].Id);

        jsonStr = '[[{\"label\":\"Id\",\"value\":\"'+bomLines[3].Id+'\"},{\"label\":\"SingleExtendedCost\",\"value\":\"\"},{\"label\":\"PriceBookName\",\"value\":\"TestAlgoPriceBook2\"},{\"label\":\"ProductCode\",\"value\":\"69200134\"},{\"label\":\"TakeOffLine\",\"value\":\"TOL-011768\"},{\"label\":\"Name\",\"value\":\"TestAlgoworksCompleteproduct\"},{\"label\":\"ListPrice\",\"value\":\"300.00\"},{\"label\":\"AdjustedPrice\",\"value\":\"500\"},{\"label\":\"Quantity\",\"value\":\"8\"},{\"label\":\"SqFt\"},{\"label\":\"UOM\",\"value\":\"None\"},{\"label\":\"ServiceCategory\",\"value\":\"Fab & Install\"}]]';
        BT_EditExtendedCostController.AuraResponse saveData7 =
            BT_EditExtendedCostController.saveData(selectionSheetTakeOff[0].buildertek__Miscellaneous_Rates__c, 'buildertek__Miscellaneous_Rates__c', selectionSheetTakeOff[0].Id);

        Test.stopTest();

        BT_EditExtendedCostController.getTypePickListValFromBOM();
        BT_EditExtendedCostController.saveBOMRecord('123');
        BT_EditExtendedCostController.saveBOMRecord(null);
        BT_EditExtendedCostController.saveBOMRecord(String.valueOf(selectionSheetTakeOff[0].Id));


        /**
         * Coverage increasing logic
         */

        String[] values = new String[]{
            'Id', 'Adjusted Price', 'Percentage To Apply', 'Extended Cost', 'Single Extended Cost',
            'Install Cost', 'Rate', 'Denominator Rate', 'Value', 'Proposal Amount'
        };
        Object[] fieldWrapsList = new Object[]{};
        List<ManagePOlinesController.fieldWrap> fieldWraps = new List<ManagePOlinesController.fieldWrap>();

        for(String api : values) {
            ManagePOlinesController.fieldWrap fw = new ManagePOlinesController.fieldWrap();
            fw.label = api;
            fw.value = api;
            fieldWraps.add(fw);
        }
        for(Integer i = 0; i < 3; i++) {
            fieldWrapsList.add(JSON.deserializeUntyped(JSON.serialize(fieldWraps)));
        }

        List<buildertek.ManagePOlinesController.ExtendedCostWrap> costWraps =
            new List<buildertek.ManagePOlinesController.ExtendedCostWrap>();
            costWraps.add(new buildertek.ManagePOlinesController.ExtendedCostWrap());

        // BT_EditExtendedCostController.getOCIPValue(String.valueOf(bomLines[0].Id), costWraps, '123');
        BT_EditExtendedCostController.getExtendedCostFromDB(String.valueOf(bomLines[0].Id), null, Decimal.valueof(7));
        BT_EditExtendedCostController.getTypePickListValFromBOM();
    }
}