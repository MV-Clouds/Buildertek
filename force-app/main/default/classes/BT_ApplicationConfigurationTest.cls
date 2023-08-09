/* **************************************************************************
* Copyright 2017-2018, BuilderTek
* All rights reserved
*
* Test Class: BT_ApplicationConfigurationTest
* Created by Sagar
*
* Test class for  BT_ApplicationConfiguration

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
private class BT_ApplicationConfigurationTest {
    @testSetup static void setup() {
       
        Folder__c lstFolderBucket2 = new Folder__c(Name='TEST2',buildertek__Description__c='Test Description',buildertek__Default__c=true,buildertek__Bucket_Name__c='Bt Test',Active__c=false);
        insert lstFolderBucket2;
        Folder__c lstFolderBucket = new Folder__c(Name='Test1',buildertek__Description__c='Test Description',buildertek__Default__c=true,buildertek__Bucket_Name__c='Bt Test',Active__c=true);
        insert lstFolderBucket;
        Amazon_S3_Key__c amazon=new Amazon_S3_Key__c(Name='Test',buildertek__Description__c='Test Description',buildertek__Label__c='TESt'); 
        insert amazon;
    }
  
    static testMethod void testInitSystem() {
        
        BT_ApplicationConfigurationController controller = new BT_ApplicationConfigurationController();
          
        controller.Initialize(); 

        // Verify control application configuation
        Map<String, Amazon_S3_Key__c> applicationConfigurationMap = Amazon_S3_Key__c.getAll();
        Amazon_S3_Key__c url = applicationConfigurationMap.get(BT_Constants.AWS_PUBLIC_KEY);
        System.assert(url != null);
        System.assertEquals('Test','Test');
        List<BT_ApplicationConfigurationController.WrappedAppConfig> apps = controller.getApplicationConfigurationData();
        System.assert(apps != null);
          
        Application_Configuration__c testapp = new Application_Configuration__c(name = 'Use Files', Configured_Value__c ='True', Description__c = 'Use files', Display_Layout__c = 'Radio');
        insert testapp;
        controller.save();
        controller.mapBuckets();
        controller.getConfiguredBuckets();            
        controller.mapBuckets();
        controller.getBucketsToMap();
        controller.createNewBucket();
        controller.showNewBucket();
        controller.hideNewBucket();
        controller.removeBucketMap();
        controller.getAmazonBucketsToMap();
        System.assertEquals('Use Files', testapp.Name);              
        List<Selectoption> options = controller.getRadioOptions();
        System.assertEquals(2, options.size());
        System.assertEquals('Test','Test');      
    
        
    }
    static testMethod void testInitSystem1() {
        
        BT_ApplicationConfigurationController controller = new BT_ApplicationConfigurationController();
          
        controller.Initialize(); 

        // Verify control application configuation
        Map<String, Amazon_S3_Key__c> applicationConfigurationMap = Amazon_S3_Key__c.getAll();
        Amazon_S3_Key__c url = applicationConfigurationMap.get(BT_Constants.AWS_PUBLIC_KEY);
        System.assert(url != null);
        System.assertEquals('Test','Test');
        Amazon_S3_Key__c url1 = applicationConfigurationMap.get(BT_Constants.MAX_FILE_SIZE);
        System.assert(url1 == null);
        System.assertEquals('','');
        List<BT_ApplicationConfigurationController.WrappedAppConfig> apps = controller.getApplicationConfigurationData();
        System.assert(apps != null);
          
        Application_Configuration__c testapp = new Application_Configuration__c(name = 'Use Files', Configured_Value__c ='', Description__c = 'Use files', Display_Layout__c = 'Radio');
        insert testapp;
        controller.save();
        controller.mapBuckets();
        controller.getConfiguredBuckets();            
        controller.mapBuckets();
        controller.getBucketsToMap();
        controller.createNewBucket();
        controller.showNewBucket();
        controller.hideNewBucket();
        controller.removeBucketMap();
        controller.getAmazonBucketsToMap();
        System.assertEquals('Use Files', testapp.Name);              
        List<Selectoption> options = controller.getRadioOptions();
        System.assertEquals(2, options.size());
        System.assertEquals('Test','Test');      
    
        
    }
    
   
    
}