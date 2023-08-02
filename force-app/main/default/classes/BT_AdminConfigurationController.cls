/* **************************************************************************
* Copyright © Copyright 2017-2018, BuilderTek
* All rights reserved
*
* Controller Class: BT_AdminConfigurationController
* Created by Sagar
*
* Controlelr for Administration page

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
public with sharing class BT_AdminConfigurationController{
    public Boolean isError{get; set;}
    
    // Varidables for history of opened tabs
    public String strOpenedTabIds{get; set;}
    public String strOpenedPageTabIds{get; set;}
    public String strSelectedTabId{get; set;}
    
    // Lists of parent node configuration objects
    Public List<Admin_Interface_Node_Configuration__c> listNodeConfigurations{get;set;}
    
    // Tab Panel object, use globally in whole page.
    transient Public Component.Apex.OutputText objDynamicTabHeaders {get; set;}
    transient Public Component.Apex.OutputPanel objDynamicTabContents {get; set;}
    
    public boolean isNewOrganization {get; set;}
    public String nameSpacePrefix{get; set;}
    
    private String staticResourceURL = BT_Utils.getResourceURL('SLDS');
    
    // -----------------------------------------------------------------------
    // Constructor Method
    // - Initialize variables used by this VF page
    // - Read data from the Parent Node Configuration object and populate
    // - Get the contents for Home tab
    // -----------------------------------------------------------------------
    Public BT_AdminConfigurationController(){
        isError = false;
        nameSpacePrefix = BT_Utils.getNamespacePrefix();
        listNodeConfigurations = New List<Admin_Interface_Node_Configuration__c>();
        isNewOrganization = BT_Utils.getIsNewOrg();
        strOpenedTabIds = 'Home,';
        strOpenedPageTabIds = '';
        fillMainPanelWithTabs();
    }
    
    /*
    *   Purpose:    Initialize the controller
    *   Parameters: 
    *   UnitTests:  
    */
    public void init(){
         try{
             User currentUser;
             if (Schema.sObjectType.Profile.fields.Name.isAccessible() && Schema.sObjectType.User.fields.Id.isAccessible()) {
                currentUser = [Select Id, Profile.Name From User Where Id = :UserInfo.getUserId() LIMIT 1];    
             }
            if(currentUser.Profile.Name != 'System Administrator'){
                throw new BT_ApplicationException(System.Label.Page_Access_Error);
            }
        } catch(Exception e){
            isError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            return;
        }
    }
    
    /*
    *   Purpose:    Prepare list of dynamic tab components
    *   Parameters: 
    *   UnitTests:  
    */
    Public PageReference fillMainPanelWithTabs(){
        
        fillNodeConfigurationList();
        
        if (listNodeConfigurations.size() > 0) {
            
            // Attributes of headers
            objDynamicTabHeaders = new Component.Apex.OutputText(escape = false, value = '<ul id="AdminConfigTabHeaders" class="slds-tabs_default__nav">');
            objDynamicTabHeaders.value += '<li style="margin:0px;" class="slds-tabs_default__item slds-grid slds-grid--vertical-align-center slds-active" id="Home"><a class="slds-tabs_default__link" id="AdminConfigTabPanelHome__header" title = "'+System.Label.File_Control_Administration+'" onclick="switchTab(this);">'+System.Label.File_Control_Administration+'</a></li>';
            
            
            List<Component.Apex.OutputText> listChildTabHeaders = New List<Component.Apex.OutputText>();
            List<Component.Apex.OutputPanel> listChildTabContents = New List<Component.Apex.OutputPanel>();
            
            // Attributes of tab panel
            objDynamicTabContents = new Component.Apex.OutputPanel(layout = 'block', id='AdminConfigTabContents',  styleClass = 'slds-tabs_default');
            Component.Apex.OutputPanel objHomeTabContent = new Component.Apex.OutputPanel(layout = 'block', id = 'AdminConfigTabPanelHome', styleClass = 'apInfoTab slds-tabs__content slds-show');
            objDynamicTabContents.childComponents.add(objHomeTabContent);
            Component.Apex.OutputText objHomeTabHTML = new Component.Apex.OutputText(escape = false);
            objHomeTabContent.childComponents.add(objHomeTabHTML);
                    
            // HTML Table for child nodes
            if(listNodeConfigurations.size() == 1){
                objHomeTabHTML.value = '<table width="50%" cellspacing="15" cellpadding="10" border="0" id="homeHTMLTable" class="">';
            } else {
                objHomeTabHTML.value = '<table width="100%" cellspacing="15" cellpadding="10" border="0" id="homeHTMLTable" class="">';
            }
            
            Integer intCount = 0;
            for (Integer intI = 0;intI < listNodeConfigurations.size();intI++) {
                
                if (listNodeConfigurations[intI].Parent_Node__c == null) {
                
                    if (math.mod(intCount,2) == 0) {
                        
                        objHomeTabHTML.value += '<tr class="">';
                        Component.Apex.OutputText objTabInfoCardHTML = getTabInfoCard(listNodeConfigurations[intI]);
                        objHomeTabHTML.value += ''+objTabInfoCardHTML.value;
                        intCount++;
                        
                    } else {
                        Component.Apex.OutputText objTabInfoCardHTML = getTabInfoCard(listNodeConfigurations[intI]);
                        objHomeTabHTML.value += ''+objTabInfoCardHTML.value;
                        intCount++;
                    }
                    
                    listChildTabHeaders = getChildTabHeaders(listNodeConfigurations[intI]);
                    if (listChildTabHeaders.size() > 0) {
                        for (Component.Apex.OutputText objTabHeader : listChildTabHeaders) {
                            // Tab for visualforce page on child node
                            objDynamicTabHeaders.value +=  '' + objTabHeader.value;
                        }
                    }
                    
                    listChildTabContents = getChildTabContents(listNodeConfigurations[intI]);
                    if (listChildTabContents.size() > 0) {
                        for (Component.Apex.OutputPanel objTabContent : listChildTabContents) {
                            // Tab for visualforce page on child node
                            objDynamicTabContents.childComponents.add(objTabContent);
                        }
                    }
                }
            }
            objHomeTabHTML.value += '</tr></table>';
            objDynamicTabHeaders.value += '</ul>';
        }
        
        return null;
    }
    
    /*
    *   Purpose: Returns list of child component header components
    *   Parameters: 
    *   UnitTests:  
    */
    public List<Component.Apex.OutputText> getChildTabHeaders(Admin_Interface_Node_Configuration__c objNodeConfiguration){
        List<Component.Apex.OutputText> listChildTabHeaders = New List<Component.Apex.OutputText>();
        if(objNodeConfiguration == null){
            return listChildTabHeaders;
        }
        
        List<Admin_Interface_Node_Configuration__c> listChildNodes = new List<Admin_Interface_Node_Configuration__c> ();
        for(Admin_Interface_Node_Configuration__c childNode : objNodeConfiguration.Admin_Interface_Node_Configurations__r){
            listChildNodes.add(childNode);
        }
        
        if(listChildNodes.size() > 0) {
            
            Component.Apex.OutputText objChildTabHeader = getTabHeader(objNodeConfiguration);
            listChildTabHeaders.add(objChildTabHeader);
            
            for (Integer intI = 0;intI < listChildNodes.size();intI++) {
                Admin_Interface_Node_Configuration__c objNodeForGetTabs;
                for (Admin_Interface_Node_Configuration__c objNextNodeConfiguration : listNodeConfigurations) {
                    if (objNextNodeConfiguration.Id == listChildNodes[intI].Id) {
                        objNodeForGetTabs = objNextNodeConfiguration;
                    }
                }
                
                if (objNodeForGetTabs != null) {
                    List<Component.Apex.OutputText> listNextChildTabHeaders = getChildTabHeaders(objNodeForGetTabs);
                    if (listNextChildTabHeaders.size() > 0)     {
                        for (Component.Apex.OutputText objTabHeader : listNextChildTabHeaders) {
                            listChildTabHeaders.add(objTabHeader);
                        }
                    }
                }
            }
        }
        return listChildTabHeaders;
    }
    
    /*
    *   Purpose: Returns list of child component content components
    *   Parameters: 
    *   UnitTests:  
    */
    public List<Component.Apex.OutputPanel> getChildTabContents(Admin_Interface_Node_Configuration__c objNodeConfiguration){
        List<Component.Apex.OutputPanel> listChildTabContents = New List<Component.Apex.OutputPanel>();
        if(objNodeConfiguration == null){
            return listChildTabContents;
        }
        
        List<Admin_Interface_Node_Configuration__c> listChildNodes = new List<Admin_Interface_Node_Configuration__c> ();
        for(Admin_Interface_Node_Configuration__c childNode : objNodeConfiguration.Admin_Interface_Node_Configurations__r){
            listChildNodes.add(childNode);
        }
        
        if(listChildNodes.size() > 0) {
            Component.Apex.OutputPanel objChildTabContent = New Component.Apex.OutputPanel(layout = 'block', id = 'AdminConfigTabPanel'+objNodeConfiguration.Id, styleClass = 'apInfoTab slds-tabs__content');
            objChildTabContent.expressions.rendered = '{!if(CONTAINS(strOpenedTabIds,\''+objNodeConfiguration.Id+'\'),true,false)}';
            listChildTabContents.Add(objChildTabContent);
            
            Component.Apex.OutputText objChildTabHTML = new Component.Apex.OutputText(escape = false);
            
            // HTML Table for child nodes
            if(listChildNodes.size() == 1) {
                objChildTabHTML.value = '<table width="50%" cellspacing="15" cellpadding="10" border="0" id="'+objNodeConfiguration.Id+'HTMLTabel" class="">';
            } else {
                objChildTabHTML.value = '<table width="100%" cellspacing="15" cellpadding="10" border="0" id="'+objNodeConfiguration.Id+'HTMLTabel" class="">';
            }
            
            Integer intCount = 0;
            for (Integer intI = 0;intI < listChildNodes.size();intI++) {
                if (math.mod(intCount, 2) == 0) {
                    objChildTabHTML.value += '<tr class="">';
                    Component.Apex.OutputText objChildTabInfoCardHTML = getTabInfoCard(listChildNodes[intI]);
                    objChildTabHTML.value += ''+objChildTabInfoCardHTML.value;
                    intCount++;
                    
                } else {
                    Component.Apex.OutputText objChildTabInfoCardHTML = getTabInfoCard(listChildNodes[intI]);
                    objChildTabHTML.value += ''+objChildTabInfoCardHTML.value;
                    intCount++;
                }
                
                Admin_Interface_Node_Configuration__c objNodeForGetTabs;
                for (Admin_Interface_Node_Configuration__c objNextNodeConfiguration : listNodeConfigurations) {
                    if (objNextNodeConfiguration.Id == listChildNodes[intI].Id) {
                        objNodeForGetTabs = objNextNodeConfiguration;
                    }
                }
                
                if (objNodeForGetTabs != null) {
                    List<Component.Apex.OutputPanel> listNextChildTabContents = getChildTabContents(objNodeForGetTabs);
                    if (listNextChildTabContents.size() > 0)     {
                        for (Component.Apex.OutputPanel objTabContent : listNextChildTabContents) {
                            listChildTabContents.add(objTabContent);
                        }
                    }
                }
            }
            objChildTabHTML.value += '</tr></table>';
            objChildTabContent.childComponents.add(objChildTabHTML);
        }
        return listChildTabContents;
    }
    
    /*
    *   Purpose: Returns HTML for tab header
    *   Parameters: 
    *   UnitTests:  
    */
    private Component.Apex.OutputText getTabHeader(Admin_Interface_Node_Configuration__c objNodeConfiguration){
        Component.Apex.OutputText objTabHeader = new Component.Apex.OutputText(escape = false, value = '');
        objTabHeader.value += '<li style="margin:0px;" class="slds-tabs_default__item slds-grid slds-grid--vertical-align-center" id="'+objNodeConfiguration.Id+'"><a class="slds-tabs_default__link" id="AdminConfigTabPanel'+objNodeConfiguration.Id+'__header" title = "'+objNodeConfiguration.Tab_Name__c+'" onclick="switchTab(this);">'+objNodeConfiguration.Tab_Name__c+'</a></li>';
        return objTabHeader;    
    }
    
    /*
    *   Purpose: Returns HTML for tab content
    *   Parameters: 
    *   UnitTests:  
    */
    private Component.Apex.OutputText getTabInfoCard(Admin_Interface_Node_Configuration__c objNodeConfiguration){
        Component.Apex.OutputText objTabInfoCard = new Component.Apex.OutputText(escape = false, value = '');
        if(objNodeConfiguration.Page_URL__c == null) {
            objTabInfoCard.value += '<td width="50%" class="parentNodeDiv" onclick="openChildNodeTab(\''+objNodeConfiguration.Id+'\');">';
        }
        else {
            if (objNodeConfiguration.Open_New_Tab__c == false) {
                objTabInfoCard.value += '<td width="50%" class="parentNodeDiv" onclick="openVFPageTab(\''+objNodeConfiguration.Page_URL__c.escapeEcmaScript().escapeHtml4()+'\',\''+objNodeConfiguration.Tab_Name__c.escapeEcmaScript().escapeHtml4()+'\',\''+objNodeConfiguration.Id+'\');">';
            } else {
                objTabInfoCard.value += '<td width="50%" class="parentNodeDiv" onclick="openNewTab(\''+objNodeConfiguration.Page_URL__c.escapeEcmaScript().escapeHtml4()+'\');">';
            }
        }
        objTabInfoCard.value += '<ul class="slds-has-dividers--around-space" style="cursor: pointer;"><li class="slds-item">';
        objTabInfoCard.value += '<div class="slds-tile slds-tile--board"><div class="slds-tile__detail slds-text-body--small">';
        objTabInfoCard.value += '<p class="slds-text-heading--small"><img class="apLightningTileBoardIcon slds-button__icon" src="'+objNodeConfiguration.Icon_URL__c.escapeHtml4()+'"/><a href="javascript:void(0);">'+objNodeConfiguration.Name.escapeEcmaScript().escapeHtml4()+'</a></p>';
        if(objNodeConfiguration.Description__c != null && objNodeConfiguration.Description__c != ''){
            objTabInfoCard.value += '<p class="slds-truncate">'+objNodeConfiguration.Description__c.escapeEcmaScript().escapeHtml4()+'</p>';    
        }
        objTabInfoCard.value += '</div></div>';
        objTabInfoCard.value += '</li></ul>';
        return objTabInfoCard;
    }
    
    /********************************************************************
    Purpose: Method is for add tab with the it's child nodes, whenever 
             click on parent node.
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/
    Public PageReference openChildNodeTab(){
        if (apexpages.currentpage().getparameters().get('prmParentNodeId') != null) {
            String strParentNodeId = apexpages.currentpage().getparameters().get('prmParentNodeId').escapeHtml4();
            if(!strOpenedTabIds.Contains(strParentNodeId + ',')) {
                strOpenedTabIds += strParentNodeId + ',';
                strSelectedTabId = strParentNodeId;
            } else {
                strSelectedTabId = strParentNodeId;
            }
        }
        return null;
    }
    
    /********************************************************************
    Purpose: Method is for close the tab, and open next or previous tab.
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/
    Public PageReference closeTab(){
        if (apexpages.currentpage().getparameters().get('prmCloseTabId') != null) {
            String strTabId = apexpages.currentpage().getparameters().get('prmCloseTabId').escapeHtml4();
            String strNextNodeId = apexpages.currentpage().getparameters().get('prmNextNodeId').escapeHtml4();
            if (strOpenedTabIds.Contains(strTabId + ',')) {
                strOpenedTabIds = strOpenedTabIds.replace(strTabId + ',','');
                strSelectedTabId = strNextNodeId;
            }
        }
        return null;
    }
    
    /********************************************************************
    Purpose: Method is stands for open visualforce page in next tab.
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/
    Public PageReference openVFPageTab(){
        if (apexpages.currentpage().getparameters().get('prmPageUrl') != null && apexpages.currentpage().getparameters().get('prmPageUrl') != ''
             && apexpages.currentpage().getparameters().get('prmPageTabId') != null) {
            
            String strPageName = apexpages.currentpage().getparameters().get('prmPageUrl').escapeHtml4();
            String strPageTabName = apexpages.currentpage().getparameters().get('prmPageTabeName').escapeHtml4();
            String strPageTabId = apexpages.currentpage().getparameters().get('prmPageTabId').escapeHtml4();
            
            system.debug('strPageName ---------> '+strPageName);
            
            if (!strOpenedPageTabIds.Contains(strPageTabId)) {
                
                List<String> fields = new List<String>{'Id', 'Name', 'Description__c', 'Open_New_Tab__c', 'Icon_URL__c', 'Page_URL__c', 'Tab_Name__c', 'Parent_Node__c'};
                // Check field level access
                SOQLManager.checkFieldAccess(Admin_Interface_Node_Configuration__c.sObjectType, fields);
                // List of node configuration
                Admin_Interface_Node_Configuration__c adminConfigurationNode;
                for(Admin_Interface_Node_Configuration__c node : Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) +' FROM Admin_Interface_Node_Configuration__c LIMIT 999'))){
                    if(node.Id == strPageTabId){
                        adminConfigurationNode = node;
                        break;
                    }
                }
                // Tab for visualforce page on child node
                String strTabHeaders = String.valueOf(objDynamicTabHeaders.value);
                strTabHeaders =  strTabHeaders.substring(0,  strTabHeaders.length() - 5);
                Component.Apex.OutputText objPageTabHeader = getTabHeader(adminConfigurationNode);
                objDynamicTabHeaders.value = strTabHeaders + objPageTabHeader.value;
                objDynamicTabHeaders.value += '</ul>';
                
                // Attributes of tab panel
                Component.Apex.OutputPanel objPageTabContent = new Component.Apex.OutputPanel(layout = 'block', style = 'min-height: 500px;', id = 'AdminConfigTabPanel'+adminConfigurationNode.Id, styleClass = 'apPageTab slds-tabs__content');
                objPageTabContent.expressions.rendered = '{!if(CONTAINS(strOpenedTabIds,\''+strPageTabId+'\'),true,false)}';
                objDynamicTabContents.childComponents.add(objPageTabContent);
                
                // Iframe for visualforce page
                Component.Apex.Iframe objIframe = New Component.Apex.Iframe(id = 'iframe'+adminConfigurationNode.Id);
                //Component.Apex.Image objImg = New Component.Apex.Image(id = 'image'+adminConfigurationNode.Id);
                objPageTabContent.childComponents.add(objIframe);
                //objPageTabContent.childComponents.add(objImg);
                
                if (strPageName.Contains('apex') && strPageName.Contains('?')) { 
                    objIframe.src = strPageName+'&isdtp=vw';
                    if(BT_Utils.isLightning()){
                        objIframe.src += '&isLX=1';
                    }
                } else if (strPageName.Contains('apex')) {
                    objIframe.src = strPageName+'?isdtp=vw';
                    if(BT_Utils.isLightning()){
                        objIframe.src += '&isLX=1';
                    }
                } else {
                    objIframe.src = strPageName;
                    if(BT_Utils.isLightning()){
                        objIframe.src += ''; 
                    }
                    
                }
                
                system.debug('objIframe ------> '+objIframe.src);
                
                objIframe.scrolling = true;
                //objIframe.height = '100%';
              //  objIframe.height = '720px';
                
                strOpenedTabIds += strPageTabId + ',';
                strOpenedPageTabIds += strPageTabId + ',';
                strSelectedTabId = strPageTabId;
                
            } else {
                strOpenedTabIds += strPageTabId + ',';
                strSelectedTabId = strPageTabId;
            }
        }
        return null;
    }
    
    /********************************************************************
    Purpose: fillNodeConfigurationList is for retrieve 
             parent node configuration and fill the list.
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/
    public void fillNodeConfigurationList(){
        List<String> fields = new List<String>{'Id', 'Name', 'Description__c', 'Open_New_Tab__c', 'Icon_URL__c', 'Page_URL__c', 'Tab_Name__c', 'Parent_Node__c'};
        // Check field level access
        SOQLManager.checkFieldAccess(Admin_Interface_Node_Configuration__c.sObjectType, fields);
        // List of node configuration
        listNodeConfigurations = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ','+ 
                                ' (Select '+BT_Utils.buildSelectListFragment(null, null, fields) + 
                                ' FROM Admin_Interface_Node_Configurations__r WHERE Disable__c = False ORDER BY Index__c,Name Asc) FROM Admin_Interface_Node_Configuration__c WHERE Disable__c = False ORDER BY Index__c,Name Asc'));
                                            
    }
    
    /********************************************************************
    Purpose: Initialize new org.
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/
    public pageReference initializeNewOrg(){
        // Initialize new org congfiguration
        BT_Utils.initializeNewOrg();
        Pagereference pg = new PageReference('/apex/BT_AdminConfiguration');
        pg.setRedirect(true);
        return pg;
    }
    
    /********************************************************************
    Purpose: reset the configuration buttons
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/
    public static pageReference reset(){ 
        SavePoint sp = Database.setSavePoint();
        try{
            List<String> fields = new List<String>{'Id'};
            // Check field level access
            SOQLManager.checkFieldAccess(Admin_Interface_Node_Configuration__c.sObjectType, fields);
            List<Admin_Interface_Node_Configuration__c> adminConfigurations = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' from Admin_Interface_Node_Configuration__c limit 999'));
            DMLManager.deleteAsUser(adminConfigurations);
            initialize();
            Pagereference pg = new PageReference('/apex/BT_AdminConfiguration');
            pg.setRedirect(true);
            return pg;
        } catch(Exception ex){
            Database.rollback(sp);
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
            ApexPages.addMessage(errorMsg);
            return null;
        }
    } 
   
    /********************************************************************
    Purpose: initialize the configuration buttons
    Parameters: 
    Returns: 
    Throws:
    ********************************************************************/
    public static void initialize(){ 
        string nameSpacePrefix = BT_Utils.getNamespacePrefix();
        //*******************************************************************
        // Create all first level nodes
        //*******************************************************************
        List<Admin_Interface_Node_Configuration__c> firstLevelNodes = new List<Admin_Interface_Node_Configuration__c>();
        
        Admin_Interface_Node_Configuration__c systemConfigurationNode = new Admin_Interface_Node_Configuration__c();
        systemConfigurationNode.Name = System.Label.System_Configuration;
        systemConfigurationNode.Disable__c = false;
        systemConfigurationNode.Index__c = 1;
        systemConfigurationNode.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        systemConfigurationNode.Tab_Name__c = System.Label.System_Configuration;
        systemConfigurationNode.Page_URL__c = '/apex/BT_ApplicationConfiguration';
        systemConfigurationNode.Description__c = System.Label.System_Configuration_Description;
        firstLevelNodes.add(systemConfigurationNode);
        
        Admin_Interface_Node_Configuration__c fileExplorerPageConfigurationNode = new Admin_Interface_Node_Configuration__c();
        fileExplorerPageConfigurationNode.Name = System.Label.File_Explorer_Page_Configuration;
        fileExplorerPageConfigurationNode.Disable__c = false;
        fileExplorerPageConfigurationNode.Index__c = 2;
        fileExplorerPageConfigurationNode.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        fileExplorerPageConfigurationNode.Tab_Name__c = System.Label.File_Explorer_Page_Configuration;
        fileExplorerPageConfigurationNode.Page_URL__c = '/apex/BT_FileExplorerPageConfiguration';
        fileExplorerPageConfigurationNode.Description__c = System.Label.File_Explorer_Page_Configuration_Description;
        firstLevelNodes.add(fileExplorerPageConfigurationNode);
        
        Admin_Interface_Node_Configuration__c fileUploadConfig = new Admin_Interface_Node_Configuration__c();
        fileUploadConfig.Name = System.Label.File_Upload_Page_Configuration;
        fileUploadConfig.Disable__c = false;
        fileUploadConfig.Index__c = 3;
        fileUploadConfig.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        fileUploadConfig.Page_URL__c = '/apex/BT_FileUploadPageConfiguration';
        fileUploadConfig.Tab_Name__c = System.Label.File_Upload_Page_Configuration;
        fileUploadConfig.Description__c = System.Label.File_Upload_Configuration_Page_Description;
        firstLevelNodes.add(fileUploadConfig);
        
        Admin_Interface_Node_Configuration__c cleanupFilesAndFoldersNode = new Admin_Interface_Node_Configuration__c();
        cleanupFilesAndFoldersNode.Name = System.Label.Cleanup_Files;
        cleanupFilesAndFoldersNode.Disable__c = false;
        cleanupFilesAndFoldersNode.Index__c = 4;
        cleanupFilesAndFoldersNode.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/delete_60.png';
        cleanupFilesAndFoldersNode.Tab_Name__c = System.Label.Cleanup_Files;
        cleanupFilesAndFoldersNode.Page_URL__c = '/apex/BT_CleanupFiles';
        cleanupFilesAndFoldersNode.Description__c = System.Label.Cleanup_Files_Description;
        firstLevelNodes.add(cleanupFilesAndFoldersNode);
        
        Admin_Interface_Node_Configuration__c importFilesAndFoldersNode = new Admin_Interface_Node_Configuration__c();
        importFilesAndFoldersNode.Name = System.Label.Import_Files;
        importFilesAndFoldersNode.Disable__c = false;
        importFilesAndFoldersNode.Index__c = 5;
        importFilesAndFoldersNode.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/download_60.png';
        importFilesAndFoldersNode.Tab_Name__c = System.Label.Import_Files;
        importFilesAndFoldersNode.Page_URL__c = '/apex/BT_ImportFiles';
        importFilesAndFoldersNode.Description__c = System.Label.Import_Files_Description;
        firstLevelNodes.add(importFilesAndFoldersNode);
        
        Admin_Interface_Node_Configuration__c groupManagementNode = new Admin_Interface_Node_Configuration__c();
        groupManagementNode.Name = System.Label.Group_Management;
        groupManagementNode.Disable__c = false;
        groupManagementNode.Index__c = 6;
        groupManagementNode.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/groups_60.png';
        groupManagementNode.Tab_Name__c = System.Label.Group_Management;
        groupManagementNode.Page_URL__c = '/apex/BT_GroupManagement';
        groupManagementNode.Description__c = System.Label.Group_Management_Description;
        firstLevelNodes.add(groupManagementNode);
        
        Admin_Interface_Node_Configuration__c emailFilesNode = new Admin_Interface_Node_Configuration__c();
        emailFilesNode.Name = System.Label.Email_Files_to_Users;
        emailFilesNode.Disable__c = false;
        emailFilesNode.Index__c = 7;
        emailFilesNode.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/email_60.png';
        emailFilesNode.Open_New_Tab__c = true;
        emailFilesNode.Tab_Name__c = System.Label.Email_Files_to_Users;
        emailFilesNode.Page_URL__c = '/apex/'+nameSpacePrefix+'BT_EmailFilesToUsers';
        emailFilesNode.Description__c = System.Label.Email_Files_to_Users_Description;
        firstLevelNodes.add(emailFilesNode);
        
        Admin_Interface_Node_Configuration__c treeConfigurationNode = new Admin_Interface_Node_Configuration__c();
        treeConfigurationNode.Name = System.Label.Tree_Configuration;
        treeConfigurationNode.Disable__c = false;
        treeConfigurationNode.Index__c = 8;
        treeConfigurationNode.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        treeConfigurationNode.Tab_Name__c = System.Label.Tree_Configuration;
        treeConfigurationNode.Open_New_Tab__c = true;
        Schema.DescribeSObjectResult describeTreeConfigurationResult = Tree_Configuration__c.sObjectType.getDescribe();
        treeConfigurationNode.Page_URL__c = '/'+describeTreeConfigurationResult.getKeyPrefix();
        treeConfigurationNode.Description__c = System.Label.Tree_Configuration_Description;
        firstLevelNodes.add(treeConfigurationNode);

        Admin_Interface_Node_Configuration__c RfiConfig = new Admin_Interface_Node_Configuration__c();
        RfiConfig.Name = 'BT RFI Configuration';
        RfiConfig.Disable__c = false;
        RfiConfig.Index__c = 9;
        RfiConfig.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        RfiConfig.Open_New_Tab__c = false;
        RfiConfig.Tab_Name__c = 'BT RFI Configuration';
        RfiConfig.Page_URL__c = '/apex/buildertek__RFI_Settingsvf';
        RfiConfig.Description__c = 'Configure RFI Process for your organization.';
        firstLevelNodes.add(RfiConfig);

        Admin_Interface_Node_Configuration__c BTPaymentApplicationConfiguration = new Admin_Interface_Node_Configuration__c();
        BTPaymentApplicationConfiguration.Name = 'BT Payment Application Configuration';
        BTPaymentApplicationConfiguration.Disable__c = false;
        BTPaymentApplicationConfiguration.Index__c = 10;
        BTPaymentApplicationConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BTPaymentApplicationConfiguration.Open_New_Tab__c = false;
        BTPaymentApplicationConfiguration.Tab_Name__c = 'BT Payment Application Configuration';
        BTPaymentApplicationConfiguration.Description__c = 'Configure payment Application  Process for your organization.';
        firstLevelNodes.add(BTPaymentApplicationConfiguration);

        Admin_Interface_Node_Configuration__c TrainingSettings = new Admin_Interface_Node_Configuration__c();
        TrainingSettings.Name = 'Training Settings';
        TrainingSettings.Disable__c = false;
        TrainingSettings.Index__c = 11;
        TrainingSettings.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        TrainingSettings.Open_New_Tab__c = false;
        TrainingSettings.Tab_Name__c = 'Training Settings';
        TrainingSettings.Page_URL__c = '/apex/TrainingSettings';
        TrainingSettings.Description__c = 'Configure Training Process for your organization.';
        firstLevelNodes.add(TrainingSettings);
        
        Admin_Interface_Node_Configuration__c MSAConfiguration = new Admin_Interface_Node_Configuration__c();
        MSAConfiguration.Name = 'MSA Configuration';
        MSAConfiguration.Disable__c = false;
        MSAConfiguration.Index__c = 12;
        MSAConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        MSAConfiguration.Open_New_Tab__c = false;
        MSAConfiguration.Tab_Name__c = 'MSA Configuration';
        MSAConfiguration.Description__c = 'Configure MSA Process for your organization.';
        firstLevelNodes.add(MSAConfiguration);

        Admin_Interface_Node_Configuration__c RFQConfiguration = new Admin_Interface_Node_Configuration__c();
        RFQConfiguration.Name = 'BT RFQ Configuration';
        RFQConfiguration.Disable__c = false;
        RFQConfiguration.Index__c = 13;
        RFQConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        RFQConfiguration.Open_New_Tab__c = false;
        RFQConfiguration.Tab_Name__c = 'BT RFQ Configuration';
        RFQConfiguration.Description__c = 'Configure RFQ Process for your organization.';
        firstLevelNodes.add(RFQConfiguration);

        Admin_Interface_Node_Configuration__c BOMLineSettings = new Admin_Interface_Node_Configuration__c();
        BOMLineSettings.Name = 'BOM Line Settings';
        BOMLineSettings.Disable__c = false;
        BOMLineSettings.Index__c = 14;
        BOMLineSettings.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BOMLineSettings.Open_New_Tab__c = false;
        BOMLineSettings.Tab_Name__c = 'BOM Line Settings';
        BOMLineSettings.Page_URL__c = '/apex/BOMLineSettings';
        BOMLineSettings.Description__c = 'Configure BOM Line Process for your organization.';
        firstLevelNodes.add(BOMLineSettings);

        Admin_Interface_Node_Configuration__c BOMSettings = new Admin_Interface_Node_Configuration__c();
        BOMSettings.Name = 'BOM Settings';
        BOMSettings.Disable__c = false;
        BOMSettings.Index__c = 15;
        BOMSettings.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BOMSettings.Open_New_Tab__c = false;
        BOMSettings.Tab_Name__c = 'BOM Settings';
        BOMSettings.Page_URL__c = '/apex/BOMSettings';
        BOMSettings.Description__c = 'Configure BOM Process for your organization.';
        BOMSettings.buildertek__Update_Quantity__c = true;
        BOMSettings.buildertek__Show_Fabrication_taxes__c = true;
        firstLevelNodes.add(BOMSettings);

        Admin_Interface_Node_Configuration__c BTQuickBooksConfiguration = new Admin_Interface_Node_Configuration__c();
        BTQuickBooksConfiguration.Name = 'BT QuickBooks Configuration';
        BTQuickBooksConfiguration.Disable__c = false;
        BTQuickBooksConfiguration.Index__c = 16;
        BTQuickBooksConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BTQuickBooksConfiguration.Open_New_Tab__c = false;
        BTQuickBooksConfiguration.Tab_Name__c = 'BT QuickBooks Configuration';
        BTQuickBooksConfiguration.Page_URL__c = '/apex/BT_Quickbooks_Config';
        BTQuickBooksConfiguration.Description__c = 'Configure Quickbooks Process for your organization.';
        firstLevelNodes.add(BTQuickBooksConfiguration);

        Admin_Interface_Node_Configuration__c BTPreQualificationConfiguration = new Admin_Interface_Node_Configuration__c();
        BTPreQualificationConfiguration.Name = 'BT Pre Qualification Configuration';
        BTPreQualificationConfiguration.Disable__c = false;
        BTPreQualificationConfiguration.Index__c = 17;
        BTPreQualificationConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BTPreQualificationConfiguration.Open_New_Tab__c = false;
        BTPreQualificationConfiguration.Tab_Name__c = 'BT Pre Qualification Configuration';
        BTPreQualificationConfiguration.Description__c = 'Configure Pre Qualification Process for your organization.';
        firstLevelNodes.add(BTPreQualificationConfiguration);

        Admin_Interface_Node_Configuration__c BTDocumentConfiguration = new Admin_Interface_Node_Configuration__c();
        BTDocumentConfiguration.Name = 'BT Document Configuration';
        BTDocumentConfiguration.Disable__c = false;
        BTDocumentConfiguration.Index__c = 18;
        BTDocumentConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BTDocumentConfiguration.Open_New_Tab__c = false;
        BTDocumentConfiguration.Tab_Name__c = 'BT Document Configuration';
        BTDocumentConfiguration.Description__c = 'Configure Document Interface for your organization.';
        firstLevelNodes.add(BTDocumentConfiguration);

        Admin_Interface_Node_Configuration__c BTProjectConfiguration = new Admin_Interface_Node_Configuration__c();
        BTProjectConfiguration.Name = 'BT Project Configuration';
        BTProjectConfiguration.Disable__c = false;
        BTProjectConfiguration.Index__c = 19;
        BTProjectConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BTProjectConfiguration.Open_New_Tab__c = false;
        BTProjectConfiguration.Tab_Name__c = 'BT Project Configuration';
        BTProjectConfiguration.Description__c = 'Configure Project Process for your organization.';
        firstLevelNodes.add(BTProjectConfiguration);

        Admin_Interface_Node_Configuration__c BTAccountPayableConfiguration = new Admin_Interface_Node_Configuration__c();
        BTAccountPayableConfiguration.Name = 'BT Account Payable Configuration';
        BTAccountPayableConfiguration.Disable__c = false;
        BTAccountPayableConfiguration.Index__c = 20;
        BTAccountPayableConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BTAccountPayableConfiguration.Open_New_Tab__c = false;
        BTAccountPayableConfiguration.Tab_Name__c = 'BT Account Payable Configuration';
        BTAccountPayableConfiguration.Description__c = 'Configure Account Payable Process for your organization.';
        firstLevelNodes.add(BTAccountPayableConfiguration);

        Admin_Interface_Node_Configuration__c BTQuoteConfiguration = new Admin_Interface_Node_Configuration__c();
        BTQuoteConfiguration.Name = 'BT Quote Configuration';
        BTQuoteConfiguration.Disable__c = false;
        BTQuoteConfiguration.Index__c = 21;
        BTQuoteConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BTQuoteConfiguration.Open_New_Tab__c = false;
        BTQuoteConfiguration.Tab_Name__c = 'BT Quote Configuration';
        BTQuoteConfiguration.Description__c = 'Configure Quote Process for your organization.';
        firstLevelNodes.add(BTQuoteConfiguration);

        Admin_Interface_Node_Configuration__c BTContractConfiguration = new Admin_Interface_Node_Configuration__c();
        BTContractConfiguration.Name = 'BT Contract Configuration';
        BTContractConfiguration.Disable__c = false;
        BTContractConfiguration.Index__c = 22;
        BTContractConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BTContractConfiguration.Open_New_Tab__c = false;
        BTContractConfiguration.Tab_Name__c = 'BT Contract Configuration';
        BTContractConfiguration.Description__c = 'Configure Contract Process for your organization.';
        firstLevelNodes.add(BTContractConfiguration);

        Admin_Interface_Node_Configuration__c BTBudgetConfiguration = new Admin_Interface_Node_Configuration__c();
        BTBudgetConfiguration.Name = 'BT Budget Configuration';
        BTBudgetConfiguration.Disable__c = false;
        BTBudgetConfiguration.Index__c = 23;
        BTBudgetConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BTBudgetConfiguration.Open_New_Tab__c = false;
        BTBudgetConfiguration.Tab_Name__c = 'BT Budget Configuration';
        BTBudgetConfiguration.Description__c = 'Configure Budget Process for your organization.';
        firstLevelNodes.add(BTBudgetConfiguration);

        Admin_Interface_Node_Configuration__c BTChangeOrderConfiguration = new Admin_Interface_Node_Configuration__c();
        BTChangeOrderConfiguration.Name = 'BT Change Order Configuration';
        BTChangeOrderConfiguration.Disable__c = false;
        BTChangeOrderConfiguration.Index__c = 24;
        BTChangeOrderConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BTChangeOrderConfiguration.Open_New_Tab__c = false;
        BTChangeOrderConfiguration.Tab_Name__c = 'BT Change Order Configuration';
        BTChangeOrderConfiguration.Description__c = 'Configure Change Order Process for your organization.';
        firstLevelNodes.add(BTChangeOrderConfiguration);

        Admin_Interface_Node_Configuration__c BoxSettings = new Admin_Interface_Node_Configuration__c();
        BoxSettings.Name = 'Box Settings';
        BoxSettings.Disable__c = false;
        BoxSettings.Index__c = 25;
        BoxSettings.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BoxSettings.Open_New_Tab__c = false;
        BoxSettings.Tab_Name__c = 'Box Settings';
        BoxSettings.Description__c = 'Configure Box Process for your organization.';
        firstLevelNodes.add(BoxSettings);

        Admin_Interface_Node_Configuration__c EmailConfiguration = new Admin_Interface_Node_Configuration__c();
        EmailConfiguration.Name = 'Email Configuration';
        EmailConfiguration.Disable__c = false;
        EmailConfiguration.Index__c = 26;
        EmailConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        EmailConfiguration.Open_New_Tab__c = false;
        EmailConfiguration.Tab_Name__c = 'Email Configuration';
        EmailConfiguration.Page_URL__c = '/apex/BT_EmailConfiguration';
        EmailConfiguration.Description__c = 'Configure Email Address for your organization.';
        firstLevelNodes.add(EmailConfiguration);

        Admin_Interface_Node_Configuration__c BTSOVConfiguration = new Admin_Interface_Node_Configuration__c();
        BTSOVConfiguration.Name = 'BT SOV Configuration';
        BTSOVConfiguration.Disable__c = false;
        BTSOVConfiguration.Index__c = 27;
        BTSOVConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BTSOVConfiguration.Open_New_Tab__c = false;
        BTSOVConfiguration.Tab_Name__c = 'BT SOV Configuration';
        BTSOVConfiguration.Description__c = 'Configure SOV Process for your organization.';
        firstLevelNodes.add(BTSOVConfiguration);

        Admin_Interface_Node_Configuration__c BTPurchaseOrderConfiguration = new Admin_Interface_Node_Configuration__c();
        BTPurchaseOrderConfiguration.Name = 'BT Purchase Order Configuration';
        BTPurchaseOrderConfiguration.Disable__c = false;
        BTPurchaseOrderConfiguration.Index__c = 28;
        BTPurchaseOrderConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BTPurchaseOrderConfiguration.Open_New_Tab__c = false;
        BTPurchaseOrderConfiguration.Tab_Name__c = 'BT Purchase Order Configuration';
        BTPurchaseOrderConfiguration.Description__c = 'Configure Purchase Order Process for your organization.';
        firstLevelNodes.add(BTPurchaseOrderConfiguration);

        Admin_Interface_Node_Configuration__c StripeSettings = new Admin_Interface_Node_Configuration__c();
        StripeSettings.Name = 'Stripe Settings';
        StripeSettings.Disable__c = false;
        StripeSettings.Index__c = 29;
        StripeSettings.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        StripeSettings.Open_New_Tab__c = false;
        StripeSettings.Tab_Name__c = 'Stripe Settings';
        StripeSettings.Page_URL__c = '/apex/BTStripeSettings';
        StripeSettings.Description__c = 'Configure Stripe Process for your organization.';
        firstLevelNodes.add(StripeSettings);
        
        Admin_Interface_Node_Configuration__c BTTraining = new Admin_Interface_Node_Configuration__c();
        BTTraining.Name = 'BT Training';
        BTTraining.Disable__c = false;
        BTTraining.Index__c = 30;
        BTTraining.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BTTraining.Open_New_Tab__c = false;
        BTTraining.Tab_Name__c = 'BT Training';
        // BTTraining.Page_URL__c = '/apex/BTStripeSettings';
        BTTraining.Description__c = 'Configure Training.';
        firstLevelNodes.add(BTTraining);

        Admin_Interface_Node_Configuration__c BTOpportunityConfiguration = new Admin_Interface_Node_Configuration__c();
        BTOpportunityConfiguration.Name = 'BT Opportunity Configuration';
        BTOpportunityConfiguration.Disable__c = false;
        BTOpportunityConfiguration.Index__c = 31;
        BTOpportunityConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BTOpportunityConfiguration.Open_New_Tab__c = false;
        BTOpportunityConfiguration.Tab_Name__c = 'BT Opportunity Configuration';
        BTOpportunityConfiguration.Description__c = 'Configure Opportunity Process for your organization.';
        firstLevelNodes.add(BTOpportunityConfiguration);

        Admin_Interface_Node_Configuration__c BudgetConfiguration = new Admin_Interface_Node_Configuration__c();
        BudgetConfiguration.Name = 'Budget Configuration';
        BudgetConfiguration.Disable__c = false;
        BudgetConfiguration.Index__c = 32;
        BudgetConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BudgetConfiguration.Open_New_Tab__c = false;
        BudgetConfiguration.Tab_Name__c = 'Budget Configuration';
        BudgetConfiguration.Page_URL__c = '/apex/BT_CreateBudgetConfiguration';
        BudgetConfiguration.buildertek__Create_Budget_on_Quote_Acceptance__c = true;
        BudgetConfiguration.buildertek__Automatically_add_Expense_to_Budget__c = true;
        BudgetConfiguration.buildertek__Automatically_add_Time_Card_to_Budget__c = true;
        firstLevelNodes.add(BudgetConfiguration);

        Admin_Interface_Node_Configuration__c CreateContractonQuoteAcceptance = new Admin_Interface_Node_Configuration__c();
        CreateContractonQuoteAcceptance.Name = 'Create Contract on Quote Acceptance';
        CreateContractonQuoteAcceptance.Disable__c = false;
        CreateContractonQuoteAcceptance.Index__c = 33;
        CreateContractonQuoteAcceptance.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        CreateContractonQuoteAcceptance.Open_New_Tab__c = false;
        CreateContractonQuoteAcceptance.Tab_Name__c = 'Create Contract on Quote Acceptance';
        CreateContractonQuoteAcceptance.Page_URL__c = '/apex/BT_CreateContractOnQuoteAcceptance';
        CreateContractonQuoteAcceptance.buildertek__Change_Order_Configuration__c = true;
        firstLevelNodes.add(CreateContractonQuoteAcceptance);

        Admin_Interface_Node_Configuration__c TurnoffCostOptionAllowanceCheck = new Admin_Interface_Node_Configuration__c();
        TurnoffCostOptionAllowanceCheck.Name = 'Turn off Cost Option Allowance Check';
        TurnoffCostOptionAllowanceCheck.Disable__c = false;
        TurnoffCostOptionAllowanceCheck.Index__c = 34;
        TurnoffCostOptionAllowanceCheck.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        TurnoffCostOptionAllowanceCheck.Open_New_Tab__c = false;
        TurnoffCostOptionAllowanceCheck.Tab_Name__c = 'Turn off Cost Option Allowance Check';
        TurnoffCostOptionAllowanceCheck.Page_URL__c = '/apex/BT_CostOverageCheck';
        firstLevelNodes.add(TurnoffCostOptionAllowanceCheck);

        Admin_Interface_Node_Configuration__c MSAConfiguration1 = new Admin_Interface_Node_Configuration__c();
        MSAConfiguration1.Name = 'MSA Configuration';
        MSAConfiguration1.Disable__c = false;
        MSAConfiguration1.Index__c = 35;
        MSAConfiguration1.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        MSAConfiguration1.Open_New_Tab__c = false;
        MSAConfiguration1.Tab_Name__c = 'MSA Configuration';
        MSAConfiguration1.Page_URL__c = '/apex/BT_MSA_Settings';
        firstLevelNodes.add(MSAConfiguration1);

        Admin_Interface_Node_Configuration__c PaymentApplicationConfiguration = new Admin_Interface_Node_Configuration__c();
        PaymentApplicationConfiguration.Name = 'Payment Application Configuration';
        PaymentApplicationConfiguration.Disable__c = false;
        PaymentApplicationConfiguration.Index__c = 36;
        PaymentApplicationConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        PaymentApplicationConfiguration.Open_New_Tab__c = false;
        PaymentApplicationConfiguration.Tab_Name__c = 'Payment Application Configuration';
        PaymentApplicationConfiguration.Page_URL__c = '/apex/BT_CreatePaymentApplicationConfiguration';
        PaymentApplicationConfiguration.buildertek__Get_Lines_From_CO__c = true;
        PaymentApplicationConfiguration.buildertek__User_SOV_Sharing__c = true;
        firstLevelNodes.add(PaymentApplicationConfiguration);

        Admin_Interface_Node_Configuration__c PreQualificationConfiguration = new Admin_Interface_Node_Configuration__c();
        PreQualificationConfiguration.Name = 'Pre Qualification Configuration';
        PreQualificationConfiguration.Disable__c = false;
        PreQualificationConfiguration.Index__c = 37;
        PreQualificationConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        PreQualificationConfiguration.Open_New_Tab__c = false;
        PreQualificationConfiguration.Tab_Name__c = 'Pre Qualification Configuration';
        PreQualificationConfiguration.Page_URL__c = '/apex/BT_PreQualificationConfiguration';
        PreQualificationConfiguration.buildertek__Selected_Templates__c = 'Pre_QualProcess_VF,Standard_PreQual_VF';
        firstLevelNodes.add(PreQualificationConfiguration);

        Admin_Interface_Node_Configuration__c ProjectConfiguration = new Admin_Interface_Node_Configuration__c();
        ProjectConfiguration.Name = 'Project Configuration';
        ProjectConfiguration.Disable__c = false;
        ProjectConfiguration.Index__c = 38;
        ProjectConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        ProjectConfiguration.Open_New_Tab__c = false;
        ProjectConfiguration.Tab_Name__c = 'Project Configuration';
        ProjectConfiguration.Page_URL__c = '/apex/BT_CreateProjectConfiguration';
        ProjectConfiguration.buildertek__Retreive_Aerial_Photo_of_project__c = true;
        ProjectConfiguration.buildertek__Google_Map_API_Key__c = 'AIzaSyA3kg7YWugGl1lTXmAmaBGPNhDW9pEh5bo';
        firstLevelNodes.add(ProjectConfiguration);

        Admin_Interface_Node_Configuration__c BoxSettings1 = new Admin_Interface_Node_Configuration__c();
        BoxSettings1.Name = 'Box Settings';
        BoxSettings1.Disable__c = false;
        BoxSettings1.Index__c = 39;
        BoxSettings1.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        BoxSettings1.Open_New_Tab__c = false;
        BoxSettings1.Tab_Name__c = 'Box Settings';
        BoxSettings1.Page_URL__c = '/apex/BT_BOX_Settings';
        firstLevelNodes.add(BoxSettings1);

        Admin_Interface_Node_Configuration__c SOVConfiguration = new Admin_Interface_Node_Configuration__c();
        SOVConfiguration.Name = 'SOV Configuration';
        SOVConfiguration.Disable__c = false;
        SOVConfiguration.Index__c = 40;
        SOVConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        SOVConfiguration.Open_New_Tab__c = false;
        SOVConfiguration.Tab_Name__c = 'SOV Configuration';
        SOVConfiguration.Page_URL__c = '/apex/BT_BOX_Settings';
        firstLevelNodes.add(SOVConfiguration);

        Admin_Interface_Node_Configuration__c RFQConfiguration1 = new Admin_Interface_Node_Configuration__c();
        RFQConfiguration1.Name = 'RFQ Configuration';
        RFQConfiguration1.Disable__c = false;
        RFQConfiguration1.Index__c = 41;
        RFQConfiguration1.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        RFQConfiguration1.Open_New_Tab__c = false;
        RFQConfiguration1.Tab_Name__c = 'RFQ Configuration';
        RFQConfiguration1.Page_URL__c = '/apex/BT_CreateRFQConfiguration';
        RFQConfiguration1.buildertek__Email_Subject__c = 'BuilderTek RFQ';
        RFQConfiguration1.buildertek__Retreive_Aerial_Photo_of_project__c = true;
        firstLevelNodes.add(RFQConfiguration1);

        Admin_Interface_Node_Configuration__c PurchaseOrderConfiguration1 = new Admin_Interface_Node_Configuration__c();
        PurchaseOrderConfiguration1.Name = 'Purchase Order Configuration';
        PurchaseOrderConfiguration1.Disable__c = false;
        PurchaseOrderConfiguration1.Index__c = 42;
        PurchaseOrderConfiguration1.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        PurchaseOrderConfiguration1.Open_New_Tab__c = false;
        PurchaseOrderConfiguration1.Tab_Name__c = 'Purchase Order Configuration';
        PurchaseOrderConfiguration1.Page_URL__c = '/apex/BT_CreatePurchaseOrderConfiguration';
        PurchaseOrderConfiguration1.Description__c = 'Use to send email on PO Approved';
        PurchaseOrderConfiguration1.buildertek__Email_Subject__c = 'image.png';
        PurchaseOrderConfiguration1.buildertek__Send_PO_On_Approval__c = true;
        PurchaseOrderConfiguration1.buildertek__Create_Invoice_on_Approval__c = true;
        firstLevelNodes.add(PurchaseOrderConfiguration1);

        Admin_Interface_Node_Configuration__c ChangeOrderConfiguration = new Admin_Interface_Node_Configuration__c();
        ChangeOrderConfiguration.Name = 'Change Order Configuration';
        ChangeOrderConfiguration.Disable__c = false;
        ChangeOrderConfiguration.Index__c = 43;
        ChangeOrderConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        ChangeOrderConfiguration.Open_New_Tab__c = false;
        ChangeOrderConfiguration.Tab_Name__c = 'Change Order Configuration';
        ChangeOrderConfiguration.Page_URL__c = '/apex/BT_Change_Order_On_Overage';
        ChangeOrderConfiguration.buildertek__Change_Order_Configuration__c = true;
        firstLevelNodes.add(ChangeOrderConfiguration);

        Admin_Interface_Node_Configuration__c CreatinganewUser = new Admin_Interface_Node_Configuration__c();
        CreatinganewUser.Name = 'Creating a new User';
        CreatinganewUser.Disable__c = false;
        CreatinganewUser.Index__c = 44;
        CreatinganewUser.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        CreatinganewUser.Open_New_Tab__c = false;
        CreatinganewUser.Tab_Name__c = 'Creating a new User';
        CreatinganewUser.Page_URL__c = '/apex/DisplayContents';
        CreatinganewUser.Description__c = 'Configure creating new users';
        firstLevelNodes.add(CreatinganewUser);

        Admin_Interface_Node_Configuration__c CreatingAccountsandContacts = new Admin_Interface_Node_Configuration__c();
        CreatingAccountsandContacts.Name = 'Creating Accounts and Contacts';
        CreatingAccountsandContacts.Disable__c = false;
        CreatingAccountsandContacts.Index__c = 45;
        CreatingAccountsandContacts.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        CreatingAccountsandContacts.Open_New_Tab__c = false;
        CreatingAccountsandContacts.Tab_Name__c = 'Creating Accounts and Contacts';
        CreatingAccountsandContacts.Description__c = 'Configure Accounts and Contacts';
        firstLevelNodes.add(CreatingAccountsandContacts);

        Admin_Interface_Node_Configuration__c CreateAccount = new Admin_Interface_Node_Configuration__c();
        CreateAccount.Name = 'Create Account';
        CreateAccount.Disable__c = false;
        CreateAccount.Index__c = 46;
        CreateAccount.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        CreateAccount.Open_New_Tab__c = false;
        CreateAccount.Tab_Name__c = 'Create Account';
        CreateAccount.Description__c = 'Configure Accounts';
        CreateAccount.Page_URL__c = '/apex/DisplayContents';
        firstLevelNodes.add(CreateAccount);

        Admin_Interface_Node_Configuration__c CreateContact = new Admin_Interface_Node_Configuration__c();
        CreateContact.Name = 'Create Contact';
        CreateContact.Disable__c = false;
        CreateContact.Index__c = 47;
        CreateContact.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        CreateContact.Open_New_Tab__c = false;
        CreateContact.Tab_Name__c = 'Create Contact';
        CreateContact.Description__c = 'Configure Contacts';
        CreateContact.buildertek__Header_Text__c = 'Create Contact';
        CreateContact.Page_URL__c = '/apex/DisplayContents';
        firstLevelNodes.add(CreateContact);

        Admin_Interface_Node_Configuration__c OpportunityConfiguration = new Admin_Interface_Node_Configuration__c();
        OpportunityConfiguration.Name = 'Opportunity Configuration';
        OpportunityConfiguration.Disable__c = false;
        OpportunityConfiguration.Index__c = 48;
        OpportunityConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        OpportunityConfiguration.Open_New_Tab__c = false;
        OpportunityConfiguration.Tab_Name__c = 'Opportunity Configuration';
        OpportunityConfiguration.buildertek__Assign_to_Existing_Project_on_Closed_Won__c = true;
        OpportunityConfiguration.Page_URL__c = '/apex/BT_CreateOpportunityConfiguration';
        firstLevelNodes.add(OpportunityConfiguration);

        Admin_Interface_Node_Configuration__c QuoteConfiguration = new Admin_Interface_Node_Configuration__c();
        QuoteConfiguration.Name = 'Quote Configuration';
        QuoteConfiguration.Disable__c = false;
        QuoteConfiguration.Index__c = 49;
        QuoteConfiguration.Icon_URL__c = '/resource/'+nameSpacePrefix+'SLDS/assets/icons/utility/settings_60.png';
        QuoteConfiguration.Open_New_Tab__c = false;
        QuoteConfiguration.Tab_Name__c = 'Quote Configuration';
        QuoteConfiguration.Page_URL__c = '/apex/CreateProjectfromQuoteAcceptanceonOpp';
        QuoteConfiguration.buildertek__Create_Project_from_Opportunity__c = true;
        QuoteConfiguration.buildertek__Quote_Configuration__c = true;
        QuoteConfiguration.buildertek__Update_the_Opp_Amount__c = true;
        QuoteConfiguration.buildertek__Email_Subject__c = 'Quote Preview';
        firstLevelNodes.add(QuoteConfiguration);

        Admin_Interface_Node_Configuration__c scheduleConfiguration = new Admin_Interface_Node_Configuration__c();
        scheduleConfiguration.Name = 'BT Schedule Configuration';
        scheduleConfiguration.buildertek__Description__c = 'Configure Schedule for your organization.';
        scheduleConfiguration.buildertek__Icon_URL__c = '/resource/'+nameSpacePrefix+'/assets/icons/utility/settings_60.png';
        scheduleConfiguration.buildertek__Tab_Name__c = 'BT Schedule Configuration';
        scheduleConfiguration.Index__c = 50;
        scheduleConfiguration.Open_New_Tab__c = false;
        scheduleConfiguration.Disable__c = false;
        firstLevelNodes.add(scheduleConfiguration);


        Admin_Interface_Node_Configuration__c scheduleChildConfiguration = new Admin_Interface_Node_Configuration__c();
        scheduleChildConfiguration.Name = 'Schedule Configuration';
        scheduleChildConfiguration.buildertek__Icon_URL__c = '/resource/'+nameSpacePrefix+'/assets/icons/utility/settings_60.png';
        scheduleChildConfiguration.buildertek__Tab_Name__c = 'Schedule Configuration';
        scheduleChildConfiguration.buildertek__Page_URL__c = '/apex/ConfigureScheduleFromSetting';
        scheduleChildConfiguration.Index__c = 51;
        scheduleChildConfiguration.Open_New_Tab__c = false;
        scheduleChildConfiguration.Disable__c = false;
        firstLevelNodes.add(scheduleChildConfiguration);


        try {
            DMLManager.insertAsUser(firstLevelNodes);

             //create a map which has the Index__c of the node as the key and the name of the node as the value by iterating through the firstLevelNodes
             Map<Decimal, buildertek__Admin_Interface_Node_Configuration__c> indexMap = new Map<Decimal, buildertek__Admin_Interface_Node_Configuration__c>();
             for (Admin_Interface_Node_Configuration__c node : firstLevelNodes) {
                 indexMap.put(node.Index__c, node);
             }
 
             Map<Decimal, Decimal> indexMap2 = new Map<Decimal, Decimal>();
             indexMap2.put(32,23);
             indexMap2.put(33,22);
             indexMap2.put(34,24);
             indexMap2.put(35,12);
             indexMap2.put(36,10);
             indexMap2.put(37,17);
             indexMap2.put(3,18);
             indexMap2.put(1,18);
             indexMap2.put(2,18);
             indexMap2.put(38,19);
             indexMap2.put(39,25);
             indexMap2.put(40,27);
             indexMap2.put(41,13);
             indexMap2.put(42,28);
             indexMap2.put(43,24);
             indexMap2.put(44,30);
             indexMap2.put(45,30);
             indexMap2.put(46,45);
             indexMap2.put(47,45);
             indexMap2.put(48,31);
             indexMap2.put(49,21);
             indexMap2.put(51,50);
 
             List<Admin_Interface_Node_Configuration__c> newNodeList = new List<Admin_Interface_Node_Configuration__c>();
             for(Decimal key : indexMap2.keySet()) {
                 Admin_Interface_Node_Configuration__c newNode = new Admin_Interface_Node_Configuration__c();
                 newNode = indexMap.get(key);
                 newNode.Parent_Node__c = indexMap.get(indexMap2.get(key)).Id;
                 newNodeList.add(newNode);
             }
 
             if (newNodeList.size()>0) {
                 DMLManager.updateAsUser(newNodeList);
             }
            
        } catch(Exception ex){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
            ApexPages.addMessage(errorMsg);
            System.debug('Error Message => '+ex.getMessage()); 
            System.debug('Error Line no => '+ex.getLineNumber());
            return;
        }
    }
}