/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: TreeConfigurationDAO
* Created by Sagar: 04/08/2017
*
* DAO class to handle the data related to tree comnfiguration
* 

* - Modifications:
* - Sagar, 04/08/2017 – Initial Development
************************************************************************** */
public with sharing class TreeConfigurationDAO {
    public TreeConfigurationDAO(){
    }
    
    /*
    *   Purpose:    Return TreeConfiguration for the specified tree type. note that it assumes that there is only one
                    record for the specified tree type. if there are more records, it returns one of them.
    *   Parameters: treeType
    *   UnitTests:  
    */
    public static Tree_Configuration__c getDTC(String treeType){
        List<String> fields = new List<String>{'id', 'name', 'Tree_Type__c', 'Number_of_Node_Path_Levels__c', 'Show_System_Default_Tree_Nodes__c'};
        SOQLManager.checkFieldAccess(Tree_Configuration__c.sObjectType, fields);
        List<Tree_Configuration__c> dtcs = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' FROM Tree_Configuration__c WHERE Tree_Type__c = :treeType');
                                                    
        if (dtcs.size() > 0) {
            return dtcs.get(0);
        }
        return null;
    }
    /*
    *   Purpose:    Return TreeConfiguration by name. note that it assumes that there is only one
                    record for the specified name. if there are more records, it returns one of them.
    *   Parameters: name
    *   UnitTests:  
    */
    public static Tree_Configuration__c getDTCByName(String name){
        List<String> fields = new List<String>{'id', 'name', 'Tree_Type__c', 'Number_of_Node_Path_Levels__c', 'Show_System_Default_Tree_Nodes__c'};
        SOQLManager.checkFieldAccess(Tree_Configuration__c.sObjectType, fields);
        List<Tree_Configuration__c> dtcs = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' FROM Tree_Configuration__c WHERE name = :name');
                                                    
        if (dtcs.size() > 0) {
            return dtcs.get(0);
        } 
        return null;
    }
    /*
    *   Purpose:    Returns the Tree node configuration for a given Tree_Configuration__c
    *   Parameters: dtcId
    *   UnitTests:  
    */
    public static List<Tree_Node_Configuration__c> getTNCByTCId(Id dtcId){
        List<String> fields = new List<String>{'id', 'name', 'Disabled__c', 'Type__c', 'Child_Object_Type__c', 'Caption__c', 'Caption_Field_Name__c', 'Query_String__c','Show_Children_as_tree_nodes__c', 'Show_this_configuration_node_in_tree__c'};
        SOQLManager.checkFieldAccess(Tree_Node_Configuration__c.sObjectType, fields);
        List<Tree_Node_Configuration__c> tncs = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' FROM Tree_Node_Configuration__c Where Tree_Configuration__r.id = :dtcId order By Sort_id__c, name');
        return tncs;
    }
    /*
    *   Purpose:    Returns the top level (when parent == null) Tree node configuration for a given Tree_Configuration__c
    *   Parameters: dtcId
    *   UnitTests:  
    */
    public static List<Tree_Node_Configuration__c> getTopLevelTNCByTCId(Id dtcId){
        List<String> fields = new List<String>{'id', 'name', 'Disabled__c', 'Type__c', 'Child_Object_Type__c', 'Caption__c', 'Caption_Field_Name__c', 'Query_String__c','Show_Children_as_tree_nodes__c', 'Show_this_configuration_node_in_tree__c', 'Order_Children_By__c'};
        SOQLManager.checkFieldAccess(Tree_Node_Configuration__c.sObjectType, fields);
        List<Tree_Node_Configuration__c> tncs = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' FROM Tree_Node_Configuration__c Where Tree_Configuration__r.id = :dtcId and parent__c = null order By Sort_id__c, name');
        return tncs;
    }
    /*
    *   Purpose:    Returns the Tree node configuration by id
    *   Parameters: tncId
    *   UnitTests:  
    */
    public static Tree_Node_Configuration__c getTNCById(Id tncId){
        List<String> fields = new List<String>{'id', 'name', 'Disabled__c', 'Type__c', 'Child_Object_Type__c', 'Caption__c', 'Caption_Field_Name__c', 'Query_String__c','Show_Children_as_tree_nodes__c', 'Show_this_configuration_node_in_tree__c'};
        SOQLManager.checkFieldAccess(Tree_Node_Configuration__c.sObjectType, fields);
        Tree_Node_Configuration__c tnc = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' FROM Tree_Node_Configuration__c Where id = :tncId');
        return tnc;
    }
    /*
    *   Purpose:    Returns the child TNCs for a parent TNC
    *   Parameters: parentTNCId
    *   UnitTests:  
    */
    public static List<Tree_Node_Configuration__c> getChildrenTNC(Id parentTNCId){
        List<String> fields = new List<String>{'id', 'name', 'Disabled__c', 'Type__c', 'Child_Object_Type__c', 'Caption__c', 'Caption_Field_Name__c', 'Query_String__c','Show_Children_as_tree_nodes__c', 'Show_this_configuration_node_in_tree__c', 'Order_Children_By__c'};
        SOQLManager.checkFieldAccess(Tree_Node_Configuration__c.sObjectType, fields);
        Tree_Node_Configuration__c ad = Database.query('SELECT id ,'+
                '(SELECT '+BT_Utils.buildSelectListFragment(null, null, fields) + ' FROM Tree_Node_Configuration__c.Children__r order By Sort_id__c, name)'+
                ' FROM Tree_Node_Configuration__c WHERE id = :parentTNCId');
        
        return ad.Children__r;
    }
}