/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Test Class: BT_AdminConfigurationControllerTest
* Created by Sagar
*
* Test class for BT_AdminConfigurationController

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
@isTest
private class BT_AdminConfigurationControllerTest {

    private static Admin_Interface_Node_Configuration__c  threeLevelConfiguration() {
        Admin_Interface_Node_Configuration__c nodeConfig = new Admin_Interface_Node_Configuration__c();
            nodeConfig.Name = 'File Control Admin';
            nodeConfig.Icon_URL__c = '/image/2.png';
            nodeConfig.Disable__c = false;
            nodeConfig.Index__C = 1;
            nodeConfig.Tab_Name__c = 'File Control Admin';
            nodeConfig.Description__c = 'Test description for File Control Admin.';
        insert nodeConfig;
        
        Admin_Interface_Node_Configuration__c firstChild = new Admin_Interface_Node_Configuration__c();
            firstChild.Parent_Node__c = nodeConfig.Id;
            firstChild.Name = 'Wizard Configuration';
            firstChild.Icon_URL__c = '/image/2.png';
            firstChild.Disable__c = false;
            firstChild.Tab_Name__c = 'Wizard Configuration';
            firstChild.Description__c = 'Test description for wizard configuration.';
        insert firstChild;
        
        
        Admin_Interface_Node_Configuration__c chdOfChd = new Admin_Interface_Node_Configuration__c();
            chdOfChd.Parent_Node__c = firstChild.Id;
            chdOfChd.Name = 'Folder Wizard';
            chdOfChd.Icon_URL__c = '/image/2.png';
            chdOfChd.Page_URL__c = '/apex/apBatchEditConfiguration';
            chdOfChd.Tab_Name__c = 'Folder Wizard';
            chdOfchd.Disable__c = false;
            chdOfchd.Description__c = 'Test description for wizard configuration.'; 
        insert chdOfchd;
        
        return chdOfchd;
    } 
     
    private static Admin_Interface_Node_Configuration__c  twoLevelConfiguration() {
         Admin_Interface_Node_Configuration__c secHomeNode = new Admin_Interface_Node_Configuration__c();
            secHomeNode.Name = 'File Control Files';
            secHomeNode.Icon_URL__c = '/image/2.png';
            secHomeNode.Disable__c = false;
            secHomeNode.Index__c = 2;
            secHomeNode.Tab_Name__c = 'File Control File';
            secHomeNode.Description__c = 'Test Description of File Control File.';
        insert secHomeNode;
        
        Admin_Interface_Node_Configuration__c chldOfSecHomeNode = new Admin_Interface_Node_Configuration__c();  
            chldOfSecHomeNode.Name = 'Mass Edit Configuration';
            chldOfSecHomeNode.Parent_Node__c = secHomeNode.Id;
            chldOfSecHomeNode.Icon_URL__c = '/image/2.png';
            chldOfSecHomeNode.Page_URL__c = '/apex/apMassEdit';
            chldOfSecHomeNode.Tab_Name__c = 'Mass Edit Configuration';
            chldOfSecHomeNode.Disable__c = false;
            chldOfSecHomeNode.Description__c = 'Test description for wizard configuration.';
        insert chldOfSecHomeNode;
        return  chldOfSecHomeNode;
    }
    
    private static Admin_Interface_Node_Configuration__c  oneLevelConfiguration() {
         Admin_Interface_Node_Configuration__c frtHomeNode = new Admin_Interface_Node_Configuration__c();
            frtHomeNode.Name = 'System Configuration';
            frtHomeNode.Icon_URL__c = '/image/2.png';
            frtHomeNode.Disable__c = false;
            frtHomeNode.Index__c = 2;
            frtHomeNode.Tab_Name__c = 'System Configuration';
            frtHomeNode.Description__c = 'Test Description of System Configuration.';
        insert frtHomeNode;
        return frtHomeNode;
    }
    
    private static Admin_Interface_Node_Configuration__c  oneLevelConfigurationWithOthLink() {
         Admin_Interface_Node_Configuration__c frtHomeNode = new Admin_Interface_Node_Configuration__c();
            frtHomeNode.Name = 'Google';
            frtHomeNode.Disable__c = false;
            frtHomeNode.Icon_URL__c = '/image/2.png';
            frtHomeNode.Index__c = 5;
            frtHomeNode.Page_URL__c = 'https://www.google.com';
            frtHomeNode.Tab_Name__c = 'Google';
            frtHomeNode.Description__c = 'Test Description of Google.';
        insert frtHomeNode;
        return frtHomeNode;
    }
    
    static testMethod void openTabTest() {
        Admin_Interface_Node_Configuration__c nc1 = oneLevelConfiguration();
        Admin_Interface_Node_Configuration__c nc2 = twoLevelConfiguration();
        Admin_Interface_Node_Configuration__c nc3 = threeLevelConfiguration();
        
        BT_AdminConfigurationController controller = new BT_AdminConfigurationController();
        controller.fillNodeConfigurationList();
        controller.fillMainPanelWithTabs();
        system.assertEquals(6,controller.listNodeConfigurations.size());
        Apexpages.currentPage().getParameters().put('prmParentNodeId', nc1.Id);
        controller.openChildNodeTab();
    }
    
    static testMethod void closeTabTest(){
        Admin_Interface_Node_Configuration__c nc1 = oneLevelConfiguration();
        BT_AdminConfigurationController controller = new BT_AdminConfigurationController(); 
        Apexpages.currentPage().getParameters().put('prmCloseTabId', nc1.Id);
        Apexpages.currentPage().getParameters().put('prmNextNodeId', nc1.Id);
        controller.closeTab(); 
        system.assertEquals(controller.strOpenedTabIds, 'Home,');
    }
    
    static testMethod void openVfTabTest(){
        Admin_Interface_Node_Configuration__c nc1 = oneLevelConfigurationWithOthLink();
        Admin_Interface_Node_Configuration__c nc2 = twoLevelConfiguration();
        Admin_Interface_Node_Configuration__c nc3 = threeLevelConfiguration();
        
        BT_AdminConfigurationController controller = new BT_AdminConfigurationController();
        Apexpages.currentPage().getParameters().put('prmPageUrl', nc2.Page_URL__c);
        Apexpages.currentPage().getParameters().put('prmPageTabeName', nc2.Tab_Name__c);
        Apexpages.currentPage().getParameters().put('prmPageTabId', nc2.Id);        
        controller.openVFPageTab();
        system.assert(controller.strOpenedTabIds != Null);
        
        Apexpages.currentPage().getParameters().put('prmPageUrl', nc3.Page_URL__c);
        Apexpages.currentPage().getParameters().put('prmPageTabeName', nc3.Tab_Name__c);
        Apexpages.currentPage().getParameters().put('prmPageTabId', nc3.Id);
        controller.openVFPageTab();
        system.assert(controller.strOpenedTabIds != Null);
        
        Apexpages.currentPage().getParameters().put('prmPageUrl', nc1.Page_URL__c);
        Apexpages.currentPage().getParameters().put('prmPageTabeName', nc1.Tab_Name__c);
        Apexpages.currentPage().getParameters().put('prmPageTabId', nc1.Id);
        controller.openVFPageTab();
        system.assert(controller.strOpenedTabIds != Null);
    }
    
    static testMethod void initializeTest(){
        Pagereference pg = BT_AdminConfigurationController.reset();
        system.assert(pg != null);  
        BT_AdminConfigurationController.initialize();
        BT_AdminConfigurationController controller = new BT_AdminConfigurationController();
        Pagereference initializeOrgPg = controller.initializeNewOrg();
        system.assert(initializeOrgPg != null);
    }
}