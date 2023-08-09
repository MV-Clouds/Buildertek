/* **************************************************************************
* Copyright 2017-2018, BuilderTek
* All rights reserved
*
* Test Class: TreeConfigurationDAOTest
* Created by Sagar: 16/09/2017
* - Modifications:
* - Sagar, 16/09/2017 – Initial Development 
************************************************************************** */
@isTest
public with sharing class TreeConfigurationDAOTest {
    static testMethod void testCeateRetrieveTreeConfigurations() {
        Tree_Configuration__c testFileTreeConfig = new Tree_Configuration__c(name='TestFilesTree', tree_type__c='Test_Files_Type', Show_System_Default_Tree_Nodes__c=true);
        insert testFileTreeConfig;
        
        
        Tree_Node_Configuration__c testFileTreeNodeConfig1 = new Tree_Node_Configuration__c(name='Test Files by Access Type',
                                                                        Caption__c='Test Files by Access Type',
                                                                        Disabled__c=false,
                                                                        Child_Object_Type__c='File__c',
                                                                        Caption_Field_Name__c='Access_Type__c',
                                                                        Query_String__c=null,
                                                                        Show_Children_as_tree_nodes__c=true,
                                                                        Show_this_configuration_node_in_tree__c=true,
                                                                        Tree_Configuration__c = testFileTreeConfig.id);
        insert testFileTreeNodeConfig1;
        
        Tree_Node_Configuration__c testFileTreeNodeConfig2 =
                new Tree_Node_Configuration__c(name = 'Test Files by Extension',
                                              Parent__c = testFileTreeNodeConfig1.Id,
                                              Tree_Configuration__c = testFileTreeConfig.Id,
                                              Caption__c= 'By Extension',
                                              Caption_Field_Name__c = 'Extension__c',
                                              Child_Object_Type__c = 'File__c',
                                              Description__c = null,
                                              Disabled__c = false,
                                              Query_String__c = null,
                                              Show_Children_As_Tree_nodes__c = true,
                                              Show_This_Configuration_Node_In_Tree__c = true,
                                              Sort_Id__c = null,
                                              Type__c = BT_Constants.TREE_NODE_TYPE_GROUPBY_ROOT);
        insert testFileTreeNodeConfig2;
                                                                
        Tree_Configuration__c fileTreeConfiguration = TreeConfigurationDAO.getDTC('Test_Files_Type');
        System.assertEquals(fileTreeConfiguration.name, 'TestFilesTree');
        System.assertEquals(fileTreeConfiguration.tree_type__c, 'Test_Files_Type');
        System.assertEquals(fileTreeConfiguration.Show_System_Default_Tree_Nodes__c, true);
        
        fileTreeConfiguration = TreeConfigurationDAO.getDTCByName('TestFilesTree');    
        System.assertEquals(fileTreeConfiguration.name, 'TestFilesTree');
            
        List<Tree_Node_Configuration__c> fileTreeNodeConfigurations = TreeConfigurationDAO.getTNCByTCId(fileTreeConfiguration.id);
        System.assertEquals(2, fileTreeNodeConfigurations.size());
        
        Tree_Node_Configuration__c fileTreeNodeConfiguration = fileTreeNodeConfigurations.get(0);
        System.assertEquals(fileTreeNodeConfiguration.name, 'Test Files by Access Type');
        System.assertEquals(fileTreeNodeConfiguration.Child_Object_Type__c, 'File__c');
        System.assertEquals(fileTreeNodeConfiguration.Caption_Field_Name__c, 'Access_Type__c');
        System.assertEquals(fileTreeNodeConfiguration.Disabled__c, false);
        System.assertEquals(fileTreeNodeConfiguration.Query_String__c, null);
        System.assertEquals(fileTreeNodeConfiguration.Show_this_configuration_node_in_tree__c, true);
        
        Tree_Node_Configuration__c treeNodeConfigurationById = TreeConfigurationDAO.getTNCById(fileTreeNodeConfiguration.Id);
        System.assertEquals(treeNodeConfigurationById.name, 'Test Files by Access Type');
        
        fileTreeNodeConfigurations = TreeConfigurationDAO.getChildrenTNC(treeNodeConfigurationById.id);
        System.assertEquals(1, fileTreeNodeConfigurations.size());
        
        fileTreeNodeConfigurations = TreeConfigurationDAO.getTopLevelTNCByTCId(fileTreeConfiguration.id);
        System.assertEquals(1, fileTreeNodeConfigurations.size());
        

        Tree_Configuration__c notSpecifiedTreeConfiguration = TreeConfigurationDAO.getDTC('NA');
        System.assertEquals(notSpecifiedTreeConfiguration, null);
        
    }
}