/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Controller Class: BT_TreePickerController
* Created by Sagar
*
* Controller for tree picker

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
public with sharing class BT_TreePickerController {
    public Integer treeWidth {get;set {
        if (value == null) {
            value=350;
        }
        treeWidth=value;
    }}
    
    public Integer totalHeight {get;set {
        if (value == null) {
            value=350;
        }
        totalHeight=value;
    }}
    
    public String treeTypeName{get;set{
        treeTypeName = value;
        }
    }
    
    public String selectedRecordType{get;set{
        if(value != null){
            selectedRecordType = value;
        } else{
            selectedRecordType = System.Label.Records;
        }
        initColumns();
        }
    }
    
    // Columns that are displayed in the list of selected items
    List<Column> columnsToDisplay;
    // Holds selected tree nodes. the list is passed from caller and this controller will add/remove items in the list  
    public List<TreePickerNode> selectedTreeNodes {get;
        set {
            // Here, we need to clean up the checkedObjectIds and checkedObjectsMap to keep only what is selected
            if (value != null) {
                checkedObjectIds.clear();
                for (TreePickerNode tpn : value) {
                    checkedObjectIds.add(tpn.fullpath);
                    checkedObjectsMap.put(tpn.fullpath, tpn);
                    checkedObjectsMapForSort.put(tpn.fullpath, tpn);
                }
                
                // Old objs
                Set<String> keys = checkedObjectsMap.keySet();
                Set<String> oldids = keys.clone();
                for (String k : oldids) {
                    if (!checkedObjectIds.contains(k)) {
                        checkedObjectsMap.remove(k);
                    }
                }
            }
            selectedTreeNodes = value;
        }
    }
    
    // Holds list of checked object ids 
    Set<string> checkedObjectIds;
    // Hold list of checked object ids to TreePickerNode object
    Map<String, TreePickerNode> checkedObjectsMap;
    Map<String, TreePickerNode> CheckedObjectsMapForSort;
    // List of object types whose nodes can be checkable in the tree.
    public List<String> checkableNodes {get;set;}
    public Boolean storeFullPathInTreePickerNodeFlag{get; set;} // If true, full path of selected node will be store in TreePickerNode
    public String rootTreeName{get;set{
            rootTreeName = value;
        }
    }
    
    public BT_TreePickerController() {
        treeWidth = 350;
        totalHeight = 350;
        checkedObjectIds = new Set<string>();
        checkedObjectsMap = new Map<String, TreePickerNode>();
        CheckedObjectsMapForSort= new Map<String, TreePickerNode>();
        initColumns();      
    }           

    private void initColumns() {
        columnsToDisplay = new List<Column>();
        if(selectedRecordType != null){
            columnsToDisplay.add(new Column('name', String.format(system.Label.Selected_Record_Name,new String[]{selectedRecordType}))); 
        } else {
            columnsToDisplay.add(new Column('name', System.Label.Selected_Records_Name)); 
        }          
    }
    
    public void clearAllLists(){
        checkedObjectIds.clear();
        checkedObjectsMap.clear();
        CheckedObjectsMapForSort.clear();
    }
    
    // Get ids of root nodes to display in control tree, as comma separated list.
    public String getTreeRootIds() {
        List<String> rootids = new List<String>();
        return String.join(rootids, ',');
    }
    
    // Return list of selected objects 
    public List<TreePickerNode> getPageRecords() {
        if(CheckedObjectsMapForSort.size() > 0){
            if(selectedTreeNodes.size() == 0){
                CheckedObjectsMapForSort.clear();
            }
        }
        List<TreePickerNode> SortedListToDisplay =  CheckedObjectsMapForSort.values();
        return SortedListToDisplay;
    }
    
    public List<String> getNoSelectedItemList(){
        List<String> emptyListMessage  = new List<string>();
        emptyListMessage.add(String.format(system.Label.No_Record_Selected, new String[]{selectedRecordType}));
        return emptyListMessage;
    }
    
    // Return list of columns
    public List<Column> getColumnsToDisplay() {
        return columnsToDisplay;
    }
    
    // If Checkable Nodes in Tree Configuration is not null then we need to use those values.
    // If Checkable nodes is empty then we need to use as is(hard coded).
    public List<String> getUpdatedCheckableNodes(){
        if(rootTreeName != null){
            List<String> fields = new List<String>{'Id', 'Checkable_Nodes__c'};
            SOQLManager.checkFieldAccess(Tree_Configuration__c.sObjectType, fields);        
            List<Tree_Configuration__c> treeConfigList = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' from Tree_Configuration__c where Name =: rootTreeName'));
            if(treeConfigList != null && treeConfigList.size() > 0){
                if(treeConfigList[0].Checkable_Nodes__c != null){
                    String trimCheckableNodes = treeConfigList[0].Checkable_Nodes__c.trim();
                    List<String> tempCheckableNodesList = trimCheckableNodes.split(',');
                    if(tempCheckableNodesList != null && tempCheckableNodesList.size() > 0){
                        return tempCheckableNodesList;
                    }
                }
            }
        }
        return checkableNodes;
    }
    
    // Has results?
    public Boolean hasResults { 
        get {
            return (checkedObjectIds.size() > 0); 
        }
        set;
    }

    // Number of columns
    public Integer numColumns {get {
        return columnsToDisplay.size();
    }}

    public String noRecordsMessage { get {
        return BT_UIConfig.getConfiguredName(BT_Constants.MSG_NO_RECORDS_SELECTED, null);
    }}
    
    // Update check status
    public PageReference updateCheckStatus() {
        // Get the parameter in controller
        Id checkObjectId = Apexpages.currentPage().getParameters().get('checkObjectId').escapeHtml4();        
        Boolean checkStatus = Boolean.valueOf(Apexpages.currentPage().getParameters().get('checkStatus').escapeHtml4());
        String checkObjectTitle = Apexpages.currentPage().getParameters().get('checkObjectTitle').escapeHtml4();
        String checkObjectPath = Apexpages.currentPage().getParameters().get('checkObjectPath').escapeHtml4();
        System.Debug('checkObjectTitle'+checkObjectTitle);
        if (checkStatus) {
            // New object checked
            // Use the object id and name to create TreePickerNode to add into the map
            TreePickerNode tpe;
            
            tpe = new TreePickerNode(checkObjectId, checkObjectTitle, checkObjectPath);
            checkedObjectIds.add(checkObjectPath);
            checkedObjectsMap.put(checkObjectPath, tpe);
            CheckedObjectsMapForSort.put(checkObjectPath, tpe);
        } else {
            // Object unchecked
            checkedObjectIds.remove(checkObjectPath);
            
            // Remove object
            checkedObjectsMap.remove(checkObjectPath);
            CheckedObjectsMapForSort.remove(checkObjectPath);
        }
        // Update selectedTreeNodes to new list of TreePickerNodes from the map
        selectedTreeNodes.clear();
        selectedTreeNodes.addAll(checkedObjectsMap.values());
        return null;
    }
    
    public class Column {
        public String name {get;set;}
        public String displayName {get;set;} 
        
        public Column(String n, String l) {
            name = n;
            displayName = l;
        }
    }
}