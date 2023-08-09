/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Test Class: BT_FileManagementConfigControllerTest
* Created by Sagar - 03/09/2017
*
*  This  is test class for BT_FileManagementConfigurationController.
*
* - Modifications:
* - Sagar – 03/09/2017 - Initial Development
************************************************************************** */
@isTest
public class BT_FileManagementConfigControllerTest {
	static testMethod void fileManagementConfiguratiomTest() {
        
        Test.StartTest();
        
        // Configuration without any existing record
    	BT_FileManagementConfigurationController objController = new BT_FileManagementConfigurationController();
        objController.save();
        objController.init();
        // Initialize configuration
        Test.setCurrentPageReference(new PageReference('Page.BT_FileManagementConfiguration'));
        objController.Intialize();
        
        // Configuration with existing record
        objController = new BT_FileManagementConfigurationController();
        // Set permission
        objController.selectedPermissions = new List<String>{'isOwner'};
        // Save configration
        objController.save();
        
        System.assertEquals( objController.fileManagementConfiguration.Delete_Permissions__c, 'isOwner');
        
        Test.StopTest();
        
    }
}