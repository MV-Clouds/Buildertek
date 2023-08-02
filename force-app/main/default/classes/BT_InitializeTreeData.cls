/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Controller Class: BT_InitializeTreeData
* Created by Sagar: 10/06/2017
*
* - Handles all tree related data

* - Modifications:
* - Sagar, 06/08/2017 – Initial Development
************************************************************************** */
public with sharing class BT_InitializeTreeData {
    
    static Map<String, Tree_Configuration__c> TREES_BY_NAME;
    static Map<String, Tree_Node_Configuration__c> ROOT_NODES_BY_NAME;
    
    //Save all the leaf ndes. Since other nodes are not dependent on these nodes, we can create them
    //at the end in one shot (save SOQL queries)
    static List<Tree_Node_Configuration__c> leafNodes = new List<Tree_Node_Configuration__c>(); 
    
    /**
    Delete the tree, node and chart configuration information.
    **/
    public static void clearConfiguration(){
        DMLManager.deleteAsUser([select id from Tree_Node_Configuration__c limit 10000]);
        DMLManager.deleteAsUser([select id from Tree_Configuration__c limit 1000]);
    }
    
    /**
    Initialize the tree, node and chart configuration
    **/
    public static void initialize(){
        
        //Create the tree objects
        initializeTrees();
        
        //Create root nodes. Assumption is that the naes of the rrot nodes are unique
        initializeRootNodes();
       
        //Create nodes for Assessment, Asset, Configuration and Controls tabs 
        initializeNodesForTabs();
        
        //Create nodes for pickers
        initializeForPickers();
        
        createNodes(leafNodes);
    }
    
    
    
    
    /*
    Create objects for Tree_Configuration__c
    */    
    private static Tree_Configuration__c createTreeConfiguration(string treeName, boolean showSystemDefaultTreeNode, string whereUsed, string treeType, string CheckableNodes){
        Tree_Configuration__c tree = new Tree_Configuration__c(name = treeName,
                                       Show_System_Default_Tree_Nodes__c = showSystemDefaultTreeNode,
                                       Where_it_is_used1__c = whereUsed,
                                       Tree_Type__c = treeType,
                                       Checkable_Nodes__c = CheckableNodes);
        return tree;
    }
    
    /**
    Intialize the trees
    **/
    public static void initializeTrees(){
        List<Tree_Configuration__c> trees = new List<Tree_Configuration__c>();
                       
        Tree_Configuration__c tree = createTreeConfiguration('User Picker Tree', false,
                                       System.Label.User_Picker_Tree_Description,
                                       BT_Constants.TREE_TYPE_USER, null);
        trees.add(tree);
        
        tree = createTreeConfiguration('Files Tree', false,
                                       System.Label.File_Exlorer_Tree_Description,
                                       BT_Constants.TREE_TYPE_FILE, null);
        trees.add(tree);
        
        tree = createTreeConfiguration('File Picker Tree', false,
                                       System.Label.File_Picker_Tree_Description,
                                       BT_Constants.TREE_TYPE_FILE, 'File__c');
        trees.add(tree);
        
        createTrees(trees);
    }
    
    /*
    Create objects for Tree_Node_Configuration__c
    */
    private static Tree_Node_Configuration__c createTreeNodeConfiguration(string treeNodeName, Id parent, Id treeConfiguration, string caption, string captionFieldName,
                                                                            string childObjType, string description, boolean disabled, string queryString, boolean showChildrenAsTreeNode,
                                                                            boolean showThisNodeInTree, string sortId, string nodeType,
                                                                            string orderChildrenBy){
        Tree_Node_Configuration__c treeNode = 
                new Tree_Node_Configuration__c(name = treeNodeName,
                                              Parent__c = parent,
                                              Tree_Configuration__c = treeConfiguration,
                                              Caption__c= caption,
                                              Caption_Field_Name__c = captionFieldName,
                                              Child_Object_Type__c = childObjType,
                                              Description__c = description,
                                              Disabled__c = disabled,
                                              Query_String__c = queryString,
                                              Show_Children_As_Tree_nodes__c = showChildrenAsTreeNode,
                                              Show_This_Configuration_Node_In_Tree__c = showThisNodeInTree,
                                              Sort_Id__c = sortId,
                                              Type__c = nodeType,
                                              Order_Children_By__c = orderChildrenBy);
        return treeNode;       
    }
       
    /**
    Intialize the root nodes for the trees
    **/
    public static void initializeRootNodes(){        
        //Create the root nodes of the tree
        List<Tree_Node_Configuration__c> rootNodes = new List<Tree_Node_Configuration__c>();
        
        //Root nodes for User Picker Tree
        Tree_Configuration__c tree = getTreeNodeByName('User Picker Tree');
        
        Tree_Node_Configuration__c treeNode = createTreeNodeConfiguration('User Picker Tree Root', null, tree.Id, System.Label.Users_Node_Title, null, 'User',
                                               'User picker tree root node', false, null, true, true, '001', BT_Constants.TREE_NODE_TYPE_QUERY, 'Name');
        rootNodes.add(treeNode);
        
        treeNode = createTreeNodeConfiguration('User Picker Tree Root - Group', null, tree.Id, System.Label.Groups_Node_Title, null, 'Group',
                                               'User picker tree root node - Group', false, null, true, true, '002', BT_Constants.TREE_NODE_TYPE_QUERY, 'Name');
        rootNodes.add(treeNode);
        
        treeNode = createTreeNodeConfiguration('User Picker Tree Root - Account', null, tree.Id, System.Label.Accounts_Node_Title, null, 'Account',
                                               'User picker tree root node - Account', true, null, true, true, '003', BT_Constants.TREE_NODE_TYPE_QUERY, 'Name');
        rootNodes.add(treeNode);
        
        treeNode = createTreeNodeConfiguration('User Picker Tree Root - Contact', null, tree.id, System.Label.Contacts_Node_Title, null, 'Contact',
                                           'User picker tree root node - Contact', false, 'Id#!null', false, true, '004', BT_Constants.TREE_NODE_TYPE_QUERY, 'Name');
        rootNodes.add(treeNode);
                                               
        treeNode = createTreeNodeConfiguration('User Picker Tree Root - Title', null, tree.id, System.Label.Titles_Node_Title, 'Title', 'User',
                                               'User picker tree root node - Title', false, 'Title#!null~IsActive#true', true, true, '005', BT_Constants.TREE_NODE_TYPE_GROUPBY_ROOT, 'Name');
        rootNodes.add(treeNode);
        
        //Root nodes for File Explorer Tree
        tree = getTreeNodeByName('Files Tree');
        
        treeNode = createTreeNodeConfiguration('File Explorer - Home', null, tree.Id, System.Label.Home, null, 'Folder__c',
                                               'Root node for File Explorer page.', false, 'Parent__c#null~Active__c#true', true, true, '001', BT_Constants.TREE_NODE_TYPE_QUERY, 'CreatedDate');
        rootNodes.add(treeNode);
        
        //Root nodes for File Picker Tree
        tree = getTreeNodeByName('File Picker Tree');
        
        treeNode = createTreeNodeConfiguration('File Picker - Home', null, tree.Id, System.Label.Home, null, 'Folder__c',
                                               'Root node for File Picker.', false, 'Parent__c#null~Active__c#true', true, true, '001', BT_Constants.TREE_NODE_TYPE_QUERY, 'Name');
        rootNodes.add(treeNode);
        
        createRootNodes(rootNodes);
    }
       
    /**
    Build the tree configuration used by the tabs.
    **/
    public static void initializeNodesForTabs(){
    }  
    
    /**
    Build the tree configuration used by the "Controls" tab.
    **/
     public static void initializeForPickers(){
        
        Map<String, Tree_Node_Configuration__c> nodesByName;        
        List<Tree_Node_Configuration__c> nodes = new List<Tree_Node_Configuration__c>();
        
        //User Picker Tree
        Tree_Configuration__c upTree = getTreeNodeByName('User Picker Tree'); 
         
        Tree_Node_Configuration__c uptpUserPicker = getRootNodeByName('User Picker Tree Root');
         
        Tree_Node_Configuration__c uptUserByType =
                createTreeNodeConfiguration('All Users', uptpUserPicker.Id, upTree.id, 'All Users', null, 'User',
                                            null, false, 'IsActive#true~UserType#!Guest', true, false, null, BT_Constants.TREE_NODE_TYPE_QUERY, null);
        leafNodes.add(uptUserByType); 
       
        Tree_Node_Configuration__c uptpGroupPicker = getRootNodeByName('User Picker Tree Root - Group');
         
        Tree_Node_Configuration__c uptGroupByType =
                createTreeNodeConfiguration('All Groups', uptpGroupPicker.Id, upTree.id, 'All Groups', null, 'Group',
                                            null, false, 'Type#Regular', true, false, null, BT_Constants.TREE_NODE_TYPE_QUERY, null);
        leafNodes.add(uptGroupByType);
       
        //Root : User Picker Tree Root - Account
        Tree_Node_Configuration__c userPickerTreeRootAccount = getRootNodeByName('User Picker Tree Root - Account');
        
        Tree_Node_Configuration__c accountTreeByTypeForUserPicker =
                createTreeNodeConfiguration('Accounts by Type - User Picker', userPickerTreeRootAccount.Id, upTree.id, 'By Type', 'Type', 'Account',
                                            null, false, 'Id#!null', true, true, null, BT_Constants.TREE_NODE_TYPE_GROUPBY_ROOT, null);
        leafNodes.add(accountTreeByTypeForUserPicker);
     }
   
    /**
    Create a tree. Before creating, check if the tree already exists. If it does not, then create this tree.
    **/
    public static void createTrees(List<Tree_Configuration__c> trees){
        if(trees == null || trees.size() == 0){
            return;
        }
        
        //Build a list of tree names to be used in the bulk query
        List<String> treeNames = new List<String>();
        for(Tree_Configuration__c tree : trees){
            treeNames.add(tree.name);
        }
        
        //Check if a tree by this name already exists
        TREES_BY_NAME = new Map<String, Tree_Configuration__c>();
        for(Tree_Configuration__c existingTree : [select id, name from Tree_Configuration__c where name in :treeNames]){
            TREES_BY_NAME.put(existingTree.name, existingTree); 
        }
        
        //Build a list of new trees
        List<Tree_Configuration__c> newTrees = new List<Tree_Configuration__c>();
        for(Tree_Configuration__c tree : trees){
            if(TREES_BY_NAME.get(tree.name) == null){
                newTrees.add(tree);
            }
        }
        
        DMLManager.insertAsUser(newTrees);
        
        //Set up a map of trees by name for later use
        for(Tree_Configuration__c existingTree : [select id, name from Tree_Configuration__c where name in :treeNames]){
            TREES_BY_NAME.put(existingTree.name, existingTree);  
        }
    }
   
    /**
    For a given name, find a matching tree node.
    **/
    private static Tree_Configuration__c getTreeNodeByName(String treeName){
        return TREES_BY_NAME.get(treeName);
    }
    
    /**
    Create root nodes. Before creating, check if the node already exists. If it does not, then create this node.
    **/ 
    public static void createRootNodes(List<Tree_Node_Configuration__c> rootNodes){
        if(rootNodes == null || rootNodes.size() == 0){
            return;
        }
        
        //Build a list of root mode names to be used in the bulk query
        List<String> rootNodeNames = new List<String>();
        for(Tree_Node_Configuration__c rootNode : rootNodes){
            rootNodeNames.add(rootNode.name);
        }
        
        //Check if a root node by this name already exists
        ROOT_NODES_BY_NAME = new Map<String, Tree_Node_Configuration__c>();
        for(Tree_Node_Configuration__c existingRootNode : [select id, name from Tree_Node_Configuration__c where name in :rootNodeNames]){
            ROOT_NODES_BY_NAME.put(existingRootNode.name, existingRootNode); 
        }
        
        //Build a list of new root nodes
        List<Tree_Node_Configuration__c> newRootNodes = new List<Tree_Node_Configuration__c>();
        for(Tree_Node_Configuration__c rootNode : rootNodes){
            if(ROOT_NODES_BY_NAME.get(rootNode.name) == null){
                newRootNodes.add(rootNode);
            }
        }
        
        DMLManager.insertAsUser(newRootNodes);
        
        //Set up a map of root nodes by name for later use
        for(Tree_Node_Configuration__c existingRootNode : [select id, name from Tree_Node_Configuration__c where name in :rootNodeNames]){
            ROOT_NODES_BY_NAME.put(existingRootNode.name, existingRootNode);  
        }
        
        List<Tree_Node_Configuration__c> rootNodesToUpdate = new List<Tree_Node_Configuration__c>();
        DMLManager.updateAsUser(rootNodesToUpdate);
    }
   
    /**
    For a given name, find a matching tree node.
    **/
    private static Tree_Node_Configuration__c getRootNodeByName(String rootNodeName){
        return ROOT_NODES_BY_NAME.get(rootNodeName);
    }
   
    /**
    Create a tree node.Before creating, check if the node already exists. If it does not, then create this node.
    **/
    public static Map<String, Tree_Node_Configuration__c> createNodes(List<Tree_Node_Configuration__c> nodes){
        Map<String, Tree_Node_Configuration__c> nodesByName = new Map<String, Tree_Node_Configuration__c>();
        List<Tree_Node_Configuration__c> newNodes = new List<Tree_Node_Configuration__c>();
        
        //Get existing nodes
        Set<String> nodeNames = new Set<String>();
        Set<Id> treeConfigurationIds = new Set<Id>();
        Set<Id> parentIds = new Set<Id>();
        for(Tree_Node_Configuration__c node : nodes){
            nodeNames.add(node.name);
            treeConfigurationIds.add(node.Tree_Configuration__c);
            parentIds.add(node.Parent__c);
        }
        
        List<String> fields = new List<String>{'Id', 'Name', 'Tree_Configuration__c', 'Parent__c'};
        SOQLManager.checkFieldAccess(Tree_Node_Configuration__c.sObjectType, fields);
        List<Tree_Node_Configuration__c> existingNodes = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' from Tree_Node_Configuration__c where name in :nodeNames and Tree_Configuration__c in :treeConfigurationIds and Parent__c in :parentIds'));
        //Build a map for quick lookup by name, tree node id and parent node id
        Map<String, Tree_Node_Configuration__c> existingNodesMap = new Map<String, Tree_Node_Configuration__c>();
        for(Tree_Node_Configuration__c existingNode : existingNodes){
            String key = existingNode.name + existingNode.Tree_Configuration__c + (existingNode.Parent__c == null ? 'NULL' : existingNode.Parent__c);
            existingNodesMap.put(key, existingNode);
        }
        
        
        for(Tree_Node_Configuration__c node : nodes){
            //Check if this node already exists
            String key = node.name + node.Tree_Configuration__c + (node.Parent__c == null ? 'NULL' : node.Parent__c);
            Tree_Node_Configuration__c existingNode = existingNodesMap.get(key);
            
            if(existingNode == null){
                newNodes.add(node);
                nodesByName.put(node.name, node);
            } else {
                nodesByName.put(existingNode.name, existingNode);
            }
        }
        DMLManager.insertAsUser(newNodes);
        return nodesByName;
        
    }
}