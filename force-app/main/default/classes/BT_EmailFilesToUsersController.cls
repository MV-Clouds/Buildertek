/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: BT_EditFileControllerTest
* Created by Sagar
*
* Send files to user throuhg email

* - Modifications:
* - Sagar – Initial Development
************************************************************************** */
public with sharing class BT_EmailFilesToUsersController {
	public string emailSubject{get; set;}
	public string emailBody{get; set;}
	public integer expireFileUrlDuration{get; set;}
	public List<TreePickerNode> selectedUserNodes {get;set;}
	public List<TreePickerNode> selectedFileNodes {get;set;}
    public List<String> searchableUserObjectTypes{get; set;}
    public List<String> searchableFileObjectTypes{get; set;}
    public string queryParameters{get; set;}
    public string folderId;
    public List<String> selectedFilesIds;
    public string retURL = '';
    public string callerPage{get; set;}
    public Boolean isShowClose{
        get{
    		return callerPage == 'FileExplore';
    	} set{ 
    	    isShowClose = value; 
    	}
    }
    public Boolean isSuccess{ get; set;}
    public BT_EmailFilesToUsersController(){
    	isShowClose = false;
    	isSuccess = false;
    	
    	// Default 2 days
    	expireFileUrlDuration = 2;
    	if(!Test.isRunningTest()){
    	retURL = ApexPages.CurrentPage().getParameters().get('retURL');
    
    	system.debug('retURL -------> '+retURL);
    	callerPage = ApexPages.currentPage().getParameters().get('callerName');
    	
    	folderId = ApexPages.currentPage().getParameters().get('folderId');
    	}
    	if(folderId != null && folderId != ''){
    	    List<String> fields = new List<String>{'Id', 'Bucket_Name__c'};
            SOQLManager.checkFieldAccess(Folder__c.sObjectType, fields);
    	    Folder__c folder = Database.query(String.escapeSingleQuotes('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From Folder__c Where Id =: folderId LIMIT 1'));
    	    //Prepare the query parameters for file tree based on folder id
            Map<String, List<BT_TreeRemotingModel.QueryParameter>> queryParamsByObjType = new Map<String, List<BT_TreeRemotingModel.QueryParameter>>();
            List<BT_TreeRemotingModel.QueryParameter> queryParamsForFile = new List<BT_TreeRemotingModel.QueryParameter>();
            queryParamsForFile.add(new BT_TreeRemotingModel.QueryParameter(BT_Constants.OBJECT_TYPE_FOLDER,folderId));
        	queryParamsByObjType.put('File__c', queryParamsForFile);
        	
        	if(folder != null && folder.Bucket_Name__c != null){
        	    List<BT_TreeRemotingModel.QueryParameter> queryParamsForFolder = new List<BT_TreeRemotingModel.QueryParameter>();
                string namespacePrefix = BT_Utils.getNamespacePrefix();
                queryParamsForFolder.add(new BT_TreeRemotingModel.QueryParameter(namespacePrefix+'Bucket_Name__c',folder.Bucket_Name__c));
                queryParamsByObjType.put('Folder__c', queryParamsForFolder);
        	}
            queryParameters = JSON.serialize(queryParamsByObjType);
        }
        
    	String selectedFileIdsString = ApexPages.CurrentPage().getParameters().Get('selectedFileIds');
    	selectedFilesIds = selectedFileIdsString != null ? selectedFileIdsString.split(',') : null;
		List<File__c> selectedFiles = new List<File__c>();
		if(selectedFilesIds != null && !selectedFilesIds.isEmpty()){
		    List<String> fields = new List<String>{'Id', 'Name', 'Access_Type__c', 'OwnerId', 'Bucket_Name__c', 'Public_On_Amazon__c', 'Track_Download_History__c', 'File_Presigned_URL__c', 'Amazon_File_Key__c'};
            SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
			selectedFiles = Database.query('Select '+BT_Utils.buildSelectListFragment(null, null, fields) + ' From File__c where Id In: selectedFilesIds');
		}
		searchableUserObjectTypes = new List<String>{'User'};
		searchableFileObjectTypes = new List<String>{'File__c'};
        selectedUserNodes = new List<TreePickerNode>();
        selectedFileNodes = new List<TreePickerNode>();
        if(!selectedFiles.isEmpty()){
        	for(File__c file : selectedFiles){
        		selectedFileNodes.add(new TreePickerNode(file.Id, file.name));
        	}
        }
        emailBody = '';
        emailSubject = '';
    }
    public String getUserTreeType() {        
        return BT_Constants.TREE_TYPE_USER;
    }
    
    public String getUserPickerConfigName() {        
        return 'User Picker Tree';
    }
    
    public List<String> getUserPickerCheckableObjectTypes() {
        List<String> checkableNodes = new List<String>();
        checkableNodes.add('User');
        return checkableNodes;
    }
	
	public String getFileTreeType() {        
        return BT_Constants.TREE_TYPE_FILE;
    }
    
    public String getFilePickerConfigName() {        
        return 'File Picker Tree';
    }
    
    public List<String> getFilePickerCheckableObjectTypes() {
        List<String> checkableNodes = new List<String>();
        checkableNodes.add('File__c');
        return checkableNodes;
    }
	
	public Pagereference sendEmail(){
	    isSuccess = false;
	    expireFileUrlDuration = (expireFileUrlDuration != null ? expireFileUrlDuration : 2);
	    if(expireFileUrlDuration < 0){
	        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'URL Expiration Duration (days) cannot be less than 0 days.');
            ApexPages.addMessage(errorMsg);
			return null;
	    } else if(expireFileUrlDuration > 30){
	        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, 'URL Expiration Duration (days) cannot be greater than 30 days.');
            ApexPages.addMessage(errorMsg);
			return null;
	    }
	    // Expire Date
	    DateTime expiryDate = System.now().addDays(expireFileUrlDuration);
		if(selectedUserNodes.isEmpty()){
			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.No_Recipient_Selected_Warning);
            ApexPages.addMessage(errorMsg);
			return null;
		}
		if(selectedFileNodes.isEmpty()){
			ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, System.Label.No_File_Selected_Warning);
            ApexPages.addMessage(errorMsg);
			return null;
		}
		List<User> selectedUsers = new List<User>();
		Set<Id> selectedUserIds = new Set<Id>();
		for(TreePickerNode selectedUserNode : selectedUserNodes){
			selectedUserIds.add(selectedUserNode.Id);
		}
		
		    selectedUsers = [Select Name, Email From User Where Id In: selectedUserIds];    
		
		
		Set<Id> selectedFileIds = new Set<Id>();
		for(TreePickerNode selectedFileNode : selectedFileNodes){
			selectedFileIds.add(selectedFileNode.Id);
		}
		List<File__c> selectedFiles = new List<File__c>();
		if(!selectedFileIds.isEmpty()){
		    List<String> fields = new List<String>{'Id','Name', 'OwnerId', 'Amazon_File_Key__c', 'File_Presigned_URL__c', 'Bucket_Name__c', 'Access_Type__c', 'Track_Download_History__c'};
            SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
			selectedFiles = Database.query('SELECT '+ BT_Utils.buildSelectListFragment(fileEmailFields(), null, fields)+' FROM File__c where Id In: selectedFileIds');
		}
		
		List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
		for(User user : selectedUsers){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.saveAsActivity = false;
			mail.setTargetObjectId(user.Id);
			mail.setReplyTo(UserInfo.getUserEmail());
			mail.setSenderDisplayName(UserInfo.getName());
			mail.setSubject(emailSubject);
			mail.setHTMLBody(prepareEmailContentForFilesDownloadLink(user, emailBody, selectedFiles, expiryDate));
			mails.add(mail);
		}
		Messaging.SendEmailResult[] sendResult = Messaging.sendEmail(mails);
		
		// Create file download history
		List<File_Download_History__c> fileDownloadHistories = new List<File_Download_History__c>();
		for(User user : selectedUsers){
		    for(File__c file : selectedFiles){
		        if(file.OwnerId != user.Id && file.Track_Download_History__c){
		            fileDownloadHistories.add(new File_Download_History__c(File__c = file.Id, DownloadedBy__c = user.Id, DownloadedDate__c = System.now(), Type__c = 'Email'));
		        }
		    }
		}
		if(!fileDownloadHistories.isEmpty()){
		    
		        
		        insert fileDownloadHistories;    
		    
		    
		}
		
		isSuccess = true;
		
		if(BT_Utils.isLightning()){
            return null;
        }
        
		if(isShowClose){
			return new Pagereference('javascript:window.close();');
		} else if(retURL != null && retURL.trim() != ''){
			if(retURL.startsWith('/')){
		        retURL = retURL.replaceFirst('/', '');    
		    }
		    system.debug('retURL -------> '+retURL);
			return new Pagereference('/'+retURL);
		} else if(folderId != null && folderId != ''){
		    return new Pagereference('/'+folderId);
		} else{
			return new Pagereference('/'+File__c.sObjectType.getDescribe().getKeyPrefix());
		}
	}
	
	/**************************************************************************
       Purpose: Retrieve the fieldset member list of file fieldset 
       Parameters:
       Returns: List of FieldSetMember
       Throws [Exceptions]: 
    ****************************************************************************/
	public static List<Schema.FieldSetMember> fileEmailFields() {
        List<Schema.FieldSetMember> inputFields = BT_Utils.getFieldSetMembers(BT_Utils.getNamespacePrefix()+'File_Fields_For_Email',BT_Constants.OBJECT_TYPE_FILE);
        List<Schema.FieldSetMember> fields = new List<Schema.FieldSetMember>();
        for(Schema.FieldSetMember inputField : inputFields){
        	fields.add(inputField);
        }
        return fields;
    }
    
	public Pagereference cancel(){
	    if(BT_Utils.isLightning()){
            return null;
        }
		if(isShowClose){
			return new Pagereference('javascript:window.close();');
		} else if(retURL != null && retURL.trim() != ''){
		    if(retURL.startsWith('/')){
		        retURL = retURL.replaceFirst('/', '');    
		    }
		    system.debug('retURL -------> '+retURL);
			return new Pagereference('/'+retURL);
		} else if(folderId != null && folderId != ''){
		    return new Pagereference('/'+folderId);
		} else{
			return new Pagereference('/'+File__c.sObjectType.getDescribe().getKeyPrefix());
		}
	}
	
	public static string prepareEmailContentForFilesDownloadLink(User user, String emailBody, List<File__c> files, DateTime expiryDate){
		// Get AWS credentials
    	AmazonS3Credential s3Credentials = new AmazonS3Credential();
    	
		String emailContent = 'Hi '+user.Name+',';
		emailContent +='<br/><br/>'+emailBody;
		emailContent +='<br/><br/>'+System.Label.Email_Note+'<br/><br/>';
		emailContent +='<table cellpadding="5"><tr style="background-color:#007fcc;color:white;font-weight:bold;">';
		List<Schema.FieldSetMember> emailFileFields = fileEmailFields();
		for(Schema.FieldSetMember field : emailFileFields){
			emailContent +='<th>'+field.getLabel()+'</th>';
		}
		emailContent +='<th>'+System.Label.Expiry_Date+'</th>';
		emailContent +='<th>'+System.Label.Action+'</th><tr>';
		for(File__c file : files){
			emailContent +='<tr>';
			String fileDownloadLinkHTML = '';
			String expiryDateString = '';
			//Check for file access type and encript the link if the file is private
			fileDownloadLinkHTML ='<a href="'+ FileUtils.getPresignedURL(file.Bucket_Name__c, file.Amazon_File_Key__c, expiryDate, s3Credentials.key, s3Credentials.secret)+'">'+System.Label.Download+'</a>';
		    expiryDateString =  expiryDate.format();
			for(Schema.FieldSetMember field : emailFileFields){
				String fieldValue = file.get(field.getFieldPath()) != null ? String.valueOf(file.get(field.getFieldPath())) : '';
				if(field.getFieldPath() == 'Name'){
					emailContent +='<td style="font-weight: bold;">'+ fieldValue+'</td>';
				} else if(field.getType() == Schema.DisplayType.Boolean){
					emailContent +='<td>'+(fieldValue == 'true'? Label.Yes : Label.No)+'</td>';
				} else{
				    emailContent +='<td>'+fieldValue+'</td>';
				}
			}
			emailContent +='<td>'+expiryDateString+'</td>';
			emailContent +='<td>'+fileDownloadLinkHTML+'</td>';
			emailContent +='</tr>';
		}
		emailContent +='</table>';
		emailContent +='<br/><br/>'+System.Label.Thank_You+'<br/><br/>'+UserInfo.getName();
		return emailContent;
	}
}