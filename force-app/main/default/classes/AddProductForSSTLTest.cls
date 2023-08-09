@isTest
public class AddProductForSSTLTest {
    @testSetup
    static void setupMethod(){
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

        Test.startTest();
      

        buildertek__BOM_Line_Setting__c settingsList = new buildertek__BOM_Line_Setting__c();
        settingsList.buildertek__BOM_Line_Filter_Fields__c = '[{"value":"buildertek__Build_Phase__c","label":"Build Phase"},{"value":"buildertek__Vendor__c","label":"Vendor"},{"value":"buildertek__Trade_Type__c","label":"Trade Type"},{"value":"buildertek__Category__c","label":"Category"},{"value":"buildertek__Product_Type__c","label":"Product Type"},{"value":"Name","label":"Name"},{"value":"buildertek__Takeoff_Line__c","label":"Takeoff Line"},{"value":"buildertek__Description__c","label":"Description"}]';
        settingsList.buildertek__BOM_Line_Selected_Fileds__c = '[{"value":"Name","label":"Name"},{"value":"buildertek__Category__c","label":"Category"},{"value":"buildertek__Takeoff_Line__c","label":"Takeoff Line"},{"value":"buildertek__Product_Code_SKU__c","label":"Product Code/SKU"},{"value":"buildertek__Product_Type__c","label":"Product Type"},{"value":"buildertek__Record_Type__c","label":"Record Type"},{"value":"buildertek__Edge__c","label":"Edge"},{"value":"buildertek__Quantity__c","label":"Quantity"},{"value":"buildertek__BL_UNIT_COST__c","label":"Unit Cost"},{"value":"buildertek__Extended_Cost__c","label":"Extended Cost"}]';
        settingsList.buildertek__BOM_Line_Selected_Fileds__c = '[{"value":"Name","label":"Name"},{"value":"buildertek__Category__c","label":"Category"},{"value":"buildertek__Takeoff_Line__c","label":"Takeoff Line"},{"value":"buildertek__Product_Code_SKU__c","label":"Product Code/SKU"},{"value":"buildertek__Product_Type__c","label":"Product Type"},{"value":"buildertek__Record_Type__c","label":"Record Type"},{"value":"buildertek__Edge__c","label":"Edge"},{"value":"buildertek__Quantity__c","label":"Quantity"},{"value":"buildertek__BL_UNIT_COST__c","label":"Unit Cost"},{"value":"buildertek__Extended_Cost__c","label":"Extended Cost"}]';
        insert settingsList;

        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = new buildertek__Admin_Interface_Node_Configuration__c();
        adminInterfaceNodeConfigurations.Name = 'BOM Settings';
        insert adminInterfaceNodeConfigurations;

        buildertek__BOM_Settings__c bomSetting = new buildertek__BOM_Settings__c();
        bomSetting.Name = 'BOM Settings';
        bomSetting.buildertek__BOM_Selected_Fields__c = '[{"value":"Name","label":"TOL #"},{"value":"buildertek__Price_Book__c","label":"Price Book"},{"value":"buildertek__Base_Location__c","label":"Base Location"},{"value":"buildertek__Location__c","label":"Location"},{"value":"buildertek__StockKeepingUnit__c","label":"Product SKU"},{"value":"buildertek__Product_Type__c","label":"Product Type"},{"value":"buildertek__Quantity__c","label":"Quantity"},{"value":"buildertek__TO_LOCATION_DETAIL_REF__c","label":"Location Detail Reference 1"},{"value":"buildertek__TO_REC_TYPE__c","label":"Record Type"},{"value":"CreatedDate","label":"Created Date"}]';
        bomSetting.buildertek__BOM_Line_Selected_Fileds__c = '[{"value":"Name","label":"Name"},{"value":"buildertek__Takeoff_Line__c","label":"Takeoff Line"},{"value":"buildertek__Product_Code_SKU__c","label":"Product Code/SKU"},{"value":"buildertek__Pricebook_Name__c","label":"Pricebook Name"},{"value":"buildertek__Category__c","label":"Category"},{"value":"buildertek__Quantity__c","label":"Quantity"},{"value":"buildertek__Product_Type__c","label":"Product Type"},{"value":"buildertek__BL_UNIT_COST__c","label":"Unit Cost"},{"value":"buildertek__BL_MARKUP__c","label":"Markup"},{"value":"buildertek__BL_DISCOUNT__c","label":"Discount"},{"value":"buildertek__BL_LIST_PRICE__c","label":"List Price"},{"value":"buildertek__Record_Type__c","label":"Record Type"},{"value":"buildertek__Edge__c","label":"Edge"}]';
        bomSetting.buildertek__Product_Selected_Fields__c = '[{"value":"Name","label":"Product Name"},{"value":"buildertek__Category__c","label":"Category"},{"value":"buildertek__Product_Type__c","label":"Product Type"},{"value":"StockKeepingUnit","label":"Product SKU"},{"value":"buildertek__Vendor__c","label":"Vendor"},{"value":"buildertek__BT_COLOR__c","label":"BT Color"}]';
        bomSetting.buildertek__BOM_Line_Filter_Fields__c = '[{"value":"Name","label":"Name"},{"value":"buildertek__Trade_Type__c","label":"Trade Type"},{"value":"buildertek__Product_Type__c","label":"Product Type"},{"value":"buildertek__Category__c","label":"Category"}]';
        bomSetting.buildertek__Takeoff_Filter_Fields__c = '[{"value":"buildertek__Product_Type__c","label":"Product Type"},{"value":"buildertek__Build_Phase__c","label":"Build Phase"},{"value":"buildertek__Quantity__c","label":"Quantity"},{"value":"buildertek__Location__c","label":"Location"}]';
        bomSetting.buildertek__Product_Filter_Fields__c = '[{"value":"Name","label":"Product Name"},{"value":"buildertek__Vendor__c","label":"Vendor"},{"value":"buildertek__Trade_Type__c","label":"Trade Type"},{"value":"buildertek__BT_COLOR__c","label":"BT Color"},{"value":"buildertek__Category__c","label":"Category"}]';
        insert bomSetting;

        buildertek__Package__c thisPack = new buildertek__Package__c();
        // thisPack.name = 'Test';
        thisPack.buildertek__Package_Name__c = 'Test';
        insert thisPack;

        billOfMeterial.buildertek__Fabrication_Install_Rate__c = '[{\"singleExtendedCostVal\":\"\",\"proposalAmountVal\":null,\"productRate\":null,\"percentageVal\":null,\"installCostVal\":null,\"extendedCostVal\":null,\"denominatorVal\":null,\"bomLineId\":\"'+bomLine1.Id+'\",\"adjustedCost\":\"500\"}]';
        billOfMeterial.buildertek__Workers_Comp__c = '[{\"singleExtendedCostVal\":\"\",\"proposalAmountVal\":null,\"productRate\":\"0.2\",\"percentageVal\":null,\"installCostVal\":\"3900.00\",\"extendedCostVal\":\"7.80\",\"denominatorVal\":\"100\",\"bomLineId\":\"'+bomLine2.Id+'\",\"adjustedCost\":null}]';
        billOfMeterial.buildertek__General_Liability_Insurance_Long__c = '[{\"singleExtendedCostVal\":null,\"proposalAmountVal\":\"20834.00\",\"productRate\":\"1.01\",\"percentageVal\":null,\"installCostVal\":null,\"extendedCostVal\":\"21.04\",\"denominatorVal\":\"1000\",\"bomLineId\":\"'+bomLine3.Id+'\",\"adjustedCost\":null}]';
        billOfMeterial.buildertek__Textura_Fee__c = '[{\"singleExtendedCostVal\":null,\"proposalAmountVal\":\"20834.00\",\"productRate\":\"0.0022\",\"percentageVal\":null,\"installCostVal\":null,\"extendedCostVal\":500,\"denominatorVal\":null,\"bomLineId\":\"'+bomLine4.Id+'\",\"adjustedCost\":null}]';
        billOfMeterial.buildertek__Fabrication_Labor_Mark_up_LongText__c = '[{\"singleExtendedCostVal\":\"\",\"proposalAmountVal\":null,\"productRate\":null,\"percentageVal\":\"0.1\",\"installCostVal\":null,\"extendedCostVal\":null,\"denominatorVal\":null,\"bomLineId\":\"'+bomLine1.Id+'\",\"adjustedCost\":null}]';
        update billOfMeterial;
        Test.stopTest();

    }   
    
