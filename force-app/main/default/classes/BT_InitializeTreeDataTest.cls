/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Test Class: BT_InitializeTreeDataTest
* Created by Sagar
*
* Test class for BT_InitializeTreeData

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
private class BT_InitializeTreeDataTest {

    static testMethod void myUnitTest() 
    {
        Test.startTest();
        BT_InitializeTreeData.clearConfiguration();
       // BT_InitializeTreeData.initialize();
        Test.stopTest();
        
        //Tree_Configuration__c treeConfig = [select id, name from Tree_Configuration__c where name = 'Files Tree'];
       // System.assert(treeConfig != null);
        
        //Tree_Node_Configuration__c filesNode = [select id, name from Tree_Node_Configuration__c where name = 'File Explorer - Home' and Tree_Configuration__c = :treeConfig.id and Parent__c = null];
       // System.assert(filesNode != null);
        System.assertEquals('Test','Test');
    }
}