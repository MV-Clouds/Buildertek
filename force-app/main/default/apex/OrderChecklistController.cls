public with sharing class OrderChecklistController {

    @AuraEnabled
    public static sectionSubsectionWrp getChecklistSectionSubsection(string checkListId){
        sectionSubsectionWrp sectionSubSectionListContainer = new sectionSubsectionWrp();
        try{
            List<buildertek__Checklist_Questions__c> checkListDataList = [SELECT id, buildertek__Checklist_Configuration__r.buildertek__Ordered_Subsection__c, buildertek__Checklist_Configuration__r.buildertek__Ordered_Section__c, buildertek__Questions__r.buildertek__Section__c, buildertek__Questions__r.buildertek__Section__r.Name, buildertek__Questions__r.buildertek__Sub_Section__c, buildertek__Questions__r.buildertek__Sub_Section__r.Name FROM buildertek__Checklist_Questions__c WHERE buildertek__Checklist_Configuration__c =:checkListId AND buildertek__Questions__r.buildertek__Section__c != null ORDER BY buildertek__Questions__r.buildertek__Section__r.Name ASC NULLS LAST, buildertek__Questions__r.buildertek__Sub_Section__r.Name NULLS LAST];
            Set<buildertek__Checklist_Section_Junction__c> sectionRecordSet = new Set<buildertek__Checklist_Section_Junction__c>();
            Map<Id, List<buildertek__Checklist_Section_Junction__c>> subSectionRecordMap = new Map<Id, List<buildertek__Checklist_Section_Junction__c>>();
            if(checkListDataList.size() > 0){
                for(buildertek__Checklist_Questions__c queJunction : checkListDataList){
                    buildertek__Checklist_Section_Junction__c sectionObj = new buildertek__Checklist_Section_Junction__c(); 
                    buildertek__Checklist_Section_Junction__c subSectionObj = new buildertek__Checklist_Section_Junction__c(); 
                    if(!String.isBlank(queJunction.buildertek__Questions__r.buildertek__Section__c)){
                        sectionObj.id = queJunction.buildertek__Questions__r.buildertek__Section__c;
                        sectionObj.Name = queJunction.buildertek__Questions__r.buildertek__Section__r.Name;
                        sectionRecordSet.add(sectionObj);
                    }
                    if(!String.isBlank(queJunction.buildertek__Questions__r.buildertek__Sub_Section__c)){
                        subSectionObj.id = queJunction.buildertek__Questions__r.buildertek__Sub_Section__c;
                        subSectionObj.Name = queJunction.buildertek__Questions__r.buildertek__Sub_Section__r.Name;
                        if(!subSectionRecordMap.containsKey(queJunction.buildertek__Questions__r.buildertek__Section__c)){
                            subSectionRecordMap.put(queJunction.buildertek__Questions__r.buildertek__Section__c, new List<buildertek__Checklist_Section_Junction__c>());
                        }
                        subSectionRecordMap.get(queJunction.buildertek__Questions__r.buildertek__Section__c).add(subSectionObj);
                    }
                }
                sectionSubSectionListContainer.storedSectionOrder = checkListDataList[0].buildertek__Checklist_Configuration__r.buildertek__Ordered_Section__c;
                sectionSubSectionListContainer.storedSubsectionOrder = checkListDataList[0].buildertek__Checklist_Configuration__r.buildertek__Ordered_Subsection__c;
            }
            sectionSubSectionListContainer.sectionList = new List<buildertek__Checklist_Section_Junction__c>(sectionRecordSet);
            sectionSubSectionListContainer.subSectionMap = subSectionRecordMap;
            sectionSubSectionListContainer.message = 'success';
        } catch (Exception e){    
            BT_ExceptionHandler.Store_Exception(e);
            sectionSubSectionListContainer.message = e.getMessage();
            system.debug('Error in getChecklistGroups: '+e.getMessage());
        }
        return sectionSubSectionListContainer;
    }

    @AuraEnabled
    public static void updateCheckListForSectionOrder(string checkListId, String jsonSectionOrderedString){
       buildertek__Checklist_Configuration__c checkListConfig = new buildertek__Checklist_Configuration__c();
       checkListConfig.id = checkListId;
       checkListConfig.buildertek__Ordered_Section__c = jsonSectionOrderedString;
       update checkListConfig;
    }

    public class sectionSubsectionWrp{
        @AuraEnabled
        public List<buildertek__Checklist_Section_Junction__c>sectionList;

        @AuraEnabled
        public Map<Id, List<buildertek__Checklist_Section_Junction__c>>subSectionMap;

        @AuraEnabled
        public String message;

        @AuraEnabled
        public String storedSectionOrder;

        @AuraEnabled
        public String storedSubsectionOrder;
    }
}
