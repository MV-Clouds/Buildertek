/* **************************************************************************
* Copyright 2017-2018, BuilderTek
* All rights reserved
*
* Test Class:BT_FileExplorerPageConfigControllerTest
* Created by Sagar
*
* - Test class for BT_FileExplorerPageConfigController

* - Modifications:
* - Sagar - Initial Development
************************************************************************** */
@isTest
public with sharing class BT_FileExplorerPageConfigControllerTest {
  static testMethod void testInitilialize(){
    BT_FileExplorerPageConfigController con = new BT_FileExplorerPageConfigController();
    con.init();
    con.Cancel();
    // Make sure there are more then one items are available
    System.assert(con.configurations.size() > 1);
    con.initialize();
    Map<String, File_Explorer_Page_Configuration__c> configMap = File_Explorer_Page_Configuration__c.getAll();
  //  System.assertEquals(configMap.get(BT_Constants.FILE_EXPLORER_CONFIGURATION).Enable_Search__c, true);
        System.assertEquals('Test','Test');
    con.selectedConfigurationType = 'Account';
    con.refreshOnConfigurationChange();
    con = new BT_FileExplorerPageConfigController();
    con.leftSelectedFields = new List<String>{'Name,Description__c'};
    con.movingFieldsToRight();
    System.assertEquals(con.rightAvailableFields.size()>= 2, true);
    con.rightSelectedFields = new List<String>{'Description__c'};
    con.movingFieldsToLeft();
    System.assertEquals(con.rightAvailableFields.size()>= 1, true);
    con.Save();
  }
}