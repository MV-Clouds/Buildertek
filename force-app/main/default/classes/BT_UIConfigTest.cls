/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: BT_UIConfigTest
* Created by Sagar: 06/07/2017
*
* Test class for BT_UIConfig

* - Modifications:
* - Sagar, 14/09/2017 – Initial Development
************************************************************************** */
@isTest
public with sharing class BT_UIConfigTest {
    @testSetup static void insertTestData(){
        List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
        System.assertEquals(buckets.size() > 0, true);
    }
    static testMethod void testMessageAndIcon() {
        BT_UIConfig.getConfiguredName(BT_Constants.MSG_NO_RECORDS_FOUND, null);
        System.assertEquals(BT_UIConfig.getConfiguredName(BT_Constants.MSG_NO_RECORDS_FOUND, null) != '', true);
        System.assertEquals(BT_UIConfig.getNodeIconImage(null, true, null, null, null), '');
        Folder__c folder = [Select id, Name from Folder__c Limit 1];
        System.assertEquals(BT_UIConfig.getNodeIconImage('Folder__c', false, folder.Id, null, folder), '');
        // Create files under bucket
        List<File__c> files = BT_TestUtils.createFiles(folder, null);
        System.assertEquals(BT_UIConfig.getNodeIconImage('File__c', false, files[0].Id, null, files[0]), 'fileIcons/png.png');
        files[0].Extension__c = '.pdf';
        System.assertEquals(BT_UIConfig.getNodeIconImage('File__c', false, files[0].Id, null, files[0]), 'fileIcons/pdf.png');
        System.assertEquals(BT_UIConfig.getNodeIconImage('User', false, null, null, null), 'icons/asset-people.png');
        System.assertEquals(BT_UIConfig.getNodeIconImage('Group', false, null, null, null), 'icons/Dark_Blue_Bg.png');
        System.assertEquals(BT_UIConfig.getNodeIconImage('Account', false, null, null, null), 'icons/Account.png');
        System.assertEquals(BT_UIConfig.getNodeIconImage('Contact', false, null, null, null), 'icons/Dark_Blue_Bg.png');
    }
}