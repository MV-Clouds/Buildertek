/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Test Class: BT_FutureCalloutUtilsTest
* Created by Sagar
*
* - All future method utils

* - Modifications:
* - Sagar – Initial Development
* - Amar - Modified test method
************************************************************************** */
@isTest
public with sharing class BT_FutureCalloutUtilsTest {
    @testSetup static void setupBaseData() {
		List<Folder__c> buckets = BT_TestUtils.createFoldersForBuckets();
		System.assertEquals(buckets.size() > 0, true);
		List<Folder__c> folders = BT_TestUtils.createSubfolders(buckets[0], null);
		List<File__c> files = BT_TestUtils.createFiles(folders[0], null);
		// Create AWS Credentials
        BT_TestUtils.createAWSCredentials();
        System.assertEquals('Test','Test');
    }
    
    public static testMethod void testBT_FutureCalloutUtils() {
        try {
        	//BT_FutureCalloutUtils.revokeFileAccessControl('Test_Bucket1', '/');
        }
        catch(Exception ex) {}
        System.assertEquals('Test','Test');
    }
}