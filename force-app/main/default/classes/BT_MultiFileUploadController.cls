/* **************************************************************************
* Copyright 2017, BuilderTek.
* All rights reserved
*
* Controller Class: BT_MultiFileUploadController
* Created by Sagar
*
* - Create folder

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
public with sharing class BT_MultiFileUploadController {
    public Boolean isError{get; set;}
    public Folder__c folder{get; set;}
    public String retURL{get;set;}
    public String parentFolderId{get;set;}
    public String strMainObjectFieldAPI{get;set;}
    public String strMainObjectId{get;set;}
    public String strOtherObjectId{get;set;}
    public String strOtherObjectFieldAPI{get;set;}
    public String callerOfChildWindow{get;set;}
    public Boolean isChildWindow {get;set;}                                 // If page is open as child window
    public Boolean isSuccess{ get; set;}
    
    public BT_MultiFileUploadController(ApexPages.StandardController controller) {
        try{
            initialize();
            List<String> allParentObjectFieldAPINames = new List<String>{BT_Utils.getNamespacePrefix()+'Parent__c'};
            List<Schema.SObjectField> parentsForFolder = BT_HomeUtils.getAllParentsForFolder();
            for(Schema.SObjectField objSchemaField: parentsForFolder) {
                Schema.DescribeFieldResult objFieldDescribe = objSchemaField.getDescribe();
                allParentObjectFieldAPINames.add(objFieldDescribe.getName());
            }
            if(!Test.isRunningTest()){
                controller.addFields(allParentObjectFieldAPINames);
            }
            folder = (Folder__c)controller.getRecord();
            if(parentFolderId == null){
                parentFolderId = folder.Parent__c;
            }
            if(folder.Id == null && parentFolderId == null){
                List<Folder__c> defaultBucketFolders;
                if(Schema.sObjectType.Folder__c.fields.Id.isAccessible()){
                    defaultBucketFolders = [Select Id From Folder__c Where Default__c = true AND Active__c = true];    
                }
                
                if(defaultBucketFolders != null && !defaultBucketFolders.isEmpty()){
                    parentFolderId = defaultBucketFolders[0].Id;
                } else{
                    throw new BT_ApplicationException(System.Label.No_Amazon_Key_Error);
                }
            }
            for(Schema.SObjectField objSchemaField: parentsForFolder) {
                Schema.DescribeFieldResult objFieldDescribe = objSchemaField.getDescribe();
                if(folder.get(objFieldDescribe.getName()) != null){
                    strMainObjectFieldAPI = String.valueOf(objFieldDescribe.getName());
                    strMainObjectId = String.valueOf(folder.get(objFieldDescribe.getName()));
                }
            }
            if(strMainObjectFieldAPI == null && parentFolderId != null){
                List<String> fields = new List<String>{'Id', 'Name'};
                fields.addAll(allParentObjectFieldAPINames);
                SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
                Folder__c parentFolder = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From Folder__c Where Id =:parentFolderId LIMIT 1');
                for(Schema.SObjectField objSchemaField: parentsForFolder) {
                    Schema.DescribeFieldResult objFieldDescribe = objSchemaField.getDescribe();
                    if(parentFolder.get(objFieldDescribe.getName()) != null){
                        strMainObjectFieldAPI = String.valueOf(objFieldDescribe.getName());
                        strMainObjectId = String.valueOf(parentFolder.get(objFieldDescribe.getName()));
                    }
                }
            }
        } catch(BT_ApplicationException e){ 
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
            ApexPages.addMessage(errorMsg);
            isError = true;
        } catch( Exception e){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage());
            ApexPages.addMessage(errorMsg);
            isError = true;
        }
    }
    
    public BT_MultiFileUploadController() {
        
    }
    
    private void initialize(){
        isSuccess = false;
        folder = new Folder__c();
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        parentFolderId = BT_Utils.escapeSingleQuotes(ApexPages.currentPage().getParameters().get('parentFolderId'));
        strMainObjectFieldAPI = BT_Utils.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().Get('mofa'));
        strMainObjectId = BT_Utils.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().Get('moi'));
        strOtherObjectFieldAPI = BT_Utils.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().Get('oofa'));
        strOtherObjectId = BT_Utils.escapeSingleQuotes(ApexPages.CurrentPage().getParameters().Get('ooi'));
        callerOfChildWindow = ApexPages.CurrentPage().getParameters().Get('clr');
        isChildWindow = callerOfChildWindow != null;
    }
    
    /**************************************************************************
       Purpose: Create Folder method
       Parameters: 
       Returns: 
       Throws [Exceptions]: 
    ****************************************************************************/
    public PageReference save(){
        try {
            isSuccess = false;
            Folder__c objParentFolder;
            if (parentFolderId != null && parentFolderId.trim() != '') {
                List<String> fields = new List<String>{'Id', 'Name', 'Bucket_Name__c', 'Parent__c', 'CreatedById'};
                //SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
                objParentFolder = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' FROM Folder__c WHERE Id =: parentFolderId LIMIT 1');
            }
            
            if(strMainObjectFieldAPI != null && strMainObjectFieldAPI != ''){
                folder.put(strMainObjectFieldAPI, strMainObjectId);
                folder.Parent_Object_API_Name__c = strMainObjectFieldAPI;
            }
            if (objParentFolder == null) {
                DMLManager.upsertAsUser(folder);
            } else if (objParentFolder != null) {
                folder.Parent__c = objParentFolder.Id;
                // If the parent folder is also child folder then populate the bucket name from parent itself
                // Otherwise parent folder must be bucket than use folder name itself as Bucket name 
                folder.Bucket_Name__c = objParentFolder.Bucket_Name__c != null ? objParentFolder.Bucket_Name__c : objParentFolder.Name;
                DMLManager.upsertAsUser(folder);
            } else {
                DMLManager.upsertAsUser(folder);
            }
            isSuccess = true;
            // Close the window and referesh parent window.
            if(isChildWindow){
                if(callerOfChildWindow == '1'){
                    return new Pagereference('javascript: window.parent.refreshAfterNewFolder();');
                }
            }
            if(BT_Utils.isLightning()){
                return null;
            }
            if(retURL != null && retURL != ''){
                if(retURL.startsWith('/')){
                    retURL = retURL.replaceFirst('/', '');   
                }
                 return new Pagereference('/'+retURL);
            } else{
                return new Pagereference('/home/home.jsp');
            }
        } catch (System.DMLException objEx) {
            ApexPages.addMessages(objEx);
            return null;
        } catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage()));
            return null;
        }
      //  return null;
    }
}