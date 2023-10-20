public with sharing class importTakeoff {
    
    @AuraEnabled(Cacheable=true)
    public static List<buildertek__Project_Takeoff__c> fetchTakeoff (String searchKeyword){
        String search = '%' + searchKeyword + '%';
        List<buildertek__Project_Takeoff__c> takeoffList = new List<buildertek__Project_Takeoff__c>([SELECT Id, Name, buildertek__Build_Phase__c, buildertek__Status__c, buildertek__Project__r.Name, buildertek__Name__c, buildertek__Number_of_TakeOff_Lines__c FROM buildertek__Project_Takeoff__c WHERE buildertek__Status__c = 'Approved' AND (Name LIKE :search OR buildertek__Name__c LIKE :search) ORDER BY Name DESC]);

        return takeoffList;
    }
    
    @AuraEnabled
    public static void fetchTakeoffLines(List<String> listOfTakeoffIds, String quoteId) {
        try {
            System.debug('quoteId: ' + quoteId);
            List<buildertek__Project_Takeoff_Lines__c> takeoffLineList = new List<buildertek__Project_Takeoff_Lines__c>([SELECT Id, Name, buildertek__Build_Phase__c, buildertek__Build_Phase__r.Name, buildertek__Project_Takeoff__c,buildertek__Quantity__c, buildertek__Product_Type__c, buildertek__Cost_Code__c, buildertek__Product__r.Name , buildertek__Product__r.IsActive FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c IN :listOfTakeoffIds]);
            Id grouppingId;
            List<buildertek__Quote_Item__c> quoteItems = [SELECT buildertek__Grouping__r.Id FROM buildertek__Quote_Item__c WHERE buildertek__Grouping__r.Name = 'No Grouping' LIMIT 1];
            List<buildertek__quote__c> quoteList = [SELECT Id, buildertek__Markup__c, buildertek__Discount__c FROM buildertek__quote__c where Id = :quoteId];
            
            Map<String,buildertek__Quote_Line_Group__c> groupingMap = new Map<String,buildertek__Quote_Line_Group__c>();
            Map<Id,PricebookEntry> PricebookMap=new Map<Id,PricebookEntry>();

            List<buildertek__Quote_Line_Group__c> groupingList;
            List<PricebookEntry> pricebookList;

            if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible() ){
                    groupingList=[select id,name from buildertek__Quote_Line_Group__c];
            }
            if(Schema.sObjectType.PricebookEntry.fields.buildertek__Markup__c.isAccessible()&&
                Schema.sObjectType.PricebookEntry.fields.buildertek__Discount__c.isAccessible()&&
                Schema.sObjectType.PricebookEntry.fields.Product2Id.isAccessible()&&
                Schema.sObjectType.PricebookEntry.fields.Pricebook2Id.isAccessible()&&
                Schema.sObjectType.PricebookEntry.fields.buildertek__Unit_Cost__c	.isAccessible() ){
                    pricebookList=[select Product2Id,Pricebook2Id,buildertek__Markup__c,buildertek__Discount__c,buildertek__Unit_Cost__c from PricebookEntry WHERE Pricebook2.IsActive = true ];
            }
            
            for(buildertek__Quote_Line_Group__c groupingItem : groupingList){
                groupingMap.put(groupingItem.Name.toLowerCase(),groupingItem);
            }

            for(PricebookEntry prItem : pricebookList){
                PricebookMap.put(prItem.Product2Id,prItem);
            }

            if (!quoteItems.isEmpty() && quoteItems[0].buildertek__Grouping__r != null) {
                grouppingId = quoteItems[0].buildertek__Grouping__r.Id;
                System.debug('grouppingId: ' + grouppingId);
            } else {
                buildertek__Quote_Line_Group__c groupRec = new buildertek__Quote_Line_Group__c();
                groupRec.Name = 'No Grouping';
                insert groupRec;
                grouppingId = groupRec.Id;
                System.debug('grouppingId: ' + grouppingId);
            }

            List<buildertek__Quote_Item__c> quotelineList = new List<buildertek__Quote_Item__c>();
            for(buildertek__Project_Takeoff_Lines__c takeoffline: takeoffLineList){
                buildertek__Quote_Item__c quoteLine = new buildertek__Quote_Item__c();
                quoteLine.buildertek__Quantity__c = takeoffline.buildertek__Quantity__c;
                quoteLine.buildertek__Cost_Code__c = takeoffline.buildertek__Cost_Code__c;
                // quoteLine.buildertek__Unit_Cost__c = 0;
                quoteLine.buildertek__Status__c = 'Accept';
                String groupingName = takeoffline.buildertek__Build_Phase__r.Name;
                if(groupingName != null &&  groupingName != ''  && groupingMap.containsKey(groupingName.toLowerCase())){
                    quoteLine.buildertek__Grouping__c = groupingMap.get(groupingName.toLowerCase()).id;
                } else {
                    quoteLine.buildertek__Grouping__c = grouppingId;
                }
                quoteLine.buildertek__Build_Phase__c = takeoffline.buildertek__Build_Phase__c;
                // quoteLine.buildertek__Grouping__c = grouppingId;
                quoteLine.buildertek__quote__c = quoteId;
                // quoteLine.buildertek__Markup__c = quoteList[0].buildertek__Markup__c;
                // quoteLine.buildertek__Additional_Discount__c = quoteList[0].buildertek__Discount__c;
                String prId = takeoffline.buildertek__Product__c;

                if(prId != null &&  prId != '' && takeoffline.buildertek__Product__r.IsActive != false  && PricebookMap.containsKey(prId)){
                    quoteLine.buildertek__Unit_Cost__c = PricebookMap.get(prId).buildertek__Unit_Cost__c;
                    quoteLine.buildertek__Additional_Discount__c = PricebookMap.get(prId).buildertek__Discount__c;
                    quoteLine.buildertek__Markup__c = PricebookMap.get(prId).buildertek__Markup__c;
                } else {
                    quoteLine.buildertek__Unit_Cost__c = 0;
                    quoteLine.buildertek__Additional_Discount__c = 0;
                    quoteLine.buildertek__Markup__c = 0;
                }
                quoteLine.buildertek__Product__c = takeoffline.buildertek__Product__c;
                
                String productName = takeoffline.buildertek__Product__r.Name;
                if (productName != null) {
                    quoteLine.Name = (productName.length() > 79) ? productName.substring(0, 79) : productName;
                    quoteLine.buildertek__Item_Name__c = (productName.length() > 255) ? productName.substring(0, 254) : productName;
                    quoteLine.buildertek__Description__c = productName;
                } else {
                    quoteLine.Name = takeoffline.Name;
                    quoteLine.buildertek__Item_Name__c = takeoffline.Name;
                    quoteLine.buildertek__Description__c = takeoffline.Name;
                }

                System.debug('quoteLine.buildertek__Product__c: ' + quoteLine.buildertek__Product__c);
                quotelineList.add(quoteLine);
            }

            System.debug('quoteLine: ' + quotelineList);

            if (quotelineList.size() > 0) {
                insert quotelineList;
            }
        } catch(Exception e) {
            System.debug('check error here :'+e.getMessage());
        }
    }

}