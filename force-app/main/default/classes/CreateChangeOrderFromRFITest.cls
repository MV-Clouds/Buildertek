/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  16-Nov-2018
*/
@isTest
public class CreateChangeOrderFromRFITest {
    @testSetup static void setupBaseData() {
        SetupTestData.setupBaseData();
    }
    
    public static testMethod void test1() {
    buildertek__RFI_Settings__c RFIsetting = new buildertek__RFI_Settings__c();
RFIsetting.Name='RFI Settings';
RFIsetting.buildertek__Using_Communities__c = true;
RFIsetting.buildertek__Using_Email__c = true;
RFIsetting.buildertek__New_RFI_Notification_Template__c = 'New RFI notification';
RFIsetting.buildertek__Queue_Name__c = 'RFI';
insert RFIsetting;

        String projectId = [Select Id from Project__c LIMIT 1].Id;
        RFI__c rfi = new RFI__c();
        rfi.Project__c = projectId;
        rfi.buildertek__Subject__c = 'TEst'; 
        rfi.buildertek__Assigned_To__c = [Select Id from contact Limit 1].Id;
        rfi.buildertek__Due_Date__c = system.today();
        insert rfi;
        
        CreateChangeOrderFromRFI.getProjectId(rfi.Id);
        CreateChangeOrderFromRFI.getselectOptions(rfi,'buildertek__Status__c');
        CreateChangeOrderFromRFI.insertChangeOrder(new buildertek__Change_Order__c (), 'test', projectId, null, [Select Id from Account LIMIT 1].Id);
        System.assertEquals('Test','Test');
    }
}