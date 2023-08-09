/*******************************************************
* Name          : ImportMasterPunchLine
* Author        : Nitin (MV Clouds)
* Create Date   : 03/11/2022
* Description   : This Class Used Import_Master_Punch_Line Aura component
*TestClass      : ImportMasterPunchLineTest
*Code Coverage  : 87%

================================================================================
Change No.          Developer Name              Date                Description     


*******************************************************/

public with sharing class ImportMasterPunchLine {
    
    @AuraEnabled
    public static List<buildertek__Punch_List__c> getMasterPL() {
        List<buildertek__Punch_List__c> masterPLList = new List<buildertek__Punch_List__c>();
        try {
            masterPLList = [SELECT Id, Name, buildertek__Description__c, buildertek__Project__c, buildertek__Project__r.Name, buildertek__Type__c FROM buildertek__Punch_List__c WHERE buildertek__Type__c = 'Master'];

            return masterPLList;
        } catch (Exception e) {
            System.debug(e);
            System.debug('Line Number ==>'+ e.getLineNumber());
            System.debug('Message ===>'+ e.getMessage() + ' <==>'+ e.getStackTraceString());
            return null;
        }
    }

    @AuraEnabled
    public static String importMasterPLRecords(List<String> selectedMasterPLIds, String recId) {
        List<buildertek__Punch_List_item__c> plLines = new List<buildertek__Punch_List_item__c>();
        List<buildertek__Punch_List_item__c> plLinesToInsert = new List<buildertek__Punch_List_item__c>();
        try {
            System.debug('selectedMasterPLIds ==>'+ selectedMasterPLIds);
            
            plLines = [SELECT Id, Name,
                        buildertek__Name__c, buildertek__Details__c, buildertek__Priority__c, buildertek__Location__c,
                        buildertek__Status__c, buildertek__Internal_Resource__c, buildertek__Assigned_Contractor__c,
                        buildertek__Assigned_Resource__c, buildertek__Schedule_Impact__c
                        FROM buildertek__Punch_List_item__c WHERE buildertek__Punch_List__c IN :selectedMasterPLIds];
            System.debug('plLines list size ==>' + plLines.size());

            if (plLines.size() == 0) {
                return 'NoChildFound';
            } else {
                for (buildertek__Punch_List_item__c pli : plLines) {
                    buildertek__Punch_List_item__c newPl = new buildertek__Punch_List_item__c(
                        buildertek__Name__c = pli.buildertek__Name__c,
                        buildertek__Details__c = pli.buildertek__Details__c,
                        buildertek__Priority__c = pli.buildertek__Priority__c,
                        buildertek__Location__c = pli.buildertek__Location__c,
                        buildertek__Status__c = 'Open',
                        buildertek__Internal_Resource__c = pli.buildertek__Internal_Resource__c,
                        buildertek__Assigned_Contractor__c = pli.buildertek__Assigned_Contractor__c,
                        buildertek__Assigned_Resource__c = pli.buildertek__Assigned_Resource__c,
                        buildertek__Schedule_Impact__c = pli.buildertek__Schedule_Impact__c,
                        buildertek__Punch_List__c = recId
                    );
                    plLinesToInsert.add(newPl);
                }
                insert plLinesToInsert;
                return 'SuccessfullyInserted';
            }

        } catch (Exception e) {
            System.debug(e);
            System.debug('Line Number ==>'+ e.getLineNumber());
            System.debug('Message ===>'+ e.getMessage() + ' <==>'+ e.getStackTraceString());
            return null;
        }
    }
}