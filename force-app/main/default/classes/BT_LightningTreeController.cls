/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date:  24-Jul-2018
 */
public with sharing class BT_LightningTreeController{
	/**************************************************************************
	 Purpose: Get root nodes for tree
	 Returns:
	 Throws [Exceptions]:
	 ****************************************************************************/
	@AuraEnabled
	public static List<BT_TreeRemotingModel.TreeNode> getRootNodes(String treeType, String treeConfigurationName, String defaultSobjectFields, Boolean isExpandTreeRoots, String defaultFilterCondition, String treeDataFields, Boolean isNoSharingOperation){

		// List of root nodes
		List<BT_TreeRemotingModel.TreeNode> result = new List<BT_TreeRemotingModel.TreeNode>();
		result = BT_TreeRemotingModel.getTreeRootNodes(treeType, treeConfigurationName, '', null, defaultSobjectFields, isExpandTreeRoots, 
		/*false,*/
		defaultFilterCondition, treeDataFields/*,
		 isNoSharingOperation*/);
		// Return root nodes
		return result;
	}

	@AuraEnabled
	public static String setRootNodeIcon(String rootNodesIdArray){
		if (String.isNotBlank(rootNodesIdArray)){
			rootNodesIdArray = rootNodesIdArray.replace('[', '');
			rootNodesIdArray = rootNodesIdArray.replace(']', '');
			rootNodesIdArray = rootNodesIdArray.replace('"', '');
			List<Id> lstString = new List<Id>();
			if (rootNodesIdArray.contains(',')){
				lstString = rootNodesIdArray.split(',');
			} else{
				lstString.add(rootNodesIdArray);
			}
			Set<Id> sectionIds = new Set<Id>(lstString);
			List<buildertek__Question__c> questions = new List<buildertek__Question__c>([Select Id, Name, buildertek__Question_Group__c, buildertek__Cost__c, buildertek__Is_Selected_Item__c, buildertek__Question_Group__r.buildertek__of_Options_Required__c, buildertek__Question_Group__r.buildertek__Locked__c, buildertek__Section__r.Name, buildertek__Section__r.buildertek__Allowance__c, buildertek__Section__r.buildertek__Due_date__c, buildertek__Section__r.buildertek__Locked__c, buildertek__Section__r.buildertek__Visible_to_Customer__c, (SELECT Id, Name, buildertek__Drop_Down_Value__c, buildertek__Text_Value__c, buildertek__Question__c
			                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  FROM buildertek__Answer_Choices__r)
			                                                                             from buildertek__Question__c
			                                                                             where buildertek__Section__c = :sectionIds]);
			if (questions.size() > 0){
				return Json.serialize(questions);
			}
		}
		return null;
	}
}