    @isTest
    static void testMethod1(){ 
        List<buildertek__Project_Takeoff_Lines__c> projectTakeOffLines = [Select Id
                                                                          FROM buildertek__Project_Takeoff_Lines__c
                                                                          LIMIT 1];
        List<Product2> pro = [Select Id, Name FROM Product2];
        List<Pricebook2> pbList = [Select id,name from Pricebook2];
        List<buildertek__Project__c> project = [Select Id FROM buildertek__Project__c LIMIT 1];
        List<buildertek__Project_Selection_Sheet_Takeoff__c> selectionSheetTakeOff = [Select Id
                                                                                      FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                                      LIMIT 1];
        List<buildertek__Project_Takeoff__c> projectTakeOff = [Select Id
                                                               FROM buildertek__Project_Takeoff__c
                                                               LIMIT 1];
        
        List<buildertek__Select_Sheet__c> SSTL = [Select Id
                                                  FROM buildertek__Select_Sheet__c
                                                  LIMIT 1];
        List<String> importTakeOffLineRecords = new List<String>();
        importTakeOffLineRecords.add(pro[0].Id);
        List<String> importProjectTakeOffLineRecords = new List<String>();
        importProjectTakeOffLineRecords.add(projectTakeOffLines[0].Id);  
        List<String> importProjectTakeOffRecords = new List<String>();
        importProjectTakeOffRecords.add(projectTakeOff[0].Id); 
       // AddProductForSSTL.getAllProductsAndTakeOffLines(selectionSheetTakeOff[0].Id,1,1,1,1,1,1,'');
        importTakeOffLineRecords = new List<String>();
        importTakeOffLineRecords.add(SSTL[0].Id);
        Test.startTest();
        AddProductForSSTL.assignProductToSSTLRecord1(1,1,1,1,1,1,JSON.serialize(projectTakeOffLines),pro[0].Id,importTakeOffLineRecords);
        importTakeOffLineRecords = new List<String>();
        importTakeOffLineRecords.add(pro[0].Id);
        AddProductForSSTL.getImages(pro[0].Id);
        AddProductForSSTL.getProjectSelectionSheetTakeOffRec(selectionSheetTakeOff[0].Id);
        AddProductForSSTL.getAllProductsAndSelectedTakeOffLines(selectionSheetTakeOff[0].Id,1,1,1,1,1,1,JSON.serialize(selectionSheetTakeOff));
        AddProductForSSTL.searchQueryResult2(selectionSheetTakeOff[0].Id,1,1,1,1,1,1,'T','T','T','T','T','T','T','T','','','','');
        // AddProductForSSTL.createTakeOffLinesRecords(importTakeOffLineRecords, selectionSheetTakeOff[0].Id, 1, 1, 1, 1, 1, 1, 'T', 'T', 'T', 'T','T', 'T', 'T', 'T', 'T', 'T', 'T','T', importTakeOffLineRecords,importProjectTakeOffLineRecords,project[0].Id);
        //  AddProductForSSTL.retrieveProductRecords(selectionSheetTakeOff[0].Id,1,1,1,1,1,1,'T','T','T','T','T','T','T','T','','','','',JSON.serialize(selectionSheetTakeOff));
        //   AddProductForSSTL.deleteSelectedSSTLRecord(selectionSheetTakeOff[0].Id,1,1,1,1,1,1,'T','T','T','T','T','T','T','T','','','','T',JSON.serialize(selectionSheetTakeOff));
        AddProductForSSTL.getTakeOffLinesData();
        AddProductForSSTL.getProductPrice(pro[0].Id);
        AddProductForSSTL.getProductfamilyRecords('Product2',pbList[0].Id);
        AddProductForSSTL.getTakeoffId(selectionSheetTakeOff[0].Id);
        AddProductForSSTL.getPackageTakeoff();
        Test.stopTest();
    }
    
