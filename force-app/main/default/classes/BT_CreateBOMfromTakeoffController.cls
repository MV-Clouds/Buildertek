public without sharing class BT_CreateBOMfromTakeoffController {
    
    @AuraEnabled
    public static returValues createBOMformTakeoff(String TakeoffId){
        returValues returValues = new returValues();
        try {
            buildertek__Project_Takeoff__c Takeoff = [SELECT Id, Name, buildertek__Name__c,buildertek__Project__c FROM buildertek__Project_Takeoff__c WHERE Id =: TakeoffId LIMIT 1];

            list<buildertek__Project_Takeoff_Lines__c> takoffLineList = [SELECT ID, Name,buildertek__Project_Takeoff__c, buildertek__Product__c, buildertek__Product__r.buildertek__Vendor__c, buildertek__Quantity__c, buildertek__Cost_Code__c, buildertek__Build_Phase__c, buildertek__Product__r.Name FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c =: TakeoffId];
            if(takoffLineList.size() > 0){

                buildertek__Project_Selection_Sheet_Takeoff__c BOMtoCreate = new buildertek__Project_Selection_Sheet_Takeoff__c();
                BOMtoCreate.buildertek__Name__c = Takeoff.buildertek__Name__c;
                BOMtoCreate.buildertek__Project__c = Takeoff.buildertek__Project__c;
                BOMtoCreate.buildertek__Takeoff__c = TakeoffId;
                insert BOMtoCreate;
                system.debug('Create BOM Id --> ' + BOMtoCreate.Id);
    
                map<Id, Id> ProductId_VendorId = new map<Id, Id>();
                set<Id> ProdutIds = new set<Id>();
                for(buildertek__Project_Takeoff_Lines__c tkoffline : takoffLineList){
                    ProductId_VendorId.put(tkoffline.buildertek__Product__c, tkoffline.buildertek__Product__r.buildertek__Vendor__c);
                    ProdutIds.add(tkoffline.buildertek__Product__c);
                }
                
                System.debug('TakeoffId_ProductId : '+ ProductId_VendorId);
    
                map<Id, PricebookEntry> ProductId_PriceBookEntry = new map<Id, PricebookEntry>();
                List<PricebookEntry> PriceBookEntries = [SELECT Id, Name , Product2Id,  buildertek__Unit_Cost__c, buildertek__Markup__c, Pricebook2Id, IsActive FROM PricebookEntry WHERE Product2Id IN : ProdutIds AND IsActive = true ORDER BY CreatedDate ASC];
                if(PriceBookEntries.size() > 0){
                    for(PricebookEntry PE : PriceBookEntries ){
                        ProductId_PriceBookEntry.put(PE.Product2Id, PE);
                    }
                }
                System.debug('ProductId_PriceBookEntry : '+ ProductId_PriceBookEntry);
    
    
                // map<Id, PricebookEntry> takeOfflineId_PricebookEntry = new map<Id, PricebookEntry>();
                // if(takoffLineList.size() > 0){
                //     for(buildertek__Project_Takeoff_Lines__c tkoffline : takoffLineList){
                //         takeOfflineId_PricebookEntry.put(tkoffline.Id, ProductId_PriceBookEntry.get(tkoffline.buildertek__Product__c));
                //     }
                // }
                // System.debug('takeOfflineId_PricebookEntry : ', takeOfflineId_PricebookEntry);
    
    
                list<buildertek__Select_Sheet__c> BOMlinesToCreateList = new list<buildertek__Select_Sheet__c>();
                for(buildertek__Project_Takeoff_Lines__c tkoffline : takoffLineList){

                    PricebookEntry relatedPricebookEntry = ProductId_PriceBookEntry.get(tkoffline.buildertek__Product__c);
                    Id vendorId = ProductId_VendorId.get(tkoffline.buildertek__Product__c);

                    buildertek__Select_Sheet__c BOMlineToCreate = new buildertek__Select_Sheet__c();

                    BOMlineToCreate.Name = tkoffline.buildertek__Product__r.Name;
                    BOMlineToCreate.buildertek__Product__c = tkoffline.buildertek__Product__c;
                    BOMlineToCreate.buildertek__Quantity__c = tkoffline.buildertek__Quantity__c;
                    BOMlineToCreate.buildertek__BL_UNIT_COST__c	= relatedPricebookEntry != null ? relatedPricebookEntry.buildertek__Unit_Cost__c : null;
                    BOMlineToCreate.buildertek__BT_Price_Book__c = relatedPricebookEntry != null ? relatedPricebookEntry.Pricebook2Id : null;
                    BOMlineToCreate.buildertek__BL_MARKUP__c = relatedPricebookEntry != null ? relatedPricebookEntry.buildertek__Markup__c : null;
                    BOMlineToCreate.buildertek__Vendor__c = vendorId;
                    BOMlineToCreate.buildertek__Cost_Code__c = tkoffline.buildertek__Cost_Code__c;
                    BOMlineToCreate.buildertek__Build_Phase__c = tkoffline.buildertek__Build_Phase__c;
                    BOMlineToCreate.buildertek__Selection_Sheet_Takeoff__c = BOMtoCreate.Id;
                    BOMlineToCreate.buildertek__Takeoff_Line__c = tkoffline.Id;

                    BOMlinesToCreateList.add(BOMlineToCreate);
                }
    
                if(BOMlinesToCreateList.size() > 0){
                    insert BOMlinesToCreateList;
                }
    
                returValues.returnState = 'success';            
                returValues.CreatedrecordId = BOMtoCreate.Id;            
            }
            else {
                returValues.returnState = 'No Lines Associated. Please create at least one line.';            
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