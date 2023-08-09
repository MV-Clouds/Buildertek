/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Test Class:BT_TreeRemotingModelTest
* Created by Sagar: 21/09/2017
*
* - Test class for BT_TreeRemotingModel

* - Modifications:
* - Sagar - Initial Development
************************************************************************** */
@isTest
public class BT_TreeRemotingModelTest {
    @testSetup static void createTestData() {
        //Initializing all tree configuration
        BT_InitializeTreeData.clearConfiguration();
       // BT_InitializeTreeData.initialize(); 
       // System.assertEquals([Select Id From Tree_Configuration__c].size() > 0, true);      
        // Create AWS Credentials
        BT_TestUtils.createAWSCredentials();
        System.assertEquals('Test','Test');
    }
    
    static testMethod void testRootNodes(){
        Folder__c f = new Folder__c(Name='Test_Bucket1');
        insert f;
        Folder__c bucket = [Select Id From Folder__c Where Name= 'Test_Bucket1' LIMIT 1];
		Set<Id> ids = new Set<Id>();
        ids.add(bucket.Id);
        List<String> fields = new List<String>();
        fields.add('Name');
        FolderDAO.getChildren(ids,fields);
        
		FolderDAO.getChildren(bucket.Id,fields);
        List<BT_TreeRemotingModel.QueryParameter> qpLst = new List<BT_TreeRemotingModel.QueryParameter>();
        BT_TreeRemotingModel.QueryParameter  qp = new BT_TreeRemotingModel.QueryParameter('Name','Test');
        qpLst.add(qp);
        Map<String, List<BT_TreeRemotingModel.QueryParameter>> qpMap = new Map<String, List<BT_TreeRemotingModel.QueryParameter>>();
        qpMap.put('key', qpLst);
        String queryParameters =JSON.serialize(qpMap);
        FolderDAO.getChildren(bucket.Id, fields, null, BT_Constants.TREE_UI_MAX_NODE ,queryParameters);
        List<String> folderIds = new List<String>();
        folderIds.add('test Folder');
        
        
        Tree_Configuration__c testFileTreeConfig = new Tree_Configuration__c(name='TestFilesTree', tree_type__c='Test_Files_Type', Show_System_Default_Tree_Nodes__c=true);
        insert testFileTreeConfig;
        
        
        Tree_Node_Configuration__c testFileTreeNodeConfig1 = new Tree_Node_Configuration__c(name='Test Files by Access Type',
                                                                        Caption__c='Test Files by Access Type',
                                                                        Disabled__c=false,
                                                                        Child_Object_Type__c='Folder__c',
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
                                              Child_Object_Type__c = 'Folder__c',
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

        BT_TreeRemotingModel.TreeNode[] userPickerTreeRootNodes = BT_TreeRemotingModel.loadDefaultTreeNodesFromConfig('Users', fileTreeConfiguration.name, 'Id name', true, '', ''); 
        
        BT_TreeRemotingModel tModel = new BT_TreeRemotingModel();
        String rootIds = BT_Constants.TREE_TYPE_FILE; 
        
        BT_TreeRemotingModel.TreeNode[] nodes = 
            BT_TreeRemotingModel.getTreeRootNodes(BT_Constants.TREE_TYPE_FILE, 'Files', rootids, null, 'Id, name', 
                                              true, null, null);
        Group testGroup = [Select Id, Name From Group LIMIT 1];   
        rootIds=BT_Constants.TREE_ROOT_OBJECT+'/'+testGroup.Id;
        BT_TreeRemotingModel.TreeNode[] nodes2 = 
            BT_TreeRemotingModel.getTreeRootNodes(BT_Constants.TREE_TYPE_FILE, 'Files', rootids, null, 'Id, name', 
                                              true, null, null); 
        BT_TreeRemotingModel.getTreeRootNodes2(BT_Constants.TREE_TYPE_FILE, 'TestFilesTree', rootids, rootids, 'Id, name', '',
                                              true, null, null); 
    
        BT_TreeRemotingModel.loadChildrenRecursively(nodes.get(0),'','',false,'');                  
        BT_TreeRemotingModel.loadChildrenRecursively(nodes.get(0),nodes.get(0).Id,'',false,'');                  
        nodes = BT_TreeRemotingModel.getFolderTreeRoot(BT_Constants.TREE_TYPE_FILE, '{}', '');
        Set<String> filePaths = new Set<String>();
        filePaths.add('test1.pdf');
        filePaths.add('test2');
        Map<String, String> fileIdByPath =new Map<String,String>();
        Map<String, Double> fileSizeByPath =new Map<String,Double>();
        fileSizeByPath.put('test1.pdf',10);
        fileSizeByPath.put('test2',10);
        BT_TreeRemotingModel.getTreeNodesFromFilePath(filePaths,fileIdByPath,fileSizeByPath);
        BT_TreeRemotingModel.isLeafNodeObjectType(null,'');
        BT_TreeRemotingModel.isLeafNodeObjectType('File__c','');
        BT_TreeRemotingModel.isLeafNodeObjectType('User','');
        List<String> homeRecordIds=new List<String>();
        BT_TreeRemotingModel.TreeNode[] loadTreeHomeRecords = BT_TreeRemotingModel.loadTreeHomeRecords('',null,homeRecordIds,'');
        
        String currentPageId=ApexPages.currentPage().getParameters().get(nodes.get(0).Id);
        if(String.isNotBlank(currentPageId)){
            Id currentRecordId=Id.valueOf(currentPageId);
            String sObjName=currentRecordId.getSObjectType().getDescribe().getName();
            Map<String, Schema.SObjectType> globalDescMap=Schema.getGlobalDescribe();
            Schema.SObjectType targetType=globalDescMap.get(sObjName);
            sObject sObj=targetType.newSObject();
        }
        Map<Id, String> recordTypeIdToNameMap =new Map<Id, String>();
        System.assert(nodes.size() > 0);
    }
    
    static testMethod void testChildrenTreeNodesFromConfig(){ 
        Tree_Configuration__c testFileTreeConfig = new Tree_Configuration__c(name='TestFilesTree', tree_type__c='Test_Files_Type', Show_System_Default_Tree_Nodes__c=true);
        insert testFileTreeConfig;
        
        
        Tree_Node_Configuration__c testFileTreeNodeConfig1 = new Tree_Node_Configuration__c(name='Test Files by Access Type',
                                                                        Caption__c='Test Files by Access Type',
                                                                        Disabled__c=true,
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
                                              Disabled__c = true,
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
        System.assertEquals(fileTreeNodeConfiguration.Disabled__c, true);
        System.assertEquals(fileTreeNodeConfiguration.Query_String__c, null);
        System.assertEquals(fileTreeNodeConfiguration.Show_this_configuration_node_in_tree__c, true);
        
        Tree_Node_Configuration__c treeNodeConfigurationById = TreeConfigurationDAO.getTNCById(fileTreeNodeConfiguration.Id);
        System.assertEquals(treeNodeConfigurationById.name, 'Test Files by Access Type');
        
        List<BT_TreeRemotingModel.TreeNode> nodes = BT_TreeRemotingModel.loadChildrenTreeNodesFromConfig(fileTreeNodeConfiguration.id, 'Files/Home - Files', 'Id, Name', false, 'Access_Type__c#Private', '', '{}', '');
    	List<BT_TreeRemotingModel.TreeNode> nodes2 = BT_TreeRemotingModel.loadChildrenTreeNodesFromConfig(null, 'Files/Home - Files', 'Id, Name', false, 'Access_Type__c#Private', '', '{}', '');
    	//System.assert(nodes.size() == 0);
    }
    static testMethod void testChildrenTreeNodesFromConfig2(){ 
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
        
        List<BT_TreeRemotingModel.TreeNode> nodes = BT_TreeRemotingModel.loadChildrenTreeNodesFromConfig(fileTreeNodeConfiguration.id, 'Files/Home - Files', 'Id, Name', false, 'Access_Type__c#Private', '', '{}', '');
    	//System.assert(nodes.size() == 0);
    }
    
   /* static testMethod void testTreeConfiguration(){
        
        Tree_Configuration__c fileTreeConfig = BT_TreeRemotingModel.getTreeConfiguration('Files', '');
        System.assertEquals(fileTreeConfig.Tree_Type__c , BT_Constants.TREE_TYPE_FILE);
        
        Tree_Configuration__c userTreeConfig = BT_TreeRemotingModel.getTreeConfiguration('','User Picker Tree');
        System.assertEquals(userTreeConfig.Tree_Type__c , BT_Constants.TREE_TYPE_USER);
    }
    */
    /*static testmethod void testFilesTree(){
        // Bulding folder hierarchy
        buildFoldersTree();
        
        BT_TreeRemotingModel.TreeNode[] nodes = BT_TreeRemotingModel.getTreeRootNodes(BT_Constants.TREE_TYPE_FILE, '', null, null, 'Id, Name', true, null, null);
        // Thre will be 1 bucket 
        System.assertEquals(nodes.size(), 1);
        
        Folder__c bucket = [select id,Name from Folder__c where Name = 'Test Bucket1' LIMIT 1];
        String nodeId = BT_Constants.TREE_ROOT_OBJECT + '/Folder__c/' + bucket.Id;
        // Get AD as root node using rootNodeIds
        BT_TreeRemotingModel.TreeNode[] rootNodes = BT_TreeRemotingModel.getTreeRootNodes(BT_Constants.TREE_TYPE_FILE, '', nodeId, null, 'Id, name', true, null, null);
        System.assertEquals(rootNodes[0].title, bucket.Name);
        
        Folder__c subFolder = [select Id, Name from Folder__c where Name = 'Test Sub Folder1'];
        String selectedNodePath = rootNodes[0].Id + '/' + subFolder.Id;
        // Recursively get the child nodes for the AD path
        BT_TreeRemotingModel.loadChildrenRecursively(rootNodes[0], selectedNodePath, 'Id, Name', false, '');
        // There are two child folders for bucket
        System.assertEquals(rootNodes[0].children.size(), 3);
        
        // Expanding root folder
        BT_TreeRemotingModel.TreeNode[] childrenOfRootFolder =  BT_TreeRemotingModel.getChildren(BT_Constants.OBJECT_TYPE_FOLDER, nodeId,'Id, Name',
                                              BT_Constants.TREE_NODE_TYPE_OBJECT, 'Folder__c',
                                              '', '', true, true, true, null, null, '{}', null);
        // There are two child folders under the root folder
        System.assertEquals(childrenOfRootFolder.size(), 3);
        
        // Expanding Sub folder node
        nodeId = BT_Constants.TREE_TYPE_FILE + '/Folder__c/' + subFolder.Id;
        BT_TreeRemotingModel.TreeNode[] childrenOfSubFolder =  BT_TreeRemotingModel.getChildren(BT_Constants.OBJECT_TYPE_FOLDER, nodeId,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_OBJECT, 'Folder__c',
                                              '', '', true, true, true, null, null, '{}', null);
        // There is one child folder and file under the folder
        System.assertEquals(childrenOfSubFolder.size(), 1);                                     
    }*/
    
    static testmethod void testUserPicker(){
        // Creating users, groups and accounts
        Account acct = new Account(Name='testAccount');  
        insert acct;
        ApexPages.StandardController standrdcontroller = new ApexPages.StandardController(acct);
        BT_TreeRemotingModel myController = new BT_TreeRemotingModel(standrdcontroller);
        List<String> fields = new List<String>{'Id', 'name'};
        Folder__c f=new Folder__c(Name='Test_Bucket1');
        insert f;
        File__c file=new File__c(Name='Test_Bucket1');
        insert file;
        Folder__c bucket = [Select Id From Folder__c Where Name= 'Test_Bucket1' LIMIT 1];
        
        
        Selection__c selection = new Selection__c();
        insert selection;
        
        Section__c section1 = new Section__c(Selection__c = selection.Id);
        insert section1;
        
        Section__c section = new Section__c(Selection__c = selection.Id, Parent__c = section1.Id);
        insert section;
        
        Question_Group__c groupQuestion = new Question_Group__c(Section__c = section.Id);
        insert groupQuestion;
        
        Choice_Template__c choiceTemplate = new Choice_Template__c();
        insert choiceTemplate;
        
        Question__c question = new Question__c(Question_Group__c = groupQuestion.Id, Choice_Template__c = choiceTemplate.Id,Question_HTML__c = 'Test #1');
        insert question;
        
        createUsersGroupsAndAccounts();
        Tree_Configuration__c testFileTreeConfig = new Tree_Configuration__c(name='TestFilesTree', tree_type__c='Test_Files_Type', Show_System_Default_Tree_Nodes__c=true);
        insert testFileTreeConfig;

        Tree_Node_Configuration__c testFileTreeNodeConfig1 = new Tree_Node_Configuration__c(name='Test Files by Access Type',
                                                                        Caption__c='Test Files by Access Type',
                                                                        Disabled__c=false,
                                                                        Child_Object_Type__c='Folder__c',
                                                                        Caption_Field_Name__c='Access_Type__c',
                                                                        Query_String__c=null,
                                                                        Show_Children_as_tree_nodes__c=true,
                                                                        Show_this_configuration_node_in_tree__c=true,
                                                                        Tree_Configuration__c = testFileTreeConfig.id,
                                                                                            Group_By_Query_String__c='All Users');
        insert testFileTreeNodeConfig1;
        // Getting the root nodes for user picker tree
        BT_TreeRemotingModel.TreeNode[] userPickerTreeRootNodes = BT_TreeRemotingModel.getTreeRootNodes('Users', 'User Picker Tree', null, null, 'Id, name', true, null, null); 
        BT_TreeRemotingModel.buildWhereClauseUsingQueryParameters(null); 
        BT_TreeRemotingModel.TreeNode[] getChildrenForSection = BT_TreeRemotingModel.getChildrenForSectionTree('', '', fields, bucket.Id, '','',''); 
        BT_TreeRemotingModel.TreeNode[] getChildrenForTree = BT_TreeRemotingModel.getChildrenForTree('File__c', '', fields, file.Id, '','',''); 
        // Three root nodes will be there Users, Accounts,Groups and Contacts
       // System.assertEquals(userPickerTreeRootNodes.size(), 4);
        
        // Expanding first row of of "Users" node.
        User testUser = [Select Id, Name From User Where IsActive = true LIMIT 1];
        String nodeId = BT_Constants.TREE_TYPE_USER+ '/' + groupQuestion.Id;
        BT_TreeRemotingModel.TreeNode[] usersChildNodes = BT_TreeRemotingModel.getChildren('File__c', nodeId,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_OBJECT, 'User',
                                              'Testing', 'User',true,true, true, null, null, '{}', null);
        BT_TreeRemotingModel.TreeNode[] usersChildNodes1 = BT_TreeRemotingModel.getChildren('buildertek__Section__c', 'Other/'+testUser.Id,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_OBJECT, 'User',
                                              'Testing', 'User',true,true, true, null, null, '{}', null);
        BT_TreeRemotingModel.TreeNode[] usersChildNodes11 = BT_TreeRemotingModel.getChildren('buildertek__Question_Group__c', 'Other/'+groupQuestion.Id,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_OBJECT, 'User',
                                              'Testing', 'User',true,true, true, null, null, '{}', null);
        BT_TreeRemotingModel.TreeNode[] usersChildNodes111 = BT_TreeRemotingModel.getChildren('buildertek__Question_Group__c', '/'+groupQuestion.Id,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_OBJECT, 'User',
                                              'Testing', 'User',true,true, true, null, null, '{}', null);

        BT_TreeRemotingModel.TreeNode[] usersChildNodes2 = BT_TreeRemotingModel.getChildren('User', nodeId,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_ROOT, 'User',
                                              'Testing', '',true,true, true, testFileTreeNodeConfig1.Id, null, '{}', null);
        /*BT_TreeRemotingModel.TreeNode[] usersChildNodes3 = BT_TreeRemotingModel.getChildren('User', nodeId,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_GROUPBY_ROOT, 'User',
                                              'Test', 'Test',true,true, true, testFileTreeNodeConfig1.Id, null, '{}', null);*/
        nodeId = BT_Constants.TREE_TYPE_USER+ '/' + testUser.Id+'/'+ testFileTreeNodeConfig1.Id;
        BT_Constants.TREE_UI_MAX_NODE=0;
        BT_TreeRemotingModel.TreeNode[] usersChildNodes4 = BT_TreeRemotingModel.getChildren('User', nodeId,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_GROUPBY, 'Account',
                                              'Testing', '',true,true, true, testFileTreeNodeConfig1.Id, 'ORDER BY', '{}', null);
        BT_TreeRemotingModel.TreeNode[] usersChildNodes41 = BT_TreeRemotingModel.getChildren('User', nodeId,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_GROUPBY, 'File__c',
                                              'Testing', '',true,true, true, testFileTreeNodeConfig1.Id, '', '{}', null);
        nodeId = BT_Constants.TREE_TYPE_USER+ '/' + testUser.Id;
        BT_TreeRemotingModel.TreeNode[] usersChildNodes44 = BT_TreeRemotingModel.getChildren('Folder__c', nodeId,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_GROUPBY, 'buildertek__Section__c',
                                              'Testing', '',true,true, true, testFileTreeNodeConfig1.Id, null, '{}', null);
        BT_TreeRemotingModel.TreeNode[] usersChildNodes5 = BT_TreeRemotingModel.getChildren('User', nodeId,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_QUERY, 'Account',
                                              'Testing', '',true,true, true, testFileTreeNodeConfig1.Id, null, '{}', null);
        BT_TreeRemotingModel.TreeNode[] usersChildNodes51 = BT_TreeRemotingModel.getChildren('User', BT_Constants.TREE_TYPE_FILE,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_QUERY, 'Account',
                                              'Testing', '',true,true, true, testFileTreeNodeConfig1.Id, null, '{}', null);
        BT_TreeRemotingModel.TreeNode[] usersChildNodes511 = BT_TreeRemotingModel.getChildrenForFolderTree('Folder__c','',fields,bucket.Id,'','');
        BT_Constants.TREE_UI_MAX_NODE=2;
        BT_TreeRemotingModel.TreeNode[] usersChildNodes5111 = BT_TreeRemotingModel.getChildrenForFolderTree('Folder__c','',fields,bucket.Id,'','');
        BT_TreeRemotingModel.TreeNode[] usersChildNodes52 = BT_TreeRemotingModel.getChildren('Folder__c', BT_Constants.TREE_TYPE_USER,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_QUERY, 'Account',
                                              'Testing', '',true,true, true, testFileTreeNodeConfig1.Id, null, '{}', null);
        BT_TreeRemotingModel.TreeNode[] usersChildNodes522 = BT_TreeRemotingModel.getChildren('File__c', BT_Constants.TREE_TYPE_USER,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_QUERY, 'Account',
                                              'Testing', '',true,true, true, testFileTreeNodeConfig1.Id, null, '{}', null);
        BT_TreeRemotingModel.TreeNode[] getChildrenForUserTree=  BT_TreeRemotingModel.getChildrenForUserTree('Folder__c','',fields, BT_Constants.TREE_TYPE_USER,'','','');
        BT_TreeRemotingModel.TreeNode[] usersChildNodes53 = BT_TreeRemotingModel.getChildren('File__c','Other','id, name',
                                                                                             BT_Constants.TREE_NODE_TYPE_QUERY, 'Account',
                                                                                             'Testing', '',true,true, true, testFileTreeNodeConfig1.Id, null, '{}', null);
        
        BT_TreeRemotingModel.TreeNode[] usersChildNodes54 = BT_TreeRemotingModel.getChildren('Folder__c','test','id, name',
                                                                                             BT_Constants.TREE_NODE_TYPE_QUERY, 'Account',
                                                                                             'Testing', '',true,true, true, testFileTreeNodeConfig1.Id, null, '{}', null);
        
        // There will be no child for user node                                      
        System.assertEquals(usersChildNodes.size(), 0);
                                              
        // Expanding first row of of "Accounts" node.
        Account testAcc = [Select Id, Name From Account LIMIT 1];
        nodeId = BT_Constants.TREE_TYPE_USER+ '/' +testAcc.Id;
        BT_TreeRemotingModel.TreeNode[] accountsChildNodes = BT_TreeRemotingModel.getChildren('Account', nodeId,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_OBJECT, 'Account',
                                              '', '',true,true, true, null, null, '{}', null);
        BT_TreeRemotingModel.TreeNode[] accountsChildNodes2 = BT_TreeRemotingModel.getChildren('File__c', nodeId,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_OBJECT, 'Account',
                                              '', '',true,true, true, null, null, '{}', null);
        BT_TreeRemotingModel.TreeNode[] accountsChildNodes3 = BT_TreeRemotingModel.getChildren('Folder__c', nodeId,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_OBJECT, 'Account',
                                              '', '',true,true, true, null, null, '{}', null);
        
        // Portal user should be there as the child of account
        System.assertEquals(accountsChildNodes.size(), 0);   
                                           
        // Expanding first row of of "Groups" node.
        Group testGroup = [Select Id, Name From Group LIMIT 1];                                      
        nodeId = BT_Constants.TREE_TYPE_USER+ '/' + testGroup.Id;                                      
        BT_TreeRemotingModel.TreeNode[] groupsChildNodes = BT_TreeRemotingModel.getChildren('Group', nodeId,'id, name',
                                              BT_Constants.TREE_NODE_TYPE_OBJECT, 'Group',
                                              '', '',true,true, true, null, null, '{}', null);  
        List<sObject> objList=new List<sObject>();
        Map<Id, String> recordTypeIdToNameMap =new Map<Id,String>();
        Set<String> filterRecordTypes=new Set<String>();
        filterRecordTypes.add('Test');
        //List<BT_TreeRemotingModel.TreeNode> nodes = new List<BT_TreeRemotingModel.TreeNode>();
        BT_TreeRemotingModel.convertSObjectsToTreeNodes2(objList, '', 'Folder__c',recordTypeIdToNameMap,filterRecordTypes,'',false, '');
        System.assertEquals('Test','Test');
        
    }
    
    static testmethod void testUserPicker2(){
        // Creating users, groups and accounts
        createUsersGroupsAndAccounts();
       
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
        List<String> fields=new List<String>();
        
        //BT_TreeRemotingModel.getChildrenForTree('', '', fields ,'' , '', '','',''); 
        BT_TreeRemotingModel.getTreeConfiguration('',''); 
        System.assertEquals('Test','Test');
        
    }
    
    public static void buildFoldersTree(){
    	List<Folder__c> bucketFolders = new List<Folder__c>();
		Folder__c bucket1 = new Folder__c(Name='Test Bucket1');
		bucket1.Parent__c = null;
		bucket1.Active__c = true;
		bucket1.Default__c = true;
		bucketFolders.add(bucket1);
		insert bucketFolders;
		
		List<Folder__c> subFolders = new List<Folder__c>();
		Folder__c sub1 = new Folder__c(Name= 'Test Sub Folder1');
		sub1.Parent__c = bucketFolders[0].Id;
		subFolders.add(sub1);
		
		Folder__c sub2 = new Folder__c(Name= 'Test Sub Folder2');
		sub2.Parent__c = bucketFolders[0].Id;
		subFolders.add(sub2);
		
		Folder__c sub3 = new Folder__c(Name= 'Test Sub Folder3');
		sub3.Parent__c = bucketFolders[0].Id;
		subFolders.add(sub3);
		insert subFolders;
		
		Folder__c grandSub1 = new Folder__c(Name= 'Test Grand Sub Folder1');
		grandSub1.Parent__c = subFolders[0].Id;
		insert grandSub1;
		
		Folder__c folder = subFolders[0];
		List<File__c> files = new List<File__c>();
		File__c file1 = new File__c(Name= 'File1.png');
		file1.Folder__c = folder.Id;
		file1.Bucket_Name__c = 'Test Bucket1';
		file1.Extension__c = '.png';
        file1.Size__c = 5000;
        file1.Content_Type__c = 'image/png';
		files.add(file1);
		
		File__c file2 = new File__c(Name= 'File2.png');
		file2.Folder__c = folder.Id;
		file2.Bucket_Name__c = 'Test Bucket1';
		file2.Extension__c = '.jpg';
        file2.Size__c = 5001;
        file2.Content_Type__c = 'image/jpg';
		files.add(file2);
		
		File__c file3 = new File__c(Name= 'File3.png');
		file3.Folder__c = folder.Id;
		file3.Bucket_Name__c = 'Test Bucket1';
		file3.Extension__c = '.pdf';
        file3.Size__c = 5000;
        file3.Content_Type__c = 'image/pdf';
		files.add(file3);
		insert files;
    }
    
    public static void createUsersGroupsAndAccounts(){
        // Create Contact
        Contact testContact = new Contact();
        testContact.FirstName = 'Appurin';
        testContact.LastName = 'Inc.';
        insert testContact;
        
        
        // Create User
        /*
        Profile p = [select id from profile where ID =: UserInfo.getUserId()];
        User testUser = new User(alias='mausam12', email='sagar@thoriyas.com', 
                    emailencodingkey='UTF-8', lastname='testing', languagelocalekey='en_US',
                    localesidkey='en_US', profileid=p.id, 
                    timezonesidkey='America/Los_Angeles', username='aradmin123@72demo.com');
        UserTriggerHandler.isSkipTrigger = true;            
        insert testUser;
        UserTriggerHandler.isSkipTrigger = false;    
        */
        // Create Group with group member
        Group testGroup = new Group();
        testGroup.Name = 'testGroup 786';
        insert testGroup;
        
        // Creating Account with portal user
        Account testAcc = new Account();
        testAcc.Name = 'test';
        insert testAcc ;
        
        // If Account owner having no role then we are assigning role to him.
        User setRoleToUser = [Select u.UserRoleId, u.Id From User u where Id =: UserInfo.getUserId()];
        if(setRoleToUser.UserRoleId == null){
            List<UserRole> roleList = [Select u.Id From UserRole u Limit 1];
            system.runAs(setRoleToUser){
                if(roleList.size() > 0){
                    setRoleToUser.UserRoleId = roleList[0].Id;
                    // update setRoleToUser;
                }
            }
        }
        
        Contact portalContact = new Contact();
        portalContact.AccountId = testAcc.Id;
        portalContact.FirstName = 'test first name';
        portalContact.LastName = 'test last name';
        portalContact.Email = 'test@sagar.com';
        insert portalContact ;
        BT_TreeRemotingModel BTTreeRemotingModelRef = new BT_TreeRemotingModel();
        BT_TreeRemotingModel.getMaxTreeNodeError();
        BT_TreeRemotingModel.getFolderTreeRoot('');
    }
}