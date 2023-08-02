/* **************************************************************************
 * Copyright 2017, BuilderTek.
 * All rights reserved
 *
 * Controller Class: BT_TreeRemotingModel
 * Created by Sagar: 06/05/2017
 *
 * Appurin js remoting class implementing all the "tree model" remoting methods for ajax support. All the methods that return one or more objects, always returns objects as array of objects.
 * Paste files from one folder to other
 *

 * - Modifications:
 * - Sagar, 06/05/2017 – Initial Development
 ************************************************************************** */
global with sharing class BT_TreeRemotingModel{
    /*
     Constructers
     */
    public BT_TreeRemotingModel(){
    }

    public BT_TreeRemotingModel(ApexPages.StandardController stdController){
    }

    //Wrapper class is boing used for pass query where condition parameters to jsRemoting methods.
    public class QueryParameter{
        public string fieldApiName;
        public string fieldValue;
        public QueryParameter(String fieldApiName, String fieldValue){
            this.fieldApiName = fieldApiName;
            this.fieldValue = fieldValue;
        }
    }

    /*
     Tree node object that is required by jquery fancytree implementation
     */
    global class TreeNode{
        /*
         All jQuery related attributes
         */
        @AuraEnabled
        public String id{ get; set; }

        // Node id, complete node path used as unique id
        @AuraEnabled
        public String title{ get; set; }

        // Tree node title text
        @AuraEnabled
        public String tooltip;                      // Tooltip for the tree node
        @AuraEnabled
        public String icon;                         // Icon file path as expected by fancytree
        @AuraEnabled
        public Boolean folder;                      // Indicates folder or leaf node
        @AuraEnabled
        public String key;                          // Node key, this is the last part of the complete node path used in id
        @AuraEnabled
        public Boolean lazy;                        // Is node lazy loaded?
        @AuraEnabled
        public Boolean active;                      // Is node active?
        @AuraEnabled
        public Boolean hideCheckBox;                      // Is node active?
        @AuraEnabled
        public String addClass;

        // this will get added as one of the class name for the node
        @AuraEnabled
        public Boolean expand{
            get;

            set{
                // Is node expanded?
                expand = value;
                if (value != null){
                    lazy = !value;
                }
                // If not expanded, needs to be lazy loaded
            }
        }

        @AuraEnabled
        public TreeNodeUserData userData;                  // Additional inforamtion related to tree node
        @AuraEnabled
        public TreeNode[] children;

        // Children nodes
        public TreeNode(){
            children = new List<TreeNode>();
            userData = new TreeNodeUserData();
        }

        /*
         *    Purpose:    Return last node key from the hierarchical key path
         *    Parameters:    path        = full key pasth for the node
         *   UnitTests:
         */
        String getNodeKey(String path){
            String key = null;
            List<String> hierarchicalIds = (id != null && id != '') ? id.split('/') : null;
            if (hierarchicalIds != null && !hierarchicalIds.isEmpty()){
                //Get the object id whose children need to be returned
                String topNodeId = hierarchicalIds.get(0);
                key = hierarchicalIds.get(hierarchicalIds.size()-1);
            }
            return key;
        }

        /*
         *    Purpose:    Based on certain system root ids, set other user data properties
         *    Parameters:
         *   UnitTests:
         */
        void setSystemRootUserDataProperties(){
            if (this.userData.key == BT_Constants.TREE_ROOT_FILES){
                this.userData.nodeType = BT_Constants.TREE_NODE_TYPE_QUERY;                  // Group by
                this.userData.childObjectType = 'Folder__c';                                    // Objects of this type needs to be queried
                this.userData.titleFieldName = null;                                            // Group by Name
                this.userData.nodeQuery = 'Parent__c' + BT_Constants.SEPARATOR_NAME_VALUE + null; // Parent__c#null'
                this.userData.showGroupByCharts = true;                                         // Render charts in detail area
                this.userData.showResultObjectsInTree = true;                                   // Allow objects of each category to show up as tree nodes too
                this.userData.showNewButton = false;                                            // Do not allow new in library?
            } else{
                this.userData.nodeType = BT_Constants.TREE_NODE_TYPE_OBJECT;                 // By default object id based node.
                this.userData.childObjectType = '';                                             // Not needed
                this.userData.titleFieldName = '';                                              // Not needed
                this.userData.nodeQuery = '';                                                   // Not needed
                this.userData.showGroupByCharts = true;                                         // Render charts in detail area
                this.userData.showResultObjectsInTree = true;                                   // Allow objects of each category to show up as tree nodes too
                this.userData.showNewButton = false;
            }
        }

        TreeNode(String id, String text, String objectType, String recordType, Boolean leaf, String iconCssClass, String queryParameters){
            this.id = id;
            this.title = text;                      // Replaces text for node caption
            this.folder = !leaf;                    // Replaces leaf to indicate folder or leaf node
            this.expand = false;                    // Replaces expanded to indicate initial expanded status
            this.lazy = !leaf;                      // If leaf node, do not allow lazy loading becuase its leaf node.
            this.icon = iconCssClass;                            // Not needed
            this.tooltip = '';                        // Default name will be tooltip
            this.key = getNodeKey(id);                             // Node key, this is the last part of the complete node path used in id.
            // It will be unique for same folder insde different parents

            // Set default user data
            this.userData = new TreeNodeUserData();
            this.userData.id = id;
            this.userData.key = key;
            this.userData.objectType = objectType;
            this.userData.recordType = recordType;
            // Any data that is not initialized by constructor, assign default value. use '' for strings else javascript breaks
            // with remoting call. The caller can overwrite this value.
            this.userData.nodeType = '';
            this.userData.childObjectType = '';
            this.userData.titleFieldName = '';
            this.userData.nodeQuery = '';
            this.userData.showGroupByCharts = true;
            this.userData.showResultObjectsInTree = true;
            this.userData.showNewButton = true;
            this.userData.tncId = '';
            this.userData.checkable = true;                     // By default all nodes are checkable
            this.userData.queryParameters = queryParameters != null ? queryParameters.unescapeHTML4() : null;
            // Based on certain system root ids, set other user data properties
            setSystemRootUserDataProperties();
        }
    }

    /*
     *   Purpose:    Loads children of the node recursively, as long as the node id is in the selectedNodeId path.
     *   Parameters: node                = Tree node whose children needs to be loaded
     selectedNodePath      = Path for selected node
     dataFields            = Feild needs to be queried
     noRecursion            = If true, it just loads children of this node.
     strFieldsToDisplay    = Fields needs to be display on selected record area
     *   UnitTests:
     */
    public static void loadChildrenRecursively(TreeNode node, String selectedNodePath, String dataFields, Boolean noRecursion, String strFieldsToDisplay){
        if (node.id == selectedNodePath){
            return;
        }

        TreeNode[] children = getChildren(node.userData.objectType, node.id, dataFields, node.userData.nodeType, node.userData.childObjectType, node.userData.titleFieldName, node.userData.nodeQuery, node.userData.showGroupByCharts, node.userData.showResultObjectsInTree, node.userData.showNewButton, node.userData.tncId, node.userData.orderChildrenBy, node.userData.queryParameters, strFieldsToDisplay);
        if (!children.isEmpty()){
            node.expand = true;
            node.children = children;
            if (!noRecursion){
                //Now from the children, find the node that matches the selected node path and load recursively
                TreeNode nextNodeToLoad = null;
                for (TreeNode n : children){
                    if (selectedNodePath.startsWith(n.id)){
                        nextNodeToLoad = n;
                        break;
                    }
                }
                if (nextNodeToLoad != null){
                    loadChildrenRecursively(nextNodeToLoad, selectedNodePath, dataFields, noRecursion, strFieldsToDisplay);
                }
            }
        }
    }

    /*
     *   Purpose:    Load an object record and create TreeNode out of the object record.
     The nodeId will be in the form BT_Constants.TREE_ROOT_OBJECT/<CustomObjectType>/<objectId>
     *   Parameters: treeType                = Tree type
     nodeId                  = Path for node
     dataFields                = Feild needs to be queried
     queryParameters            = Query parameters setted from controller
     strFieldsToDisplay        = Fields needs to be display on selected record area
     *   UnitTests:
     */
    public static TreeNode loadObjectRecordNode(String treeType, String nodeId, String dataFields, String queryParameters, String strFieldsToDisplay){
        TreeNode node = null;
        List<String> tokens = nodeId.split('/');
        List<String> fields = new List<String>{'Id', 'Name'};
        if (tokens.size() >= 3){
            //Create parent id by prefixing tree type and removing the last object id
            String parentId = treeType + '/' + tokens.get(0)+'/' + tokens.get(1);
            String objectType = tokens.get(1);
            String objectId = tokens.get(2);
            List<sObject> objList = new List<sObject>();
            if (objectType.equalsIgnoreCase('Folder__c')){
                List<String> fieldsForAD = new List<String>{'Id', 'Name', 'Amazon_File_Key__c', 'Bucket_Name__c'};
                objList = GenericDAO.getSObjectsById(objectType, objectId, 10, fieldsForAD, false);
            } else if (objectType.equalsIgnoreCase('File__c')){
                List<String> listFields = new List<String>{'Id', 'Name', 'Access_Type__c', 'File_Presigned_URL__c', 'Amazon_File_Key__c', 'Bucket_Name__c', 'Description__c', 'OwnerId', 'Public_On_Amazon__c', 'Allow_to_Download_by_Presigned_URL__c', 'Track_Download_History__c'};
                objList = GenericDAO.getSObjectsById(objectType, objectId, 10, listFields, false);
            } else{
                objList = GenericDAO.getSObjectsById(objectType, objectId, 10, fields, false);
            }
            if (objList.size() > 0){
                //Now based on object type, convert it into tree node
                List<TreeNode> nodes = convertSObjectsToTreeNodes(objList, parentId, 'Folder__c', null, false, queryParameters);
                node = nodes.get(0);
            }
        }
        System.debug('NODE 1::' + node);
        return node;
    }

    /*
     *   Purpose:    Returns default tree root node ids to display
     *   Parameters: treeType        = Tree type
     *   UnitTests:
     */
    static List<String> getTreeDefaultRootNodeIds(String treeType){
        List<String> rootids = new List<String>();
        if (treeType == BT_Constants.TREE_TYPE_FILE){
            rootids.add(BT_Constants.TREE_ROOT_FILES);
        }
        return rootids;
    }

    /*
     *   Purpose:    This method loads children nodes for the given node
     *   Parameters: tncId        = Tree node configuration id
     nodeId
     dataFields
     expandRoots
     parentNodeQuery
     orderChildrenBy
     queryParameters
     strFieldsToDisplay
     *   UnitTests:
     */
    public static TreeNode[] loadChildrenTreeNodesFromConfig(String tncId, String nodeId, String dataFields, Boolean expandRoots, String parentNodeQuery, String orderChildrenBy, String queryParameters, String strFieldsToDisplay){
        List<TreeNode> result = new List<TreeNode>();
        if (tncId == null || tncId == ''){
            return result;
        }

        List<Tree_Node_Configuration__c> tncs = TreeConfigurationDAO.getChildrenTNC(tncId);
        List<String> fields = new List<String>{'Id', 'Allow_To_Select_Grouping_Nodes__c', 'Name'};
        SOQLManager.checkFieldAccess(Tree_Node_Configuration__c.sObjectType, fields);
        Tree_Node_Configuration__c parentTreeNode = Database.query('Select ' + BT_Utils.buildSelectListFragment(null, null, fields)+' FROM Tree_Node_Configuration__c WHERE Id =: tncId LIMIT 1');
        for (Tree_Node_Configuration__c tnc : tncs){
            if (tnc.Disabled__c){
                continue;
            }

            TreeNode node = new TreeNode(nodeId + '/' + tnc.name, BT_UIConfig.getConfiguredName(tnc.Caption__c, null), BT_Constants.TREE_ROOT_LANDING_PAGE, null, false, '', queryParameters);
            node.tooltip = BT_UIConfig.getConfiguredName(tnc.Caption__c, null);
            node.userData.nodeType = tnc.Type__c;
            node.userData.childObjectType = tnc.Child_Object_Type__c != null ? tnc.Child_Object_Type__c : '';
            node.userData.titleFieldName = tnc.Caption_Field_Name__c != null ? tnc.Caption_Field_Name__c : '';
            node.userData.nodeQuery = tnc.Query_String__c != null ? tnc.Query_String__c : '';
            node.userData.orderChildrenBy = orderChildrenBy;
            node.userData.showGroupByCharts = false;
            node.userData.showResultObjectsInTree = tnc.Show_Children_as_tree_nodes__c != null ? tnc.Show_Children_as_tree_nodes__c : true;
            node.userData.showNewButton = false;
            node.userData.tncId = tnc.id;
            node.userData.checkable = parentTreeNode != null ? parentTreeNode.Allow_To_Select_Grouping_Nodes__c : false;

            // Since we are loading children of a parent, need to add parent's filter into the children's filter
            if (parentNodeQuery != null && parentNodeQuery != ''){
                if (node.userData.nodeQuery != null && node.userData.nodeQuery.length() > 0){
                    // There is some condition in there, add nv pair separator
                    node.userData.nodeQuery = node.userData.nodeQuery + BT_Constants.SEPARATOR_NV_PAIR + parentNodeQuery;
                } else{
                    node.userData.nodeQuery = parentNodeQuery;
                }
            }

            //Load children
            if (expandRoots || (tnc.Show_this_configuration_node_in_tree__c != null && !tnc.Show_this_configuration_node_in_tree__c)){
                loadChildrenRecursively(node, null, dataFields, true, strFieldsToDisplay);
            }

            if (tnc.Show_this_configuration_node_in_tree__c == null || tnc.Show_this_configuration_node_in_tree__c){
                //Need to display the configuration node in tree
                result.add(node);
            } else{
                //Hide the configuration node from the tree.
                if (node.children != null && node.children.size() > 0){
                    result.addAll(node.children);
                }
            }
        }

        return result;
    }

    /*
     *   Purpose:    This method get home record nodes
     *   Parameters: homeRecordIds            = List of home record ids
     *   UnitTests:
     */
    @TestVisible
    static TreeNode[] loadTreeHomeRecords(String treeType, String treeRootConfigName, List<String> homeRecordIds, String queryParameters){
        List<TreeNode> result = new List<TreeNode>();
        if (treeRootConfigName == null || treeRootConfigName == ''){
            treeRootConfigName = treeType + ' Tree';
        }
        String objType;
        //Read tree configuration objects
        Tree_Configuration__c dtc = TreeConfigurationDAO.getDTCByName(treeRootConfigName);
        if (dtc != null){
            List<Tree_Node_Configuration__c> tncs = TreeConfigurationDAO.getTopLevelTNCByTCId(dtc.id);
            if (!tncs.isEmpty()){
                objType = tncs[0].Child_Object_Type__c;
            }
        }
        if (objType == 'Folder__c'){
            List<String> fieldsForFolder = new List<String>{'Id', 'Name'};
            List<Folder__c> folders = FolderDAO.getFolders(homeRecordIds, fieldsForFolder, new List<String>{'createddate'}, BT_Constants.TREE_UI_MAX_NODE, queryParameters);
            List<TreeNode> nodes = convertSObjectsToTreeNodes(folders, 'Files', objType, null, false, queryParameters);
            result.addAll(nodes);
        }
        return result;
    }

    /*
     *   Purpose:    This method loads default tree nodes for the specified tree type from the tree configuration
     *   Parameters: treeType            = Tree node configuration id
     treeRootConfigName    = Root config name of the tree. if null or '', assumes "treeType + ' Tree'".
     It will search for tree configuration with this name to find all the configured nodes for the tree.
     dataFields
     expandRoots
     orderChildrenBy[TODO]
     queryParameters
     strFieldsToDisplay
     *   UnitTests:
     */
    @TestVisible
    static TreeNode[] loadDefaultTreeNodesFromConfig(String treeType, String treeRootConfigName, String dataFields, Boolean expandRoots, String queryParameters, String strFieldsToDisplay){
        List<TreeNode> result = new List<TreeNode>();
        if (treeRootConfigName == null || treeRootConfigName == ''){
            treeRootConfigName = treeType + ' Tree';
        }
        //Read tree configuration objects
        Tree_Configuration__c dtc = TreeConfigurationDAO.getDTCByName(treeRootConfigName);
        system.debug('---dtc---' + dtc);

        if (dtc == null || dtc.Show_System_Default_Tree_Nodes__c){
            //Based on tree type, add default hard coded nodes
            List<String> defaultRootIds = getTreeDefaultRootNodeIds(treeType);
            //If no rootids specified, return treeType node as root node
            for (String nodeId : defaultRootIds){
                //Static root node
                TreeNode node = new TreeNode(treeType + '/' + nodeId, BT_UIConfig.getConfiguredName(nodeId, null), BT_Constants.TREE_ROOT_LANDING_PAGE, null, false, '', queryParameters);
                if (node == null){
                    continue;
                }
                node.userData.checkable = false;             //Landing page node means not checkable, hide checkbox
                result.add(node);
                System.debug('expandRoots:::' + expandRoots);
                if (expandRoots){
                    loadChildrenRecursively(node, null, dataFields, true, strFieldsToDisplay);
                }
            }
        }
        //Now read configured nodes and add them
        if (dtc != null){
            //For configured nodes, use tree type configured with the node and not what's passed in
            String configuredTreeType = dtc.Tree_Type__c;
            List<Tree_Node_Configuration__c> tncs = TreeConfigurationDAO.getTopLevelTNCByTCId(dtc.id);

            system.debug('---tncs--->' + tncs);
            for (Tree_Node_Configuration__c tnc : tncs){
                if (tnc.Disabled__c)
                    continue;
                //Node is disabled, no need to display

                TreeNode node = new TreeNode(configuredTreeType + '/' + tnc.name, BT_UIConfig.getConfiguredName(tnc.Caption__c, null), BT_Constants.TREE_ROOT_LANDING_PAGE, null, false, '', queryParameters);
                node.tooltip = BT_UIConfig.getConfiguredName(tnc.Caption__c, null);
                node.userData.nodeType = tnc.Type__c;
                node.userData.childObjectType = tnc.Child_Object_Type__c != null ? tnc.Child_Object_Type__c : '';
                node.userData.titleFieldName = tnc.Caption_Field_Name__c != null ? tnc.Caption_Field_Name__c : '';
                node.userData.nodeQuery = tnc.Query_String__c != null ? tnc.Query_String__c : '';
                node.userData.orderChildrenBy = tnc.Order_Children_By__c != null ? tnc.Order_Children_By__c : '';
                node.userData.showGroupByCharts = false;
                node.userData.showResultObjectsInTree = tnc.Show_Children_as_tree_nodes__c != null ? tnc.Show_Children_as_tree_nodes__c : true;
                node.userData.showNewButton = false;
                node.userData.tncId = tnc.id;
                node.userData.checkable = false;

                if (tnc.Type__c == BT_Constants.TREE_NODE_TYPE_ROOT){
                    expandRoots = true;
                }

                // Load children
                if (expandRoots || (tnc.Show_this_configuration_node_in_tree__c != null && !tnc.Show_this_configuration_node_in_tree__c)){
                    loadChildrenRecursively(node, null, dataFields, true, strFieldsToDisplay);
                }

                if (tnc.Show_this_configuration_node_in_tree__c == null || tnc.Show_this_configuration_node_in_tree__c){
                    //Need to display the configuration node in tree
                    result.add(node);
                } else{
                    //Hide the configuration node from the tree.
                    result.addAll(node.children);
                }
            }
        }

        return result;
    }

    /*
     Purpose:     Get the Tree Configuration record using treeType and return it into component
     Parameters: 1) treeType: Its a attribute passed in component to prepare the tree such as Controls, Assessments, Policies, Assets etc
     2) treeConfigName: Tree Configuration Name. If null or '', assumes treeType + ' Tree'.
     Returns:    JSON string with of all required data of tree configuration
     Throws [Exceptions]:
     */
    @TestVisible@RemoteAction
    global static Tree_Configuration__c getTreeConfiguration(String treeType, String treeConfigName){
        String jsonStringForTreeConfgiration = '[]';
        if (treeConfigName == null || treeConfigName == ''){
            treeConfigName = treeType + ' Tree';
        }


        // Read tree configuration objects
        Tree_Configuration__c dtc = TreeConfigurationDAO.getDTCByName(treeConfigName);
        return dtc;
    }

    /*
     *   Purpose:    Build root nodes using specified ids
     The root node ids can be either static nodes as defined in BT_Constants such as TREE_ROOT_CONTROL_LIBRARY.
     However, sometimes it may be necessary to start displaying tree with a specific object record. in such case
     the id should start with BT_Constants.TREE_ROOT_OBJECT/<CustomObjectType>/<objectId> e.g.
     RootObject/Folder__c/a04A000000BGYZeIAP

     *   Parameters:    treeType - type of the tree such as Controls, Assets; one of BT_Constants.TREE_TYPE_*

     treeRootConfigName - root config name of the tree. if null or '', assumes "treeType + ' Tree'". it will search for
     tree configuration with this name to find all the configured nodes for the tree.

     rootids - comma separated list of root ids; can be one of BT_Constants.TREE_ROOT_*
     or object record as root as mentioned above

     homeids - comma separated list of home record ids

     selectedNodePath - selected node path in the tree using path syntax such as Controls/Controls Library/<record id>/<record id>
     if passed a valid path, it will pre-load all the children in the hierarchy

     dataFields - NOT IMPLEMENTED
     comma separated list of data field names to retrieve along with children, defaults to "Id, Name"

     expandRoots - if set to true, pre-loads children of first level root nodes

     queryParameters - any field value filter you wnt to add from controller side

     strFieldsToDisplay - It contains comma separated field API names which need to be displayed in selected record table in tree picker component.Currently, we are allowing only one object type, that is not supported for multiple objects in the same tree picker. If we need to allow for multiple objects then weneed to pass JSON data in map format (map of object API name and a list of its field API names). We need to pass the serialized JSON string of map from the page where we are using tree picker component and we can deserialize it in this method and use for multiple objects.For this we will not need to add another variable, we can use the same variable "".
     *   UnitTests:
     */
    @RemoteAction
    global static TreeNode[] getTreeRootNodes(String treeType, String treeRootConfigName, String rootids, String selectedNodePath, String dataFields, Boolean expandRoots, String queryParameters, String strFieldsToDisplay){
        System.debug('ExpandRoots:::' + expandRoots);
        return getTreeRootNodes2(treeType, treeRootConfigName, rootids, null, selectedNodePath, dataFields, expandRoots, queryParameters, strFieldsToDisplay);
    }

    @RemoteAction
    global static TreeNode[] getTreeRootNodes2(String treeType, String treeRootConfigName, String rootids, String homeids, String selectedNodePath, String dataFields, Boolean expandRoots, String queryParameters, String strFieldsToDisplay){
        List<TreeNode> result = new List<TreeNode>();
        List<String> homeRecordIds = (homeids != null && homeids != '') ? homeids.split(',') : new List<String>();
        List<String> rootidsList = (rootids != null && rootids != '') ? rootids.split(',') : new List<String>();
        if (!homeRecordIds.isEmpty()){
            System.debug('Loog HomeRecordIDds');
            result = loadTreeHomeRecords(treeType, treeRootConfigName, homeRecordIds, queryParameters);
        } else if (rootidsList.isEmpty()){
            //Load defaults and from config
            System.debug('Loog Default');
            result = loadDefaultTreeNodesFromConfig(treeType, treeRootConfigName, dataFields, expandRoots, queryParameters, strFieldsToDisplay);
        } else{
            //Specific root nodes are passed by the caller, in this case use only those root nodes
            System.debug('Loog:0:');
            for (String nodeId : rootidsList){
                System.debug('Loog:nodeId:' + nodeId);
                TreeNode node;
                if (nodeId.startsWith(BT_Constants.TREE_ROOT_OBJECT)){
                    System.debug('Loog:1:');
                    //Object record based node
                    node = loadObjectRecordNode(treeType, nodeId, dataFields, queryParameters, strFieldsToDisplay);
                    System.debug('Loog:2:' + node);
                } else{
                    //Static root node
                    node = new TreeNode(treeType + '/' + nodeId, BT_UIConfig.getConfiguredName(nodeId, null), BT_Constants.TREE_ROOT_LANDING_PAGE, null, false, '', queryParameters);
                    System.debug('Loog:3:' + node);
                }
                if (node == null){
                    continue;
                }
                node.userData.checkable = false;     //Landing page node means not checkable, hide checkbox
                result.add(node);
                System.debug('Result::' + result);
                node.tooltip = BT_UIConfig.getConfiguredName(nodeId, null);
                if (selectedNodePath != null && selectedNodePath.startsWith(node.id)){
                    //Get actual path of the selected node and expand until it's parent.
                    loadChildrenRecursively(node, selectedNodePath, dataFields, false, strFieldsToDisplay);
                } else if (expandRoots){
                    loadChildrenRecursively(node, selectedNodePath, dataFields, true, strFieldsToDisplay);
                }
            }
        }
        //Integer a =1/0;
        return result;
    }

    /*
     *   Purpose:    Get file system tree root nodes. returns each node that is requested by the caller
     *   Parameters: treeType            = Id of parent folder
     *   UnitTests:
     */
    @RemoteAction
    global static TreeNode[] getFolderTreeRoot(String treeType){
        return getFolderTreeRoot(treeType, null, '');
    }

    public static TreeNode[] getFolderTreeRoot(String treeType, String queryParameters, String strFieldsToDisplay){
        List<TreeNode> result = new List<TreeNode>();
        List<String> rootids = getTreeDefaultRootNodeIds(treeType);
        return getTreeRootNodes(BT_Constants.TREE_TYPE_FILE, null, String.join(rootids, ','), null, 'Id,Name', false, queryParameters, strFieldsToDisplay);
    }

    /*
     *   Purpose:   Find children of the object
     *   Parameters: objType        - type of object

     id             - hierarchical object identifier e.g. grandparentId/parentId/childId. The call should
     take the last childId and return children of that object.

     fields         - list of data field names to return as object attributes, if null
     returns only id and name

     objectId     - an object id whose children needs to be returned.
     *   UnitTests:
     */
    @TestVisible
    static TreeNode[] getChildrenForTree(String objType, String id, List<String> fields, String objectId, String queryNVPairs, String queryParameters, String strFieldsToDisplay){
        List<TreeNode> resultChildren = new List<TreeNode>();

        //Special handling for the object that have record type. The record type information is
        //used in the pickers to decide if a node is checkable or not
        if (BT_Utils.hasRecordType(objType)){
            //If nodeQuery is not null and contains query for RecordType.name, we need to filter result for those record types only
            Map<String, String> queryStrings = getQueryParams(null, null, queryNVPairs);
            Set<String> filterRecordTypeNames = null;
            String recordTypeFilter = queryStrings.get('RecordType.name');
            if (recordTypeFilter != null){
                filterRecordTypeNames = new Set<String>();
                filterRecordTypeNames.addAll(recordTypeFilter.split(';', 0));
            }

            List<sObject> sObjs = new List<sObject>();
            //See if this object has children__r relationship to itself
            if (objType.equalsIgnoreCase('Folder__c')){
                sObjs = GenericDAO.getChildren(objType, objectId, new List<String>{'Id', 'Name'});
            } else if (objType.equalsIgnoreCase('File__c')){
                List<String> listFileFields = new List<String>{'Id', 'Name', 'Description__c', 'Access_Type__c', 'OwnerId', 'Public_On_Amazon__c', 'Allow_to_Download_by_Presigned_URL__c', 'Track_Download_History__c', 'File_Presigned_URL__c', 'Amazon_File_Key__c', 'Bucket_Name__c'};
                listFileFields.addAll(BT_Utils.tokenizeStringWithSeparator(strFieldsToDisplay, ','));
                sObjs = GenericDAO.getChildren(objType, objectId, listFileFields);
            } else{
                sObjs = GenericDAO.getChildren(objType, objectId, new List<String>{'Id', 'Name', 'RecordTypeId'});
            }

            Map<Id, String> recordTypeIdToNameMap = new Map<Id, String>();
            Set<Id> recordTypeIds = new Set<Id>();
            //Throwing exception for parent node expand if parent has no child.
            if (sObjs != null){
                for (sObject sObj : sObjs){
                    recordTypeIds.add((Id)sObj.get('RecordTypeId'));
                }
            }
            if (recordTypeIds.size() > 0){
                List<RecordType> recordTypes;
                if (Schema.sObjectType.RecordType.fields.Id.isAccessible() && Schema.sObjectType.RecordType.fields.Name.isAccessible()){
                    recordTypes = [select Id, name
                                   from RecordType
                                   where Id in :recordTypeIds];
                }
                for (RecordType rt : recordTypes){
                    recordTypeIdToNameMap.put(rt.Id, rt.Name);
                }
            }

            if (sObjs != null && sObjs.size() > 0){
                List<TreeNode> nodes = null;
                if (filterRecordTypeNames == null){
                    nodes = convertSObjectsToTreeNodes(sObjs, id, objType, recordTypeIdToNameMap, false, queryParameters);
                } else{
                    nodes = convertSObjectsToTreeNodes2(sObjs, id, objType, recordTypeIdToNameMap, filterRecordTypeNames, queryNVPairs, false, queryParameters);
                }
                resultChildren.addAll(nodes);
            }
        } else{
            //See if this object has children__r relationship to itself
            List<sObject> sObjs = GenericDAO.getChildren(objType, objectId, new List<String>{'Id', 'Name'});
            if (sObjs != null && sObjs.size() > 0){
                List<TreeNode> nodes = convertSObjectsToTreeNodes(sObjs, id, objType, null, false, queryParameters);
                resultChildren.addAll(nodes);
            }
        }
        return resultChildren;
    }

    /*
     *   Purpose:   Find children of the object
     *   Parameters: objType        - type of object

     id             - hierarchical object identifier e.g. grandparentId/parentId/childId. The call should
     take the last childId and return children of that object.

     fields         - list of data field names to return as object attributes, if null
     returns only id and name

     objectId     - an object id whose children needs to be returned.
     *   UnitTests:
     */
    @TestVisible
    static TreeNode[] getChildrenForFolderTree(String objType, String id, List<String> fields, String objectId, String queryParameters, String strFieldsToDisplay){
        List<TreeNode> resultChildren = new List<TreeNode>();
        //Folders tree structure being rendered
        if (objectId == BT_Constants.TREE_TYPE_FILE){
            return getFolderTreeRoot(BT_Constants.TREE_TYPE_FILE, queryParameters, strFieldsToDisplay);
        } else{
            //Regular node, get same type of children of the objectId and then append
            //other types of children e.g. for Folder, get children Folder and then all files
            //linked to the Folder as children too.
            if (objType == 'Folder__c'){
                //Current object is Folder, get children Folder and then Files
                List<String> fieldsForFolder = new List<String>{'Id', 'Name'};
                List<Folder__c> folders = FolderDAO.getChildren(objectId, fieldsForFolder, new List<String>{'createddate'}, BT_Constants.TREE_UI_MAX_NODE, queryParameters);
                List<TreeNode> nodes = convertSObjectsToTreeNodes(folders, id, objType, null, false, queryParameters);
                resultChildren.addAll(nodes);

                //Assume that the number of child Folder's will not go over max tree node limit
                Integer maxFilesCount = BT_Constants.TREE_UI_MAX_NODE - nodes.size();

                //Just in case the number of Folders goes over the limit
                if (maxFilesCount > 0){
                    // Get children files
                    List<File__c> files = FolderDAO.getChildrenFiles(objectId, new List<String>{'Name', 'Description__c', 'Access_Type__c', 'OwnerId', 'Public_On_Amazon__c', 'Allow_to_Download_by_Presigned_URL__c', 'Track_Download_History__c', 'File_Presigned_URL__c', 'Amazon_File_Key__c', 'Bucket_Name__c', 'Extension__c'}, true, new List<String>{'CreatedDate'}, maxFilesCount, queryParameters);
                    if (!files.isEmpty()){
                        List<TreeNode> nodesForInnerFiles = convertSObjectsToTreeNodes(files, id, 'File__c', null, false, queryParameters);
                        resultChildren.addAll(nodesForInnerFiles);
                    }
                }

                if (resultChildren.size() >= BT_Constants.TREE_UI_MAX_NODE){
                    //Too many tree nodes, add error node as first child indicating too many nodes
                    TreeNode errorNode = getMaxTreeNodeError();
                    //There are some child Folder's also. Need to add the error node
                    //at the begining of the result nodes.
                    List<TreeNode> finalNodes = new List<TreeNode>();
                    finalNodes.add(errorNode);
                    finalNodes.addAll(resultChildren);
                    resultChildren = finalNodes;
                }

            } else{
                //See if this object has children__r relationship to itself
                List<sObject> sObjs = GenericDAO.getChildren(objType, objectId, new List<String>{'Id', 'name'});
                if (sObjs.size() > 0){
                    List<TreeNode> nodes = convertSObjectsToTreeNodes(sObjs, id, objType, null, false, queryParameters);
                    resultChildren.addAll(nodes);
                }
            }
        }

        return resultChildren;
    }

    public static String buildWhereClauseUsingQueryParameters(List<BT_TreeRemotingModel.QueryParameter> lstQueryParameters){
        String whereClause = '';
        if (lstQueryParameters != null && !lstQueryParameters.isEmpty()){
            for (BT_TreeRemotingModel.QueryParameter queryParam : lstQueryParameters){
                whereClause += ' AND ' + queryParam.fieldApiName + ' = \'' + queryParam.fieldValue + '\'';
            }
        }
        return whereClause;
    }

    /*
     *   Purpose:   Find children of the object
     *   Parameters: objType        - type of object

     id             - hierarchical object identifier e.g. grandparentId/parentId/childId. The call should
     take the last childId and return children of that object.

     fields         - list of data field names to return as object attributes, if null
     returns only id and name

     objectId     - an object id whose children needs to be returned.
     *   UnitTests:
     */
    @TestVisible
    static TreeNode[] getChildrenForSectionTree(String objType, String id, List<String> fields, String objectId, String orderChildrenBy, String queryParameters, String strFieldsToDisplay){
        List<TreeNode> resultChildren = new List<TreeNode>();
        Set<String> controlFields = new set<String>();
        controlFields.add('Id');
        controlFields.add('Name');
        controlFields.add('Title__c');
        List<Question_Group__c> controls = getChildrenControls(objectId, new List<String>(controlFields), new List<String>{'Sort_Id__c', 'Name'}, true);

        resultChildren = convertSObjectsToTreeNodes(controls, id, 'buildertek__Question_Group__c', null, false, queryParameters);


        system.debug('---resultChildren--->' + resultChildren);
        return resultChildren;
    }

    public static List<buildertek__Question_Group__c> getChildrenControls(Id id, List<String> fields, List<String> sortFields, Boolean nonDeprecatedOnly){
        String soql = 'SELECT id';
        if (fields != null){
            for (String field : fields){
                if (field != 'id'){
                    soql = soql + ', ' + field;
                }
            }
        }

        soql = soql + ' FROM buildertek__Question_Group__c WHERE buildertek__Section__c =:id';
        soql = soql + BT_SoqlUtils.buildOrderByClause(sortFields, true);
        List<buildertek__Question_Group__c> controls;
        /*if(Schema.sObjectType.buildertek__Question_Group__c.fields.id.isAccessible()
         && Schema.sObjectType.buildertek__Question_Group__c.fields.Name.isAccessible()
         && Schema.sObjectType.buildertek__Question_Group__c.fields.buildertek__Parent__c.isAccessible()
         && Schema.sObjectType.buildertek__Question_Group__c.fields.buildertek__Section__c.isAccessible()
         && Schema.sObjectType.buildertek__Question_Group__c.fields.buildertek__Selected_By__c.isAccessible()
         && Schema.sObjectType.buildertek__Question_Group__c.fields.buildertek__Sort_Id__c.isAccessible()
         && Schema.sObjectType.buildertek__Question_Group__c.fields.buildertek__Title__c.isAccessible()){*/
        controls = (List<buildertek__Question_Group__c>)Database.query(soql);
        /*}*/
        return controls;
    }

    @TestVisible
    static TreeNode[] getChildrenForUserTree(String objType, String id, List<String> fields, String objectId, String orderChildrenBy, String queryParameters, String strFieldsToDisplay){
        List<TreeNode> resultChildren = new List<TreeNode>();
        System.debug('**objectId-->' + objectId);
        //Users tree structure being rendered
        if (objectId == BT_Constants.TREE_TYPE_USER){
            return resultChildren;
        } else{
            //Based on the object type, find "Users" contained within this object
            if (objType == 'Account'){
                //Prepare orderby children
                String orderChildrenByString = BT_SoqlUtils.buildSOQLOrderByClause(orderChildrenBy);
                List<User> users = getActivePortalUsersForAccount(objectId, orderChildrenByString);
                List<TreeNode> nodes = convertSObjectsToTreeNodes(users, id, 'User', null, false, queryParameters);
                resultChildren.addAll(nodes);
            } else if (objType == 'Group'){
                //Prepare orderby children
                String orderChildrenByString = BT_SoqlUtils.buildSOQLOrderByClause(orderChildrenBy);
                List<User> users = getActivePortalUsersForGroup(objectId, orderChildrenByString, false);
                List<TreeNode> nodes = convertSObjectsToTreeNodes(users, id, 'User', null, false, queryParameters);
                resultChildren.addAll(nodes);
            } else{
                //See if this object has children__r relationship to itself
                List<sObject> sObjs = new List<Sobject>();
                if (objType.equalsIgnoreCase('Folder__c')){
                    sObjs = GenericDAO.getChildren(objType, objectId, new List<String>{'Id', 'Name'});
                } else if (objType.equalsIgnoreCase('File__c')){
                    List<String> listFileFields = new List<String>{'Id', 'Name', 'Description__c', 'Access_Type__c', 'OwnerId', 'Allow_to_Download_by_Presigned_URL__c', 'Track_Download_History__c', 'File_Presigned_URL__c', 'Amazon_File_Key__c', 'Bucket_Name__c'};
                    sObjs = GenericDAO.getChildren(objType, objectId, listFileFields);
                } else{

                    sObjs = GenericDAO.getChildren(objType, objectId, new List<String>{'Id', 'name'});
                }
                if (sObjs != null && sObjs.size() > 0){
                    List<TreeNode> nodes = convertSObjectsToTreeNodes(sObjs, id, objType, null, false, queryParameters);
                    resultChildren.addAll(nodes);
                }
            }
        }
        return resultChildren;
    }

    /*
     *   Purpose:   Find children of the object
     *   Parameters: objType        - type of object

     id             - hierarchical object identifier e.g. grandparentId/parentId/childId. The call should
     take the last childId and return children of that object.

     fields         - list of data field names to return as object attributes, if null
     returns only id and name

     objectId     - an object id whose children needs to be returned.
     *   UnitTests:
     */
    // get all "active" portal users for the specified group. Returns id, name
    // if group id is not for a valid account or there are no users, returns empty list;
    public static List<User> getActivePortalUsersForGroup(String groupId, String orderChildrenBy, Boolean showOnlyPortalUserFlag){
        Map<Id, List<User>> groupIdByUsers = getActivePortalUsersForGroups(new Set<Id>{Id.valueOf(groupId)}, orderChildrenBy, showOnlyPortalUserFlag);

        if (groupIdByUsers.get(groupId) == null){
            return new List<User>();
        }

        return groupIdByUsers.get(groupId);
    }

    /*
     *   Purpose:   Get all "active" portal users for the specified groups.
     *   Parameters: groupIds    - groupIds
     *   UnitTests:
     */
    public static Map<Id, List<User>> getActivePortalUsersForGroups(Set<Id> groupIds, String orderChildrenBy, Boolean showOnlyPortalUserFlag){
        // Get the user ids along with the group ids.
        Map<Id, Id> userIdByGroupId = new Map<Id, Id>();
        for (GroupMember gm : [SELECT GroupId, UserorGroupId
                               from GroupMember
                               where GroupId In :groupIds]){
            userIdByGroupId.put(gm.UserorGroupId, gm.GroupId);
        }

        // String query doesn't support the map.keyset(), due to that we are converting it into set.
        Set<Id> userOrGroupIdSet = userIdByGroupId.keySet();

        String soql;
        soql = 'Select u.Id, u.name, u.UserType From User u where u.UserType != \'Guest\' and u.isActive = true and u.id in : userOrGroupIdSet';

        Map<Id, List<User>> groupIdByUsers = new Map<Id, List<User>>();
        for (User user : Database.query(soql)){
            Id groupId = userIdByGroupId.get(user.Id);

            if (groupId != null){
                if (!groupIdByUsers.containsKey(groupId)){
                    groupIdByUsers.put(groupId, new List<User>());
                }

                groupIdByUsers.get(groupId).add(user);
            }
        }
        return groupIdByUsers;
    }

    /*
     *   Purpose:       Get all "active" portal users for the specified account. Returns id, name, contactid,
     and accountid for each returned user object.
     if account id is not for a valid account or there are no users, returns empty list;

     *   Parameters: accountId        - account id
     orderChildrenBy
     *   UnitTests:
     */
    public static List<User> getActivePortalUsersForAccount(String accountId, String orderChildrenBy){
        List<User> userList = getActivePortalUsersForAccounts(new Set<Id>{Id.valueOf(accountId)}, orderChildrenBy);

        return userList;
    }

    /*
     *   Purpose:   Get all "active" portal users for the specified accounts.
     *   Parameters: accountIds        - account ids
     orderChildrenBy
     *   UnitTests:
     */
    public static List<User> getActivePortalUsersForAccounts(Set<Id> accountIds, String orderChildrenBy){
        String soql = 'Select u.Id, u.Name, u.ContactId, u.AccountId, u.UserType From User u where u.AccountId In : accountIds and u.IsActive = true';

        if (orderChildrenBy != null && orderChildrenBy.length() > 0 && orderChildrenBy != ''){
            soql = soql + ' ' + orderChildrenBy;
        }

        List<User> userList;
        /* if(Schema.sObjectType.User.fields.Id.isAccessible()
         && Schema.sObjectType.User.fields.Name.isAccessible()
         && Schema.sObjectType.User.fields.ContactId.isAccessible()
         && Schema.sObjectType.User.fields.AccountId.isAccessible()
         && Schema.sObjectType.User.fields.UserType.isAccessible()){*/

        userList = Database.query(soql);
        /*}*/
        return userList;
    }

    /*
     *   Purpose:   Find children of the object
     *   Parameters: objType type of object -- for object type nodes.

     id hierarchical object identifier e.g. grandparentId/parentId/childId. The call should
     take the last childId and return children of that object.

     dataFields comma separated data field names to return as object attributes, if null
     returns only id and name

     nodeType - type of node, one of BT_Constants.TREE_NODE_TYPE_*

     childObjectType - for grouping or query object type nodes

     titleFieldName - title field name for group by and query type nodes

     nodeQuery - queryNVPairs is in the form of Name#Vaue~N2#V2...

     showGroupByCharts - show group by chart in detail pane

     showResultObjectsInTree - show result objects as tree node for the group

     showNewButton - shows new button on the grid

     tncId - tree node configuration id, the object in SFDC
     *   UnitTests:
     */
    @RemoteAction
    global static TreeNode[] getChildren(String objType, String id, String dataFields, String nodeType, String childObjectType, String titleFieldName, String nodeQuery, Boolean showGroupByCharts, Boolean showResultObjectsInTree, Boolean showNewButton, String tncId, String orderChildrenBy, String queryParameters, String strFieldsToDisplay){
        //To support jQuery, if the first character is '/', remove it
        if (id.startsWith('/')){
            id = id.substring(1);
        }

        system.debug('---getChildren--call---' + objType);
        system.debug('---nodeType--call---' + nodeType);


        List<TreeNode> resultChildren = new List<TreeNode>();
        List<String> hierarchicalIds = (id != null && id != '') ? id.split('/') : null;
        List<String> fields = new List<String>{'Id', 'Name'};
        if (hierarchicalIds == null || hierarchicalIds.isEmpty()){
            //Error, throw exception
            throw new BT_ApplicationException(System.Label.Missing_Root_Node_For_Tree_Request);
        }

        //Get the object id whose children need to be returned
        String topNodeId = hierarchicalIds.get(0);
        system.debug('---topNodeId--call---' + topNodeId);
        String objectId = hierarchicalIds.get(hierarchicalIds.size()-1);
        //Here based on the node type, retrive children of the node
        if (nodeType == BT_Constants.TREE_NODE_TYPE_ROOT){
            //Its the root node, means the node that can have only static children in configuration
            List<TreeNode> nodes = loadChildrenTreeNodesFromConfig(tncId, id, dataFields, false, nodeQuery, '', queryParameters, strFieldsToDisplay);
            resultChildren.addAll(nodes);
        } else if (nodeType == BT_Constants.TREE_NODE_TYPE_GROUPBY_ROOT){
            //We need to run the query to get unique values for the titleFieldName
            //and return them as nodes.
            List<TreeNode> nodes = queryGroupByTreeNodes(id, childObjectType, titleFieldName, nodeQuery, showGroupByCharts, showResultObjectsInTree, showNewButton, tncId, queryParameters);
            resultChildren.addAll(nodes);
        } else if (nodeType == BT_Constants.TREE_NODE_TYPE_GROUPBY){
            //One of the group node is clicked under group by root, find all items matching the group node
            List<TreeNode> nodes = queryGroupByChildrenTreeNodes(id, objectId, dataFields, childObjectType, titleFieldName, nodeQuery, showGroupByCharts, showResultObjectsInTree, showNewButton, tncId, orderChildrenBy, queryParameters, strFieldsToDisplay);
            resultChildren.addAll(nodes);
        } else if (nodeType == BT_Constants.TREE_NODE_TYPE_QUERY){
            //By query
            List<TreeNode> nodes = queryGroupByChildrenTreeNodes(id, objectId, dataFields, childObjectType, titleFieldName, nodeQuery, showGroupByCharts, showResultObjectsInTree, showNewButton, tncId, orderChildrenBy, queryParameters, strFieldsToDisplay);
            system.debug('---nodes--->' + nodes);
            resultChildren.addAll(nodes);

        } else if (nodeTYpe == BT_Constants.TREE_NODE_TYPE_OBJECT){
            system.debug('---topNodeId--->' + topNodeId);
            if (topNodeId == BT_Constants.TREE_TYPE_FILE){
                resultChildren = getChildrenForFolderTree(objType, id, fields, objectId, queryParameters, strFieldsToDisplay);
            } else if (topNodeId == BT_Constants.TREE_TYPE_USER){
                resultChildren = getChildrenForUserTree(objType, id, fields, objectId, orderChildrenBy, queryParameters, strFieldsToDisplay);
            } else if (topNodeId == 'Other'){
                if (objType == 'buildertek__Section__c'){
                    resultChildren = getChildrenForSectionTree(objType, id, fields, objectId, orderChildrenBy, queryParameters, strFieldsToDisplay);
                } else if (objType == 'buildertek__Question_Group__c'){
                    List<String> idLst = id.split('/');
                    List<TreeNode> nodes = new List<TreeNode>();
                    if (idLst.size() > 1){
                        String parentId = idLst[1];
                        List<sobject> controls = [SELECT Id, Name, buildertek__Question_HTML__c
                                                  from buildertek__Question__c
                                                  where buildertek__Question_Group__c = :parentId];
                        for (sobject obj : controls){
                            TreeNode n = new TreeNode(id + '/' + obj.Id, (String)obj.get('Name'), objType, '', true, BT_UIConfig.getNodeIconImage(objType, false, obj.Id, '', obj), queryParameters);
                            // n.tooltip = null;
                            n.tooltip = (String)obj.get('Name');
                            //n.expand=false;
                            n.userData.objSelectedRecord = obj;
                            if (String.isNotEmpty((String)obj.get('Name'))){
                                n.title = ((String)obj.get('Name')).replaceAll('<[^>]+>', ' ');
                            } else{
                                n.title = '';
                            }

                            nodes.add(n);
                        }
                    }

                    resultChildren = nodes;
                }
            } else{
                //If record types are passed in query string, filter records for those types.
                resultChildren = getChildrenForTree(objType, id, fields, objectId, nodeQuery, queryParameters, strFieldsToDisplay);
            }
        }
        System.debug('resultChildern::' + resultChildren);
        //Integer a= 1/0;
        return resultChildren;
    }

    /*
     *   Purpose:   Convert sobject into tree node
     *   Parameters: sobjs - sobjs needs to be converted into tree node.
     parentId
     objType
     recordTypeIdToNameMap
     isLeaf
     nodeClass
     queryParameters
     *   UnitTests:
     */
    public static List<TreeNode> convertSObjectsToTreeNodes(List<SObject> sobjs, String parentId, String objType, Map<Id, String> recordTypeIdToNameMap, Boolean isLeaf, String queryParameters){
        List<TreeNode> nodes = new List<TreeNode>();
        for (SObject obj : sobjs){
            String recordTypeName = null;
            if (recordTypeIdToNameMap != null){
                recordTypeName = recordTypeIdToNameMap.get((Id)obj.get('RecordTypeId'));
            }
            Boolean objectIsLeaf = isLeaf;
            if (!objectIsLeaf){
                //Check using object type
                objectIsLeaf = isLeafNodeObjectType(objType, recordTypeName);
            }
            String strTooltip = '';
            if (objType == 'File__c'){
                strTooltip = (String)obj.get('Description__c');
            } else{
                strTooltip = (String)obj.get('Name');
            }

            TreeNode n = new TreeNode(parentId + '/' + obj.Id, (String)obj.get('Name'), objType, recordTypeName, objectIsLeaf, BT_UIConfig.getNodeIconImage(objType, false, obj.Id, recordTypeName, obj), queryParameters);
            n.tooltip = strTooltip != null ? strTooltip : null;
            n.userData.objSelectedRecord = obj;
            if (objType == 'File__c'){
                if (obj.get('Access_Type__c') == BT_Constants.FILE_ACCESS_PRIVATE && obj.get('OwnerId') != UserInfo.getUserId()){
                    n.userData.downloadUrl = new PageReference('/apex/BT_FileDetail').getUrl()+'?cleanId=' + obj.get('Id');
                } else{
                    n.userData.downloadUrl = BT_HomeUtils.getDownloadURL(obj);
                }
            }

            if (objType == 'buildertek__Question_Group__c' || objType == 'Section__c'){
                n.title = (String)obj.get('Title__c');
            }
            nodes.add(n);
        }
        return nodes;
    }

    /*
     *   Purpose:   Convert sobject into tree node. Variation of convertSObjectsToTreeNodes that can filter records for specified record types
     *   Parameters: sobjs - sobjs needs to be converted into tree node.
     parentId
     objType
     recordTypeIdToNameMap
     filterRecordTypes
     queryNVPairs
     isLeaf
     nodeClass
     queryParameters
     *   UnitTests:
     */
    public static List<TreeNode> convertSObjectsToTreeNodes2(List<SObject> sobjs, String parentId, String objType, Map<Id, String> recordTypeIdToNameMap, Set<String> filterRecordTypes, String queryNVPairs, Boolean isLeaf, String queryParameters){
        List<TreeNode> nodes = new List<TreeNode>();
        for (SObject obj : sobjs){
            String recordTypeName = null;
            if (recordTypeIdToNameMap != null){
                recordTypeName = recordTypeIdToNameMap.get((Id)obj.get('RecordTypeId'));
            }
            //Only process node if we do not need to filter based on record type
            if (recordTypeName == null || filterRecordTypes.contains(recordTypeName)){
                Boolean objectIsLeaf = isLeaf;
                if (!objectIsLeaf){
                    //Check using object type
                    objectIsLeaf = isLeafNodeObjectType(objType, recordTypeName);
                }
                String strTooltip = '';
                if (objType == 'File__c'){
                    strTooltip = (String)obj.get('Description__c');
                } else{
                    strTooltip = (String)obj.get('Name');
                }

                TreeNode n = new TreeNode(parentId + '/' + obj.Id, (String)obj.get('Name'), objType, recordTypeName, objectIsLeaf, '', queryParameters);
                n.userData.nodeQuery = queryNVPairs;
                n.tooltip = strTooltip;
                n.userData.objSelectedRecord = obj;
                nodes.add(n);
            }
        }

        return nodes;
    }

    /*
     *   Purpose:   Return is leaf node object type?
     *   Parameters: objType - object type
     recordTypeName
     *   UnitTests:
     */
    public static Boolean isLeafNodeObjectType(String objType, String recordTypeName){
        if (objType == null){
            return false;
        }
        Boolean leaf = false;
        if (objType.equalsIgnoreCase('File__c')){
            leaf = true;
        } else if (objType.equalsIgnoreCase('User')){
            leaf = true;
        }
        return leaf;
    }

    /*
     *   Purpose:   Converts group by aggregate results to tree node. the fieldValue field represents title
     *   Parameters:
     *   UnitTests:
     */
    public static List<TreeNode> queryGroupByTreeNodes(String parentId, String objectType, String groupByField, String queryNVPairs, Boolean showGroupByCharts, Boolean showResultObjectsInTree, Boolean showNewButton, String tncId, String queryParameters){

        List<String> fields = new List<String>{'Id', 'Name', 'Group_By_Query_String__c', 'Allow_To_Select_Grouping_Nodes__c'};
        SOQLManager.checkFieldAccess(Tree_Node_Configuration__c.sObjectType, fields);
        List<Tree_Node_Configuration__c> parentTreeNodes = Database.query('Select ' + BT_Utils.buildSelectListFragment(null, null, fields)+' FROM Tree_Node_Configuration__c WHERE Id =: tncId LIMIT 1');
        Tree_Node_Configuration__c parentTreeNode;
        if (!parentTreeNodes.isEmpty()){
            parentTreeNode = parentTreeNodes[0];
        }
        List<TreeNode> nodes = new List<TreeNode>();

        //queryNVPairs is in the form of Name#Vaue~N2#V2... prepare queryString map of (n,v)
        Map<String, String> queryStrings = BT_Utils.convertNVStringToMap(queryNVPairs, BT_Constants.SEPARATOR_NAME_VALUE, BT_Constants.SEPARATOR_NV_PAIR);

        //Now query for objects grouped by the titleField
        sObject[] result = GenericDAO.getObjectGroupByCount(objectType, groupByField, queryStrings, 'and', parentTreeNode.Group_By_Query_String__c);
        AggregateResult[] groupedResults = (AggregateResult[])result;

        //Convert each of the unique value as tree node of the groupby
        for (AggregateResult ar : groupedResults){
            String title = (String)ar.get('fieldValue');
            Integer count = (Integer)ar.get('fieldCount');
            //If title or id not set, use constant value
            if (title == null || title == ''){
                title = BT_UIConfig.getConfiguredName(BT_Constants.APPURIN_VALUE_NOT_SET, null);
            }
            //If showResultObjectsInTree is not true, mark this as leaf node
            TreeNode node = new TreeNode(parentId + '/' + title, title, BT_Constants.TREE_ROOT_LANDING_PAGE, null, false, null, queryParameters);

            node.userData.childObjectType = objectType;
            node.userData.nodeType = BT_Constants.TREE_NODE_TYPE_GROUPBY;
            node.userData.titleFieldName = groupByField;
            node.userData.nodeQuery = queryNVPairs;
            node.userData.showGroupByCharts = showGroupByCharts;
            node.userData.showResultObjectsInTree = showResultObjectsInTree;
            node.userData.showNewButton = showNewButton;
            node.userData.tncId = tncId;
            node.userData.checkable = parentTreeNode != null ? parentTreeNode.Allow_To_Select_Grouping_Nodes__c : false; // landing page node means not checkable, hide checkbox
            node.folder = true;
            node.tooltip = title;
            if (!showResultObjectsInTree){
                //Do not allow to lazy load
                node.lazy = false;
            }
            nodes.add(node);
        }
        return nodes;
    }

    public static Map<String, String> getQueryParams(String groupByField, String groupByFieldValue, String queryNVPairs){

        //queryNVPairs is in the form of Name#Vaue~N2#V2... prepare queryString map of (n,v)
        Map<String, String> queryStrings = BT_Utils.convertNVStringToMap(queryNVPairs, BT_Constants.SEPARATOR_NAME_VALUE, BT_Constants.SEPARATOR_NV_PAIR);

        //Here groupByFieldValue is the value for groupByField, add this into query string
        if (groupByField != null && groupByField != '' && groupByFieldValue != null && groupByFieldValue != ''){
            if (groupByFieldValue == BT_Constants.APPURIN_VALUE_NOT_SET){
                groupByFieldValue = null;
            }
            queryStrings.put(groupByField, groupByFieldValue);
        }
        return queryStrings;
    }

    public static TreeNode getMaxTreeNodeError(){
        String title = BT_UIConfig.getConfiguredName(BT_Constants.TREE_UI_MAX_NODE_ERROR, null);
        TreeNode node = new TreeNode('maxRecordErrorNodeId', title, null, null, true, BT_Constants.TREE_UI_MAX_NODE_CSSCLASS, null);
        node.userData.childObjectType = null;
        node.userData.nodeType = null;
        node.userData.titleFieldName = null;
        node.userData.nodeQuery = null;
        node.userData.showGroupByCharts = false;
        node.userData.showResultObjectsInTree = false;
        node.lazy = false;
        node.userData.showNewButton = false;
        node.userData.tncId = null;
        node.userData.checkable = false;     //Landing page node means not checkable, hide checkbox
        node.tooltip = title;
        return node;
    }

    // Return group by children nodes
    public static List<TreeNode> queryGroupByChildrenTreeNodes(String parentId, String groupByFieldValue, String dataFields, String objectType, String groupByField, String queryNVPairs, Boolean showGroupByCharts, Boolean showResultObjectsInTree, Boolean showNewButton, String tncId, String orderChildrenBy, String queryParameters, String strFieldsToDisplay){
        List<TreeNode> nodes = new List<TreeNode>();
        List<Tree_Node_Configuration__c> childrenTNCs = null;
        if (tncId != null && tncId != ''){
            childrenTNCs = TreeConfigurationDAO.getChildrenTNC(tncId);
        }

        system.debug('--objectTYpe--' + objectTYpe);
        //Integer i =1/0;
        if (queryParameters != '' && queryParameters != null && objectTYpe == 'buildertek__Section__c'){
            Map<String, List<BT_TreeRemotingModel.QueryParameter>> queryParametersByObject = (Map<String, List<BT_TreeRemotingModel.QueryParameter>>)JSON.deserialize(queryParameters.unescapeHTML4(), Map<String, List<BT_TreeRemotingModel.QueryParameter>>.class);
            List<BT_TreeRemotingModel.QueryParameter> lstQueryParameters = queryParametersByObject.get('buildertek__Section__c');
            String strTemp = '';
            if (lstQueryParameters != null && !lstQueryParameters.isEmpty()){
                for (BT_TreeRemotingModel.QueryParameter queryParam : lstQueryParameters){
                    strTemp += '~' + queryParam.fieldApiName + '#' + String.escapeSingleQuotes(queryParam.fieldValue);
                }
            }
            queryNVPairs = queryNVPairs + strTemp;
        }

        if (parentId != null && parentId.split('/').size() > 2 && queryParameters != '' && queryParameters != null && objectTYpe != 'buildertek__Section__c'){
            Map<String, List<QueryParameter>> queryParametersByObject = (Map<String, List<QueryParameter>>)JSON.deserialize(queryParameters.unescapeHTML4(), Map<String, List<QueryParameter>>.class);
            List<QueryParameter> lstQueryParameters = queryParametersByObject.get(objectTYpe);
            String strTemp = '';
            if (lstQueryParameters != null && !lstQueryParameters.isEmpty()){
                for (QueryParameter queryParam : lstQueryParameters){
                    strTemp += '~' + queryParam.fieldApiName + '#' + queryParam.fieldValue;
                }
            }
            queryNVPairs = queryNVPairs + strTemp;
        }

        if (childrenTNCs != null && childrenTNCs.size() > 0){
            //Need to add parent's filter into the list of filters
            //Here groupByFieldValue is the value for groupByField, add this into query string
            String parentNVPairs = '';
            if (groupByField != null && groupByField != '' && groupByFieldValue != null && groupByFieldValue != ''){
                if (groupByFieldValue == BT_Constants.APPURIN_VALUE_NOT_SET){
                    groupByFieldValue = 'null';
                }
                //Since we are loading children of a parent, need to add parent's filter into the children's filter
                if (queryNVPairs != null && queryNVPairs.length() > 0){
                    //There is some condition in there, add nv pair separator
                    parentNVPairs = queryNVPairs + BT_Constants.SEPARATOR_NV_PAIR + groupByField + BT_Constants.SEPARATOR_NAME_VALUE + groupByFieldValue;
                } else{
                    parentNVPairs = queryNVPairs + BT_Constants.SEPARATOR_NV_PAIR + groupByField + BT_Constants.SEPARATOR_NAME_VALUE + groupByFieldValue;
                }
            }
            nodes = loadChildrenTreeNodesFromConfig(tncId, parentId, dataFields, false, parentNVPairs, orderChildrenBy, queryParameters, strFieldsToDisplay);
        } else{
            Map<String, String> queryStrings = getQueryParams(groupByField, groupByFieldValue, queryNVPairs);

            //Now we have to find objects of objectType with the query string
            List<String> fields = new List<String>{'Id', 'Name'};
            if (objectType == 'File__c'){
                fields.Add('Description__c');
            }

            if (objectType == 'buildertek__Section__c'){
                fields.Add('Title__c');
                fields.Add('Total_Options__c');
                fields.Add('Due_Date__c');
                fields.Add('Total_Tested_Options__c');
                fields.Add('Visible_to_Customer__c');
            }

            list<String> orderBy = new list<String>();
            if (orderChildrenBy != ''){
                String orderChildrenByString = BT_SoqlUtils.buildSOQLOrderByClause(orderChildrenBy);
                //Remove "Order By" from String as we are suing apex lang method to add order by query
                if (orderChildrenByString.contains('ORDER BY')){
                    orderChildrenByString = orderChildrenByString.subString(9);
                    orderBy.add(orderChildrenByString);
                }
            } else{
                orderBy.add('Name');
            }

            //For now we are using record type in checkable nodes for objects with record type
            Boolean hasRecordType = BT_Utils.hasRecordType(objectType);
            if (hasRecordType){
                fields.add('RecordTypeId');
            }

            sObject[] result = GenericDAO.getSObjects(objectType, BT_Constants.TREE_UI_MAX_NODE + 2, fields, queryStrings, '', orderBy, null, null, false);

            if (result.size() > BT_Constants.TREE_UI_MAX_NODE){
                //Too many tree nodes, add error node as first child indicating too many nodes
                TreeNode node = getMaxTreeNodeError();
                nodes.add(node);
            }

            Map<Id, String> recordTypeIdToNameMap = new Map<Id, String>();
            if (hasRecordType){
                Set<Id> recordTypeIds = new Set<Id>();
                for (sObject sObj : result){
                    recordTypeIds.add((Id)sObj.get('RecordTypeId'));
                }
                if (recordTypeIds.size() > 0){
                    List<RecordType> recordTypes;
                    if (Schema.sObjectType.RecordType.fields.Id.isAccessible() && Schema.sObjectType.RecordType.fields.Name.isAccessible()){
                        recordTypes = [select Id, name
                                       from RecordType
                                       where Id in :recordTypeIds];
                    }
                    for (RecordType rt : recordTypes){
                        recordTypeIdToNameMap.put(rt.Id, rt.Name);
                    }
                }
            }


            //Convert each sobject to tree node of the groupby
            for (sObject obj : result){
                String title = (String)obj.get('Name');
                String id = obj.id;

                String recordTypeName = null;
                String adTitleType = null;
                if (recordTypeIdToNameMap.size() > 0){
                    recordTypeName = recordTypeIdToNameMap.get((Id)obj.get('RecordTypeId'));
                }

                String strTooltip = '';

                if (objectType.equalsIgnoreCase('File__c')){
                    strTooltip = (String)obj.get('Description__c');
                } else{
                    strTooltip = (String)obj.get('Name');
                }

                TreeNode node = new TreeNode(parentId + '/' + id, title, objectType, recordTypeName, isLeafNodeObjectType(objectType, recordTypeName), BT_UIConfig.getNodeIconImage(objectType, false, id, recordTypeName, obj), queryParameters);
                node.userData.childObjectType = objectType;
                node.userData.nodeType = BT_Constants.TREE_NODE_TYPE_OBJECT;
                node.userData.titleFieldName = groupByField;
                node.userData.nodeQuery = queryNVPairs;
                node.userData.showGroupByCharts = showGroupByCharts;
                node.userData.showResultObjectsInTree = showResultObjectsInTree;
                node.userData.showNewButton = showNewButton;
                node.userData.tncId = tncId;
                node.userData.orderChildrenBy = orderChildrenBy;
                node.userData.objSelectedRecord = obj;

                if (objectType.equalsIgnoreCase('buildertek__Section__c')){
                    // node.title = (String)obj.get('Title__c');
                    node.title = (String)obj.get('Name');
                    if (obj.get('Total_Options__c') != null){
                        node.userData.totalOptions = String.valueOf(Integer.valueOf((Double)obj.get('Total_Options__c')));
                    } else{
                        node.userData.totalOptions = '0';
                    }

                    if (obj.get('Total_Tested_Options__c') != null){
                        node.userData.totalTestedOptions = String.valueOf(Integer.valueOf((Double)obj.get('Total_Tested_Options__c')));
                    } else{
                        node.userData.totalTestedOptions = '0';
                    }

                    if (obj.get('Visible_to_Customer__c') != null){
                        node.userData.CustomerVisibility = (Boolean)obj.get('Visible_to_Customer__c');
                    } 

                    if (obj.get('Due_Date__c') != null){
                        node.userData.isDue = (Date)obj.get('Due_Date__c') > System.today() ? false : true;
                    } else{
                        node.userData.isDue = false;
                    }
                }

                if (!showResultObjectsInTree){
                    node.lazy = false;
                }
                if (strTooltip != '' && strTooltip != null){
                    strTooltip = strTooltip;
                }
                node.tooltip = strTooltip;
                nodes.add(node);
            }
        }
        return nodes;
    }

    public static string getTreeNodesFromFilePath(Set<String> filePaths, Map<String, String> fileIdByPath, Map<String, Double> fileSizeByPath){
        String treeNodesString = '';
        Map<String, BT_TreeRemotingModel.TreeNode> treeNodeByKeyPath = new Map<String, BT_TreeRemotingModel.TreeNode>();
        List<BT_TreeRemotingModel.TreeNode> treeNodes = new List<BT_TreeRemotingModel.TreeNode>();
        List<String> amazonFilePaths = new List<String>();
        amazonFilePaths.addAll(filePaths);
        //Go through all file needs to delete
        for (integer j = 0; j < amazonFilePaths.size(); j++){
            String filePathNeedsToCheckForImport = amazonFilePaths[j];
            Double size = fileSizeByPath.get(amazonFilePaths[j]);
            List<String> internalPathTokens = filePathNeedsToCheckForImport.split('/');
            String interPath = '';
            for (integer i = 0; i < internalPathTokens.size(); i++){
                interPath += internalPathTokens[i]+'/';
                BT_TreeRemotingModel.TreeNode newTreeNode = new BT_TreeRemotingModel.TreeNode();

                newTreeNode.title = internalPathTokens[i];
                newTreeNode.children = new List<BT_TreeRemotingModel.TreeNode>();
                newTreeNode.key = interPath.substring(0, interPath.length()-1);
                if (fileIdByPath.get(filePathNeedsToCheckForImport) != null){
                    newTreeNode.userData.downloadUrl = EncodingUtil.urlEncode(fileIdByPath.get(filePathNeedsToCheckForImport), 'UTF-8');
                    newTreeNode.userData.id = fileIdByPath.get(filePathNeedsToCheckForImport);
                }
                newTreeNode.userData.key = EncodingUtil.urlEncode(newTreeNode.key, 'UTF-8');
                if (i == 0){
                    newTreeNode.userData.checkable = false;
                } else{
                    newTreeNode.userData.checkable = true;
                }
                newTreeNode.lazy = false;
                newTreeNode.userData.childObjectType = 'AmazonFile';
                if (i == internalPathTokens.size()-1 && internalPathTokens[i].indexOf('.') != -1){
                    newTreeNode.folder = false;
                    newTreeNode.title += (size != null ? ' (' + size / 1000+' KB)' : '');
                    newTreeNode.icon = 'fileIcons/';
                    String extension = internalPathTokens[i].substring(internalPathTokens[i].lastIndexOf('.'), internalPathTokens[i].length());
                    String iconImage = extension != null ? BT_Constants.FILE_ICON_MAP.get(extension.toLowerCase()) : null;
                    if (iconImage == null || iconImage == ''){
                        iconImage = 'file.png';
                    }
                    newTreeNode.icon += iconImage;
                    newTreeNode.userData.objectType = 'AmazonFile';
                    newTreeNode.userData.nodeType = 'NodeType_Query';
                } else{
                    newTreeNode.folder = true;
                    newTreeNode.icon = 'fileIcons/folder.png';
                    newTreeNode.userData.objectType = 'AmazonFolder';
                    newTreeNode.userData.nodeType = 'NodeType_Query';
                }
                String parentKey = interPath.substring(0, interPath.length()-internalPathTokens[i].length()-1);
                BT_TreeRemotingModel.TreeNode parentNode = treeNodeByKeyPath.get(parentKey);
                if (parentNode != null){
                    if (treeNodeByKeyPath.get(interPath) == null){
                        parentNode.children.add(newTreeNode);
                        treeNodeByKeyPath.put(interPath, newTreeNode);
                    }
                } else{
                    if (treeNodeByKeyPath.get(interPath) == null){
                        treeNodes.add(newTreeNode);
                        treeNodeByKeyPath.put(interPath, newTreeNode);
                    }
                }
            }
        }
        treeNodesString = JSON.serialize(treeNodes);
        return treeNodesString;
    }
}