    @isTest
    static void testMethod2()
    { 
        List<buildertek__Project_Takeoff_Lines__c> projectTakeOffLines = [Select Id
                                                                          FROM buildertek__Project_Takeoff_Lines__c
                                                                          LIMIT 1];
        List<Product2> pro = [Select Id, Name FROM Product2];
        List<buildertek__Project__c> project = [Select Id FROM buildertek__Project__c LIMIT 1];
        List<buildertek__Project_Selection_Sheet_Takeoff__c> selectionSheetTakeOff = [Select Id
                                                                                      FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                                      LIMIT 1];
        
        List<buildertek__Select_Sheet__c> SSTL = [Select Id
                                                  FROM buildertek__Select_Sheet__c
                                                  LIMIT 1];
        List<String> importTakeOffLineRecords = new List<String>();
        importTakeOffLineRecords.add(pro[0].Id);
        List<String> importProjectTakeOffLineRecords = new List<String>();
        AddProductForSSTL.getProjectSelectionSheetTakeOffRec('');
       // AddProductForSSTL.createTakeOffLinesRecords(importTakeOffLineRecords, selectionSheetTakeOff[0].Id, 1, 1, 1, 1, 1, 1, 'T', 'T', 'T', 'T','T', 'T', 'T', 'T', 'T', 'T', 'T','T', importTakeOffLineRecords,importProjectTakeOffLineRecords,project[0].Id);
        AddProductForSSTL.assignProductToSSTLRecord1(1,1,1,1,1,1,JSON.serialize(projectTakeOffLines),'',new List<String>());
        AddProductForSSTL.searchQueryResult2(selectionSheetTakeOff[0].Id,1,1,1,1,1,1,'','','','','','','','','T','T','T','T');
       // AddProductForSSTL.retrieveProductRecords(selectionSheetTakeOff[0].Id,1,1,1,1,1,1,'','','','','','','','','T','T','T','T',JSON.serialize(selectionSheetTakeOff));
       // AddProductForSSTL.deleteSelectedSSTLRecord(selectionSheetTakeOff[0].Id,1,1,1,1,1,1,'','','','','','','','','T','T','T','T',JSON.serialize(selectionSheetTakeOff));
        
    }

