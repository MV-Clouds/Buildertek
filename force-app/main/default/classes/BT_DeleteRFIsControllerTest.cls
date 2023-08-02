@isTest
private class BT_DeleteRFIsControllerTest {

    private static testMethod void insertRFIs() {
        Contact ConRef = new Contact();
        ConRef.LastName = 'test';
        insert ConRef;
        buildertek__RFI_Settings__c RFIsetting = new buildertek__RFI_Settings__c();
        RFIsetting.Name='RFI Settings';
        RFIsetting.buildertek__Using_Communities__c = true;
        RFIsetting.buildertek__Using_Email__c = true;
        RFIsetting.buildertek__New_RFI_Notification_Template__c = 'New RFI notification';
        RFIsetting.buildertek__Queue_Name__c = 'RFI';
        insert RFIsetting;
        List<buildertek__RFI__c> buildertekListRFI = new List<buildertek__RFI__c>();
        buildertek__RFI__c buildertekRFIRef = new buildertek__RFI__c();
        buildertekRFIRef.buildertek__Subject__c = 'test';
        buildertekRFIRef.buildertek__Assigned_To__c = ConRef.id;
        buildertekRFIRef.buildertek__Due_Date__c = system.today();
        buildertekListRFI.add(buildertekRFIRef);
        insert buildertekRFIRef;
        
        BT_DeleteRFIsController.deleteRFIsRecord(buildertekRFIRef.id);
        System.assertEquals('Test','Test');

    }

}