public without sharing class ManageBOMlinesController {
    
    @AuraEnabled
    public static buildertek__Project_Selection_Sheet_Takeoff__c getProject(String recordId){
        try {
        String projectName = '';
        buildertek__Project_Selection_Sheet_Takeoff__c Porecord = [Select Id, Name,buildertek__Opportunity__r.Id,buildertek__Opportunity__r.Name,buildertek__Opportunity__r.Description, buildertek__Project__r.Name,buildertek__OCIP_CCIP_Required__c from buildertek__Project_Selection_Sheet_Takeoff__c  where Id =: recordId LIMIT 1];
        projectName = Porecord.buildertek__Project__r.Name;
        System.debug('#@#@Porecord--'+Porecord);
        return Porecord;
            
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
    }

    @AuraEnabled
    public static String GetBOMRecord(String RecordID){
        try {
        String BOMName = '';
        buildertek__Project_Selection_Sheet_Takeoff__c BOMRecord = [SELECT Id, Name,buildertek__Opportunity__r.Id,buildertek__Opportunity__r.Name,buildertek__Opportunity__r.Description, buildertek__Project__r.Name,buildertek__OCIP_CCIP_Required__c FROM buildertek__Project_Selection_Sheet_Takeoff__c WHERE Id =: RecordID LIMIT 1];
        BOMName = BOMRecord.buildertek__Project__r.Name;
        System.debug('#@#@Porecord-- >>    '+BOMRecord);
        return 'BC';
            
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
    }

    @AuraEnabled
    public static RfqDataTableWrapper getProductOptionLines(Integer pageNumber, Integer pageSize, string recordId, String vendorName, String category, String tradeType,String purchaseOrder, String productType, String buildPhase,Boolean toggleValue,String filter){
        try {

        List<buildertek__Select_Sheet__c> productOptionLineList = new List<buildertek__Select_Sheet__c>();
        List<sObject> lstResult = new List<sObject>();
        String sObjectRecordsList = '[]';
        String fieldValues = '';
        List<String> pickListValuesList = new List<String>();
        
        List<Product2> productList = [SELECT Id,Name,StockKeepingUnit,buildertek__Vendor__c,buildertek__Vendor__r.Name FROM Product2];
        Map<String,List<String>> productMapList = new  Map<String,List<String>> ();
        for(Product2 pr : productList){
            if(pr.buildertek__Vendor__c != null){
                if(productMapList.get(pr.Name)!=null){
                    list<string> prList = productMapList.get(pr.Name);
                    prList.add(pr.buildertek__Vendor__r.Name);    
                    productMapList.put(pr.Name,prList);                                        
                }else{
                    list<string> onboardingrec = new list<string>();
                    onboardingrec.add(pr.buildertek__Vendor__r.Name);
                    productMapList.put(pr.Name,onboardingrec);                    
                }
            }

            
            
        }
        
        
        //system.debug(vendorName+''+tradeType+''+description+''+description!='');
        
        Integer offset = (pageNumber - 1) * pageSize;
        //Total Records
        Integer totalRecords = 0;
      /*  if(vendorName != '' || tradeType != '' || purchaseOrder != '' || category != '' || productType != '' || buildPhase != ''){
            system.debug(category+'tradeType'+tradeType+'vendorName'+vendorName);
            String query = 'Select COUNT() FROM buildertek__Select_Sheet__c where (buildertek__Selection_Sheet_Takeoff__c =: recordId) ';
            if(buildPhase != '' && buildPhase != null){
                query = query+ 'AND (buildertek__Build_Phase__r.Name LIKE \'%'+String.escapeSingleQuotes(buildPhase)+'%\')';
            }
            if(tradeType != '' && tradeType != null){
                query = query+ ' AND (buildertek__Trade_Type__r.Name LIKE \'%'+String.escapeSingleQuotes(tradeType)+'%\')';
            }
            if(purchaseOrder != '' && purchaseOrder != null){
                query = query+ ' AND (buildertek__Purchase_Order__r.Name LIKE \'%'+String.escapeSingleQuotes(purchaseOrder)+'%\')';
            }
            if(vendorName != '' && vendorName != null){
                query = query+ 'AND (buildertek__Vendor__r.Name LIKE \'%'+String.escapeSingleQuotes(vendorName)+'%\')';
            }
            if(productType != '' && productType != null){
                query = query+ 'AND (buildertek__Product_Type__r.Name LIKE \'%'+String.escapeSingleQuotes(productType)+'%\')';
                //buildertek__Product_Type__r
            }
            if(category != '' && category != null){
                query = query+ 'AND (buildertek__Category__r.Name LIKE \'%'+String.escapeSingleQuotes(category)+'%\')';
                //buildertek__Category__r
            }
            totalRecords = Database.countQuery(query);
            system.debug(totalRecords);
        }else{
            totalRecords = [SELECT COUNT() FROM buildertek__Select_Sheet__c 
                            where buildertek__Selection_Sheet_Takeoff__c =: recordId];
        }*/
        System.debug('recordId==='+recordId);
        String query = 'Select COUNT() FROM buildertek__Select_Sheet__c where (buildertek__Selection_Sheet_Takeoff__c =: recordId) ';
        query += filter;
        System.debug('query=='+query);
        totalRecords = Database.countQuery(query);
        system.debug('***************************'+totalRecords);
        
        
        Integer recordEnd = pageSize * pageNumber;
        
        //Instance of Contact DataTable Wrapper Class
        RfqDataTableWrapper objDT = new RfqDataTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        //objDT.isProduct= false;
        objDT.totalRecords = totalRecords;
        
                /*        List<String> strids = new List<String>();
        List<AggregateResult> groupList = new List<AggregateResult>();
        if(!toggleValue){
        groupList = [Select Id,buildertek__Build_Phase__r.Name From buildertek__Select_Sheet__c where buildertek__Selection_Sheet_Takeoff__c =: recordId GROUP BY buildertek__Build_Phase__r.Name,Id];
        }else{
        groupList = [Select Id,buildertek__Vendor__r.Name From buildertek__Select_Sheet__c where buildertek__Selection_Sheet_Takeoff__c =: recordId GROUP BY buildertek__Vendor__r.Name,Id];
        }
        system.debug(groupList);
        for(AggregateResult agg : groupList){
        
        strids.add(agg.Id);
        }
        system.debug(strids);*/
        
        
                
        // dynamic query for filter and field
        // String jsonSerializeFields='';
        // String jsonSerializeFields1='';
        // buildertek__BOM_Line_Setting__c settingsrec = new buildertek__BOM_Line_Setting__c();
        // list<buildertek__BOM_Line_Setting__c>  settingsList = [Select id,Name, buildertek__BOM_Line_Filter_Fields__c,
        //                                                        buildertek__BOM_Line_Selected_Fileds__c
        //                                                        From buildertek__BOM_Line_Setting__c 
        //                                                        limit 1];        
        // String FieldsDefaultValues =    '[{"label":"Name","value":"Name"}]';
        
        
        // if(settingsList.size()>0)  {
            
        //     settingsrec =  settingsList[0]; 
        //     if(settingsList[0].buildertek__BOM_Line_Selected_Fileds__c !=null){
        //         jsonSerializeFields = settingsList[0].buildertek__BOM_Line_Selected_Fileds__c;      
        //     } else{
        //         jsonSerializeFields = FieldsDefaultValues;
        //     }
        //     if(settingsList[0].buildertek__BOM_Line_Filter_Fields__c !=null){
        //         jsonSerializeFields1 = settingsList[0].buildertek__BOM_Line_Filter_Fields__c;      
        //     } else{
        //         jsonSerializeFields1 = FieldsDefaultValues;
        //     }
            
            
        // } else  {
        //     jsonSerializeFields =   FieldsDefaultValues;          
        //     jsonSerializeFields1 =   FieldsDefaultValues;          
        // }
        
        // String jsonSerializeFields = '[{"value": "buildertek__Takeoff_Line__c","label": "Takeoff Line"},{"value": "buildertek__Pricebook_Name__c","label": "Pricebook Name"},{"value": "Name","label": "Product Name Proposal"},{"value": "buildertek__Quantity__c","label": "Quantity"},{"value": "buildertek__BL_LIST_PRICE__c","label": "List Price"},{"value": "buildertek__UOM_PL__c","label": "UOM"},{"value": "buildertek__Tax__c","label": "Tax"},{"value": "buildertek__Tax_Percent__c","label": "Tax (%)"},{"value": "buildertek__BL_MARKUP__c","label": "Markup"}]';
        String jsonSerializeFields = '[';
        jsonSerializeFields += '{"value": "buildertek__BT_Price_Book__c","label": "Pricebook Name"},';
        jsonSerializeFields += '{"value": "buildertek__Product__c","label": "Product"},';
        jsonSerializeFields += '{"value": "Name","label": "Product Name Proposal"},';
        jsonSerializeFields += '{"value": "buildertek__Takeoff_Line__c","label": "Takeoff Line"},';
        jsonSerializeFields += '{"value": "buildertek__Vendor__c","label": "Vendor"},';
        jsonSerializeFields += '{"value": "buildertek__Quantity__c","label": "Quantity"},';
        jsonSerializeFields += '{"value": "buildertek__BL_UNIT_COST__c","label": "Unit Cost"},';
        // jsonSerializeFields += '{"value": "buildertek__BL_LIST_PRICE__c","label": "List Price"},';
        // jsonSerializeFields += '{"value": "buildertek__UOM_Picklist__c","label": "UOM"},';
        jsonSerializeFields += '{"value": "buildertek__Extended_Cost__c","label": "Total Cost"},';
        jsonSerializeFields += '{"value": "buildertek__Tax_Percent__c","label": "Tax (%)"},';
        jsonSerializeFields += '{"value": "buildertek__BL_MARKUP__c","label": "Markup"},';
        jsonSerializeFields += '{"value": "buildertek__BL_LIST_PRICE_F__c","label": "Unit Sales Price"},';
        jsonSerializeFields += '{"value": "buildertek__Total_Sales_Price__c","label": "Total Sales Price"}';
        jsonSerializeFields += ']';
        String FieldsDefaultValues =    '[{"label":"Name","value":"Name"}]';
        String jsonSerializeFields1 =   FieldsDefaultValues;          
        
        
        InnSettings Inn = new InnSettings();        
        map<string,string> fieldtypemap = new map<string,string>();
        List<fieldWrap> FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict( jsonSerializeFields, List<fieldWrap>.class);
        Inn.TakeOffFieldSettings = FieldsSettings;
        
        String objectname='buildertek__Select_Sheet__c';
        Map<String, Schema.SObjectType> schemaMapPTL = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchemaPTL = schemaMapPTL.get(objectname);
        Map<String, Schema.SObjectField> fieldMapPTL = leadSchemaPTL.getDescribe().fields.getMap();     
        
        query = 'SELECT ';
        String fields= ' Id ';
        //'Id, Name, buildertek__Categories__r.Name, buildertek__Product_Type__r.Name, buildertek__Trade_Type__r.Name ';
        for(fieldWrap filedwraprec : FieldsSettings){
            string fieldName = filedwraprec.value;
            string fldname = filedwraprec.value; 
            Schema.DisplayType fielddataType = fieldMapPTL.get(fieldName).getDescribe().getType();
            string fldtype = STRING.valueOf(fielddataType);
            if (fieldValues != ''){
                fieldValues += ',';
            }
            String jsonPart = '{';
            jsonPart += '"label":"' + fieldMapPTL.get(fieldName).getDescribe().getLabel()+'",';
            jsonPart += '"required":"' + 'false' +'",';
            jsonPart += '"type":"' +fldtype+'",';
            jsonPart += '"name":"' + fieldName+'"';
            if (/*fieldName == 'Name' ||*/ (fieldMapPTL.get(fieldName).getDescribe().isCalculated())){
                jsonPart += ',"readOnly":"' + 'true' + '"';
            }
            if (fldtype == 'PICKLIST'){
                pickListValuesList = getDropDown('buildertek__Select_Sheet__c', fieldName);
                jsonPart += ',"pickListValuesList":' + JSON.serialize(pickListValuesList);
            }
            jsonPart += '}';
            fieldValues += jsonPart;
            
            if(fldtype == 'REFERENCE' ){
                if(fieldName.contains('__c')){
                    fldname = fieldName.replace('__c', '__r');
                    fieldName = fieldName.replace('__c', '__r.Name');  
                }
            }
            fieldtypemap.put(fldname,fldtype);

            if(fields == ''){
                fields = fieldName;    
            }else{
                fields += ' , ' + fieldName;       
            }
        }
        system.debug(fields);
        
        // filter fields
        FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict( jsonSerializeFields1, List<fieldWrap>.class);
        Inn.TakeOffFieldSettings = FieldsSettings;
        for(fieldWrap filedwraprec : FieldsSettings){
            string fieldName = filedwraprec.value;
            Schema.DisplayType fielddataType = fieldMapPTL.get(fieldName).getDescribe().getType();
            string fldtype = STRING.valueOf(fielddataType);
            if(fldtype == 'REFERENCE' ){
                if(fieldName.contains('__c')){
                    fieldName = fieldName.replace('__c', '__r.Name');  
                }
            }
            
            if(fields == ''){
                fields = fieldName;    
            }else{
                if(fields.contains(fieldName) == false){
                    fields += ' , ' + fieldName;    
                }
                
            }
        }
        system.debug(fields);
       /* if(fields.contains('Name') == false){
            fields += ' , ' + 'Name ';
        }*/
        if(fields.contains('buildertek__Build_Phase__c') == false){
            fields += ' , ' + 'buildertek__Build_Phase__c ';
        }
        if(fields.contains('buildertek__Build_Phase__r.Name') == false){
            fields += ' , ' + 'buildertek__Build_Phase__r.Name ';
        }
        if(fields.contains('buildertek__Category__c') == false){
            fields += ' , ' + 'buildertek__Category__c ';
        }
        if(fields.contains('buildertek__Category__r.Name') == false){
            fields += ' , ' + 'buildertek__Category__r.Name ';
        }
        if(fields.contains('buildertek__Vendor__c') == false){
            fields += ' , ' + 'buildertek__Vendor__c ';
        }
        if(fields.contains('buildertek__Vendor__r.Name') == false){
            fields += ' , ' + 'buildertek__Vendor__r.Name ';
        }
        if(fields.contains('buildertek__Product__c') == false){
            fields += ' , ' + 'buildertek__Product__c';
        }
        if(fields.contains('buildertek__Product__r.Name') == false){
            fields += ' , ' + 'buildertek__Product__r.Name ';
        }
        if(fields.contains('buildertek__Product__r.buildertek__Vendor__c') == false){
            fields += ' , ' + 'buildertek__Product__r.buildertek__Vendor__c ';
        }
        if(fields.contains('buildertek__Selection_Sheet_Takeoff__r.buildertek__Options_Rate__c') == false){
            fields += ' , ' + 'buildertek__Selection_Sheet_Takeoff__r.buildertek__Options_Rate__c ';
        }
        fields += ' , ' + 'buildertek__Product__r.ProductCode , buildertek__Takeoff_Line__r.buildertek__TL_SERVICE_CATEGORY__c, buildertek__Takeoff_Line__r.buildertek__Sq_Ft__c, buildertek__Takeoff_Line__r.buildertek__UOM_PL__c  ';
        system.debug('fields==='+fields);
        
        
        
        
        
        
       /* if(vendorName != '' || tradeType != '' || purchaseOrder != '' || category != '' || productType != '' || buildPhase != ''){
            String queryList = 'Select Id,Name,buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__Quantity__c,buildertek__Purchase_Order__c,buildertek__Purchase_Order__r.Name,buildertek__Upgrade_Price__c,buildertek__Standard__c,buildertek__Location_Picklist__c,buildertek__Product_Type__c,buildertek__Product_Type__r.Name,buildertek__Category__c,buildertek__Category__r.Name,buildertek__Trade_Type__c,buildertek__Trade_Type__r.Name,buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name,buildertek__Product__c,buildertek__Product__r.Name from buildertek__Select_Sheet__c';
            queryList = queryList +  ' where (buildertek__Selection_Sheet_Takeoff__c =: recordId) ';
            if(buildPhase != '' && buildPhase != null){
                queryList = queryList+ 'AND (buildertek__Build_Phase__r.Name LIKE \'%'+String.escapeSingleQuotes(buildPhase)+'%\')';
            }
            if(tradeType != '' && tradeType != null){
                queryList = queryList+ ' AND (buildertek__Trade_Type__r.Name LIKE \'%'+String.escapeSingleQuotes(tradeType)+'%\')';
            }
            if(purchaseOrder != '' && purchaseOrder != null){
                queryList = queryList + ' AND (buildertek__Purchase_Order__r.Name LIKE \'%'+String.escapeSingleQuotes(purchaseOrder)+'%\')';
            }
            if(vendorName != '' && vendorName != null){
                queryList = queryList+ 'AND (buildertek__Vendor__r.Name LIKE \'%'+String.escapeSingleQuotes(vendorName)+'%\')';
            }
            if(productType != '' && productType != null){
                queryList = queryList+ 'AND (buildertek__Product_Type__r.Name LIKE \'%'+String.escapeSingleQuotes(productType)+'%\')';
                //buildertek__Product_Type__r
            }
            if(category != '' && category != null){
                queryList = queryList+ 'AND (buildertek__Category__r.Name LIKE \'%'+String.escapeSingleQuotes(category)+'%\')';
                //buildertek__Category__r
            }
           
            //queryList = queryList+ ' ORDER BY Name LIMIT :pageSize OFFSET :offset';
            system.debug(queryList);
            objDT.recordList = Database.query(queryList);
            system.debug(objDT.recordList);
            
        }else{
            //if(toggleValue){
            objDT.recordList = [Select Id,Name,buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__Quantity__c,buildertek__Upgrade_Price__c,buildertek__Purchase_Order__c,buildertek__Purchase_Order__r.Name,
                                buildertek__Standard__c,buildertek__Location_Picklist__c,buildertek__Product_Type__c,buildertek__Product_Type__r.Name,
                                buildertek__Category__c,buildertek__Category__r.Name,buildertek__Trade_Type__c,buildertek__Trade_Type__r.Name,
                                buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name,buildertek__Product__c,buildertek__Product__r.Name,
                                buildertek__BL_UNIT_COST__c,buildertek__BL_MARKUP__c,buildertek__BL_DISCOUNT__c,buildertek__BL_LIST_PRICE__c
                                from buildertek__Select_Sheet__c  where buildertek__Selection_Sheet_Takeoff__c =: recordId  ORDER BY Name                       
                                //LIMIT :pageSize
                                //OFFSET :offset];
                                           
            
        }*/
        
         query = query+fields+' FROM buildertek__Select_Sheet__c WHERE (buildertek__Selection_Sheet_Takeoff__c =: recordId) ';
         query += filter;
       // String queryList = 'Select Id,Name,buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__Quantity__c,buildertek__Purchase_Order__c,buildertek__Purchase_Order__r.Name,buildertek__Upgrade_Price__c,buildertek__Standard__c,buildertek__Location_Picklist__c,buildertek__Product_Type__c,buildertek__Product_Type__r.Name,buildertek__Category__c,buildertek__Category__r.Name,buildertek__Trade_Type__c,buildertek__Trade_Type__r.Name,buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name,buildertek__Product__c,buildertek__Product__r.Name from buildertek__Select_Sheet__c';
        //queryList = query +  ' where (buildertek__Selection_Sheet_Takeoff__c =: recordId) ';
       // query += ' ORDER BY Name ';
          query += ' ORDER BY buildertek__Takeoff_Line__c ASC ';
        system.debug(query);
        List<SheetInner> sheetList = new List<SheetInner>();
       List<buildertek__Select_Sheet__c> recList = Database.query(query);
        for(buildertek__Select_Sheet__c bc:recList){
            SheetInner innn = new SheetInner();
            system.debug('#@@# bc--' +bc);
            //system.debug('productMapList.get(bc.Name).size('+productMapList.get(bc.Name).size());
            if(productMapList.get(bc.Name) != null){
                if(productMapList.get(bc.Name).size()>1 && bc.buildertek__Product__c !=null&& bc.buildertek__Product__r.buildertek__Vendor__c != null ){ //&& bc.buildertek__Product__r.buildertek__Vendor__c != null
                    innn.sheetrecord = bc;
                    innn.isShowIcon = true;
                }else{
                    innn.sheetrecord = bc;
                    innn.isShowIcon = false;
                }
            }else{
                    innn.sheetrecord = bc;
                    innn.isShowIcon = false;
                }
           
            sheetList.add(innn);
        }
        objDT.recordList = sheetList;
        objDT.fieldtypemap = fieldtypemap;
        for (sObject s : Database.query(query)){
            lstResult.add(s);
        }
        if (lstResult.size() > 0){
            sObjectRecordsList = JSON.serialize(lstResult);
        }
        objDT.sObjectRecordsList = sObjectRecordsList;
        objDT.fieldValues = '[' + fieldValues + ']';
        system.debug(objDT.recordList);
        return objDT;
            
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
    }

    @AuraEnabled
    public static Boolean checkFabricationTaxes(){
        try {
        Boolean showFabricationTaxes = false;
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Update_Quantity__c,buildertek__Show_Fabrication_taxes__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'BOM Settings'];
        showFabricationTaxes = adminInterfaceNodeConfigurations.buildertek__Show_Fabrication_taxes__c != null ? adminInterfaceNodeConfigurations.buildertek__Show_Fabrication_taxes__c : false;
        return showFabricationTaxes;
            
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
    }
    

    @AuraEnabled 
    public static InnSettings getTakeOffLinesData() {  
        try {

        // String jsonSerializeFields='';
        // buildertek__BOM_Line_Setting__c settingsrec = new buildertek__BOM_Line_Setting__c();
        // list<buildertek__BOM_Line_Setting__c>  settingsList = [Select id,Name, buildertek__BOM_Line_Filter_Fields__c,
        //                                                        buildertek__BOM_Line_Selected_Fileds__c
        //                                                        From buildertek__BOM_Line_Setting__c 
        //                                                        limit 1];        
        
        // String FieldsDefaultValues =    '[{"label":"Name","value":"Name"}]';
        
        
        // if(settingsList.size()>0) {
            
        //     settingsrec =  settingsList[0]; 
        //     if(settingsList[0].buildertek__BOM_Line_Selected_Fileds__c !=null){
        //         jsonSerializeFields = settingsList[0].buildertek__BOM_Line_Selected_Fileds__c;      
        //     } else{
        //         jsonSerializeFields = FieldsDefaultValues;
        //     }                     
            
            
        // }else {
        //     jsonSerializeFields =   FieldsDefaultValues;          
        // }
        String jsonSerializeFields = '[';
        jsonSerializeFields += '{"value": "buildertek__BT_Price_Book__c","label": "Pricebook Name"},';
        jsonSerializeFields += '{"value": "buildertek__Product__c","label": "Product"},';
        jsonSerializeFields += '{"value": "Name","label": "Product Name Proposal"},';
        jsonSerializeFields += '{"value": "buildertek__Takeoff_Line__c","label": "Takeoff Line"},';
        jsonSerializeFields += '{"value": "buildertek__Vendor__c","label": "Vendor"},';
        jsonSerializeFields += '{"value": "buildertek__Quantity__c","label": "Quantity"},';
        jsonSerializeFields += '{"value": "buildertek__BL_UNIT_COST__c","label": "Unit Cost"},';
        // jsonSerializeFields += '{"value": "buildertek__BL_LIST_PRICE__c","label": "List Price"},';
        // jsonSerializeFields += '{"value": "buildertek__UOM_Picklist__c","label": "UOM"},';
        jsonSerializeFields += '{"value": "buildertek__Extended_Cost__c","label": "Total Cost"},';
        jsonSerializeFields += '{"value": "buildertek__Tax_Percent__c","label": "Tax (%)"},';
        jsonSerializeFields += '{"value": "buildertek__BL_MARKUP__c","label": "Markup"},';
        jsonSerializeFields += '{"value": "buildertek__BL_LIST_PRICE_F__c","label": "Unit Sales Price"},';
        jsonSerializeFields += '{"value": "buildertek__Total_Sales_Price__c","label": "Total Sales Price"}';
        jsonSerializeFields += ']';

        
        InnSettings Inn = new InnSettings();        
        
        List<fieldWrap> FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(
            jsonSerializeFields,
            List<fieldWrap>.class);
        
        Inn.bomLineFieldSettings = FieldsSettings;                        
        String objectname='buildertek__Select_Sheet__c';
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(objectname);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();     
        
        string selectedFields = '';
        for(fieldWrap filedwraprec : FieldsSettings){
            string fieldName = filedwraprec.value;
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            string fldtype = STRING.valueOf(fielddataType);
            string selectedfield = fieldName; 
            if(fldtype == 'REFERENCE' ){
                if(fieldName.contains('__c')){
                    fieldName = fieldName.replace('__c', '__r.Name');  
                    selectedfield = selectedfield.replace('__c', '__r');    
                }
            }
            
            if(selectedFields == ''){
                selectedFields =selectedfield;  
            }else{
                selectedFields += ','+selectedfield;     
            }
        }
        system.debug('selectedFields--->'+selectedFields);
        Inn.bomLineselectedFields = selectedFields; 
        
        return Inn;
            
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
        
    }

    //BOM line
    @AuraEnabled
    public static Map<String, filterOptionclsForsettings> getBOMLineFiledNameAndApi(){
        try {
        String type='buildertek__Select_Sheet__c';
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<String, filterOptionclsForsettings>fieldNameApiMap = new Map<String, filterOptionclsForsettings>();
        
        
        buildertek__BOM_Line_Setting__c settingsList = [Select id,Name, buildertek__BOM_Line_Filter_Fields__c,
                                                            buildertek__BOM_Line_Selected_Fileds__c
                                                            From buildertek__BOM_Line_Setting__c 
                                                            limit 1];        
                                                        
        
        List<BOMSelectedFields> filterOptionList2  = (List<BOMSelectedFields>)System.JSON.deserialize(settingsList.buildertek__BOM_Line_Filter_Fields__c, List<BOMSelectedFields>.class);
        List<String> SelectedFields = new List<String>();
        for(BOMSelectedFields BomItem : filterOptionList2){
            SelectedFields.add(BomItem.value);
        }
        
        for (String fieldName: SelectedFields) {
            //It provides to get the object fields label.
            String fieldLabel = fieldMap.get(fieldName).getDescribe().getLabel();
            //It provides to get the object fields data type.
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            filterOptionclsForsettings filterOption = new filterOptionclsForsettings();
            filterOption.Key = fieldLabel;
            filterOption.Name = fieldName;
            filterOption.Type = STRING.valueOf(fielddataType);
            fieldNameApiMap.put(fieldLabel,filterOption);
            
        }
        system.debug(fieldNameApiMap);  
        return fieldNameApiMap;

            
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
            }
            return null;

        }
        
    }

    @AuraEnabled
    public static List<String> getDropDown(String objName, String fieldName){
        List<String> pickListValuesList = new List<String>();
        try{
            Schema.SObjectType s = Schema.getGlobalDescribe().get(objName);
            Schema.DescribeSObjectResult r = s.getDescribe();
            Map<String, Schema.SObjectField> fields = r.fields.getMap();
            Schema.DescribeFieldResult fieldResult = fields.get(fieldName).getDescribe();
            List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
            for (Schema.PicklistEntry pickListVal : ple){
                pickListValuesList.add(pickListVal.getLabel());
            }
            return pickListValuesList;
            
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
            }
            return null;

        }
    }

    @AuraEnabled
    public static string updateBOMlines(String recordId, String updatedRecords){
        try {
            if (String.isNotBlank(updatedRecords)){
                system.debug('updatedRecords : ' + updatedRecords);
                List<buildertek__Select_Sheet__c> items = (List<buildertek__Select_Sheet__c>)JSON.deserialize(updatedRecords, List<buildertek__Select_Sheet__c>.class);
                for (buildertek__Select_Sheet__c item : items){
                    System.debug('<--item-->'+item);
                    System.debug('<--item adjusted price -->'+item.buildertek__Upgrade_Price__c);
                    if (item.Id == null){
                        item.buildertek__Selection_Sheet_Takeoff__c = recordId;
                    }
                    item.Name = item.Name.length() > 79 ? item.Name.substring(0, 79) : item.Name;
                }
                if (items.size() > 0){
                    upsert items;
                }
            }
            return 'successfull';
            
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
    }


    public class BOMSelectedFields{
        @AuraEnabled
        public String value;
        @AuraEnabled
        public String label;
    } 
     public class filterOptionclsForsettings{
        @AuraEnabled
        public String Key;
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Type;
        @AuraEnabled
        public String Value;
    }
    
    
    public class RfqDataTableWrapper{
        @AuraEnabled
        public Integer pageSize{ get; set; }
        
        @AuraEnabled
        public Integer pageNumber{ get; set; }
        
        @AuraEnabled
        public Integer totalRecords{ get; set; }
        
        @AuraEnabled
        public Integer recordStart{ get; set; }
        
        @AuraEnabled
        public Integer recordEnd{ get; set; }
        
        /*@AuraEnabled
        public Boolean isProduct{ get; set; }*/
        
        @AuraEnabled
        public List<SheetInner> recordList{ get; set; }
        @AuraEnabled
        public map<string,string> fieldtypemap{ get; set; }
        @AuraEnabled
        public string sObjectRecordsList{ get; set; }
        @AuraEnabled
        public string fieldValues{ get; set; }
    }
    public class SheetInner{
         @AuraEnabled
        public buildertek__Select_Sheet__c sheetrecord{ get; set; }
        
        @AuraEnabled
        public Boolean isShowIcon{ get; set; }
    }
    
    public class VendorClass{
         @AuraEnabled
        public String productId {get;set;}
        @AuraEnabled
        public String productName {get;set;}
        @AuraEnabled
        public String productSKU {get;set;}
        @AuraEnabled
        public String vendorId {get;set;}
        @AuraEnabled
        public String vendorName {get;set;}
       /* @AuraEnabled
        public List<buildertek__Select_Sheet__c> vendorNameList {get;set;} */
        @AuraEnabled
        public Decimal unitCost {get;set;}
    }
    
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public string Message {get;set;}
        
    }
    public class ProductClass{
         @AuraEnabled
        public buildertek__Select_Sheet__c sheetRec {get;set;}
        @AuraEnabled
        public Boolean isproduct {get;set;}
    }
    public class InnSettings{
        @AuraEnabled
        public list<fieldWrap> TakeOffFieldSettings{ get; set; } 
        @AuraEnabled
        public string selectedFields;
        
        @AuraEnabled
        public list<fieldWrap> productFieldSettings{ get; set; } 
        @AuraEnabled
        public string productselectedFields;
        
        @AuraEnabled
        public list<fieldWrap> bomLineFieldSettings{ get; set; } 
        @AuraEnabled
        public string bomLineselectedFields;
        
    }
      public class fieldWrap{
        @AuraEnabled
        public string label{ get; set; }    
        @AuraEnabled
        public string value{ get; set; }    
    }

    public class ExtendedCostWrap{
        @AuraEnabled
        public string bomLineId{ get; set; }    
        @AuraEnabled
        public string productRate{ get; set; }    
        @AuraEnabled
        public string percentageVal{ get; set; } 
        @AuraEnabled
        public string extendedCostVal{ get; set; } 
        @AuraEnabled
        public string singleExtendedCostVal{ get; set; }
        @AuraEnabled
        public string denominatorVal{ get; set; } 
        @AuraEnabled
        public string installCostVal{ get; set; }
        @AuraEnabled
        public string proposalAmountVal{ get; set; } 
        @AuraEnabled
        public string adjustedCost{ get; set; } 
        @AuraEnabled
        public boolean taxbvalue{ get; set; } 
    }

    public class BomLineWrapper{
        @AuraEnabled
        public List<buildertek__Select_Sheet__c> bomLineList{ get; set; }    
        @AuraEnabled
        public List<extendedCostWrap> fabAndInstallRateWrap{ get; set; }  
        @AuraEnabled
        public List<extendedCostWrap> fabOnlyRateWrap{ get; set; }  
        @AuraEnabled
        public List<extendedCostWrap> installOnlyRateWrap{ get; set; }  
        @AuraEnabled
        public List<extendedCostWrap> nonSlabLaborMarkupWrap{ get; set; }    
        
    }
}