    @isTest
    static void testMethod3(){ 
        List<buildertek__Project_Takeoff_Lines__c> projectTakeOffLines = [Select Id
                                                                          FROM buildertek__Project_Takeoff_Lines__c
                                                                          LIMIT 1];
        List<Product2> pro = [Select Id, Name FROM Product2];
        List<buildertek__budget__c> budgets = [Select Id, Name FROM buildertek__budget__c];
        List<Pricebook2> pbList = [Select id,name from Pricebook2];
        List<buildertek__Project__c> project = [Select Id FROM buildertek__Project__c LIMIT 1];
        List<buildertek__Project_Selection_Sheet_Takeoff__c> selectionSheetTakeOff = [Select Id
                                                                                      FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                                      ];
        List<buildertek__Project_Takeoff__c> projectTakeOff = [Select Id
                                                               FROM buildertek__Project_Takeoff__c
                                                               LIMIT 1];
        
        List<buildertek__Select_Sheet__c> SSTL = [Select Id
                                                  FROM buildertek__Select_Sheet__c
                                                  LIMIT 1];

        List<String> prodcutIds = new List<String>{String.valueOf(pro[0].Id)};
        Test.startTest();
        AddProductForSSTL.deleteSelectedProducts(prodcutIds,String.valueOf(selectionSheetTakeOff[0].id));

        List<String> TOLIds = new List<String>{String.valueOf(projectTakeOffLines[0].Id)};
        AddProductForSSTL.deleteTakeoffLines(TOLIds);

        AddProductForSSTL.PackageLinesClass lineClassObj = new AddProductForSSTL.PackageLinesClass();
        List<buildertek__Package_Line__c> packageLinesRecord = lineClassObj.packageLinesRecord;
        List<buildertek__Project_Takeoff_Lines__c> takeOffLinesList = lineClassObj.takeOffLinesList;
        Set<Id> insertedTakeOffLines = lineClassObj.insertedTakeOffLines;
        String Status = lineClassObj.Status;
        string Message = lineClassObj.Message;

        buildertek__Project_Takeoff_Lines__c theTOL = new buildertek__Project_Takeoff_Lines__c();
       // theTOL.buildertek__TL_SERVICE_CATEGORY__c = 'Complete';
        theTOL.buildertek__TL_SERVICE_CATEGORY__c = 'Fab & Install';
        theTOL.buildertek__Product_Code__c = 'complete';
        theTOL.buildertek__Price_Book__c = pbList[0].Id;

        buildertek__Project_Selection_Sheet_Takeoff__c billOfMeterial = new buildertek__Project_Selection_Sheet_Takeoff__c();
        // AddProductForSSTL.savePToffline(JSON.serialize(theTOL),projectTakeOff[0].Id,JSON.serialize(billOfMeterial));

        AddProductForSSTL.getadminvalue();
        prodcutIds.add(String.valueOf(pro[1].Id));
        AddProductForSSTL.productrecords(prodcutIds);
        AddProductForSSTL.updateBOMquantityvalues(SSTL);
        AddProductForSSTL.verifytakeofflines(selectionSheetTakeOff[0].id);
        List<String> bomIds = new List<String>{String.valueOf(selectionSheetTakeOff[0].Id)};
        AddProductForSSTL.updatequantityvalues(selectionSheetTakeOff[0].Id);
        AddProductForSSTL.getpricebooks();
        AddProductForSSTL.getpricebook(budgets[0].Id);
        AddProductForSSTL.getBOMRec(selectionSheetTakeOff[0].id);
        // AddProductForSSTL.getAllProductsAndTakeOffLines(String.valueOf(selectionSheetTakeOff[0].id),0,1,1,1,1,1,'','','',String.valueOf(pbList[0].Id));
        AddProductForSSTL.getAllProductsAndTakeOffLines(String.valueOf(selectionSheetTakeOff[0].id),1,1,1,1,1,1,String.valueOf(pbList[0].Id));
        AddProductForSSTL.validateAndCreateBOMLines(selectionSheetTakeOff[1].id);
        AddProductForSSTL.retrieveProductRecords(String.valueOf(selectionSheetTakeOff[0].id),1,1,1,1,1,1,'','','',JSON.serialize(projectTakeOffLines),String.valueOf(pbList[0].Id));
        Test.stopTest();
    }

