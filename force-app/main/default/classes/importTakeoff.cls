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
            List<buildertek__Project_Takeoff_Lines__c> takeoffLineList = new List<buildertek__Project_Takeoff_Lines__c>([SELECT Id, Name, buildertek__Build_Phase__c, buildertek__Build_Phase__r.Name, buildertek__Project_Takeoff__c,buildertek__Quantity__c, buildertek__Product_Type__c, buildertek__Cost_Code__c,buildertek__Product__r.Name FROM buildertek__Project_Takeoff_Lines__c WHERE buildertek__Project_Takeoff__c IN :listOfTakeoffIds]);
            Id grouppingId;
            List<buildertek__Quote_Item__c> quoteItems = [SELECT buildertek__Grouping__r.Id FROM buildertek__Quote_Item__c WHERE buildertek__Grouping__r.Name = 'TakeOff' LIMIT 1];

            if (!quoteItems.isEmpty() && quoteItems[0].buildertek__Grouping__r != null) {
                grouppingId = quoteItems[0].buildertek__Grouping__r.Id;
                System.debug('grouppingId: ' + grouppingId);
            } else {
                buildertek__Quote_Line_Group__c groupRec = new buildertek__Quote_Line_Group__c();
                groupRec.Name = 'TakeOff';
                insert groupRec;
                grouppingId = groupRec.Id;
                System.debug('grouppingId: ' + grouppingId);
            }

            List<buildertek__Quote_Item__c> quotelineList = new List<buildertek__Quote_Item__c>();
            for(buildertek__Project_Takeoff_Lines__c takeoffline: takeoffLineList){
                buildertek__Quote_Item__c quoteLine = new buildertek__Quote_Item__c();
                quoteLine.buildertek__Quantity__c = takeoffline.buildertek__Quantity__c;
                quoteLine.buildertek__Cost_Code__c = takeoffline.buildertek__Cost_Code__c;
                quoteLine.buildertek__Unit_Cost__c = 0;
                quoteLine.buildertek__Status__c = 'Accept';
                quoteLine.buildertek__Build_Phase__c = takeoffline.buildertek__Build_Phase__c;
                quoteLine.buildertek__Grouping__c = grouppingId;
                quoteLine.buildertek__quote__c = quoteId;
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