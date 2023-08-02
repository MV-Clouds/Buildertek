/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_FileExplorerComponentController
* Created by Sagar: 06/05/2017
*
* - Showing the list of all documents and also allowed to perform various operation on those documents.

* - Modifications:
* - Sagar, 06/05/2017 – Initial Development
************************************************************************** */
public with sharing class BT_FileExplorerComponentController{
    public S3.AmazonS3 amazonS3 { get; private set; }               //This object represents an instance of the Amazon S3 toolkit and makes all the Web Service calls to AWS. 
    public Boolean isNoAmazonCredential{get; set;}
    
    public String folderToExpand{get; set;}                         //Folder id to expand on page load
    public String folderPathToExpand{get; set;}                     //FOlder path to expand on page load
    
    public String selectedFolder{get; set;}                         //Selected folder id
    public String selectedBucket{get; set;}                         //Selected Amazon bucket name
    public String selectedBucketId{get; set;}                       //Id of the selected bucket folder
    
    public string searchString{get; set;}                           //File or Folder search string
    
    public String breadCrumbRecordsString;                          //JSON string returned from click of tree node
    public List<BreadCrumbNode> breadCrumbRecords{get; set;}        //List of BreadCrumb records. THat will be display in page as link so user can easily open the folders
    
    public String getBreadCrumbRecordsString(){
        if(breadCrumbRecords != null){
            return JSON.serialize(breadCrumbRecords);
        } else{
            return '[]';
        }
    }
    
    public Integer activeFolderHistoryIndex{get; set;}
    public List<String> folderHistory{get; set;}
    
    public String mainObjectId{get; set;}                           //Main object id prepared from selected folder or passed as param
    public String mainObjectFieldAPI{get;set;}                      //File and folder field API Name created for main object. Used to query all files and folders.
    
    public String primaryParentObjId{get; set;}                     //Main object id prepared using parentToShow
    public String primaryParentObjFieldAPI{get;set;}                //File and folder field API Name created for main object. Used to query all files and folders.
    
    public String otherObjectFieldAPI{get;set;}                     //File and folder field api name used for other object. Used to display the files created for other object
    public String otherObjectId{get; set;}                          //Id of the other object id. Used to query files only related to other object id
    
    public Boolean selectAll{get; set;}                             //Used for select all check box 
    
    public String sourceRecordsString{get; set;}                    //JSON for source files selected for copy and paste 
    
    public Boolean isTrackDownloadHistory{get; set;}                //True, if file downlaod history has been enabled
    public string fileDownloadURL{get; set;}                        //Download URL of file
    
    public String callerPage{get; set;}                             //Caller of the page
    
    public String queryParameters{get; set;}
    
    public String explorerConfigName{get; set;}
    public FileExplorePageConfguration fileExplorerPageConfugration {get; set;}
    
    //public Boolean isAllowCreateFolder{get; set;}
    
    public Boolean isShowDuplicateNamePopup {get; set;}
    
    public List<FileSystemDetail> fileSystemDetailListForSelectedFolder{get; set;}
    
    public List<SourceRecord> duplicateRecordsWhilePaste{get; set;}
    
    // Flag for Modify all permission of File
	public Boolean isHasModifyAllermissionForFile{get; set;}
	// Flag for Modify all permission of Folder
	public Boolean isHasModifyAllermissionForFolder;
	
	// Flag for Delete permission of folder
	public Boolean blnHasFolderDeletePermission{get; set;}
	// Flag for Edit permission of folder
	public Boolean blnHasFolderEditPermission{get; set;}
	
	// Show message for max items
	public Boolean isShowMaxRecordsMsg{get; set;}
	// Message for max items
	public String maxRecordsMsg{get; set;}
	// Max search items for selected folder
	public Integer maxItems = 1000; 
	// Max sub items for folder
	public Integer maxSubItems{get; set;} 
	
	// Filter folders only
	public Boolean isShowFolders{get; set;}
	// Filter file only
	public Boolean isShowFiles{get; set;}
	// Filter my files only
	public Boolean isShowMyRecords{get; set;}
	
	// Show files related to object records
	public Boolean isShowRelatedFiles;
	// Flag to if this is main file system
	public Boolean isMainFileSystem;
	
	// Sorting variable
	public String sortByAPI{get; set;}
	public String sortByLabel{get; set;}
	public List<SelectOption> sortByOptions{get; set;}
	
    /*
    *   Purpose:    Get all sortable fields
    *   Parameters: 
    *   UnitTests:  
    */
    public List<SelectOption> getSortableFields(){
        List<SelectOption> sortableFields = new List<SelectOption>();
        List<Schema.FieldSetMember> fields = BT_Utils.getFieldSetMembers('File_Fields_For_Sorting',BT_Constants.OBJECT_TYPE_FILE);
        if(!fields.isEmpty()){
            for(Schema.FieldSetMember field: sortableFields()){
    	        sortableFields.add(new SelectOption(field.getFieldPath(), field.getLabel()));
            }
        } else{
            sortableFields.add(new SelectOption('Name', 'Name'));
            sortableFields.add(new SelectOption('CreatedDate', 'CreatedDate'));
            sortableFields.add(new SelectOption('CreatedBy.Name', 'CreatedBy'));
            sortableFields.add(new SelectOption('Size__c', 'Size'));
            sortableFields.add(new SelectOption('Extension__c', 'Extension'));
        }
        
        return sortableFields;
    }
    
    /*
       Purpose: Retrieve the fieldset member list of file sortable fields 
       Parameters:
       Returns: List of FieldSetMember
       Throws [Exceptions]: 
    */
    public static List<Schema.FieldSetMember> sortableFields() {
        List<Schema.FieldSetMember> fields = BT_Utils.getFieldSetMembers('File_Fields_For_Sorting',BT_Constants.OBJECT_TYPE_FILE);
        return fields;
    }
    
    /*
       Purpose: Get the label of sortable field
       Parameters:
       Throws [Exceptions]: 
    */
    public String getSortableFieldLabel(String sortableFieldAPIName) {
        for(SelectOption sortableFieldOption : sortByOptions){
            if(sortableFieldOption.getValue() == sortableFieldAPIName){
                return sortableFieldOption.getLabel();
            }
        }
        return 'CreatedDate';
    }
    
    /*
    *   Executed:   Everytime breadcrum needs to be updated
    *   Purpose:    Here we will prepare the list of warpper class which will be used to display breadcrum on the page
    *   Parameters: 
    *   UnitTests:  
    */
    public List<BreadCrumbNode> getBreadCrumbRecords(){
        List<BreadCrumbNode> breadCrumbRecords = new List<BreadCrumbNode>();
        if(fileExplorerPageConfugration.homeFolders == null || fileExplorerPageConfugration.homeFolders == ''){
            breadCrumbRecords.add(new BreadCrumbNode('Home',System.Label.Home,'LandingPage',''));
        }
        List<BreadCrumbNode> breadCrumbRecordsForFolder = new List<BreadCrumbNode>();
        if(selectedFolder != '' && selectedFolder != 'Home' && selectedFolder != 'File Explorer - Home'){
            breadCrumbRecordsForFolder = getBreadCrumbRecords(selectedFolder, fileExplorerPageConfugration.homeFolders);
        }
        if(!breadCrumbRecordsForFolder.isEmpty()){
            breadCrumbRecords.addAll(breadCrumbRecordsForFolder);
        }
        return breadCrumbRecords;
    }
    
    public S3.AmazonS3 as3 { get; private set; } //This object represents an instance of the Amazon S3 toolkit and makes all the Web Service calls to AWS. 
    
    /*
    *   Executed:   On click of any link inside the breadcrumb
    *   Purpose:    When user will click on any link inside bewad crum, new list of files and folders will be prepared for selected folder and displayed on the page
    *   Parameters: 
    *   UnitTests:  
    */
    public void openBreadCrumbSelectedRecord(){
        getFilesAndFolders();
    }
    
    /**************************************************************************
       Purpose: Get the breadcrumb for folder.
       Parameters: folderId - folder id
       Returns: 
       Throws [Exceptions]: 
    ****************************************************************************/
	public static List<BreadCrumbNode> getBreadCrumbRecords(String folderId, String homeFolders){
		List<BreadCrumbNode> breadCrumbs = new List<BreadCrumbNode>();
		
		// Get all folder path
		List<String> fields = new List<String>{'Id', 'Bucket_Name__c', 'Amazon_File_Path_With_Bucket__c'};
		SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
		buildertek__Folder__c folder = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From buildertek__Folder__c Where Id =: folderId');
		system.debug('folder ---------> '+folder);
		// Folder path
		String strFolderPath = folder.Amazon_File_Path_With_Bucket__c;
		String strFolderBucket = folder.Bucket_Name__c;
		
		// Get all relative folder paths
		Set<String> relativeFolderPath= new Set<String>();
		List<String> internalPathTokens = strFolderPath.split('/');
    	String interPath = internalPathTokens[0];
    	relativeFolderPath.add(interPath);
    	for(integer i = 1; i < internalPathTokens.size();  i++){
    		interPath += '/'+internalPathTokens[i];
    		relativeFolderPath.add(interPath);
    	}
    	
    	String bucketId = '';
    	
    	// Get all folders with relative path
    	List<Folder__c> foldersForBreadCrumb;
    	
    	    
    	    foldersForBreadCrumb = [Select Id, Name, Parent__c, Bucket_Name__c From Folder__c Where Name =: strFolderBucket OR  Amazon_File_Path_With_Bucket__c IN : relativeFolderPath order by Amazon_File_Path_With_Bucket__c NULLS FIRST];    
    	
    	
    	for(Folder__c folderForBreadCrumb : foldersForBreadCrumb){
    	    if(folderForBreadCrumb.Parent__c == null){
    		    bucketId = folderForBreadCrumb.Id;
    		}
    	}
    	Boolean homeFound = homeFolders == null || homeFolders == '';
    	for(Folder__c folderForBreadCrumb : foldersForBreadCrumb){
    	    if(!homeFound){
    	        homeFound = homeFolders.contains(folderForBreadCrumb.Id);
    	    }
    	    if(homeFound){
    		    breadCrumbs.add(new BreadCrumbNode(folderForBreadCrumb.Id, folderForBreadCrumb.Name, 'Folder', bucketId));
    	    }
    	}
		return breadCrumbs; 
	}
	
    public BT_FileExplorerComponentController(){
    	duplicateRecordsWhilePaste = new List<SourceRecord>();
    }
    
    /*
    *   Executed:   On load of the page
    *   Purpose:    All data will be initialized.
    *   Parameters: 
    *   UnitTests:  
    */
    public void getInitialize(){
        if(explorerConfigName != null && explorerConfigName != ''){
    	    fileExplorerPageConfugration = BT_HomeUtils.getFileExplorerPageConfiguration(explorerConfigName);
        } else{
            fileExplorerPageConfugration = BT_HomeUtils.getFileExplorerPageConfiguration(mainObjectFieldAPI);
        }
    	
    	sortByOptions = getSortableFields();
    	sortByAPI = 'CreatedDate';
    	sortByLabel = 'CreatedDate';
    	
        maxItems = fileExplorerPageConfugration.maxSearchRecords;
        maxSubItems = fileExplorerPageConfugration.maxInnerItemsCount;
        
        isShowRelatedFiles = fileExplorerPageConfugration.isShowRelatedFiles;
        isMainFileSystem = true;
    	try{ 
            AmazonS3Credential s3LinkConfig = new AmazonS3Credential();
            amazonS3 = new S3.AmazonS3(s3LinkConfig.key,s3LinkConfig.secret);
            
            if(primaryParentObjFieldAPI != null && primaryParentObjFieldAPI.trim() != ''){
                isMainFileSystem = false;
                if(BT_Utils.getField(BT_Constants.OBJECT_TYPE_FILE, primaryParentObjFieldAPI) == null ){
            	    throw new BT_ApplicationException(System.Label.Invalid_Primary_Object_Field_API_Name);
            	} else{
            	    mainObjectFieldAPI = primaryParentObjFieldAPI;
            	    mainObjectId = primaryParentObjId;
            	}
            }
        	if(otherObjectFieldAPI != null && otherObjectFieldAPI.trim() != '' && BT_Utils.getField(BT_Constants.OBJECT_TYPE_FILE, otherObjectFieldAPI) == null ){
        	    throw new BT_ApplicationException(System.Label.Invalid_Secondary_Object_Field_API_Name);
        	}
        } 
        catch(AmazonS3Credential.AmazonS3CredentialException AmazonS3CredentialEx){
            isNoAmazonCredential = true;
            return;
        } 
        catch(Exception e){
            isNoAmazonCredential = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
            return;
        } 
        
        Boolean isHasModifyAllDataPermission = BT_Utils.hasModifyAllDataPermission();
        isHasModifyAllermissionForFile =  isHasModifyAllDataPermission || BT_Utils.hasModifyAllPermissionForObjectType(BT_Constants.OBJECT_TYPE_FILE);
        isHasModifyAllermissionForFolder = isHasModifyAllDataPermission || BT_Utils.hasModifyAllPermissionForObjectType(BT_Constants.OBJECT_TYPE_FOLDER);
        
        blnHasFolderDeletePermission = false;
        blnHasFolderEditPermission = false;
        isShowMaxRecordsMsg = false;
        maxRecordsMsg = '';
        
        isShowFiles = true;
        isShowFolders = true;
        isShowMyRecords = false;
        
        fileDownloadURL = '';
        isTrackDownloadHistory = false;
        Map<String, Application_Configuration__c> applicationConfigurationMap = Application_Configuration__c.getAll();
        if(applicationConfigurationMap.get(BT_Constants.ENABLE_FILE_DOWNLOAD_HISTORY) != null && applicationConfigurationMap.get(BT_Constants.ENABLE_FILE_DOWNLOAD_HISTORY).Configured_value__c == 'True'){
            isTrackDownloadHistory = true;
        }
        
        //isAllowCreateFolder = false;
        isShowDuplicateNamePopup = false;
        selectAll = false;
        selectedFolder = '';
        selectedBucket = '';
        selectedBucketId = '';
        fileSystemDetailListForSelectedFolder = new List<FileSystemDetail>();
        duplicateRecordsWhilePaste = new List<SourceRecord>();
    	
    	if(fileExplorerPageConfugration.homeFolders != null && fileExplorerPageConfugration.homeFolders != ''){
    	    selectedFolder = fileExplorerPageConfugration.homeFolders.split(',')[0];
    	}
        breadCrumbRecords = new List<BreadCrumbNode>();
        
        if(folderToExpand != null && folderToExpand != ''){
            selectedFolder = folderToExpand;
            List<BreadCrumbNode> defaultBreadCrumbs = getBreadCrumbRecords(folderToExpand, fileExplorerPageConfugration.homeFolders);
            if(!defaultBreadCrumbs.isEmpty()){
                if(fileExplorerPageConfugration.homeFolders == null || fileExplorerPageConfugration.homeFolders == ''){
                    folderPathToExpand = '/File Explorer - Home';
                } else{
                    folderPathToExpand = '';
                }
                for(BreadCrumbNode breadCrumbRecord : defaultBreadCrumbs){
                    folderPathToExpand +='/'+breadCrumbRecord.Id;
                }
                activeFolderHistoryIndex = 0;
                folderHistory = new List<String>{defaultBreadCrumbs[defaultBreadCrumbs.size()-1].Id};
            }
        }
        
        
        if(folderToExpand == null || folderToExpand == ''){
            activeFolderHistoryIndex = 0;
            folderHistory = new List<String>{selectedFolder};
        }
        
        try{  
            getFilesAndFolders();
        } catch(EXception e){
            System.debug(e.getMessage());
            
        }
        
        //Prepare the quesry parameters for tree based on the url parameters
        Map<String, List<BT_TreeRemotingModel.QueryParameter>> queryParamsByObjType = new Map<String, List<BT_TreeRemotingModel.QueryParameter>>();
        List<BT_TreeRemotingModel.QueryParameter> queryParams = new List<BT_TreeRemotingModel.QueryParameter>();
        if(!isMainFileSystem){
            if(mainObjectFieldAPI != null && mainObjectFieldAPI != ''){
            	queryParams.add(new BT_TreeRemotingModel.QueryParameter(mainObjectFieldAPI,mainObjectId));
            	if(otherObjectFieldAPI != null && otherObjectFieldAPI != ''){
    	        	queryParams.add(new BT_TreeRemotingModel.QueryParameter(otherObjectFieldAPI,otherObjectId));
    	        }
            }
        } else if(!isShowRelatedFiles){
        	queryParams.add(new BT_TreeRemotingModel.QueryParameter('Parent_Object_API_Name__c', ''));
        }
        queryParamsByObjType.put('Folder__c', queryParams);
        queryParamsByObjType.put('File__c', queryParams);
        queryParameters = JSON.serialize(queryParamsByObjType);
    }
    
    /*
    *   Executed:   Everytime folder is explored from tree or breadcrum
    *   Purpose:    Here we are preparing the list of files and folders for explored folder
    *   Parameters: 
    *   UnitTests:  
    */
    public void getFilesAndFolders(){
        blnHasFolderDeletePermission = false;
        blnHasFolderEditPermission = false;
        sortByLabel = getSortableFieldLabel(sortByAPI);
        breadCrumbRecords = getBreadCrumbRecords();
        BreadCrumbNode selectedBreadCrumbNode = breadCrumbRecords.get(breadCrumbRecords.size()-1);
        if(selectedBreadCrumbNode != null && (selectedBreadCrumbNode.objectType == 'LandingPage' || selectedBreadCrumbNode.objectType == 'ParentObject')){
             selectedFolder = '';
             selectedBucketId = '';
        } else{
            selectedFolder = selectedBreadCrumbNode.id;
            
            if(BT_Utils.hasModifyAllPermissionForObjectType(BT_Constants.OBJECT_TYPE_FOLDER)){
				blnHasFolderEditPermission = true;
				blnHasFolderDeletePermission = true;
			}
			if(selectedFolder != ''){
			    List<Schema.SObjectField> parentsForFolder = new List<Schema.SObjectField>();
				List<String> fields = new List<String>{'Id', 'OwnerId', 'Parent__c', 'CreatedById'};
				if(isMainFileSystem && isShowRelatedFiles){
				    mainObjectFieldAPI = null;
				    mainObjectId = null;
				    parentsForFolder = BT_HomeUtils.getAllParentsForFolder();
    				for(Schema.SObjectField objSchemaField: parentsForFolder) {
    					Schema.DescribeFieldResult objFieldDescribe = objSchemaField.getDescribe();
    					fields.add(objFieldDescribe.getName());
    				}
				}
				SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
				buildertek__Folder__c selectedFolder = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ', UserRecordAccess.HasDeleteAccess, UserRecordAccess.HasEditAccess From buildertek__Folder__c Where Id =: selectedFolder LIMIT 1');
				if(BT_Utils.hasModifyAllPermissionForObjectType(BT_Constants.OBJECT_TYPE_FOLDER)){
    				blnHasFolderEditPermission = true;
    				blnHasFolderDeletePermission = true;
    			} else{
    				blnHasFolderDeletePermission = selectedFolder.UserRecordAccess.HasDeleteAccess;
    				blnHasFolderEditPermission = selectedFolder.UserRecordAccess.HasEditAccess;
    			}
    			if(isMainFileSystem && isShowRelatedFiles){
        			for(Schema.SObjectField objSchemaField: parentsForFolder) {
    					Schema.DescribeFieldResult objFieldDescribe = objSchemaField.getDescribe();
    					if(selectedFolder.get(objFieldDescribe.getName()) != null){
    						mainObjectFieldAPI = String.valueOf(objFieldDescribe.getName());
    						mainObjectId = String.valueOf(selectedFolder.get(mainObjectFieldAPI));
    					}
    		        }
    			}
			}

            selectedBucketId = selectedBreadCrumbNode.bucket;
        }
        if(selectedBucketId != null && selectedBucketId != ''){
            Folder__c fol;
            
                fol = [Select Name From Folder__c Where Id =:selectedBucketId LIMIT 1];        
            
            selectedBucket = fol.Name;
        }
        fileSystemDetailListForSelectedFolder = new list<FileSystemDetail>();
        
        // Modified By: Laxman 03/07/2020
        // here getInnerFilesAndFolders(selectedFolder) value getting null so we check the value is null or Not 
        if(getInnerFilesAndFolders(selectedFolder) != null ){
        fileSystemDetailListForSelectedFolder.addAll(getInnerFilesAndFolders(selectedFolder));
        }
    }
    
    /*
    *   Executed:   Everytime list of files and folders updated
    *   Purpose:    To find inner files and folder for expanded folder
    *   Parameters: 
    *   UnitTests:  
    */
    private List<FileSystemDetail> getInnerFilesAndFolders(String folderId){
        isShowMaxRecordsMsg = false;
        String fieldUploadStatus = BT_Constants.FILE_UPLOAD_STATUS_DELETING;
        String accessType = BT_Constants.FILE_ACCESS_PRIVATE;
        String userId = UserInfo.getUserId();
        if(!folderHistory.isEmpty() && folderHistory.get(activeFolderHistoryIndex) != selectedFolder){
            activeFolderHistoryIndex += 1;
            folderHistory.add(selectedFolder);
        }
        selectAll = false;
        List<FileSystemDetail> innerFilesDetail = new List<FileSystemDetail>();
        String whereClauseForRelatedRecords = '';
        if(!isMainFileSystem && mainObjectFieldAPI != null && mainObjectFieldAPI != ''){
            whereClauseForRelatedRecords = ' AND ' + mainObjectFieldAPI+' =:mainObjectId ';
        } else if(!isShowRelatedFiles){
            whereClauseForRelatedRecords = ' AND Parent_Object_API_Name__c = null ';
        }
        if(isShowFolders){
            List<String> fields = new List<String>{'Id', 'Name', 'Description__c', 'Parent__c', 'Amazon_File_Key__c', 'OwnerId', 'CreatedDate'};
    		//SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
    		//modified below query by laxman 03/07/2020
    		//Dynamic query for to get All Folders
            String queryStringForFolders = 'Select '+BT_Utils.buildSelectListFragment(null, null, fields) +', CreatedBy.Name, Owner.Name, UserRecordAccess.HasEditAccess, UserRecordAccess.HasDeleteAccess, (Select Id From Files__r Where Id != null  AND Upload_Status__c  !=: fieldUploadStatus '+ whereClauseForRelatedRecords+' LIMIT '+maxSubItems+'), (Select Id From Children__r Where Id != null ' +whereClauseForRelatedRecords+' LIMIT '+maxSubItems+') From buildertek__Folder__c Where Parent__c =: folderId AND Upload_Status__c  !=: fieldUploadStatus AND '+getWhereCondition();
            if(folderId != null && folderId != ''){
                if(whereClauseForRelatedRecords != null && whereClauseForRelatedRecords != ''){
                    queryStringForFolders += whereClauseForRelatedRecords;
                }
            }
            
            if(folderId == null || folderId == ''){
                queryStringForFolders += ' AND Active__c = true';
            }else if(isShowMyRecords){
                queryStringForFolders += ' AND CreatedById =: userId';
            }
            if(sortByAPI != null && sortByAPI != '' && !sortByAPI.endsWith('__c')){
                queryStringForFolders += ' order by '+sortByAPI;
            }
            queryStringForFolders += ' LIMIT '+maxItems;
            List<buildertek__Folder__c> folders = new List<buildertek__Folder__c>();
            try{  
        			system.debug('queryStringForFolders-------------'+queryStringForFolders);
                folders = Database.query(queryStringForFolders);
            
            } catch(System.QueryException e){
                isNoAmazonCredential = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.label.SOQL_Query_Error));
                return null;
            } 
            for(Folder__c folder : folders){
                String totalSubItems;
            	Integer totalSubItemsCount = folder.Files__r.size() + folder.Children__r.size();
            	if(totalSubItemsCount >= maxSubItems){
            	    totalSubItems = maxSubItems+'+';
            	} else{
            	    totalSubItems = String.valueOf(totalSubItemsCount);
            	}
                FileSystemDetail innerFolder = new FileSystemDetail(folder.Name, folder, 'Folder', 0, totalSubItems, folder.UserRecordAccess, isHasModifyAllermissionForFile, isHasModifyAllermissionForFolder, false);
                innerFilesDetail.add(innerFolder);
                if(innerFilesDetail.size() >= maxItems){
                    isShowMaxRecordsMsg = true;
                    maxRecordsMsg = String.format(System.Label.Max_Records_Message, new List<String>{String.valueOf(maxItems), String.valueOf(maxItems)});
                    return innerFilesDetail;
                }
            }
        }
        
        // Set remaining search records count
        Integer remainingRecords = maxItems - innerFilesDetail.size();
        
        if(isShowFiles){
            List<File__c> files = new List<File__c>();
            string whereClause = '';
            if(otherObjectFieldAPI != null && otherObjectFieldAPI != '' && otherObjectId != null && otherObjectId != ''){
                whereClause = otherObjectFieldAPI +' =:otherObjectId AND';
            }
            
            Set<Id> privateFilesAllowedToDownload = new Set<Id>();
            
            try{
            	List<String> fields = new List<String>{'Id', 'OwnerId', 'File_Downloads__c', 'Allow_to_Copy_Move__c', 'Allow_To_Delete__c', 'Size__c', 'File_Presigned_URL__c', 'Public_On_Amazon__c', 'Allow_to_Download_by_Presigned_URL__c', 'Track_Download_History__c', 'Extension__c', 'Allow_To_Rename__c', 'Name', 'Access_Type__c', 'Description__c', 'CreatedDate', 'Download_Link__c', 'Bucket_Name__c', 'Amazon_File_Key__c'};
    			SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
    			String queryStringForFiles = 'Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ', UserRecordAccess.HasEditAccess, UserRecordAccess.HasDeleteAccess, CreatedBy.Id, CreatedBy.Name ';
    			if(!isHasModifyAllermissionForFile){
    			    queryStringForFiles += ', (Select Id From File_Access_Control__r Where Download__c = true AND File__r.OwnerId !=: userId  AND File__r.Access_Type__c =: accessType  AND Grantee__c =: userId  LIMIT 1)';
    			}
    			queryStringForFiles += ' From File__c Where Folder__c =: folderId AND Upload_Status__c  !=: fieldUploadStatus ';
                if(whereClauseForRelatedRecords != null && whereClauseForRelatedRecords != ''){
                    queryStringForFiles += whereClauseForRelatedRecords;
                }
                if(isShowMyRecords){
                    queryStringForFiles += ' AND CreatedById =: userId ';
                }
                queryStringForFiles += ' AND '+whereClause +' '+getWhereCondition();
                if(sortByAPI != null && sortByAPI != ''){
                    queryStringForFiles += ' order by '+sortByAPI;
                }
                queryStringForFiles += ' LIMIT '+remainingRecords;
                files = Database.query(queryStringForFiles);
            } catch(System.QueryException e){
                isNoAmazonCredential = true;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, System.label.SOQL_Query_Error));
                return null;
            }
            
            for(File__c file : files){
                String name = file.Name;
                if(!fileExplorerPageConfugration.isShowExtension){
                    String extension = name.split('\\.').size() > 0 ? name.split('\\.')[1] : '';
                    name = name.substring(0, name.length() - (extension.length()+1));
                }
                Boolean isAllowToDownload = true;
                if(!isHasModifyAllermissionForFile && file.OwnerId != UserInfo.getUserId() && file.Access_Type__c == BT_Constants.FILE_ACCESS_PRIVATE && file.File_Access_Control__r.isEmpty()){
                    isAllowToDownload = false;
                }
                
                // Clear file access controls for file to remove it from view state
                File__c objFile = file.clone();
            	
            	FileSystemDetail innerFile = new FileSystemDetail(name, file, 'File', file.size__c, '0', file.UserRecordAccess, isHasModifyAllermissionForFile, isHasModifyAllermissionForFolder, isAllowToDownload);
                innerFilesDetail.add(innerFile);
                if(innerFilesDetail.size() >= maxItems){
                    isShowMaxRecordsMsg = true;
                    maxRecordsMsg = String.format(System.Label.Max_Records_Message, new List<String>{String.valueOf(maxItems), String.valueOf(maxItems)});
                    return innerFilesDetail;
                }
            }
        }
        return innerFilesDetail;
    }
    
    /*
    *   Executed:   Everytime list of files and folders updated
    *   Purpose:    To preare the dynamic where clause using search string
    *   Parameters: 
    *   UnitTests:  
    */
    private string getWhereCondition(){
        string whereClause = ' Id != null';
        
        if(searchString != null&& searchString != ''){
            whereClause += ' AND Name like \'%'+searchString+'%\''; 
        }
        system.debug('whereClause---->'+whereClause);
        return whereClause;
    }
    
    /*
    *   Executed:   Everytime user click "Previous"
    *   Purpose:    Get list of files and folders for previous folder
    *   Parameters: 
    *   UnitTests:  
    */
    public void goPrevious(){
        activeFolderHistoryIndex -= 1;
        if(folderHistory.size() > activeFolderHistoryIndex) {
            selectedFolder = folderHistory.get(activeFolderHistoryIndex);
        }
        getFilesAndFolders();
    }
    
    /*
    *   Executed:   Everytime user click "Next"
    *   Purpose:    Get list of files and folders for next folder
    *   Parameters: 
    *   UnitTests:  
    */
    public void goNext(){
        activeFolderHistoryIndex += 1;
        if(folderHistory.size() > activeFolderHistoryIndex) {
            selectedFolder = folderHistory.get(activeFolderHistoryIndex);
        }
        getFilesAndFolders();
    }
    
    /*
    *   Executed:   On click of "Download" for file
    *   Purpose:    This method will prepare the download URL for file.
    *   Parameters: 
    *   UnitTests:  
    */
    public void download(){
        String fileIdToDownload = ApexPages.currentPage().getParameters().get('fileIdToDownload');
        fileDownloadURL = '';
        List<String> fields = new List<String>{'Id', 'OwnerId', 'Bucket_Name__c', 'Amazon_File_Key__c','Track_Download_History__c', 'Access_Type__c', 'File_Presigned_URL__c'};
		SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
		// SOQL Query variable for file
		String fileQuery = 'SELECT ' + BT_Utils.buildSelectListFragment(null, null, fields) +' FROM buildertek__File__c WHERE ID =: fileIdToDownload LIMIT 1';
		
		// Execute query
		buildertek__File__c objFileToDownload;
		List<buildertek__File__c> files = Database.query(fileQuery);
		if(!files.isEmpty()){
			objFileToDownload = files[0];
		}
		if(objFileToDownload != null){
        	if(objFileToDownload.Track_Download_History__c && objFileToDownload.OwnerId != UserInfo.getUserId()){
				File_Download_History__c fileDownloadHistory = new File_Download_History__c(File__c = objFileToDownload.Id, DownloadedBy__c = UserInfo.getUserId(), DownloadedDate__c = System.now());
				
				    
				    insert fileDownloadHistory;    
				
				
			}
			
			// Get AWS credentials
            AmazonS3Credential s3Credentials = new AmazonS3Credential();
            Datetime expiryDate = System.now().addMinutes(1);
            fileDownloadURL = FileUtils.getPresignedURL(objFileToDownload.Bucket_Name__c, objFileToDownload.Amazon_File_Key__c, expiryDate, s3Credentials.key, s3Credentials.secret);
        }
        return;
    }
    
    /*
    *   Executed:   On click of "Delete" for file
    *   Purpose:    This method will delete file from amazon as well from salesforce database.
    *   Parameters: 
    *   UnitTests:  
    */
    public void deleteFile(){
        try{
        	String fileIdToDelete = ApexPages.currentPage().getParameters().get('fileIdToDelete');
        File__c filerec;
        if(Schema.sObjectType.File__c.fields.Id.isAccessible()){
          filerec = [Select Id from File__c Where Id =: fileIdToDelete];
        }
			DMLManager.deleteAsUser(filerec);
			// Update the list with deleted file
            getFilesAndFolders();
			return;
        } catch(System.CalloutException callout){
			ApexPages.addMessages(callout);
			return;  
		} catch(Exception ex){
           ApexPages.addMessages(ex);
           return; 
        }
    }
    
    /*
    *   Executed:   On click of "Delete" for folder
    *   Purpose:    This method will delete folder from amazon as well from salesforce database.
    *   Parameters: 
    *   UnitTests:  
    */
    public void deleteFolder(){
        SavePoint sp = Database.setSavePoint();
        try{
            String folderIdToDelete = ApexPages.currentPage().getParameters().get('folderIdToDelete');
            list<Folder__c> foldersToDelete;
            
                foldersToDelete = [Select Id From Folder__c Where Id =: folderIdToDelete LIMIT 1];    
            
            if(!foldersToDelete.isEmpty()){
                //Subfolders will be delete automaticaaly in trigger
                DMLManager.deleteAsUser(foldersToDelete);
            }
            
            // IF the deleted folder was the current folder then activate previous folder in breadcrumb
            if(folderIdToDelete == selectedFolder){
                breadCrumbRecords.remove(breadCrumbRecords.size()-1);
                selectedFolder = breadCrumbRecords[breadCrumbRecords.size() - 1].Id;
            }
            
            // Update the list with deleted folder
            getFilesAndFolders();
        }  catch(Exception ex){
            Database.rollback(sp);
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
            ApexPages.addMessage(errorMsg);
            return;
        }
    }
    
    /*
    *   Executed:   On click of "Delete" for selected files
    *   Purpose:    This method will delete all selected files and folders from amazon as well from salesforce database.
    *   Parameters: 
    *   UnitTests:  
    */
    public void deleteSelectedFiles(){
		SavePoint sp = Database.setSavePoint();
        try{
    		// Folders to delete
            List<Folder__c> foldersToDelete = new List<Folder__c>();
            // Files to delete
    		List<File__c> filesToDelete = new List<File__c>();
    		
            for(FileSystemDetail fileRecord : fileSystemDetailListForSelectedFolder){
                if(fileRecord.isSelected && fileRecord.isAllowToDelete){
                    if(fileRecord.objectType == 'File'){
                        filesToDelete.add((File__c)fileRecord.obj);
                    } else{
                        foldersToDelete.add((Folder__c)fileRecord.obj);
                    }
                }
            }
    		
    		// Delete files
            if(!filesToDelete.isEmpty()){
                DMLManager.deleteAsUser(filesToDelete);
            }
    		// Delete folders
            if(!foldersToDelete.isEmpty()){
                DMLManager.deleteAsUser(foldersToDelete);
            }
    		
    		// Update the list with deleted folder
            getFilesAndFolders();
        } catch(Exception ex){
            Database.rollback(sp);
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
            ApexPages.addMessage(errorMsg);
            return;
        }
    }
    
    /*
    *   Executed:   On click of "Replace" button
    *   Purpose:    This method will replace all file and folders inside the selected folder
    *   Parameters: 
    *   UnitTests:  
    */
    public void replaceSelectedDuplicates(){
    	// Prepare the new set of source and paste again
        Map<String, SourceRecord>  newSourceRecordsById = new Map<String, SourceRecord>();
        
    	// Set of file ids to replace
    	Set<Id> duplicateFileIds = new Set<Id>();
    	
    	// Set of folder ids to replace
    	Set<Id> duplicateFolderIds = new Set<Id>();
    	
    	for(SourceRecord duplicateRecord : duplicateRecordsWhilePaste){
    		if(duplicateRecord.isReplace){
	    		// Get source from duplicate record
	    		newSourceRecordsById.put(duplicateRecord.id, duplicateRecord);
	    		
	            // If record type if file
	            if(duplicateRecord.recordType == 'File'){
	            	duplicateFileIds.add(duplicateRecord.duplicateId);
	            }
	            
	            if(duplicateRecord.recordType == 'Folder'){
	            	duplicateFolderIds.add(duplicateRecord.duplicateId);
	            }
    		}
        }
        
        // Find the dupliace files
        if(!duplicateFileIds.isEmpty()){
           list<File__c> filelst ;
            
           filelst = [select Id From File__c Where Id IN: duplicateFileIds];
            
        	BT_NoSharingUtils.deleteSobjects(filelst);
        }
        
        // Find the dupliace folders
        if(!duplicateFolderIds.isEmpty()){
            list<Folder__c> fldrlst;
          
             fldrlst =[select Id From Folder__c Where Id IN: duplicateFolderIds];
            
        	BT_NoSharingUtils.deleteSobjects(fldrlst);
        }
        
        // String for source records
	    sourceRecordsString = JSON.serialize(newSourceRecordsById);
	    
        // Paste duplicate files
        if(!newSourceRecordsById.isEmpty()){
	        
	        // Paste Again
	    	pasteRecords();
	    	
	    	// Update the list with deleted folder
	        getFilesAndFolders();
        }
        
        // Clear list for duplicates
        duplicateRecordsWhilePaste = new List<SourceRecord>();
    }
    
    /*
    *   Executed:   On click of "Replace All" button
    *   Purpose:    This method will replace all selected file and folders inside the selected folder
    *   Parameters: 
    *   UnitTests:  
    */
    public void replaceAllDuplicates(){
    	// Prepare the new set of source and paste again
        Map<String, SourceRecord>  newSourceRecordsById = new Map<String, SourceRecord>();
        
    	// Set of file ids to replace
    	Set<Id> duplicateFileIds = new Set<Id>();
    	
    	// Set of folder ids to replace
    	Set<Id> duplicateFolderIds = new Set<Id>();
    	
    	for(SourceRecord duplicateRecord : duplicateRecordsWhilePaste){
    		// Get source from duplicate record
    		newSourceRecordsById.put(duplicateRecord.id, duplicateRecord);
    		
            // If record type if file
            if(duplicateRecord.recordType == 'File'){
            	duplicateFileIds.add(duplicateRecord.duplicateId);
            }
            
            if(duplicateRecord.recordType == 'Folder'){
            	duplicateFolderIds.add(duplicateRecord.duplicateId);
            }
        }
        
        // Find the dupliace files
        if(!duplicateFileIds.isEmpty()){
            list<File__c> filelist ;
            if(Schema.sObjectType.File__c.fields.Id.isAccessible()){
           filelist = [select Id From File__c Where Id IN: duplicateFileIds];
            }
        	BT_NoSharingUtils.deleteSobjects(filelist);
        }
        
        // Find the dupliace folders
        if(!duplicateFolderIds.isEmpty()){
              list<Folder__c> fldrlist;
            if(Schema.sObjectType.Folder__c.fields.Id.isAccessible()){
             fldrlist =[select Id From Folder__c Where Id IN: duplicateFolderIds];
            }
        	BT_NoSharingUtils.deleteSobjects(fldrlist);
        }
        
        // String for source records
        sourceRecordsString = JSON.serialize(newSourceRecordsById);
	    
	    // Paste duplicate files
        if(!newSourceRecordsById.isEmpty()){
	        
	        // Paste Again
	    	pasteRecords();
	    	
	    	// Update the list with deleted folder
	        getFilesAndFolders();
        }
        
        // Clear list for duplicates
        duplicateRecordsWhilePaste = new List<SourceRecord>();
    }
    
    /*
    *   Executed:   On click of "Cancel" on replace popup button
    *   Purpose:    This method will cancel replace of duplicate founds
    *   Parameters: 
    *   UnitTests:  
    */
    public void cancelReplaceForDuplicates(){
        system.debug('HIHILJOu');
    	duplicateRecordsWhilePaste = new List<SourceRecord>();
    }
    
    /*
    *   Executed:   On click of "Paste" button
    *   Purpose:    This method will copy/move, copied file and folders(with subfolder/files) inside the selected folder
    *   Parameters: 
    *   UnitTests:  
    */
    public void pasteRecords(){
        SavePoint sp = Database.setSavePoint();
        try {
        	// New folders which are pasted from source folders by amazon path
        	Map<String, Folder__c> pastedFoldersByPath = new Map<String, Folder__c>();
        	
            // New files which are pasted from source files and folders 
            List<File__c> pastedFiles = new List<File__c>();
            
            // All new folders needs to be create including sub folders 
    		List<Folder__c> pastedFolders = new List<Folder__c>();
    		
            // Source records to paste by id
    		Map<String,SourceRecord> sourceRecords = (Map<String, SourceRecord>)System.JSON.deserialize(sourceRecordsString, Map<String, SourceRecord>.class);
            
            // Name of source files needs to be pasted
            Set<String> sourceFileNames = new Set<String>();
            // Name of source folders needs to be pasted
            Set<String> sourceFolderNames = new Set<String>();
            
    		for(SourceRecord sourceRecord : sourceRecords.values()){
                // If record type if file
                if(sourceRecord.recordType == 'File'){
                    sourceFileNames.add(sourceRecord.name);
                }
                
                if(sourceRecord.recordType == 'Folder'){
                    sourceFolderNames.add(sourceRecord.name);
                }
            }
            
            // Find files with the same name as source file
            Map<String, Id> duplicateRecordIdBySourceRecordName = new Map<String, Id>();
            
            if(!sourceFileNames.isEmpty()){
    	        for(Sobject file : BT_Utils.queryForWithOrWithoutSharing(true, 'Select Id, Name From File__c Where Folder__c = '+BT_Utils.prepareQueryStringForEqualClause(selectedFolder)+' AND Name In '+BT_Utils.prepareQueryStringForInClause(sourceFileNames))){
    	        	duplicateRecordIdBySourceRecordName.put(String.valueOf(file.get('Name')), String.valueOf(file.get('Id')));
    	        }
            }
            // Find folders with the same name as source folders
            if(!sourceFolderNames.isEmpty()){
    	        for(Sobject folder : BT_Utils.queryForWithOrWithoutSharing(true, 'Select Id, Name From Folder__c Where Parent__c = '+BT_Utils.prepareQueryStringForEqualClause(selectedFolder)+' AND Name In '+BT_Utils.prepareQueryStringForInClause(sourceFolderNames))){
    	        	duplicateRecordIdBySourceRecordName.put(String.valueOf(folder.get('Name')), String.valueOf(folder.get('Id')));
    	        }
            }
            
    		// Ids of breadcrumb records
            Set<String> breadCrumbRecordIds = new Set<String>();
            for(BreadCrumbNode breadCrumbRecord : breadCrumbRecords){
                breadCrumbRecordIds.add(breadCrumbRecord.id);
            }
            
            // Ids of source files needs to be pasted
            Set<String> sourceFileIds = new Set<String>();
            // Ids of source folders needs to be pasted
            Set<String> sourceFolderIds = new Set<String>();
            
            // Prepare the list of duplicate records
            duplicateRecordsWhilePaste = new List<SourceRecord>();
            
    		for(SourceRecord sourceRecord : sourceRecords.values()){
                // If record type if file
                if(sourceRecord.recordType == 'File'){
                	if(!duplicateRecordIdBySourceRecordName.keySet().contains(sourceRecord.name)){
                    	sourceFileIds.add(sourceRecord.id);
    	            } else{
    	            	sourceRecord.duplicateId = duplicateRecordIdBySourceRecordName.get(sourceRecord.name);
    	            	sourceRecord.isReplace = false;
    	            	duplicateRecordsWhilePaste.add(sourceRecord);
    	            }
                }
                // If user is trying to moved the folder inside itself then we will not do anything for that. We will skip that folder.
                if(sourceRecord.recordType == 'Folder' && ((sourceRecord.actionType == 'Cut' && !breadCrumbRecordIds.contains(sourceRecord.id)) || (sourceRecord.actionType == 'Copy'))){
                    if(!duplicateRecordIdBySourceRecordName.keySet().contains(sourceRecord.name)){
                    	sourceFolderIds.add(sourceRecord.id);
    	            } else{
    	            	sourceRecord.duplicateId = duplicateRecordIdBySourceRecordName.get(sourceRecord.name);
    	            	sourceRecord.isReplace = false;
    	            	duplicateRecordsWhilePaste.add(sourceRecord);
    	            }
                }
            }
    		
            // Current folder. This will be setted as the parent for all files and folder goint to paste
            List<String> fields = new List<String>{'Id', 'Amazon_File_Key__c'};
			SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
            Folder__c selectedFolder = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From Folder__c where Id =:selectedFolder LIMIT 1');
            
    		// All source files
    		Set<String> allFileFields = File__c.sObjectType.getDescribe().fields.getMap().keySet();
    		fields = new List<String>();
    		fields.addAll(allFileFields);
    		SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
            List<File__c> sourceFiles = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From File__c Where Id in: sourceFileIds');
            
            // Source files to update the status
            List<File__c> sourceFilesWithUpdatedStatus = new List<File__c>();
            
            // Source folder to update the status
            List<Folder__c> sourceFoldersWithUpdatedStatus = new List<Folder__c>();
            
            // Going through all source files and created respective copy of that file in amazon as well in salesforce database
            for(File__c sourceFile : sourceFiles){
                
    			// Creating copy of that file in salesforce data base
    			File__c pastedFile = sourceFile.clone(false,true,false,false);  
    			
    			// Set the source for the file needs to be pasted
    			pastedFile.Source_File__c  = sourceFile.Id;
    			
    			// File is cutted then delete the source file from Amazon and salesorce database
    			if(sourceRecords.keySet().contains(sourceFile.Id)){
    				// Set the uplaod status.
    				if(sourceRecords.get(sourceFile.Id).actionType == 'Cut'){
    					pastedFile.Upload_Status__c  = BT_Constants.FILE_UPLOAD_STATUS_MOVING;
    					sourceFile.Upload_Status__c  = BT_Constants.FILE_UPLOAD_STATUS_DELETING;
    					sourceFilesWithUpdatedStatus.add(sourceFile);
    				} else{
    					pastedFile.Upload_Status__c  = BT_Constants.FILE_UPLOAD_STATUS_COPYING;
    				}
    			}
    			
    			// Set the bucket name and other fields
    			pastedFile.Bucket_Name__c = selectedBucket;
    			pastedFile.Parent_Object_API_Name__c = mainObjectFieldAPI;
    			if(mainObjectFieldAPI != null && mainObjectFieldAPI != ''){
    				pastedFile.put(mainObjectFieldAPI, mainObjectId);
    			}
    			pastedFile.Folder__c = selectedFolder.Id;
    			pastedFiles.add(pastedFile);
            }
            
            // Update the status of source files
            if(!sourceFilesWithUpdatedStatus.isEmpty()){
            	BT_NoSharingUtils.updateSobjects(sourceFilesWithUpdatedStatus);
            }
            
            // Insert new files for copy and move
            if(!pastedFiles.isEmpty()){
            	DMLManager.insertAsUser(pastedFiles);
            }
            
            if(!sourceFolderIds.isEmpty()){
    	        // Find all source folder. After fetching source folders we will find subfolders of that folder. 
    	        Set<String> allFolderFields = Folder__c.sObjectType.getDescribe().fields.getMap().keySet();
	    		fields = new List<String>();
	    		fields.addAll(allFolderFields);
	    		SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
    	        List<Folder__c> sourceFolders = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ', Parent__r.Name, Parent__r.Amazon_File_Key__c, Parent__r.Bucket_Name__c, Parent__r.Amazon_File_Path_With_Bucket__c, (Select '+BT_Utils.getQueryStringForObjectWithAllFields(BT_Constants.OBJECT_TYPE_FILE)+'  From Files__r  Where '+(mainObjectFieldAPI != null && mainObjectFieldAPI != '' ?mainObjectFieldAPI+' =:mainObjectId' : 'Parent_Object_API_Name__c = null')+') From Folder__c Where Id in: sourceFolderIds');
    	        
    	        // Amazon path of folder where all source files and folders belongs
    	        String amazonPathForParentFolderOfAllSourceFilesAndFolders = FolderUtils.getAmazonFilePathWithBucket(sourceFolders[0].Parent__r);
    	        
    	        // Subfolder ids by parent folder id
    			Map<Id, Set<Id>> subFolderIdsByParentFolderId = new Map<Id, Set<Id>>(); 
    			
    			// Upload Status by folder id
    			Map<Id, String> uploadStatusByFolderId = new Map<Id, String>();
    	        
    			// Get the list of subfolders for all source folders
    			List<Folder__c> subFoldersIncludingSourceFolders = FolderUtils.getAllSubFolders(sourceFolders, true);
    			
    			// Went through all subfolders and parpare the map
    			for(Folder__c sourceFolderToPaste : subFoldersIncludingSourceFolders){
    				
    				// Prepare the map for parent to child folders
    				Set<Id> subFolderIds = subFolderIdsByParentFolderId.get(sourceFolderToPaste.Parent__c);
    				if(subFolderIds == null){
    					subFolderIds = new Set<Id>();
    				}
    				subFolderIds.add(sourceFolderToPaste.Id);
    				subFolderIdsByParentFolderId.put(sourceFolderToPaste.Parent__c, subFolderIds);
    			}
    			
    			// Prepare the map for upload status by folder id
    			for(SourceRecord sourceRecord : sourceRecords.values()){
    	            if(sourceRecord.recordType == 'Folder'){
    	                uploadStatusByFolderId.put(sourceRecord.Id, sourceRecord.actionType == 'Cut' ? BT_Constants.FILE_UPLOAD_STATUS_MOVING : BT_Constants.FILE_UPLOAD_STATUS_COPYING);
    	                for(Id subFolderId : FolderUtils.getSubFolders(sourceRecord.id, subFolderIdsByParentFolderId)){
    	                	uploadStatusByFolderId.put(subFolderId, sourceRecord.actionType == 'Cut' ? BT_Constants.FILE_UPLOAD_STATUS_MOVING : BT_Constants.FILE_UPLOAD_STATUS_COPYING);
    	                }
    	            }
    	        }
    	        
    			// Went through all subfolders and create new folder
    			for(Folder__c sourceFolderToPaste : subFoldersIncludingSourceFolders){	
    				// Relative Amazon folder path for new folder for paste
    				String relativeAmazonPathForNewFolder = FolderUtils.getAmazonFilePathWithBucket(sourceFolderToPaste);
    				relativeAmazonPathForNewFolder = relativeAmazonPathForNewFolder.replaceFirst(amazonPathForParentFolderOfAllSourceFilesAndFolders,'');
    				
    				// Pasted new folder. Cloned from source
    				Folder__c pasteFolder = sourceFolderToPaste.clone(false,true,false,false);
    				
    				// Set Source and upload status
    				pasteFolder.Source_Folder__c = sourceFolderToPaste.Id;
    				pasteFolder.Upload_Status__c = uploadStatusByFolderId.get(sourceFolderToPaste.Id);  
    				if(pasteFolder.Upload_Status__c == BT_Constants.FILE_UPLOAD_STATUS_MOVING){
    					sourceFolderToPaste.Upload_Status__c = BT_Constants.FILE_UPLOAD_STATUS_DELETING;
    					sourceFoldersWithUpdatedStatus.add(sourceFolderToPaste);
    				}
    				
    				// Clear the parent
    				pasteFolder.Parent__c = null;
    				
    				// Set Amazon Path using the relative path of source folders 
    				pasteFolder.Amazon_File_Key__c = (selectedFolder.Amazon_File_Key__c != null ? selectedFolder.Amazon_File_Key__c: '') + relativeAmazonPathForNewFolder;
    	            
    	            // Set the parent object and other related info
    	            pasteFolder.Parent_Object_API_Name__c = mainObjectFieldAPI;
    	            pasteFolder.Bucket_Name__c = selectedBucket;
    	            if(mainObjectFieldAPI != null && mainObjectFieldAPI != ''){
    	            	pasteFolder.put(mainObjectFieldAPI, mainObjectId);
    	            }
    	            
    	            // Prepare the map
    	            pastedFoldersByPath.put(pasteFolder.Amazon_File_Key__c, pasteFolder);
    			}
    			
    	    	// Create new pasted folders without parent
    	    	if(pastedFoldersByPath.keySet().size() > 0){
    	    	 
    	    	    	insert pastedFoldersByPath.values();
                        
    	    		fields = new List<String>{'Id', 'Salesforce_Unique_Number__c', 'Amazon_File_Key__c', 'Amazon_File_Path__c', 'Parent__c'};
					SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
					Set<Id> pastedFolderIds = new Set<Id>();
					for(Folder__c newPasteFolder : pastedFoldersByPath.values()){
						pastedFolderIds.add(newPasteFolder.Id);
					}
    	    		for(Folder__c folder : Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From Folder__c Where Id In: pastedFolderIds')){
    	    		   pastedFoldersByPath.put(folder.Amazon_File_Key__c, folder); 
    	    		}
    	    	}
    	    	
    	    	// Update the status of source folders
    	        if(!sourceFoldersWithUpdatedStatus.isEmpty()){
    	        	FolderTriggerHandler.isSkipTrigger = true;
    	        	BT_NoSharingUtils.updateSobjects(sourceFoldersWithUpdatedStatus);
    	        	FolderTriggerHandler.isSkipTrigger = false;
    	        }
    	        
    	        // Parent folder ids
    	        Set<Id> parentFolderIds = new Set<Id>();
    	    	// Set the parent for all folders using path
    	    	for(String pastedFolderPath : pastedFoldersByPath.keySet()){
    	    		String pastedFolderName = pastedFolderPath.split('/')[pastedFolderPath.split('/').size()-1];
    				String parentfolderPath = pastedFolderPath.substring(0, pastedFolderPath.length() - (pastedFolderName.length()+1));
    				String parentFolderId = pastedFoldersByPath.get(parentfolderPath) != null ? pastedFoldersByPath.get(parentfolderPath).Id : selectedFolder.Id;
    	    		pastedFoldersByPath.get(pastedFolderPath).Parent__c = parentFolderId;
    	    	    parentFolderIds.add(parentFolderId);
    	    	}
    	    	
    	    	// Get all parent folders
    	    	Map<Id, Folder__c> parentFoldersById = new Map<Id, Folder__c>();
    	    	if(!parentFolderIds.isEmpty()){
    	    	    list<Folder__c> fldrlst ;
    	    	   
    	    	   fldrlst= [Select Id, Salesforce_Unique_Number__c, Amazon_File_Key__c, Amazon_File_Path__c, Parent__c From Folder__c Where Id In: parentFolderIds];
    	    	   
    	    	   parentFoldersById = new Map<Id, Folder__c>(fldrlst);
    	    	}
    	    	
    			// Set the parent and salesforce path for folders
    			if(!pastedFoldersByPath.keyset().isEmpty()){
    			    for(Folder__c folder : pastedFoldersByPath.values()){
                        folder.Parent__r = parentFoldersById.get(folder.Parent__c);
                        if(folder.Parent__c != null){
                            folder.Amazon_File_Path__c = (folder.Parent__r.Amazon_File_Path__c != null ? folder.Parent__r.Amazon_File_Path__c+'/'+Integer.valueOf(folder.Salesforce_Unique_Number__c) : String.valueOf(Integer.valueOf(folder.Salesforce_Unique_Number__c)));
                        }
                        if(parentFoldersById.containsKey(folder.Id)){
                            parentFoldersById.get(folder.Id).Amazon_File_Path__c = folder.Amazon_File_Path__c;
                        }
                    }
                    
    				update pastedFoldersByPath.values();
                        
    			}
            }
            
            // Clear source records
            sourceRecordsString = '';
        }  catch(Exception ex){
            Database.rollback(sp);
            System.debug('***Error-->'+ex.getMessage());
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, ex.getMessage());
            ApexPages.addMessage(errorMsg);
            return;
        }
    }
    
    /*
    *   Executed:   When user delete any folder
    *   Purpose:    This method will get all files and files into subfolders to delete
    *   Parameters: FolderToDelete = Folder needs to be deleted. allFoldersById = Map of all folders it will be used to find all files into subfolders
    *   UnitTests:  
    */
    public list<File__c> getInnerFilesToDelete(Folder__c folderToDelete, Map<Id, Folder__c> allFoldersById){
        //Files needs to be deleted
        list<File__c> innerFilesToDelete = new list<File__c>();
        for(File__c file : folderToDelete.Files__r){
            //All files inside the folder needs to delete
            innerFilesToDelete.add(file);
        }
        
        //Going for all subfolders and delete all files in those subfoldera
        for(Folder__c subFolderToDelete : folderToDelete.Children__r){
            Folder__c subFolderFromMap = allFoldersById.get(subFolderToDelete.Id);
            innerFilesToDelete.addAll(getInnerFilesToDelete(subFolderFromMap, allFoldersById));
        }
        return innerFilesToDelete;
    }
    
    /*
    *   Executed:   On click of "Search" icon
    *   Purpose:    Search the inner files and folders
    *   Parameters: 
    *   UnitTests:  
    */
    public void searchFiles(){
        //we just needs to call function for get fiels and folder and it will return list of files using the search string
        getFilesAndFolders();
    }
    
    /*
    Class used to store the detail of duplicate files and folders whilepaste.
    */
    public class DuplicateRecord{
        public String id{get;set;}                  //Id of file. Used for selected files.
        public String duplicateId{get;set;}         //Id of duplicate file. Used for selected files.
        public String name{get;set;}                //Name of file. Used for selected files.
        public String recordType{get;set;}          //Record type of selected record. ie. file or folder
        public Boolean isReplace{get;set;}          //Do we need to relace the object
        public DuplicateRecord(String id, String duplicateId, String name, String recordType, Boolean isReplace){
        	this.id = id;
        	this.duplicateId = duplicateId;
        	this.name = name;
        	this.recordType = recordType;
        	this.isReplace = isReplace;
        }
    }
    
    /*
    Class used to store the detail of all fiels and folders selected for copy/cut and paste.
    */
    public class SourceRecord{
        public String id{get;set;}                  //Id of file. Used for selected files.
        public String duplicateId{get;set;}         //Id of duplicate file. Used for selected files.
        public String name{get;set;}                //Name of file. Used for selected files.
        public String folderId{get;set;}            //Id of folder. Used for selected folders
        public String objId{get;set;}               //Main object id whose files are copied or cut
        public String recordType{get;set;}          //Record type of selected record. ie. file or folder
        public String actionType{get;set;}          //Action needs to be taken. ie. Copy or Cut
        public Boolean isReplace{get;set;}          //Do we need to relace the object
    }
    
    /*
    Class used to render bread crumb at the top of the page.
    */
    public class BreadCrumbNode{
        public String id{get;set;}                  //Id of file or folder
        public String title{get;set;}               //Title of file or folder
        public String bucket{get;set;}              //Bucket name for file or folder
        public String objectType{get; set;}         //Type of the record. ie. File, Folder or Bucket
        
        public BreadCrumbNode(String id, string title, String objectType, String bucket){
            this.id = id;
            this.title = title;
            this.objectType = objectType;
            this.bucket = bucket;
        }
    }
    
    /*
    Class used to display detail related to file or folder on the page
    */
    public class FileSystemDetail{
        public Boolean isSelected{get; set;}            //Checkbox for selection
        public string name{get; set;}            		//File/Folder name with or without extension
        public sObject obj{get; set;}                   //File or folder object.
        public String objectType{get; set;}             //Object type. ie. File or Folder
        public String totalSize{get; set;}              //Total size of file or files inside the folder
        public String totalSubItems{get; set;}          //Total file + folders inside the folder
        public String icon{get; set;}                   //File or folder icon image url
        public string downloadUrl{get; set;}            //Amazon file download url
        public Boolean isAllowToDownload{get; set;}
        public Boolean isAllowToEdit{get; set;}
        public Boolean isAllowToDelete{get; set;}
        public Boolean isAllowToCut{get; set;}
        public Boolean isAllowToCopy{get; set;}
        public FileSystemDetail(string name, sObject obj,String objectType, Decimal totalSize,  String totalSubItems, UserRecordAccess userRecordAccessObj, Boolean isHasModifyAllermissionForFile, Boolean isHasModifyAllermissionForFolder, Boolean isAllowToDownload){
            this.isSelected = false;
            this.name = name;
            this.obj = obj;
            this.objectType = objectType;
            this.totalSubItems = totalSubItems;
            this.totalSize = (totalSize/1024).setScale(2)+' KB';
            this.isAllowToDownload = isAllowToDownload;
            this.isAllowToEdit = userRecordAccessObj.HasEditAccess;
            this.isAllowToDelete = userRecordAccessObj.HasDeleteAccess;
            this.isAllowToCut =  objectType == 'File' ? isHasModifyAllermissionForFile || ((obj.get('OwnerId') == UserInfo.getUserId() || Boolean.valueOf(obj.get('Allow_to_Copy_Move__c'))) && userRecordAccessObj.HasDeleteAccess && Schema.sObjectType.File__c.isCreateable()) : isHasModifyAllermissionForFile && isHasModifyAllermissionForFolder;
            this.isAllowToCopy =  objectType == 'File' ? isHasModifyAllermissionForFile || ((obj.get('OwnerId') == UserInfo.getUserId() || Boolean.valueOf(obj.get('Allow_to_Copy_Move__c'))) && Schema.sObjectType.File__c.isCreateable()) : isHasModifyAllermissionForFile && isHasModifyAllermissionForFolder;
            if(objectType == 'File'){
                //For files, download url will be bucket name / file path 
                downloadUrl = obj.Id;
                //Get the image url for icon needs to be display. It will be dependent on the file extension 
                icon = obj.get('Extension__c') != null ? BT_Constants.FILE_ICON_MAP.get((String.valueOf(obj.get('Extension__c')).toLowerCase())) : null;
                if(icon == null || icon == ''){
                    icon = 'file.png';
                }
            } else{
                icon = 'folder.png';
            }
        }
    }
    public class FileExplorePageConfguration{
        public Boolean isShowDescription{get; set;}
        public Boolean isShowCreatedBy{get; set;}
        public Boolean isShowCreatedDate{get; set;}
        public Boolean isShowSize{get; set;}
        public Boolean isShowDownload{get; set;}
        public Boolean isShowFileDownloads{get; set;}
        public Boolean isShowExtensionIcon{get; set;}
        public Boolean isShowExtension{get; set;}
        public Boolean isShowSearch{get; set;}
        public Boolean isShowBreadcrumb{get; set;}
        public Boolean isShowMassActions{get; set;}
        public Boolean isShowHeader{get; set;}
        public Boolean isShowHirarchicalFileUI{get; set;}
        public Boolean isShowRelatedFiles{get; set;}
        public Integer pageSize{get; set;}
        public Integer maxSearchRecords{get; set;}
        public Integer maxInnerItemsCount{get; set;}
        public String fileExtensionIconStaticResourceName{get; set;}
        public String homeFolders{get; set;}
        public FileExplorePageConfguration(){
            isShowDescription = false;
            isShowCreatedBy = false;
            isShowCreatedDate = false;
            isShowSize = false;
            isShowDownload = false;
            isShowFileDownloads = false;
            isShowExtensionIcon = true;
            isShowExtension = false;
            isShowSearch = false;
            isShowBreadcrumb = false;
            isShowMassActions = false;
            isShowHeader = false;
            isShowHirarchicalFileUI = false;
            isShowRelatedFiles = false;
            pageSize = 10;
            maxSearchRecords = 1000;
            maxInnerItemsCount = 100;
            fileExtensionIconStaticResourceName = 'BT_ResourceUtils';
        }
    }
}