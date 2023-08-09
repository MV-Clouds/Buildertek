public with sharing class BT_EditExtendedCostController 
{


    //Constructor
    public void BT_EditExtendedCostController()
    {
        
    }

    //Aura Handlers
    @AuraEnabled
    public static buildertek__Project_Selection_Sheet_Takeoff__c getOCIPVal(String recordId){
        buildertek__Project_Selection_Sheet_Takeoff__c Porecord = new buildertek__Project_Selection_Sheet_Takeoff__c();
        if(String.isNotBlank(recordId))
        {
            Porecord = [Select Id, Name,buildertek__Type__c,buildertek__Textura_Fee__c,buildertek__Edge__c,buildertek__Options_Rate__c,buildertek__Miscellaneous_Rates__c,buildertek__Workers_Comp__c,buildertek__Fabrication_Install_Rate__c,buildertek__Mark_Up_Non_Slab_or_Labor__c,buildertek__Install_Only__c,buildertek__OCIP_CCIP_Required__c,buildertek__CCIP__c,buildertek__General_Liability_Insurance_Long__c,buildertek__OCIP_CCIP__c,buildertek__Fab_Only_Rate__c,LastModifiedBy.Name, buildertek__Region_State_Country_County__c,buildertek__Tax_Rate_1__c,buildertek__Tax_Rate_2__c,buildertek__Slab_Discount_Rate_LongText__c,buildertek__Fabrication_Labor_Mark_up_LongText__c,buildertek__Tax_on_Fabrication_Required__c from buildertek__Project_Selection_Sheet_Takeoff__c  where Id =: recordId LIMIT 1];
        }
        System.debug('Porecord=='+Porecord);
        return Porecord;
    }
    @AuraEnabled 
    public static Map<String, String> getTypePickListValFromBOM(){
        Map<String, String> options = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = buildertek__Project_Selection_Sheet_Takeoff__c.buildertek__Type__c.getDescribe();
        List<Schema.PicklistEntry> pList = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry p: pList) {
            //Put Picklist Value & Label in Map
            options.put(p.getValue(), p.getLabel());
        }
        return options;
    }
    @AuraEnabled
    public static AuraResponse saveBOMRecord(String recordDetail)
    {
        String response = '';
        String messasge = '';
        boolean success = false;
        try 
        {
            if(String.isNotBlank(recordDetail))
            {
                buildertek__Project_Selection_Sheet_Takeoff__c updatedRecord = (buildertek__Project_Selection_Sheet_Takeoff__c)
                    JSON.deserialize(recordDetail, buildertek__Project_Selection_Sheet_Takeoff__c.class);
                System.debug('#@#@ updatedRecord---'+updatedRecord);
                update updatedRecord;
                response = JSON.serialize(updatedRecord);
                success = true;
            }
        } catch (Exception e) 
        {
            System.debug('#@#@ Exception---'+e.getMessage() );
            messasge = e.getMessage();
            success = false;
        }
        
        return new AuraResponse(success,messasge,response);
    }

    @AuraEnabled
    public Static List<List<fieldWrap>> getData(String bomId,String fieldName)
    {
        List<List<fieldWrap>> finalWrapList = new List<List<fieldWrap>>();
        Map<Id,Decimal> bomLineVstotalCost = new Map<Id,Decimal>();
        Decimal totalExtendedCost = 0;
        String workersCompId = '';
        String generalLiabilityId = '';
        String texturaFeeId = '';

        //Textura Fee Product Codes
        set<String> textursProdCodes = new set<String>();
        textursProdCodes.add('69201198');

        try 
        {
            if(String.isNotBlank(bomId) && String.isNotBlank(fieldName))
            {
                System.debug('fieldName==='+fieldName);
                System.debug('bomId=='+bomId);
                String query = 'SELECT ';
                String fields= ' Id, Name,buildertek__Selection_Sheet_Takeoff__r.buildertek__OCIP_CCIP_Required__c,buildertek__Tax__c,buildertek__BL_LIST_PRICE_F__c,buildertek__BL_LIST_PRICE__c, buildertek__Pricebook_Name__c,buildertek__Selection_Sheet_Takeoff__r.buildertek__Options_Rate__c,buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Labor_Mark_up_LongText__c,buildertek__Selection_Sheet_Takeoff__r.buildertek__Slab_Discount_Rate_LongText__c,buildertek__Selection_Sheet_Takeoff__r.buildertek__Textura_Fee__c,buildertek__Selection_Sheet_Takeoff__r.buildertek__General_Liability_Insurance_Long__c,buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Install_Rate__c,buildertek__Selection_Sheet_Takeoff__r.buildertek__Miscellaneous_Rates__c, buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c,buildertek__Selection_Sheet_Takeoff__r.buildertek__Edge__c, buildertek__Selection_Sheet_Takeoff__r.buildertek__Install_Only__c, buildertek__Selection_Sheet_Takeoff__r.buildertek__Mark_Up_Non_Slab_or_Labor__c, ';
                fields = fields + 'buildertek__Product__r.ProductCode , buildertek__Upgrade_Price__c, buildertek__Selection_Sheet_Takeoff__r.buildertek__Workers_Comp__c,buildertek__Takeoff_Line__r.buildertek__Product_Code__c, buildertek__Service_Category__c, buildertek__BL_SERVICE_CATEGORY__c, buildertek__Takeoff_Line__r.buildertek__Build_Phase__c, buildertek__Takeoff_Line__r.buildertek__Build_Phase__r.Name,buildertek__Takeoff_Line__r.buildertek__Sq_Ft__c, buildertek__Takeoff_Line__r.Name, buildertek__BL_UNIT_COST__c, buildertek__Quantity__c, buildertek__Takeoff_Line__r.buildertek__UOM_PL__c  ';
                query = query+fields+' FROM buildertek__Select_Sheet__c WHERE (buildertek__Selection_Sheet_Takeoff__c =: bomId) ';
                system.debug('#@#@#Query---'+query);
                List<buildertek__Select_Sheet__c> recList = Database.query(query);

                System.debug('recList==='+recList);
                System.debug('recList size==='+recList.size());
                if(recList != null && recList.Size() > 0)
                {
                    for(buildertek__Select_Sheet__c thisBomLine : recList)
                    {
                        system.debug('#@#@#thisBomLine---'+thisBomLine);
                        system.debug('#@#@#ProductCode---'+thisBomLine.buildertek__Takeoff_Line__r.buildertek__Product_Code__c);
                        //For Fabrication and Install rate
                        if(fieldName.equals('buildertek__Fabrication_Install_Rate__c') && 
                           /*String.isNotBlank(thisBomLine.buildertek__Service_Category__c) 
                           && thisBomLine.buildertek__Service_Category__c.equals('Complete') &&*/
                           String.isNotBlank(thisBomLine.buildertek__BL_SERVICE_CATEGORY__c) 
                           && /*thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equals('Complete')*/
                           thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equals('Fab & Install')&&
                        !textursProdCodes.contains(thisBomLine.buildertek__Takeoff_Line__r.buildertek__Product_Code__c) )
                        {
                            System.debug('#@#@Fabrication and Install rate');

                            // for(buildertek__Select_Sheet__c thisBomLine : recList)
                            // {
                                List<fieldWrap> row = new List<fieldWrap>();
                                row.add(new fieldWrap('Id',thisBomLine.Id,false));
                                row.add(new fieldWrap('Single Extended Cost',getSingleExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Install_Rate__c),false));
                                row.add(new fieldWrap('Price Book Name',thisBomLine.buildertek__Pricebook_Name__c,false));
                                row.add(new fieldWrap('Product Code',thisBomLine.buildertek__Product__r.ProductCode,false));
                                row.add(new fieldWrap('TakeOff Line',thisBomLine.buildertek__Takeoff_Line__r.Name,false));
                                row.add(new fieldWrap('Name',thisBomLine.Name,false));
                                row.add(new fieldWrap('List Price',String.valueOf(thisBomLine.buildertek__BL_LIST_PRICE__c),false));
                                // row.add(new fieldWrap('Adjusted Price',getRateValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Install_Rate__c),false));
                                row.add(new fieldWrap('Adjusted Price',String.valueOf(thisBomLine.buildertek__Upgrade_Price__c),false));
                                row.add(new fieldWrap('Quantity',String.valueOf(thisBomLine.buildertek__Quantity__c),false));
                                row.add(new fieldWrap('Sq Ft',String.valueOf(thisBomLine.buildertek__Takeoff_Line__r.buildertek__Sq_Ft__c),false));
                                row.add(new fieldWrap('UOM',thisBomLine.buildertek__Takeoff_Line__r.buildertek__UOM_PL__c,false));
                               // row.add(new fieldWrap('Service Category',thisBomLine.buildertek__Service_Category__c,false));
                                row.add(new fieldWrap('Service Category',thisBomLine.buildertek__BL_SERVICE_CATEGORY__c,false)); 
                                // row.add(new fieldWrap('Extended Cost',getExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Install_Rate__c,thisBomLine.buildertek__Quantity__c)));

                                finalWrapList.add(row); 
                            //}
                        
                        }else if(fieldName.equals('buildertek__Install_Only__c') 
                                 /*&& String.isNotBlank(thisBomLine.buildertek__Service_Category__c)
                                 && thisBomLine.buildertek__Service_Category__c.equals('Install')*/
                                 && String.isNotBlank(thisBomLine.buildertek__BL_SERVICE_CATEGORY__c)
                                 && thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equals('Install')
                        && !textursProdCodes.contains(thisBomLine.buildertek__Takeoff_Line__r.buildertek__Product_Code__c) )
                        {
                            System.debug('#@#@Install Only rate');

                            // for(buildertek__Select_Sheet__c thisBomLine : recList)
                            // {
                                List<fieldWrap> row = new List<fieldWrap>();
                                row.add(new fieldWrap('Id',thisBomLine.Id,false));
                                row.add(new fieldWrap('Single Extended Cost',getSingleExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Install_Only__c),false));
                                row.add(new fieldWrap('Price Book Name',thisBomLine.buildertek__Pricebook_Name__c,false));
                                row.add(new fieldWrap('Product Code',thisBomLine.buildertek__Product__r.ProductCode,false));
                                row.add(new fieldWrap('TakeOff Line',thisBomLine.buildertek__Takeoff_Line__r.Name,false));
                                row.add(new fieldWrap('Name',thisBomLine.Name,false));
                                row.add(new fieldWrap('List Price',String.valueOf(thisBomLine.buildertek__BL_LIST_PRICE__c),false));
                                // row.add(new fieldWrap('Adjusted Price',getRateValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Install_Only__c),false));
                                row.add(new fieldWrap('Adjusted Price',String.valueOf(thisBomLine.buildertek__Upgrade_Price__c),false));
                                row.add(new fieldWrap('Quantity',String.valueOf(thisBomLine.buildertek__Quantity__c),false));
                                row.add(new fieldWrap('Sq Ft',String.valueOf(thisBomLine.buildertek__Takeoff_Line__r.buildertek__Sq_Ft__c),false));
                                row.add(new fieldWrap('UOM',thisBomLine.buildertek__Takeoff_Line__r.buildertek__UOM_PL__c,false));
                               // row.add(new fieldWrap('Service Category',thisBomLine.buildertek__Service_Category__c,false));
                                row.add(new fieldWrap('Service Category',thisBomLine.buildertek__BL_SERVICE_CATEGORY__c,false));
                                // row.add(new fieldWrap('Extended Cost',getExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Install_Only__c,thisBomLine.buildertek__Quantity__c)));

                                finalWrapList.add(row); 
                            //}
                        
                        }else if(fieldName.equals('buildertek__Mark_Up_Non_Slab_or_Labor__c') /*&& ( (String.isBlank(thisBomLine.buildertek__Service_Category__c)) || 
                        (String.isNotBlank(thisBomLine.buildertek__Service_Category__c) && 
                        !thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Fab') && 
                        !thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Complete') && 
                        !thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Install') &&
                        !thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Edge') && 
                        !thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Slab') &&
                        !thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Slab - Quartz') &&
                        !thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Slab - Granite') &&
                        !thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Slab - Porcelain') &&
                        !thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Ins') &&
                        !thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Fabrication') && 
                        !thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Labor') &&*/
                        && !thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('OCIP')
                         && ( (String.isBlank(thisBomLine.buildertek__BL_SERVICE_CATEGORY__c)) || 
                        (String.isNotBlank(thisBomLine.buildertek__BL_SERVICE_CATEGORY__c) && 
                        !thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Fab') && 
                        /*!thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Complete')*/
                         !thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Fab & Install')&& 
                        !thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Install') &&
                        !thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Edge') && 
                        !thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Slab') &&
                        !thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Slab - Quartz') &&
                        !thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Slab - Granite') &&
                        !thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Slab - Porcelain') &&
                        !thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Work Comp') &&
                        //!thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Ins') &&
                        !thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Insurance') &&
                        !thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Fabrication') && 
                        !thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Labor') &&
                        !textursProdCodes.contains(thisBomLine.buildertek__Takeoff_Line__r.buildertek__Product_Code__c) )) 
                        
                        )
                        {
                            System.debug('#@#@Non Slab rate');
                            List<fieldWrap> row = new List<fieldWrap>();
                                row.add(new fieldWrap('Id',thisBomLine.Id,false));
                                row.add(new fieldWrap('Single Extended Cost',getSingleExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Mark_Up_Non_Slab_or_Labor__c),false));
                                row.add(new fieldWrap('Price Book Name',thisBomLine.buildertek__Pricebook_Name__c,false));
                                row.add(new fieldWrap('Product Code',thisBomLine.buildertek__Product__r.ProductCode,false));
                                row.add(new fieldWrap('TakeOff Line',thisBomLine.buildertek__Takeoff_Line__r.Name,false));
                                row.add(new fieldWrap('Name',thisBomLine.Name,false));
                                // row.add(new fieldWrap('Cost Adjustment Rate',getRateValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c)));
                                String placeholderDefaultValue = getParcentValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Mark_Up_Non_Slab_or_Labor__c);
                                if(String.isBlank(placeholderDefaultValue)) {
                                    placeholderDefaultValue = '0.115';
                                }
                                row.add(new fieldWrap('Percentage To Apply',placeholderDefaultValue,false));
                                // row.add(new fieldWrap('Percentage To Apply',getParcentValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Mark_Up_Non_Slab_or_Labor__c)));
                                row.add(new fieldWrap('Quantity',String.valueOf(thisBomLine.buildertek__Quantity__c),false));
                                row.add(new fieldWrap('UOM',thisBomLine.buildertek__Takeoff_Line__r.buildertek__UOM_PL__c,false));
                               // row.add(new fieldWrap('Service Category',thisBomLine.buildertek__Service_Category__c,false));
                                row.add(new fieldWrap('Service Category',thisBomLine.buildertek__BL_SERVICE_CATEGORY__c ,false));
                                // row.add(new fieldWrap('Extended Cost',getExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c,thisBomLine.buildertek__Quantity__c)));

                                finalWrapList.add(row);
                        
                        }else if(fieldName.equals('buildertek__Fab_Only_Rate__c') 
                                 /* && String.isNotBlank(thisBomLine.buildertek__Service_Category__c) 
                                 && thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Fab') */
                                 && String.isNotBlank(thisBomLine.buildertek__BL_SERVICE_CATEGORY__c) 
                                 && thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Fab')
                        && !textursProdCodes.contains(thisBomLine.buildertek__Takeoff_Line__r.buildertek__Product_Code__c) )
                        {
                            System.debug('#@#@Fabrication and Install rate');

                            // for(buildertek__Select_Sheet__c thisBomLine : recList)
                            // {
                                List<fieldWrap> row = new List<fieldWrap>();
                                row.add(new fieldWrap('Id',thisBomLine.Id,false));
                                row.add(new fieldWrap('Single Extended Cost',getSingleExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c),false));
                                row.add(new fieldWrap('Price Book Name',thisBomLine.buildertek__Pricebook_Name__c,false));
                                row.add(new fieldWrap('Product Code',thisBomLine.buildertek__Product__r.ProductCode,false));
                                row.add(new fieldWrap('TakeOff Line',thisBomLine.buildertek__Takeoff_Line__r.Name,false));
                                row.add(new fieldWrap('Name',thisBomLine.Name,false));
                                row.add(new fieldWrap('List Price',String.valueOf(thisBomLine.buildertek__BL_LIST_PRICE__c),false));
                                // row.add(new fieldWrap('Adjusted Price',getRateValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c),false));
                                row.add(new fieldWrap('Adjusted Price',String.valueOf(thisBomLine.buildertek__Upgrade_Price__c),false));
                                // row.add(new fieldWrap('Percentage To Apply',getParcentValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c)));
                                row.add(new fieldWrap('Quantity',String.valueOf(thisBomLine.buildertek__Quantity__c),false));
                                row.add(new fieldWrap('UOM',thisBomLine.buildertek__Takeoff_Line__r.buildertek__UOM_PL__c,false));
                               // row.add(new fieldWrap('Service Category',thisBomLine.buildertek__Service_Category__c,false));
                                row.add(new fieldWrap('Service Category',thisBomLine.buildertek__BL_SERVICE_CATEGORY__c,false));
                                // row.add(new fieldWrap('Extended Cost',getExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c,thisBomLine.buildertek__Quantity__c)));

                                finalWrapList.add(row); 
                            //}
                        
                        }else if(fieldName.equals('buildertek__Edge__c') 
                               /*  && String.isNotBlank(thisBomLine.buildertek__Service_Category__c) 
                                 &&  thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Edge') &&*/
                                 && String.isNotBlank(thisBomLine.buildertek__BL_SERVICE_CATEGORY__c) 
                                 &&  thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Edge') &&
                        !textursProdCodes.contains(thisBomLine.buildertek__Takeoff_Line__r.buildertek__Product_Code__c) )
                        {
                            System.debug('#@#@Edge Rate');

                            
                            List<fieldWrap> row = new List<fieldWrap>();
                            row.add(new fieldWrap('Id',thisBomLine.Id,false));
                            row.add(new fieldWrap('Single Extended Cost',getSingleExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Edge__c),false));
                            row.add(new fieldWrap('Price Book Name',thisBomLine.buildertek__Pricebook_Name__c,false));
                            row.add(new fieldWrap('Product Code',thisBomLine.buildertek__Product__r.ProductCode,false));
                            row.add(new fieldWrap('TakeOff Line',thisBomLine.buildertek__Takeoff_Line__r.Name,false));
                            row.add(new fieldWrap('Name',thisBomLine.Name,false));
                            row.add(new fieldWrap('List Price',String.valueOf(thisBomLine.buildertek__BL_LIST_PRICE__c),false));
                            // row.add(new fieldWrap('Adjusted Price',getRateValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Edge__c),false));
                            row.add(new fieldWrap('Adjusted Price',String.valueOf(thisBomLine.buildertek__Upgrade_Price__c),false));
                            row.add(new fieldWrap('Quantity',String.valueOf(thisBomLine.buildertek__Quantity__c),false));
                            row.add(new fieldWrap('UOM',thisBomLine.buildertek__Takeoff_Line__r.buildertek__UOM_PL__c,false));
                           // row.add(new fieldWrap('Service Category',thisBomLine.buildertek__Service_Category__c,false));
                            row.add(new fieldWrap('Service Category',thisBomLine.buildertek__BL_SERVICE_CATEGORY__c,false));
                            // row.add(new fieldWrap('Extended Cost',getExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Edge__c,thisBomLine.buildertek__Quantity__c)));

                            finalWrapList.add(row); 
                        
                        }else if(fieldName.equals('buildertek__Options_Rate__c')
                                 /*&& ((String.isNotBlank(thisBomLine.buildertek__Service_Category__c) 
                                      && thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Option')) || */
                                 && ((String.isNotBlank(thisBomLine.buildertek__BL_SERVICE_CATEGORY__c) 
                                      && thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Option')) ||
                        (String.isNotBlank(thisBomLine.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c) && thisBomLine.buildertek__Takeoff_Line__r.buildertek__Build_Phase__r.Name.equalsIgnoreCase('Option'))) &&
                        !textursProdCodes.contains(thisBomLine.buildertek__Takeoff_Line__r.buildertek__Product_Code__c) 
                        && !thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('OCIP')
                        && !thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Work Comp')
                        && !thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Insurance'))
                        {
                            System.debug('#@#@OPtions');

                            
                            List<fieldWrap> row = new List<fieldWrap>();
                            row.add(new fieldWrap('Id',thisBomLine.Id,false));
                            row.add(new fieldWrap('Single Extended Cost',getSingleExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Options_Rate__c),false));
                            row.add(new fieldWrap('Price Book Name',thisBomLine.buildertek__Pricebook_Name__c,false));
                            row.add(new fieldWrap('Product Code',thisBomLine.buildertek__Product__r.ProductCode,false));
                            row.add(new fieldWrap('TakeOff Line',thisBomLine.buildertek__Takeoff_Line__r.Name,false));
                            row.add(new fieldWrap('Name',thisBomLine.Name,false));
                            row.add(new fieldWrap('List Price',String.valueOf(thisBomLine.buildertek__BL_LIST_PRICE__c),false));
                            // row.add(new fieldWrap('Adjusted Price',getRateValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Options_Rate__c),false));
                            row.add(new fieldWrap('Adjusted Price',String.valueOf(thisBomLine.buildertek__Upgrade_Price__c),false));
                            row.add(new fieldWrap('Tax','',thisBomLine.buildertek__Tax__c));
                            row.add(new fieldWrap('Quantity',String.valueOf(thisBomLine.buildertek__Quantity__c),false));
                            row.add(new fieldWrap('UOM',thisBomLine.buildertek__Takeoff_Line__r.buildertek__UOM_PL__c,false));
                        //    row.add(new fieldWrap('Service Category',thisBomLine.buildertek__Service_Category__c,false));
                            row.add(new fieldWrap('Service Category',thisBomLine.buildertek__BL_SERVICE_CATEGORY__c,false));
                            // row.add(new fieldWrap('Extended Cost',getExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Options_Rate__c,thisBomLine.buildertek__Quantity__c)));

                            finalWrapList.add(row); 
                        
                        }else if(fieldName.equals('buildertek__Miscellaneous_Rates__c') &&
                        /*String.isNotBlank(thisBomLine.buildertek__Service_Category__c) && 
                        thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Misc') &&*/
                        String.isNotBlank(thisBomLine.buildertek__BL_SERVICE_CATEGORY__c) && 
                        thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Misc') &&
                        !textursProdCodes.contains(thisBomLine.buildertek__Takeoff_Line__r.buildertek__Product_Code__c)
                        )
                        {
                            System.debug('#@#@Misc rate');
                            System.debug('** thisBomLine  ------------------------------->: ' + JSON.serialize(thisBomLine));
                            // for(buildertek__Select_Sheet__c thisBomLine : recList)
                            // {
                                List<fieldWrap> row = new List<fieldWrap>();
                                row.add(new fieldWrap('Id',thisBomLine.Id,false));
                                row.add(new fieldWrap('Single Extended Cost',getSingleExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Miscellaneous_Rates__c),false));
                                row.add(new fieldWrap('Price Book Name',thisBomLine.buildertek__Pricebook_Name__c,false));
                                row.add(new fieldWrap('Product Code',thisBomLine.buildertek__Product__r.ProductCode,false));
                                row.add(new fieldWrap('TakeOff Line',thisBomLine.buildertek__Takeoff_Line__r.Name,false));
                                row.add(new fieldWrap('Name',thisBomLine.Name,false));
                                row.add(new fieldWrap('List Price',String.valueOf(thisBomLine.buildertek__BL_LIST_PRICE__c),false));
                                // row.add(new fieldWrap('Adjusted Price',getRateValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Miscellaneous_Rates__c),false));
                                row.add(new fieldWrap('Adjusted Price',String.valueOf(thisBomLine.buildertek__Upgrade_Price__c),false));
                                row.add(new fieldWrap('Tax','',thisBomLine.buildertek__Tax__c));
                                row.add(new fieldWrap('Quantity',String.valueOf(thisBomLine.buildertek__Quantity__c),false));
                                row.add(new fieldWrap('UOM',thisBomLine.buildertek__Takeoff_Line__r.buildertek__UOM_PL__c,false));
                               // row.add(new fieldWrap('Service Category',thisBomLine.buildertek__Service_Category__c,false));
                               row.add(new fieldWrap('Service Category',thisBomLine.buildertek__BL_SERVICE_CATEGORY__c,false));
                                // row.add(new fieldWrap('Extended Cost',getExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Miscellaneous_Rates__c,thisBomLine.buildertek__Quantity__c)));

                                finalWrapList.add(row); 
                            //}
                        
                        }
                        else if(fieldName.equals('buildertek__Slab_Discount_Rate_LongText__c') 
                               /* && String.isNotBlank(thisBomLine.buildertek__Service_Category__c) && (thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Slab') ||
                                thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Slab - Quartz') || 
                                thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Slab - Granite') || 
                                thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Slab - Porcelain'))*/ 
                               && String.isNotBlank(thisBomLine.buildertek__BL_SERVICE_CATEGORY__c) && (thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Slab') ||
                                thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Slab - Quartz') || 
                                thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Slab - Granite') || 
                                thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Slab - Porcelain')))
                        {
                            System.debug('#@#@Slab Discount Rate');

                            // for(buildertek__Select_Sheet__c thisBomLine : recList)
                            // {
                                List<fieldWrap> row = new List<fieldWrap>();
                                row.add(new fieldWrap('Id',thisBomLine.Id,false));
                                row.add(new fieldWrap('Single Extended Cost',getSingleExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Slab_Discount_Rate_LongText__c),false));
                                row.add(new fieldWrap('Price Book Name',thisBomLine.buildertek__Pricebook_Name__c,false));
                                row.add(new fieldWrap('Product Code',thisBomLine.buildertek__Product__r.ProductCode,false));
                                row.add(new fieldWrap('TakeOff Line',thisBomLine.buildertek__Takeoff_Line__r.Name,false));
                                row.add(new fieldWrap('Name',thisBomLine.Name,false));
                                // row.add(new fieldWrap('Cost Adjustment Rate',getRateValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c)));
                                row.add(new fieldWrap('List Price',String.valueOf(thisBomLine.buildertek__BL_LIST_PRICE__c),false));
                                // row.add(new fieldWrap('Adjusted Price',getRateValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Slab_Discount_Rate_LongText__c),false));
                                row.add(new fieldWrap('Adjusted Price',String.valueOf(thisBomLine.buildertek__Upgrade_Price__c),false));
                                String placeholderDefaultValuefordiscount = getParcentValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Slab_Discount_Rate_LongText__c);
                                System.debug('placeholderDefaultValuefordiscount-->'+placeholderDefaultValuefordiscount);
                                if(String.isBlank(placeholderDefaultValuefordiscount)) {
                                    Decimal disucountvalue = 0.450 * -1;
                                    placeholderDefaultValuefordiscount = String.valueOf(disucountvalue);
                                }
                                if(thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Slab - Quartz')){
                                    row.add(new fieldWrap('Percentage To Apply',placeholderDefaultValuefordiscount,false));   
                                }else{
                                  row.add(new fieldWrap('Percentage To Apply',getParcentValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Slab_Discount_Rate_LongText__c),false));
                                }
                                row.add(new fieldWrap('Tax','',thisBomLine.buildertek__Tax__c));
                                row.add(new fieldWrap('Quantity',String.valueOf(thisBomLine.buildertek__Quantity__c),false));
                                row.add(new fieldWrap('UOM',thisBomLine.buildertek__Takeoff_Line__r.buildertek__UOM_PL__c,false));
                               // row.add(new fieldWrap('Service Category',thisBomLine.buildertek__Service_Category__c,false));
                               row.add(new fieldWrap('Service Category',thisBomLine.buildertek__BL_SERVICE_CATEGORY__c,false));
                            // row.add(new fieldWrap('Extended Cost',getExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c,thisBomLine.buildertek__Quantity__c)));

                                finalWrapList.add(row); 
                            //}
                        
                        }
                        else if(fieldName.equals('buildertek__Fabrication_Labor_Mark_up_LongText__c') 
                                /*&& String.isNotBlank(thisBomLine.buildertek__Service_Category__c) && 
                        !textursProdCodes.contains(thisBomLine.buildertek__Takeoff_Line__r.buildertek__Product_Code__c) &&
                        ( thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Fab') ||
                        thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Install') ||
                        thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Edge') ||
                        thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Complete') || 
                        thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Labor'))*/
                               && String.isNotBlank(thisBomLine.buildertek__BL_SERVICE_CATEGORY__c) && 
                        !textursProdCodes.contains(thisBomLine.buildertek__Takeoff_Line__r.buildertek__Product_Code__c) &&
                        ( thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Fab') ||
                        thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Install') ||
                        thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Edge') ||
                        /*thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Complete')*/
                        thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Fab & Install') || 
                        thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Labor')))
                        {
                            List<fieldWrap> row = new List<fieldWrap>();
                                row.add(new fieldWrap('Id',thisBomLine.Id,false));
                                row.add(new fieldWrap('Single Extended Cost',getSingleExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Labor_Mark_up_LongText__c),false));
                                row.add(new fieldWrap('Price Book Name',thisBomLine.buildertek__Pricebook_Name__c,false));
                                row.add(new fieldWrap('Product Code',thisBomLine.buildertek__Product__r.ProductCode,false));
                                row.add(new fieldWrap('TakeOff Line',thisBomLine.buildertek__Takeoff_Line__r.Name,false));
                                row.add(new fieldWrap('Name',thisBomLine.Name,false));
                                // row.add(new fieldWrap('Cost Adjustment Rate',getRateValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c)));
                                String placeholderDefaultValueforfab = getParcentValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Labor_Mark_up_LongText__c);
                                if(String.isBlank(placeholderDefaultValueforfab)) {
                                    placeholderDefaultValueforfab = '0.115';
                                }
                               row.add(new fieldWrap('Percentage To Apply',placeholderDefaultValueforfab,false));
                              // row.add(new fieldWrap('Percentage To Apply',getParcentValueFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Labor_Mark_up_LongText__c),false));
                                row.add(new fieldWrap('Quantity',String.valueOf(thisBomLine.buildertek__Quantity__c),false));
                                row.add(new fieldWrap('UOM',thisBomLine.buildertek__Takeoff_Line__r.buildertek__UOM_PL__c,false));
                              //  row.add(new fieldWrap('Service Category',thisBomLine.buildertek__Service_Category__c,false));
                                row.add(new fieldWrap('Service Category',thisBomLine.buildertek__BL_SERVICE_CATEGORY__c,false));
                                // row.add(new fieldWrap('Extended Cost',getExtendedCostFromDB(thisBomLine.Id,thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c,thisBomLine.buildertek__Quantity__c)));

                                finalWrapList.add(row);
                        }
                        else if(fieldName.equals('buildertek__Workers_Comp__c') /*&& String.isNotBlank(thisBomLine.buildertek__Service_Category__c)
                        && thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Work Comp')*/&& String.isNotBlank(thisBomLine.buildertek__BL_SERVICE_CATEGORY__c)
                        && thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Work Comp')&& 
                               (thisBomLine.buildertek__Takeoff_Line__r.buildertek__Build_Phase__r.Name.equalsIgnoreCase('Base') 
                                || thisBomLine.buildertek__Takeoff_Line__r.buildertek__Build_Phase__r.Name.equalsIgnoreCase('Option'))) 
                        {
                            System.debug('thisBomLine.buildertek__BL_SERVICE_CATEGORY__c=='+thisBomLine.buildertek__BL_SERVICE_CATEGORY__c);
                            System.debug('thisBomLine.buildertek__Takeoff_Line__r.buildertek__Build_Phase__r.Name=='+thisBomLine.buildertek__Takeoff_Line__r.buildertek__Build_Phase__r.Name);
                            workersCompId = String.valueOf(thisBomLine.Id);
                            String totalCost = '';
                            set<String> fieldNames = new set<String>();
                            fieldNames.add(thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Install_Rate__c);
                            fieldNames.add(thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Install_Only__c);
                            fieldNames.add(thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c);
                            fieldNames.add(thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__Edge__c);


                            for(String fieldString : fieldNames)
                            {
                                System.debug('fieldString=='+fieldString);
                                totalCost = getExtendedCostFromDB(thisBomLine.Id,fieldString,thisBomLine.buildertek__Quantity__c);
                                System.debug('#@#@ totalCost--'+totalCost);
                                if(String.isNotBlank(totalCost))
                                {
                                    break;
                                }
                            }
                            System.debug('#@#@ totalExtendedCost BEFORE--'+totalExtendedCost);
                            if(String.isNotBlank(totalCost))
                            {
                            // system.debug('&&&&jhkghilkbm');
                               // if(thisBomLine.buildertek__Selection_Sheet_Takeoff__r.buildertek__OCIP_CCIP_Required__c == true){
                                 //   system.debug('&&&&jhkghilkbm');
                                    totalExtendedCost = totalExtendedCost + Decimal.valueOf(totalCost).setscale(2);
                               // }else{
                              //      totalExtendedCost = 0;
                               // }
                                
                            }
                            System.debug('#@#@ totalExtendedCost AFTER--'+totalExtendedCost);
                        }
                        else if(fieldName.equals('buildertek__General_Liability_Insurance_Long__c') /*&& String.isNotBlank(thisBomLine.buildertek__Service_Category__c)
                        && thisBomLine.buildertek__Service_Category__c.equalsIgnoreCase('Ins')*/&& String.isNotBlank(thisBomLine.buildertek__BL_SERVICE_CATEGORY__c)
                        && thisBomLine.buildertek__BL_SERVICE_CATEGORY__c.equalsIgnoreCase('Insurance'))
                        //  && (thisBomLine.buildertek__Takeoff_Line__r.buildertek__Build_Phase__r.Name.equalsIgnoreCase('Base') ||
                        //  thisBomLine.buildertek__Takeoff_Line__r.buildertek__Build_Phase__r.Name.equalsIgnoreCase('Alt 1') || // added Alt 1 & option as a build phase condition as a part of CAES-84 issue
                        //  thisBomLine.buildertek__Takeoff_Line__r.buildertek__Build_Phase__r.Name.equalsIgnoreCase('Option') )) 
                        {
                            system.debug('Ins--->');
                            generalLiabilityId = String.valueOf(thisBomLine.Id);
                        }
                        else if(fieldName.equals('buildertek__Textura_Fee__c') && String.isNotBlank(thisBomLine.buildertek__Takeoff_Line__r.buildertek__Product_Code__c)
                        && textursProdCodes.contains(thisBomLine.buildertek__Takeoff_Line__r.buildertek__Product_Code__c) ) 
                        {
                            texturaFeeId = String.valueOf(thisBomLine.Id);
                        }
                    }

                    if(fieldName.equals('buildertek__Workers_Comp__c'))
                    {
                        List<fieldWrap> row = new List<fieldWrap>();
                        row.add(new fieldWrap('Id',workersCompId,false));
                        row.add(new fieldWrap('Id',workersCompId,false));
                        System.debug('totalExtendedCost==='+String.valueOf(totalExtendedCost));
                        row.add(new fieldWrap('Install Cost',String.valueOf(totalExtendedCost),false));
                        String nominatorVal = '';
                        String deNominatorVal = '100';
                        String rateValue = '';
                        
                        if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Workers_Comp__c))
                        {
                            List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Workers_Comp__c, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
                            if(wrapperList != null && wrapperList.size() > 0)
                            {
                                if(wrapperList[0].productRate != null && wrapperList[0].denominatorVal != null)
                                {
                                    nominatorVal = wrapperList[0].productRate;
                                    deNominatorVal = wrapperList[0].deNominatorVal;
                                    rateValue = wrapperList[0].extendedCostVal;
                                }
                            }
                        

                            Decimal deNomiVal = 100.00;
                            Decimal rateVal;

                            if(String.isNotBlank(deNominatorVal))
                            {
                                deNomiVal = Decimal.valueOf(deNominatorVal).setScale(2);
                            }

                            if(String.isNotBlank(nominatorVal) )
                            {
                                rateVal = totalExtendedCost * ((Decimal.valueOf(nominatorVal).setScale(2)) / (deNomiVal));
                                rateVal = rateVal.setScale(2);

                                if(rateVal != null)
                                {
                                    rateValue = String.valueOf(rateVal);
                                }
                            }
                            else{
                                nominatorVal = '1.11'; //added on 24th Aug,2022 fro setting default value in Rate at workers comp
                            }
                        }
                        

                        row.add(new fieldWrap('Rate',nominatorVal,false));
                        row.add(new fieldWrap('Denominator Rate',deNominatorVal,false));
                        row.add(new fieldWrap('Value',rateValue,false));
                        finalWrapList.add(row);
                    }


                    if(fieldName.equals('buildertek__General_Liability_Insurance_Long__c'))
                    {
                        List<fieldWrap> row = new List<fieldWrap>();
                        row.add(new fieldWrap('Id',generalLiabilityId,false));
                        row.add(new fieldWrap('Id',generalLiabilityId,false));
                        
                        String nominatorVal = '1.01';
                        String deNominatorVal = '1000';
                        String rateValue = '';
                        String proposalAmount = '';
                        
                        if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__General_Liability_Insurance_Long__c))
                        {
                            List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__General_Liability_Insurance_Long__c, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
                            if(wrapperList != null && wrapperList.size() > 0)
                            {
                                if(wrapperList[0].productRate != null && wrapperList[0].denominatorVal != null && 
                                wrapperList[0].extendedCostVal != null && wrapperList[0].proposalAmountVal != null)
                                {
                                    nominatorVal = wrapperList[0].productRate;
                                    deNominatorVal = wrapperList[0].deNominatorVal;
                                    rateValue = wrapperList[0].extendedCostVal;
                                    proposalAmount = wrapperList[0].proposalAmountVal;
                                }
                            }
                        }
                        
                        row.add(new fieldWrap('Proposal Amount',proposalAmount,false));
                        row.add(new fieldWrap('Rate',nominatorVal,false));
                        row.add(new fieldWrap('Denominator Rate',deNominatorVal,false));
                        row.add(new fieldWrap('Value',rateValue,false));
                        finalWrapList.add(row);
                    }

                    if(fieldName.equals('buildertek__Textura_Fee__c'))
                    {
                        List<fieldWrap> row = new List<fieldWrap>();
                        row.add(new fieldWrap('Id',texturaFeeId,false));
                        row.add(new fieldWrap('Single Extended Cost','',false));
                        
                        String rate = '3500.00';
                        String rateValue = '';
                        String proposalAmount = '';
                        String extendedCost = '';
                        
                        if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Textura_Fee__c))
                        {
                            List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Textura_Fee__c, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
                            if(wrapperList != null && wrapperList.size() > 0)
                            {
                                System.debug('wrapperList[0].productRate==='+wrapperList[0].productRate);
                                if(wrapperList[0].productRate != null && 
                                wrapperList[0].extendedCostVal != null && wrapperList[0].proposalAmountVal != null)
                                {
                                    rate = wrapperList[0].productRate;
                                    rateValue = wrapperList[0].extendedCostVal;
                                    proposalAmount = wrapperList[0].proposalAmountVal;
                                }
                            }

                            extendedCost = getExtendedCostFromDB(texturaFeeId,recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Textura_Fee__c,Decimal.valueOf(1));
                        }
                        System.debug('rate-->'+rate);
                        row.add(new fieldWrap('Proposal Amount',proposalAmount,false));
                        row.add(new fieldWrap('Rate',rate,false));
                        row.add(new fieldWrap('Value',rateValue,false));
                        row.add(new fieldWrap('Extended Cost','',false));
                        finalWrapList.add(row);
                    }
                    
                }
            }
        } catch (Exception e) 
        {
            System.debug('Exception---'+e.getMessage());
        }
        System.debug('#@#@finalWrapList---'+finalWrapList);
        System.debug('#@#@finalWrapList Size---'+finalWrapList.size() );
        return finalWrapList;
    } 

    private Static String getRateValueFromDB(String bomLineId,String longText)
    {
        String rateValToReturn = '';
        if(String.isNotBlank(bomLineId) && String.isNotBlank(longText))
        {
            
            List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(longText, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
            System.debug('#@#@wrapperList--'+wrapperList);

            for(buildertek.ManagePOlinesController.ExtendedCostWrap wrapObj : wrapperList)
            {
                if(wrapObj.bomLineId == bomLineId)
                {
                    System.debug('#@#@ BOMLINE MAtched');
                    rateValToReturn = wrapObj.adjustedCost;
                }
            }
        }

        return rateValToReturn;
    }

    private Static String getParcentValueFromDB(String bomLineId,String longText)
    {
        String rateValToReturn = '';
        if(String.isNotBlank(bomLineId) && String.isNotBlank(longText))
        {
            
            List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(longText, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
            System.debug('#@#@wrapperList--'+wrapperList);

            for(buildertek.ManagePOlinesController.ExtendedCostWrap wrapObj : wrapperList)
            {
                if(wrapObj.bomLineId == bomLineId)
                {
                    System.debug('#@#@ BOMLINE MAtched');
                    rateValToReturn = wrapObj.percentageVal;
                }
            }
        }

        return rateValToReturn;
    }

    @TestVisible
    private Static String getExtendedCostFromDB(String bomLineId,String longText,Decimal quantity)
    {
        System.debug('bomLineId=='+bomLineId);
        System.debug('longText=='+longText);
        System.debug('quantity=='+quantity);
        String rateValToReturn = '';
        if(String.isNotBlank(bomLineId) && String.isNotBlank(longText) && quantity != null)
        {
            
            List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(longText, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
            System.debug('#@#@wrapperList--'+wrapperList);

            for(buildertek.ManagePOlinesController.ExtendedCostWrap wrapObj : wrapperList)
            {
                System.debug('wrapObj.bomLineId=='+wrapObj.bomLineId);
                System.debug('bomLineId=='+bomLineId);
                if(wrapObj.bomLineId == bomLineId)
                {
                    System.debug('#@#@ BOMLINE MAtched Extended Cost'+wrapObj.bomLineId+'----Quantity---'+quantity+'---wrapObj.singleExtendedCostVal--'+wrapObj.singleExtendedCostVal);
                    //rateValToReturn = wrapObj.extendedCostVal;
                    Decimal singleCost = 0;
                    System.debug('wrapObj.singleExtendedCostVal=='+wrapObj.singleExtendedCostVal);
                    if(String.isNotBlank(wrapObj.singleExtendedCostVal))
                    {
                        singleCost= Decimal.valueOf(wrapObj.singleExtendedCostVal);
                    }
                    //Decimal Quantity = Decimal.valueOf(quantity);
                    System.debug('singleCost=='+singleCost);
                    System.debug('quantity=='+quantity);
                    Decimal valToReturn = singleCost * quantity;
                    rateValToReturn = String.valueOf(valToReturn.setScale(2));
                }
            }
        }

        return rateValToReturn;
    }

    private Static String getSingleExtendedCostFromDB(String bomLineId,String longText)
    {
        String rateValToReturn = '';
        if(String.isNotBlank(bomLineId) && String.isNotBlank(longText))
        {
            
            List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(longText, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
            System.debug('#@#@wrapperList--'+wrapperList);

            for(buildertek.ManagePOlinesController.ExtendedCostWrap wrapObj : wrapperList)
            {
                if(wrapObj.bomLineId == bomLineId)
                {
                    System.debug('#@#@ BOMLINE MAtched Extended Cost');
                    rateValToReturn = wrapObj.singleExtendedCostVal;
                }
            }
        }

        return rateValToReturn;
    }

    @AuraEnabled
    public Static AuraResponse saveData(String jsonString,String fieldToUpdate,String bomId)
    {
        String response = '';
        String messasge = '';
        boolean success = false;
        List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList = new List<buildertek.ManagePOlinesController.ExtendedCostWrap>();
        Map<String,String> bomLineIdVsExtndCost = new Map<String,String>();
        Map<String,Decimal> bomLineIdVsAdjustedPrice = new Map<String,Decimal>();
        Map<String,Boolean> bomLineIdVstax = new Map<String,Boolean>();

     //  try 
      //  {
            if(String.isNotBlank(jsonString) && String.isNotBlank(fieldToUpdate))
            {
                System.debug('#@#@jsonString--'+jsonString);
                List<List<fieldWrap>> finalWrapList = (List<List<fieldWrap>>)JSON.deserialize(jsonString, List<List<fieldWrap>>.Class);
                System.debug('**            finalWrapList-------------------------------->:' + finalWrapList);
                System.debug('**            finalWrapList-------------------------------->:' + finalWrapList.size());    
                if(finalWrapList != null && finalWrapList.size()>0)
                {
                    for(List<fieldWrap> dataList : finalWrapList)
                    {
                        buildertek.ManagePOlinesController.ExtendedCostWrap singleWrapper = new buildertek.ManagePOlinesController.ExtendedCostWrap();
                        for(fieldWrap wrapObj : dataList)
                        {
                            system.debug('wrapObj.label-->'+wrapObj.label);
                            
                            if(wrapObj.label == 'Id')
                            {
                                singleWrapper.bomLineId = wrapObj.value;
                            }
                            else if(wrapObj.label == 'Adjusted Price')
                            {
                                singleWrapper.adjustedCost = wrapObj.value;
                            }
                            else if(wrapObj.label == 'Percentage To Apply')
                            {
                                System.debug('wrapObj.value Percentage To Apply-->'+wrapObj.value);
                                singleWrapper.percentageVal = wrapObj.value;
                            }
                            else if(wrapObj.label == 'Extended Cost')
                            {
                                singleWrapper.extendedCostVal = wrapObj.value;
                            } 
                            else if(wrapObj.label == 'Single Extended Cost')
                            {
                                singleWrapper.singleExtendedCostVal = wrapObj.value;
                            } 
                            else if(wrapObj.label == 'Install Cost')
                            {
                                singleWrapper.installCostVal = wrapObj.value;
                            } 
                            else if(wrapObj.label == 'Rate')
                            {
                                singleWrapper.productRate = wrapObj.value;
                            }   
                            else if(wrapObj.label == 'Denominator Rate')
                            {
                                singleWrapper.denominatorVal = wrapObj.value;
                            } 
                            else if(wrapObj.label == 'Value')
                            {
                                singleWrapper.extendedCostVal = wrapObj.value;
                            }
                            else if(wrapObj.label == 'Proposal Amount')
                            {
                                singleWrapper.proposalAmountVal = wrapObj.value;
                                
                            }else if(wrapObj.label == 'Tax'){
                                 singleWrapper.taxbvalue = wrapObj.taxvalue;
                            }                        
                        }
                        if(String.isNotBlank(singleWrapper.bomLineId) && String.isNotBlank(singleWrapper.adjustedCost))
                        {
                            bomLineIdVsAdjustedPrice.put(singleWrapper.bomLineId,Decimal.valueOf(singleWrapper.adjustedCost) );
                        }else if(String.isNotBlank(singleWrapper.bomLineId) && String.isBlank(singleWrapper.adjustedCost) &&
                        !fieldToUpdate.equals('buildertek__Mark_Up_Non_Slab_or_Labor__c') &&
                        !fieldToUpdate.equals('buildertek__Fabrication_Labor_Mark_up_LongText__c'))
                        {
                            bomLineIdVsAdjustedPrice.put(singleWrapper.bomLineId,null );
                        }
                        bomLineIdVstax.put(singleWrapper.bomLineId,singleWrapper.taxbvalue);
                        bomLineIdVsExtndCost.put(singleWrapper.bomLineId,singleWrapper.extendedCostVal);
                        wrapperList.add(singleWrapper);
                    }

                    system.debug('wrapperList'+wrapperList.size());
                    System.debug('wrapperList===='+wrapperList);
                    if(wrapperList.size() > 0 )
                    {
                        buildertek__Project_Selection_Sheet_Takeoff__c bomToUpdate = new buildertek__Project_Selection_Sheet_Takeoff__c();
                        bomToUpdate.Id = bomId;
                        System.debug('bomId-->'+bomId);

                        if(fieldToUpdate.equals('buildertek__Fabrication_Install_Rate__c'))
                        {
                            bomToUpdate.buildertek__Fabrication_Install_Rate__c = JSON.serialize(wrapperList);
                        }

                        if(fieldToUpdate.equals('buildertek__Install_Only__c'))
                        {
                               bomToUpdate.buildertek__Install_Only__c = JSON.serialize(wrapperList); 
                        }

                        if(fieldToUpdate.equals('buildertek__Fab_Only_Rate__c'))
                        {
                            bomToUpdate.buildertek__Fab_Only_Rate__c = JSON.serialize(wrapperList);
                        }

                        if(fieldToUpdate.equals('buildertek__Mark_Up_Non_Slab_or_Labor__c'))
                        {
                            bomToUpdate.buildertek__Mark_Up_Non_Slab_or_Labor__c = JSON.serialize(wrapperList);
                        }
                        if(fieldToUpdate.equals('buildertek__Miscellaneous_Rates__c'))
                        {
                            bomToUpdate.buildertek__Miscellaneous_Rates__c = JSON.serialize(wrapperList);
                        }
                        if(fieldToUpdate.equals('buildertek__Edge__c'))
                        {
                            bomToUpdate.buildertek__Edge__c = JSON.serialize(wrapperList);
                        }
                        if(fieldToUpdate.equals('buildertek__Options_Rate__c'))
                        {
                            bomToUpdate.buildertek__Options_Rate__c = JSON.serialize(wrapperList);
                        }
                        if(fieldToUpdate.equals('buildertek__Slab_Discount_Rate_LongText__c'))
                        {
                            bomToUpdate.buildertek__Slab_Discount_Rate_LongText__c = JSON.serialize(wrapperList);
                        }
                        if(fieldToUpdate.equals('buildertek__Fabrication_Labor_Mark_up_LongText__c'))
                        {
                            bomToUpdate.buildertek__Fabrication_Labor_Mark_up_LongText__c = JSON.serialize(wrapperList);
                        }
                        if(fieldToUpdate.equals('buildertek__Textura_Fee__c'))
                        {
                            bomToUpdate.buildertek__Textura_Fee__c = JSON.serialize(wrapperList);
                        }
                        if(fieldToUpdate.equals('buildertek__Workers_Comp__c'))
                        {
                            bomToUpdate.buildertek__Workers_Comp__c = JSON.serialize(wrapperList);
                        }
                        if(fieldToUpdate.equals('buildertek__General_Liability_Insurance_Long__c'))
                        {
                            bomToUpdate.buildertek__General_Liability_Insurance_Long__c = JSON.serialize(wrapperList);
                        }
                        system.debug('wrapperList'+wrapperList.size());
                        system.debug('wrapperList===='+wrapperList);

                        system.debug('fieldToUpdate'+fieldToUpdate);
                        system.debug('bomId'+bomId);
                        if(fieldToUpdate.equals('buildertek__General_Liability_Insurance_Long__c') || fieldToUpdate.equals('buildertek__Workers_Comp__c') )
                        {
                            bomToUpdate.buildertek__OCIP_CCIP__c = getOCIPValue(bomId,wrapperList,fieldToUpdate);
                        }
                        
                        System.debug('bomToUpdate-->'+bomToUpdate);
                        update bomToUpdate;


                        if(bomLineIdVsAdjustedPrice != null && bomLineIdVsAdjustedPrice.size() > 0)
                        {
                            List<buildertek__Select_Sheet__c> bomLinesToUpdate = new List<buildertek__Select_Sheet__c>();
                            List<buildertek__Select_Sheet__c> bomLinesToUpdate1 = new List<buildertek__Select_Sheet__c>();
                            for(String bomLineId : bomLineIdVsAdjustedPrice.keySet() )
                            {
                                buildertek__Select_Sheet__c theBomLine = new buildertek__Select_Sheet__c();
                                theBomLine.Id = bomLineId;
                                theBomLine.buildertek__Upgrade_Price__c = bomLineIdVsAdjustedPrice.get(bomLineId);

                                bomLinesToUpdate.add(theBomLine);
                            }

                            System.debug('#@#@ bomLinesToUpdate---'+bomLinesToUpdate);
                            System.debug('#@#@ bomLinesToUpdate---'+bomLinesToUpdate.size() );

                            if(bomLinesToUpdate != null && bomLinesToUpdate.size() > 0)
                            {
                                update bomLinesToUpdate;
                            }
                        }if(bomLineIdVstax.size() > 0){
                            List<buildertek__Select_Sheet__c> bomLinesToUpdate1 = new List<buildertek__Select_Sheet__c>();
                            for(String bomLineId1 : bomLineIdVstax.keySet() )
                            {
                                if(bomLineId1 != ''){
                                    buildertek__Select_Sheet__c theBomLine1 = new buildertek__Select_Sheet__c();
                                    theBomLine1.Id = bomLineId1;
                                    if(bomLineIdVstax.get(bomLineId1) != null){
                                        system.debug('bomLineIdVstax.get(bomLineId1)'+bomLineIdVstax.get(bomLineId1));
                                        theBomLine1.buildertek__Tax__c = bomLineIdVstax.get(bomLineId1);
                                    }
                                    
                                    bomLinesToUpdate1.add(theBomLine1);
                                }
                            }
                            if(bomLinesToUpdate1 != null && bomLinesToUpdate1.size() > 0)
                            {
                                update bomLinesToUpdate1;
                            }
                        }

                        success = true;
                    }
                }
            }
      /*} catch (Exception e) 
        {
            success = false;
            messasge = e.getMessage();
            System.debug('EXCEPTION!!!!!!!!'+e.getMessage());
        }*/

        System.debug('**   bomLineIdVsExtndCost   ------------------------>: ' + bomLineIdVsExtndCost);
        response = JSON.serialize(bomLineIdVsExtndCost);
        return new AuraResponse(success,messasge,response);
    }


    @TestVisible
    private Static Decimal getOCIPValue(String bomId,List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList,String fieldName)
    {
        Decimal ocipValToReturn;
        Decimal workerCompVal = 0;
        Decimal generalLiabilityVal = 0;
        if(String.isNotBlank(bomId) && String.isNotBlank(fieldName) && wrapperList != null && !wrapperList.isEmpty() )
        {
            buildertek__Project_Selection_Sheet_Takeoff__c bomFromDB = [Select id,name,buildertek__General_Liability_Insurance_Long__c,buildertek__Workers_Comp__c,buildertek__OCIP_CCIP__c from buildertek__Project_Selection_Sheet_Takeoff__c where id=:bomId limit 1]; 
            System.debug('** @#@wrapperList OCIP/CCIP---------------------------->:'+ JSON.serialize(wrapperList));
            System.debug('** bomFromDB---------------------------->:'+ JSON.serialize(bomFromDB));


            if(fieldName.equals('buildertek__Workers_Comp__c'))
            {
                system.debug('wrapperList[0].extendedCostVal'+wrapperList[0].extendedCostVal);
                if(wrapperList[0].extendedCostVal != 'NaN'){
                    workerCompVal  = Decimal.valueOf(wrapperList[0].extendedCostVal);
            }
                if(bomFromDB != null && String.isNotBlank(bomFromDB.buildertek__General_Liability_Insurance_Long__c))
                {
                    List<buildertek.ManagePOlinesController.ExtendedCostWrap> generalWrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(bomFromDB.buildertek__General_Liability_Insurance_Long__c, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
                    if(generalWrapperList.size()>0){
                         generalLiabilityVal = Decimal.valueOf(generalWrapperList[0].extendedCostVal);
                    }
                }
            }

            if(fieldName.equals('buildertek__General_Liability_Insurance_Long__c'))
            {
                System.debug('GLS insurance record==='+wrapperList[0]);
                generalLiabilityVal  = Decimal.valueOf(wrapperList[0].extendedCostVal);
                if(bomFromDB != null && String.isNotBlank(bomFromDB.buildertek__Workers_Comp__c) )
                {
                    List<buildertek.ManagePOlinesController.ExtendedCostWrap> workerWrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(bomFromDB.buildertek__Workers_Comp__c, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
                    System.debug('workerWrapperList=='+workerWrapperList);
                    workerCompVal = Decimal.valueOf(workerWrapperList[0].extendedCostVal);
                }
            }

            ocipValToReturn = workerCompVal + generalLiabilityVal;
            ocipValToReturn = ocipValToReturn.setScale(2);
            
        }

        return ocipValToReturn;
    }

    public class fieldWrap{
        @AuraEnabled
        public string label{ get; set; }    
        @AuraEnabled
        public string value{ get; set; } 
        @AuraEnabled
        public boolean taxvalue{ get; set; } 
        
        public fieldWrap(String labelValue, String valueToPut, Boolean taxvalueToPut)
        {
            this.label = labelValue;
            this.value = valueToPut;
            this.taxvalue = taxvalueToPut;
        }
    }

    public class AuraResponse
    {
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public String message;
        @AuraEnabled
        public String response;

        public AuraResponse(Boolean isSuccess, String message,String response)
        {
            this.isSuccess = isSuccess;
            this.message = message;
            this.response = response;
        }

    }

    /**
     * this*BomLine.buildertek__Service_Category__c.equalsIgnoreCase('Slab') replaced with
     * isPresentInSlab(thisBomLine.buildertek__Service_Category__c)
     */
    public static Boolean isPresentInSlab(String valueServiceCategory) {

        String[] slabValues = new String[]{'Slab', 'Slab - Quartz', 'Slab - Granite', 'Slab - Porcelain'};

        if(valueServiceCategory != NULL && valueServiceCategory != '') {

            for(String serviceCategory : slabValues) {

                if(serviceCategory.equalsIgnoreCase(valueServiceCategory)) {
                    return true;
                }
            }
        }


        return false;
    }
}