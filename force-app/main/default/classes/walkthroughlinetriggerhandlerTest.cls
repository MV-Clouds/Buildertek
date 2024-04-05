@isTest
public with sharing class walkthroughlinetriggerhandlerTest {
    @isTest
    static void test() {
        Buildertek__Walk_Through_List__c wt = new Buildertek__Walk_Through_List__c(
            Buildertek__Description__c = 'Test wt'
        );
        insert wt;

        Buildertek__RFQ__c rfq = new Buildertek__RFQ__c();
        insert rfq;

        Buildertek__RFQ_Item__c rfqli = new Buildertek__RFQ_Item__c(
            Buildertek__Description__c = 'Test rfqli',
            Buildertek__RFQ_Package__c = rfq.Id
        );
        insert rfqli;

        List<Buildertek__Walk_Through_Line_Items__c> wtlList = new List<Buildertek__Walk_Through_Line_Items__c>();

        for (Integer i = 0; i < 2; i++) {
            Buildertek__Walk_Through_Line_Items__c wtl = new Buildertek__Walk_Through_Line_Items__c(
                Buildertek__Description__c = 'Test wtl' + i,
                Buildertek__Walk_Through_List__c = wt.Id,
                Buildertek__BT_RFQ_Line__c = rfqli.Id
            );
            wtlList.add(wtl);
        }

        insert wtlList;

        wtlList[1].Buildertek__BT_RFQ_Line__c = null;
        update wtlList[1];

        Map<Id, Buildertek__Walk_Through_Line_Items__c> oldMap = new Map<Id, Buildertek__Walk_Through_Line_Items__c>();

        for (Buildertek__Walk_Through_Line_Items__c wtl : wtlList) {
            oldMap.put(wtl.Id, wtl);
        }

        Test.startTest();
        WalkThroughLineTriggerHandler.onAfterInsert(wtlList);
        WalkThroughLineTriggerHandler.onAfterUpdate(wtlList, oldMap);
        WalkThroughLineTriggerHandler.onAfterDelete(wtlList);
        Test.stopTest();
    }
}
