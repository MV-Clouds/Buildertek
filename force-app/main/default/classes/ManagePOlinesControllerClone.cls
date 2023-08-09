public with sharing class ManagePOlinesControllerClone {
    
    @AuraEnabled
    public static buildertek__Project_Selection_Sheet_Takeoff__c getProject(String recordId){
        String projectName = '';
        buildertek__Project_Selection_Sheet_Takeoff__c Porecord = [Select Id, buildertek__Project__r.Name from buildertek__Project_Selection_Sheet_Takeoff__c  where Id =: recordId LIMIT 1];
        projectName = Porecord.buildertek__Project__r.Name;
        return Porecord;
    }
    
    @AuraEnabled
    public static RfqDataTableWrapper getProductOptionLines(Integer pageNumber, Integer pageSize, string recordId, String vendorName, String category, String tradeType,String purchaseOrder, String productType, String buildPhase,Boolean toggleValue){
        List<buildertek__Select_Sheet__c> productOptionLineList = new List<buildertek__Select_Sheet__c>();
        
        
        //system.debug(vendorName+''+tradeType+''+description+''+description!='');
        
        Integer offset = (pageNumber - 1) * pageSize;
        //Total Records
        Integer totalRecords = 0;
        if(vendorName != '' || tradeType != '' || purchaseOrder != '' || category != '' || productType != '' || buildPhase != ''){
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
        }
        
        
        Integer recordEnd = pageSize * pageNumber;
        
        //Instance of Contact DataTable Wrapper Class
        RfqDataTableWrapper objDT = new RfqDataTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
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
        
        if(vendorName != '' || tradeType != '' || purchaseOrder != '' || category != '' || productType != '' || buildPhase != ''){
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
            /*if(toggleValue){
queryList = queryList+ ' ORDER BY buildertek__Vendor__r.Name LIMIT :pageSize OFFSET :offset';
}else{
queryList = queryList+ ' ORDER BY buildertek__Build_Phase__r.Name LIMIT :pageSize OFFSET :offset';
}*/
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
                                /*LIMIT :pageSize
                                OFFSET :offset*/];
                                            /* }else{
                                objDT.recordList = [Select Id,Name,buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__Upgrade_Price__c,
                                buildertek__Standard__c,buildertek__Location_Picklist__c,buildertek__Product_Type__c,buildertek__Product_Type__r.Name,
                                buildertek__Category__c,buildertek__Category__r.Name,buildertek__Trade_Type__c,buildertek__Trade_Type__r.Name,
                                buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name,buildertek__Product__c,buildertek__Product__r.Name
                                from buildertek__Select_Sheet__c  where buildertek__Selection_Sheet_Takeoff__c =: recordId Order by buildertek__Build_Phase__r.Name                          
                                LIMIT :pageSize
                                OFFSET :offset];
                                }*/
            
        }
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
              priceBookId = '01s41000000kFZJAA2'; //standard price book
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
        List<Product2> productList = [SELECT Id,Name,StockKeepingUnit,buildertek__Vendor__c,buildertek__Vendor__r.Name FROM Product2 WHERE 
                                      Name =: optionLineItem.buildertek__Product__r.Name]; //buildertek__Vendor__c !=: optionLineItem.buildertek__Product__r.buildertek__Vendor__c AND
        
        Set<String> productIds = new Set<String>();
        system.debug(productList);
        for(Product2 p: productList){
            productIds.add(p.Id);
        }
        Map<String,Decimal> productPriceMap = new Map<String,Decimal>();
        
        List<PricebookEntry> entryList = [SELECT Product2Id,buildertek__Unit_Cost__c FROM PricebookEntry WHERE Pricebook2Id =: '01s41000000kFZJAA2' AND Product2Id IN:productIds];
        for(PricebookEntry entry: entryList){
            productPriceMap.put(entry.Product2Id,entry.buildertek__Unit_Cost__c);
        }
        
        List<Object> vendorItemList = new List<Object>();
        //system.debug(vendorList);
        for(Product2 p: productList){
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
        system.debug(vendorItemList);
        return vendorItemList;
    }
    @AuraEnabled 
    public static List<Object> getprovendors(String optionLineID){
        list<buildertek__Select_Sheet__c> optionLineItemslist = [SELECT Id,Name,buildertek__Vendor__c,buildertek__Product__c,buildertek__Product__r.buildertek__Vendor__c,buildertek__Product__r.Name FROM buildertek__Select_Sheet__c WHERE buildertek__Selection_Sheet_Takeoff__c =:optionLineID];
        system.debug(optionLineItemslist);
        list<Id> sheetids = new list<Id>();
        List<Product2> productList = [SELECT Id,Name,StockKeepingUnit,buildertek__Vendor__c,buildertek__Vendor__r.Name FROM Product2 /*WHERE 
                                      Name =: optionLineItem.buildertek__Product__r.Name*/]; 
        for(buildertek__Select_Sheet__c sheetRec : optionLineItemslist){
            for(Product2 proRec : productList){
                if(sheetRec.buildertek__Product__r.Name != proRec.Name){
                     sheetids.add(sheetRec.id);
                }
            }
        }
        list<buildertek__Select_Sheet__c> sheetItemslist = [SELECT Id,Name,buildertek__Vendor__c,buildertek__Product__c,buildertek__Product__r.buildertek__Vendor__c,
                                                                 buildertek__Product__r.Name FROM buildertek__Select_Sheet__c WHERE Id  =:sheetids];
        List<Object> vendorItemList = new List<Object>();
        for(buildertek__Select_Sheet__c p: sheetItemslist){
            ProductClass productRec = new ProductClass();
            productRec.sheetId = p.Id;
            productRec.isproduct = false;
            vendorItemList.add(productRec);
        }
        system.debug(vendorItemList);
        return vendorItemList;
    }

    @AuraEnabled
    public static String createNewOptionLine(String productId, String projectId, String optionLineId){
        Product2 selectedProduct = [SELECT Id,Name,StockKeepingUnit,buildertek__Product_Type__c,buildertek__Trade_Type__c,buildertek__Type__c,buildertek__Vendor__c, 
                                    buildertek__Category__c FROM Product2 WHERE Id =: productId];
        
        buildertek__Select_Sheet__c optionLineRecord = [SELECT Id,Name,buildertek__Vendor__c,buildertek__Product__c,buildertek__Product__r.Name,buildertek__Purchase_Order__c, 
                                                       buildertek__Takeoff_Line__c,buildertek__Selection_Sheet_Takeoff__c,buildertek__Location_Picklist__c,buildertek__Build_Phase__c,
                                                        buildertek__Quantity__c
                                                       FROM buildertek__Select_Sheet__c WHERE Id =: optionLineId];
        
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
        newOptionLine.buildertek__Takeoff_Line__c = takeoff;//optionLineRecord.buildertek__Takeoff_Line__c;
        system.debug(optionLineRecord.buildertek__Takeoff_Line__c+','+ newOptionLine.buildertek__Takeoff_Line__c);
        //newOptionLine.buildertek__Standard__c
        //instructios
        //upgraded price
        
        newOptionLine.buildertek__Location_Picklist__c = optionLineRecord.buildertek__Location_Picklist__c;
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
        
        @AuraEnabled
        public List<buildertek__Select_Sheet__c> recordList{ get; set; }
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
    public class ProductClass{
         @AuraEnabled
        public String sheetId {get;set;}
        @AuraEnabled
        public Boolean isproduct {get;set;}
    }
    
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
        @AuraEnabled
        public string Message {get;set;}
        
    }
    
}