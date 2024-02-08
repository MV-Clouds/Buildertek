public without sharing class BT_CreateBOMfromTakeoffController {
    
    @AuraEnabled
    public static returValues createBOMformTakeoff(String TakeoffId){
        returValues returValues = new returValues();
        try {
            buildertek__Project_Takeoff__c Takeoff = [SELECT Id, Name, buildertek__Name__c,buildertek__Project__c FROM buildertek__Project_Takeoff__c WHERE Id =: TakeoffId LIMIT 1];

            list<buildertek__Project_Takeoff_Lines__c> takoffLineList = [SELECT ID, Name,buildertek__Project_Takeoff__c, buildertek__Product__c, buildertek__Price_Book__c,buildertek__Product__r.buildertek__Vendor__c, buildertek__Quantity__c, buildertek__Cost_Code__c, buildertek__Build_Phase__c,buildertek__Description__c, buildertek__Product__r.Name,buildertek__UOM_PL__c,buildertek__Vendor__c,buildertek__Categories__c,buildertek__Sort_Id__c	 FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =: TakeoffId];
            if(takoffLineList.size() > 0){

                buildertek__Project_Selection_Sheet_Takeoff__c BOMtoCreate = new buildertek__Project_Selection_Sheet_Takeoff__c();
                BOMtoCreate.buildertek__Name__c = Takeoff.buildertek__Name__c;
                BOMtoCreate.buildertek__Project__c = Takeoff.buildertek__Project__c;
                BOMtoCreate.buildertek__Takeoff__c = TakeoffId;
                insert BOMtoCreate;
                system.debug('Create BOM Id --> ' + BOMtoCreate.Id);
    
                set<Id> ProdutIds = new set<Id>();
                set<Id> PriceBookId = new set<Id>();
                for(buildertek__Project_Takeoff_Lines__c tkoffline : takoffLineList){
                    ProdutIds.add(tkoffline.buildertek__Product__c);
                    PriceBookId.add(tkoffline.buildertek__Price_Book__c);
                }
                
                map<Id, PricebookEntry> ProductId_PriceBookEntry = new map<Id, PricebookEntry>();
                map<Id, PricebookEntry> ProceBookId_PriceBookEntry = new map<Id, PricebookEntry>();
                map<Id, PricebookEntry> PricebookEntry_Map = new map<Id, PricebookEntry>();
                // List<PricebookEntry> PriceBookEntries = [SELECT Id, Name, Product2Id, buildertek__Vendor__c, buildertek__Unit_Cost__c, buildertek__Markup__c, Pricebook2Id, Pricebook2.Name, IsActive FROM PricebookEntry ORDER BY CreatedDate ASC LIMIT 50000];
                List<PricebookEntry> PriceBookEntries = [SELECT Id, Name, Product2Id, buildertek__Vendor__c, buildertek__Unit_Cost__c, buildertek__Markup__c, Pricebook2Id, Pricebook2.Name, IsActive FROM PricebookEntry WHERE Product2Id IN: ProdutIds AND IsActive = true ORDER BY CreatedDate ASC LIMIT 50000];
                
                map<String, PricebookEntry> ProPric_Entry = new map<String, PricebookEntry>();
                if(PriceBookEntries.size() > 0){
                    for(PricebookEntry PE : PriceBookEntries){
                        String key =  PE.Product2Id + '-' + PE.Pricebook2Id;
                        ProPric_Entry.put(key, PE);
                        ProductId_PriceBookEntry.put(PE.Product2Id, PE);
                        ProceBookId_PriceBookEntry.put(PE.Pricebook2Id, PE);
                    }
                }
                System.debug('ProductId_PriceBookEntry : '+ ProductId_PriceBookEntry.keySet());
                map<Id, PricebookEntry> takeOfflineId_PricebookEntry = new map<Id, PricebookEntry>();
                map<Id, String> takeOfflineId_BOmlineNametoBe = new map<Id, String>();

                for(buildertek__Project_Takeoff_Lines__c tkoffline : takoffLineList){
                    String Match_Key = tkoffline.buildertek__Product__c +'-'+ tkoffline.buildertek__Price_Book__c;
                    if(tkoffline.buildertek__Product__c != null && tkoffline.buildertek__Price_Book__c != null){
                        Id Entry_ProductId = ProPric_Entry.get(Match_Key) != null ? ProPric_Entry.get(Match_Key).Product2Id : null;
                        Id Entry_PricebookId = ProPric_Entry.get(Match_Key) != null ? ProPric_Entry.get(Match_Key).Pricebook2Id : null;
                        if(tkoffline.buildertek__Product__c == Entry_ProductId && tkoffline.buildertek__Price_Book__c == Entry_PricebookId){
                            system.debug('Matched Entry >> Product : ' + ProPric_Entry.get(Match_Key).Name +' Pricebook : '+ ProPric_Entry.get(Match_Key).Pricebook2.Name);
                            takeOfflineId_PricebookEntry.put(tkoffline.Id, ProPric_Entry.get(Match_Key));
                            takeOfflineId_BOMlineNametoBe.put(tkoffline.Id, tkoffline.buildertek__Product__r.Name);
                        }
                        else{
                            System.debug('Not Entry Matched');
                            takeOfflineId_BOMlineNametoBe.put(tkoffline.Id, tkoffline.buildertek__Product__r.Name);
                        }
                    }
                    else if(tkoffline.buildertek__Product__c == null && tkoffline.buildertek__Price_Book__c != null){
                        System.debug('Product null, Nothing to Do here ...');
                        takeOfflineId_BOMlineNametoBe.put(tkoffline.Id, tkoffline.buildertek__Description__c);
                    }
                    else if(tkoffline.buildertek__Product__c != null && tkoffline.buildertek__Price_Book__c == null){
                        String Entry_ProductName = ProductId_PriceBookEntry.get(tkoffline.buildertek__Product__c) != null ? ProductId_PriceBookEntry.get(tkoffline.buildertek__Product__c).Name : null;
                        String Entry_PricebookName = ProductId_PriceBookEntry.get(tkoffline.buildertek__Product__c) != null ? ProductId_PriceBookEntry.get(tkoffline.buildertek__Product__c).Pricebook2.Name : null;
                        System.debug('Pricebook Null > Product : '+ Entry_ProductName +' Latest Pricebook : ' + Entry_PricebookName);
                        takeOfflineId_PricebookEntry.put(tkoffline.Id, ProductId_PriceBookEntry.get(tkoffline.buildertek__Product__c));
                        takeOfflineId_BOMlineNametoBe.put(tkoffline.Id, tkoffline.buildertek__Product__r.Name);
                    }
                    else{
                        system.debug('Both Pricebook and Product not available');
                        takeOfflineId_BOMlineNametoBe.put(tkoffline.Id, tkoffline.buildertek__Description__c);
                    }
                }
                
                // for(buildertek__Project_Takeoff_Lines__c tkoffline : takoffLineList){
                //     for(PricebookEntry PE : PriceBookEntries ){
                //         if(tkoffline.buildertek__Product__c != null && tkoffline.buildertek__Price_Book__c != null){
                //             // System.debug('Pricebook and product are not null');
                //             if(tkoffline.buildertek__Product__c == PE.Product2Id && tkoffline.buildertek__Price_Book__c == PE.Pricebook2Id){
                //                 takeOfflineId_PricebookEntry.put(tkoffline.Id, PE);
                //                 system.debug(' Product and pricebook match : ' + PE.Name +' pricebook : '+ PE.Pricebook2.Name);
                //                 takeOfflineId_BOMlineNametoBe.put(tkoffline.Id, tkoffline.buildertek__Description__c);
                //             }
                //             else{
                //                 takeOfflineId_BOMlineNametoBe.put(tkoffline.Id, tkoffline.buildertek__Product__r.Name);
                //             }
                //         }
                //         else if(tkoffline.buildertek__Product__c == null && tkoffline.buildertek__Price_Book__c != null){
                //             // System.debug('Product is null');
                //             // if(tkoffline.buildertek__Price_Book__c == PE.Pricebook2Id){
                //             //     takeOfflineId_PricebookEntry.put(tkoffline.Id, PE);
                //             //     // system.debug(' Latest PE from Pricebook : Name ' + PE.Name +' pricebook : '+ PE.Pricebook2.Name);
                //             // }
                //             takeOfflineId_BOMlineNametoBe.put(tkoffline.Id, tkoffline.buildertek__Description__c);
                //         }
                //         else if(tkoffline.buildertek__Product__c != null && tkoffline.buildertek__Price_Book__c == null){
                //             // Do Nothing with unit cost and markup....
                //             takeOfflineId_BOMlineNametoBe.put(tkoffline.Id, tkoffline.buildertek__Product__r.Name);
                //             // System.debug('Pricebook is null');
                //             if(tkoffline.buildertek__Product__c == PE.Product2Id){
                //                 takeOfflineId_PricebookEntry.put(tkoffline.Id, PE);
                //             }
                //         }
                //         else{
                //             takeOfflineId_BOMlineNametoBe.put(tkoffline.Id, 'No Product');
                //         }
                //     }
                // }
    
                list<buildertek__Select_Sheet__c> BOMlinesToCreateList = new list<buildertek__Select_Sheet__c>();
                for(buildertek__Project_Takeoff_Lines__c tkoffline : takoffLineList){

                    // PricebookEntry relatedPricebookEntry = ProductId_PriceBookEntry.get(tkoffline.buildertek__Product__c);
                    PricebookEntry relatedPricebookEntry = takeOfflineId_PricebookEntry.get(tkoffline.Id);

                    buildertek__Select_Sheet__c BOMlineToCreate = new buildertek__Select_Sheet__c();

                    String ProductNameProposed = takeOfflineId_BOMlineNametoBe.get(tkoffline.Id) != null ? takeOfflineId_BOMlineNametoBe.get(tkoffline.Id) : 'No Description';
                    ProductNameProposed = ProductNameProposed.length() > 79 ? ProductNameProposed.substring(0, 79) : ProductNameProposed;

                    BOMlineToCreate.Name = ProductNameProposed;
                    BOMlineToCreate.buildertek__Quantity__c = tkoffline.buildertek__Quantity__c;
                    BOMlineToCreate.buildertek__Product__c = relatedPricebookEntry != null ? relatedPricebookEntry.Product2Id : tkoffline.buildertek__Product__c;
                    BOMlineToCreate.buildertek__BT_Price_Book__c = relatedPricebookEntry != null ? relatedPricebookEntry.Pricebook2Id : tkoffline.buildertek__Price_Book__c;
                    BOMlineToCreate.buildertek__BL_UNIT_COST__c	= relatedPricebookEntry != null ? relatedPricebookEntry.buildertek__Unit_Cost__c : null;
                    BOMlineToCreate.buildertek__BL_MARKUP__c = relatedPricebookEntry != null ? relatedPricebookEntry.buildertek__Markup__c : null;
                    BOMlineToCreate.buildertek__Vendor__c = tkoffline.buildertek__Vendor__c != null ? tkoffline.buildertek__Vendor__c : (relatedPricebookEntry != null ? relatedPricebookEntry.buildertek__Vendor__c : null);
                    BOMlineToCreate.buildertek__Cost_Code__c = tkoffline.buildertek__Cost_Code__c;
                    BOMlineToCreate.buildertek__Build_Phase__c = tkoffline.buildertek__Build_Phase__c;
                    BOMlineToCreate.buildertek__Selection_Sheet_Takeoff__c = BOMtoCreate.Id;
                    BOMlineToCreate.buildertek__Takeoff_Line__c = tkoffline.Id;
                    BOMlineToCreate.buildertek__UOM_Picklist__c = tkoffline.buildertek__UOM_PL__c;  
                    BOMlineToCreate.buildertek__Sort_Id__c = tkoffline.buildertek__Sort_Id__c;
                    BOMlineToCreate.buildertek__Category__c = tkoffline.buildertek__Categories__c;

                    BOMlinesToCreateList.add(BOMlineToCreate);
                }
    
                system.debug('BOMlinesToCreateList.size() ' + BOMlinesToCreateList.size());
                if(BOMlinesToCreateList.size() > 0){
                    system.debug('Going to create BOM Lines >>>> ');
                    insert BOMlinesToCreateList;
                }
    
                returValues.returnState = 'success';            
                returValues.CreatedrecordId = BOMtoCreate.Id;            
            }
            else {
                returValues.returnState = 'No lines. Please create at least one line.';            
                returValues.CreatedrecordId = null;
            }
            return returValues;
        } catch (Exception e) {
            System.debug('ERROR IN createBOMformTakeoff :: '+ e.getMessage() +'\n Line Number --> '+e.getLineNumber() +'\n Stack --> '+ e.getStackTraceString());
            returValues.returnState = 'Something went wrong!';            
            returValues.CreatedrecordId = null;            
            return returValues;

        }
    }

    public class returValues{
        @AuraEnabled public string returnState;
        @AuraEnabled public string CreatedrecordId;
    }
}