public without sharing class createInspectionController {

    @AuraEnabled(cacheable=true)
    public static List<buildertek__Inspection__c> getInspection(String searchKeyword) {
        String search = '%' + searchKeyword + '%';
        List<buildertek__Inspection__c> masterInspectionList = [Select Id, Name, buildertek__Project__c, buildertek__Name__c, buildertek__TYpe__c, buildertek__Type_Clone__c, buildertek__Status__c, buildertek__Inspector__c, buildertek__Details__c from buildertek__Inspection__c where buildertek__Type_Clone__c = 'Master' AND (Name LIKE :search OR buildertek__Name__c LIKE :search) ORDER BY Name DESC];

        if (masterInspectionList.size() > 0) {
            return masterInspectionList;
        }

        return null;
    }
    
    @AuraEnabled
    public static String createInspectionAndInspectionLine(List<String> listOfInspectionId, String permitId) {
        System.debug('listOfInspectionId: ' + listOfInspectionId);
        System.debug('permitId: ' + permitId);
        List<buildertek__Inspection_Line__c> inspectionLineList = [SELECT Id, buildertek__Inspection__c, buildertek__Description__c, buildertek__Status__c, buildertek__Comments__c FROM buildertek__Inspection_Line__c
        WHERE buildertek__Inspection__c IN :listOfInspectionId];
    
        List<buildertek__Inspection__c> inspectionList = [SELECT Id, buildertek__Project__c, buildertek__Name__c, buildertek__TYpe__c, buildertek__Type_Clone__c, buildertek__Status__c, buildertek__Inspector__c, buildertek__Details__c FROM buildertek__Inspection__c WHERE Id IN :listOfInspectionId];
        
        String projectId = [SELECT Id, buildertek__Project__c FROM buildertek__Permit__c WHERE Id =:permitId].buildertek__Project__c;
        System.debug('projectId: ' + projectId);
        if (inspectionList.isEmpty()) {
            return 'No inspections found';
        }
    
        // Create a map to associate old inspection Ids with new inspection Ids
        Map<Id, Id> inspectionIdMap = new Map<Id, Id>();
    
        // Create new inspections and add them to the map
        List<buildertek__Inspection__c> newInspections = new List<buildertek__Inspection__c>();
        for (buildertek__Inspection__c inspection : inspectionList) {
            buildertek__Inspection__c newInspection = new buildertek__Inspection__c();
            newInspection.buildertek__Project__c = projectId;
            newInspection.buildertek__Name__c = inspection.buildertek__Name__c;
            newInspection.buildertek__TYpe__c = inspection.buildertek__TYpe__c;
            newInspection.buildertek__Status__c = 'Open';
            newInspection.buildertek__Inspector__c = inspection.buildertek__Inspector__c;
            newInspection.buildertek__Details__c = inspection.buildertek__Details__c;
            newInspection.buildertek__BT_Permit__c = permitId;
            newInspections.add(newInspection);
        }
        System.debug('newInspections: ' + newInspections);
        insert newInspections;
    
        // Populate the inspectionIdMap with old and new inspection Ids
        for (Integer i = 0; i < inspectionList.size(); i++) {
            inspectionIdMap.put(inspectionList[i].Id, newInspections[i].Id);
        }
    
        // Create new inspection lines
        List<buildertek__Inspection_Line__c> newInspectionLines = new List<buildertek__Inspection_Line__c>();
        for (buildertek__Inspection_Line__c inspectionLine : inspectionLineList) {
            buildertek__Inspection_Line__c newInspectionLine = new buildertek__Inspection_Line__c();
            newInspectionLine.buildertek__Inspection__c = inspectionIdMap.get(inspectionLine.buildertek__Inspection__c);
            newInspectionLine.buildertek__Status__c = 'Pending';
            newInspectionLine.buildertek__Description__c = inspectionLine.buildertek__Description__c;
            newInspectionLine.buildertek__Comments__c = inspectionLine.buildertek__Comments__c;
            newInspectionLines.add(newInspectionLine);
        }
        System.debug('newInspectionLines: ' + newInspectionLines);
        insert newInspectionLines;
    
        return 'Success';
    }
    
    
}