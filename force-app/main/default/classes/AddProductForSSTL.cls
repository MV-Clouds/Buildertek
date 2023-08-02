public with sharing class AddProductForSSTL{
 @AuraEnabled
    public static Boolean getadminvalue(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id,buildertek__Update_Quantity__c
                                                                                              from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'BOM Settings'];
        return adminInterfaceNodeConfigurations.buildertek__Update_Quantity__c;
    }
    @AuraEnabled
    public static string productrecords(List<String> productIds){
        //list<Product2> productlist = [Select Id,Name,StockKeepingUnit from Product2 Where Id IN:productIds AND StockKeepingUnit = null];
        list<Product2> productlist = [Select Id,Name,StockKeepingUnit,ProductCode from Product2 Where Id IN:productIds AND ProductCode=null AND StockKeepingUnit = null];
        if(productlist.size() >0){
            return 'success';
        }else{
            return null;
        }
        
    }
    @AuraEnabled
    public static void updateBOMquantityvalues(List<buildertek__Select_Sheet__c> prodIds){
        update prodIds;
    }
    @AuraEnabled
    public static string verifytakeofflines(String sheetId){
        list<buildertek__Select_Sheet__c> bomLines = [select Id, Name,buildertek__Takeoff_Line__c,buildertek__Takeoff_Line__r.Name,buildertek__Takeoff_Line__r.buildertek__Project_Takeoff__c
                                                      from buildertek__Select_Sheet__c  where buildertek__Selection_Sheet_Takeoff__c =:sheetId];
        list<id> selectsheetid = new list<id>();
        for(buildertek__Select_Sheet__c sheetRec : bomLines){
            selectsheetid.add(sheetRec.buildertek__Takeoff_Line__c);
        }
        list<buildertek__Project_Takeoff_Lines__c> takeofflines = [select Id, Name,buildertek__Project_Takeoff__c,buildertek__Suppress_Record__c
                                                                      from buildertek__Project_Takeoff_Lines__c where 
                                                                      Id NOT IN: selectsheetid AND buildertek__Project_Takeoff__c =: bomLines[0].buildertek__Takeoff_Line__r.buildertek__Project_Takeoff__c AND
                                                                      buildertek__Suppress_Record__c = 'No'];
        if(takeofflines.size() > 0){
            return 'takeofflines';
        }else{
            return 'No lines';
        }
        
    }
    @AuraEnabled
    public static list<buildertek__Select_Sheet__c> updatequantityvalues(String prodIds){
        list<Id> takeoffid= new list<Id>();
        list<buildertek__Select_Sheet__c> productlist = new list<buildertek__Select_Sheet__c>();
        list<buildertek__Select_Sheet__c> productlist1 = new list<buildertek__Select_Sheet__c>();
        list<buildertek__Select_Sheet__c> buildrefproductlist = new list<buildertek__Select_Sheet__c>();
        list<buildertek__Select_Sheet__c> buildrefproductlist2 = new list<buildertek__Select_Sheet__c>();
        list<buildertek__Select_Sheet__c> buildrefproductlist3 = new list<buildertek__Select_Sheet__c>();
        list<buildertek__Select_Sheet__c> buildrefproductlist4 = new list<buildertek__Select_Sheet__c>();
        list<buildertek__Select_Sheet__c> buildrefproductlist5 = new list<buildertek__Select_Sheet__c>();
        list<buildertek__Select_Sheet__c> schemeproductlist = new list<buildertek__Select_Sheet__c>();
        string schemeduplicatecheck = '';
        string duplicatebuildcheck1 = '';
         string locationduplicatebuildcheck1 = '';
        string duplicatecheck = '';
        string locationduplicatecheck = '';
        string duplicatebuildcheck = '';
        Decimal takeoffRec;
        string logic;
        list<buildertek__Select_Sheet__c> bomLines = [select Id, Name,buildertek__Takeoff_Line__c,buildertek__Takeoff_Line__r.Name,buildertek__Takeoff_Line__r.buildertek__Project_Takeoff__c,buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c,
                                                      buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c,buildertek__Takeoff_Line__r.buildertek__Build_Phase__c,
                                                      buildertek__Takeoff_Line__r.buildertek__Product_Type__c,buildertek__Takeoff_Line__r.buildertek__Product_Type__r.Name,
                                                      buildertek__Takeoff_Line__r.buildertek__Product_Size__c,buildertek__QunUpdate__c,buildertek__Selection_Sheet_Takeoff__c,
                                                       buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c,buildertek__Takeoff_Line__r.buildertek__Base_Location__c,
                                                      buildertek__Takeoff_Line__r.buildertek__TO_SUMMARY_VALUE__c,buildertek__Takeoff_Line__r.buildertek__StockKeepingUnit__c,
                                                      buildertek__Takeoff_Line__r.buildertek__Location__c,buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c,buildertek__Quantity__c,
                                                      buildertek__Takeoff_Line__r.buildertek__TO_LOCATION_DETAIL_REF__c,buildertek__Sum_Value__c,buildertek__Takeoff_Line__r.buildertek__Quantity__c, buildertek__Slab_SQF__c,
                                                      buildertek__Product__c,buildertek__Product__r.StockKeepingUnit,buildertek__Product__r.ProductCode
                                                      from buildertek__Select_Sheet__c  where buildertek__Selection_Sheet_Takeoff__c =:prodIds];
        list<buildertek__Project_Takeoff_Lines__c> takeofflines = [select Id, Name,buildertek__TO_LAST_EST_DATE__c,
                                                                   buildertek__TO_VERSION__c,buildertek__Build_Phase__c,buildertek__Product_Type__c,
                                                                   buildertek__Product_Type__r.Name,buildertek__TO_BUILD_REF1__c,buildertek__Base_Location__c,
                                                                   buildertek__TO_SUMMARY_VALUE__c,buildertek__StockKeepingUnit__c,buildertek__TL_QUANTITY_2__c,
                                                                   buildertek__Location__c,buildertek__Location_Detailed_Area__c,
                                                                   buildertek__TO_LOCATION_DETAIL_REF__c,buildertek__Quantity__c, buildertek__TO_SLAB_SF__c, buildertek__Slab_SQFT_2__c
                                                                   from buildertek__Project_Takeoff_Lines__c where buildertek__Project_Takeoff__c =: bomLines[0].buildertek__Takeoff_Line__r.buildertek__Project_Takeoff__c];

      map<string,list<buildertek__Select_Sheet__c>> productskuMap = new map<string,list<buildertek__Select_Sheet__c>>();
        for(buildertek__Select_Sheet__c bomrec:bomLines){
            if(productskuMap.get(bomrec.buildertek__Product__r.ProductCode) != null){
                List<buildertek__Select_Sheet__c> bomLineList = productskuMap.get(bomrec.buildertek__Product__r.ProductCode);
                bomLineList.add(bomrec);
                productskuMap.put(bomrec.buildertek__Product__r.ProductCode,bomLineList);
            }else if(productskuMap.get(bomrec.buildertek__Product__r.StockKeepingUnit) != null){
                List<buildertek__Select_Sheet__c> bomLineList = productskuMap.get(bomrec.buildertek__Product__r.StockKeepingUnit);
                bomLineList.add(bomrec);
                productskuMap.put(bomrec.buildertek__Product__r.StockKeepingUnit,bomLineList);
            }else{
                List<buildertek__Select_Sheet__c> bomLineList =  new List<buildertek__Select_Sheet__c>();
                bomLineList.add(bomrec);
                //productskuMap.put(bomrec.buildertek__Product__r.StockKeepingUnit,bomLineList);
                if(bomrec.buildertek__Product__r.ProductCode != null)
                {
                    productskuMap.put(bomrec.buildertek__Product__r.ProductCode,bomLineList);
                }
                else
                {
                    productskuMap.put(bomrec.buildertek__Product__r.StockKeepingUnit,bomLineList);
                }
            }
            
        }
        system.debug('productskuMap -->'+productskuMap.keySet());
        system.debug('productskuMap -->'+productskuMap.keySet().size());
       Boolean notselectedbomLinesId;
        if(productskuMap.keySet().size() == 1){
           notselectedbomLinesId = false;
        }else {
            notselectedbomLinesId = true;
        }
        if(notselectedbomLinesId == false){
            for(integer i= 0; i<bomLines.size(); i++){
                for(integer j= 0; j< bomLines.size(); j++){ 
                    if(i != j){
                        System.debug('**  bomLines[i]:116 ------------------------------------>: ' + JSON.serialize(bomLines[i]));
                        System.debug('**  bomLines[j]:117------------------------------------>: ' + JSON.serialize(bomLines[j]));
                        if(bomLines[i].buildertek__Product__r.ProductCode != null && bomLines[j].buildertek__Product__r.ProductCode != null)
                        {
                            if(bomLines[i].buildertek__Product__r.ProductCode == bomLines[j].buildertek__Product__r.ProductCode){
                                if(!locationduplicatecheck.contains(bomLines[i].id)){
                                            String productCodeStr = bomLines[i].buildertek__Product__r.ProductCode;
                                            if(productCodeStr.length() >= 6){
                                                String xyz = bomLines[i].buildertek__Product__r.ProductCode != null ? bomLines[i].buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                if(xyz == '0'){
                                                    bomLines[i].buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                }else if(xyz == '1'){
                                                    bomLines[i].buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                } 
                                            }
                                            bomLines[i].buildertek__Sum_Value__c ='Location';
                                            productlist1.add(bomLines[i]);
                                        }
                                        locationduplicatecheck += bomLines[i].id;
                            }
                        }else if(bomLines[i].buildertek__Product__r.StockKeepingUnit != null && bomLines[j].buildertek__Product__r.StockKeepingUnit != null)
                        {
                            if(bomLines[i].buildertek__Product__r.StockKeepingUnit == bomLines[j].buildertek__Product__r.StockKeepingUnit){
                                if(!locationduplicatecheck.contains(bomLines[i].id)){
                                            String producsku = bomLines[i].buildertek__Product__r.StockKeepingUnit;
                                            if(producsku.length() >= 6){
                                                String xyz = bomLines[i].buildertek__Product__r.StockKeepingUnit != null ? bomLines[i].buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                if(xyz == '0'){
                                                    bomLines[i].buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                }else if(xyz == '1'){
                                                    bomLines[i].buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                } 
                                            }
                                            bomLines[i].buildertek__Sum_Value__c ='Location';
                                            productlist1.add(bomLines[i]);
                                        }
                                        locationduplicatecheck += bomLines[i].id;
                            }
                        }
                        
                    }
                }
            }
            list<buildertek__Project_Takeoff_Lines__c> buildrefproductlist1 = new list<buildertek__Project_Takeoff_Lines__c>();
            system.debug('**'+bomLines.size());
            for(buildertek__Project_Takeoff_Lines__c sheetrec : takeofflines){
                integer k = 0;
                for(buildertek__Select_Sheet__c sheetrec1 : productlist1){
                    if(sheetrec.buildertek__TO_SUMMARY_VALUE__c == sheetrec1.buildertek__Sum_Value__c){
                        if(!locationduplicatebuildcheck1 .contains(sheetrec1.id)){
                            if(sheetrec1.buildertek__QunUpdate__c == false){
                                if(sheetrec1.buildertek__Takeoff_Line__r.buildertek__Product_Size__c == 'Jumbo'){
                                    if(sheetrec.buildertek__TL_QUANTITY_2__c != 0){
                                        if(k == 0){
                                            sheetrec1.buildertek__Quantity__c = sheetrec.buildertek__TL_QUANTITY_2__c;
                                            k++;
                                        }else{
                                            sheetrec1.buildertek__Quantity__c = 0;  
                                        }
                                        sheetrec1.buildertek__QunUpdate__c = true;
                                    }
                                    buildrefproductlist2.add(sheetrec1);
                                    
                                }else{
                                    if(sheetrec.buildertek__Quantity__c != 0){
                                        if(k == 0){
                                            sheetrec1.buildertek__Quantity__c = sheetrec.buildertek__Quantity__c;
                                            k++;
                                        }else{
                                            sheetrec1.buildertek__Quantity__c = 0;  
                                        }
                                    }
                                    sheetrec1.buildertek__QunUpdate__c = true;
                                    buildrefproductlist2.add(sheetrec1);
                                }
                            }
                        }
                        buildrefproductlist3.add(sheetrec1);
                        locationduplicatebuildcheck1 += sheetrec1.id; 
                    }
                }
            }
            if(buildrefproductlist2.size() > 0){
                update buildrefproductlist2;
            }
        }
        else{
            list<buildertek__Select_Sheet__c> bomLines9 = [select Id, Name,buildertek__Takeoff_Line__c,buildertek__Takeoff_Line__r.Name,buildertek__Takeoff_Line__r.buildertek__Project_Takeoff__c,buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c,
                                                        buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c,buildertek__Takeoff_Line__r.buildertek__Build_Phase__c,
                                                        buildertek__Takeoff_Line__r.buildertek__Product_Type__c,buildertek__Takeoff_Line__r.buildertek__Product_Type__r.Name,
                                                        buildertek__Takeoff_Line__r.buildertek__Product_Size__c,buildertek__QunUpdate__c,buildertek__Selection_Sheet_Takeoff__c,
                                                        buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c,buildertek__Takeoff_Line__r.buildertek__Base_Location__c,
                                                        buildertek__Takeoff_Line__r.buildertek__TO_SUMMARY_VALUE__c,buildertek__Takeoff_Line__r.buildertek__StockKeepingUnit__c,
                                                        buildertek__Takeoff_Line__r.buildertek__Location__c,buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c,buildertek__Quantity__c,
                                                        buildertek__Takeoff_Line__r.buildertek__TO_LOCATION_DETAIL_REF__c,buildertek__Sum_Value__c,buildertek__Takeoff_Line__r.buildertek__Quantity__c, buildertek__Slab_SQF__c,
                                                        buildertek__Product__c,buildertek__Product__r.StockKeepingUnit,buildertek__Product__r.ProductCode
                                                        from buildertek__Select_Sheet__c  where buildertek__Selection_Sheet_Takeoff__c =:prodIds AND buildertek__Takeoff_Line__r.buildertek__Product_Type__r.Name = 'CounterTop'];    
                map<string,list<buildertek__Select_Sheet__c>> productskuMap1 = new map<string,list<buildertek__Select_Sheet__c>>();
                System.debug('**  bomLines9:214 ------------------------------------>: ' + JSON.serialize(bomLines9));

                for(buildertek__Select_Sheet__c bomlinerec:bomLines9){
                    System.debug('**  productskuMap1:215 ------------------------------------>: ' + JSON.serialize(productskuMap1));
                    System.debug('**  bomlinerec.buildertek__Product__r.ProductCode:216------------------------------------>: ' + bomlinerec.buildertek__Product__r.ProductCode);
                    if(productskuMap1.get(bomlinerec.buildertek__Product__r.ProductCode) != null){
                        List<buildertek__Select_Sheet__c> bomLinesList = productskuMap1.get(bomlinerec.buildertek__Product__r.ProductCode);
                        bomLinesList.add(bomlinerec);
                        productskuMap1.put(bomlinerec.buildertek__Product__r.ProductCode,bomLinesList);
                    }else if(productskuMap1.get(bomlinerec.buildertek__Product__r.StockKeepingUnit) != null){
                        List<buildertek__Select_Sheet__c> bomLinesList = productskuMap1.get(bomlinerec.buildertek__Product__r.StockKeepingUnit);
                        bomLinesList.add(bomlinerec);
                        productskuMap1.put(bomlinerec.buildertek__Product__r.StockKeepingUnit,bomLinesList);
                    }else{
                        List<buildertek__Select_Sheet__c> bomLinesList =  new List<buildertek__Select_Sheet__c>();
                        bomLinesList.add(bomlinerec);
                        if(bomlinerec.buildertek__Product__r.ProductCode != null)
                        {
                            productskuMap1.put(bomlinerec.buildertek__Product__r.ProductCode,bomLinesList);
                        }
                        else
                        {
                            productskuMap1.put(bomlinerec.buildertek__Product__r.StockKeepingUnit,bomLinesList);
                    }
                        //productskuMap1.put(bomlinerec.buildertek__Product__r.StockKeepingUnit,bomLinesList);
                    }

                }
                system.debug('productskuMap1 -->'+productskuMap1.keySet());
                system.debug('productskuMap -->'+productskuMap1.keySet().size());
                Boolean notselectedbomLinesId1;
                if(productskuMap1.keySet().size() == 1){
                    notselectedbomLinesId1 = false;
                    integer m = 0;
                    System.debug('**  bomLines9:246 ------------------------------------>: ' + JSON.serialize(bomLines9));



                    for(buildertek__Select_Sheet__c shetRec : bomLines9){

                        integer n = 0;
                        for(buildertek__Select_Sheet__c shetRec1 : bomLines9){
                            System.debug('**  shetRec:247 ------------------------------------>: ' + JSON.serialize(shetRec));
                            System.debug('**  shetRec1:248 ------------------------------------>: ' + JSON.serialize(shetRec1));
                            if(m != n){
                        if(shetRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                shetRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                shetRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                && shetRec.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c
                                && shetRec.buildertek__Takeoff_Line__r.buildertek__Base_Location__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__Base_Location__c
                                && shetRec.buildertek__Takeoff_Line__r.buildertek__Location__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__Location__c
                                && shetRec.buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c
                                && shetRec.buildertek__Takeoff_Line__r.buildertek__TO_LOCATION_DETAIL_REF__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_LOCATION_DETAIL_REF__c){
                                    if(!duplicatecheck.contains(shetRec.id)){
                                        if(shetRec.buildertek__Product__r.ProductCode != null)
                                        {
                                        String producsku = shetRec.buildertek__Product__r.ProductCode;
                                        if(producsku.length() >= 6){
                                            String xyz = shetRec.buildertek__Product__r.ProductCode != null ? shetRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                            if(xyz == '0'){
                                                shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                            }else if(xyz == '1'){
                                                shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                            } 
                                        }
                                        shetRec.buildertek__Sum_Value__c ='Location Detail Reference 1';
                                        productlist.add(shetRec);
                                        }else if(shetRec.buildertek__Product__r.StockKeepingUnit != null)
                                        {
                                            String producsku = shetRec.buildertek__Product__r.StockKeepingUnit;
                                            if(producsku.length() >= 6){
                                            String xyz = shetRec.buildertek__Product__r.StockKeepingUnit != null ? shetRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                            if(xyz == '0'){
                                                shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                            }else if(xyz == '1'){
                                                shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                            } 
                                            }
                                        shetRec.buildertek__Sum_Value__c ='Location Detail Reference 1';
                                        productlist.add(shetRec);
                                        }
                                    }
                                    duplicatecheck += shetRec.id;
                                }else if(shetRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                        shetRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                        && shetRec.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c
                                        && shetRec.buildertek__Takeoff_Line__r.buildertek__Base_Location__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__Base_Location__c
                                        && shetRec.buildertek__Takeoff_Line__r.buildertek__Location__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__Location__c
                                        && shetRec.buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c
                                        ){
                                            system.debug('%%%%%%%%%%%%%%%%%'+shetRec.id);
                                            if(!duplicatecheck.contains(shetRec.id)){

                                                if(shetRec.buildertek__Product__r.ProductCode != null)
                                                {
                                                    String producsku = shetRec.buildertek__Product__r.ProductCode;
                                                    if(producsku.length() >= 6){
                                                    String xyz = shetRec.buildertek__Product__r.ProductCode != null ? shetRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                shetRec.buildertek__Sum_Value__c ='Location Detailed Area';
                                                productlist.add(shetRec);
                                                }
                                                else if(shetRec.buildertek__Product__r.StockKeepingUnit != null)
                                                {
                                                    String producsku = shetRec.buildertek__Product__r.StockKeepingUnit;
                                                    if(producsku.length() >= 6){
                                                    String xyz = shetRec.buildertek__Product__r.StockKeepingUnit != null ? shetRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                shetRec.buildertek__Sum_Value__c ='Location Detailed Area';
                                                productlist.add(shetRec);
                                                }
                                                
                                            }
                                            duplicatecheck += shetRec.id; 
                                }else if(shetRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                        shetRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                        && shetRec.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c
                                        && shetRec.buildertek__Takeoff_Line__r.buildertek__Base_Location__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__Base_Location__c
                                        && shetRec.buildertek__Takeoff_Line__r.buildertek__Location__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__Location__c
                                        ){
                                            system.debug('%%%%%%%%%%%%%%%%%');
                                            if(!duplicatecheck.contains(shetRec.id)){

                                                if(shetRec.buildertek__Product__r.ProductCode != null)
                                                {
                                                    String producsku = shetRec.buildertek__Product__r.ProductCode;
                                                    if(producsku.length() >= 6){
                                                    String xyz = shetRec.buildertek__Product__r.ProductCode != null ? shetRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                shetRec.buildertek__Sum_Value__c ='Location';
                                                productlist.add(shetRec);
                                                }
                                                else if(shetRec.buildertek__Product__r.StockKeepingUnit != null)
                                                {
                                                    String producsku = shetRec.buildertek__Product__r.StockKeepingUnit;
                                                    if(producsku.length() >= 6){
                                                    String xyz = shetRec.buildertek__Product__r.StockKeepingUnit != null ? shetRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                shetRec.buildertek__Sum_Value__c ='Location';
                                                productlist.add(shetRec);
                                                }
                                            }
                                            duplicatecheck += shetRec.id; 
                                } else if(shetRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                        shetRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                        && shetRec.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c
                                        && shetRec.buildertek__Takeoff_Line__r.buildertek__Base_Location__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__Base_Location__c
                                        ){
                                            system.debug('%%%%%%%%%%%%%%%%%');
                                            if(!duplicatecheck.contains(shetRec.id)){

                                                if(shetRec.buildertek__Product__r.ProductCode != null)
                                                {
                                                    String producsku = shetRec.buildertek__Product__r.ProductCode;
                                                    if(producsku.length() >= 6){
                                                    String xyz = shetRec.buildertek__Product__r.ProductCode != null ? shetRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                shetRec.buildertek__Sum_Value__c ='Base Location';
                                                productlist.add(shetRec);
                                                }
                                                else if(shetRec.buildertek__Product__r.StockKeepingUnit != null)
                                                {
                                                    String producsku = shetRec.buildertek__Product__r.StockKeepingUnit;
                                                    if(producsku.length() >= 6){
                                                    String xyz = shetRec.buildertek__Product__r.StockKeepingUnit != null ? shetRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                shetRec.buildertek__Sum_Value__c ='Base Location';
                                                productlist.add(shetRec);
                                                }
                                            }
                                            duplicatecheck += shetRec.id; 
                                }else if(shetRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                        shetRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                        && shetRec.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c
                                        ){
                                            system.debug('%%%%%%%%%%%%%%%%%');
                                            if(!duplicatecheck.contains(shetRec.id)){

                                                if(shetRec.buildertek__Product__r.ProductCode != null)
                                                {
                                                    String producsku = shetRec.buildertek__Product__r.ProductCode;
                                                    if(producsku.length() >= 6){
                                                    String xyz = shetRec.buildertek__Product__r.ProductCode != null ? shetRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                shetRec.buildertek__Sum_Value__c ='Building Ref 1';
                                                productlist.add(shetRec);
                                                }
                                                else if(shetRec.buildertek__Product__r.StockKeepingUnit != null)
                                                {
                                                    String producsku = shetRec.buildertek__Product__r.StockKeepingUnit;
                                                    if(producsku.length() >= 6){
                                                    String xyz = shetRec.buildertek__Product__r.StockKeepingUnit != null ? shetRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                shetRec.buildertek__Sum_Value__c ='Building Ref 1';
                                                productlist.add(shetRec);
                                                }
                                            }
                                            duplicatecheck += shetRec.id; 
                                }else if(shetRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                        shetRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == shetRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                        ){
                                            if(!duplicatecheck.contains(shetRec.id)){

                                                if(shetRec.buildertek__Product__r.ProductCode != null)
                                                {
                                                    String producsku = shetRec.buildertek__Product__r.ProductCode;
                                                    if(producsku.length() >= 6){
                                                    String xyz = shetRec.buildertek__Product__r.ProductCode != null ? shetRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                shetRec.buildertek__Sum_Value__c ='Project';
                                                productlist.add(shetRec);
                                                }
                                                else if(shetRec.buildertek__Product__r.StockKeepingUnit != null)
                                                {
                                                    String producsku = shetRec.buildertek__Product__r.StockKeepingUnit;
                                                    if(producsku.length() >= 6){
                                                    String xyz = shetRec.buildertek__Product__r.StockKeepingUnit != null ? shetRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        shetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                shetRec.buildertek__Sum_Value__c ='Project';
                                                productlist.add(shetRec);
                                                }
                                            }
                                            duplicatecheck += shetRec.id; 
                                }
                        

                            }
                            n++;
                        }
                        m++;
                    }
                for(buildertek__Project_Takeoff_Lines__c sheetrec : takeofflines){ 
                    integer k = 0;
                    for(buildertek__Select_Sheet__c sheetrec1 : productlist){
                        if(sheetrec.buildertek__TO_SUMMARY_VALUE__c == sheetrec1.buildertek__Sum_Value__c){
                            if(sheetrec.buildertek__Product_Type__r.Name == sheetrec1.buildertek__Takeoff_Line__r.buildertek__Product_Type__r.Name ){
                                if(!duplicatebuildcheck1 .contains(sheetrec1.id)){
                                    if(sheetrec1.buildertek__QunUpdate__c == false){
                                        if(sheetrec1.buildertek__Takeoff_Line__r.buildertek__Product_Size__c == 'Jumbo'){
                                            if(sheetrec.buildertek__TL_QUANTITY_2__c != 0){
                                                if(k == 0){
                                                    sheetrec1.buildertek__Quantity__c = sheetrec.buildertek__TL_QUANTITY_2__c;
                                                    k++;
                                                }else{
                                                    sheetrec1.buildertek__Quantity__c = 0;  
                                                }
                                                sheetrec1.buildertek__QunUpdate__c = true;
                                            }
                                            buildrefproductlist5.add(sheetrec1);
                                            
                                        }else{
                                            if(sheetrec.buildertek__Quantity__c != 0){
                                                if(k == 0){
                                                    sheetrec1.buildertek__Quantity__c = sheetrec.buildertek__Quantity__c;
                                                    k++;
                                                }else{
                                                    sheetrec1.buildertek__Quantity__c = 0;  
                                                }
                                            }
                                            sheetrec1.buildertek__QunUpdate__c = true;
                                            buildrefproductlist5.add(sheetrec1);
                                        }
                                    }
                                }
                                buildrefproductlist3.add(sheetrec1);
                                duplicatebuildcheck1 += sheetrec1.id; 
                            }
                        }
                    }
                    }
                    if(buildrefproductlist5.size() > 0){
                        update buildrefproductlist5;
                    }
                }else {
                    notselectedbomLinesId1 = true;
                }
                list<Id> splashsheetIds = new list<Id>();
                for(buildertek__Select_Sheet__c selesheRec : buildrefproductlist5){
                    splashsheetIds.add(selesheRec.Id);
                }
                list<buildertek__Select_Sheet__c> buildrefproductlist6 = new list<buildertek__Select_Sheet__c>();
                list<buildertek__Select_Sheet__c> splashbomLines = [select Id, Name,buildertek__Takeoff_Line__c,buildertek__Takeoff_Line__r.Name,buildertek__Takeoff_Line__r.buildertek__Project_Takeoff__c,buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c,
                                                        buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c,buildertek__Takeoff_Line__r.buildertek__Build_Phase__c,
                                                        buildertek__Takeoff_Line__r.buildertek__Product_Type__c,buildertek__Takeoff_Line__r.buildertek__Product_Type__r.Name,
                                                        buildertek__Takeoff_Line__r.buildertek__Product_Size__c,buildertek__QunUpdate__c,buildertek__Selection_Sheet_Takeoff__c,
                                                        buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c,buildertek__Takeoff_Line__r.buildertek__Base_Location__c,
                                                        buildertek__Takeoff_Line__r.buildertek__TO_SUMMARY_VALUE__c,buildertek__Takeoff_Line__r.buildertek__StockKeepingUnit__c,
                                                        buildertek__Takeoff_Line__r.buildertek__Location__c,buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c,buildertek__Quantity__c,
                                                        buildertek__Takeoff_Line__r.buildertek__TO_LOCATION_DETAIL_REF__c,buildertek__Sum_Value__c,buildertek__Takeoff_Line__r.buildertek__Quantity__c, buildertek__Slab_SQF__c,
                                                        buildertek__Product__c,buildertek__Product__r.StockKeepingUnit,buildertek__Product__r.ProductCode
                                                        from buildertek__Select_Sheet__c  where Id NOT IN: splashsheetIds AND buildertek__Selection_Sheet_Takeoff__c =: prodIds AND buildertek__Takeoff_Line__r.buildertek__Product_Type__r.Name = 'Splash'];    
                map<string,list<buildertek__Select_Sheet__c>> productskuMap2 = new map<string,list<buildertek__Select_Sheet__c>>(); 
                for(buildertek__Select_Sheet__c splashbomlinerec : splashbomLines){
                    if(productskuMap2.get(splashbomlinerec.buildertek__Product__r.ProductCode) != null){
                        List<buildertek__Select_Sheet__c> spalshbomLinesList = productskuMap2.get(splashbomlinerec.buildertek__Product__r.ProductCode);
                        spalshbomLinesList.add(splashbomlinerec);
                        productskuMap2.put(splashbomlinerec.buildertek__Product__r.ProductCode,spalshbomLinesList);
                    }
                    else if(productskuMap2.get(splashbomlinerec.buildertek__Product__r.StockKeepingUnit) != null){
                        List<buildertek__Select_Sheet__c> spalshbomLinesList = productskuMap2.get(splashbomlinerec.buildertek__Product__r.StockKeepingUnit);
                        spalshbomLinesList.add(splashbomlinerec);
                        productskuMap2.put(splashbomlinerec.buildertek__Product__r.StockKeepingUnit,spalshbomLinesList);
                    }else{
                        List<buildertek__Select_Sheet__c> spalshbomLinesList =  new List<buildertek__Select_Sheet__c>();
                        spalshbomLinesList.add(splashbomlinerec);
                        //productskuMap2.put(splashbomlinerec.buildertek__Product__r.StockKeepingUnit,spalshbomLinesList);
                        if(splashbomlinerec.buildertek__Product__r.ProductCode != null)
                        {
                            productskuMap2.put(splashbomlinerec.buildertek__Product__r.ProductCode,spalshbomLinesList);
                        }
                        else 
                        {
                            productskuMap2.put(splashbomlinerec.buildertek__Product__r.StockKeepingUnit,spalshbomLinesList);
                        }
                    }
                    
                }
                system.debug('productskuMap2 -->'+productskuMap2.keySet());
                system.debug('productskuMap -->'+productskuMap2.keySet().size());
                Boolean notselectedbomLinesId2;
                list<buildertek__Select_Sheet__c> splashproductlist = new list<buildertek__Select_Sheet__c>();
                if(productskuMap2.keySet().size() == 1){
                    notselectedbomLinesId2 = false;
                    integer p = 0;
                    System.debug('**    splashbomLines:589  ------------------->: ' + JSON.serialize(splashbomLines));

                    for(buildertek__Select_Sheet__c splashshetRec : splashbomLines){
                        integer q = 0;
                        for(buildertek__Select_Sheet__c splashshetRec1 : splashbomLines){
                            if(p != q){
                                System.debug('**    splashshetRec:794  ------------------->: ' + JSON.serialize(splashshetRec));
                                System.debug('**    splashshetRec1:795  ------------------->: ' + JSON.serialize(splashshetRec1));
                        if(splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                splashshetRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                && splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c
                                && splashshetRec.buildertek__Takeoff_Line__r.buildertek__Base_Location__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__Base_Location__c
                                && splashshetRec.buildertek__Takeoff_Line__r.buildertek__Location__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__Location__c
                                && splashshetRec.buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c
                                && splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_LOCATION_DETAIL_REF__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_LOCATION_DETAIL_REF__c){
                                    if(!duplicatecheck.contains(splashshetRec.id)){

                                        if(splashshetRec.buildertek__Product__r.ProductCode != null)
                                        {
                                            String producsku = splashshetRec.buildertek__Product__r.ProductCode;
                                            if(producsku.length() >= 6){
                                            String xyz = splashshetRec.buildertek__Product__r.ProductCode != null ? splashshetRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                            if(xyz == '0'){
                                                splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                            }else if(xyz == '1'){
                                                splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                            } 
                                            }
                                        splashshetRec.buildertek__Sum_Value__c ='Location Detail Reference 1';
                                        splashproductlist.add(splashshetRec);
                                        }
                                        else if(splashshetRec.buildertek__Product__r.StockKeepingUnit != null)
                                        {
                                            String producsku = splashshetRec.buildertek__Product__r.StockKeepingUnit;
                                            if(producsku.length() >= 6){
                                            String xyz = splashshetRec.buildertek__Product__r.StockKeepingUnit != null ? splashshetRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                            if(xyz == '0'){
                                                splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                            }else if(xyz == '1'){
                                                splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                            } 
                                            }
                                        splashshetRec.buildertek__Sum_Value__c ='Location Detail Reference 1';
                                        splashproductlist.add(splashshetRec);
                                        }
                                    }
                                    duplicatecheck += splashshetRec.id;
                                }else if(splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                        && splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c
                                        && splashshetRec.buildertek__Takeoff_Line__r.buildertek__Base_Location__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__Base_Location__c
                                        && splashshetRec.buildertek__Takeoff_Line__r.buildertek__Location__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__Location__c
                                        && splashshetRec.buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c
                                        ){
                                            system.debug('%%%%%%%%%%%%%%%%%'+splashshetRec.id);
                                            if(!duplicatecheck.contains(splashshetRec.id)){

                                                if(splashshetRec.buildertek__Product__r.ProductCode != null)
                                                {
                                                    String producsku = splashshetRec.buildertek__Product__r.ProductCode;
                                                    if(producsku.length() >= 6){
                                                    String xyz = splashshetRec.buildertek__Product__r.ProductCode != null ? splashshetRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                splashshetRec.buildertek__Sum_Value__c ='Location Detailed Area';
                                                splashproductlist.add(splashshetRec);
                                                }
                                                else if(splashshetRec.buildertek__Product__r.StockKeepingUnit != null)
                                                {
                                                    String producsku = splashshetRec.buildertek__Product__r.StockKeepingUnit;
                                                    if(producsku.length() >= 6){
                                                    String xyz = splashshetRec.buildertek__Product__r.StockKeepingUnit != null ? splashshetRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                splashshetRec.buildertek__Sum_Value__c ='Location Detailed Area';
                                                splashproductlist.add(splashshetRec);
                                                }
                                                
                                            }
                                            duplicatecheck += splashshetRec.id; 
                                }else if(splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                        && splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c
                                        && splashshetRec.buildertek__Takeoff_Line__r.buildertek__Base_Location__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__Base_Location__c
                                        && splashshetRec.buildertek__Takeoff_Line__r.buildertek__Location__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__Location__c
                                        ){
                                            system.debug('%%%%%%%%%%%%%%%%%');
                                            if(!duplicatecheck.contains(splashshetRec.id)){

                                                if(splashshetRec.buildertek__Product__r.ProductCode != null)
                                                {
                                                    String producsku = splashshetRec.buildertek__Product__r.ProductCode;
                                                    if(producsku.length() >= 6){
                                                    String xyz = splashshetRec.buildertek__Product__r.ProductCode != null ? splashshetRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                splashshetRec.buildertek__Sum_Value__c ='Location';
                                                splashproductlist.add(splashshetRec);
                                                }
                                                else if(splashshetRec.buildertek__Product__r.StockKeepingUnit != null)
                                                {
                                                    String producsku = splashshetRec.buildertek__Product__r.StockKeepingUnit;
                                                    if(producsku.length() >= 6){
                                                    String xyz = splashshetRec.buildertek__Product__r.StockKeepingUnit != null ? splashshetRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                splashshetRec.buildertek__Sum_Value__c ='Location';
                                                splashproductlist.add(splashshetRec);
                                                }
                                            }
                                            duplicatecheck += splashshetRec.id; 
                                } else if(splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                        && splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c
                                        && splashshetRec.buildertek__Takeoff_Line__r.buildertek__Base_Location__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__Base_Location__c
                                        ){
                                            system.debug('%%%%%%%%%%%%%%%%%');
                                            if(!duplicatecheck.contains(splashshetRec.id)){
                                                if(splashshetRec.buildertek__Product__r.ProductCode != null)
                                                {
                                                    String producsku = splashshetRec.buildertek__Product__r.ProductCode;
                                                    if(producsku.length() >= 6){
                                                    String xyz = splashshetRec.buildertek__Product__r.ProductCode != null ? splashshetRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                splashshetRec.buildertek__Sum_Value__c ='Location';
                                                splashproductlist.add(splashshetRec);
                                                }
                                                else if(splashshetRec.buildertek__Product__r.StockKeepingUnit != null)
                                                {
                                                    String producsku = splashshetRec.buildertek__Product__r.StockKeepingUnit;
                                                    if(producsku.length() >= 6){
                                                    String xyz = splashshetRec.buildertek__Product__r.StockKeepingUnit != null ? splashshetRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                splashshetRec.buildertek__Sum_Value__c ='Base Location';
                                                splashproductlist.add(splashshetRec);
                                                }
                                            }
                                            duplicatecheck += splashshetRec.id; 
                                }
                                else if(splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                        && splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c
                                        ){
                                            system.debug('%%%%%%%%%%%%%%%%%');
                                            if(!duplicatecheck.contains(splashshetRec.id)){
                                                if(splashshetRec.buildertek__Product__r.ProductCode != null)
                                                {
                                                    String producsku = splashshetRec.buildertek__Product__r.ProductCode;
                                                    if(producsku.length() >= 6){
                                                    String xyz = splashshetRec.buildertek__Product__r.ProductCode != null ? splashshetRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                splashshetRec.buildertek__Sum_Value__c ='Location';
                                                splashproductlist.add(splashshetRec);
                                                }
                                                else if(splashshetRec.buildertek__Product__r.StockKeepingUnit != null)
                                                {
                                                    String producsku = splashshetRec.buildertek__Product__r.StockKeepingUnit;
                                                    if(producsku.length() >= 6){
                                                    String xyz = splashshetRec.buildertek__Product__r.StockKeepingUnit != null ? splashshetRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                splashshetRec.buildertek__Sum_Value__c ='Building Ref 1';
                                                splashproductlist.add(splashshetRec);
                                                }
                                            }
                                            duplicatecheck += splashshetRec.id; 
                                }
                                else if(splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == splashshetRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                        ){
                                            if(!duplicatecheck.contains(splashshetRec.id)){
                                                if(splashshetRec.buildertek__Product__r.ProductCode != null)
                                                {
                                                    String producsku = splashshetRec.buildertek__Product__r.ProductCode;
                                                    if(producsku.length() >= 6){
                                                    String xyz = splashshetRec.buildertek__Product__r.ProductCode != null ? splashshetRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                splashshetRec.buildertek__Sum_Value__c ='Location';
                                                splashproductlist.add(splashshetRec);
                                                }
                                                else if(splashshetRec.buildertek__Product__r.StockKeepingUnit != null)
                                                {
                                                    String producsku = splashshetRec.buildertek__Product__r.StockKeepingUnit;
                                                    if(producsku.length() >= 6){
                                                    String xyz = splashshetRec.buildertek__Product__r.StockKeepingUnit != null ? splashshetRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                    if(xyz == '0'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                    }else if(xyz == '1'){
                                                        splashshetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                    } 
                                                    }
                                                splashshetRec.buildertek__Sum_Value__c ='Project';
                                                splashproductlist.add(splashshetRec);
                                                }
                                            }
                                            duplicatecheck += splashshetRec.id; 
                                }
                        

                            }
                        q++;
                        }
                        p++;
                    }
                    
                    for(buildertek__Project_Takeoff_Lines__c splashsheetrec : takeofflines){
                        integer r = 0;
                    for(buildertek__Select_Sheet__c splashsheetrec1 : splashproductlist){
                        if(splashsheetrec.buildertek__TO_SUMMARY_VALUE__c == splashsheetrec1.buildertek__Sum_Value__c){
                            if(splashsheetrec.buildertek__Product_Type__r.Name == splashsheetrec1.buildertek__Takeoff_Line__r.buildertek__Product_Type__r.Name ){
                                if(!duplicatebuildcheck1 .contains(splashsheetrec1.id)){
                                    if(splashsheetrec1.buildertek__QunUpdate__c == false){
                                        if(splashsheetrec1.buildertek__Takeoff_Line__r.buildertek__Product_Size__c == 'Jumbo'){
                                            if(splashsheetrec.buildertek__TL_QUANTITY_2__c != 0){
                                                if(r == 0){
                                                    splashsheetrec1.buildertek__Quantity__c = splashsheetrec.buildertek__TL_QUANTITY_2__c;
                                                    r++;
                                                }else{
                                                    splashsheetrec1.buildertek__Quantity__c = 0;  
                                                }
                                                splashsheetrec1.buildertek__QunUpdate__c = true;
                                            }
                                            buildrefproductlist6.add(splashsheetrec1);
                                            
                                        }else{
                                            if(splashsheetrec.buildertek__Quantity__c != 0){
                                                if(r == 0){
                                                    splashsheetrec1.buildertek__Quantity__c = splashsheetrec.buildertek__Quantity__c;
                                                    r++;
                                                }else{
                                                    splashsheetrec1.buildertek__Quantity__c = 0;  
                                                }
                                            }
                                            splashsheetrec1.buildertek__QunUpdate__c = true;
                                            buildrefproductlist6.add(splashsheetrec1);
                                        }
                                    }
                                }
                                buildrefproductlist3.add(splashsheetrec1);
                                duplicatebuildcheck1 += splashsheetrec1.id; 
                            }
                        }
                    }
                    }
                    if(buildrefproductlist6.size() > 0){
                        update buildrefproductlist6;
                    }
                }else{}
            list<id> noskulist = new list<id>();
            for(buildertek__Select_Sheet__c ssRec : buildrefproductlist6){
                splashsheetIds.add(ssRec.id); 
            }
            list<buildertek__Select_Sheet__c> bomLines1 = [
                select
                    Id, Name,buildertek__Takeoff_Line__c,buildertek__Takeoff_Line__r.Name,buildertek__Takeoff_Line__r.buildertek__Project_Takeoff__c,buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c,
                    buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c,buildertek__Takeoff_Line__r.buildertek__Build_Phase__c,
                    buildertek__Takeoff_Line__r.buildertek__Product_Type__c,buildertek__Takeoff_Line__r.buildertek__Product_Type__r.Name,
                    buildertek__Takeoff_Line__r.buildertek__Product_Size__c,buildertek__QunUpdate__c,buildertek__Selection_Sheet_Takeoff__c,
                    buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c,buildertek__Takeoff_Line__r.buildertek__Base_Location__c,
                    buildertek__Takeoff_Line__r.buildertek__TO_SUMMARY_VALUE__c,buildertek__Takeoff_Line__r.buildertek__StockKeepingUnit__c,
                    buildertek__Takeoff_Line__r.buildertek__Location__c,buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c,buildertek__Quantity__c,
                    buildertek__Takeoff_Line__r.buildertek__TO_LOCATION_DETAIL_REF__c,buildertek__Takeoff_Line__r.buildertek__Quantity__c, buildertek__Slab_SQF__c
                    ,buildertek__Takeoff_Line__r.buildertek__TL_QUANTITY_2__c,buildertek__Product__c,buildertek__Product__r.StockKeepingUnit,buildertek__Product__r.ProductCode
                from
                    buildertek__Select_Sheet__c
                where
                    Id NOT IN: splashsheetIds
                    AND
                    buildertek__Selection_Sheet_Takeoff__c =:prodIds
                ];
            integer i = 0;
            for(buildertek__Select_Sheet__c bomRec : bomLines1){
                integer j = 0;
                for(buildertek__Select_Sheet__c bomRec1 : bomLines1){
                    system.debug('^^^^'+bomRec.buildertek__Takeoff_Line__r.Name); 
                    system.debug('####'+bomRec.Id);
                      if(i != j){
                            system.debug('%%%'+bomRec.buildertek__Takeoff_Line__r.Name);
                            if(bomRec.buildertek__Takeoff_Line__r.buildertek__TO_LOCATION_DETAIL_REF__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_LOCATION_DETAIL_REF__c  && 
                               (bomRec.buildertek__Product__r.StockKeepingUnit == bomRec1.buildertek__Product__r.StockKeepingUnit || bomRec.buildertek__Product__r.ProductCode == bomRec1.buildertek__Product__r.ProductCode)){
                                   if(bomRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                      bomRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                      bomRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                      && bomRec.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c
                                      && bomRec.buildertek__Takeoff_Line__r.buildertek__Base_Location__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__Base_Location__c
                                      && bomRec.buildertek__Takeoff_Line__r.buildertek__Location__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__Location__c
                                      && bomRec.buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c
                                      && bomRec.buildertek__Takeoff_Line__r.buildertek__TO_LOCATION_DETAIL_REF__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_LOCATION_DETAIL_REF__c){

                                        if(!schemeduplicatecheck.contains(bomRec.id)){
                                            if(bomRec.buildertek__Product__r.ProductCode != null)
                                            {
                                              String producsku = bomRec.buildertek__Product__r.ProductCode;
                                              if(producsku.length() >= 6){
                                                String xyz = bomRec.buildertek__Product__r.ProductCode != null ? bomRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                if(xyz == '0'){
                                                    bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                }else if(xyz == '1'){
                                                    bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                } 
                                              }
                                                bomRec.buildertek__Sum_Value__c ='Location Detail Reference 1';
                                                system.debug('&&'+bomRec.buildertek__Sum_Value__c );
                                                schemeproductlist.add(bomRec);
                                            }
                                            else if(bomRec.buildertek__Product__r.StockKeepingUnit != null)
                                            {
                                                String producsku = bomRec.buildertek__Product__r.StockKeepingUnit;
                                                if(producsku.length() >= 6){
                                                  String xyz = bomRec.buildertek__Product__r.StockKeepingUnit != null ? bomRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                  if(xyz == '0'){
                                                      bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                  }else if(xyz == '1'){
                                                      bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                  } 
                                                }
                                              bomRec.buildertek__Sum_Value__c ='Location Detail Reference 1';
                                              system.debug('&&'+bomRec.buildertek__Sum_Value__c );
                                              schemeproductlist.add(bomRec);
                                            }
                                          }
                                          schemeduplicatecheck += bomRec.id;
                                      }
                                      else if(bomRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                               bomRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                               bomRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                               && bomRec.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c
                                               && bomRec.buildertek__Takeoff_Line__r.buildertek__Base_Location__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__Base_Location__c
                                               && bomRec.buildertek__Takeoff_Line__r.buildertek__Location__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__Location__c
                                               && bomRec.buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c
                                              ){
                                                  
                                                  if(!schemeduplicatecheck.contains(bomRec.id)){
                                                    if(bomRec.buildertek__Product__r.ProductCode != null)
                                                    {
                                                        String producsku = bomRec.buildertek__Product__r.ProductCode;
                                                        if(producsku.length() >= 6){
                                                          String xyz = bomRec.buildertek__Product__r.ProductCode != null ? bomRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                          if(xyz == '0'){
                                                              bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                          }else if(xyz == '1'){
                                                              bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                          } 
                                                        }
                                                      system.debug('&&'+bomRec.buildertek__Sum_Value__c );
                                                      bomRec.buildertek__Sum_Value__c ='Location Detailed Area';
                                                      schemeproductlist.add(bomRec);
                                                    }
                                                    else if(bomRec.buildertek__Product__r.StockKeepingUnit != null)
                                                    {
                                                        String producsku = bomRec.buildertek__Product__r.StockKeepingUnit;
                                                        if(producsku.length() >= 6){
                                                          String xyz = bomRec.buildertek__Product__r.StockKeepingUnit != null ? bomRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                          if(xyz == '0'){
                                                              bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                          }else if(xyz == '1'){
                                                              bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                          } 
                                                        }
                                                      system.debug('&&'+bomRec.buildertek__Sum_Value__c );
                                                      bomRec.buildertek__Sum_Value__c ='Location Detailed Area';
                                                      schemeproductlist.add(bomRec);
                                                    }
                                                  }
                                                  schemeduplicatecheck += bomRec.id; 
                                              }else if(bomRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                                       bomRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                                       bomRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                                       && bomRec.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c
                                                       && bomRec.buildertek__Takeoff_Line__r.buildertek__Base_Location__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__Base_Location__c
                                                       && bomRec.buildertek__Takeoff_Line__r.buildertek__Location__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__Location__c
                                                      ){
                                                          if(!schemeduplicatecheck.contains(bomRec.id)){

                                                            if(bomRec.buildertek__Product__r.ProductCode != null)
                                                            {
                                                                String producsku = bomRec.buildertek__Product__r.ProductCode;
                                                                if(producsku.length() >= 6){
                                                                  String xyz = bomRec.buildertek__Product__r.ProductCode != null ? bomRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                                  if(xyz == '0'){
                                                                      bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                                  }else if(xyz == '1'){
                                                                      bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                                  } 
                                                                }
                                                              bomRec.buildertek__Sum_Value__c ='Location';
                                                              schemeproductlist.add(bomRec);
                                                            }
                                                            else if(bomRec.buildertek__Product__r.StockKeepingUnit != null)
                                                            {
                                                                String producsku = bomRec.buildertek__Product__r.StockKeepingUnit;
                                                                if(producsku.length() >= 6){
                                                                  String xyz = bomRec.buildertek__Product__r.StockKeepingUnit != null ? bomRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                                  if(xyz == '0'){
                                                                      bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                                  }else if(xyz == '1'){
                                                                      bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                                  } 
                                                                }
                                                              bomRec.buildertek__Sum_Value__c ='Location';
                                                              schemeproductlist.add(bomRec);
                                                            }
                                                          }
                                                          schemeduplicatecheck += bomRec.id; 
                                                      } else if( bomRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                                                bomRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                                                bomRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                                                && bomRec.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c
                                                                && bomRec.buildertek__Takeoff_Line__r.buildertek__Base_Location__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__Base_Location__c
                                                               ){
                                                                   if(!schemeduplicatecheck.contains(bomRec.id)){
                                                                    if(bomRec.buildertek__Product__r.ProductCode != null)
                                                                    {
                                                                        String producsku = bomRec.buildertek__Product__r.ProductCode;
                                                                       if(producsku.length() >= 6){
                                                                           String xyz = bomRec.buildertek__Product__r.ProductCode != null ? bomRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                                           if(xyz == '0'){
                                                                               bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                                           }else if(xyz == '1'){
                                                                               bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                                           } 
                                                                       }
                                                                       bomRec.buildertek__Sum_Value__c ='Base Location';
                                                                       schemeproductlist.add(bomRec);
                                                                    }   
                                                                    else if(bomRec.buildertek__Product__r.StockKeepingUnit != null)
                                                                    {
                                                                        String producsku = bomRec.buildertek__Product__r.StockKeepingUnit;
                                                                       if(producsku.length() >= 6){
                                                                           String xyz = bomRec.buildertek__Product__r.StockKeepingUnit != null ? bomRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                                           if(xyz == '0'){
                                                                               bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                                           }else if(xyz == '1'){
                                                                               bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                                           } 
                                                                       }
                                                                       bomRec.buildertek__Sum_Value__c ='Base Location';
                                                                       schemeproductlist.add(bomRec);
                                                                    }
                                                                   }
                                                                   schemeduplicatecheck += bomRec.id; 
                                                               }else if(bomRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                                                        bomRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                                                        bomRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                                                        && bomRec.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c
                                                                       ){
                                                                           if(!schemeduplicatecheck.contains(bomRec.id)){
                                                                            if(bomRec.buildertek__Product__r.ProductCode != null)
                                                                            {
                                                                                String producsku = bomRec.buildertek__Product__r.ProductCode;
                                                                               if(producsku.length() >= 6){
                                                                                   String xyz = bomRec.buildertek__Product__r.ProductCode != null ? bomRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                                                   if(xyz == '0'){
                                                                                       bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                                                   }else if(xyz == '1'){
                                                                                       bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                                                   } 
                                                                               }
                                                                               bomRec.buildertek__Sum_Value__c ='Building Ref 1';
                                                                               schemeproductlist.add(bomRec);
                                                                            }
                                                                            else if(bomRec.buildertek__Product__r.StockKeepingUnit != null)
                                                                            {
                                                                                String producsku = bomRec.buildertek__Product__r.StockKeepingUnit;
                                                                               if(producsku.length() >= 6){
                                                                                   String xyz = bomRec.buildertek__Product__r.StockKeepingUnit != null ? bomRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                                                   if(xyz == '0'){
                                                                                       bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                                                   }else if(xyz == '1'){
                                                                                       bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                                                   } 
                                                                               }
                                                                               bomRec.buildertek__Sum_Value__c ='Building Ref 1';
                                                                               schemeproductlist.add(bomRec);
                                                                            }
                                                                           }
                                                                           schemeduplicatecheck += bomRec.id; 
                                                                       }else if( bomRec.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c && 
                                                                                bomRec.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c &&
                                                                                bomRec.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c == bomRec1.buildertek__Takeoff_Line__r.buildertek__Build_Phase__c
                                                                               ){
                                                                                   if(!schemeduplicatecheck.contains(bomRec.id)){
                                                                                    if(bomRec.buildertek__Product__r.ProductCode != null)
                                                                                    {
                                                                                        String producsku = bomRec.buildertek__Product__r.ProductCode;
                                                                                        if(producsku.length() >= 6){
                                                                                           String xyz = bomRec.buildertek__Product__r.ProductCode != null ? bomRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                                                                                           if(xyz == '0'){
                                                                                               bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                                                           }else if(xyz == '1'){
                                                                                               bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                                                           } 
                                                                                        }
                                                                                       bomRec.buildertek__Sum_Value__c ='Project';
                                                                                       schemeproductlist.add(bomRec);
                                                                                    }
                                                                                    else if(bomRec.buildertek__Product__r.StockKeepingUnit != null)
                                                                                    {
                                                                                        String producsku = bomRec.buildertek__Product__r.StockKeepingUnit;
                                                                                        if(producsku.length() >= 6){
                                                                                           String xyz = bomRec.buildertek__Product__r.StockKeepingUnit != null ? bomRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                                                                                           if(xyz == '0'){
                                                                                               bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                                                                                           }else if(xyz == '1'){
                                                                                               bomRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                                                                                           } 
                                                                                        }
                                                                                       bomRec.buildertek__Sum_Value__c ='Project';
                                                                                       schemeproductlist.add(bomRec);
                                                                                    }
                                                                                   }
                                                                                   schemeduplicatecheck += bomRec.id; 
                                                                               }
                               }
                        }
                    
                    j++;
                }
   
                i++;
            }         
         for(buildertek__Project_Takeoff_Lines__c sheetrec : takeofflines){
            integer k = 0;
            for(buildertek__Select_Sheet__c sheetrec1: schemeproductlist){
                if(sheetrec.buildertek__TO_LOCATION_DETAIL_REF__c == sheetrec1.buildertek__Takeoff_Line__r.buildertek__TO_LOCATION_DETAIL_REF__c
                  && sheetrec.buildertek__TO_SUMMARY_VALUE__c == sheetrec1.buildertek__Sum_Value__c){
                     system.debug('**'+sheetrec.buildertek__TO_LOCATION_DETAIL_REF__c);
                        if(!duplicatebuildcheck1 .contains(sheetrec1.id)){
                            if(sheetrec1.buildertek__QunUpdate__c == false){
                                if(sheetrec1.buildertek__Takeoff_Line__r.buildertek__Product_Size__c == 'Jumbo'){
                                    if(sheetrec.buildertek__TL_QUANTITY_2__c != 0){
                                        if(k == 0){
                                            sheetrec1.buildertek__Quantity__c = sheetrec.buildertek__TL_QUANTITY_2__c;
                                            k++;
                                        }else{
                                            sheetrec1.buildertek__Quantity__c = 0;  
                                        }
                                        sheetrec1.buildertek__QunUpdate__c = true;
                                    }
                                    buildrefproductlist4.add(sheetrec1);
                                    
                                }else{
                                    if(sheetrec.buildertek__Quantity__c != 0){
                                        if(k == 0){
                                            sheetrec1.buildertek__Quantity__c = sheetrec.buildertek__Quantity__c;
                                            k++;
                                        }else{
                                            sheetrec1.buildertek__Quantity__c = 0;  
                                        }
                                    }
                                    sheetrec1.buildertek__QunUpdate__c = true;
                                    buildrefproductlist4.add(sheetrec1);
                                }
                            }
                        }
                        buildrefproductlist3.add(sheetrec1);
                        duplicatebuildcheck1 += sheetrec1.id; 
                    }
            }
        }
            if(buildrefproductlist4.size() > 0){
            system.debug('buildrefproductlist'+buildrefproductlist4);
            update buildrefproductlist4;
        }
        //decimal quan = 0;
         decimal quan = 0;
         list<id> noskulist1 = new list<id>();
          // system.debug('ssRec1.id'+schemeproductlist.size()); 
           // system.debug('ssRec1.id'+schemeproductlist); 
        for(buildertek__Select_Sheet__c ssRec1 : buildrefproductlist4){
            splashsheetIds.add(ssRec1.id); 
           // system.debug('ssRec1.id'+ssRec1.id);
        }
        system.debug('noskulist'+noskulist);
        list<buildertek__Select_Sheet__c> bomLines2 = [select Id, Name,buildertek__Takeoff_Line__c,buildertek__Takeoff_Line__r.Name,buildertek__Takeoff_Line__r.buildertek__Project_Takeoff__c,buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c,
                                                      buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c,buildertek__Takeoff_Line__r.buildertek__Build_Phase__c,
                                                      buildertek__Takeoff_Line__r.buildertek__Product_Type__c,buildertek__Takeoff_Line__r.buildertek__Product_Type__r.Name,
                                                      buildertek__Takeoff_Line__r.buildertek__Product_Size__c,buildertek__QunUpdate__c,buildertek__Selection_Sheet_Takeoff__c,
                                                      buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c,buildertek__Takeoff_Line__r.buildertek__Base_Location__c,
                                                      buildertek__Takeoff_Line__r.buildertek__TO_SUMMARY_VALUE__c,buildertek__Takeoff_Line__r.buildertek__StockKeepingUnit__c,
                                                      buildertek__Takeoff_Line__r.buildertek__Location__c,buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c,buildertek__Quantity__c,
                                                      buildertek__Takeoff_Line__r.buildertek__TO_LOCATION_DETAIL_REF__c,buildertek__Takeoff_Line__r.buildertek__Quantity__c, buildertek__Slab_SQF__c
                                                      ,buildertek__Takeoff_Line__r.buildertek__TL_QUANTITY_2__c,buildertek__Product__c,buildertek__Product__r.StockKeepingUnit,buildertek__Product__r.ProductCode
                                                      from buildertek__Select_Sheet__c  where Id NOT IN: noskulist AND buildertek__Selection_Sheet_Takeoff__c =:prodIds];
        system.debug('bomLines2'+bomLines2.size()); 
            system.debug('bomLines2'+bomLines2); 
        for(buildertek__Select_Sheet__c sheetRec : bomLines2){
            integer k = 0;
             if(sheetRec.buildertek__QunUpdate__c == false){
                if(sheetRec.buildertek__Product__r.ProductCode != null)
                {
                    String producsku = sheetRec.buildertek__Product__r.ProductCode;
                           if(producsku.length() >= 6){
                              String xyz = sheetRec.buildertek__Product__r.ProductCode != null ? sheetRec.buildertek__Product__r.ProductCode.substring(5,6) : null;
                               if(xyz == '0'){
                                   sheetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                               }else if(xyz == '1'){
                                   sheetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                               } 
                           }
                }
                else if(sheetRec.buildertek__Product__r.StockKeepingUnit != null)
                {
                    String producsku = sheetRec.buildertek__Product__r.StockKeepingUnit;
                    if(producsku.length() >= 6){
                        String xyz = sheetRec.buildertek__Product__r.StockKeepingUnit != null ? sheetRec.buildertek__Product__r.StockKeepingUnit.substring(5,6) : null;
                            if(xyz == '0'){
                                sheetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Standard'; 
                            }else if(xyz == '1'){
                                sheetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c = 'Jumbo';  
                            } 
                    }
                }
                                if(sheetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c == 'Jumbo'){
                                    system.debug('&&&'+sheetRec.buildertek__Takeoff_Line__r.buildertek__Product_Size__c);
                                    if(sheetRec.buildertek__Takeoff_Line__r.buildertek__TL_QUANTITY_2__c != 0){
                                        if(k == 0){
                                            sheetRec.buildertek__Quantity__c = sheetRec.buildertek__Takeoff_Line__r.buildertek__TL_QUANTITY_2__c;
                                            k++;
                                        }else{
                                            sheetRec.buildertek__Quantity__c = 0;  
                                        }
                                        sheetRec.buildertek__QunUpdate__c = true;
                                    }
                                    buildrefproductlist2.add(sheetRec);
                                    
                                }else{
                                    system.debug('^^^');
                                    if(sheetrec.buildertek__Quantity__c != 0){
                                        if(k == 0){
                                            sheetrec.buildertek__Quantity__c = sheetRec.buildertek__Takeoff_Line__r.buildertek__Quantity__c;
                                            k++;
                                        }else{
                                            sheetrec.buildertek__Quantity__c = 0;  
                                        }
                                    }
                                    sheetrec.buildertek__QunUpdate__c = true;
                                    buildrefproductlist2.add(sheetrec);
                                }
                            }
            
            buildrefproductlist3.add(sheetrec);
        }
         if(buildrefproductlist2.size() > 0){
            system.debug('buildrefproductlist'+buildrefproductlist2);
            update buildrefproductlist2;
        }
        list<buildertek__Project_Takeoff_Lines__c> buildrefproductlist1 = new list<buildertek__Project_Takeoff_Lines__c>();
            system.debug('buildrefproductlist.size'+buildrefproductlist2.size());
            }
       list<buildertek__Select_Sheet__c> bomLines3 = [select Id, Name,buildertek__Takeoff_Line__c,buildertek__Takeoff_Line__r.Name,buildertek__Takeoff_Line__r.buildertek__Project_Takeoff__c,buildertek__Takeoff_Line__r.buildertek__TO_LAST_EST_DATE__c,
                                                      buildertek__Takeoff_Line__r.buildertek__TO_VERSION__c,buildertek__Takeoff_Line__r.buildertek__Build_Phase__c,
                                                      buildertek__Takeoff_Line__r.buildertek__Product_Type__c,buildertek__Takeoff_Line__r.buildertek__Product_Type__r.Name,
                                                      buildertek__Takeoff_Line__r.buildertek__Product_Size__c,buildertek__QunUpdate__c,buildertek__Selection_Sheet_Takeoff__c,
                                                      buildertek__Takeoff_Line__r.buildertek__TO_BUILD_REF1__c,buildertek__Takeoff_Line__r.buildertek__Base_Location__c,
                                                      buildertek__Takeoff_Line__r.buildertek__TO_SUMMARY_VALUE__c,buildertek__Takeoff_Line__r.buildertek__StockKeepingUnit__c,
                                                      buildertek__Takeoff_Line__r.buildertek__Location__c,buildertek__Takeoff_Line__r.buildertek__Location_Detailed_Area__c,buildertek__Quantity__c,
                                                      buildertek__Takeoff_Line__r.buildertek__TO_LOCATION_DETAIL_REF__c,buildertek__Takeoff_Line__r.buildertek__Quantity__c, buildertek__Slab_SQF__c
                                                      ,buildertek__Takeoff_Line__r.buildertek__TL_QUANTITY_2__c,buildertek__Product__c,buildertek__Product__r.StockKeepingUnit,buildertek__Product__r.ProductCode
                                                      from buildertek__Select_Sheet__c  where buildertek__Selection_Sheet_Takeoff__c =:prodIds ORDER BY buildertek__Takeoff_Line__r.Name];
        return bomLines3;
    }
    @AuraEnabled
    public static string getpricebook(string BudgetId){
        list<buildertek__budget__c> budget;
        if (Schema.sObjectType.buildertek__Budget__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Budget__c.fields.buildertek__Project__c.isAccessible() && Schema.sObjectType.buildertek__Project__c.fields.buildertek__Price_Book__c.isAccessible()){
            budget = [select id, buildertek__Project__r.buildertek__Price_Book__c
                      from buildertek__budget__c
                      where id = :BudgetId];
        }
        if (budget.size() > 0){
            return budget[0].buildertek__Project__r.buildertek__Price_Book__c;
        }
        return null;
    }
    
    
    @AuraEnabled
    //get Pricebook Values
    public static Map<String, String> getpricebooks(){
        Map<String, String> options = new Map<String, String>();
        list<pricebook2> PriceList;
        PriceList = [select Id, Name,buildertek__BT_Visible__c
                     from pricebook2
                     Where isActive = true AND buildertek__BT_Visible__c = true];
        
        for (pricebook2 p : PriceList){
            //Put Picklist Value & Label in Map
            options.put(p.name, p.Id);
        }
        return options;
    }
    
    @AuraEnabled
    public static string getBOMRec(String recordId){
        try{
            if (String.isNotBlank(recordId)){
                buildertek__Project_Selection_Sheet_Takeoff__c projectSelectionSheetTakeOffRec = [Select Id, Name, buildertek__Project__c, buildertek__Project__r.buildertek__Plan_Type__c
                                                                                                  FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                                                  WHERE Id = :recordId];
                return projectSelectionSheetTakeOffRec.Name;
            }
        } catch (Exception e){
            System.debug('Error Message::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    
    //Retrieve ProjectTakeOff
    @AuraEnabled
    public static ProjectSelectionSheetTakeOff getProjectSelectionSheetTakeOffRec(String recordId){
        try{
            if (String.isNotBlank(recordId)){
                ProjectSelectionSheetTakeOff projectSelectionSheetTakeOffRec = new ProjectSelectionSheetTakeOff();
                projectSelectionSheetTakeOffRec.projectSelectionSheetTakeOffRec = [Select Id, Name, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Project__r.buildertek__Project_Tiers__c, buildertek__Project__r.buildertek__Plan_Type__c,buildertek__Opportunity__r.Id,buildertek__Opportunity__r.Name,buildertek__Opportunity__r.Description
                                                                                   FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                                   WHERE Id = :recordId];
                return projectSelectionSheetTakeOffRec;
            }
        } catch (Exception e){
            System.debug('Error Message::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
        return null;
    }
    
    //Get All Products, TakeOffLines records and Selection Sheet TakeOff Lines
    @AuraEnabled
    public static ProductClass getAllProductsAndTakeOffLines(String recordId, Integer productPageNumber, Integer productPageSize, Integer pageNumber, Integer pageSize, Integer SSTLPageNumber, Integer SSTLPageSize,string selectPriceBook){
        // try{
        // return searchQueryResult2(recordId, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, '', '', '', '', '', '', '', '', '', '', '','');
        return searchQueryResult3(recordId, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize,'', '','',selectPriceBook);
        // } catch (Exception e){
        //    System.debug('Error Message::' + e.getMessage());
        //     System.debug('Error Line::' + e.getLineNumber());
        //       throw new AuraHandledException(e.getMessage());
        //  }
    }
    
    //Get All Selected Products, TakeOffLines records and Selection Sheet TakeOff Lines
    @AuraEnabled
    public static ProductClass getAllProductsAndSelectedTakeOffLines(String recordId, Integer productPageNumber, Integer productPageSize, Integer pageNumber, Integer pageSize, Integer SSTLPageNumber, Integer SSTLPageSize, String filteredTakeOffLines){
        //   try{
        ProductClass productClassWrapper = new ProductClass();
        //Base Query for Product2
        String query = '';
        String filter = '';
        
        Integer offset = (pageNumber - 1) * pageSize;//For SSTL
        Integer SSTLOffset = (SSTLPageNumber - 1) * SSTLPageSize;//For SSTL
        buildertek__Project_Selection_Sheet_Takeoff__c projectSelectionSheetTakeOff = [Select Id, Name, buildertek__Takeoff__c, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Project__r.buildertek__Project_Tiers__c, buildertek__Project__r.buildertek__Plan_Type__c
                                                                                       FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                                       WHERE Id = :recordId
                                                                                       LIMIT 1];
        system.debug('projectSelectionSheetTakeOff:::::' + projectSelectionSheetTakeOff.buildertek__Takeoff__c);
        string takeOffId = projectSelectionSheetTakeOff.buildertek__Takeoff__c;
        system.debug('takeOffId:::::' + takeOffId);
        List<Product2> productList = new List<Product2>();
        if(String.isNotBlank(filteredTakeOffLines))
        {
            productList = (List<Product2>)JSON.deserialize(filteredTakeOffLines, List<Product2>.class);
        }
        productClassWrapper.projectSelectionSheetTakeOffRec = projectSelectionSheetTakeOff;
        
        //Take Off Lines
        
        String jsonSerializeFields='';
        String jsonSerializeFields1='';
        buildertek__BOM_Settings__c settingsrec = new buildertek__BOM_Settings__c();
        list<buildertek__BOM_Settings__c>  settingsList = [Select id,Name, buildertek__BOM_Selected_Fields__c,
                                                           buildertek__BOM_Line_Selected_Fileds__c,
                                                           buildertek__Product_Selected_Fields__c,
                                                           buildertek__BOM_Line_Filter_Fields__c,
                                                           buildertek__Takeoff_Filter_Fields__c,
                                                           buildertek__Product_Filter_Fields__c
                                                           From buildertek__BOM_Settings__c 
                                                           limit 1];        
        String FieldsDefaultValues =    '[{"label":"Name","value":"Name"}]';
        
        
        if(settingsList.size()>0){
            
            settingsrec =  settingsList[0]; 
            if(settingsList[0].buildertek__BOM_Selected_Fields__c !=null){
                jsonSerializeFields = settingsList[0].buildertek__BOM_Selected_Fields__c;      
            } else{
                jsonSerializeFields = FieldsDefaultValues;
            }
            if(settingsList[0].buildertek__Takeoff_Filter_Fields__c !=null){
                jsonSerializeFields1 = settingsList[0].buildertek__Takeoff_Filter_Fields__c;      
            } else{
                jsonSerializeFields1 = FieldsDefaultValues;
            }
            
            
        }
        else{
            jsonSerializeFields =   FieldsDefaultValues;          
            jsonSerializeFields1 =   FieldsDefaultValues;          
        }
        
        InnSettings Inn = new InnSettings();        
        
        List<fieldWrap> FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict( jsonSerializeFields,List<fieldWrap>.class);
        Inn.TakeOffFieldSettings = FieldsSettings;
        
        String objectname='buildertek__Project_Takeoff_Lines__c';
        Map<String, Schema.SObjectType> schemaMapPTL = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchemaPTL = schemaMapPTL.get(objectname);
        Map<String, Schema.SObjectField> fieldMapPTL = leadSchemaPTL.getDescribe().fields.getMap();     
        
        list<buildertek__Project_Takeoff_Lines__c> recordsList = new list<buildertek__Project_Takeoff_Lines__c>();
        query = 'SELECT ';
        String fields= ' Id ';
        //'Id, Name, buildertek__Categories__r.Name, buildertek__Product_Type__r.Name, buildertek__Trade_Type__r.Name ';
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
                fields += ' , ' + fieldName;       
            }
        }
        system.debug(fields);
        
        //takeoff line filter fields
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
        if(fields.contains('buildertek__Trade_Type__c') == false){
            fields += ' , ' + 'buildertek__Trade_Type__c';
        }
        if(fields.contains('buildertek__Trade_Type__r.Name') == false){
            fields += ' , ' + 'buildertek__Trade_Type__r.Name';
        }
        if(fields.contains('buildertek__Category__c') == false){
            fields += ' , ' + 'buildertek__Category__c ';
        }
        if(fields.contains('buildertek__Categories__c') == false){
            fields += ' , ' + 'buildertek__Categories__c ';
        }
        if(fields.contains('buildertek__Categories__r.Name') == false){
            fields += ' , ' + 'buildertek__Categories__r.Name ';
        }
        if(fields.contains('buildertek__Product_Type__c') == false){
            fields += ' , ' + 'buildertek__Product_Type__c ';
        }
        if(fields.contains('buildertek__Product_Type__r.Name') == false){
            fields += ' , ' + 'buildertek__Product_Type__r.Name ';
        }
        if(fields.contains('buildertek__Location__c') == false){
            fields += ' , ' + 'buildertek__Location__c ';
        }
        if(fields.contains('buildertek__Quantity__c') == false){
            fields += ' , ' + 'buildertek__Quantity__c ';
        }
        if(fields.contains('buildertek__Product_Code__c') == false){
            fields += ' , ' + 'buildertek__Product_Code__c ';
        }
        if(fields.contains('buildertek__Price_Book__c') == false){
            fields += ' , ' + 'buildertek__Price_Book__c ';
        }
        if(fields.contains('buildertek__Pricebook_Name__c') == false){
            fields += ' , ' + 'buildertek__Pricebook_Name__c ';
        }
        if(fields.contains('buildertek__TL_SERVICE_CATEGORY__c') == false){
            fields += ' , ' + 'buildertek__TL_SERVICE_CATEGORY__c ';
        }
        system.debug(fields);
        
        
        query = query+fields+' FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =:takeOffId ';
        
        
        //query = 'Select Id,Name,buildertek__Categories__c, buildertek__Categories__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Location__c, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Quantity__c FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =:takeOffId ';
        filter = '';
        //Filter query based on Product2.
        if(productList != null && !productList.isEmpty() && productList.size() > 0 )
        {
            for (Product2 product : productList){
                filter += product.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + product.buildertek__Trade_Type__c + '\'';
                filter += product.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + product.buildertek__Product_Type__c + '\'';
                filter += product.buildertek__Category__c == null ? ' AND buildertek__Categories__c = null' : ' AND buildertek__Categories__c =\'' + product.buildertek__Category__c + '\'';
                filter += ' ) ';
            }
        }
        query += filter;
        //query = query.replace(' WHERE  OR ', ' WHERE ');
        //query += ' ORDER BY buildertek__Trade_Type__r.Name ASC , buildertek__Categories__r.Name ASC, buildertek__Product_Type__r.Name ASC, buildertek__Location__c ASC, buildertek__Quantity__c ASC';
        //query += ' LIMIT : pageSize OFFSET : offset';
        productClassWrapper.takeOffLinesList = Database.query(query);
        
        query = 'Select COUNT() FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =:takeOffId ' + filter;//Total records with Search Query filter.
        //query = query.replace(' WHERE  OR ', ' WHERE ');
        productClassWrapper.totalRecords = Database.countQuery(query);
        
        //SSTL
        query = 'Select Id,Name,buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Location__c, buildertek__Product_Type__c, buildertek__Product_Type__r.Name FROM buildertek__Select_Sheet__c WHERE ';
        filter = '';
        filter = ' buildertek__Selection_Sheet_Takeoff__c=:recordId';
        //Filter query based on Product2.
        if(productList != null && !productList.isEmpty() && productList.size() > 0 )
        {
            for (Product2 product : productList){
                filter += product.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + product.buildertek__Trade_Type__c + '\'';
                filter += product.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + product.buildertek__Product_Type__c + '\'';
                filter += product.buildertek__Category__c == null ? ' AND buildertek__Category__c = null' : ' AND buildertek__Category__c =\'' + product.buildertek__Category__c + '\'';
                filter += ' ) ';
            }
        }
        query += filter;
        //query = query.replace(' WHERE  OR ', ' WHERE ');
        //query += ' ORDER BY buildertek__Trade_Type__r.Name ASC , buildertek__Category__r.Name ASC,buildertek__Vendor__r.Name ASC, buildertek__Product_Type__r.Name ASC, buildertek__Location__c ASC';
        //query += ' LIMIT : pageSize OFFSET : offset';
        System.debug('#@#@query--'+query);
        productClassWrapper.selectionSheetTakeOffLines = Database.query(query);
        //SSTL Count
        query = 'Select COUNT() FROM buildertek__Select_Sheet__c WHERE ' + filter;//Total records with Search Query filter.
        query = query.replace(' WHERE  OR ', ' WHERE ');
        productClassWrapper.SSTLTotalRecords = Database.countQuery(query);
        return productClassWrapper;
        //   } catch (Exception e){
        //       System.debug('Error Message::' + e.getMessage());
        //       System.debug('Error Line::' + e.getLineNumber());
        //        throw new AuraHandledException(e.getMessage());
        //   }
    }
    
    //Assign Product to the SSTL.
    @AuraEnabled
    public static String assignProductToSSTLRecord1(Integer productPageNumber, Integer productPageSize, Integer pageNumber, Integer pageSize, Integer SSTLPageNumber, Integer SSTLPageSize, String filteredTakeOffLines, String productId, List<String> selectedSSTL){
        // try{
        if (String.isNotBlank(productId) && selectedSSTL.size() > 0){
            Product2 productRec = [Select Id, Name
                                   FROM Product2
                                   WHERE Id = :productId
                                   LIMIT 1];
            List<buildertek__Select_Sheet__c> SSTLList = new List<buildertek__Select_Sheet__c>();
            for (String recId : selectedSSTL){
                buildertek__Select_Sheet__c SSTL = new buildertek__Select_Sheet__c();
                SSTL.buildertek__Product__c = productRec.Id;
                // SSTL.Name = productRec.Name;
                SSTL.Id = recId;
                SSTLList.add(SSTL);
            }
            if (SSTLList.size() > 0){
                update SSTLList;
            }
            return 'Success';
        }
        return null;
        //  } catch (Exception e){
        //      System.debug('Error Message::' + e.getMessage());
        //     System.debug('Error Line::' + e.getLineNumber());
        //throw new AuraHandledException(e.getMessage());
        // }
    }

    @AuraEnabled
    public static ProductClass validateAndCreateBOMLines(String billOfMaterialId)
    {
        try 
        {
            String query = '';
            String fields= '';
            String filter = '';
            
            List<buildertek__Select_Sheet__c> bomLines = new List<buildertek__Select_Sheet__c>();
            Map<Id,buildertek__Project_Takeoff_Lines__c> takeOfflineMap = new Map<Id,buildertek__Project_Takeoff_Lines__c>();
            //List<buildertek__Project_Takeoff_Lines__c> finalTOLlist = new List<buildertek__Project_Takeoff_Lines__c>();
            List<String> finalTOLlist = new List<String>();
            List<String> productIdList = new List<String>();
            Set<String> productIdSet = new Set<String>();
            Map<String,List<String>> takeOffVsProdCode = new Map<String,List<String>>();
            if(String.isNotBlank(billOfMaterialId))
            {
                AddProductForSSTL.ProductClass pdCls = AddProductForSSTL.getAllProductsAndSelectedTakeOffLines(billOfMaterialId,0,0,0,0,0,0,'');
                System.debug('#@#@BOM--'+pdcls.projectSelectionSheetTakeOffRec);
                System.debug('#@#@BOM Lines--'+pdcls.selectionSheetTakeOffLines);
                System.debug('#@#@BOM Lines Size--'+pdcls.selectionSheetTakeOffLines.size() );
                System.debug('#@#@TakeOff Lines--'+pdcls.takeOffLinesList);
                System.debug('#@#@TakeOff Lines Size--'+pdcls.takeOffLinesList.size());

                //No BOM Line Record Present, Create New Ones
                if(pdcls.selectionSheetTakeOffLines == null || pdcls.selectionSheetTakeOffLines.isEmpty() ||  pdcls.selectionSheetTakeOffLines.size() == 0)
                {
                    Map<String,String> takeOffLineVsPriceBookIds = new Map<String,String>();
                    //Map<String,String> takeOffLineVsProductCode = new Map<String,String>();
                    Map<String,set<String>> takeOffLineVsProductCode = new Map<String,set<String>>();
                    Map<String,String> priceBookIdVsProdCodeMap = new Map<String,String>();

                    if(pdcls.takeOffLinesList != null && pdcls.takeOffLinesList.size() > 0)
                    {
                        for(buildertek__Project_Takeoff_Lines__c singleTakeOffLine : pdcls.takeOffLinesList)
                        {
                            if(String.isNotBlank(singleTakeOffLine.buildertek__Price_Book__c) && String.isNotBlank(singleTakeOffLine.buildertek__Product_Code__c))
                            {
                                system.debug('***-->'+singleTakeOffLine.buildertek__Price_Book__c+'&&&--->'+singleTakeOffLine.buildertek__Product_Code__c);
                                takeOffLineVsPriceBookIds.put(singleTakeOffLine.Id, singleTakeOffLine.buildertek__Price_Book__c);
                                //takeOffLineVsProductCode.put(singleTakeOffLine.Id, singleTakeOffLine.buildertek__Product_Code__c);
                                priceBookIdVsProdCodeMap.put(singleTakeOffLine.buildertek__Price_Book__c, singleTakeOffLine.buildertek__Product_Code__c);

                                if(takeOffLineVsProductCode.containsKey(singleTakeOffLine.buildertek__Product_Code__c) )
                                {
                                    set<String> takeOffIds = takeOffLineVsProductCode.get(singleTakeOffLine.buildertek__Product_Code__c);
                                    takeOffIds.add(singleTakeOffLine.Id);
                                    takeOffLineVsProductCode.put(singleTakeOffLine.buildertek__Product_Code__c,takeOffIds);
                                }
                                else
                                {
                                    set<String> takeOffIds = new set<String>();
                                    takeOffIds.add(singleTakeOffLine.Id);
                                    takeOffLineVsProductCode.put(singleTakeOffLine.buildertek__Product_Code__c,takeOffIds);
                                }
                            }

                            takeOfflineMap.put(singleTakeOffLine.Id,singleTakeOffLine);
                        }

                        System.debug('#@#@ takeOffLineVsProductCode===='+takeOffLineVsProductCode);
                        System.debug('#@#@ priceBookIdVsProdCodeMap===='+priceBookIdVsProdCodeMap);

                        return checkPBAndCreateBomLines(takeOffLineVsPriceBookIds,takeOffLineVsProductCode,priceBookIdVsProdCodeMap,pdcls.projectSelectionSheetTakeOffRec.buildertek__Project__c,billOfMaterialId);

                        // if(takeOffLineVsPriceBookIds != null && takeOffLineVsPriceBookIds.size() > 0)
                        // {
                        //     list<PricebookEntry> allPbEntries = AddProductForSSTL.getPriceBookEntries(takeOffLineVsPriceBookIds.values());
                        //     if(allPbEntries != null && allPbEntries.size() > 0)
                        //     {
                        //         for(PricebookEntry pbEntry :allPbEntries)
                        //         {
                        //            if(pbEntry.ProductCode != null && pbEntry.product2Id != null && !productIdSet.contains(pbEntry.product2Id) && priceBookIdVsProdCodeMap.containsKey(pbEntry.pricebook2Id) && takeOffLineVsProductCode.containsKey(pbEntry.ProductCode) )
                        //            {
                        //             System.debug('#@#@ pbEntry.ProductCode===='+pbEntry.ProductCode);
                        //                System.debug('#@#@ FOund TakeOff===='+takeOffLineVsProductCode.get(pbEntry.ProductCode));
                        //                productIdList.add(pbEntry.product2Id);
                        //                productIdSet.add(pbEntry.product2Id);

                        //                for(String bomLineId : takeOffLineVsProductCode.get(pbEntry.ProductCode))
                        //                {
                        //                    finalTOLlist.add(bomLineId) ;
                        //                }
                                       

                        //                List<String> prodIds = new List<String>();
                        //                prodIds.add(pbEntry.product2Id);
                        //                //takeOffVsProdCode.put(takeOffLineVsProductCode.get(pbEntry.ProductCode), prodIds);
                        //                for(String bomLineId : takeOffLineVsProductCode.get(pbEntry.ProductCode))
                        //                {
                        //                   takeOffVsProdCode.put(bomLineId, prodIds);
                        //                }
                        //            } 
                        //         }
                        //     }
                        // }

                        // System.debug('#@#@finalTOLlist--'+finalTOLlist);
                        // System.debug('#@#@finalTOLlist--'+finalTOLlist.size());
                        // System.debug('#@#@ProjectId--'+pdcls.projectSelectionSheetTakeOffRec.buildertek__Project__c);
                        // System.debug('#@#@productIdList--'+productIdList.size());
                        // System.debug('#@#@productIdList--'+productIdList);
                        // System.debug('#@#@takeOffVsProdCode--'+takeOffVsProdCode.size());
                        // System.debug('#@#@takeOffVsProdCode--'+takeOffVsProdCode);
                        // String projectId = pdcls.projectSelectionSheetTakeOffRec.buildertek__Project__c;
                        // if(finalTOLlist != null && finalTOLlist.size() > 0 && !finalTOLlist.isEmpty() && productIdList != null && productIdList.size() > 0 && !productIdList.isEmpty())
                        // {
                        //     List<String> productIds = new List<String>();
                        //     //return AddProductForSSTL.createTakeOffLinesRecords(productIds,billOfMaterialId,0,0,0,0,0,0,'','','',productIdList,finalTOLlist,projectId,'');
                        //     return AddProductForSSTL.createBOMLinesAuto(productIds,billOfMaterialId,0,0,0,0,0,0,'','','',productIdList,finalTOLlist,projectId,'',takeOffVsProdCode);
                        // }
                    }
                }
                else 
                {
                    System.debug('#@#@ BOM LINE PRESENT');
                }

            }
            return null;
        } catch (Exception e) {
            System.debug(e);
            System.debug('Error Message validateAndCreateBOMLines::' + e.getMessage());
            System.debug('Error Line validateAndCreateBOMLines::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    @AuraEnabled
    public static list<PricebookEntry> getPriceBookEntries(List<String> priceBookIds){
        System.debug('########pricebook'+priceBookIds);
        list<PricebookEntry> pList;
        if(Schema.sObjectType.pricebookEntry.fields.Id.isAccessible()&&
           Schema.sObjectType.PricebookEntry.fields.UnitPrice.isAccessible() &&
           Schema.sObjectType.PricebookEntry.fields.product2Id.isAccessible() &&
           Schema.sObjectType.Pricebook2.fields.Id.isAccessible() &&
           Schema.sObjectType.Pricebook2.fields.isActive.isAccessible()){
               pList = [select id,UnitPrice,product2Id,ProductCode,pricebook2Id from PricebookEntry where 
                        isActive = true and 
                        pricebook2Id IN:priceBookIds ];
           }
        for(PricebookEntry pocrec: pList){
            system.debug('pocrec'+pocrec.product2Id);
             system.debug('ProductCode'+pocrec.ProductCode);
             system.debug('pricebook2Id'+pocrec.pricebook2Id);
        }
        system.debug('====pList'+pList);
        return pList;
    } 

    private static ProductClass checkPBAndCreateBomLines(Map<String,String> takeOffLineVsPriceBookIds,Map<String,set<String>> takeOffLineVsProductCode,Map<String,String> priceBookIdVsProdCodeMap,String projectId,String billOfMaterialId)
    {
        List<String> finalTOLlist = new List<String>();
        List<String> productIdList = new List<String>();
        Set<String> productIdSet = new Set<String>();
        Map<String,List<String>> takeOffVsProdCode = new Map<String,List<String>>();
        system.debug('takeOffLineVsPriceBookIds'+takeOffLineVsPriceBookIds);
        if (takeOffLineVsPriceBookIds != null && takeOffLineVsPriceBookIds.size() > 0) 
        {
            list < PricebookEntry > allPbEntries = AddProductForSSTL.getPriceBookEntries(takeOffLineVsPriceBookIds.values());
            system.debug('allPbEntries'+allPbEntries);
            if (allPbEntries != null && allPbEntries.size() > 0) 
            {
                for (PricebookEntry pbEntry: allPbEntries) 
                {
                    if (pbEntry.ProductCode != null && pbEntry.product2Id != null && !productIdSet.contains(pbEntry.product2Id) && 
                        priceBookIdVsProdCodeMap.containsKey(pbEntry.pricebook2Id) && takeOffLineVsProductCode.containsKey(pbEntry.ProductCode)) 
                    {
                        System.debug('#@#@ pbEntry.ProductCode====' + pbEntry.ProductCode);
                        System.debug('#@#@ FOund TakeOff====' + takeOffLineVsProductCode.get(pbEntry.ProductCode));
                        productIdList.add(pbEntry.product2Id);
                        productIdSet.add(pbEntry.product2Id);
        
                        for (String bomLineId: takeOffLineVsProductCode.get(pbEntry.ProductCode)) 
                        {
                            finalTOLlist.add(bomLineId);
                        }
        
        
                        List < String > prodIds = new List < String > ();
                        prodIds.add(pbEntry.product2Id);
                        for (String bomLineId: takeOffLineVsProductCode.get(pbEntry.ProductCode)) 
                        {
                            takeOffVsProdCode.put(bomLineId, prodIds);
                        }
                    }
                }
            }
        }
        
        
        if (finalTOLlist != null && finalTOLlist.size() > 0 && !finalTOLlist.isEmpty() && productIdList != null && productIdList.size() > 0 && !productIdList.isEmpty()) {
            List < String > productIds = new List < String > ();
            return AddProductForSSTL.createBOMLinesAuto(productIds, billOfMaterialId, 0, 0, 0, 0, 0, 0, '', '', '', productIdList, finalTOLlist, projectId, '', takeOffVsProdCode);
        }

        return null;
    }


    @AuraEnabled
    public static ProductClass createTakeOffLinesRecords(List<String> productIds, String recordId, Integer productPageNumber, Integer productPageSize, Integer pageSize, 
                                                         Integer pageNumber, Integer SSTLPageNumber, Integer SSTLPageSize,  String filter1,String filter2,String filter3,  List<String> productIdList, List<String> takeOffLineList, String projectId,String selectPriceBook){
          try{
              
              
              Map<String,String> LocationMap = new Map<String, String>();
              Map<String, String> takeOffLineMap = new Map<String, String>();
              Map<String, Decimal> quantityMap    = new Map<String, Decimal>();
              Map<String, String> buildPhaseMap = new Map<String, String>();
               List<buildertek__Project_Takeoff_Lines__c> takeOffLinesList = new List<buildertek__Project_Takeoff_Lines__c>();
              if(takeOffLineList.size() > 0){
                  takeOffLinesList = [SELECT Id, 
                                                                                 Name, 
                                                                                 buildertek__Location__c, 
                                                                                 buildertek__Quantity__c,
                                                                                 buildertek__Product_Type__c,
                                                                                 buildertek__Build_Phase__c,
                                                                                 buildertek__TL_SERVICE_CATEGORY__c,
                                                                                 buildertek__Build_Phase__r.Name,
                                                                                 buildertek__TO_BUILD_REF1__c,buildertek__Base_Location__c,buildertek__Location_Detailed_Area__c,
                                                                                 buildertek__TO_LOCATION_DETAIL_REF__c,buildertek__TO_INSTALL_LOC__c,
                                                                                 buildertek__TO_INSTALL_LOC_REF__c
                                                                                 FROM buildertek__Project_Takeoff_Lines__c
                                                                                 WHERE Id IN: takeOffLineList];  
                  system.debug('takeOffLinesList --------> '+takeOffLinesList);
                  for(buildertek__Project_Takeoff_Lines__c takeOffLine : takeOffLinesList){
                      quantityMap.put(takeOffLine.buildertek__Product_Type__c,takeOffLine.buildertek__Quantity__c);
                      LocationMap.put(takeOffLine.buildertek__Product_Type__c, takeOffLine.buildertek__Location__c);
                      takeOffLineMap.put(takeOffLine.buildertek__Product_Type__c, takeOffLine.Id);
                      buildPhaseMap.put(takeOffLine.buildertek__Product_Type__c,takeOffLine.buildertek__Build_Phase__c);
                  }
                  system.debug(buildPhaseMap);
              }
              if (productIdList.size() > 0){
                  List<Product2> productList = [Select Id, Name, buildertek__Category__c, buildertek__Instructions__c, buildertek__Trade_Type__c, buildertek__Product_Type__c, 
                                                buildertek__Vendor__c
                                                FROM Product2
                                                WHERE Id IN :productIdList];
                  list<pricebook2> PriceListt;
                              PriceListt = [select Id, Name
                                           from pricebook2
                                           Where Id =: selectPriceBook AND buildertek__BT_Visible__c = true];
                  system.debug('products size ----> '+productList.size());
                  system.debug('productList for vendor'+productList);
                  List<buildertek__Select_Sheet__c> selectionList = new List<buildertek__Select_Sheet__c>();
                  
                  if (productList.size() > 0 && takeOffLineList.size() > 0){
                      for(buildertek__Project_Takeoff_Lines__c takeoffLineItem : takeOffLinesList){
                          for (Product2 product : productList){
                              //for (String takeOffLineId : takeOffLineList){
                              buildertek__Select_Sheet__c SSTL = new buildertek__Select_Sheet__c();
                              SSTL.Name = product.Name;
                              SSTL.buildertek__Category__c = product.buildertek__Category__c;
                              SSTL.buildertek__Instructions__c = product.buildertek__Instructions__c;
                              SSTL.buildertek__Product_Type__c = product.buildertek__Product_Type__c;
                              SSTL.buildertek__Selection_Sheet_Takeoff__c = recordId;
                              SSTL.buildertek__Product__c = product.Id;
                              SSTL.buildertek__Trade_Type__c = product.buildertek__Trade_Type__c;
                              SSTL.buildertek__Project__c = projectId;
                              SSTL.buildertek__Vendor__c = product.buildertek__Vendor__c;
                              SSTL.buildertek__Takeoff_Line__c = takeoffLineItem.Id; //takeOffLineList[0];//takeOffLineMap.get(product.buildertek__Product_Type__c);
                              SSTL.buildertek__Standard__c = 'Yes';
                              SSTL.buildertek__Type__c = 'Standard';
                              SSTL.buildertek__Location_Picklist__c = takeoffLineItem.buildertek__Location__c; //LocationMap.get(product.buildertek__Product_Type__c);
                              SSTL.buildertek__Build_Reference_1__c = takeoffLineItem.buildertek__TO_BUILD_REF1__c; 
                              SSTL.buildertek__Base_Location__c = takeoffLineItem.buildertek__Base_Location__c; 
                              SSTL.buildertek__Location_Detailed_Area__c = takeoffLineItem.buildertek__Location_Detailed_Area__c; 
                              SSTL.buildertek__Location_Detail_Reference_1__c = takeoffLineItem.buildertek__TO_LOCATION_DETAIL_REF__c; 
                              SSTL.buildertek__Install_Location__c = takeoffLineItem.buildertek__TO_INSTALL_LOC__c; 
                              SSTL.buildertek__Install_Location_Reference__c = takeoffLineItem.buildertek__TO_INSTALL_LOC_REF__c; 
                              SSTL.buildertek__Build_Phase__c = takeoffLineItem.buildertek__Build_Phase__c; // buildPhaseMap.get(product.buildertek__Product_Type__c);
                              SSTL.buildertek__Quantity__c = takeoffLineItem.buildertek__Quantity__c;//quantityMap.get(product.buildertek__Product_Type__c);
                              SSTL.buildertek__Service_Category__c = takeoffLineItem.buildertek__TL_SERVICE_CATEGORY__c;
                              SSTL.buildertek__BL_SERVICE_CATEGORY__c = takeoffLineItem.buildertek__TL_SERVICE_CATEGORY__c;
                              SSTL.buildertek__BT_Price_Book__c = PriceListt[0].Id;
                              selectionList.add(SSTL);
                              system.debug(SSTL.buildertek__BT_Price_Book__c);
                              //}
                          }
                      }
                      
                      
                  } else if (productList.size() > 0 && takeOffLineList.size() == 0){
                      for (Product2 product : productList){
                          buildertek__Select_Sheet__c SSTL = new buildertek__Select_Sheet__c();
                          SSTL.Name = product.Name;
                          SSTL.buildertek__Category__c = product.buildertek__Category__c;
                          SSTL.buildertek__Instructions__c = product.buildertek__Instructions__c;
                          SSTL.buildertek__Product_Type__c = product.buildertek__Product_Type__c;
                          SSTL.buildertek__Selection_Sheet_Takeoff__c = recordId;
                          SSTL.buildertek__Product__c = product.Id;
                          SSTL.buildertek__Trade_Type__c = product.buildertek__Trade_Type__c;
                          SSTL.buildertek__Project__c = projectId;
                          SSTL.buildertek__Vendor__c = product.buildertek__Vendor__c;
                          SSTL.buildertek__Standard__c = 'Yes';
                          SSTL.buildertek__Type__c = 'Standard';
                          SSTL.buildertek__Build_Phase__c = buildPhaseMap.get(product.buildertek__Product_Type__c);
                          SSTL.buildertek__Quantity__c = quantityMap.get(product.buildertek__Product_Type__c);
                          SSTL.buildertek__BT_Price_Book__c = PriceListt[0].Id;
                          selectionList.add(SSTL);
                          system.debug(selectionList);
                      }
                  }
                  
                  if (selectionList.size() > 0){
                      system.debug('selectionList size -----> '+selectionList.size());
                      system.debug('selectionList buildertek__BT_Price_Book__c -----> '+selectionList[0].buildertek__BT_Price_Book__c);
                      //selectionList[0].buildertek__BT_Price_Book__c = PriceListt[0].Id;
                      
                     
                      System.debug('<selectPriceBook>==>'+selectPriceBook);
                      if(selectPriceBook != null && selectPriceBook != ''){
                          List<buildertek__Project_Takeoff_Lines__c> TakeofLinesToUpdate = new List<buildertek__Project_Takeoff_Lines__c>();
                          System.debug('<takeOffLineList>'+takeOffLineList);
                          for(buildertek__Project_Takeoff_Lines__c TakeOfLines: [SELECT id, name, buildertek__Price_Book__c FROM buildertek__Project_Takeoff_Lines__c WHERE Id IN: takeOffLineList]){
                              System.debug('<TakeOfLines> '+TakeOfLines);
                              System.debug('<TakeOfLines.buildertek__Price_Book__c> '+TakeOfLines.buildertek__Price_Book__c);
                              if(TakeOfLines.buildertek__Price_Book__c == NULL){
                                  System.debug(PriceListt.size()+'<>'+PriceListt[0].Id);
                                TakeOfLines.buildertek__Price_Book__c = PriceListt[0].Id;
                                
                                TakeofLinesToUpdate.add(TakeOfLines);   
                              }
                          }
                          if(TakeofLinesToUpdate.size() > 0){
                                update TakeofLinesToUpdate;
                          }
                      }else{
                          List<buildertek__Project_Takeoff_Lines__c> TakeofLinesToUpdate = new List<buildertek__Project_Takeoff_Lines__c>();
                          //System.debug('<takeOffLineList>'+takeOffLineList);
                          for(buildertek__Project_Takeoff_Lines__c TakeOfLines: [SELECT id, name, buildertek__Price_Book__c FROM buildertek__Project_Takeoff_Lines__c WHERE Id IN: takeOffLineList]){
                              //System.debug('<TakeOfLines> '+TakeOfLines);
                              //System.debug('<TakeOfLines.buildertek__Price_Book__c> '+TakeOfLines.buildertek__Price_Book__c);
                              //if(TakeOfLines.buildertek__Price_Book__c == null || TakeOfLines.buildertek__Price_Book__c == ''){
                                  //System.debug(PriceListt.size()+'<>'+PriceListt[0].Id);
                                TakeOfLines.buildertek__Price_Book__c = null;
                                
                                TakeofLinesToUpdate.add(TakeOfLines);   
                              //}
                          }
                          if(TakeofLinesToUpdate.size() > 0){
                                update TakeofLinesToUpdate;
                          }
                      }
                      
                     
                        Database.SaveResult[] saveResultList = Database.insert(selectionList, false);

                        // Iterate through saveResultList based on isSuccess capture the failed records
                        for (Database.SaveResult sr : saveResultList) {
                            if (sr.isSuccess()) {
                                // Operation was successful, so get the ID of the record that was processed
                                System.debug('Successfully inserted account. Account ID: ' + sr.getId());
                            }
                            else {
                                // Operation failed, so get all errors                
                                for(Database.Error err : sr.getErrors()) {
                                    System.debug('The following error has occurred.');                    
                                    System.debug(err.getStatusCode() + ': ' + err.getMessage());
                                    System.debug('Account fields that affected this error: ' + err.getFields());
                                }
                            }
                        }
                    //   insert selectionList;
                      
                      // update BOM Line with pricebook values
                      list<Id> proID= new list<Id>();
                      for(buildertek__Select_Sheet__c sheetRec : selectionList){
                          proID.add(sheetRec.buildertek__Product__c);
                      }
                      list<buildertek__Select_Sheet__c> selectionList1 = new list<buildertek__Select_Sheet__c>();
                      if(selectPriceBook != null && selectPriceBook != ''){
                          
                          if(UserInfo.isMultiCurrencyOrganization()){
                              buildertek__Project_Selection_Sheet_Takeoff__c parentBOMrecord = new buildertek__Project_Selection_Sheet_Takeoff__c();
                              string parentBOMrecordQry = 'Select Id,Name,CurrencyIsoCode from buildertek__Project_Selection_Sheet_Takeoff__c where Id=:recordId';    
                              parentBOMrecord = Database.query(parentBOMrecordQry);
                              system.debug(proID);
                              system.debug(parentBOMrecord);
                              list<pricebook2> PriceList;
                              PriceList = [select Id, Name
                                           from pricebook2
                                           Where Id =: selectPriceBook AND buildertek__BT_Visible__c = true];
                              System.debug('PriceList-->'+PriceList);
                              if(parentBOMrecord != null){
                                  //  String code = (String) parentBOMrecord.get('CurrencyIsoCode');
                                  // string parentBOMCurrency =  parentBOMrecord.CurrencyIsoCode;
                                  string parentBOMCurrency =  (String) parentBOMrecord.get('CurrencyIsoCode');
                                  string pricebookentrylistQry = 'select id,Name,CurrencyIsoCode,buildertek__Unit_Cost__c,buildertek__Markup__c,buildertek__Discount__c,UnitPrice, Product2Id,Pricebook2Id from PricebookEntry   where Product2Id IN: proID and Pricebook2Id IN: PriceList AND CurrencyIsoCode=: parentBOMCurrency limit 1';    
                                  list<PricebookEntry> pricebookentrylist1 =  Database.query(pricebookentrylistQry);
                                  system.debug(pricebookentrylist1);
                                  if(pricebookentrylist1.size() > 0){
                                      for(PricebookEntry pricebookRec : pricebookentrylist1){
                                          for(buildertek__Select_Sheet__c sheetRec1 : selectionList){
                                            System.debug('<--pricebookRec.Product2Id-->'+pricebookRec.Product2Id);
                                            System.debug('<--sheetRec1.buildertek__Product__c-->'+sheetRec1.buildertek__Product__c);
                                              if(pricebookRec.Product2Id == sheetRec1.buildertek__Product__c){
                                                //   if(PriceList.size() >0 ){
                                                //       sheetRec1.buildertek__BT_Price_Book__c = PriceList[0].Id;
                                                //   }
                                                  System.debug('<--sheetRec1.buildertek__BT_Price_Book__c-->'+sheetRec1.buildertek__BT_Price_Book__c);
                                                  sheetRec1.put('CurrencyIsoCode',(String) parentBOMrecord.get('CurrencyIsoCode'));
                                                  //  (String) sheetRec1.set('CurrencyIsoCode') = (String) parentBOMrecord.get('CurrencyIsoCode');
                                                  sheetRec1.buildertek__BL_MARKUP__c = pricebookRec.buildertek__Markup__c;
                                                  sheetRec1.buildertek__BL_DISCOUNT__c = pricebookRec.buildertek__Discount__c;
                                                         system.debug('pricebookRec.UnitPrice3------>'+pricebookRec.UnitPrice);
                                                        system.debug('sheetRec1.buildertek__BL_LIST_PRICE__c3---->'+sheetRec1.buildertek__BL_LIST_PRICE__c);
                                                  sheetRec1.buildertek__BL_LIST_PRICE__c = pricebookRec.UnitPrice;
                                                  sheetRec1.buildertek__BL_UNIT_COST__c = pricebookRec.buildertek__Unit_Cost__c;
                                                  sheetRec1.id = sheetRec1.id;
                                                  selectionList1.add(sheetRec1);
                                              }
                                          }
                                      }  
                                      if(selectionList1.size() > 0){
                                          update selectionList1;
                                          for(buildertek__Select_Sheet__c bs : selectionList1){
                                                System.debug(bs.Id);
                                                System.debug(bs.buildertek__BT_Price_Book__c);
                                                System.debug(bs.Name);
                                          }
                                      }
                                  }else {
                                      parentBOMCurrency =  'USD';
                                      pricebookentrylistQry = 'select id,Name,CurrencyIsoCode,buildertek__Unit_Cost__c,buildertek__Markup__c,buildertek__Discount__c,UnitPrice, Product2Id,Pricebook2Id from PricebookEntry   where Product2Id IN: proID and Pricebook2Id IN: PriceList AND CurrencyIsoCode=: parentBOMCurrency limit 1';    
                                      pricebookentrylist1 =  Database.query(pricebookentrylistQry);
                                      system.debug(pricebookentrylist1);
                                      if(pricebookentrylist1.size() > 0){
                                          selectionList1 = new list<buildertek__Select_Sheet__c>();
                                          for(PricebookEntry pricebookRec : pricebookentrylist1){
                                              for(buildertek__Select_Sheet__c sheetRec1 : selectionList){
                                                  if(pricebookRec.Product2Id == sheetRec1.buildertek__Product__c){
                                                    //   if(PriceList.size() >0 ){
                                                    //       sheetRec1.buildertek__BT_Price_Book__c = PriceList[0].Id;
                                                    //   }
                                                      sheetRec1.put('CurrencyIsoCode',(String) parentBOMrecord.get('CurrencyIsoCode')); 
                                                      // sheetRec1.CurrencyIsoCode =  parentBOMCurrency;
                                                      sheetRec1.buildertek__BL_MARKUP__c = pricebookRec.buildertek__Markup__c;
                                                      sheetRec1.buildertek__BL_DISCOUNT__c = pricebookRec.buildertek__Discount__c;
                                                           system.debug('pricebookRec.UnitPrice4------>'+pricebookRec.UnitPrice);
                                                           system.debug('sheetRec1.buildertek__BL_LIST_PRICE__c4---->'+sheetRec1.buildertek__BL_LIST_PRICE__c);
                                                      sheetRec1.buildertek__BL_LIST_PRICE__c = pricebookRec.UnitPrice;
                                                      sheetRec1.buildertek__BL_UNIT_COST__c = pricebookRec.buildertek__Unit_Cost__c;
                                                      sheetRec1.id = sheetRec1.id;
                                                      selectionList1.add(sheetRec1);
                                                  }
                                              }
                                          }  
                                          if(selectionList1.size() > 0){
                                              update selectionList1;
                                              System.debug(selectionList1);
                                          }
                                      }
                                  }
                              }   
                          }else{
                              list<pricebook2> PriceList;
                              PriceList = [select Id, Name
                                           from pricebook2
                                           Where Id =: selectPriceBook AND buildertek__BT_Visible__c = true];
                              list<PricebookEntry> pricebookentrylist1 = [select id,Name,buildertek__Unit_Cost__c,buildertek__Markup__c,buildertek__Discount__c,UnitPrice,
                                                                          Product2Id,Pricebook2Id from PricebookEntry
                                                                          where Product2Id IN: proID and Pricebook2Id IN: PriceList]; 
                              if(pricebookentrylist1.size() > 0){
                                  for(PricebookEntry pricebookRec : pricebookentrylist1){
                                      for(buildertek__Select_Sheet__c sheetRec1 : selectionList){
                                          if(pricebookRec.Product2Id == sheetRec1.buildertek__Product__c){
                                              sheetRec1.buildertek__BL_MARKUP__c = pricebookRec.buildertek__Markup__c;
                                              sheetRec1.buildertek__BL_DISCOUNT__c = pricebookRec.buildertek__Discount__c;
                                              system.debug('pricebookRec.UnitPrice5------>'+pricebookRec.UnitPrice);
                                                           system.debug('sheetRec1.buildertek__BL_LIST_PRICE__c5---->'+sheetRec1.buildertek__BL_LIST_PRICE__c);
                                              sheetRec1.buildertek__BL_LIST_PRICE__c = pricebookRec.UnitPrice;
                                              sheetRec1.buildertek__BL_UNIT_COST__c = pricebookRec.buildertek__Unit_Cost__c;
                                              sheetRec1.id = sheetRec1.id;
                                              selectionList1.add(sheetRec1);
                                          }
                                      }
                                  }  
                                  if(selectionList1.size() > 0){
                                      update selectionList1;
                                      System.debug(selectionList1);
                                  }
                              }
                          }
                          
                      }
                  }
                  // return searchQueryResult2(recordId, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, buildPhase, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
                  return searchQueryResult3(recordId, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, filter1,filter2, filter3, selectPriceBook);
              }
              return null;
          } catch (Exception e){
              System.debug('Error Message::' + e.getMessage());
              System.debug('Error Line::' + e.getLineNumber());
              System.debug('Error Cause::'+e.getCause());
              throw new AuraHandledException(e.getMessage());
          }
                                                         }


    
    @AuraEnabled
    public static ProductClass createBOMLinesAuto(List<String> productIds, String recordId, Integer productPageNumber, Integer productPageSize, Integer pageSize, 
                                                         Integer pageNumber, Integer SSTLPageNumber, Integer SSTLPageSize,  String filter1,String filter2,String filter3,  List<String> productIdList, List<String> takeOffLineList, String projectId,String selectPriceBook,Map<String,List<String>> takeOffVsProdCode){
          try{
              
              
              Map<String,String> LocationMap = new Map<String, String>();
              Map<String, String> takeOffLineMap = new Map<String, String>();
              Map<String, Decimal> quantityMap    = new Map<String, Decimal>();
              Map<String, String> buildPhaseMap = new Map<String, String>();
              Map<String, String> prodCodeVsPricebookMap = new Map<String, String>();
               List<buildertek__Project_Takeoff_Lines__c> takeOffLinesList = new List<buildertek__Project_Takeoff_Lines__c>();
              if(takeOffLineList.size() > 0){
                  takeOffLinesList = [SELECT Id, 
                                                                                 Name, 
                                                                                 buildertek__Location__c, 
                                                                                 buildertek__Quantity__c,
                                                                                 buildertek__Product_Type__c,
                                                                                 buildertek__Build_Phase__c,
                                                                                 buildertek__Price_Book__c,
                                                                                 buildertek__Product_Code__c,
                                                                                 buildertek__TL_SERVICE_CATEGORY__c,
                                                                                 buildertek__Build_Phase__r.Name,
                                                                                 buildertek__TO_BUILD_REF1__c,buildertek__Base_Location__c,
                                                                                 buildertek__Location_Detailed_Area__c,
                                                                                 buildertek__TO_LOCATION_DETAIL_REF__c,buildertek__TO_INSTALL_LOC__c,
                                                                                 buildertek__TO_INSTALL_LOC_REF__c
                                                                                 FROM buildertek__Project_Takeoff_Lines__c
                                                                                 WHERE Id IN: takeOffLineList];  
                  system.debug('takeOffLinesList --------> '+takeOffLinesList);
                  for(buildertek__Project_Takeoff_Lines__c takeOffLine : takeOffLinesList){
                      quantityMap.put(takeOffLine.buildertek__Product_Type__c,takeOffLine.buildertek__Quantity__c);
                      LocationMap.put(takeOffLine.buildertek__Product_Type__c, takeOffLine.buildertek__Location__c);
                      takeOffLineMap.put(takeOffLine.buildertek__Product_Type__c, takeOffLine.Id);
                      buildPhaseMap.put(takeOffLine.buildertek__Product_Type__c,takeOffLine.buildertek__Build_Phase__c);
                      prodCodeVsPricebookMap.put(takeOffLine.buildertek__Product_Code__c,takeOffLine.buildertek__Price_Book__c);
                  }
                  system.debug(buildPhaseMap);
              }
              if (productIdList.size() > 0){
                  List<Product2> productList = [Select Id, Name,ProductCode, buildertek__Category__c, buildertek__Instructions__c, buildertek__Trade_Type__c, buildertek__Product_Type__c, 
                                                buildertek__Vendor__c
                                                FROM Product2
                                                WHERE Id IN :productIdList];
                  system.debug('products size ----> '+productList.size());
                  system.debug('productList for vendor'+productList);
                  List<buildertek__Select_Sheet__c> selectionList = new List<buildertek__Select_Sheet__c>();
                  
                  if (productList.size() > 0 && takeOffLineList.size() > 0){
                      Map<Id,Product2> prodMap = new Map<Id,Product2>(productList);
                      for(buildertek__Project_Takeoff_Lines__c takeoffLineItem : takeOffLinesList){
                          if(takeOffVsProdCode.containsKey(takeoffLineItem.Id) && takeOffVsProdCode.get(takeoffLineItem.Id) != null )
                          {
                            for (String productId : takeOffVsProdCode.get(takeoffLineItem.Id)){
                                if(prodMap.containsKey(productId) && prodMap.get(productId) != null)
                                {
                                    Product2 product = prodMap.get(productId);
                                //for (String takeOffLineId : takeOffLineList){
                                buildertek__Select_Sheet__c SSTL = new buildertek__Select_Sheet__c();
                                SSTL.Name = product.Name;
                                SSTL.buildertek__Category__c = product.buildertek__Category__c;
                                SSTL.buildertek__Instructions__c = product.buildertek__Instructions__c;
                                SSTL.buildertek__Product_Type__c = product.buildertek__Product_Type__c;
                                SSTL.buildertek__Selection_Sheet_Takeoff__c = recordId;
                                SSTL.buildertek__Product__c = product.Id;
                                SSTL.buildertek__Trade_Type__c = product.buildertek__Trade_Type__c;
                                SSTL.buildertek__Project__c = projectId;
                                SSTL.buildertek__Vendor__c = product.buildertek__Vendor__c;
                                SSTL.buildertek__Takeoff_Line__c = takeoffLineItem.Id; //takeOffLineList[0];//takeOffLineMap.get(product.buildertek__Product_Type__c);
                                SSTL.buildertek__Standard__c = 'Yes';
                                SSTL.buildertek__Type__c = 'Standard';
                                SSTL.buildertek__Location_Picklist__c = takeoffLineItem.buildertek__Location__c; //LocationMap.get(product.buildertek__Product_Type__c);
                                SSTL.buildertek__Build_Reference_1__c = takeoffLineItem.buildertek__TO_BUILD_REF1__c; 
                                SSTL.buildertek__Base_Location__c = takeoffLineItem.buildertek__Base_Location__c; 
                                SSTL.buildertek__Location_Detailed_Area__c = takeoffLineItem.buildertek__Location_Detailed_Area__c; 
                                SSTL.buildertek__Location_Detail_Reference_1__c = takeoffLineItem.buildertek__TO_LOCATION_DETAIL_REF__c; 
                                SSTL.buildertek__Install_Location__c = takeoffLineItem.buildertek__TO_INSTALL_LOC__c; 
                                SSTL.buildertek__Install_Location_Reference__c = takeoffLineItem.buildertek__TO_INSTALL_LOC_REF__c; 
                                SSTL.buildertek__Build_Phase__c = takeoffLineItem.buildertek__Build_Phase__c; // buildPhaseMap.get(product.buildertek__Product_Type__c);
                                SSTL.buildertek__Quantity__c = takeoffLineItem.buildertek__Quantity__c;//quantityMap.get(product.buildertek__Product_Type__c);
                                SSTL.buildertek__Service_Category__c = takeoffLineItem.buildertek__TL_SERVICE_CATEGORY__c;
                                SSTL.buildertek__BL_SERVICE_CATEGORY__c = takeoffLineItem.buildertek__TL_SERVICE_CATEGORY__c;
                               /* if(prodCodeVsPricebookMap.containsKey(product.ProductCode))
                                {
                                    SSTL.buildertek__BT_Price_Book__c = prodCodeVsPricebookMap.get(product.ProductCode);
                                }*/
                                SSTL.buildertek__BT_Price_Book__c = takeoffLineItem.buildertek__Price_Book__c;
                                selectionList.add(SSTL);
                                system.debug('ergty#@#@pricebook--->'+SSTL.buildertek__BT_Price_Book__c);
                                //}
                                }
                            }
                          }
                          
                      }
                      
                      
                  } else if (productList.size() > 0 && takeOffLineList.size() == 0){
                      for (Product2 product : productList){
                          buildertek__Select_Sheet__c SSTL = new buildertek__Select_Sheet__c();
                          SSTL.Name = product.Name;
                          SSTL.buildertek__Category__c = product.buildertek__Category__c;
                          SSTL.buildertek__Instructions__c = product.buildertek__Instructions__c;
                          SSTL.buildertek__Product_Type__c = product.buildertek__Product_Type__c;
                          SSTL.buildertek__Selection_Sheet_Takeoff__c = recordId;
                          SSTL.buildertek__Product__c = product.Id;
                          SSTL.buildertek__Trade_Type__c = product.buildertek__Trade_Type__c;
                          SSTL.buildertek__Project__c = projectId;
                          SSTL.buildertek__Vendor__c = product.buildertek__Vendor__c;
                          SSTL.buildertek__Standard__c = 'Yes';
                          SSTL.buildertek__Type__c = 'Standard';
                          SSTL.buildertek__Build_Phase__c = buildPhaseMap.get(product.buildertek__Product_Type__c);
                          SSTL.buildertek__Quantity__c = quantityMap.get(product.buildertek__Product_Type__c);
                          selectionList.add(SSTL);
                          system.debug(selectionList);
                      }
                  }

                  system.debug('selectionList.size()**'+selectionList.size());
                  system.debug('selectionList**'+JSON.serialize(selectionList));

                  if (selectionList.size() > 0){
                      system.debug('selectionList size -----> '+selectionList.size());  
                      insert selectionList;
                      
                      // update BOM Line with pricebook values
                      list<Id> proID= new list<Id>();
                      list<Id> pricebookIds= new list<Id>();
                      for(buildertek__Select_Sheet__c sheetRec : selectionList){
                          proID.add(sheetRec.buildertek__Product__c);

                          if(sheetRec.BT_Price_Book__c!= null)
                          pricebookIds.add(sheetRec.BT_Price_Book__c);
                      }

                      system.debug('pricebookIds**'+pricebookIds);

                      list<buildertek__Select_Sheet__c> selectionList1 = new list<buildertek__Select_Sheet__c>();
                      if(pricebookIds != null && !pricebookIds.isEmpty()){
                          
                          if(UserInfo.isMultiCurrencyOrganization()){
                              buildertek__Project_Selection_Sheet_Takeoff__c parentBOMrecord = new buildertek__Project_Selection_Sheet_Takeoff__c();
                              string parentBOMrecordQry = 'Select Id,Name,CurrencyIsoCode from buildertek__Project_Selection_Sheet_Takeoff__c where Id=:recordId';    
                              parentBOMrecord = Database.query(parentBOMrecordQry);
                              system.debug('proID--'+proID);
                              system.debug('parentBOMrecord--'+parentBOMrecord);
                              list<pricebook2> PriceList;
                              PriceList = [select Id, Name
                                           from pricebook2
                                           Where Id IN : pricebookIds AND buildertek__BT_Visible__c = true];
                              
                              if(parentBOMrecord != null){
                                  //  String code = (String) parentBOMrecord.get('CurrencyIsoCode');
                                  // string parentBOMCurrency =  parentBOMrecord.CurrencyIsoCode;
                                  string parentBOMCurrency =  (String) parentBOMrecord.get('CurrencyIsoCode');
                                  string pricebookentrylistQry = 'select id,Name,CurrencyIsoCode,buildertek__Unit_Cost__c,buildertek__Markup__c,buildertek__Discount__c,UnitPrice, Product2Id,Pricebook2Id from PricebookEntry   where Product2Id IN: proID and Pricebook2Id IN: PriceList AND CurrencyIsoCode=: parentBOMCurrency';
                                  list<PricebookEntry> pricebookentrylist1 =  Database.query(pricebookentrylistQry);
                                  system.debug('pricebookentrylist1--'+pricebookentrylist1);
                                  if(pricebookentrylist1.size() > 0){
                                      for(PricebookEntry pricebookRec : pricebookentrylist1){
                                          for(buildertek__Select_Sheet__c sheetRec1 : selectionList){
                                              if(pricebookRec.Product2Id == sheetRec1.buildertek__Product__c &&
                                                      pricebookRec.Pricebook2Id == sheetRec1.BT_Price_Book__c) //Add Pricebook check
                                              {
                                                  if(PriceList.size() >0 ){
                                                  system.debug('KIOUH:JP:'+PriceList[0].Id);
                                                      sheetRec1.buildertek__BT_Price_Book__c = PriceList[0].Id;
                                                  }
                                                  sheetRec1.put('CurrencyIsoCode',(String) parentBOMrecord.get('CurrencyIsoCode'));
                                                  //  (String) sheetRec1.set('CurrencyIsoCode') = (String) parentBOMrecord.get('CurrencyIsoCode');
                                                  sheetRec1.buildertek__BL_MARKUP__c = pricebookRec.buildertek__Markup__c;
                                                  sheetRec1.buildertek__BL_DISCOUNT__c = pricebookRec.buildertek__Discount__c;
                                                  system.debug('pricebookRec.UnitPrice------>'+pricebookRec.UnitPrice);
                                                  system.debug('sheetRec1.buildertek__BL_LIST_PRICE__c---->'+sheetRec1.buildertek__BL_LIST_PRICE__c);
                                                  sheetRec1.buildertek__BL_LIST_PRICE__c = pricebookRec.UnitPrice;
                                                  sheetRec1.buildertek__BL_UNIT_COST__c = pricebookRec.buildertek__Unit_Cost__c;
                                                  sheetRec1.id = sheetRec1.id;
                                                  selectionList1.add(sheetRec1);
                                              }
                                          }
                                      }  
                                      if(selectionList1.size() > 0){
                                          update selectionList1;
                                      }
                                  }else {
                                      parentBOMCurrency =  'USD';
                                      pricebookentrylistQry = 'select id,Name,CurrencyIsoCode,buildertek__Unit_Cost__c,buildertek__Markup__c,buildertek__Discount__c,UnitPrice, Product2Id,Pricebook2Id from PricebookEntry   where Product2Id IN: proID and Pricebook2Id IN: PriceList AND CurrencyIsoCode=: parentBOMCurrency';
                                      pricebookentrylist1 =  Database.query(pricebookentrylistQry);
                                      if(pricebookentrylist1.size() > 0){
                                          selectionList1 = new list<buildertek__Select_Sheet__c>();
                                          for(PricebookEntry pricebookRec : pricebookentrylist1){
                                              for(buildertek__Select_Sheet__c sheetRec1 : selectionList){
                                                  if(pricebookRec.Product2Id == sheetRec1.buildertek__Product__c &&
                                                          pricebookRec.Pricebook2Id == sheetRec1.BT_Price_Book__c){
                                                      if(PriceList.size() >0 ){
                                                       system.debug('KIOUH:JP:123'+PriceList[0].Id);
                                                          sheetRec1.buildertek__BT_Price_Book__c = PriceList[0].Id;
                                                      }
                                                      sheetRec1.put('CurrencyIsoCode',(String) parentBOMrecord.get('CurrencyIsoCode')); 
                                                      // sheetRec1.CurrencyIsoCode =  parentBOMCurrency;
                                                      sheetRec1.buildertek__BL_MARKUP__c = pricebookRec.buildertek__Markup__c;
                                                      sheetRec1.buildertek__BL_DISCOUNT__c = pricebookRec.buildertek__Discount__c;
                                                              system.debug('pricebookRec.UnitPrice1------>'+pricebookRec.UnitPrice);
                                                             system.debug('sheetRec1.buildertek__BL_LIST_PRICE__c1---->'+sheetRec1.buildertek__BL_LIST_PRICE__c);
                                                      sheetRec1.buildertek__BL_LIST_PRICE__c = pricebookRec.UnitPrice;
                                                      sheetRec1.buildertek__BL_UNIT_COST__c = pricebookRec.buildertek__Unit_Cost__c;
                                                      sheetRec1.id = sheetRec1.id;
                                                      selectionList1.add(sheetRec1);
                                                  }
                                              }
                                              
                                              
                                              
                                              
                                              
                                              
                                              
                                              
                                              
                                              
                                          }  
                                          if(selectionList1.size() > 0){
                                              update selectionList1;
                                          }
                                      }
                                  }
                              }   
                          }else{
                              list<pricebook2> PriceList;
                              PriceList = [select Id, Name
                                           from pricebook2
                                           Where Id IN : pricebookIds AND buildertek__BT_Visible__c = true];
                              list<PricebookEntry> pricebookentrylist1 = [select id,Name,buildertek__Unit_Cost__c,buildertek__Markup__c,buildertek__Discount__c,UnitPrice,
                                                                          Product2Id,Pricebook2Id from PricebookEntry
                                                                          where Product2Id IN: proID and Pricebook2Id IN: PriceList]; 
                                                                          system.debug('#@#@pricebookentrylist3--'+pricebookentrylist1);
                              if(pricebookentrylist1.size() > 0){
                                  for(PricebookEntry pricebookRec : pricebookentrylist1){
                                      for(buildertek__Select_Sheet__c sheetRec1 : selectionList){
                                          if(pricebookRec.Product2Id == sheetRec1.buildertek__Product__c &&
                                                  pricebookRec.Pricebook2Id == sheetRec1.BT_Price_Book__c){
                                                   system.debug('KIOUH:JP:1234'+PriceList[0].Id);
                                              sheetRec1.buildertek__BT_Price_Book__c = pricebookRec.Pricebook2Id;
                                              sheetRec1.buildertek__BL_MARKUP__c = pricebookRec.buildertek__Markup__c;
                                              sheetRec1.buildertek__BL_DISCOUNT__c = pricebookRec.buildertek__Discount__c;
                                                      system.debug('pricebookRec.UnitPrice2------>'+pricebookRec.UnitPrice);
                                                      system.debug('sheetRec1.buildertek__BL_LIST_PRICE__c2---->'+sheetRec1.buildertek__BL_LIST_PRICE__c);
                                              sheetRec1.buildertek__BL_LIST_PRICE__c = pricebookRec.UnitPrice;
                                              sheetRec1.buildertek__BL_UNIT_COST__c = pricebookRec.buildertek__Unit_Cost__c;
                                              sheetRec1.id = sheetRec1.id;
                                              selectionList1.add(sheetRec1);
                                          }
                                      }
                                  }  
                                  if(selectionList1.size() > 0){
                                      update selectionList1;
                                  }
                              }
                          }
                          
                      }
                  }
                  // return searchQueryResult2(recordId, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection, buildPhase, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
                  return searchQueryResult3(recordId, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, filter1,filter2, filter3, selectPriceBook);
              }
              return null;
          } catch (Exception e){
              System.debug('Error Message::' + e.getMessage());
              System.debug('Error Line::' + e.getLineNumber());
              throw new AuraHandledException(e.getMessage());
          }
                                                         }
   
    
    @AuraEnabled
    public static ProductClass searchQueryResult2(String recordId, Integer productPageNumber, Integer productPageSize, Integer pageNumber, Integer pageSize, Integer SSTLPageNumber, 
                                                  Integer SSTLPageSize, String packageLinesSearchTradeType, String packageLinesSearchCategory, String packageLinesSearchProductType,
                                                  String collection, String buildPhase, String tradeType, String category, String productType, String locationSearch, String tradeTypeSSTL,
                                                  String categorySSTL, String productTypeSSTL){
                                                      try{
                                                          ProductClass productClassWrapper = new ProductClass();
                                                          productClassWrapper.takeOffLinesList = new List<buildertek__Project_Takeoff_Lines__c>();
                                                          productClassWrapper.productsRecord = new List<Product2>();
                                                          //Base Query for Product2
                                                          String query = '';
                                                          String filter = '';
                                                          String baseFilter = '';
                                                          Boolean isFieldExist = false;
                                                          Integer productOffset = (productPageNumber - 1) * productPageSize;//For Product
                                                          Integer offset = (pageNumber - 1) * pageSize;//For SSTL
                                                          Integer SSTLOffset = (SSTLPageNumber - 1) * SSTLPageSize;//For SSTL
                                                          
                                                          buildertek__Project_Selection_Sheet_Takeoff__c projectSelectionSheetTakeOff = [Select Id, Name, buildertek__Takeoff__c, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Project__r.buildertek__Project_Tiers__c, buildertek__Project__r.buildertek__Plan_Type__c
                                                                                                                                         FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                                                                                         WHERE Id = :recordId
                                                                                                                                         LIMIT 1];
                                                          system.debug('projectSelectionSheetTakeOff:::::' + projectSelectionSheetTakeOff.buildertek__Takeoff__c);
                                                          if(projectSelectionSheetTakeOff.buildertek__Takeoff__c != null ){
                                                              string takeOffId = projectSelectionSheetTakeOff.buildertek__Takeoff__c;
                                                              system.debug('takeOffId:::::' + takeOffId);
                                                          }
                                                          //TakeOff Lines
                                                          String jsonSerializeFields='';
                                                          buildertek__BOM_Settings__c settingsrec = new buildertek__BOM_Settings__c();
                                                          list<buildertek__BOM_Settings__c>  settingsList = [Select id,buildertek__BOM_Selected_Fields__c
                                                                                                             From buildertek__BOM_Settings__c 
                                                                                                             limit 1];        
                                                          String FieldsDefaultValues =    '[{"label":"Name","value":"Name"}]';
                                                          
                                                          
                                                          if(settingsList.size()>0)
                                                          {//22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222
                                                              
                                                              settingsrec =  settingsList[0]; 
                                                              if(settingsList[0].buildertek__BOM_Selected_Fields__c !=null){
                                                                  jsonSerializeFields = settingsList[0].buildertek__BOM_Selected_Fields__c;      
                                                              } else{
                                                                  jsonSerializeFields = FieldsDefaultValues;
                                                              }                     
                                                              
                                                              
                                                          }//22222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222222         
                                                          else        // if no records, take default values
                                                              // STATUS default values : take all values of a picklist
                                                              // CATEGORIES default values : take all values of a picklist
                                                              // New Ticket default values : 
                                                          {//33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333                                       
                                                              jsonSerializeFields =   FieldsDefaultValues;          
                                                          }//33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
                                                          
                                                          InnSettings Inn = new InnSettings();        
                                                          
                                                          List<fieldWrap> FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(
                                                              jsonSerializeFields,
                                                              List<fieldWrap>.class);
                                                          Inn.TakeOffFieldSettings = FieldsSettings;
                                                          String objectname='buildertek__Project_Takeoff_Lines__c';
                                                          Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
                                                          Schema.SObjectType leadSchema = schemaMap.get(objectname);
                                                          Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();     
                                                          
                                                          list<buildertek__Project_Takeoff_Lines__c> recordsList = new list<buildertek__Project_Takeoff_Lines__c>();
                                                          query = 'SELECT ';
                                                          String fields= ' Id, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name ';
                                                          //'Id, Name, buildertek__Categories__r.Name, buildertek__Product_Type__r.Name, buildertek__Trade_Type__r.Name ';
                                                          for(fieldWrap filedwraprec : FieldsSettings){
                                                              string fieldName = filedwraprec.value;
                                                              Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
                                                              string fldtype = STRING.valueOf(fielddataType);
                                                              if(fldtype == 'REFERENCE' ){
                                                                  if(fieldName.contains('__c')){
                                                                      fieldName = fieldName.replace('__c', '__r.Name');  
                                                                  }
                                                              }
                                                              
                                                              if(fields == ''){
                                                                  fields = fieldName;    
                                                              }else{
                                                                  fields += ' , ' + fieldName;       
                                                              }
                                                          }
                                                          system.debug(fields);
                                                          
                                                          query = query+fields+' FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =:takeOffId ';
                                                          //query = 'Select Id,Name,buildertek__Project_Takeoff__c,buildertek__Categories__c, buildertek__Categories__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Location__c, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Quantity__c,buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =:takeOffId ';
                                                          filter = '';
                                                          isFieldExist = false;
                                                          if (String.isNotBlank(buildPhase)){
                                                              buildPhase = '%' + buildPhase + '%';
                                                              filter += ' AND buildertek__Build_Phase__r.Name LIKE :buildPhase';
                                                              isFieldExist = true;
                                                          }
                                                          if (String.isNotBlank(tradeType)){
                                                              tradeType = '%' + tradeType + '%';
                                                              filter += ' AND buildertek__Trade_Type__r.Name LIKE :tradeType';
                                                              isFieldExist = true;
                                                          }
                                                          if (String.isNotBlank(category)){
                                                              category = '%' + category + '%';
                                                              filter += ' AND buildertek__Categories__r.Name LIKE :category';
                                                              isFieldExist = true;
                                                          }
                                                          if (String.isNotBlank(productType)){
                                                              productType = '%' + productType + '%';
                                                              filter += ' AND buildertek__Product_Type__r.Name LIKE :productType';
                                                              isFieldExist = true;
                                                          }
                                                          if (String.isNotBlank(locationSearch)){
                                                              locationSearch = '%' + locationSearch + '%';
                                                              filter += ' AND buildertek__Location__c LIKE :locationSearch';
                                                              isFieldExist = true;
                                                          }
                                                          query += filter;
                                                          //query = isFieldExist ? query.replace('WHERE  AND', ' WHERE ') : query.replace('WHERE ', '');
                                                          query += ' ORDER BY  buildertek__Trade_Type__r.Name ASC NULLS LAST , buildertek__Categories__r.Name ASC NULLS LAST, buildertek__Product_Type__r.Name ASC NULLS LAST, buildertek__Location__c ASC NULLS LAST, buildertek__Quantity__c ASC NULLS LAST';
                                                          query += ' LIMIT : pageSize OFFSET : offset';
                                                          system.debug('query:11::' + query);
                                                          productClassWrapper.takeOffLinesList = Database.query(query);
                                                          system.debug('productClassWrapper.takeOffLinesList:11::' + productClassWrapper.takeOffLinesList);
                                                          
                                                          query = 'Select COUNT() FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =:takeOffId ' + filter;//Total records with Search Query filter.
                                                          //query = isFieldExist ? query.replace('WHERE  AND', ' WHERE ') : query.replace('WHERE ', '');
                                                          system.debug('query:22::' + query);
                                                          productClassWrapper.totalRecords = Database.countQuery(query);
                                                          if (productClassWrapper.takeOffLinesList.size() > 0){
                                                              //Product2 Query
                                                              query = 'SELECT Id, Name, buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Series__c ,buildertek__Cost_Code__r.Name, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Vendor__r.Name,StockKeepingUnit FROM Product2';
                                                              query += ' WHERE';
                                                              filter = '';
                                                              for (buildertek__Project_Takeoff_Lines__c takeOffLines : productClassWrapper.takeOffLinesList){
                                                                  // filter += takeOffLines.buildertek__Build_Phase__c == null ? ' OR ( buildertek__Build_Phase__c = null' : ' OR ( buildertek__Build_Phase__c =\'' + takeOffLines.buildertek__Build_Phase__c + '\'';
                                                                  filter += takeOffLines.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + takeOffLines.buildertek__Trade_Type__c + '\'';
                                                                  filter += takeOffLines.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + takeOffLines.buildertek__Product_Type__c + '\'';
                                                                  filter += takeOffLines.buildertek__Categories__c == null ? ' AND buildertek__Category__c = null' : ' AND buildertek__Category__c =\'' + takeOffLines.buildertek__Categories__c + '\'';
                                                                  filter += projectSelectionSheetTakeOff.buildertek__Project__r == null || projectSelectionSheetTakeOff.buildertek__Project__r.buildertek__Project_Tiers__c == null ? ' AND buildertek__Collection__c = null' : ' AND buildertek__Collection__c =\'' + projectSelectionSheetTakeOff.buildertek__Project__r.buildertek__Project_Tiers__c + '\'';
                                                                  
                                                                  if (String.isNotBlank(packageLinesSearchTradeType)){
                                                                      packageLinesSearchTradeType = '%' + packageLinesSearchTradeType + '%';
                                                                      filter += ' AND buildertek__Trade_Type__r.Name LIKE :packageLinesSearchTradeType';
                                                                  }
                                                                  if (String.isNotBlank(packageLinesSearchCategory)){
                                                                      packageLinesSearchCategory = '%' + packageLinesSearchCategory + '%';
                                                                      filter += ' AND buildertek__Category__r.Name LIKE :packageLinesSearchCategory';
                                                                  }
                                                                  if (String.isNotBlank(packageLinesSearchProductType)){
                                                                      packageLinesSearchProductType = '%' + packageLinesSearchProductType + '%';
                                                                      filter += ' AND buildertek__Product_Type__r.Name LIKE :packageLinesSearchProductType';
                                                                  }
                                                                  filter += ' ) ' ;
                                                              }
                                                              query += filter;
                                                              query = productClassWrapper.takeOffLinesList.size() > 0 ? query.replace('WHERE OR', 'WHERE ') : query.replace('WHERE', ' ');
                                                              query += ' ORDER BY  buildertek__Trade_Type__r.Name ASC NULLS LAST, buildertek__Category__r.Name ASC NULLS LAST, buildertek__Product_Type__r.Name ASC NULLS LAST';
                                                              query += ' LIMIT : productPageSize OFFSET : productOffset';
                                                              //Retrieve Product2
                                                              System.debug('Product Query : ' + query);
                                                              productClassWrapper.productsRecord = Database.query(query);
                                                              system.debug('productClassWrapper.productsRecord:::::='+productClassWrapper.productsRecord);
                                                              query = 'Select COUNT() FROM Product2 WHERE';
                                                              query += filter;
                                                              query = productClassWrapper.takeOffLinesList.size() > 0 ? query.replace(' WHERE OR ', ' WHERE ') : query.replace(' WHERE', ' ');
                                                              productClassWrapper.productTotalRecords = Database.countQuery(query);
                                                              system.debug('productClassWrapper.productsRecord:::;'+productClassWrapper.productsRecord);
                                                              
                                                          }
                                                          
                                                          //SSTL
                                                          //
                                                          system.debug(recordId);
                                                          if (productClassWrapper.productsRecord.size() > 0){
                                                              query = 'Select Id,Name,buildertek__Selection_Sheet_Takeoff__c, buildertek__Takeoff_Line__c, buildertek__Takeoff_Line__r.Name, buildertek__Location__c, buildertek__Quantity__c,buildertek__Product__c,buildertek__Product__r.Name , buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Vendor__r.Name, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name FROM buildertek__Select_Sheet__c WHERE ';
                                                              filter = '';
                                                              isFieldExist = false;
                                                              //Filter query based on Product2.
                                                              for (Product2 product : productClassWrapper.productsRecord){
                                                                  filter += product.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + product.buildertek__Trade_Type__c + '\'';
                                                                  filter += product.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + product.buildertek__Product_Type__c + '\'';
                                                                  filter += product.buildertek__Category__c == null ? ' AND buildertek__Category__c = null' : ' AND buildertek__Category__c =\'' + product.buildertek__Category__c + '\'';
                                                                  if (String.isNotBlank(tradeTypeSSTL)){
                                                                      tradeTypeSSTL = '%' + tradeTypeSSTL + '%';
                                                                      filter += ' AND buildertek__Trade_Type__r.Name LIKE :tradeTypeSSTL';
                                                                      isFieldExist = true;
                                                                  }
                                                                  if (String.isNotBlank(categorySSTL)){
                                                                      categorySSTL = '%' + categorySSTL + '%';
                                                                      filter += ' AND buildertek__Category__r.Name LIKE :categorySSTL';
                                                                      isFieldExist = true;
                                                                  }
                                                                  if (String.isNotBlank(productTypeSSTL)){
                                                                      productTypeSSTL = '%' + productTypeSSTL + '%';
                                                                      filter += ' AND buildertek__Product_Type__r.Name LIKE :productTypeSSTL';
                                                                      isFieldExist = true;
                                                                  }
                                                                  filter += ' AND  buildertek__Selection_Sheet_Takeoff__c=:recordId )  ';
                                                              }
                                                              query += filter;
                                                              if (productClassWrapper.productsRecord.size() > 0){
                                                                  query = query.replace('WHERE  OR', ' WHERE ');
                                                                  query += ' ORDER BY buildertek__Takeoff_Line__r.Name ASC , buildertek__Build_Phase__r.Name ASC NULLS LAST , buildertek__Trade_Type__r.Name ASC NULLS LAST , buildertek__Category__r.Name ASC NULLS LAST, buildertek__Product_Type__r.Name ASC NULLS LAST,buildertek__Vendor__r.Name ASC NULLS LAST, buildertek__Location__c ASC NULLS LAST';
                                                                  query += ' LIMIT : SSTLPageSize OFFSET : SSTLOffset';
                                                                  productClassWrapper.selectionSheetTakeOffLines = Database.query(query);
                                                                  system.debug(productClassWrapper.selectionSheetTakeOffLines);
                                                                  system.debug(productClassWrapper.selectionSheetTakeOffLines.size());
                                                                  query = 'Select COUNT() FROM buildertek__Select_Sheet__c WHERE ' + filter  ;//Total records with Search Query filter.
                                                                  query = productClassWrapper.productsRecord.size() > 0 ? query.replace('WHERE  OR', ' WHERE ') : query.replace('WHERE ', ' ');
                                                                  productClassWrapper.SSTLTotalRecords = Database.countQuery(query);
                                                              } else{
                                                                  productClassWrapper.selectionSheetTakeOffLines = new List<buildertek__Select_Sheet__c>();
                                                                  productClassWrapper.SSTLTotalRecords = 0;
                                                                  
                                                              }
                                                              
                                                          }
                                                          
                                                          return productClassWrapper;
                                                          
                                                      } catch (Exception e){
                                                          System.debug('Error Message::' + e.getMessage());
                                                          System.debug('Error Line::' + e.getLineNumber());
                                                          throw new AuraHandledException(e.getMessage());
                                                          
                                                      }
                                                  }
    
    @AuraEnabled
    public static ProductClass retrieveProductRecords(String recordId, Integer productPageNumber, Integer productPageSize, Integer pageNumber, 
                                                      Integer pageSize, Integer SSTLPageNumber, Integer SSTLPageSize ,String filter1, String filter2,
                                                      String filter3, String filteredTakeOffLines, String selectPriceBook){
        try{
            
            List<buildertek__Project_Takeoff_Lines__c> filteredTakeOffLineList = (List<buildertek__Project_Takeoff_Lines__c>)JSON.deserialize(filteredTakeOffLines, List<buildertek__Project_Takeoff_Lines__c>.class);
            system.debug('filteredTakeOffLineList::'+filteredTakeOffLineList);
            ProductClass productClassWrapper = new ProductClass();
            productClassWrapper.selectionSheetTakeOffLines = new List<buildertek__Select_Sheet__c>();
            productClassWrapper.takeOffLinesList = new List<buildertek__Project_Takeoff_Lines__c>();
            productClassWrapper.productsRecord = new List<Product2>();
            
            //Base Query for Product2
            
            // with pricebook
            list<pricebook2> PriceList;
            PriceList = [select Id, Name
                         from pricebook2
                         Where Id =: selectPriceBook AND buildertek__BT_Visible__c = true];
            system.debug('selectPriceBook'+selectPriceBook);
            system.debug('&&&&&'+PriceList );
            list<Id> productIds = new list<Id>();
            list<PricebookEntry>  pricebookentrylist = [select id,Name,buildertek__Unit_Cost__c,Product2Id,Pricebook2Id from PricebookEntry
                                                        where /*Product2Id IN:productid AND*/ Pricebook2Id IN: PriceList];
            
            for(PricebookEntry pricebookRec : pricebookentrylist ){
                productIds.add(pricebookRec.Product2Id);
            }            
            list<string> productIdlist = new list<string>(); 
            //productlist = [Select id,Name from Product2 where id IN : productIds];
            
            for(Product2 prodItem : [Select Id,Name from Product2 where Id IN : productIds]){
                productIdlist.add(prodItem.Id);
            }
           
            String query = '';
            String filter = '';
            String baseFilter = '';
            Boolean isFieldExist = false;
            Integer productOffset = (productPageNumber - 1) * productPageSize;//For Product
            Integer offset = (pageNumber - 1) * pageSize;//For SSTL
            Integer SSTLOffset = (SSTLPageNumber - 1) * SSTLPageSize;//For SSTL
            
            buildertek__Project_Selection_Sheet_Takeoff__c projectSelectionSheetTakeOff = [Select Id, Name, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Project__r.buildertek__Project_Tiers__c, buildertek__Project__r.buildertek__Plan_Type__c
                                                                                           FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                                           WHERE Id = :recordId
                                                                                           LIMIT 1];
            if (filteredTakeOffLineList.size() > 0){
                
                String jsonSerializeFields='';
                buildertek__BOM_Settings__c settingsrec = new buildertek__BOM_Settings__c();
                list<buildertek__BOM_Settings__c>  settingsList = [Select id,Name, buildertek__BOM_Selected_Fields__c,
                                                                   buildertek__BOM_Line_Selected_Fileds__c,
                                                                   buildertek__Product_Selected_Fields__c,
                                                                   buildertek__BOM_Line_Filter_Fields__c,
                                                                   buildertek__Takeoff_Filter_Fields__c,
                                                                   buildertek__Product_Filter_Fields__c
                                                                   From buildertek__BOM_Settings__c 
                                                                   limit 1];        
                String FieldsDefaultValues =    '[{"label":"Name","value":"Name"}]';
                
                String jsonSerializeFields1 = '';
                if(settingsList.size()>0) {
                    
                    settingsrec =  settingsList[0]; 
                    // product dynamic fields
                    if(settingsList[0].buildertek__Product_Selected_Fields__c !=null){
                        jsonSerializeFields1 = settingsList[0].buildertek__Product_Selected_Fields__c;      
                    } else{
                        jsonSerializeFields1 = FieldsDefaultValues;
                    }
                    
                    //filter
                    if(settingsList[0].buildertek__Product_Filter_Fields__c !=null){
                        jsonSerializeFields = settingsList[0].buildertek__Product_Filter_Fields__c;      
                    } else{
                        jsonSerializeFields = FieldsDefaultValues;
                    }  
                    
                } else {
                    jsonSerializeFields =   FieldsDefaultValues;      
                    jsonSerializeFields1 = FieldsDefaultValues;
                }
                
                InnSettings Inn = new InnSettings();        
                
                List<fieldWrap> FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(  jsonSerializeFields,  List<fieldWrap>.class);
                Inn.TakeOffFieldSettings = FieldsSettings;
                
                String objectname='Product2';
                Map<String, Schema.SObjectType> schemaMapPTL = Schema.getGlobalDescribe();
                Schema.SObjectType leadSchemaPTL = schemaMapPTL.get(objectname);
                Map<String, Schema.SObjectField> fieldMapPTL = leadSchemaPTL.getDescribe().fields.getMap();     
                
                list<Product2> recordsList = new list<Product2>();
                query = 'SELECT Id, Name, buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c,buildertek__Series__c ,buildertek__Cost_Code__r.Name, buildertek__Trade_Type__r.Name,  buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Vendor__r.Name,StockKeepingUnit ';
                String fields= '';
                //'Id, Name, buildertek__Categories__r.Name, buildertek__Product_Type__r.Name, buildertek__Trade_Type__r.Name ';
                for(fieldWrap filedwraprec : FieldsSettings){
                    string fieldName = filedwraprec.value;
                    Schema.DisplayType fielddataType = fieldMapPTL.get(fieldName).getDescribe().getType();
                    string fldtype = STRING.valueOf(fielddataType);
                    if(fldtype == 'REFERENCE' ){
                        if(fieldName.contains('__c')){
                            fieldName = fieldName.replace('__c', '__r.Name');  
                        }
                    }
                    
                    
                    if(fields.contains(fieldName) == false && query.contains(fieldName) == false && fieldName != 'buildertek__Color__c'){
                        fields += ' , ' + fieldName;    
                    }
                    
                    
                }
                system.debug(fields);
                if(fields.contains('buildertek__Trade_Type__c') == false  && query.contains('buildertek__Trade_Type__c') == false){
                    fields += ' , ' + 'buildertek__Trade_Type__c';
                }
                if(fields.contains('buildertek__Trade_Type__r.Name') == false  && query.contains('buildertek__Trade_Type__r.Name') == false){
                    fields += ' , ' + 'buildertek__Trade_Type__r.Name';
                }
                system.debug(fields);
                
                //product dynamic fiedls
                FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeFields1,List<fieldWrap>.class);
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
                    
                    if(fields.contains(fieldName) == false && query.contains(fieldName) == false && fieldName != 'buildertek__Color__c'){
                        fields += ' , ' + fieldName;    
                    }
                }
                system.debug(fields);
                if(fields.contains('buildertek__Trade_Type__c') == false  && query.contains('buildertek__Trade_Type__c') == false){
                    fields += ' , ' + 'buildertek__Trade_Type__c';
                }
                if(fields.contains('buildertek__Trade_Type__r.Name') == false  && query.contains('buildertek__Trade_Type__r.Name') == false){
                    fields += ' , ' + 'buildertek__Trade_Type__r.Name';
                }
                if(fields.contains('buildertek__Category__r.Name') == false  && query.contains('buildertek__Category__r.Name') == false){
                    fields += ' , ' + 'buildertek__Category__r.Name';
                }
                if(fields.contains('buildertek__Product_Type__r.Name') == false  && query.contains('buildertek__Product_Type__r.Name') == false){
                    fields += ' , ' + 'buildertek__Product_Type__r.Name';
                }
                
                query = query+fields+' FROM Product2 ';
                
                
                
                
                //Product2 Query
                //  query = 'SELECT Id, Name, buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c,buildertek__Series__c ,buildertek__Cost_Code__r.Name, buildertek__Trade_Type__r.Name,  buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Vendor__r.Name,StockKeepingUnit FROM Product2';
                query += ' WHERE';
                filter = '';
                filter += filter2;
                if (String.isNotBlank(selectPriceBook)){
                    
                    filter += ' AND Id IN: productIdlist';
                }
                //for (buildertek__Project_Takeoff_Lines__c takeOffLines : filteredTakeOffLineList){
                    
                   // System.debug(' takeOffLines.buildertek__Trade_Type__c : ' +takeOffLines.buildertek__Trade_Type__c == 'No Grouping');
                   
                    /* String tradeType = takeOffLines.buildertek__Trade_Type__c;
                    if(takeOffLines.buildertek__Trade_Type__c == null){
                        filter += takeOffLines.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + takeOffLines.buildertek__Trade_Type__c + '\'';
                    }else if (tradeType == 'No Grouping'){
                        filter += ' OR ( buildertek__Trade_Type__c = null';
                    }else{
                         filter += takeOffLines.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + takeOffLines.buildertek__Trade_Type__c + '\'';
                    }
                    //filter += takeOffLines.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + takeOffLines.buildertek__Trade_Type__c + '\'';
                    filter += takeOffLines.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + takeOffLines.buildertek__Product_Type__c + '\'';
                    filter += takeOffLines.buildertek__Categories__c == null ? ' AND buildertek__Category__c = null' : ' AND buildertek__Category__c =\'' + takeOffLines.buildertek__Categories__c + '\'';
                    filter += projectSelectionSheetTakeOff.buildertek__Project__r == null || projectSelectionSheetTakeOff.buildertek__Project__r.buildertek__Project_Tiers__c == null ? ' AND buildertek__Collection__c = null' : ' AND buildertek__Collection__c =\'' + projectSelectionSheetTakeOff.buildertek__Project__r.buildertek__Project_Tiers__c + '\'';*/
                    
                    /*filter += takeOffLines.buildertek__Product_Type__c == null ? ' OR ((buildertek__Product_Type__c = null' : ' OR (( buildertek__Product_Type__c =\'' + takeOffLines.buildertek__Product_Type__c + '\'';
                    filter += takeOffLines.buildertek__Category__c == null ? ' OR buildertek__Category__c = null)' : ' OR buildertek__Category__r.Name =\'' + takeOffLines.buildertek__Category__c + '\')';
                    */
                    
                    /*if (String.isNotBlank(packageLinesSearchTradeType)){
                        packageLinesSearchTradeType = '%' + packageLinesSearchTradeType + '%';
                        filter += ' AND buildertek__Trade_Type__r.Name LIKE :packageLinesSearchTradeType';
                        }
                        if (String.isNotBlank(packageLinesSearchCategory)){
                        packageLinesSearchCategory = '%' + packageLinesSearchCategory + '%';
                        filter += ' AND buildertek__Category__r.Name LIKE :packageLinesSearchCategory';
                        }
                        if (String.isNotBlank(packageLinesSearchProductType)){
                        packageLinesSearchProductType = '%' + packageLinesSearchProductType + '%';
                        filter += ' AND buildertek__Product_Type__r.Name LIKE :packageLinesSearchProductType';
                        }*/
                    
                    
                    /*filter += filter2;
                    if (String.isNotBlank(selectPriceBook)){
                        
                        filter += ' AND Id IN: productIdlist';
                    }
                    
                    
                    filter += ' ) ';*/
               // }
                query += filter;
                if (String.isNotBlank(filter) == false){
                     System.debug('filter Query : ' + String.isNotBlank(filter));
                    query = query.replace('WHERE', '');
                     System.debug('Product Query : ' + query);
                 }else if (String.isNotBlank(filter)){
                     query =  query.replace('WHERE AND', 'WHERE ');
                 }
                //query = filteredTakeOffLineList.size() > 0 ? query.replace('WHERE OR', 'WHERE ') : query.replace('WHERE', ' ');
                query =  query.replace('WHERE AND', 'WHERE ');
                query += ' ORDER BY buildertek__Trade_Type__r.Name ASC NULLS LAST, buildertek__Category__r.Name ASC NULLS LAST, buildertek__Product_Type__r.Name ASC NULLS LAST';
                query += ' LIMIT : productPageSize OFFSET : productOffset';
                //Retrieve Product2
                System.debug('Product Query : ' + query);
                productClassWrapper.productsRecord = Database.query(query);
                query = 'Select COUNT() FROM Product2 WHERE';
                query += filter;
                if (String.isNotBlank(filter) == false){
                    System.debug('filter Query : ' + String.isNotBlank(filter));
                    query = query.replace('WHERE', '');
                    System.debug('Product Query : ' + query);
                }else if (String.isNotBlank(filter)){
                    query =  query.replace('WHERE AND', 'WHERE ');
                }
                //query = filteredTakeOffLineList.size() > 0 ? query.replace(' WHERE OR ', ' WHERE ') : query.replace(' WHERE', ' ');
                productClassWrapper.productTotalRecords = Database.countQuery(query);
                
                if (productClassWrapper.productsRecord.size() > 0){
                    //SSTL
                    
                    if(settingsList.size()>0) {
                        
                        settingsrec =  settingsList[0]; 
                        // bom line fileds
                        if(settingsList[0].buildertek__BOM_Line_Selected_Fileds__c !=null){
                            jsonSerializeFields1 = settingsList[0].buildertek__BOM_Line_Selected_Fileds__c;      
                        } else{
                            jsonSerializeFields1 = FieldsDefaultValues;
                        }
                        
                        // bom line filters
                        if(settingsList[0].buildertek__BOM_Line_Filter_Fields__c !=null){
                            jsonSerializeFields = settingsList[0].buildertek__BOM_Line_Filter_Fields__c;      
                        } else{
                            jsonSerializeFields = FieldsDefaultValues;
                        }  
                        
                    } else {
                        jsonSerializeFields =   FieldsDefaultValues;  
                        jsonSerializeFields1 = FieldsDefaultValues;
                    }
                    
                     Inn = new InnSettings();        
                    
                     FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeFields,  List<fieldWrap>.class);
                    Inn.TakeOffFieldSettings = FieldsSettings;
                    
                    objectname='buildertek__Select_Sheet__c';
                    schemaMapPTL = Schema.getGlobalDescribe();
                    leadSchemaPTL = schemaMapPTL.get(objectname);
                    fieldMapPTL = leadSchemaPTL.getDescribe().fields.getMap();     

                    query = 'Select Id,Name,buildertek__Selection_Sheet_Takeoff__c,buildertek__Product__r.Name,buildertek__Takeoff_Line__r.Name, buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Location__c, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name ';
                    fields= '';
                    //'Id, Name, buildertek__Categories__r.Name, buildertek__Product_Type__r.Name, buildertek__Trade_Type__r.Name ';
                    for(fieldWrap filedwraprec : FieldsSettings){
                        string fieldName = filedwraprec.value;
                        Schema.DisplayType fielddataType = fieldMapPTL.get(fieldName).getDescribe().getType();
                        string fldtype = STRING.valueOf(fielddataType);
                        if(fldtype == 'REFERENCE' ){
                            if(fieldName.contains('__c')){
                                fieldName = fieldName.replace('__c', '__r.Name');  
                            }
                        }
                        
                        if(fields.contains(fieldName) == false && query.contains(fieldName) == false){
                            fields += ' , ' + fieldName;    
                        }
                        
                    }
                    system.debug(fields);
                    if(fields.contains('buildertek__Trade_Type__c') == false  && query.contains('buildertek__Trade_Type__c') == false){
                        fields += ' , ' + 'buildertek__Trade_Type__c';
                    }
                    if(fields.contains('buildertek__Trade_Type__r.Name') == false  && query.contains('buildertek__Trade_Type__c') == false){
                        fields += ' , ' + 'buildertek__Trade_Type__r.Name';
                    }
                    system.debug(fields);
                    
                    //bom line dynamic fiedls
                    FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeFields1,List<fieldWrap>.class);
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
                        
                        if(fields.contains(fieldName) == false && query.contains(fieldName) == false){
                            fields += ' , ' + fieldName;    
                        }
                    }
                    system.debug(fields);
                    if(fields.contains('buildertek__Trade_Type__c') == false  && query.contains('buildertek__Trade_Type__c') == false){
                        fields += ' , ' + 'buildertek__Trade_Type__c';
                    }
                    if(fields.contains('buildertek__Trade_Type__r.Name') == false  && query.contains('buildertek__Trade_Type__r.Name') == false){
                        fields += ' , ' + 'buildertek__Trade_Type__r.Name';
                    }
                    if(fields.contains('buildertek__Build_Phase__r.Name') == false  && query.contains('buildertek__Build_Phase__r.Name') == false){
                        fields += ' , ' + 'buildertek__Build_Phase__r.Name';
                    }
                    if(fields.contains('buildertek__Category__r.Name') == false  && query.contains('buildertek__Category__r.Name') == false){
                        fields += ' , ' + 'buildertek__Category__r.Name';
                    }  
                    if(fields.contains('buildertek__Product_Type__r.Name') == false  && query.contains('buildertek__Product_Type__r.Name') == false){
                        fields += ' , ' + 'buildertek__Product_Type__r.Name';
                    }
                    if(fields.contains('buildertek__Vendor__r.Name') == false  && query.contains('buildertek__Vendor__r.Name') == false){
                        fields += ' , ' + 'buildertek__Vendor__r.Name';
                    } 
                    if(fields.contains('buildertek__Location__c') == false  && query.contains('buildertek__Location__c') == false){
                        fields += ' , ' + 'buildertek__Location__c';
                    }
                    
                    
                    query = query+fields+'  FROM buildertek__Select_Sheet__c WHERE ';
                    

                    
                    
                   // query = 'Select Id,Name,buildertek__Selection_Sheet_Takeoff__c,buildertek__Product__r.Name,buildertek__Takeoff_Line__r.Name, buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Location__c, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name FROM buildertek__Select_Sheet__c WHERE ';
                    filter = '';
                    isFieldExist = false;
                    filter += filter3;
                    if (String.isNotBlank(filter) == false){
                        filter += ' buildertek__Selection_Sheet_Takeoff__c=:recordId  AND buildertek__Takeoff_Line__c IN: filteredTakeOffLineList ';
                    }else{
                        filter += ' AND  buildertek__Selection_Sheet_Takeoff__c=:recordId   AND buildertek__Takeoff_Line__c IN: filteredTakeOffLineList ';
                    }
                    //Filter query based on Product2.
                  //  for (Product2 product : productClassWrapper.productsRecord){
                       /*filter += product.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + product.buildertek__Trade_Type__c + '\'';
                        filter += product.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + product.buildertek__Product_Type__c + '\'';
                        filter += product.buildertek__Category__c == null ? ' AND buildertek__Category__c = null' : ' AND buildertek__Category__c =\'' + product.buildertek__Category__c + '\'';*/
                        
                        
                       /* filter += product.buildertek__Product_Type__c == null ? ' OR ((buildertek__Product_Type__c = null' : ' OR ((buildertek__Product_Type__c =\'' + product.buildertek__Product_Type__c + '\'';
                        filter += product.buildertek__Category__c == null ? ' OR buildertek__Category__c = null)' : ' AND buildertek__Category__c =\'' + product.buildertek__Category__c + '\')';*/

                        /*if (String.isNotBlank(tradeTypeSSTL)){
                            tradeTypeSSTL = '%' + tradeTypeSSTL + '%';
                            filter += ' AND buildertek__Trade_Type__r.Name LIKE :tradeTypeSSTL';
                            isFieldExist = true;
                            }
                            if (String.isNotBlank(categorySSTL)){
                            categorySSTL = '%' + categorySSTL + '%';
                            filter += ' AND buildertek__Category__r.Name LIKE :categorySSTL';
                            isFieldExist = true;
                            }
                            if (String.isNotBlank(productTypeSSTL)){
                            productTypeSSTL = '%' + productTypeSSTL + '%';
                            filter += ' AND buildertek__Product_Type__r.Name LIKE :productTypeSSTL';
                            isFieldExist = true;
                            }*/
                        
                        
                       /* filter += filter3;
                      
                        filter += '  AND  buildertek__Selection_Sheet_Takeoff__c=:recordId AND buildertek__Takeoff_Line__c IN: filteredTakeOffLineList) '; */
                  //  }
                    query += filter;
                    if (productClassWrapper.productsRecord.size() > 0){
                        if (String.isNotBlank(filter) == false){
                            query =  query.replace('WHERE', ' ');
                        }else if (String.isNotBlank(filter)){
                            query =  query.replace('WHERE  AND', 'WHERE');
                        }
                       // query = query.replace('WHERE  OR', ' WHERE ');
                        query += ' ORDER BY buildertek__Takeoff_Line__r.Name ASC , buildertek__Trade_Type__r.Name ASC NULLS LAST , buildertek__Category__r.Name ASC NULLS LAST, buildertek__Product_Type__r.Name ASC NULLS LAST,buildertek__Vendor__r.Name ASC NULLS LAST, buildertek__Location__c ASC NULLS LAST';
                        query += ' LIMIT : SSTLPageSize OFFSET : SSTLOffset';
                        system.debug(query);
                        productClassWrapper.selectionSheetTakeOffLines = Database.query(query);
                        query = 'Select COUNT() FROM buildertek__Select_Sheet__c WHERE ' + filter;//Total records with Search Query filter.
                        if (String.isNotBlank(filter) == false){
                            query =  query.replace('WHERE', ' ');
                        }else if (String.isNotBlank(filter)){
                            query =  query.replace('WHERE  AND', 'WHERE');
                        }
                       // query = productClassWrapper.productsRecord.size() > 0 ? query.replace('WHERE  OR', ' WHERE ') : query.replace('WHERE ', ' ');
                        productClassWrapper.SSTLTotalRecords = Database.countQuery(query);
                    } else{
                        productClassWrapper.selectionSheetTakeOffLines = new List<buildertek__Select_Sheet__c>();
                        productClassWrapper.SSTLTotalRecords = 0;
                    }
                    
                }
                
            }
            
            
            return productClassWrapper;
        } catch (Exception e){
            System.debug('Error Message::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
                                                      }
    
    @AuraEnabled
    public static ProductClass deleteSelectedSSTLRecord(String recordId, Integer productPageNumber, Integer productPageSize, Integer pageNumber, 
                                                        Integer pageSize, Integer SSTLPageNumber, Integer SSTLPageSize, String filter1, String filter2,
                                                        String filter3, String deleteSSTLIds,String selectPriceBook){
                                                            try{
                                                                System.debug('Delete Id::' + deleteSSTLIds);
                                                                if (String.isNotBlank(deleteSSTLIds)){
                                                                    delete [Select Id
                                                                            FROM buildertek__Select_Sheet__c
                                                                            WHERE ID = :deleteSSTLIds];
                                                                }
                                                                list<buildertek__Select_Sheet__c> bomLines = [select Id, Name,buildertek__Takeoff_Line__c,buildertek__Takeoff_Line__r.Name,buildertek__Takeoff_Line__r.buildertek__Project_Takeoff__c,
                                                                                                              buildertek__Takeoff_Line__r.buildertek__Quantity__c
                                                                                                              from buildertek__Select_Sheet__c  where buildertek__Selection_Sheet_Takeoff__c =:recordId];
                                                                list<id> selectsheetid = new list<id>();
                                                                list<buildertek__Select_Sheet__c> sheetlist = new list<buildertek__Select_Sheet__c>();
                                                                if(bomLines.size()>0){
                                                                    list<buildertek__Project_Takeoff_Lines__c> takeofflines = [select Id, Name,buildertek__Project_Takeoff__c,buildertek__Suppress_Record__c,buildertek__Quantity__c
                                                                                                                               from buildertek__Project_Takeoff_Lines__c where 
                                                                                                                               buildertek__Project_Takeoff__c =: bomLines[0].buildertek__Takeoff_Line__r.buildertek__Project_Takeoff__c AND 
                                                                                                                               buildertek__Suppress_Record__c = 'No'];
                                                                    for(buildertek__Select_Sheet__c sheetRec : bomLines){
                                                                        for(buildertek__Project_Takeoff_Lines__c takeoffRec : takeofflines){
                                                                            if(sheetRec.buildertek__Takeoff_Line__c == takeoffRec.Id){
                                                                                sheetRec.buildertek__Quantity__c = takeoffRec.buildertek__Quantity__c;
                                                                                sheetRec.buildertek__QunUpdate__c = false;
                                                                                sheetlist.add(sheetRec);
                                                                            }
                                                                        }
                                                                    }
                                                                    if(sheetlist.size()>0){
                                                                        Update sheetlist;
                                                                    }
                                                                }
                                                                return searchQueryResult3(recordId, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, filter1,filter2, filter3,selectPriceBook);
                                                                //return searchQueryResult2(recordId, productPageNumber, productPageSize, pageNumber, pageSize, SSTLPageNumber, SSTLPageSize, packageLinesSearchTradeType, packageLinesSearchCategory, packageLinesSearchProductType, collection,buildPhase, tradeType, category, productType, locationSearch, tradeTypeSSTL, categorySSTL, productTypeSSTL);
                                                            } catch (Exception e){
                                                                System.debug('Error Message::' + e.getMessage());
                                                                System.debug('Error Line::' + e.getLineNumber());
                                                                throw new AuraHandledException(e.getMessage());
                                                            }
                                                        }
    
    //Get All products
    @AuraEnabled
    public static String getImages(String recordId){
        try{
            if (String.isNotBlank(recordId)){
                Set<Id> conDocIdSet = new Set<Id>();
                for (ContentDocumentLink contDocLink : [Select Id, ContentDocumentId
                                                        FROM ContentDocumentLink
                                                        WHERE LinkedEntityId = :recordId]){
                                                            conDocIdSet.add(contDocLink.ContentDocumentId);
                                                        }
                if (conDocIdSet.size() > 0){
                    List<ContentVersion> conVerRecords = [Select Id
                                                          FROM ContentVersion
                                                          WHERE ContentDocumentId In :conDocIdSet AND FileExtension != 'pdf'];
                    return conVerRecords.size() > 0 ? JSON.serialize(conVerRecords) : '[]';
                }
            }
            return null;
        } catch (Exception e){
            System.debug('Error Message::' + e.getMessage());
            System.debug('Error Line::' + e.getLineNumber());
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    
    
    
    
    
    
    //dynamic filter 
    @AuraEnabled
    public static ProductClass searchQueryResult3(String recordId, Integer productPageNumber, Integer productPageSize, Integer pageNumber, Integer pageSize, Integer SSTLPageNumber, 
                                                  Integer SSTLPageSize,string filter1, string filter2,  string filter3,String selectPriceBook ){
                                                      // String packageLinesSearchTradeType, String packageLinesSearchCategory, String packageLinesSearchProductType,String collection,
        //  try{
                           
             //pricebook
             list<pricebook2> PriceList;
             PriceList = [select Id, Name
                          from pricebook2
                          Where Id =: selectPriceBook AND buildertek__BT_Visible__c = true];
             system.debug('selectPriceBook'+selectPriceBook);
             system.debug('&&&&&'+PriceList );
             list<Id> productIds = new list<Id>();
             list<PricebookEntry>  pricebookentrylist = [select id,Name,buildertek__Unit_Cost__c,Product2Id,Pricebook2Id from PricebookEntry
                                                         where /*Product2Id IN:productid AND*/ Pricebook2Id IN: PriceList];
             
             for(PricebookEntry pricebookRec : pricebookentrylist ){
                 productIds.add(pricebookRec.Product2Id);
             }            
             list<string> productIdlist = new list<string>(); 
          //   productlist = [Select id,Name from Product2 where id IN : productIds];
             
             for(Product2 productItem : [Select Id,Name from Product2 where Id IN : productIds]){
                 productIdlist.add(productItem.Id);
             }
             
             ProductClass productClassWrapper = new ProductClass();
             productClassWrapper.takeOffLinesList = new List<buildertek__Project_Takeoff_Lines__c>();
             productClassWrapper.productsRecord = new List<Product2>();
             //Base Query for Product2
             String query = '';
             String filter = '';
             String baseFilter = '';
             Boolean isFieldExist = false;
             Integer productOffset = (productPageNumber - 1) * productPageSize;//For Product
             Integer offset = (pageNumber - 1) * pageSize;//For SSTL
             Integer SSTLOffset = (SSTLPageNumber - 1) * SSTLPageSize;//For SSTL
             
             buildertek__Project_Selection_Sheet_Takeoff__c projectSelectionSheetTakeOff = [Select Id, Name, buildertek__Takeoff__c, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Project__r.buildertek__Project_Tiers__c, buildertek__Project__r.buildertek__Plan_Type__c
                                                                                            FROM buildertek__Project_Selection_Sheet_Takeoff__c
                                                                                            WHERE Id = :recordId
                                                                                            LIMIT 1];
             system.debug('projectSelectionSheetTakeOff:::::' + projectSelectionSheetTakeOff.buildertek__Takeoff__c);
             if(projectSelectionSheetTakeOff.buildertek__Takeoff__c != null ){
                 string takeOffId = projectSelectionSheetTakeOff.buildertek__Takeoff__c;
                 system.debug('takeOffId:::::' + takeOffId);
             }
             //TakeOff Lines
             
             // query BOM Lines
             list<Id> takeofflineslist = new list<Id>();
             list<buildertek__Select_Sheet__c> sheetlist = [select id,Name,buildertek__Selection_Sheet_Takeoff__c,buildertek__Takeoff_Line__c from buildertek__Select_Sheet__c where buildertek__Selection_Sheet_Takeoff__c =: recordId];
             for(buildertek__Select_Sheet__c sheetrec : sheetlist ){
                 takeofflineslist.add(sheetrec.buildertek__Takeoff_Line__c);
             }
             
             
             // dynamic query for filter and field
             String jsonSerializeFields='';
             String jsonSerializeFields1='';
             buildertek__BOM_Settings__c settingsrec = new buildertek__BOM_Settings__c();
             list<buildertek__BOM_Settings__c>  settingsList = [Select id,Name, buildertek__BOM_Selected_Fields__c,
                                                                buildertek__BOM_Line_Selected_Fileds__c,
                                                                buildertek__Product_Selected_Fields__c,
                                                                buildertek__BOM_Line_Filter_Fields__c,
                                                                buildertek__Takeoff_Filter_Fields__c,
                                                                buildertek__Product_Filter_Fields__c
                                                                From buildertek__BOM_Settings__c 
                                                                limit 1];        
             String FieldsDefaultValues =    '[{"label":"Name","value":"Name"}]';
             
             
             if(settingsList.size()>0)  {
                 
                 settingsrec =  settingsList[0]; 
                 if(settingsList[0].buildertek__BOM_Selected_Fields__c !=null){
                     jsonSerializeFields = settingsList[0].buildertek__BOM_Selected_Fields__c;      
                 } else{
                     jsonSerializeFields = FieldsDefaultValues;
                 }
                 if(settingsList[0].buildertek__Takeoff_Filter_Fields__c !=null){
                     jsonSerializeFields1 = settingsList[0].buildertek__Takeoff_Filter_Fields__c;      
                 } else{
                     jsonSerializeFields1 = FieldsDefaultValues;
                 }
                 
                 
             }
             else  {//33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333                                       
                 jsonSerializeFields =   FieldsDefaultValues;          
                 jsonSerializeFields1 =   FieldsDefaultValues;          
             }//33333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333333
             
             InnSettings Inn = new InnSettings();        
             
             List<fieldWrap> FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(
                 jsonSerializeFields,
                 List<fieldWrap>.class);
             Inn.TakeOffFieldSettings = FieldsSettings;
             
             String objectname='buildertek__Project_Takeoff_Lines__c';
             Map<String, Schema.SObjectType> schemaMapPTL = Schema.getGlobalDescribe();
             Schema.SObjectType leadSchemaPTL = schemaMapPTL.get(objectname);
             Map<String, Schema.SObjectField> fieldMapPTL = leadSchemaPTL.getDescribe().fields.getMap();     
             
             list<buildertek__Project_Takeoff_Lines__c> recordsList = new list<buildertek__Project_Takeoff_Lines__c>();
             query = 'SELECT ';
             String fields= ' Id ';
             //'Id, Name, buildertek__Categories__r.Name, buildertek__Product_Type__r.Name, buildertek__Trade_Type__r.Name ';
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
                     fields += ' , ' + fieldName;       
                 }
             }
             system.debug(fields);
             
             // filter fields
             FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(
                 jsonSerializeFields1,
                 List<fieldWrap>.class);
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
             if(fields.contains('buildertek__Trade_Type__c') == false){
                 fields += ' , ' + 'buildertek__Trade_Type__c ';
             }
             if(fields.contains('buildertek__Trade_Type__r.Name') == false){
                 fields += ' , ' + 'buildertek__Trade_Type__r.Name ';
             }
             if(fields.contains('buildertek__Category__c') == false){
                 fields += ' , ' + 'buildertek__Category__c ';
             }
             if(fields.contains('buildertek__Categories__c') == false){
                 fields += ' , ' + 'buildertek__Categories__c ';
             }
             if(fields.contains('buildertek__Categories__r.Name') == false){
                 fields += ' , ' + 'buildertek__Categories__r.Name ';
             }
             if(fields.contains('buildertek__Product_Type__c') == false){
                 fields += ' , ' + 'buildertek__Product_Type__c ';
             }
             if(fields.contains('buildertek__Product_Type__r.Name') == false){
                 fields += ' , ' + 'buildertek__Product_Type__r.Name ';
             }
             if(fields.contains('buildertek__Location__c') == false){
                 fields += ' , ' + 'buildertek__Location__c ';
             }
             if(fields.contains('buildertek__Quantity__c') == false){
                 fields += ' , ' + 'buildertek__Quantity__c ';
             }
             if(fields.contains('buildertek__Project_Takeoff__c') == false){
                fields += ' , ' + 'buildertek__Project_Takeoff__c ';
             }
             
             system.debug(fields);
             string suppressrecord = 'Yes';
            //  System.debug('takeOffId=='+takeOffId);
             System.debug('takeOsuppressrecordffId=='+suppressrecord);
             query = query+fields+' FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =:takeOffId AND buildertek__Suppress_Record__c !=: suppressrecord ';
             
             //query = 'Select Id,Name,buildertek__Project_Takeoff__c,buildertek__Categories__c, buildertek__Categories__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Location__c, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Quantity__c,buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name,createddate,lastmodifieddate FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =:takeOffId ';
             filter = '';
             isFieldExist = false;
             
             filter += filter1; 
             
            /* if (recordId != '' && recordId != null){
                filter += ' AND Id NOT IN: takeofflineslist';
                //isFieldExist = true;
            }*/
             
             isFieldExist = true;
                  /*if (String.isNotBlank(buildPhase)){
                        buildPhase = '%' + buildPhase + '%';
                        filter += ' AND buildertek__Build_Phase__r.Name LIKE :buildPhase';
                        isFieldExist = true;
                        }*/
                                                                                  /* if (String.isNotBlank(tradeType)){
                        tradeType = '%' + tradeType + '%';
                        filter += ' AND buildertek__Trade_Type__r.Name LIKE :tradeType';
                        isFieldExist = true;
                        }*/
                                                                                  /*if (String.isNotBlank(category)){
                        category = '%' + category + '%';
                        filter += ' AND buildertek__Categories__r.Name LIKE :category';
                        isFieldExist = true;
                        }*/
                                                                                  /*if (String.isNotBlank(productType)){
                        productType = '%' + productType + '%';
                        filter += ' AND buildertek__Product_Type__r.Name LIKE :productType';
                        isFieldExist = true;
                        }*/
                                                                                  /* if (String.isNotBlank(locationSearch)){
                        locationSearch = '%' + locationSearch + '%';
                        filter += ' AND buildertek__Location__c LIKE :locationSearch';
                        isFieldExist = true;
                        }*/
             query += filter;
             //query = isFieldExist ? query.replace('WHERE  AND', ' WHERE ') : query.replace('WHERE ', '');
            query += ' ORDER BY  Name ASC NULLS LAST , buildertek__Trade_Type__r.Name ASC NULLS LAST , buildertek__Categories__r.Name ASC NULLS LAST,  buildertek__Location__c ASC NULLS LAST, buildertek__Quantity__c ASC NULLS LAST';
            // query += ' ORDER BY  Name ASC ';
             query += ' LIMIT : pageSize OFFSET : offset';
             system.debug('query:11::' + query);
            List<string> idlist = new List<string>();
             map<Id,List<buildertek__Select_Sheet__c>> Bommap =new map<Id,List<buildertek__Select_Sheet__c>>();

             for(buildertek__Project_Takeoff_Lines__c take :Database.query(query)){
                 idlist.add(take.Id);
             }
             List<buildertek__Select_Sheet__c> bomlines = [select id,Name,buildertek__Takeoff_Line__c from buildertek__Select_Sheet__c where buildertek__Takeoff_Line__c IN:idlist AND buildertek__Selection_Sheet_Takeoff__c =:recordId];
             for(buildertek__Select_Sheet__c line:bomlines){
                 if(Bommap.containsKey(line.buildertek__Takeoff_Line__c)){
                      Bommap.get(line.buildertek__Takeoff_Line__c).add(line);
                 }else{
                     Bommap.put(line.buildertek__Takeoff_Line__c,new List<buildertek__Select_Sheet__c>{line});
                 }
             }
             List<buildertek__Project_Takeoff_Lines__c> takeoffList = Database.query(query);
             Map<String, Set<Id>> valueSetIdMap = new Map<String, Set<Id>>();
             valueSetIdMap.put('true', new Set<Id>());
             valueSetIdMap.put('false', new Set<Id>());
             valueSetIdMap.put('null', new Set<Id>());

              for(buildertek__Project_Takeoff_Lines__c take :takeoffList){
                  if(Bommap.get(take.Id) != null){
                      if(Bommap.get(take.Id).size() > 0){
                          take.buildertek__IsBOMLines__c = true;
                          Set<Id> takeOffIds = valueSetIdMap.get('true');
                          takeOffIds.add(take.Id);
                          valueSetIdMap.put('true', takeOffIds);
                      }else{
                          take.buildertek__IsBOMLines__c = false;
                          Set<Id> takeOffIds = valueSetIdMap.get('false');
                          takeOffIds.add(take.Id);
                          valueSetIdMap.put('false', takeOffIds);
                      }

                  }
                  else{

                        take.buildertek__IsBOMLines__c = false;
                        Set<Id> takeOffIds = valueSetIdMap.get('false');
                        takeOffIds.add(take.Id);
                        valueSetIdMap.put('false', takeOffIds);
                    }

             }

             System.debug('** takeoffList  --------------------------------->: '+ takeoffList.size()+ '--:' + JSON.serialize(takeoffList));
             Map<Id, buildertek__Project_Takeoff_Lines__c> takeoffListMap =
                    new Map<Id, buildertek__Project_Takeoff_Lines__c>(takeoffList);
             productClassWrapper.takeOffLinesList =
                orderTakeOffs(
                    takeoffList,
                    valueSetIdMap,
                    takeoffListMap
                );// Database.query(query);

            System.debug('** productClassWrapper.takeOffLinesList  --------------------------------->: '+ productClassWrapper.takeOffLinesList.size()+ '--:' + JSON.serialize(productClassWrapper.takeOffLinesList));
             
             
             system.debug('productClassWrapper.takeOffLinesList:11::' + productClassWrapper.takeOffLinesList);
             
             query = 'Select COUNT() FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =:takeOffId  AND buildertek__Suppress_Record__c !=: suppressrecord ' + filter;//Total records with Search Query filter.
             //query = isFieldExist ? query.replace('WHERE  AND', ' WHERE ') : query.replace('WHERE ', '');
             system.debug('query:22::' + query);
             productClassWrapper.totalRecords = Database.countQuery(query);
             
             // dynamic product query for filter
             if(settingsList.size()>0)  {
                 settingsrec =  settingsList[0]; 
                 // dynamic product field
                 if(settingsList[0].buildertek__Product_Selected_Fields__c !=null){
                     jsonSerializeFields1 = settingsList[0].buildertek__Product_Selected_Fields__c;      
                 } else{
                     jsonSerializeFields1 = FieldsDefaultValues;
                 }
                 // filter
                 if(settingsList[0].buildertek__Product_Filter_Fields__c !=null){
                     jsonSerializeFields = settingsList[0].buildertek__Product_Filter_Fields__c;      
                 } else{
                     jsonSerializeFields = FieldsDefaultValues;
                 }
             }
             else{
                 jsonSerializeFields =   FieldsDefaultValues;
                 jsonSerializeFields1 = FieldsDefaultValues;
             }
             
             Inn = new InnSettings();        
             
             FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeFields,List<fieldWrap>.class);
             Inn.TakeOffFieldSettings = FieldsSettings;
             
             objectname='Product2';
             schemaMapPTL = Schema.getGlobalDescribe();
             leadSchemaPTL = schemaMapPTL.get(objectname);
             fieldMapPTL = leadSchemaPTL.getDescribe().fields.getMap();     
             query = 'SELECT Id, Name,buildertek__Collection__c, buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Series__c ,buildertek__Cost_Code__r.Name, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Vendor__r.Name,StockKeepingUnit ';
             fields= '';
             // filter
             for(fieldWrap filedwraprec : FieldsSettings){
                 string fieldName = filedwraprec.value;
                 Schema.DisplayType fielddataType = fieldMapPTL.get(fieldName).getDescribe().getType();
                 string fldtype = STRING.valueOf(fielddataType);
                 if(fldtype == 'REFERENCE' ){
                     if(fieldName.contains('__c')){
                         fieldName = fieldName.replace('__c', '__r.Name');  
                     }
                 }
                 
                 if(fields.contains(fieldName) == false && query.contains(fieldName) == false && fieldName != 'buildertek__Color__c'){
                     fields += ' , ' + fieldName;    
                 }
             }
             system.debug(fields);
             if(fields.contains('buildertek__Trade_Type__c') == false  && query.contains('buildertek__Trade_Type__c') == false){
                 fields += ' , ' + 'buildertek__Trade_Type__c';
             }
             if(fields.contains('buildertek__Trade_Type__r.Name') == false  && query.contains('buildertek__Trade_Type__r.Name') == false){
                 fields += ' , ' + 'buildertek__Trade_Type__r.Name';
             }
             system.debug(fields);
             
             // dynamic product field
             FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeFields1,List<fieldWrap>.class);
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
                 
                 if(fields.contains(fieldName) == false && query.contains(fieldName) == false && fieldName != 'buildertek__Color__c'){
                     fields += ' , ' + fieldName;    
                 }
             }
             system.debug(fields);
             if(fields.contains('buildertek__Trade_Type__c') == false  && query.contains('buildertek__Trade_Type__c') == false){
                 fields += ' , ' + 'buildertek__Trade_Type__c';
             }
             if(fields.contains('buildertek__Trade_Type__r.Name') == false  && query.contains('buildertek__Trade_Type__r.Name') == false){
                 fields += ' , ' + 'buildertek__Trade_Type__r.Name';
             }
             if(fields.contains('buildertek__Category__r.Name') == false  && query.contains('buildertek__Category__r.Name') == false){
                 fields += ' , ' + 'buildertek__Category__r.Name';
             }
             if(fields.contains('buildertek__Product_Type__r.Name') == false  && query.contains('buildertek__Product_Type__r.Name') == false){
                 fields += ' , ' + 'buildertek__Product_Type__r.Name';
             }
             
             query = query+fields+' FROM Product2  ';
             
             
             //query = 'SELECT Id, Name,buildertek__Collection__c, buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Series__c ,buildertek__Cost_Code__r.Name, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Vendor__r.Name,StockKeepingUnit,createddate FROM Product2';
             query += ' WHERE';
             filter = '';
             filter += filter2; 
             if (String.isNotBlank(selectPriceBook)){
                 
                 if (String.isNotBlank(filter)){
                     filter += ' AND Id IN: productIdlist';
                 }else{
                     filter += ' Id IN: productIdlist';
                 }
                 
             }
             query += filter;
             System.debug('filter Query : ' + filter);
             System.debug('filter Query : ' + String.isNotBlank(filter));
             if (String.isNotBlank(filter) == false){
                 System.debug('filter Query : ' + String.isNotBlank(filter));
                 query = query.replace('WHERE', '');
                 System.debug('Product Query : ' + query);
             }else if (String.isNotBlank(filter)){
                 query =  query.replace('WHERE AND', 'WHERE ');
             }
             
             // query = productClassWrapper.takeOffLinesList.size() > 0 ? query.replace('WHERE OR', 'WHERE ') : query.replace('WHERE', ' ');
            query += ' ORDER BY  buildertek__Trade_Type__r.Name ASC NULLS LAST, buildertek__Category__r.Name ASC NULLS LAST, buildertek__Product_Type__r.Name ASC NULLS LAST';
       //   query += ' ORDER BY buildertek__IsBOMLines__c';
             query += ' LIMIT : productPageSize OFFSET : productOffset';
             
             //Retrieve Product2
             System.debug('Product Query : ' + query);
             productClassWrapper.productsRecord = Database.query(query);
             system.debug('productClassWrapper.productsRecord:::::='+productClassWrapper.productsRecord);
             query = 'Select COUNT() FROM Product2 WHERE';
             query += filter;
             if (String.isNotBlank(filter) == false){
                 System.debug('filter Query : ' + String.isNotBlank(filter));
                 query = query.replace('WHERE', '');
                 System.debug('Product Query : ' + query);
             }else if (String.isNotBlank(filter)){
                 query =  query.replace('WHERE AND', 'WHERE ');
             }
             System.debug('Product Query : ' + query);
             // query = productClassWrapper.takeOffLinesList.size() > 0 ? query.replace(' WHERE OR ', ' WHERE ') : query.replace(' WHERE', ' ');
             productClassWrapper.productTotalRecords = Database.countQuery(query);
             system.debug('productClassWrapper.productsRecord:::;'+productClassWrapper.productsRecord);
             
             /*if (productClassWrapper.takeOffLinesList.size() > 0){
                 //Product2 Query
                 
                 // dynamic product query for filter
                 if(settingsList.size()>0)  {
                     settingsrec =  settingsList[0]; 
                     // dynamic product field
                     if(settingsList[0].buildertek__Product_Selected_Fields__c !=null){
                         jsonSerializeFields1 = settingsList[0].buildertek__Product_Selected_Fields__c;      
                     } else{
                         jsonSerializeFields1 = FieldsDefaultValues;
                     }
                     // filter
                     if(settingsList[0].buildertek__Product_Filter_Fields__c !=null){
                         jsonSerializeFields = settingsList[0].buildertek__Product_Filter_Fields__c;      
                     } else{
                         jsonSerializeFields = FieldsDefaultValues;
                     }
                 }
                 else{
                     jsonSerializeFields =   FieldsDefaultValues;
                     jsonSerializeFields1 = FieldsDefaultValues;
                 }
                 
                 Inn = new InnSettings();        
                 
                 FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeFields,List<fieldWrap>.class);
                 Inn.TakeOffFieldSettings = FieldsSettings;
                 
                 objectname='Product2';
                 schemaMapPTL = Schema.getGlobalDescribe();
                 leadSchemaPTL = schemaMapPTL.get(objectname);
                 fieldMapPTL = leadSchemaPTL.getDescribe().fields.getMap();     
                 query = 'SELECT Id, Name,buildertek__Collection__c, buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Series__c ,buildertek__Cost_Code__r.Name, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Vendor__r.Name,StockKeepingUnit ';
                  fields= '';
                 // filter
                 for(fieldWrap filedwraprec : FieldsSettings){
                     string fieldName = filedwraprec.value;
                     Schema.DisplayType fielddataType = fieldMapPTL.get(fieldName).getDescribe().getType();
                     string fldtype = STRING.valueOf(fielddataType);
                     if(fldtype == 'REFERENCE' ){
                         if(fieldName.contains('__c')){
                             fieldName = fieldName.replace('__c', '__r.Name');  
                         }
                     }
                     
                     if(fields.contains(fieldName) == false && query.contains(fieldName) == false){
                         fields += ' , ' + fieldName;    
                     }
                 }
                 system.debug(fields);
                 if(fields.contains('buildertek__Trade_Type__c') == false  && query.contains('buildertek__Trade_Type__c') == false){
                     fields += ' , ' + 'buildertek__Trade_Type__c';
                 }
                 if(fields.contains('buildertek__Trade_Type__r.Name') == false  && query.contains('buildertek__Trade_Type__r.Name') == false){
                     fields += ' , ' + 'buildertek__Trade_Type__r.Name';
                 }
                 system.debug(fields);
                 
                 // dynamic product field
                 FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeFields1,List<fieldWrap>.class);
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
                     
                     if(fields.contains(fieldName) == false && query.contains(fieldName) == false){
                         fields += ' , ' + fieldName;    
                     }
                 }
                 system.debug(fields);
                 if(fields.contains('buildertek__Trade_Type__c') == false  && query.contains('buildertek__Trade_Type__c') == false){
                     fields += ' , ' + 'buildertek__Trade_Type__c';
                 }
                 if(fields.contains('buildertek__Trade_Type__r.Name') == false  && query.contains('buildertek__Trade_Type__r.Name') == false){
                     fields += ' , ' + 'buildertek__Trade_Type__r.Name';
                 }
                 if(fields.contains('buildertek__Category__r.Name') == false  && query.contains('buildertek__Category__r.Name') == false){
                     fields += ' , ' + 'buildertek__Category__r.Name';
                 }
                 if(fields.contains('buildertek__Product_Type__r.Name') == false  && query.contains('buildertek__Product_Type__r.Name') == false){
                     fields += ' , ' + 'buildertek__Product_Type__r.Name';
                 }
                 
                 query = query+fields+' FROM Product2  ';
                 
                 
                 //query = 'SELECT Id, Name,buildertek__Collection__c, buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Series__c ,buildertek__Cost_Code__r.Name, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Vendor__r.Name,StockKeepingUnit,createddate FROM Product2';
                 query += ' WHERE';
                 filter = '';
                 filter += filter2; 
                 if (String.isNotBlank(selectPriceBook)){
                     
                     if (String.isNotBlank(filter)){
                         filter += ' AND Id IN: productIdlist';
                     }else{
                         filter += ' Id IN: productIdlist';
                     }
                     
                 }
                 for (buildertek__Project_Takeoff_Lines__c takeOffLines : productClassWrapper.takeOffLinesList){
                     // filter += takeOffLines.buildertek__Build_Phase__c == null ? ' OR ( buildertek__Build_Phase__c = null' : ' OR ( buildertek__Build_Phase__c =\'' + takeOffLines.buildertek__Build_Phase__c + '\'';
                  
                   //  filter += takeOffLines.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + takeOffLines.buildertek__Trade_Type__c + '\'';
                    // filter += takeOffLines.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + takeOffLines.buildertek__Product_Type__c + '\'';
                    // filter += takeOffLines.buildertek__Categories__c == null ? ' AND buildertek__Category__c = null' : ' AND buildertek__Category__c =\'' + takeOffLines.buildertek__Categories__c + '\'';
                   //  filter += projectSelectionSheetTakeOff.buildertek__Project__r == null || projectSelectionSheetTakeOff.buildertek__Project__r.buildertek__Project_Tiers__c == null ? ' AND buildertek__Collection__c = null' : ' AND buildertek__Collection__c =\'' + projectSelectionSheetTakeOff.buildertek__Project__r.buildertek__Project_Tiers__c + '\'';
                     
                    // filter += takeOffLines.buildertek__Product_Type__c == null ? ' OR ((buildertek__Product_Type__c = null' : ' OR ((buildertek__Product_Type__c =\'' + takeOffLines.buildertek__Product_Type__c + '\'';
                     //filter += takeOffLines.buildertek__Category__c == null ? ' OR buildertek__Category__c = null)' : ' OR buildertek__Category__r.Name =\'' + takeOffLines.buildertek__Category__c + '\')';
                 
                    // filter += filter2; 
                     
                     
                     
                    
                     
                   // if (String.isNotBlank(selectPriceBook)){
                         filter += ' AND Id IN: productIdlist';
                   //  }

                   //  filter += ' ) ' ;
                  }
                 query += filter;
                 System.debug('filter Query : ' + filter);
                 System.debug('filter Query : ' + String.isNotBlank(filter));
                 if (String.isNotBlank(filter) == false){
                     System.debug('filter Query : ' + String.isNotBlank(filter));
                    query = query.replace('WHERE', '');
                     System.debug('Product Query : ' + query);
                 }else if (String.isNotBlank(filter)){
                     query =  query.replace('WHERE AND', 'WHERE ');
                 }
                 
                // query = productClassWrapper.takeOffLinesList.size() > 0 ? query.replace('WHERE OR', 'WHERE ') : query.replace('WHERE', ' ');
                 query += ' ORDER BY  buildertek__Trade_Type__r.Name ASC NULLS LAST, buildertek__Category__r.Name ASC NULLS LAST, buildertek__Product_Type__r.Name ASC NULLS LAST';
                 query += ' LIMIT : productPageSize OFFSET : productOffset';
                 //Retrieve Product2
                 System.debug('Product Query : ' + query);
                 productClassWrapper.productsRecord = Database.query(query);
                 system.debug('productClassWrapper.productsRecord:::::='+productClassWrapper.productsRecord);
                 query = 'Select COUNT() FROM Product2 WHERE';
                 query += filter;
                 if (String.isNotBlank(filter) == false){
                     System.debug('filter Query : ' + String.isNotBlank(filter));
                     query = query.replace('WHERE', '');
                     System.debug('Product Query : ' + query);
                 }else if (String.isNotBlank(filter)){
                     query =  query.replace('WHERE AND', 'WHERE ');
                 }
                  System.debug('Product Query : ' + query);
                // query = productClassWrapper.takeOffLinesList.size() > 0 ? query.replace(' WHERE OR ', ' WHERE ') : query.replace(' WHERE', ' ');
                 productClassWrapper.productTotalRecords = Database.countQuery(query);
                 system.debug('productClassWrapper.productsRecord:::;'+productClassWrapper.productsRecord);
                 
             }*/
             
             //SSTL
             system.debug(recordId);
             
             //SSTL query for dynamic filter
                 if(settingsList.size()>0)  {
                     settingsrec =  settingsList[0]; 
                     if(settingsList[0].buildertek__BOM_Line_Selected_Fileds__c !=null){
                         jsonSerializeFields1 = settingsList[0].buildertek__BOM_Line_Selected_Fileds__c;      
                     } else{
                         jsonSerializeFields1 = FieldsDefaultValues;
                     }
                     // filter
                     
                     if(settingsList[0].buildertek__BOM_Line_Filter_Fields__c !=null){
                         jsonSerializeFields = settingsList[0].buildertek__BOM_Line_Filter_Fields__c;      
                     } else{
                         jsonSerializeFields = FieldsDefaultValues;
                     }
                 }
                 else{
                     jsonSerializeFields =   FieldsDefaultValues;           
                 }
                 
                 Inn = new InnSettings();        
                 
                 FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeFields,List<fieldWrap>.class);
                 Inn.TakeOffFieldSettings = FieldsSettings;
                 
                 objectname='buildertek__Select_Sheet__c';
                 schemaMapPTL = Schema.getGlobalDescribe();
                 leadSchemaPTL = schemaMapPTL.get(objectname);
                 fieldMapPTL = leadSchemaPTL.getDescribe().fields.getMap();     
                 
                 query = 'Select Id,Name,buildertek__Selection_Sheet_Takeoff__c, buildertek__Takeoff_Line__c, buildertek__Takeoff_Line__r.Name, buildertek__Location__c, buildertek__Quantity__c,buildertek__Product__c,buildertek__Product__r.Name , buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Vendor__r.Name, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name ';
                 fields= '';
                 for(fieldWrap filedwraprec : FieldsSettings){
                     string fieldName = filedwraprec.value;
                     Schema.DisplayType fielddataType = fieldMapPTL.get(fieldName).getDescribe().getType();
                     string fldtype = STRING.valueOf(fielddataType);
                     if(fldtype == 'REFERENCE' ){
                         if(fieldName.contains('__c')){
                             fieldName = fieldName.replace('__c', '__r.Name');  
                         }
                     }
                     
                     if(fields.contains(fieldName) == false && query.contains(fieldName) == false){
                         fields += ' , ' + fieldName;    
                     }
                 }
                 system.debug(fields);
                 if(fields.contains('buildertek__Trade_Type__c') == false  && query.contains('buildertek__Trade_Type__c') == false){
                     fields += ' , ' + 'buildertek__Trade_Type__c';
                 }
                 if(fields.contains('buildertek__Trade_Type__r.Name') == false  && query.contains('buildertek__Trade_Type__r.Name') == false){
                     fields += ' , ' + 'buildertek__Trade_Type__r.Name';
                 }
                 system.debug(fields);
                 
                 // bom line product field
                 FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeFields1,List<fieldWrap>.class);
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
                     
                     if(fields.contains(fieldName) == false && query.contains(fieldName) == false){
                         fields += ' , ' + fieldName;    
                     }
                 }
                 system.debug(fields);
                 if(fields.contains('buildertek__Trade_Type__c') == false  && query.contains('buildertek__Trade_Type__c') == false){
                     fields += ' , ' + 'buildertek__Trade_Type__c';
                 }
                 if(fields.contains('buildertek__Trade_Type__r.Name') == false  && query.contains('buildertek__Trade_Type__r.Name') == false){
                     fields += ' , ' + 'buildertek__Trade_Type__r.Name';
                 }
                 if(fields.contains('buildertek__Takeoff_Line__r.Name') == false  && query.contains('buildertek__Takeoff_Line__r.Name') == false){
                     fields += ' , ' + 'buildertek__Takeoff_Line__r.Name';
                 }
                 if(fields.contains('buildertek__Build_Phase__r.Name') == false  && query.contains('buildertek__Build_Phase__r.Name') == false){
                     fields += ' , ' + 'buildertek__Build_Phase__r.Name';
                 }
                 if(fields.contains('buildertek__Category__r.Name') == false  && query.contains('buildertek__Category__r.Name') == false){
                     fields += ' , ' + 'buildertek__Category__r.Name';
                 }  
                 if(fields.contains('buildertek__Product_Type__r.Name') == false  && query.contains('buildertek__Product_Type__r.Name') == false){
                     fields += ' , ' + 'buildertek__Product_Type__r.Name';
                 }
                 if(fields.contains('buildertek__Vendor__r.Name') == false  && query.contains('buildertek__Vendor__r.Name') == false){
                     fields += ' , ' + 'buildertek__Vendor__r.Name';
                 } 
                 if(fields.contains('buildertek__Location__c') == false  && query.contains('buildertek__Location__c') == false){
                     fields += ' , ' + 'buildertek__Location__c';
                 }
                 query = query+fields+'  FROM buildertek__Select_Sheet__c WHERE';
                 
                 
                 //query = 'Select Id,Name,buildertek__Selection_Sheet_Takeoff__c, buildertek__Takeoff_Line__c, buildertek__Takeoff_Line__r.Name, buildertek__Location__c, buildertek__Quantity__c,buildertek__Product__c,buildertek__Product__r.Name , buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Vendor__r.Name, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name,createddate FROM buildertek__Select_Sheet__c WHERE';
                 filter = '';
                 isFieldExist = false;
                 filter += filter3; 
                if (String.isNotBlank(filter) == false){
                     filter += ' buildertek__Selection_Sheet_Takeoff__c=:recordId  ';
                 }else{
                     filter += ' AND buildertek__Selection_Sheet_Takeoff__c=:recordId  ';
                 }
                  
              query += filter;
                 System.debug('filter Query : ' + filter);
                 if (String.isNotBlank(filter) == false){
                     System.debug('filter Query : ' + String.isNotBlank(filter));
                     query = query.replace('WHERE', '');
                 }else if (String.isNotBlank(filter)){
                     query =  query.replace('WHERE AND', 'WHERE ');
                 }
             
              //query = query.replace('WHERE OR', ' WHERE ');
                     System.debug(' Query : ' + query);
                     query += ' ORDER BY buildertek__Takeoff_Line__r.Name ASC , buildertek__Build_Phase__r.Name ASC NULLS LAST , buildertek__Trade_Type__r.Name ASC NULLS LAST , buildertek__Category__r.Name ASC NULLS LAST, buildertek__Product_Type__r.Name ASC NULLS LAST,buildertek__Vendor__r.Name ASC NULLS LAST, buildertek__Location__c ASC NULLS LAST';
                     query += ' LIMIT : SSTLPageSize OFFSET : SSTLOffset';
                     productClassWrapper.selectionSheetTakeOffLines = Database.query(query);
                     system.debug(productClassWrapper.selectionSheetTakeOffLines);
                     query = 'Select COUNT() FROM buildertek__Select_Sheet__c WHERE' + filter;//Total records with Search Query filter.
                    if (String.isNotBlank(filter) == false){
                         System.debug('filter Query : ' + String.isNotBlank(filter));
                         query = query.replace('WHERE', '');
                     }else if (String.isNotBlank(filter)){
                         query =  query.replace('WHERE AND', 'WHERE ');
                     }
                     //query = productClassWrapper.productsRecord.size() > 0 ? query.replace('WHERE OR', ' WHERE ') : query.replace('WHERE ', ' ');
                     productClassWrapper.SSTLTotalRecords = Database.countQuery(query);
             
             /*if (productClassWrapper.productsRecord.size() > 0){
                 
                 //SSTL query for dynamic filter
                 if(settingsList.size()>0)  {
                     settingsrec =  settingsList[0]; 
                     if(settingsList[0].buildertek__BOM_Line_Selected_Fileds__c !=null){
                         jsonSerializeFields1 = settingsList[0].buildertek__BOM_Line_Selected_Fileds__c;      
                     } else{
                         jsonSerializeFields1 = FieldsDefaultValues;
                     }
                     // filter
                     
                     if(settingsList[0].buildertek__BOM_Line_Filter_Fields__c !=null){
                         jsonSerializeFields = settingsList[0].buildertek__BOM_Line_Filter_Fields__c;      
                     } else{
                         jsonSerializeFields = FieldsDefaultValues;
                     }
                 }
                 else{
                     jsonSerializeFields =   FieldsDefaultValues;           
                 }
                 
                 Inn = new InnSettings();        
                 
                 FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeFields,List<fieldWrap>.class);
                 Inn.TakeOffFieldSettings = FieldsSettings;
                 
                 objectname='buildertek__Select_Sheet__c';
                 schemaMapPTL = Schema.getGlobalDescribe();
                 leadSchemaPTL = schemaMapPTL.get(objectname);
                 fieldMapPTL = leadSchemaPTL.getDescribe().fields.getMap();     
                 
                 query = 'Select Id,Name,buildertek__Selection_Sheet_Takeoff__c, buildertek__Takeoff_Line__c, buildertek__Takeoff_Line__r.Name, buildertek__Location__c, buildertek__Quantity__c,buildertek__Product__c,buildertek__Product__r.Name , buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Vendor__r.Name, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name ';
                 fields= '';
                 for(fieldWrap filedwraprec : FieldsSettings){
                     string fieldName = filedwraprec.value;
                     Schema.DisplayType fielddataType = fieldMapPTL.get(fieldName).getDescribe().getType();
                     string fldtype = STRING.valueOf(fielddataType);
                     if(fldtype == 'REFERENCE' ){
                         if(fieldName.contains('__c')){
                             fieldName = fieldName.replace('__c', '__r.Name');  
                         }
                     }
                     
                     if(fields.contains(fieldName) == false && query.contains(fieldName) == false){
                         fields += ' , ' + fieldName;    
                     }
                 }
                 system.debug(fields);
                 if(fields.contains('buildertek__Trade_Type__c') == false  && query.contains('buildertek__Trade_Type__c') == false){
                     fields += ' , ' + 'buildertek__Trade_Type__c';
                 }
                 if(fields.contains('buildertek__Trade_Type__r.Name') == false  && query.contains('buildertek__Trade_Type__r.Name') == false){
                     fields += ' , ' + 'buildertek__Trade_Type__r.Name';
                 }
                 system.debug(fields);
                 
                 // bom line product field
                 FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(jsonSerializeFields1,List<fieldWrap>.class);
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
                     
                     if(fields.contains(fieldName) == false && query.contains(fieldName) == false){
                         fields += ' , ' + fieldName;    
                     }
                 }
                 system.debug(fields);
                 if(fields.contains('buildertek__Trade_Type__c') == false  && query.contains('buildertek__Trade_Type__c') == false){
                     fields += ' , ' + 'buildertek__Trade_Type__c';
                 }
                 if(fields.contains('buildertek__Trade_Type__r.Name') == false  && query.contains('buildertek__Trade_Type__r.Name') == false){
                     fields += ' , ' + 'buildertek__Trade_Type__r.Name';
                 }
                 if(fields.contains('buildertek__Build_Phase__r.Name') == false  && query.contains('buildertek__Build_Phase__r.Name') == false){
                     fields += ' , ' + 'buildertek__Build_Phase__r.Name';
                 }
                 if(fields.contains('buildertek__Category__r.Name') == false  && query.contains('buildertek__Category__r.Name') == false){
                     fields += ' , ' + 'buildertek__Category__r.Name';
                 }  
                 if(fields.contains('buildertek__Product_Type__r.Name') == false  && query.contains('buildertek__Product_Type__r.Name') == false){
                     fields += ' , ' + 'buildertek__Product_Type__r.Name';
                 }
                 if(fields.contains('buildertek__Vendor__r.Name') == false  && query.contains('buildertek__Vendor__r.Name') == false){
                     fields += ' , ' + 'buildertek__Vendor__r.Name';
                 } 
                 if(fields.contains('buildertek__Location__c') == false  && query.contains('buildertek__Location__c') == false){
                     fields += ' , ' + 'buildertek__Location__c';
                 }
                 query = query+fields+'  FROM buildertek__Select_Sheet__c WHERE';
                 
                 
                 //query = 'Select Id,Name,buildertek__Selection_Sheet_Takeoff__c, buildertek__Takeoff_Line__c, buildertek__Takeoff_Line__r.Name, buildertek__Location__c, buildertek__Quantity__c,buildertek__Product__c,buildertek__Product__r.Name , buildertek__Category__c, buildertek__Category__r.Name, buildertek__Trade_Type__c, buildertek__Trade_Type__r.Name,buildertek__Vendor__r.Name, buildertek__Product_Type__c, buildertek__Product_Type__r.Name,buildertek__Build_Phase__c,buildertek__Build_Phase__r.Name,createddate FROM buildertek__Select_Sheet__c WHERE';
                 filter = '';
                 isFieldExist = false;
                 filter += filter3; 
                if (String.isNotBlank(filter) == false){
                     filter += ' buildertek__Selection_Sheet_Takeoff__c=:recordId  ';
                 }else{
                     filter += ' AND buildertek__Selection_Sheet_Takeoff__c=:recordId  ';
                 }
                  
                 //Filter query based on Product2.
                for (Product2 product : productClassWrapper.productsRecord){
                     //filter += product.buildertek__Trade_Type__c == null ? ' OR ( buildertek__Trade_Type__c = null' : ' OR ( buildertek__Trade_Type__c =\'' + product.buildertek__Trade_Type__c + '\'';
                    // filter += product.buildertek__Product_Type__c == null ? ' AND buildertek__Product_Type__c = null' : ' AND buildertek__Product_Type__c =\'' + product.buildertek__Product_Type__c + '\'';
                    // filter += product.buildertek__Category__c == null ? ' AND buildertek__Category__c = null' : ' AND buildertek__Category__c =\'' + product.buildertek__Category__c + '\'';
                     
                     //filter += product.buildertek__Product_Type__c == null ? ' OR ( (buildertek__Product_Type__c = null' : ' OR ((buildertek__Product_Type__c =\'' + product.buildertek__Product_Type__c + '\'';
                    // filter += product.buildertek__Category__c == null ? ' OR buildertek__Category__c = null)' : ' OR buildertek__Category__c =\'' + product.buildertek__Category__c + '\')';
                     
                     
                   
                     
                    //filter += filter3; 
                     
                        
                     
                    // filter += '  AND  buildertek__Selection_Sheet_Takeoff__c=:recordId ) ';
                }
                 query += filter;
                 System.debug('filter Query : ' + filter);
                 if (String.isNotBlank(filter) == false){
                     System.debug('filter Query : ' + String.isNotBlank(filter));
                     query = query.replace('WHERE', '');
                 }else if (String.isNotBlank(filter)){
                     query =  query.replace('WHERE AND', 'WHERE ');
                 }
                 if (productClassWrapper.productsRecord.size() > 0){
                     //query = query.replace('WHERE OR', ' WHERE ');
                     System.debug(' Query : ' + query);
                     query += ' ORDER BY buildertek__Build_Phase__r.Name ASC NULLS LAST , buildertek__Trade_Type__r.Name ASC NULLS LAST , buildertek__Category__r.Name ASC NULLS LAST, buildertek__Product_Type__r.Name ASC NULLS LAST,buildertek__Vendor__r.Name ASC NULLS LAST, buildertek__Location__c ASC NULLS LAST';
                     query += ' LIMIT : SSTLPageSize OFFSET : SSTLOffset';
                     productClassWrapper.selectionSheetTakeOffLines = Database.query(query);
                     system.debug(productClassWrapper.selectionSheetTakeOffLines);
                     query = 'Select COUNT() FROM buildertek__Select_Sheet__c WHERE' + filter;//Total records with Search Query filter.
                    if (String.isNotBlank(filter) == false){
                         System.debug('filter Query : ' + String.isNotBlank(filter));
                         query = query.replace('WHERE', '');
                     }else if (String.isNotBlank(filter)){
                         query =  query.replace('WHERE AND', 'WHERE ');
                     }
                     //query = productClassWrapper.productsRecord.size() > 0 ? query.replace('WHERE OR', ' WHERE ') : query.replace('WHERE ', ' ');
                     productClassWrapper.SSTLTotalRecords = Database.countQuery(query);
                 } else{
                     productClassWrapper.selectionSheetTakeOffLines = new List<buildertek__Select_Sheet__c>();
                     productClassWrapper.SSTLTotalRecords = 0;
                     
                 }
                 
             }*/
             
             return productClassWrapper;
             
        // }
        // catch (Exception e){
        //      System.debug('Error Message::' + e.getMessage());
        //      System.debug('Error Line::' + e.getLineNumber());
        //      throw new AuraHandledException(e.getMessage());
             
        // }
    }    
    
    //get field name and api map
    //Take off
    @AuraEnabled
    public static Map<String, filterOptionclsForsettings> getFiledNameAndApi(){
        String type='buildertek__Project_Takeoff_Lines__c';
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<String, filterOptionclsForsettings>fieldNameApiMap = new Map<String, filterOptionclsForsettings>();
        
        /*buildertek__BOM_Filters_Configuration__c BomConfigList  = [Select id,Name,buildertek__BOM_Selected_Fields__c
From buildertek__BOM_Filters_Configuration__c 
limit 1];*/
        
        buildertek__BOM_Settings__c  settingsList = [Select id,Name, buildertek__BOM_Selected_Fields__c,buildertek__BOM_Line_Selected_Fileds__c,buildertek__Product_Selected_Fields__c, buildertek__BOM_Line_Filter_Fields__c,
                                                     buildertek__Takeoff_Filter_Fields__c,
                                                     buildertek__Product_Filter_Fields__c
                                                     From buildertek__BOM_Settings__c 
                                                     limit 1];                                                         
        
        List<BOMSelectedFields> filterOptionList2  = (List<BOMSelectedFields>)System.JSON.deserialize(settingsList.buildertek__Takeoff_Filter_Fields__c, List<BOMSelectedFields>.class);
        List<String> SelectedFields = new List<String>();
        for(BOMSelectedFields BomItem : filterOptionList2){
            system.debug(BomItem.value);
            SelectedFields.add(BomItem.value);
        }
        
        for (String fieldName: SelectedFields) {
            system.debug(fieldName);
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
    
    // Product
    @AuraEnabled
    public static Map<String, filterOptionclsForsettings> getProductFiledNameAndApi(){
        String type='Product2';
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<String, filterOptionclsForsettings>fieldNameApiMap = new Map<String, filterOptionclsForsettings>();
        
        system.debug(fieldMap);
        /*buildertek__BOM_Filters_Configuration__c BomConfigList  = [Select id,Name,buildertek__BOM_Selected_Fields__c
From buildertek__BOM_Filters_Configuration__c 
limit 1];*/
        
        buildertek__BOM_Settings__c  settingsList = [Select id,Name, buildertek__BOM_Selected_Fields__c,buildertek__BOM_Line_Selected_Fileds__c,buildertek__Product_Selected_Fields__c, buildertek__BOM_Line_Filter_Fields__c,
                                                     buildertek__Takeoff_Filter_Fields__c,
                                                     buildertek__Product_Filter_Fields__c
                                                     From buildertek__BOM_Settings__c 
                                                     limit 1];                                                         
        
        system.debug(settingsList.buildertek__Product_Selected_Fields__c);
        List<BOMSelectedFields> filterOptionList2  = (List<BOMSelectedFields>)System.JSON.deserialize(settingsList.buildertek__Product_Filter_Fields__c, List<BOMSelectedFields>.class);
        List<String> SelectedFields = new List<String>();
        for(BOMSelectedFields BomItem : filterOptionList2){
            system.debug(BomItem.value);
            SelectedFields.add(BomItem.value);
        }
        
        for (String fieldName: SelectedFields) {
            system.debug(fieldName);
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
    
    
    //BOM line
    @AuraEnabled
    public static Map<String, filterOptionclsForsettings> getBOMLineFiledNameAndApi(){
        String type='buildertek__Select_Sheet__c';
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Schema.SObjectType leadSchema = schemaMap.get(type);
        Map<String, Schema.SObjectField> fieldMap = leadSchema.getDescribe().fields.getMap();
        Map<String, filterOptionclsForsettings>fieldNameApiMap = new Map<String, filterOptionclsForsettings>();
        
        /*buildertek__BOM_Filters_Configuration__c BomConfigList  = [Select id,Name,buildertek__BOM_Selected_Fields__c
From buildertek__BOM_Filters_Configuration__c 
limit 1];*/
        
        buildertek__BOM_Settings__c  settingsList = [Select id,Name, buildertek__BOM_Selected_Fields__c,buildertek__BOM_Line_Selected_Fileds__c,buildertek__Product_Selected_Fields__c, buildertek__BOM_Line_Filter_Fields__c,
                                                     buildertek__Takeoff_Filter_Fields__c,
                                                     buildertek__Product_Filter_Fields__c
                                                     From buildertek__BOM_Settings__c 
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
    
    public class filterOptioncls{
        @AuraEnabled
        public String Name;
        @AuraEnabled
        public String Value;
        @AuraEnabled
        public String apiName;
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
    
    
    public class ProjectTakeOffWrapper{
        @AuraEnabled
        public List<Product2> records{ get; set; }
        
        @AuraEnabled
        public List<LocationWrapper> locationDropDown;
        @AuraEnabled
        public Integer totalRecords;
    }
    
    public class LocationWrapper{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
    
    public class ProductClass{
        @AuraEnabled
        public buildertek__Project_Selection_Sheet_Takeoff__c projectSelectionSheetTakeOffRec;
        
        @AuraEnabled
        public List<Product2> productsRecord{ get; set; }
        
        @AuraEnabled
        public List<buildertek__Project_Takeoff_Lines__c> takeOffLinesList{ get; set; }
        
        @AuraEnabled
        public List<buildertek__Select_Sheet__c> selectionSheetTakeOffLines{ get; set; }
        
        @AuraEnabled
        public Integer productTotalRecords;
        @AuraEnabled
        public Integer totalRecords;
        @AuraEnabled
        public Integer SSTLTotalRecords;
        
    }
    
    public class ProjectSelectionSheetTakeOff{
        @AuraEnabled
        public buildertek__Project_Selection_Sheet_Takeoff__c projectSelectionSheetTakeOffRec;
        
    }
    
    public class MessageClass{
        @AuraEnabled
        public String Status{ get; set; }
        
        @AuraEnabled
        public string Message{ get; set; }
    }
    
    
    @AuraEnabled
    public static void  fetchObjectRecords() {                        
        List <SObject> allRecords = new List <SObject> ();
        
        list<string> fieldApiValues = new List <string>();
        
        String query = 'SELECT ';
        
        /*for(Integer i=0; i<fieldApiValues.size(); i++){

query += fieldApiValues[i] +' ,';

}*/
        
        query = query.removeEnd(',');
        
        query += ' FROM  buildertek__Project_Takeoff_Lines__c LIMIT 50000';
        
        System.debug('qq:::' + query);
        
        allRecords = Database.query(query);
        
        System.debug('allRecords:::'+allRecords);
        
        //return allRecords;
        
    }
    
    
    
    
    @AuraEnabled 
    public static InnSettings getTakeOffLinesData() {        
        String jsonSerializeFields='';
        buildertek__BOM_Settings__c settingsrec = new buildertek__BOM_Settings__c();

        list<buildertek__BOM_Settings__c>  settingsList = [Select id,Name, buildertek__BOM_Selected_Fields__c,buildertek__BOM_Line_Selected_Fileds__c,buildertek__Product_Selected_Fields__c, buildertek__BOM_Line_Filter_Fields__c,
                                                     buildertek__Takeoff_Filter_Fields__c,
                                                     buildertek__Product_Filter_Fields__c
                                                     From buildertek__BOM_Settings__c 
                                                     limit 1]; 
        
        String FieldsDefaultValues =    '[{"label":"Name","value":"Name"}]';
        
        
        if(settingsList.size()>0) {
            
            settingsrec =  settingsList[0]; 
            if(settingsList[0].buildertek__BOM_Selected_Fields__c !=null){
                jsonSerializeFields = settingsList[0].buildertek__BOM_Selected_Fields__c;      
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
        
        Inn.TakeOffFieldSettings = FieldsSettings;                        
        String objectname='buildertek__Project_Takeoff_Lines__c';
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
        Inn.selectedFields = selectedFields; 
        
        //product 
        if(settingsList.size()>0) {
            
            settingsrec =  settingsList[0]; 
            if(settingsList[0].buildertek__Product_Selected_Fields__c !=null){
                jsonSerializeFields = settingsList[0].buildertek__Product_Selected_Fields__c;      
            } else{
                jsonSerializeFields = FieldsDefaultValues;
            }                     
            
            
        }else {
            jsonSerializeFields =   FieldsDefaultValues;          
        }
        
        // Inn = new InnSettings();        
        
         FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(
            jsonSerializeFields,
            List<fieldWrap>.class);
        Inn.productFieldSettings = FieldsSettings; 
        
        
        objectname='Product2';
         schemaMap = Schema.getGlobalDescribe();
        leadSchema = schemaMap.get(objectname);
         fieldMap = leadSchema.getDescribe().fields.getMap();     
        
        selectedFields = '';
        for(fieldWrap filedwraprec : FieldsSettings){
            string fieldName = filedwraprec.value;
            Schema.DisplayType fielddataType = fieldMap.get(fieldName).getDescribe().getType();
            string fldtype = STRING.valueOf(fielddataType);
            string selectedfield = fieldName; 
            if( fieldName != 'buildertek__Color__c'){
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
            
        }
        Inn.productselectedFields = selectedFields; 
        
        
        //bom line.
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
        
        // Inn = new InnSettings();        
        
         FieldsSettings = (List<fieldWrap>)JSON.deserializeStrict(
            jsonSerializeFields,
            List<fieldWrap>.class);
        Inn.bomLineFieldSettings = FieldsSettings; 
        
        
        objectname='buildertek__Select_Sheet__c';
         schemaMap = Schema.getGlobalDescribe();
        leadSchema = schemaMap.get(objectname);
         fieldMap = leadSchema.getDescribe().fields.getMap();     
        
        selectedFields = '';
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
        Inn.bomLineselectedFields = selectedFields; 
        
       
        System.debug('#@#@ Inn.bomLineselectedFields---'+Inn.bomLineselectedFields);
        System.debug('#@#@ Inn.bomLineFieldSettings---'+Inn.bomLineFieldSettings);
        return Inn;
        
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
    
    
    // pavan code
     
    
    @AuraEnabled
    public static list<PricebookEntry> getProductPrice(string productId){
        System.debug('########pricebook'+productId);
        list<PricebookEntry> pList;
        if(Schema.sObjectType.pricebookEntry.fields.Id.isAccessible()&&
           Schema.sObjectType.PricebookEntry.fields.UnitPrice.isAccessible() &&
           Schema.sObjectType.PricebookEntry.fields.product2Id.isAccessible() &&
           Schema.sObjectType.Pricebook2.fields.Id.isAccessible() &&
           Schema.sObjectType.Pricebook2.fields.isActive.isAccessible()){
               pList = [select id,UnitPrice from PricebookEntry where 
                        product2Id =: productId and
                        isActive = true and 
                        pricebook2Id IN (select id from Pricebook2 Where isActive =true AND buildertek__BT_Visible__c = true)];
           }
        system.debug('====pList'+pList);
        return pList;
    }    
    
    
    
    @AuraEnabled public list<productfamilyClass> pfwrapperlst {get;set;}
    //get product family Values
    @AuraEnabled 
    public static list<productfamilyClass> getProductfamilyRecords(String ObjectName,string parentId) {
        system.debug('ObjectName-->' + ObjectName);
        Map<String, String> options = new Map<String, String>();
        List < sObject > returnList = new List < sObject > ();
        
        list<string> ProdIds = new list<string>();
        if(ObjectName == 'Product2' && parentId != null){
            
            list<pricebookEntry> PElist;
            
            PElist = [select id,Product2Id from pricebookEntry where pricebook2Id =: parentId];
            
            for(pricebookEntry PE : PElist){
                ProdIds.add(PE.Product2Id);
            }
        }
        //list<Product2> productfamlylst = [select id, Name,family from Product2 where Id IN :ProdIds AND family != null order by family];
        List<AggregateResult> productfamlylst =[SELECT family FROM Product2  where (Id IN :ProdIds AND family != null) group by family];
        list<productfamilyClass> pfwrapperlst = new list<productfamilyClass>();
        if(productfamlylst.size() > 0 ){
            for(AggregateResult agg : productfamlylst){
                productfamilyClass pf = new productfamilyClass();
                pf.productfamilyvalues = string.valueof(agg.get('family'));
                pfwrapperlst.add(pf);
            }
            system.debug('pfwrapperlst---->'+pfwrapperlst);
        }
        return pfwrapperlst;
    }
    public class productfamilyClass{
        @AuraEnabled public string productfamilyvalues {get;set;}
    }    
    
    @AuraEnabled
    public static buildertek__Project_Takeoff_Lines__c savePToffline(String takeoffLines, String PtoffId,String bomRecordString){
        try 
        {
            buildertek__Project_Takeoff_Lines__c TakeofflineToInsert = (buildertek__Project_Takeoff_Lines__c)JSON.deserialize(takeoffLines, buildertek__Project_Takeoff_Lines__c.class);
            system.debug('PtoffId---->'+PtoffId);
            // system.debug('checknamelength----'+TakeofflineToInsert.buildertek__Item_Name__c.length());
        
            // TakeofflineToInsert.buildertek__Description__c = TakeofflineToInsert.buildertek__Product__r.name;
            // TakeofflineToInsert.buildertek__Item_Name__c = TakeofflineToInsert.buildertek__Item_Name__c.left(250);
            // TakeofflineToInsert.Name = TakeofflineToInsert.buildertek__Item_Name__c.left(79);
        
        
            TakeofflineToInsert.buildertek__Project_Takeoff__c = PtoffId;
        
            insert TakeofflineToInsert;
        
            Map<String,String> takeOffLineVsPriceBookIds = new Map<String,String>();
            Map<String,set<String>> takeOffLineVsProductCode = new Map<String,set<String>>();
            Map<String,String> priceBookIdVsProdCodeMap = new Map<String,String>();
            if(String.isNotBlank(TakeofflineToInsert.buildertek__Price_Book__c) && String.isNotBlank(TakeofflineToInsert.buildertek__Product_Code__c))
            {
                takeOffLineVsPriceBookIds.put(TakeofflineToInsert.Id, TakeofflineToInsert.buildertek__Price_Book__c);
                priceBookIdVsProdCodeMap.put(TakeofflineToInsert.buildertek__Price_Book__c, TakeofflineToInsert.buildertek__Product_Code__c);
                set<String> takeOffIds = new set<String>();
                takeOffIds.add(TakeofflineToInsert.Id);
                takeOffLineVsProductCode.put(TakeofflineToInsert.buildertek__Product_Code__c,takeOffIds);

                buildertek__Project_Selection_Sheet_Takeoff__c bomRecord = (buildertek__Project_Selection_Sheet_Takeoff__c)JSON.deserialize(bomRecordString, buildertek__Project_Selection_Sheet_Takeoff__c.class);

                ProductClass productClassObj = checkPBAndCreateBomLines(takeOffLineVsPriceBookIds,takeOffLineVsProductCode,priceBookIdVsProdCodeMap,bomRecord.buildertek__Project__c,bomRecord.Id);
            }
        
            return TakeofflineToInsert;
        } catch (Exception e) {
            System.debug('Exception--'+e.getMessage());
            return null; 
        }
        // return null;     
    }
    
    
    @AuraEnabled
    public static buildertek__Project_Takeoff__c  getTakeoffId(String recordId){
        buildertek__Project_Selection_Sheet_Takeoff__c takeoffId = [select id, Name, buildertek__Takeoff__c from buildertek__Project_Selection_Sheet_Takeoff__c where Id =: recordId];
        
        buildertek__Project_Takeoff__c takeoffrec = [select Id, Name from buildertek__Project_Takeoff__c where Id =: takeoffId.buildertek__Takeoff__c];
        system.debug('takeoffrec'+takeoffrec);
        return takeoffrec;
    }
    
    
    @AuraEnabled
    public static object getPackageTakeoff(){
        List<buildertek__Package__c> packageList = [SELECT Id, Name, buildertek__Package_Name__c
                                                    FROM buildertek__Package__c ORDER BY Name ASC];
        system.debug(packageList);
        List<ProjectClass> projectClassWrapperList = new List<ProjectClass>();
        for (buildertek__Package__c masterTakeOff : packageList){
            ProjectClass projectClassWrapper = new ProjectClass();
            projectClassWrapper.packageRecord = masterTakeOff;
            projectClassWrapper.packageTakeOffCheck = false;
            projectClassWrapperList.add(projectClassWrapper);
        }
        system.debug('projectClassWrapperList'+projectClassWrapperList);
        return projectClassWrapperList;
    }
    
    public class ProjectClass{
        @AuraEnabled
        public buildertek__Package__c packageRecord{ get; set; }
        
        @AuraEnabled
        public Boolean packageTakeOffCheck{ get; set; }
    }
    
    
    @AuraEnabled
    public static String importPackageLinesRecords(List<String> takeOffLinesIds, String recordId){
        PackageLinesClass response = new PackageLinesClass();
        Set<Id> insertedTakeOffLines = new Set<Id>();
            List<buildertek__Package_Line__c> packageLineList = [SELECT Id, Name, buildertek__Category__c, buildertek__Trade_Type__c, buildertek__Quantity__c, buildertek__UOM__c, buildertek__Location__c, buildertek__Product_Type__c, buildertek__Package_Name__c
                                                                 FROM buildertek__Package_Line__c
                                                                 WHERE buildertek__Package_Name__c IN :takeOffLinesIds];


            List<buildertek__Project_Takeoff_Lines__c> takeOffItemsToInsertList = new List<buildertek__Project_Takeoff_Lines__c>();
            if (!packageLineList.isEmpty()){
                for (buildertek__Package_Line__c takeOffItem : packageLineList){
                    buildertek__Project_Takeoff_Lines__c projectTakeOffItemToInsert = new buildertek__Project_Takeoff_Lines__c();
                    projectTakeOffItemToInsert.buildertek__Location__c = takeOffItem.buildertek__Location__c;
                    projectTakeOffItemToInsert.buildertek__Quantity__c = takeOffItem.buildertek__Quantity__c;
                    projectTakeOffItemToInsert.buildertek__Categories__c = takeOffItem.buildertek__Category__c;
                    projectTakeOffItemToInsert.buildertek__Product_Type__c = takeOffItem.buildertek__Product_Type__c;
                    projectTakeOffItemToInsert.buildertek__Trade_Type__c = takeOffItem.buildertek__Trade_Type__c;
                    projectTakeOffItemToInsert.buildertek__Project_Takeoff__c = recordId;
                    projectTakeOffItemToInsert.buildertek__UOM__c = takeOffItem.buildertek__UOM__c;
                    projectTakeOffItemToInsert.buildertek__Source__c = 'Package';
                    takeOffItemsToInsertList.add(projectTakeOffItemToInsert);
                }
            }
            if (takeOffItemsToInsertList.size() > 0){
                insert takeOffItemsToInsertList;
                for (buildertek__Project_Takeoff_Lines__c record : takeOffItemsToInsertList){
                    insertedTakeOffLines.add(record.Id);
                }
           
                return 'success';
            } else{
                response.Status = 'Failed';
                response.Message = 'There were no Package Lines for the selected Package';
            }
            return 'There were no Package Lines for the selected Package';
    }
    
    
    public class PackageLinesClass{
        @AuraEnabled
        public Integer totalRecords;
        @AuraEnabled
        public buildertek__Project_Takeoff__c projectTakeOffRec;

        @AuraEnabled
        public List<buildertek__Package_Line__c> packageLinesRecord{ get; set; }

        @AuraEnabled
        public List<buildertek__Project_Takeoff_Lines__c> takeOffLinesList{ get; set; }

        @AuraEnabled
        public Set<Id> insertedTakeOffLines{ get; Set; }

        @AuraEnabled
        public String Status{ get; set; }

        @AuraEnabled
        public string Message{ get; set; }
    }

    
  @AuraEnabled
    public static String deleteSelectedProducts(List<String> prodIds, string sheetId){
        system.debug('prodIds'+ prodIds);
        
        list<buildertek__Select_Sheet__c>  deleteSovLine = [select Id, Name from buildertek__Select_Sheet__c where Id IN:prodIds];
        
        delete deleteSovLine;
        list<buildertek__Select_Sheet__c> bomLines = [select Id, Name,buildertek__Takeoff_Line__c,buildertek__Takeoff_Line__r.Name,buildertek__Takeoff_Line__r.buildertek__Project_Takeoff__c,
                                                      buildertek__Takeoff_Line__r.buildertek__Quantity__c,buildertek__QunUpdate__c
                                                      from buildertek__Select_Sheet__c  where buildertek__Selection_Sheet_Takeoff__c =:sheetId];
        list<id> selectsheetid = new list<id>();
        list<buildertek__Select_Sheet__c> sheetlist = new list<buildertek__Select_Sheet__c>();
        if(bomLines.size()>0){
        list<buildertek__Project_Takeoff_Lines__c> takeofflines = [select Id, Name,buildertek__Project_Takeoff__c,buildertek__Suppress_Record__c,buildertek__Quantity__c
                                                                   from buildertek__Project_Takeoff_Lines__c where 
                                                                   buildertek__Project_Takeoff__c =: bomLines[0].buildertek__Takeoff_Line__r.buildertek__Project_Takeoff__c AND 
                                                                   buildertek__Suppress_Record__c = 'No'];
            for(buildertek__Select_Sheet__c sheetRec : bomLines){
                for(buildertek__Project_Takeoff_Lines__c takeoffRec : takeofflines){
                    if(sheetRec.buildertek__Takeoff_Line__c == takeoffRec.Id){
                        sheetRec.buildertek__Quantity__c = takeoffRec.buildertek__Quantity__c;
                        sheetRec.buildertek__QunUpdate__c = false;
                        sheetlist.add(sheetRec);
                    }
                }
            }
            if(sheetlist.size()>0){
                Update sheetlist;
            }
        }
        return 'Success';
    } 
     @AuraEnabled
    public static void deleteTakeoffLines(List<String> TakeOffIds){
       system.debug('****TakeOffIds'+ TakeOffIds);
     
        
        list<buildertek__Project_Takeoff_Lines__c>  deleteSovLine = [select Id, Name from buildertek__Project_Takeoff_Lines__c where Id IN:TakeOffIds];
        
        delete deleteSovLine;
        
        
       
    } 

    /**
     * Helper Methods
     */
    public static buildertek__Project_Takeoff_Lines__c[] orderTakeOffs(
        buildertek__Project_Takeoff_Lines__c[] takeoffList,
        Map<String, Set<Id>> valueSetIdMap,
        Map<Id, buildertek__Project_Takeoff_Lines__c> takeoffListMap
        ) {

            buildertek__Project_Takeoff_Lines__c[] orderedTakeOffs = new buildertek__Project_Takeoff_Lines__c[]{};
            buildertek__Project_Takeoff_Lines__c[] orderedfalseTakeOffs = new buildertek__Project_Takeoff_Lines__c[]{};
            buildertek__Project_Takeoff_Lines__c[] orderedNULLTakeOffs = new buildertek__Project_Takeoff_Lines__c[]{};
            buildertek__Project_Takeoff_Lines__c[] orderedTrueTakeOffs = new buildertek__Project_Takeoff_Lines__c[]{};

            for(Id takeoffId : valueSetIdMap.get('false')){

                orderedTakeOffs.add(takeoffListMap.get(takeoffId));
            }
            for(Id takeoffId : valueSetIdMap.get('null')){

                orderedTakeOffs.add(takeoffListMap.get(takeoffId));
            }
            for(Id takeoffId : valueSetIdMap.get('true')){

                orderedTakeOffs.add(takeoffListMap.get(takeoffId));
            }

            return orderedTakeOffs;
    }
}