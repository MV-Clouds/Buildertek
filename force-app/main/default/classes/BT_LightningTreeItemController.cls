/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  24-Jul-2018
*/
public with sharing class BT_LightningTreeItemController {
    /**************************************************************************
       Purpose: Get child nodes for selected node
       Returns: 
       Throws [Exceptions]: 
    ****************************************************************************/
    @AuraEnabled 
    public static List<BT_TreeRemotingModel.TreeNode> getChildNodes(String treeType, String sobjectFields,
                                              String nodeData){
                                                  
        // Select node data
        TreeNodeUserData node = (TreeNodeUserData)JSON.deserialize(nodeData, TreeNodeUserData.class);
        System.debug('node>>>'+node);
        // Need to prefix tree type
        String key = treeType + '/' + node.key;
        
        // Object type of the tree node like 
        String objectType = node.objectType;
        
        // Node type
        String nodeType = node.nodeType;
        
        // Child object type
        String childObjectType = node.childObjectType;
        
        // Title field
        String titleFieldName = node.titleFieldName;
        System.debug('titleFieldName>>>'+titleFieldName);
        // Query string
        String nodeFilterCondition = node.nodeQuery;
        
        // Show charts for the node
        Boolean isShowGroupByCharts = node.showGroupByCharts;
        
        // Show child in the tree
        Boolean isShowResultObjectsInTree = node.showResultObjectsInTree;
        
        // Show new button
        Boolean isShowNewButton = node.showNewButton;
        
        // Tree Configuration Node Id
        String treeNodeConfigurationId = node.tncId;
        
        // Order by field in the query for child records
        String orderChildrenBy = node.orderChildrenBy;
        
        //  Query parameters for child records
        String defaultFilterCondition = node.queryParameters;
        
        // Do we need to fetch only portla users
        Boolean isShowOnlyPortalUser = node.showOnlyPortalUser;
        
        // Get children of selected node using node data
        List<BT_TreeRemotingModel.TreeNode> result = new List<BT_TreeRemotingModel.TreeNode>();
        result = BT_TreeRemotingModel.getChildren(objectType, 
                            key, 
                            'Id,Name', 
                            nodeType,
				            childObjectType, 
				            titleFieldName, 
				            nodeFilterCondition,
				            isShowGroupByCharts, 
				            isShowResultObjectsInTree,
				            isShowNewButton, 
				            treeNodeConfigurationId,
				            orderChildrenBy, 
				            /*isShowOnlyPortalUser,*/ 
				            defaultFilterCondition, 
				            sobjectFields/*, 
				            false*/); 
				            
        // Return those child nodes
        return result;
    }
}