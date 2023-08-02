@isTest
public with sharing class ProjectTriggerHandlerTest {
    public static final string CONTENT_NAME = 'Test file';
    public static final string CONTENT_DATA = 'Test Data';
    @testsetup
    static void commonSetup() {
        Account acc = new Account();
        acc.Name = 'Test 1'; 
        insert acc;
        buildertek__Project__c projectRec = new buildertek__Project__c();
        projectRec.Name = 'Test';
        projectRec.buildertek__Account__c = acc.Id;
        projectRec.buildertek__Address__c = '2705 NE';
        projectRec.buildertek__Zip__c =  '64014';
        projectRec.buildertek__Country__c = 'Unites States';
        projectRec.buildertek__State__c = 'MO';
        projectRec.buildertek__City__c = 'Blue Springs';
        projectRec.buildertek__Type__c = 'Master';
        insert projectRec;
        buildertek__Project__c project = new buildertek__Project__c();
        project.Name = 'Test';
        project.buildertek__Type__c = 'Master';
        project.buildertek__Master_Project__c = projectRec.id;
        insert project;
        buildertek__Purchase_Order__c purchaseorderRec = new buildertek__Purchase_Order__c();
        purchaseorderRec.buildertek__Project__c  = project.buildertek__Master_Project__c;
        purchaseorderRec.buildertek__Vendor__c = acc.id;
        insert purchaseorderRec; 
        buildertek__Schedule__c schRec = new buildertek__Schedule__c();
        schRec.buildertek__Project__c = project.buildertek__Master_Project__c;
        insert schRec;
        buildertek__Punch_List__c punchlist = new buildertek__Punch_List__c();
        punchlist.buildertek__Project__c =  project.buildertek__Master_Project__c;
        punchlist.buildertek__Description__c = 'test';
        insert  punchlist;
        buildertek__Select_Sheet__c selectsheetRec = new buildertek__Select_Sheet__c();
        selectsheetRec.buildertek__Project__c =  project.buildertek__Master_Project__c;
        insert  selectsheetRec;
    }
    
    @isTest
    static void testMethod1() {
        Test.startTest();
        buildertek__Admin_Interface_Node_Configuration__c AINC = new buildertek__Admin_Interface_Node_Configuration__c(Name = 'Project Configuration',
                                                                                                                       buildertek__Retreive_Aerial_Photo_of_project__c = true);
        insert AINC;
        List<buildertek__Project__c> project = [Select Id, buildertek__City__c, buildertek__State__c, buildertek__Address__c, buildertek__Zip__c, buildertek__Master_Project__c FROM buildertek__Project__c LIMIT 1];
        project[0].buildertek__City__c = '1test';
        update project;
        
        buildertek__Project__c projectRec2 = New buildertek__Project__c(Name = 'Test',
                                                                        buildertek__Master_Project__c = project[0].Id,
                                                                        buildertek__Source_Project__c = 'Test ~Purchase Order,Schedule,PunchList,Inspections,Warranty,Contract,Quote,Budget,Selection Sheet,Selection~ Test2');
        //Insert projectRec2;
        buildertek__Purchase_Order__c PORec2 = New buildertek__Purchase_Order__c(buildertek__Project__c = projectRec2.buildertek__Master_Project__c); //[select id from buildertek__Purchase_Order__c limit 1];
        //insert PORec2;
        buildertek__Inspection__c inspRec = new buildertek__Inspection__c(buildertek__Project__c = projectRec2.buildertek__Master_Project__c,
                                                                          buildertek__Name__c = 'test');
        insert inspRec;
        Test.stopTest();
    }
    
    @isTest
    static void testMethod2() {
        Test.startTest();
        Account accRec = new Account();
        accRec.Name = 'Test 2'; 
        insert accRec;
        buildertek__Admin_Interface_Node_Configuration__c AINC = new buildertek__Admin_Interface_Node_Configuration__c(Name = 'Project Configuration',
                                                                                                                       buildertek__Retreive_Aerial_Photo_of_project__c = true);
        insert AINC;
        List<buildertek__Project__c> project = [Select Id, buildertek__City__c, buildertek__State__c, buildertek__Address__c, buildertek__Zip__c, buildertek__Master_Project__c FROM buildertek__Project__c LIMIT 1];
        Inspection__c insRec = New Inspection__c(buildertek__Name__c ='Test', Project__c = project[0].buildertek__Master_Project__c);
        insert insRec;
        
        buildertek__Project__c projectRec2 = New buildertek__Project__c(Name = 'Test',
                                                                        buildertek__Master_Project__c = project[0].Id,
                                                                        buildertek__Source_Project__c = 'Test ~Purchase Order,Schedule,PunchList,Inspections,Warranty,Contract,Quote,Budget,Selection Sheet,Selection~ Test2');
        //Insert projectRec2; 
        buildertek__Purchase_Order__c PORec2 = New buildertek__Purchase_Order__c(buildertek__Project__c = projectRec2.buildertek__Master_Project__c,
                                                                                buildertek__Vendor__c = accRec.id); //[select id from buildertek__Purchase_Order__c limit 1];
        insert PORec2; 
        buildertek__Inspection__c inspRec = new buildertek__Inspection__c(buildertek__Project__c = projectRec2.buildertek__Master_Project__c,
                                                                          buildertek__Name__c = 'test');
        insert inspRec;
        
        //update projectRec2;
        Test.stopTest();
        
    }
}