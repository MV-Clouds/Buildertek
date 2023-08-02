public with sharing class Create_SOV_From_Quote {
    
    @AuraEnabled
    public static buildertek__Quote__c getQuoteData(String recordId) {
        buildertek__Quote__c quote = [SELECT Id, Name, buildertek__Schedule_of_Values__c FROM buildertek__Quote__c WHERE Id =: recordId];
        return quote;
    }

    @AuraEnabled
    public static String createSOV(String recordId){
        buildertek__Quote__c quote = [SELECT Id, Name, buildertek__Project__c, buildertek__Schedule_of_Values__c FROM buildertek__Quote__c WHERE Id =: recordId];

        List<buildertek__Quote_Item__c> quoteLineList = [SELECT Id, Name, buildertek__Total_Cost__c,buildertek__Grouping__c, buildertek__Grouping__r.Name FROM buildertek__Quote_Item__c WHERE buildertek__Quote__c =: recordId];

        Id sovRecordTypeId = Schema.SObjectType.buildertek__Schedule_of_Values__c.getRecordTypeInfosByName().get('Standard').getRecordTypeId();

        buildertek__Schedule_of_Values__c sov = new buildertek__Schedule_of_Values__c();
        sov.Name = quote.Name;
        sov.buildertek__Status__c = 'Pending';
        sov.buildertek__Project__c = quote.buildertek__Project__c;
        sov.buildertek__Type__c = 'Standard';
        sov.RecordTypeId = sovRecordTypeId;
        insert sov;

        quote.buildertek__Schedule_of_Values__c = sov.Id;
        update quote;

        List<buildertek__Budget_Line_Group__c> groupList = [SELECT Id, Name FROM buildertek__Budget_Line_Group__c];

        Map<String, Id> groupMap = new Map<String, Id>();

        for (buildertek__Budget_Line_Group__c groupData : groupList) {
            groupMap.put(groupData.Name, groupData.Id);
        }

        List<buildertek__Budget_Line_Group__c> newGroupList = new List<buildertek__Budget_Line_Group__c>();
        String groupId = recordId;
        for (buildertek__Quote_Item__c quoteLine : quoteLineList) {
            if (quoteLine.buildertek__Grouping__c != null && quoteLine.buildertek__Grouping__c != groupId) {
                if (!groupMap.containsKey(quoteLine.buildertek__Grouping__r.Name)) {
                    buildertek__Budget_Line_Group__c newGroup = new buildertek__Budget_Line_Group__c();
                    newGroup.Name = quoteLine.buildertek__Grouping__r.Name;
                    newGroupList.add(newGroup);
                }
                groupId = quoteLine.buildertek__Grouping__c;
            }
        }

        if (newGroupList.size() > 0) {
            insert newGroupList;
            for (buildertek__Budget_Line_Group__c groupData : newGroupList) {
                groupMap.put(groupData.Name, groupData.Id);
            }
        }

        List<buildertek__Schedule_of_Value_Lines__c> sovLineList = new List<buildertek__Schedule_of_Value_Lines__c>();

        for (buildertek__Quote_Item__c quoteLine : quoteLineList) {
            buildertek__Schedule_of_Value_Lines__c sovLine = new buildertek__Schedule_of_Value_Lines__c();
            sovLine.buildertek__Description_of_Work__c = quoteLine.Name;
            sovLine.buildertek__Status__c = 'Pending';
            sovLine.buildertek__Scheduled_Value__c = quoteLine.buildertek__Total_Cost__c;
            sovLine.buildertek__Schedule_of_Values__c = sov.Id;
            sovLine.buildertek__Budget_Line_Group__c = groupMap.get(quoteLine.buildertek__Grouping__r.Name);
            sovLineList.add(sovLine);
        }

        if (sovLineList.size() > 0) {
            insert sovLineList;
        }

        return sov.Id;
    }

}