    @isTest
    static void testMethod4(){ 
        List<buildertek__Project_Takeoff_Lines__c> projectTakeOffLines = [Select Id
                                                                          FROM buildertek__Project_Takeoff_Lines__c
                                                                          LIMIT 1];
        List<Product2> pro = [Select Id, Name FROM Product2];
        List<buildertek__budget__c> budgets = [Select Id, Name FROM buildertek__budget__c];
        List<Pricebook2> pbList = [Select id,name from Pricebook2];
        List<buildertek__Project__c> project = [Select Id FROM buildertek__Project__c LIMIT 1];
        List<buildertek__Project_Selection_Sheet_Takeoff__c> selectionSheetTakeOff = [Select Id
                                                                                      FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                                      ];
        List<buildertek__Project_Takeoff__c> projectTakeOff = [Select Id
                                                               FROM buildertek__Project_Takeoff__c
                                                               LIMIT 1];
        
        List<buildertek__Select_Sheet__c> SSTL = [Select Id
                                                  FROM buildertek__Select_Sheet__c
                                                  LIMIT 1];

        List<String> prodcutIds = new List<String>{String.valueOf(pro[0].Id)};
        buildertek__Project_Takeoff_Lines__c theTOL = new buildertek__Project_Takeoff_Lines__c();
        theTOL.buildertek__TL_SERVICE_CATEGORY__c = 'Complete';
        theTOL.buildertek__Product_Code__c = 'complete';
        theTOL.buildertek__Price_Book__c = pbList[0].Id;
        Test.startTest();
        AddProductForSSTL.savePToffline(JSON.serialize(theTOL),projectTakeOff[0].Id,JSON.serialize(selectionSheetTakeOff[0]));
        List<String> takeOffLineList = new List<String>();
        takeOffLineList.add(String.valueOf(projectTakeOffLines[0].Id));
        List<String> productIdList = new List<String>();
        productIdList.add(String.valueOf(pro[0].Id));
        //AddProductForSSTL.createTakeOffLinesRecords(prodcutIds,String.valueOf(selectionSheetTakeOff[0].id),1,1,1,1,1,1,'','','',productIdList,takeOffLineList,project[0].Id,String.valueOf(pbList[0].Id));
        //AddProductForSSTL.getFiledNameAndApi();
        //AddProductForSSTL.getProductFiledNameAndApi();
        //AddProductForSSTL.getBOMLineFiledNameAndApi();
        //AddProductForSSTL.fetchObjectRecords();
        //AddProductForSSTL.MessageClass  msgClsObj = new AddProductForSSTL.MessageClass();
        //String Status = msgClsObj.Status;
        //String message = msgClsObj.Message;


        Product2 prodNew = new Product2();
        prodNew.name = 'Textura Product';
        // prodNew.ProductCode = 'complete';
        // prodNew.buildertek__Vendor__c = acc1.Id;
        prodNew.IsActive = true;
        prodNew.family = 'None';
        prodNew.StockKeepingUnit = '5';
        insert prodNew;

        Product2 prodNew2 = new Product2();
        prodNew2.name = 'Textura Product 2';
        // prodNew2.ProductCode = 'complete';
        // prodNew.buildertek__Vendor__c = acc1.Id;
        prodNew2.IsActive = true;
        prodNew2.family = 'None';
        prodNew2.StockKeepingUnit = '8';
        insert prodNew2;

        buildertek__Product_Type__c pdTypeNew = new buildertek__Product_Type__c();
        pdTypeNew.Name = 'CounterTop';
        insert pdTypeNew;


        buildertek__Project_Takeoff__c  projectTakeOffNew = new buildertek__Project_Takeoff__c ();
        projectTakeOffNew.buildertek__Project__c = project[0].Id;
        projectTakeOffNew.buildertek__Name__c = 'Test Takeoff';
        insert projectTakeOffNew;
        
        buildertek__Project_Takeoff_Lines__c projectTakeOffLinesNew = new buildertek__Project_Takeoff_Lines__c();
        projectTakeOffLinesNew.buildertek__Project_Takeoff__c  = projectTakeOffNew.Id;
       // projectTakeOffLinesNew.buildertek__TL_SERVICE_CATEGORY__c = 'Complete';
        projectTakeOffLinesNew.buildertek__TL_SERVICE_CATEGORY__c = 'Fab & Install';
        projectTakeOffLinesNew.buildertek__Product_Code__c = 'complete';
        projectTakeOffLinesNew.buildertek__Price_Book__c = pbList[0].Id;
        projectTakeOffLinesNew.buildertek__Product_Type__c = pdTypeNew.Id;
        
        insert projectTakeOffLinesNew;
        
        
        buildertek__Project_Selection_Sheet_Takeoff__c billOfMeterialNew = new buildertek__Project_Selection_Sheet_Takeoff__c();
        billOfMeterialNew.buildertek__Project__c = project[0].Id;
        billOfMeterialNew.buildertek__Takeoff__c = projectTakeOffNew.Id;
        insert billOfMeterialNew;
        
        buildertek__Select_Sheet__c bomLine1New = new buildertek__Select_Sheet__c();
        bomLine1New.buildertek__Selection_Sheet_Takeoff__c = billOfMeterialNew.Id;
        bomLine1New.buildertek__Product__c = prodNew2.Id;
        bomLine1New.buildertek__Takeoff_Line__c = projectTakeOffLinesNew.Id;
        
        insert bomLine1New;

        buildertek__Select_Sheet__c bomLine2New = new buildertek__Select_Sheet__c();
        bomLine2New.buildertek__Selection_Sheet_Takeoff__c = billOfMeterialNew.Id;
        bomLine2New.buildertek__Product__c = prodNew.Id;
        bomLine2New.buildertek__Takeoff_Line__c = projectTakeOffLinesNew.Id;
        
        insert bomLine2New;
        AddProductForSSTL.updatequantityvalues(billOfMeterialNew.Id);


        Test.stopTest();
    }


