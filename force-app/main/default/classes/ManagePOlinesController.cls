public with sharing class ManagePOlinesController {
    
    @AuraEnabled
    public static buildertek__Project_Selection_Sheet_Takeoff__c getProject(String recordId){
        String projectName = '';
        buildertek__Project_Selection_Sheet_Takeoff__c Porecord = [Select Id, Name,buildertek__Opportunity__r.Id,buildertek__Opportunity__r.Name,buildertek__Opportunity__r.Description, buildertek__Project__r.Name,buildertek__OCIP_CCIP_Required__c from buildertek__Project_Selection_Sheet_Takeoff__c  where Id =: recordId LIMIT 1];
        projectName = Porecord.buildertek__Project__r.Name;
        System.debug('#@#@Porecord--'+Porecord);
        return Porecord;
    }
    
    @AuraEnabled
    
    public static RfqDataTableWrapper getProductOptionLines(Integer pageNumber, Integer pageSize, string recordId, String vendorName, String category, String tradeType,String purchaseOrder, String productType, String buildPhase,Boolean toggleValue,String filter){
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
        String jsonSerializeFields='';
        String jsonSerializeFields1='';
        buildertek__BOM_Line_Setting__c settingsrec = new buildertek__BOM_Line_Setting__c();
        list<buildertek__BOM_Line_Setting__c>  settingsList = [Select id,Name, buildertek__BOM_Line_Filter_Fields__c,
                                                               buildertek__BOM_Line_Selected_Fileds__c
                                                               From buildertek__BOM_Line_Setting__c 
                                                               limit 1];        
        String FieldsDefaultValues =    '[{"label":"Name","value":"Name"}]';
        
        
        if(settingsList.size()>0)  {
            
            settingsrec =  settingsList[0]; 
            if(settingsList[0].buildertek__BOM_Line_Selected_Fileds__c !=null){
                jsonSerializeFields = settingsList[0].buildertek__BOM_Line_Selected_Fileds__c;      
            } else{
                jsonSerializeFields = FieldsDefaultValues;
            }
            if(settingsList[0].buildertek__BOM_Line_Filter_Fields__c !=null){
                jsonSerializeFields1 = settingsList[0].buildertek__BOM_Line_Filter_Fields__c;      
            } else{
                jsonSerializeFields1 = FieldsDefaultValues;
            }
            
            
        } else  {
            jsonSerializeFields =   FieldsDefaultValues;          
            jsonSerializeFields1 =   FieldsDefaultValues;          
        }
        
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
    }
    
    
    @AuraEnabled
    public static String createPO(List<String> selectedIds,String recordId){
        system.debug(selectedIds);
        try{
            buildertek__Select_Sheet__c sampleOption = [Select buildertek__Selection_Sheet_Takeoff__r.buildertek__Project__c,buildertek__Quantity__c FROM buildertek__Select_Sheet__c WHERE Id IN: selectedIds][0];
            String projectId = sampleOption.buildertek__Selection_Sheet_Takeoff__r.buildertek__Project__c;

            Map<String,List<String>> optionLineMap = new Map<String,List<String>>();
            List<buildertek__Purchase_Order__c> POlist = new List<buildertek__Purchase_Order__c>();
            Map<String,String> poMap = new Map<String,String>();
            
            //with all
            List<buildertek__Select_Sheet__c> selectedOptionLines = [Select Id,Name,buildertek__Product_Type__c,buildertek__Product__c,buildertek__Purchase_Order__c,buildertek__Vendor__c,buildertek__Quantity__c FROM buildertek__Select_Sheet__c WHERE Id IN: selectedIds];
            Set<String> productIds = new Set<String>();
            for(buildertek__Select_Sheet__c opline: selectedOptionLines){
                productIds.add(opline.buildertek__Product__c);
            }
            system.debug(productIds);
            
            //product,optionline map
            Map<String,List<buildertek__Select_Sheet__c>> productOptionLineWithVendorMap = new Map<String,List<buildertek__Select_Sheet__c>>();
            Map<String,List<buildertek__Select_Sheet__c>> productOptionLineWithOutVendorMap = new Map<String,List<buildertek__Select_Sheet__c>>();
            
            //with vendor list
            List<buildertek__Select_Sheet__c> optionLineList = new List<buildertek__Select_Sheet__c>();
            optionLineList = [Select Id,Name,buildertek__Product_Type__c,buildertek__Product__c,buildertek__Purchase_Order__c,buildertek__Vendor__c,buildertek__Quantity__c FROM buildertek__Select_Sheet__c WHERE Id IN: selectedIds AND buildertek__Vendor__c !=null];
            system.debug(optionLineList.Size()+' '+recordId);
            
            //no vendor list
            List<buildertek__Select_Sheet__c> emptyVendorOptionLines = [Select Id,Name,buildertek__Product_Type__c,buildertek__Product__c,buildertek__Purchase_Order__c,buildertek__Vendor__c,buildertek__Quantity__c FROM buildertek__Select_Sheet__c WHERE Id IN: selectedIds AND buildertek__Vendor__c =null];
            system.debug(emptyVendorOptionLines);
            
            //priceBook
            List<Pricebook2> pricebook = [Select Id,Name from Pricebook2];
            String priceBookId ;
            if(pricebook.Size()>1){
                 Pricebook2 StdPriceBook =  [SELECT Id, Name,IsStandard from Pricebook2 WHERE IsStandard = true];
             // priceBookId = '01s41000000kFZJAA2'; //standard price book
              priceBookId = StdPriceBook.Id;
            }else if(pricebook.size() == 1){
                priceBookId = pricebook[0].Id;
                 
            }
            system.debug(priceBookId);
            Map<String,Decimal> productPriceMap = new Map<String,Decimal>();
            List<PricebookEntry> priceEntries = [Select Id, Pricebook2Id,buildertek__Unit_Cost__c,Product2Id FROM PricebookEntry WHERE Product2Id IN: productIds AND Pricebook2Id =: priceBookId];
            system.debug(priceEntries);
            for(PricebookEntry entry: priceEntries){
                productPriceMap.put(entry.Product2Id,entry.buildertek__Unit_Cost__c);
            }
            
            system.debug(productPriceMap);
            //lines with vendors
            if(optionLineList.Size()>0){
                for(buildertek__Select_Sheet__c optionLine : optionLineList){
                    if(optionLineMap.containsKey(optionLine.buildertek__Vendor__c)){
                        list<String> newOptionList = optionLineMap.get(optionLine.buildertek__Vendor__c);
                        newOptionList.add(optionLine.Id);    
                        optionLineMap.put(optionLine.buildertek__Vendor__c,newOptionList);                                        
                    }else{
                        list<String> newOptionList = new list<String>();
                        newOptionList.add(optionLine.Id);
                        optionLineMap.put(optionLine.buildertek__Vendor__c,newOptionList);                    
                    }
                }
                for(buildertek__Select_Sheet__c optionLine : optionLineList){
                    if(productOptionLineWithVendorMap.containsKey(optionLine.buildertek__Product__c+'_'+optionLine.buildertek__Vendor__c)){
                        list<buildertek__Select_Sheet__c> newOptionList = productOptionLineWithVendorMap.get(optionLine.buildertek__Product__c+'_'+optionLine.buildertek__Vendor__c);
                        newOptionList.add(optionLine);    
                        productOptionLineWithVendorMap.put(optionLine.buildertek__Product__c+'_'+optionLine.buildertek__Vendor__c,newOptionList);                                        
                    }else{
                        list<buildertek__Select_Sheet__c> newOptionList = new list<buildertek__Select_Sheet__c>();
                        newOptionList.add(optionLine);
                        productOptionLineWithVendorMap.put(optionLine.buildertek__Product__c+'_'+optionLine.buildertek__Vendor__c,newOptionList);                    
                    }
                    system.debug(productOptionLineWithVendorMap.get(optionLine.buildertek__Product__c+'_'+optionLine.buildertek__Vendor__c));
                }
                
                
                /*for(buildertek__Select_Sheet__c optionLine : optionLineList){
                    List<String> newOptionList = new List<String>();
                    
                    if(optionLineMap.containsKey(optionLine.buildertek__Vendor__c)){
                        newOptionList = optionLineMap.get(optionLine.buildertek__Vendor__c);
                    }
                    newOptionList.add(optionLine.Id);
                    optionLineMap.put(optionLine.buildertek__Vendor__c,newOptionList);
                    
                    //priceMap
                }*/
                system.debug(optionLineMap);
                system.debug(productOptionLineWithVendorMap.Size());
                system.debug(productOptionLineWithVendorMap);
                system.debug(productOptionLineWithVendorMap.keySet());
                for(string key : productOptionLineWithVendorMap.keySet()){
                    system.debug(productOptionLineWithVendorMap.get(key));
                    system.debug(productOptionLineWithVendorMap.get(key).Size());
                }
                system.debug(optionLineMap.keySet());
                //system.debug(vendorSet[0]);
                for(String key: optionLineMap.keySet()){
                    buildertek__Purchase_Order__c newPO = new buildertek__Purchase_Order__c();
                    newPO.buildertek__Vendor__c = key;
                    newPO.buildertek__Project__c = projectId;
                    POlist.add(newPO);
                }
                system.debug(POlist);
                insert POlist;
                
                for(buildertek__Purchase_Order__c poItem :POlist){
                    poMap.put(poItem.buildertek__Vendor__c,poItem.Id);
                }
                
                List<buildertek__Purchase_Order_Item__c> poLineList = new List<buildertek__Purchase_Order_Item__c>();
                List<buildertek__Select_Sheet__c> updateOptionLines = new List<buildertek__Select_Sheet__c>();
                
                //insert order lines with common and uncommon products
              /* for(String key: productOptionLineWithVendorMap.keySet()){
                    List<buildertek__Select_Sheet__c> optionLineListInMap = productOptionLineWithVendorMap.get(key);
                    buildertek__Purchase_Order_Item__c Poline = new buildertek__Purchase_Order_Item__c();
                    Poline.Name = optionLineListInMap[0].Name;
                    Poline.buildertek__Product__c = optionLineListInMap[0].buildertek__Product__c;
                    Poline.buildertek__Unit_Price__c = productPriceMap.get(optionLineListInMap[0].buildertek__Product__c);
                    
                    Poline.buildertek__Purchase_Order__c = poMap.get(optionLineListInMap[0].buildertek__Vendor__c);
                    for(buildertek__Select_Sheet__c optionLine : optionLineListInMap){
                        //Poline.buildertek__Purchase_Order__c = poMap.get(optionLine.buildertek__Vendor__c);
                        if(Poline.buildertek__Quantity__c != null){
                            Poline.buildertek__Quantity__c = Poline.buildertek__Quantity__c+optionLine.buildertek__Quantity__c;
                        }else{
                            Poline.buildertek__Quantity__c = optionLine.buildertek__Quantity__c;
                        }
                        optionLine.buildertek__Purchase_Order__c = poMap.get(optionLine.buildertek__Vendor__c);
                        updateOptionLines.add(optionLine);
                    }
                    poLineList.add(Poline);
                    system.debug(Poline);
                }*/
                
                for(buildertek__Select_Sheet__c optionLine : optionLineList){
                    buildertek__Purchase_Order_Item__c Poline = new buildertek__Purchase_Order_Item__c();
                    Poline.Name = optionLine.Name;
                    Poline.buildertek__Product__c = optionLine.buildertek__Product__c;
                    Poline.buildertek__Quantity__c = optionLine.buildertek__Quantity__c;
                    Poline.buildertek__Unit_Price__c = productPriceMap.get(optionLine.buildertek__Product__c);
                    Poline.buildertek__Purchase_Order__c = poMap.get(optionLine.buildertek__Vendor__c);
                    optionLine.buildertek__Purchase_Order__c = poMap.get(optionLine.buildertek__Vendor__c);
                    updateOptionLines.add(optionLine);
                    poLineList.add(Poline);
                }
                system.debug(poLineList);
                insert poLineList;
                update updateOptionLines;
            }
            
            //lines without vendors
            List<buildertek__Purchase_Order__c> polistwithnoVendor = new List<buildertek__Purchase_Order__c>();
            if(emptyVendorOptionLines.Size()>0){
                
                for(buildertek__Select_Sheet__c optionLine : emptyVendorOptionLines){
                    if(productOptionLineWithOutVendorMap.containsKey(optionLine.buildertek__Product__c)){
                        list<buildertek__Select_Sheet__c> newOptionList = productOptionLineWithOutVendorMap.get(optionLine.buildertek__Product__c);
                        newOptionList.add(optionLine);    
                        productOptionLineWithOutVendorMap.put(optionLine.buildertek__Product__c,newOptionList);                                        
                    }else{
                        list<buildertek__Select_Sheet__c> newOptionList = new list<buildertek__Select_Sheet__c>();
                        newOptionList.add(optionLine);
                        productOptionLineWithOutVendorMap.put(optionLine.buildertek__Product__c,newOptionList);                    
                    }
                }
                system.debug(productOptionLineWithOutVendorMap.Size()+' '+productOptionLineWithOutVendorMap);
                
                //creating one PO for all option lines with no vendor
                buildertek__Purchase_Order__c newPOwithNoVendor = new buildertek__Purchase_Order__c();
                newPOwithNoVendor.buildertek__Project__c = projectId;
                insert newPOwithNoVendor;
                
                List<buildertek__Select_Sheet__c> noVendorOptionList = new List<buildertek__Select_Sheet__c>();
                List<buildertek__Purchase_Order_Item__c> insertNoVendorList = new List<buildertek__Purchase_Order_Item__c>();
                
                //common products combining
                /*for(String key: productOptionLineWithOutVendorMap.keySet()){
                    List<buildertek__Select_Sheet__c> optionLineListInMap = productOptionLineWithOutVendorMap.get(key);
                    buildertek__Purchase_Order_Item__c PolineWithNovendor = new buildertek__Purchase_Order_Item__c();
                    PolineWithNovendor.Name = optionLineListInMap[0].Name;
                    PolineWithNovendor.buildertek__Product__c = optionLineListInMap[0].buildertek__Product__c;
                    PolineWithNovendor.buildertek__Unit_Price__c = productPriceMap.get(optionLineListInMap[0].buildertek__Product__c);
                    PolineWithNovendor.buildertek__Purchase_Order__c = newPOwithNoVendor.Id;
                    for(buildertek__Select_Sheet__c optionLine: optionLineListInMap){
                        if(PolineWithNovendor.buildertek__Quantity__c != null){
                            PolineWithNovendor.buildertek__Quantity__c = PolineWithNovendor.buildertek__Quantity__c + optionLine.buildertek__Quantity__c;
                        }else{
                            PolineWithNovendor.buildertek__Quantity__c = optionLine.buildertek__Quantity__c;
                        }
                        optionLine.buildertek__Purchase_Order__c = newPOwithNoVendor.Id;
                        noVendorOptionList.add(optionLine);
                    }
                    insertNoVendorList.add(PolineWithNovendor);
                }*/
                
                
                for(buildertek__Select_Sheet__c optionLine: emptyVendorOptionLines){
                    buildertek__Purchase_Order_Item__c PolineWithNovendor = new buildertek__Purchase_Order_Item__c();
                    PolineWithNovendor.Name = optionLine.Name;
                    PolineWithNovendor.buildertek__Product__c = optionLine.buildertek__Product__c;
                    PolineWithNovendor.buildertek__Quantity__c = optionLine.buildertek__Quantity__c;
                    PolineWithNovendor.buildertek__Unit_Price__c = productPriceMap.get(optionLine.buildertek__Product__c);
                    PolineWithNovendor.buildertek__Purchase_Order__c = newPOwithNoVendor.Id;
                    optionLine.buildertek__Purchase_Order__c = newPOwithNoVendor.Id;
                    noVendorOptionList.add(optionLine);
                    insertNoVendorList.add(PolineWithNovendor);
                }
                insert insertNoVendorList;
               update noVendorOptionList;
            }
            return 'SUCCESS';
        }catch(Exception ex){
            String message = ex.getMessage();
            return message;
        }
        
    }
    
    @AuraEnabled 
    public static List<Object> getVendors(String optionLineID){
       
        buildertek__Select_Sheet__c optionLineItem = [SELECT Id,Name,buildertek__Vendor__c,buildertek__Product__c,buildertek__Product__r.buildertek__Vendor__c,buildertek__Product__r.Name FROM buildertek__Select_Sheet__c WHERE Id=:optionLineID];
        system.debug(optionLineItem);
      //  List<Product2> productList = [SELECT Id,Name,StockKeepingUnit,buildertek__Vendor__c,buildertek__Vendor__r.Name FROM Product2 WHERE  Name =: optionLineItem.buildertek__Product__r.Name]; //buildertek__Vendor__c !=: optionLineItem.buildertek__Product__r.buildertek__Vendor__c AND
         List<Product2> productList = [SELECT Id,Name,StockKeepingUnit,buildertek__Vendor__c,buildertek__Vendor__r.Name FROM Product2 WHERE  Name =: optionLineItem.buildertek__Product__r.Name AND Id !=: optionLineItem.buildertek__Product__c]; //buildertek__Vendor__c !=: optionLineItem.buildertek__Product__r.buildertek__Vendor__c AND
        
        Set<String> productIds = new Set<String>();
        system.debug(productList);
        for(Product2 p: productList){
            productIds.add(p.Id);
        }
        Map<String,Decimal> productPriceMap = new Map<String,Decimal>();
        Pricebook2 StdPriceBook =  [SELECT Id, Name,IsStandard from Pricebook2 WHERE IsStandard = true];
        
        List<PricebookEntry> entryList = [SELECT Product2Id,buildertek__Unit_Cost__c FROM PricebookEntry WHERE Pricebook2Id =:StdPriceBook.Id  AND Product2Id IN:productIds]; //'01s41000000kFZJAA2'
        for(PricebookEntry entry: entryList){
            productPriceMap.put(entry.Product2Id,entry.buildertek__Unit_Cost__c);
        }
        
        List<Object> vendorItemList = new List<Object>();
        //system.debug(vendorList);
        for(Product2 p: productList){
            if(p.buildertek__Vendor__c != null){
                VendorClass vendorList = new VendorClass();
                vendorList.productId = p.Id;
                vendorList.productName = p.Name;
                vendorList.vendorId = p.buildertek__Vendor__c;
                vendorList.vendorName = p.buildertek__Vendor__r.Name;
                vendorList.productSKU = p.StockKeepingUnit;
                vendorList.unitCost = productPriceMap.get(p.Id);
                system.debug(vendorList);
                vendorItemList.add(vendorList);
            }
            
        }
        system.debug(vendorItemList);
        return vendorItemList;
    }
    @AuraEnabled 
    public static List<Object> getprovendors(String optionLineID){
        list<buildertek__Select_Sheet__c> optionLineItemslist = [SELECT Id,Name,buildertek__Vendor__c,buildertek__Product__c,buildertek__Product__r.buildertek__Vendor__c,
                                                                 buildertek__Product__r.Name FROM buildertek__Select_Sheet__c WHERE 
                                                                 buildertek__Selection_Sheet_Takeoff__c =:optionLineID];
        system.debug(optionLineItemslist);
        list<Id> sheetids = new list<Id>();
        List<Object> vendorItemList = new List<Object>();
        for(buildertek__Select_Sheet__c sheetRec : optionLineItemslist){
                if(sheetRec.buildertek__Product__c == null){
                    ProductClass productRec = new ProductClass();
                    productRec.sheetRec = sheetRec;
                    productRec.isproduct = false;
                    vendorItemList.add(productRec);
                }
        }
        return vendorItemList;
    }
    
    @AuraEnabled
    public static String createNewOptionLine(String productId, String projectId, String optionLineId){
        Product2 selectedProduct = [SELECT Id,Name,StockKeepingUnit,buildertek__Product_Type__c,buildertek__Trade_Type__c,buildertek__Type__c,buildertek__Vendor__c, 
                                    buildertek__Category__c FROM Product2 WHERE Id =: productId];
         string opionlineQuery = '';
        if(UserInfo.isMultiCurrencyOrganization()){
            opionlineQuery = 'SELECT Id,Name,buildertek__BT_Price_Book__c,CurrencyIsoCode,buildertek__Vendor__c,buildertek__Product__c,buildertek__Product__r.Name,buildertek__Purchase_Order__c,  buildertek__Takeoff_Line__c,buildertek__Selection_Sheet_Takeoff__c,buildertek__Location_Picklist__c,buildertek__Build_Reference_1__c,buildertek__Base_Location__c,buildertek__Location_Detailed_Area__c,buildertek__Location_Detail_Reference_1__c,buildertek__Install_Location__c,buildertek__Install_Location_Reference__c,buildertek__Build_Phase__c, buildertek__Quantity__c  FROM buildertek__Select_Sheet__c WHERE Id =: optionLineId' ;
            
        }else{
            opionlineQuery = 'SELECT Id,Name,buildertek__BT_Price_Book__c,buildertek__Vendor__c,buildertek__Product__c,buildertek__Product__r.Name,buildertek__Purchase_Order__c,  buildertek__Takeoff_Line__c,buildertek__Selection_Sheet_Takeoff__c,buildertek__Location_Picklist__c,buildertek__Build_Reference_1__c,buildertek__Base_Location__c,buildertek__Location_Detailed_Area__c,buildertek__Location_Detail_Reference_1__c,buildertek__Install_Location__c,buildertek__Install_Location_Reference__c,buildertek__Build_Phase__c, buildertek__Quantity__c  FROM buildertek__Select_Sheet__c WHERE Id =: optionLineId' ;
        }
        
       
        
        /*buildertek__Select_Sheet__c optionLineRecord = [SELECT Id,Name,buildertek__Vendor__c,buildertek__Product__c,buildertek__Product__r.Name,buildertek__Purchase_Order__c, 
                                                       buildertek__Takeoff_Line__c,buildertek__Selection_Sheet_Takeoff__c,buildertek__Location_Picklist__c,buildertek__Build_Phase__c,
                                                        buildertek__Quantity__c
                                                       FROM buildertek__Select_Sheet__c WHERE Id =: optionLineId];*/
        
           buildertek__Select_Sheet__c optionLineRecord =  Database.query(opionlineQuery);
        system.debug(optionLineRecord);
        system.debug(selectedProduct);
        buildertek__Select_Sheet__c newOptionLine = new buildertek__Select_Sheet__c();
        String productOption = optionLineRecord.buildertek__Selection_Sheet_Takeoff__c;
        String takeoff = optionLineRecord.buildertek__Takeoff_Line__c;
        //String
        newOptionLine.Name = selectedProduct.Name;
        newOptionLine.buildertek__Product_Type__c = selectedProduct.buildertek__Product_Type__c;
        newOptionLine.buildertek__Selection_Sheet_Takeoff__c = productOption; //optionLineRecord.buildertek__Selection_Sheet_Takeoff__c;
        newOptionLine.buildertek__Vendor__c = selectedProduct.buildertek__Vendor__c;
        newOptionLine.buildertek__Product__c = selectedProduct.Id;
            Pricebook2 StdPriceBook =  [SELECT Id, Name,IsStandard from Pricebook2 WHERE IsStandard = true];
        PricebookEntry pricebookRec;
        if(UserInfo.isMultiCurrencyOrganization()){
            String BOMlinecurrency = 'USD';//optionLineRecord.CurrencyIsoCode;
            String prodId = selectedProduct.Id;
            String pricebook = StdPriceBook.Id;
            // String priceBook = optionLineRecord.buildertek__BT_Price_Book__c;
            String pricebookentrylistQry = 'select id,Name,CurrencyIsoCode,buildertek__Unit_Cost__c,buildertek__Markup__c,buildertek__Discount__c,UnitPrice, Product2Id,Pricebook2Id from PricebookEntry   where Product2Id =: prodId AND Pricebook2Id =:pricebook  AND CurrencyIsoCode=: BOMlinecurrency limit 1';    
            pricebookRec =  Database.query(pricebookentrylistQry);
            // PricebookEntry pricebookRec = [select id,Name,CurrencyIsoCode,buildertek__Unit_Cost__c,buildertek__Markup__c,buildertek__Discount__c,UnitPrice, Product2Id,Pricebook2Id from PricebookEntry   where Product2Id =: selectedProduct.Id AND ];
        }else{
            String BOMlinecurrency = 'USD';//optionLineRecord.CurrencyIsoCode;
            String prodId = selectedProduct.Id;
            String pricebook = StdPriceBook.Id;
            // String priceBook = optionLineRecord.buildertek__BT_Price_Book__c;
            String pricebookentrylistQry = 'select id,Name,buildertek__Unit_Cost__c,buildertek__Markup__c,buildertek__Discount__c,UnitPrice, Product2Id,Pricebook2Id from PricebookEntry   where Product2Id =: prodId AND Pricebook2Id =:pricebook limit 1';    
            pricebookRec =  Database.query(pricebookentrylistQry);
            // PricebookEntry pricebookRec = [select id,Name,CurrencyIsoCode,buildertek__Unit_Cost__c,buildertek__Markup__c,buildertek__Discount__c,UnitPrice, Product2Id,Pricebook2Id from PricebookEntry   where Product2Id =: selectedProduct.Id AND ];
        }
         newOptionLine.buildertek__Takeoff_Line__c = takeoff;//optionLineRecord.buildertek__Takeoff_Line__c;
        system.debug(optionLineRecord.buildertek__Takeoff_Line__c+','+ newOptionLine.buildertek__Takeoff_Line__c);
        //newOptionLine.buildertek__Standard__c
        //instructios
        //upgraded price
        newOptionLine.buildertek__BL_MARKUP__c = pricebookRec.buildertek__Markup__c;
        newOptionLine.buildertek__BL_DISCOUNT__c = pricebookRec.buildertek__Discount__c;
        newOptionLine.buildertek__BL_LIST_PRICE__c = pricebookRec.UnitPrice;
        newOptionLine.buildertek__BL_UNIT_COST__c = pricebookRec.buildertek__Unit_Cost__c;
        newOptionLine.buildertek__Location_Picklist__c = optionLineRecord.buildertek__Location_Picklist__c;
        newOptionLine.buildertek__Build_Reference_1__c = optionLineRecord.buildertek__Build_Reference_1__c ; 
        newOptionLine.buildertek__Base_Location__c = optionLineRecord.buildertek__Base_Location__c ; 
        newOptionLine.buildertek__Location_Detailed_Area__c = optionLineRecord.buildertek__Location_Detailed_Area__c; 
        newOptionLine.buildertek__Location_Detail_Reference_1__c = optionLineRecord.buildertek__Location_Detail_Reference_1__c; 
        newOptionLine.buildertek__Install_Location__c = optionLineRecord.buildertek__Install_Location__c; 
        newOptionLine.buildertek__Install_Location_Reference__c = optionLineRecord.buildertek__Install_Location_Reference__c; 
        newOptionLine.buildertek__Build_Phase__c = optionLineRecord.buildertek__Build_Phase__c; 
        newOptionLine.buildertek__Quantity__c = optionLineRecord.buildertek__Quantity__c;
        newOptionLine.buildertek__Trade_Type__c = selectedProduct.buildertek__Trade_Type__c;
        newOptionLine.buildertek__Product_Type__c = selectedProduct.buildertek__Product_Type__c;
        newOptionLine.buildertek__Category__c = selectedProduct.buildertek__Category__c;
        Id projId = Id.valueOf(projectId);
        newOptionLine.buildertek__Project__c = projId;
        system.debug(newOptionLine.buildertek__Takeoff_Line__c);
        insert newOptionLine;
        system.debug(newOptionLine.buildertek__Takeoff_Line__c);
        
       optionLineRecord.buildertek__Purchase_Order__c = null;
        optionLineRecord.buildertek__Takeoff_Line__c = null;
        optionLineRecord.buildertek__Selection_Sheet_Takeoff__c = null;
        //update optionLineRecord;
        buildertek__Select_Sheet__c deleteOptionLineRecord = [SELECT Id,Name FROM buildertek__Select_Sheet__c WHERE Id =: optionLineRecord.Id];
        system.debug(deleteOptionLineRecord);
        try {
            delete deleteOptionLineRecord;
        } catch (DmlException e) {
            system.debug(e);
            // Process exception here
        }
        String returnValue = newOptionLine.Id+'_'+optionLineRecord.Id;
        return returnValue;
    }
    
    
    @AuraEnabled
    public static String deleteOptionLine(String productId, String projectId, String optionLineId){
        
        
        buildertek__Select_Sheet__c optionLineRecord = [SELECT Id,Name,buildertek__Purchase_Order__c
                                                        FROM buildertek__Select_Sheet__c WHERE Id =: optionLineId];
        
        if(optionLineRecord.buildertek__Purchase_Order__c == null){
            delete optionLineRecord;
            return 'Deleted';
            
        }else{
            return 'Please Delete the Purchase Order';
            
        }
        
    }
    
    
     @AuraEnabled 
    public static InnSettings getTakeOffLinesData() {        
        String jsonSerializeFields='';
        buildertek__BOM_Line_Setting__c settingsrec = new buildertek__BOM_Line_Setting__c();
        list<buildertek__BOM_Line_Setting__c>  settingsList = [Select id,Name, buildertek__BOM_Line_Filter_Fields__c,
                                                               buildertek__BOM_Line_Selected_Fileds__c
                                                               From buildertek__BOM_Line_Setting__c 
                                                               limit 1];        
        
        String FieldsDefaultValues =    '[{"label":"Name","value":"Name"}]';
        
        
        if(settingsList.size()>0) {
            
            settingsrec =  settingsList[0]; 
            if(settingsList[0].buildertek__BOM_Line_Selected_Fileds__c !=null){
                jsonSerializeFields = settingsList[0].buildertek__BOM_Line_Selected_Fileds__c;      
            } else{
                jsonSerializeFields = FieldsDefaultValues;
            }                     
            
            
        }else {
            jsonSerializeFields =   FieldsDefaultValues;          
        }
        
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
        
    }
    
     //BOM line
    @AuraEnabled
    public static Map<String, filterOptionclsForsettings> getBOMLineFiledNameAndApi(){
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
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        return pickListValuesList;
    }

    @AuraEnabled
    public static String updateRecords(String recordId, String updatedRecords){
        // try{
        if (String.isNotBlank(updatedRecords)){
            List<buildertek__Select_Sheet__c> items = (List<buildertek__Select_Sheet__c>)JSON.deserialize(updatedRecords, List<buildertek__Select_Sheet__c>.class);
            for (buildertek__Select_Sheet__c item : items){
                System.debug('<--item-->'+item);
                System.debug('<--item adjusted price -->'+item.buildertek__Upgrade_Price__c);
                if (item.Id == null){
                    item.buildertek__Selection_Sheet_Takeoff__c = recordId;
                }
            }
            if (items.size() > 0){
                upsert items;
            }
            return '';
        }
        /*  } catch (Exception e){
         System.debug('Error::' + e.getMessage());
         System.debug('Error Line::' + e.getLineNumber());
         throw new AuraHandledException(e.getMessage());
         }*/
        return null;
    }

    @AuraEnabled
    public static String deleteBOMLine(String deleteRecordId){
        try{
            if (String.isNotBlank(deleteRecordId)){
                delete [Select Id
                        FROM buildertek__Select_Sheet__c
                        WHERE ID = :deleteRecordId];
                return '';
            }
        } catch (Exception e){
            System.debug('Error::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    @AuraEnabled
    public static Boolean checkFabricationTaxes(){
        Boolean showFabricationTaxes = false;
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Update_Quantity__c,buildertek__Show_Fabrication_taxes__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'BOM Settings'];
        showFabricationTaxes = adminInterfaceNodeConfigurations.buildertek__Show_Fabrication_taxes__c != null ? adminInterfaceNodeConfigurations.buildertek__Show_Fabrication_taxes__c : false;
        return showFabricationTaxes;
    }
    
    @AuraEnabled
    public static List<buildertek__Project_Selection_Sheet_Takeoff__c> getBTAdminRecorDetails(String recordId){
        List<buildertek__Project_Selection_Sheet_Takeoff__c> BomList = new List<buildertek__Project_Selection_Sheet_Takeoff__c>();
        if(String.isNotBlank(recordId))
        {
            buildertek__Project_Selection_Sheet_Takeoff__c Porecord = [Select Id, Name,buildertek__Textura_Fee__c,buildertek__Edge__c,buildertek__Options_Rate__c,buildertek__Miscellaneous_Rates__c,buildertek__Workers_Comp__c,buildertek__Fabrication_Install_Rate__c,buildertek__Mark_Up_Non_Slab_or_Labor__c,buildertek__Install_Only__c,buildertek__OCIP_CCIP_Required__c,buildertek__CCIP__c,buildertek__General_Liability_Insurance_Long__c,buildertek__OCIP_CCIP__c,buildertek__Fab_Only_Rate__c,LastModifiedBy.Name, buildertek__Region_State_Country_County__c,buildertek__Tax_Rate_1__c,buildertek__Tax_Rate_2__c,buildertek__Slab_Discount_Rate_LongText__c,buildertek__Fabrication_Labor_Mark_up_LongText__c,buildertek__Tax_on_Fabrication_Required__c from buildertek__Project_Selection_Sheet_Takeoff__c  where Id =: recordId LIMIT 1];
            if(Porecord != null )
            {
                BomList.add(Porecord);
            }
        }
        return BomList;
    }

    @AuraEnabled    
    public static AuraResponse updateBomRecords( List < buildertek__Project_Selection_Sheet_Takeoff__c > updatedBomList ) {    
            
        System.debug('#@#@# updatedBomList--'+updatedBomList);
        System.debug('#@#@# updatedBomList--'+updatedBomList[0].id);
        try {  
          
            update updatedBomList;  
            //return true;  
            return new AuraResponse(true, '', 'Success');
              
        } catch(Exception e) {  
            System.debug('#@#@# updatedBomList Error--'+e.getMessage());
            //return false;  
            return new AuraResponse(false, e.getMessage(), 'Error');  
        }  
            
    }
    @AuraEnabled
    public static List<Map<String, String>> getAllCountryList() {


        List<Map<String, String>> items = new List<Map<String, String>>();
        items.add(new Map<String, String>{'value' => 'Florida', 'label' => 'Florida'});
        items.add(new Map<String, String>{'value' => 'Mid_Atlantic', 'label' => 'Mid Atlantic'});
        items.add(new Map<String, String>{'value' => 'Midwest', 'label' => 'Midwest'});
        items.add(new Map<String, String>{'value' => 'Mountain', 'label' => 'Mountain'});
        items.add(new Map<String, String>{'value' => 'New_England', 'label' => 'New England'});
        items.add(new Map<String, String>{'value' => 'New_York', 'label' => 'New York'});
        items.add(new Map<String, String>{'value' => 'Northern_CA', 'label' => 'Northern CA'});
        items.add(new Map<String, String>{'value' => 'Northwest', 'label' => 'Northwest'});
        items.add(new Map<String, String>{'value' => 'Ohio_Valley', 'label' => 'Ohio Valley'});
        items.add(new Map<String, String>{'value' => 'Southeast', 'label' => 'Southeast'});
        items.add(new Map<String, String>{'value' => 'Southen_CA', 'label' => 'Southen CA'});
        items.add(new Map<String, String>{'value' => 'TOLA', 'label' => 'TOLA'});
        items.add(new Map<String, String>{'value' => 'Montreal', 'label' => 'Montreal'});
        items.add(new Map<String, String>{'value' => 'Quebec', 'label' => 'Quebec'});
        items.add(new Map<String, String>{'value' => 'Burnaby', 'label' => 'Burnaby'});
        items.add(new Map<String, String>{'value' => 'Toronto', 'label' => 'Toronto'});


        return items;
    }    
    
    @AuraEnabled
    public static List<fieldWrap> getproductCodes(String bomId)
    {
        String jsonStr = '{';
        List<fieldWrap> prodCodeWrapList = new List<fieldWrap>();
        set<String> duplicatePrdValues = new Set<String>();
        Map<String,String> prodCodeMap = new Map<String,String>();
        if(String.isNotBlank(bomId))
        {
            String query = 'SELECT ';
            String fields= ' Id, buildertek__Product__r.ProductCode , buildertek__Takeoff_Line__r.buildertek__TL_SERVICE_CATEGORY__c  ';
            query = query+fields+' FROM buildertek__Select_Sheet__c WHERE (buildertek__Selection_Sheet_Takeoff__c =: bomId) ';
            system.debug('#@#@#Query---'+query);
            List<buildertek__Select_Sheet__c> recList = Database.query(query);
            system.debug('#@#@#recList---'+recList);
            if(recList != null && recList.size() > 0)
            {
                for(buildertek__Select_Sheet__c bomLine : recList)
                {
                    if(String.isNotBlank(bomLine.buildertek__Product__r.ProductCode) && !duplicatePrdValues.contains(bomLine.buildertek__Product__r.ProductCode) )
                    {
                        fieldWrap wrap = new fieldWrap();
                        wrap.label = bomLine.buildertek__Product__r.ProductCode;
                        wrap.value = '';
                        system.debug('#@#@#wrap---'+JSON.serialize(wrap) );
                        prodCodeWrapList.add(wrap);
                        duplicatePrdValues.add(bomLine.buildertek__Product__r.ProductCode);
                        
                        prodCodeMap.put(wrap.label,wrap.value);
                    }
                }
            }

        }
        system.debug('#@#@#prodCodeWrapList---'+prodCodeWrapList);
        system.debug('#@#@#prodCodeWrapList Size---'+JSON.serialize(prodCodeWrapList) );
        system.debug('#@#@#prodCodeMap---'+JSON.serialize(prodCodeMap) );
        return  prodCodeWrapList;
    }

    @AuraEnabled
    public static Map<String,Map<String,String>> getExtendedCosts(String bomId)
    {
        System.debug('getExtendedCosts called==='+bomId);
        Map<String,Map<String,String>> returnMapVal = new Map<String,Map<String,String>>();
     //   try 
     //   {
            if(String.isNotBlank(bomId))
            {
                String query = 'SELECT ';
                String fields= ' Id, Name,buildertek__Upgrade_Price__c,buildertek__Quantity__c,buildertek__Selection_Sheet_Takeoff__r.buildertek__Textura_Fee__c, buildertek__Selection_Sheet_Takeoff__r.buildertek__General_Liability_Insurance_Long__c,buildertek__Selection_Sheet_Takeoff__r.buildertek__Workers_Comp__c, buildertek__Selection_Sheet_Takeoff__r.buildertek__Options_Rate__c,buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Labor_Mark_up_LongText__c,buildertek__Selection_Sheet_Takeoff__r.buildertek__Slab_Discount_Rate_LongText__c,buildertek__Selection_Sheet_Takeoff__r.buildertek__Edge__c, buildertek__Selection_Sheet_Takeoff__r.buildertek__Miscellaneous_Rates__c,buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Install_Rate__c, buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c, buildertek__Selection_Sheet_Takeoff__r.buildertek__Install_Only__c, buildertek__Selection_Sheet_Takeoff__r.buildertek__Mark_Up_Non_Slab_or_Labor__c, ';
                fields = fields + ' buildertek__Extended_Cost__c,buildertek__Product__r.ProductCode , buildertek__Takeoff_Line__r.buildertek__TL_SERVICE_CATEGORY__c  ';
                query = query+fields+' FROM buildertek__Select_Sheet__c WHERE (buildertek__Selection_Sheet_Takeoff__c =: bomId) ';
                system.debug('#@#@#Query---*****'+query);
                System.debug('bomId===='+bomId);
                List<buildertek__Select_Sheet__c> recList = Database.query(query);
                System.debug('recList==='+recList);
                System.debug('recList size==='+recList.size());
                if(recList != null && recList.size() > 0)
                {
                    Map<Id,buildertek__Select_Sheet__c> bomLineMap = new Map<Id,buildertek__Select_Sheet__c>(recList);
                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Install_Rate__c))
                    {
                        // returnMapVal.put('buildertek__Fabrication_Install_Rate__c', formatExtendedCost(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Install_Rate__c,bomLineMap));
                    }
                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c))
                    {
                        // returnMapVal.put('buildertek__Fab_Only_Rate__c', formatratePercentage(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c,bomLineMap));
                    }
                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Install_Only__c))
                    {
                        // returnMapVal.put('buildertek__Install_Only__c', formatExtendedCost(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Install_Only__c,bomLineMap));
                    }

                    System.debug('wc===='+recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Workers_Comp__c);
                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Workers_Comp__c))
                    {
                        System.debug('buildertek__Selection_Sheet_Takeoff__r.buildertek__Workers_Comp__c');
                        // if(string.valueof(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Workers_Comp__c) != null){
                            System.debug('work comp===');
                            returnMapVal.put('buildertek__Workers_Comp__c', formatExtendedCostForWorkComp('buildertek__Workers_Comp__c',recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Workers_Comp__c,bomLineMap));
                            System.debug('work comp==='+returnMapVal.get('buildertek__Workers_Comp__c'));
                        // }
                    }
                    // System.debug('Gl insurance====='+formatExtendedCostForWorkComp('buildertek__General_Liability_Insurance_Long__c',recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__General_Liability_Insurance_Long__c,bomLineMap));
                    System.debug('gl====='+recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__General_Liability_Insurance_Long__c);
                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__General_Liability_Insurance_Long__c))
                    {
                        returnMapVal.put('buildertek__General_Liability_Insurance_Long__c', formatExtendedCostForWorkComp('buildertek__General_Liability_Insurance_Long__c',recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__General_Liability_Insurance_Long__c,bomLineMap));
                        System.debug('Gl insurance====='+returnMapVal.get('buildertek__General_Liability_Insurance_Long__c'));
                    }
                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Textura_Fee__c))
                    {
                        returnMapVal.put('buildertek__Textura_Fee__c', formatExtendedCostForWorkComp('buildertek__Textura_Fee__c',recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Textura_Fee__c,bomLineMap));
                    }
                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Mark_Up_Non_Slab_or_Labor__c))
                    {
                        returnMapVal.put('buildertek__Mark_Up_Non_Slab_or_Labor__c', formatratePercentage(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Mark_Up_Non_Slab_or_Labor__c,bomLineMap));
                    }
                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Miscellaneous_Rates__c))
                    {
                        // returnMapVal.put('buildertek__Miscellaneous_Rates__c', formatExtendedCost(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Miscellaneous_Rates__c,bomLineMap));
                    }
                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Edge__c))
                    {
                        // returnMapVal.put('buildertek__Edge__c', formatExtendedCost(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Edge__c,bomLineMap));
                    }
                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Slab_Discount_Rate_LongText__c))
                    {                       
                        returnMapVal.put('buildertek__Slab_Discount_Rate_LongText__c', formatratePercentage(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Slab_Discount_Rate_LongText__c,bomLineMap));
                    }
                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Labor_Mark_up_LongText__c))
                    {      
                        System.debug('testing');                 
                        System.debug(formatratePercentage(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Labor_Mark_up_LongText__c,bomLineMap));
                        returnMapVal.put('buildertek__Fabrication_Labor_Mark_up_LongText__c', formatratePercentage(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Labor_Mark_up_LongText__c,bomLineMap));
                    }
                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Options_Rate__c))
                    {    
                        // returnMapVal.put('buildertek__Options_Rate__c', formatExtendedCost(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Options_Rate__c,bomLineMap));
                    }
                    System.debug('#@#@ returnMapVal--'+returnMapVal);
                    System.debug('#@#@ returnMapVal--'+returnMapVal.size() );

                    //For Empty List for the first time get the Formula field
                    // if(returnMapVal.size() == 0)
                    // {
                        Map<String,String> strMap = new Map<String,String>();
                        Map<String,String> blankDiscountMap = new Map<String,String>();
                        Map<String,String> markUpnonSlabMap = new Map<String,String>();
                        Map<String,String> workersCompMap = new Map<String,String>();
                        Map<String,String> generalLiabMap = new Map<String,String>();
                        Map<String,String> texturaFeeMap = new Map<String,String>();
                        Map<String,String> blankslabDiscountMap = new Map<String,String>();
                        Map<String,String> blankmarkupDiscountMap = new Map<String,String>();
                        workersCompMap.put('buildertek__Workers_Comp__c', '0');
                        generalLiabMap.put('buildertek__General_Liability_Insurance_Long__c', '0');
                        texturaFeeMap.put('buildertek__Textura_Fee__c', '0');
                        System.debug('#@#@ EMPTY MAP');
                        for(buildertek__Select_Sheet__c bomLine : recList)
                        {
                            // strMap.put(bomLine.Id, String.valueOf(bomLine.buildertek__Extended_Cost__c));
                            strMap.put(bomLine.Id, '0');
                            blankDiscountMap.put(bomLine.Id, '0');
                            blankslabDiscountMap.put(bomLine.Id, '');
                            blankmarkupDiscountMap.put(bomLine.Id,'');
                        }
                        if(!returnMapVal.containsKey('buildertek__Fabrication_Install_Rate__c'))
                        {
                            returnMapVal.put('buildertek__Fabrication_Install_Rate__c',strMap );
                        }
                        if(!returnMapVal.containsKey('buildertek__Fab_Only_Rate__c'))
                        {
                            returnMapVal.put('buildertek__Fab_Only_Rate__c',blankDiscountMap );
                        }
                        if(!returnMapVal.containsKey('buildertek__Install_Only__c'))
                        {
                            returnMapVal.put('buildertek__Install_Only__c',strMap );
                        }
                        if(!returnMapVal.containsKey('buildertek__Workers_Comp__c'))
                        {
                            returnMapVal.put('buildertek__Workers_Comp__c',workersCompMap );
                        }
                        if(!returnMapVal.containsKey('buildertek__Textura_Fee__c'))
                        {
                            returnMapVal.put('buildertek__Textura_Fee__c',texturaFeeMap );
                        }
                        if(!returnMapVal.containsKey('buildertek__General_Liability_Insurance_Long__c'))
                        {
                            returnMapVal.put('buildertek__General_Liability_Insurance_Long__c',generalLiabMap );
                        }
                        if(!returnMapVal.containsKey('buildertek__Mark_Up_Non_Slab_or_Labor__c'))
                        {
                            returnMapVal.put('buildertek__Mark_Up_Non_Slab_or_Labor__c',markUpnonSlabMap );
                        }
                        if(!returnMapVal.containsKey('buildertek__Miscellaneous_Rates__c'))
                        {
                            returnMapVal.put('buildertek__Miscellaneous_Rates__c',strMap );
                        }
                        if(!returnMapVal.containsKey('buildertek__Edge__c'))
                        {
                            returnMapVal.put('buildertek__Edge__c',strMap );
                        }
                        if(!returnMapVal.containsKey('buildertek__Slab_Discount_Rate_LongText__c'))
                        {
                            returnMapVal.put('buildertek__Slab_Discount_Rate_LongText__c',blankslabDiscountMap);
                        }
                        if(!returnMapVal.containsKey('buildertek__Fabrication_Labor_Mark_up_LongText__c'))
                        {
                            returnMapVal.put('buildertek__Fabrication_Labor_Mark_up_LongText__c',blankmarkupDiscountMap );
                        }
                        if(!returnMapVal.containsKey('buildertek__Options_Rate__c'))
                        {
                            returnMapVal.put('buildertek__Options_Rate__c',strMap );
                        }
                    //}
                }
            }
      /*  } catch (Exception e) 
        {
            System.debug('Exception--'+e.getMessage());
        }*/
        return returnMapVal;
    }

    @AuraEnabled
    public static Boolean calculateOCIP_CCIP(String JSONData)
    {
        Boolean isSuccess = false;
        try 
        {
           if(String.isNotBlank(JSONData))
           {
            List<buildertek__Project_Selection_Sheet_Takeoff__c> BOMs = (List<buildertek__Project_Selection_Sheet_Takeoff__c>)JSON.deserialize(JSONData, List<buildertek__Project_Selection_Sheet_Takeoff__c>.Class);
            update BOMs;
            isSuccess = true;
           }
            
        } catch (Exception e) {
            isSuccess = false;
            System.debug('Exception--'+e.getMessage());
        }

        return isSuccess;
    }

    

    // private Static Map<String,String> formatExtendedCost(String fieldName,Map<Id,buildertek__Select_Sheet__c> bomLineMap )
    // {
    //     Map<String,String> fabInstallRates = new Map<String,String>();
    //     List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(fieldName, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
    //     for(buildertek.ManagePOlinesController.ExtendedCostWrap wrapObj : wrapperList)
    //     {
    //         if(bomLineMap.containsKey(wrapObj.bomLineId) && bomLineMap.get(wrapObj.bomLineId).buildertek__Quantity__c != null )
    //         {
    //             Decimal extendedCost;
    //             if(String.isNotBlank(wrapObj.singleExtendedCostVal))
    //             {
    //                 extendedCost = Decimal.valueOf(wrapObj.singleExtendedCostVal);
    //                 extendedCost = extendedCost * bomLineMap.get(wrapObj.bomLineId).buildertek__Quantity__c;
    //                 extendedCost = extendedCost.setScale(2);

    //                 fabInstallRates.put(wrapObj.bomLineId, String.valueOf(extendedCost));
    //             }
    //         }
    //     }
    //     return fabInstallRates;
    // }

    private Static Map<String,String> formatExtendedCostForWorkComp(String fieldAPIName,String fieldName,Map<Id,buildertek__Select_Sheet__c> bomLineMap )
    {
        System.debug('fieldAPIName=='+fieldAPIName);
        System.debug('fieldName=='+fieldName);
        System.debug('bomLineMap=='+bomLineMap);
        for(buildertek__Select_Sheet__c val : bomLineMap.values()){
            System.debug(val.Id +'==>' +val);
        }
        Map<String,String> fabInstallRates = new Map<String,String>();
        List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(fieldName, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
        try{

            for(buildertek.ManagePOlinesController.ExtendedCostWrap wrapObj : wrapperList)
            {
                System.debug('wrapObj=== '+wrapObj);
                System.debug('wrapObj.bomLineId=='+wrapObj.bomLineId);
                System.debug('wrapObj.bomLineId exists in a Map=='+bomLineMap.get(wrapObj.bomLineId));
                System.debug('Qty==='+bomLineMap.get(wrapObj.bomLineId).buildertek__Quantity__c);
                if(bomLineMap.containsKey(wrapObj.bomLineId)){
                    System.debug('contains===');
                    if(bomLineMap.containsKey(wrapObj.bomLineId) && bomLineMap.get(wrapObj.bomLineId).buildertek__Quantity__c != null )
                    {
                        Decimal extendedCost;
                        system.debug('wrapObj.extendedCostVal=='+string.valueof(wrapObj.extendedCostVal));
                        if(String.isNotBlank(wrapObj.extendedCostVal))
                        {
                            extendedCost = Decimal.valueOf(wrapObj.extendedCostVal);
                            System.debug('extendedCost=='+extendedCost);
                            fabInstallRates.put(fieldAPIName, String.valueOf(extendedCost));
                        }
                    }
                }
            }
        }catch(Exception e){
            System.debug('error=='+e.getMessage());
            System.debug('errorLine=='+e.getLineNumber());
        }
        return fabInstallRates;
    }

    private Static Map<String,String> formatratePercentage(String fieldName,Map<Id,buildertek__Select_Sheet__c> bomLineMap )
    {
        Map<String,String> fabInstallRates = new Map<String,String>();
        List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(fieldName, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
        for(buildertek.ManagePOlinesController.ExtendedCostWrap wrapObj : wrapperList)
        {
            if(bomLineMap.containsKey(wrapObj.bomLineId)  )
            {
                String rateValue;
                if(String.isNotBlank(wrapObj.percentageVal))
                {
                    rateValue = wrapObj.percentageVal;

                    fabInstallRates.put(wrapObj.bomLineId, rateValue);
                }
            }
        }

        return fabInstallRates;
    }

    @AuraEnabled
    public static BomLineWrapper getBomLineDetails(String bomId)
    {
        BomLineWrapper bomWrapObj = new BomLineWrapper();

        try 
        {
            if(String.isNotBlank(bomId))
            {
                String query = 'SELECT ';
                String fields= ' Id, Name, buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Install_Rate__c, buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c, buildertek__Selection_Sheet_Takeoff__r.buildertek__Install_Only__c, buildertek__Selection_Sheet_Takeoff__r.buildertek__Mark_Up_Non_Slab_or_Labor__c, ';
                fields = fields + 'buildertek__Product__r.ProductCode , buildertek__Takeoff_Line__r.buildertek__TL_SERVICE_CATEGORY__c  ';
                query = query+fields+' FROM buildertek__Select_Sheet__c WHERE (buildertek__Selection_Sheet_Takeoff__c =: bomId) ';
                system.debug('#@#@#Query---'+query);
                List<buildertek__Select_Sheet__c> recList = Database.query(query);
                if(recList != null && recList.size() > 0)
                {
                    bomWrapObj.bomLineList = recList;

                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Install_Rate__c))
                    {
                        List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Fabrication_Install_Rate__c, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
                        System.debug('#@#@Fabricatrion Install Rate wrapperList--'+wrapperList);
                        bomWrapObj.fabAndInstallRateWrap = wrapperList;
                    }
                    else 
                    {
                        bomWrapObj.fabAndInstallRateWrap = createExtendedCostWrap(recList);
                    }

                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c))
                    {
                        List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Fab_Only_Rate__c, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
                        System.debug('#@#@Fab Only Rate wrapperList--'+wrapperList);
                        bomWrapObj.fabOnlyRateWrap = wrapperList;
                    }
                    else 
                    {
                        bomWrapObj.fabOnlyRateWrap = createExtendedCostWrap(recList);
                    }

                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Install_Only__c))
                    {
                        List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Install_Only__c, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
                        System.debug('#@#@Install Only Rate wrapperList--'+wrapperList);
                        bomWrapObj.installOnlyRateWrap = wrapperList;
                    }
                    else 
                    {
                        bomWrapObj.installOnlyRateWrap = createExtendedCostWrap(recList);
                    }

                    if(String.isNotBlank(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Mark_Up_Non_Slab_or_Labor__c))
                    {
                        List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapperList = (List<buildertek.ManagePOlinesController.ExtendedCostWrap>)JSON.deserialize(recList[0].buildertek__Selection_Sheet_Takeoff__r.buildertek__Mark_Up_Non_Slab_or_Labor__c, List<buildertek.ManagePOlinesController.ExtendedCostWrap>.Class);
                        System.debug('#@#@Non Slab Rate wrapperList--'+wrapperList);
                        bomWrapObj.nonSlabLaborMarkupWrap = wrapperList;
                    }
                    else 
                    {
                        bomWrapObj.nonSlabLaborMarkupWrap = createExtendedCostWrap(recList);
                    }

                }
            }
        } catch (Exception e) {
            System.debug('Exception--'+e.getMessage());
        }

        System.debug('#@#@bomWrapObj--'+bomWrapObj);
        return bomWrapObj;
        
    }

    private static List<buildertek.ManagePOlinesController.ExtendedCostWrap> createExtendedCostWrap(List<buildertek__Select_Sheet__c> bomLines)
    {
        List<buildertek.ManagePOlinesController.ExtendedCostWrap> wrapListToReturn = new List<buildertek.ManagePOlinesController.ExtendedCostWrap>();

        for(buildertek__Select_Sheet__c thisBomLine : bomLines)
        {
            buildertek.ManagePOlinesController.ExtendedCostWrap wrapperObj = new buildertek.ManagePOlinesController.ExtendedCostWrap();
            wrapperObj.bomLineId = thisBomLine.Id;
            wrapperObj.productRate = '';

            if(thisBomLine.buildertek__Takeoff_Line__r.buildertek__TL_SERVICE_CATEGORY__c != null && 
            (thisBomLine.buildertek__Takeoff_Line__r.buildertek__TL_SERVICE_CATEGORY__c == 'Fab' ||
            thisBomLine.buildertek__Takeoff_Line__r.buildertek__TL_SERVICE_CATEGORY__c == 'Install'||
            thisBomLine.buildertek__Takeoff_Line__r.buildertek__TL_SERVICE_CATEGORY__c == 'Labor'))
            {
                wrapperObj.percentageVal = '0';
            }
            else {
                wrapperObj.percentageVal = '';
            }
            wrapperObj.extendedCostVal = '';

            wrapListToReturn.add(wrapperObj);
        }
        return wrapListToReturn;
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

    /* this method is used for creating quote and quotelines and associate it with the bom and bomlines
    also logic is added for creating new grouping if not available on the quotelines */
    @AuraEnabled
    public static List<String> createQuoteMethod(String recordId, String mapFieldData){
        List<String> message = new List<String>();
        List<buildertek__Project_Selection_Sheet_Takeoff__c> bom = new List<buildertek__Project_Selection_Sheet_Takeoff__c>();
        List<buildertek__Select_Sheet__c> bomLineList = new List<buildertek__Select_Sheet__c>();
        Map<String, Id> quoteLineGroupMap = new Map<String, Id>();
        List<buildertek__Build_Phase__c> buildPhaseList = new List<buildertek__Build_Phase__c>();
        Map<String, buildertek__Quote_Line_Group__c> newQuoteLineGroupMap = new Map<String, buildertek__Quote_Line_Group__c>();
        Map<Id, buildertek__Quote_Item__c> qtLineMap = new Map<Id, buildertek__Quote_Item__c>();
        
        Map<String,List<String>> myMap = (Map<String,List<String>>)JSON.deserialize(mapFieldData, Map<String,List<String>>.class);

        try {
            bom = [SELECT ID, Name,buildertek__BT_Quote__c,buildertek__Tax_Rate_1__c, 
                    (SELECT Id,Name,buildertek__Quantity__c, buildertek__BL_LIST_PRICE__c, buildertek__Tax_Percent__c, buildertek__Upgrade_Price__c, buildertek__Build_Phase__c, 
                    buildertek__Build_Reference_1__c, buildertek__Base_Location__c, buildertek__Location_Picklist__c, buildertek__Location_Detailed_Area__c, 
                    buildertek__Location_Detail_Reference_1__c,buildertek__BL_UNIT_COST__c, buildertek__BL_SERVICE_CATEGORY__c FROM buildertek__Selection_Sheet_Takeoff_Lines__r) 
                    FROM buildertek__Project_Selection_Sheet_Takeoff__c WHERE Id =:recordId];
            
            buildPhaseList = [SELECT Id, Name FROM buildertek__Build_Phase__c];
            
            for (buildertek__Quote_Line_Group__c qtGroup : [SELECT Id, Name FROM buildertek__Quote_Line_Group__c]) {
                quoteLineGroupMap.put(qtGroup.Name, qtGroup.Id);
            }

            if (buildPhaseList.size() > 0) {
                for (buildertek__Build_Phase__c bPhase : buildPhaseList) {
                    if (!quoteLineGroupMap.containsKey(bPhase.Name)) {
                        buildertek__Quote_Line_Group__c qtLineGp = new buildertek__Quote_Line_Group__c();
                        qtLineGp.Name = bPhase.Name;
                        newQuoteLineGroupMap.put(qtLineGp.Name ,qtLineGp);
                    }
                }
                insert newQuoteLineGroupMap.values();
            }

            if (bom.size() > 0 && bom[0].buildertek__BT_Quote__c == null) {
                if (bom[0].buildertek__Selection_Sheet_Takeoff_Lines__r.size() > 0) {
                    buildertek__Quote__c quote = new buildertek__Quote__c();
                    quote.Name = 'Quote - '+bom[0].Name;
                    quote.buildertek__Bill_of_Material__c = bom[0].Id;
                    insert quote;
                    bom[0].buildertek__BT_Quote__c = quote.Id;
                    update bom[0];
                    for (buildertek__Select_Sheet__c bomLine : bom[0].buildertek__Selection_Sheet_Takeoff_Lines__r) {
                        buildertek__Quote_Item__c qtLine = new buildertek__Quote_Item__c();
                        Decimal markUp;
                        Decimal discount;
                        Decimal salesTax;
                        Decimal TotalCost;
                        String str = myMap.get(bomLine.Id)[2];
                        String str1 = myMap.get(bomLine.Id)[0];
                        String str2 = myMap.get(bomLine.Id)[3];
                        String groupName = myMap.get(bomLine.Id)[1];
                        String str3 = myMap.get(bomLine.Id)[4];
                        if (String.isNotBlank(str)) {
                            markUp = decimal.valueOf(str);
                        }else{
                            markUp = 0;
                        }
                        if (String.isNotBlank(str1)) {
                            discount = decimal.valueOf(str1);
                        }else{
                            discount = 0;
                        }
                        if (String.isNotBlank(str2)) {
                            salesTax = decimal.valueOf(str2);
                        }else{
                            salesTax = 0;
                        }
                        
                        qtLine.Name = 'Qt '+bomLine.Name;
                        qtLine.buildertek__Quantity__c = bomLine.buildertek__Quantity__c;
                        if (bomLine.buildertek__Upgrade_Price__c != null) {
                            qtLine.buildertek__Unit_Cost__c = bomLine.buildertek__Upgrade_Price__c;
                        } else if(bomLine.buildertek__BL_LIST_PRICE__c != null && bomLine.buildertek__BL_LIST_PRICE__c != 0 ){
                            qtLine.buildertek__Unit_Cost__c = bomLine.buildertek__BL_LIST_PRICE__c;
                        }
                        else{
                            qtLine.buildertek__Unit_Cost__c = decimal.valueOf(str3);
                        }
                        qtLine.buildertek__Quote__c = quote.Id;
                        qtLine.buildertek__Markup__c = markUp;
                        qtLine.buildertek__Additional_Discount__c = discount;
                        qtLine.buildertek__Sales_Tax_Amount_Manual__c = salesTax;
                        qtLine.buildertek__Tax__c = bomLine.buildertek__Tax_Percent__c;
                        qtLine.buildertek__BOM_Line__c = bomLine.Id;
                        qtLine.buildertek__Build_Phase__c = bomLine.buildertek__Build_Phase__c;
                        qtLine.buildertek__Build_Reference_1__c = bomLine.buildertek__Build_Reference_1__c;
                        qtLine.buildertek__Base_Location__c = bomLine.buildertek__Base_Location__c;
                        qtLine.buildertek__Location_Picklist__c = bomLine.buildertek__Location_Picklist__c;
                        qtLine.buildertek__Location_Detailed_Area__c = bomLine.buildertek__Location_Detailed_Area__c;
                        qtLine.buildertek__Location_Detail_Reference_1__c = bomLine.buildertek__Location_Detail_Reference_1__c;
                        qtLine.buildertek__BL_SERVICE_CATEGORY__c = bomLine.buildertek__BL_SERVICE_CATEGORY__c;

                        // *check if the value come for first time then newQuoteLineGroupMap should have the values
                        if (newQuoteLineGroupMap.containsKey(groupName)) {
                            qtLine.buildertek__Grouping__c = newQuoteLineGroupMap.get(groupName).Id;
                        }
                        // *if the values are already there then quoteLineGroupMap should have the values
                        else{ 
                            qtLine.buildertek__Grouping__c = quoteLineGroupMap.get(groupName);
                        }
                        qtLineMap.put(bomLine.Id,qtLine);
                    }
                    insert qtLineMap.values();

                    for (buildertek__Select_Sheet__c bomLine : bom[0].buildertek__Selection_Sheet_Takeoff_Lines__r) {
                        if (qtLineMap.containsKey(bomLine.Id)) {
                            bomLine.buildertek__BT_Quote_Line__c = qtLineMap.get(bomLine.Id).Id;
                            bomLineList.add(bomLine);
                        }
                    }
                    update bomLineList;
                    message.add('Success');
                    message.add(quote.Id);
                }else {
                    message.add('null');
                }
            }else{
                message.add('notNull');
            }
            return message;
        } catch (Exception e) {
            String str = 'Error Message : '+ e.getMessage()+ ' Error Line Number : ' + e.getLineNumber();
            message.add(str);
            return message;
        }
    }
    
}