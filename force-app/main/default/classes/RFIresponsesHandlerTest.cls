@isTest
public class RFIresponsesHandlerTest {
    
    @testSetup static void setupBaseData() {
        system.debug('test');
    }
    
    public static testMethod void test1() {
        contact con = new contact();
        con.Lastname = 'test';
        insert con;
        buildertek__RFI_Settings__c RFIsetting = new buildertek__RFI_Settings__c();
        RFIsetting.Name='RFI Settings';
        RFIsetting.buildertek__Using_Communities__c = true;
        RFIsetting.buildertek__Using_Email__c = true;
        RFIsetting.buildertek__New_RFI_Notification_Template__c = 'New RFI notification';
        RFIsetting.buildertek__Queue_Name__c = 'RFI';
        insert RFIsetting;
        buildertek__RFI__c rfi = new buildertek__RFI__c();
        rfi.buildertek__Subject__c = 'test';
        rfi.buildertek__Assigned_To__c = con.Id;
        rfi.buildertek__Due_Date__c = system.today();
        insert rfi;
        buildertek__RFI_Response__c res = new buildertek__RFI_Response__c();
        res.buildertek__RFI__c = rfi.Id; 
        res.buildertek__Answered__c='Yes';
        res.buildertek__Response_From_CMP__c = true;
        insert res;
        RFIresponsesHandler.test();
    }
    
    
}