    @isTest
    static void testMethod5(){ 
        List<buildertek__Project_Takeoff_Lines__c> projectTakeOffLines = [Select Id
                                                                          FROM buildertek__Project_Takeoff_Lines__c
                                                                          LIMIT 1];
        List<Product2> pro = [Select Id, Name FROM Product2];
        List<buildertek__budget__c> budgets = [Select Id, Name FROM buildertek__budget__c];
        List<Pricebook2> pbList = [Select id,name from Pricebook2];
        List<buildertek__Project__c> project = [Select Id FROM buildertek__Project__c LIMIT 1];
        List<buildertek__Project_Selection_Sheet_Takeoff__c> selectionSheetTakeOff = [Select Id
                                                                                      FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                                      ];
        List<buildertek__Project_Takeoff__c> projectTakeOff = [Select Id
                                                               FROM buildertek__Project_Takeoff__c
                                                               LIMIT 1];
        
        List<buildertek__Select_Sheet__c> SSTL = [Select Id
                                                  FROM buildertek__Select_Sheet__c
                                                  LIMIT 1];

        
        Test.startTest();

        Product2 prodNew = new Product2();
        prodNew.name = 'Textura Product';
        // prod1.ProductCode = 'complete';
        // prodNew.buildertek__Vendor__c = acc1.Id;
        prodNew.IsActive = true;
        prodNew.family = 'None';
        prodNew.StockKeepingUnit = '72356111';
        insert prodNew;


        buildertek__Project_Takeoff__c  projectTakeOffNew = new buildertek__Project_Takeoff__c ();
        projectTakeOffNew.buildertek__Project__c = project[0].Id;
        projectTakeOffNew.buildertek__Name__c = 'Test Takeoff';
        insert projectTakeOffNew;
        
        buildertek__Project_Takeoff_Lines__c projectTakeOffLinesNew = new buildertek__Project_Takeoff_Lines__c();
        projectTakeOffLinesNew.buildertek__Project_Takeoff__c  = projectTakeOffNew.Id;
        projectTakeOffLinesNew.buildertek__TL_SERVICE_CATEGORY__c = 'Complete';
        projectTakeOffLinesNew.buildertek__TL_SERVICE_CATEGORY__c = 'Fab & Install';
        projectTakeOffLinesNew.buildertek__Product_Code__c = 'complete';
        projectTakeOffLinesNew.buildertek__Price_Book__c = pbList[0].Id;
        projectTakeOffLinesNew.buildertek__TO_SUMMARY_VALUE__c = 'Location';
        
        insert projectTakeOffLinesNew;
        
        
        buildertek__Project_Selection_Sheet_Takeoff__c billOfMeterialNew = new buildertek__Project_Selection_Sheet_Takeoff__c();
        billOfMeterialNew.buildertek__Project__c = project[0].Id;
        billOfMeterialNew.buildertek__Takeoff__c = projectTakeOffNew.Id;
        insert billOfMeterialNew;
        
        buildertek__Select_Sheet__c bomLine1New = new buildertek__Select_Sheet__c();
        bomLine1New.buildertek__Selection_Sheet_Takeoff__c = billOfMeterialNew.Id;
        bomLine1New.buildertek__Product__c = prodNew.Id;
        bomLine1New.buildertek__Takeoff_Line__c = projectTakeOffLinesNew.Id;
        bomLine1New.buildertek__Sum_Value__c = 'Location Detailed Area';
        
        insert bomLine1New;

        buildertek__Select_Sheet__c bomLine2New = new buildertek__Select_Sheet__c();
        bomLine2New.buildertek__Selection_Sheet_Takeoff__c = billOfMeterialNew.Id;
        bomLine2New.buildertek__Product__c = prodNew.Id;
        bomLine2New.buildertek__Takeoff_Line__c = projectTakeOffLinesNew.Id;
        bomLine2New.buildertek__Sum_Value__c = 'Location Detailed Area';
        
        insert bomLine2New;
        AddProductForSSTL.updatequantityvalues(billOfMeterialNew.Id);

        prodNew.StockKeepingUnit = '723560000';
        prodNew.ProductCode = 'complete';
        update prodNew;
        AddProductForSSTL.updatequantityvalues(billOfMeterialNew.Id);

        Test.stopTest();
    }
}