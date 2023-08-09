/* **************************************************************************
* Copyright 2016, BuilderTek.
* All rights reserved
*
* Controller Class: BT_TreePickerWithSelectController
* Created by Sagar
*
* Controller for Tree Picker With Select

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
public with sharing class BT_TreePickerWithSelectController {
    public List<TreePickerNode> alreadySelectedNodes {get; set;}
    public List<TreePickerNode> selectedNodes1 {get; set;}
    public String jsonStringForSelectedNodes{get; set;}
    public Id removedNodeId {get; set;}
    public String searchText{get;set;}
    public Boolean displaySearchResult { get; set; }
    public Boolean displayRecordMessage { get; set; }
    public String displayErrorMessage { get; set; }
    public List<String> searchableObject{get; set;}
    public Map<String, List<sObjectWrapperClass>> sObjectRecList {get; set;}
    public string selectModeForPicker {get; set;}
    Map<String, List<sObject>> searchResult;
    
    // Constructor
    public BT_TreePickerWithSelectController() {
        alreadySelectedNodes = new List<TreePickerNode>();
    }
    
    public pagereference createNodeList(){
    if(jsonStringForSelectedNodes.startsWith('\"')){
        jsonStringForSelectedNodes = jsonStringForSelectedNodes.substring(1,jsonStringForSelectedNodes.length()-1);
        // If json string starts with "\" it meanse its escaped for script so we need to unescape its first. 
        jsonStringForSelectedNodes = jsonStringForSelectedNodes.unescapeEcmaScript();
    }
    List<TreePickerNode> jsonTreeNodeList = (List<TreePickerNode>)System.JSON.deserialize(jsonStringForSelectedNodes,List<TreePickerNode>.class);
    // Clear previsous list
    selectedNodes1.clear();
    for(TreePickerNode jsonNode : jsonTreeNodeList){
        selectedNodes1.add(new TreePickerNode(ID.valueOf(jsonNode.id), jsonNode.name));
    }
    
    // ProcessChecked method removes duplicated nodes (if selected).
    // It not required to execute for single select mode
    if (selectModeForPicker != '1') {
        processChecked();
    }
    return null;
  }
    // Process checked
    public PageReference processChecked() {
        // TODO: Selected tree nodes are in selectedNodes1, do whatever you want such as transferring to list of selected
        // templates, list of selected assets etc.

        displayPopup = false; // close popup
        // Sdd previously selected nodes into updated selected nodes list
        if(alreadySelectedNodes.size() > 0) {
            selectedNodes1.addAll(removeDuplicates(alreadySelectedNodes));
        }
        // Store user selected value in temporary variable
        if(selectedNodes1.size() > 0) {
            // Remove duplicates
            // We are persisting the tree state so we will use only selected node from tree. No need to use previously selected nodes.
            list<TreePickerNode> uniqueNodes = removeDuplicates(selectedNodes1);
            // Maintain selectedNodes1
            // Clear selected nodes and set selected nodes
            selectedNodes1.clear();
            selectedNodes1.addAll(uniqueNodes);
        }
        return null;
    }
    
    // Remove duplicate nodes from selected nodes
    public static list<TreePickerNode> removeDuplicates(list<TreePickerNode> treeNodes){
      list<TreePickerNode> uniqueNodes = new list<TreePickerNode>();
      Set<Id> nodeIds=new Set<Id>();
      for(TreePickerNode treeNode : treeNodes){
          if(!nodeIds.contains(treeNode.Id)){
              nodeIds.add(treeNode.Id);
              uniqueNodes.add(treeNode);
          }
      }
      return uniqueNodes;
    }
    
    public PageReference cancel() {
        // Process cancel
        // Recover list of selected items back. ideally you would maintain selectedAssets or selectedTemplates etc 
        // and copy selectedNodes1 into those list on ok and just clear selectedNodes1 list on cancel.
        return null;
    }


    public boolean displayPopup {get; set;}
    
    // Show pop up       
    public void showPopup() {
        jsonStringForSelectedNodes = System.JSON.serialize(selectedNodes1);
        displayPopup = true;    
    }
    
    public String getDisplayPopupStyle() {       
        if (displayPopup != null && displayPopup) {
            return ''; // make style empty so it gets rendered
        } else {
            return 'display:none'; // do not show popup area
        }   
    }
    
    // Remove node from list
    public void removeItems(){
        // Maintain selectedNodes1
        List<TreePickerNode> nodesToKeep = new List<TreePickerNode>();
        for (TreePickerNode tpn : selectedNodes1) {
            if (tpn.Id != removedNodeId) {
                nodesToKeep.add(tpn);
            }
        }
        // Clear selected nodes, remove duplicates and add into selected nodes
        selectedNodes1.clear();
        selectedNodes1.addAll(removeDuplicates(nodesToKeep));
        // Maintain alreadySelectedNodes
        nodesToKeep = new List<TreePickerNode>();
        for (TreePickerNode tpn : alreadySelectedNodes) {
            if (tpn.Id != removedNodeId) {
                nodesToKeep.add(tpn);
            }
        }
        // Clear alreadySelectedNodes, remove duplicates and add into alreadySelectedNodes
        alreadySelectedNodes.clear();
        alreadySelectedNodes.addAll(removeDuplicates(nodesToKeep));
    }
    public PageReference processSearched(){
        // If select mode is 1 then clear the previsous selection for search and browes.
        if (selectModeForPicker == '1') {
            alreadySelectedNodes.clear();
            selectedNodes1.clear();
        }   
        if(sObjectRecList.size() > 0){
            // Add selected nodes after search into alreadySelectedNodes so that can be use to differentiate from browsed nodes
            for(string sObjType: sObjectRecList.keySet()){
                for(sObjectWrapperClass sObjWrrapper: sObjectRecList.get(sObjType)){
                    if(sObjWrrapper.isSelected == true) {
                        alreadySelectedNodes.add(new TreePickerNode(sObjWrrapper.cSObject.Id, string.valueOf(sObjWrrapper.cSObject.get('Name')).replaceAll('<','&lt;'), true)); 
                    }
                }   
            }
        }
        selectedNodes1.addAll(alreadySelectedNodes);
        displaySearchResult = false;
        searchText = '';
        // ProcessChecked method removes duplicated nodes (if selected).
        // It not required to execute for single select mode
        if(selectModeForPicker != '1') {
            processChecked(); 
        }
        return null;  
    }
   
    public PageReference doSearch() {  
        // Search text is empty
        if(searchText.length() == 0) {
            displayRecordMessage = true;
            displayErrorMessage = System.Label.Please_Enter_Keyword;  
            displaySearchResult = false;   
            return null;         
        }
        
        try {
            if(searchText != '' || searchText != null){
                searchResult = new Map<String, List<sObject>>();
                if(searchableObject.size() > 0){
                    for(String sObjWithRecType: searchableObject){
                        string sObj = sObjWithRecType.split(':')[0];
                        List<String> recTypesList;
                        if(sObjWithRecType.split(':').size() > 1 && (sObjWithRecType.split(':')[1] != null || sObjWithRecType.split(':')[1] != '')){
                            recTypesList = sObjWithRecType.split(':')[1].split('~');
                        }
                        string soql;
                        // If record types are specified in searchable object means we need to display record type in search result
                        // so we need to include record type in query also.
                        if(recTypesList != null && recTypesList.size() > 0){
                            soql = 'SELECT Id, Name, RecordType.Name from '+sObj+' WHERE';
                        } else { 
                            soql = 'SELECT Id, Name from '+sObj+' WHERE';
                        }
                        // If one or more recoird type are specified with searchable object type then only we need to add them query
                        // Otherwise we will go without record type in query
                        if(recTypesList != null && recTypesList.size() > 0){
                            List<string> recTypes = new List<String>();
                            for(String rec: recTypesList){
                                string s = '\''+rec+'\'';
                                recTypes.add(s);    
                            }
                            soql = soql + ' RecordType.Name IN '+recTypes +' AND';
                        }
                        
                        // Finally we will do filter on Name as per the search text
                        String nameLike = '%'+searchText+'%';
                        soql = soql + ' Name LIKE: nameLike';
                        soql = soql + ' limit 999';
                        sObject[] res = database.query(String.escapeSingleQuotes(soql));
                        system.debug('Size ------> '+res.size());
                        if(res.size() > 0){
                            searchResult.put(sObj+'~'+(recTypesList != null ? recTypesList.size(): 0), res);
                        }
                    }
                }
                if(searchResult.size() > 0) {
                    displaySearchResult = true;
                    displayRecordMessage = false;
                    sObjectRecList = new Map<String, List<sObjectWrapperClass>>();
                    for(String sObjType: searchResult.keySet()){
                        string typeSize = sObjType.split('~')[1];
                        Boolean blnShowRecordType = false;
                        if (typeSize != null && Integer.valueof(typeSize) > 1) {
                            blnShowRecordType = true;
                        }
                        sObject[] sobjList = searchResult.get(sObjType);
                        List<sObjectWrapperClass> sObjWrapper = new List<sObjectWrapperClass>();
                        for(sObject sObj: sobjList){
                            sObjectWrapperClass sObjWra = new sObjectWrapperClass(sObj);
                            sObjWra.isSelected = false;
                            sObjWrapper.add(sObjWra);
                        }
                        sObjectRecList.put(sObjType+'~'+String.ValueOf(blnShowRecordType), sObjWrapper);
                    }
                } else {
                    displayRecordMessage=true; 
                    displayErrorMessage = System.Label.No_Search_Record_Found;
                    searchResult=null;
                    displaySearchResult = false;
                    return null;
                }
            }                   
        } catch (System.SearchException se) {
            displayRecordMessage = true; 
            displayErrorMessage = se.getMessage();
            return null;
        }
        return null;
    }
    
    public class sObjectWrapperClass {
        public Boolean isSelected {get;set;}
        public sObject cSObject {get;set;}
        public boolean showRecordType {get; set;}
        
        public sObjectWrapperClass(sObject cSObject){
            this.cSObject = cSObject;
        }
    }
}