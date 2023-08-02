/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  10-May-2018
*/
public with sharing class SubmittalTriggerHandler {
    //Boolean variable to allow skipping execution of trigger in certain scenarios
	public static Boolean blnSkipTrigger = false;
	 
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    
    public SubmittalTriggerHandler (boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
 	public void OnBeforeInsert(Submittal__c[] newSubmittals){
    	
 	}
 	
 	public void OnAfterInsert(Submittal__c[] newSubmittals){
    	
    	Map<Id, Set<Id>> specFileIds = new Map<Id,Set<Id>>();
    	for(Submittal__c Submittal :newSubmittals) {
    		if(Submittal.Spec__c != null){
    			if(specFileIds.containsKey(Submittal.id)) {
    				specFileIds.get(Submittal.id).add(Submittal.Spec__c);
    			} else {
    				specFileIds.put(Submittal.id, new set<Id>{Submittal.Spec__c});
    			}
    		}
    		
    		if(Submittal.Spec_1__c != null){
    			if(specFileIds.containsKey(Submittal.id)) {
    				specFileIds.get(Submittal.id).add(Submittal.Spec_1__c);
    			} else {
    				specFileIds.put(Submittal.id, new set<Id>{Submittal.Spec_1__c});
    			}
    		}
    		
    		if(Submittal.Spec_2__c != null){
    			if(specFileIds.containsKey(Submittal.id)) {
    				specFileIds.get(Submittal.id).add(Submittal.Spec_2__c);
    			} else {
    				specFileIds.put(Submittal.id, new set<Id>{Submittal.Spec_2__c});
    			}
    		}
    		
    		if(Submittal.Spec_3__c != null){
    			if(specFileIds.containsKey(Submittal.id)) {
    				specFileIds.get(Submittal.id).add(Submittal.Spec_3__c);
    			} else {
    				specFileIds.put(Submittal.id, new set<Id>{Submittal.Spec_3__c});
    			}
    		}
    		
    	}
    	
    	if(!specFileIds.isEmpty()){ 
    		
    		Map<Id,String> submittalWithSpecsHTML = new Map<Id, String>();
    		for(Id submittalID:specFileIds.keySet()) {
    			Set<Id> selectedFileIds = specFileIds.get(submittalID);
			    List<String> fields = new List<String>{'Id','Name', 'OwnerId', 'Amazon_File_Key__c', 'File_Presigned_URL__c', 'Bucket_Name__c', 'Access_Type__c', 'Track_Download_History__c'};
	            SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
				List<File__c> selectedFiles = Database.query(String.escapeSingleQuotes('SELECT '+ BT_Utils.buildSelectListFragment(BT_EmailFilesToUsersController.fileEmailFields(), null, fields)+' FROM File__c where Id In: selectedFileIds'));
				
				submittalWithSpecsHTML.put(submittalID, prepareEmailContentForFilesDownloadLink(selectedFiles, System.now().addDays(10)));
    		}
			List<submittal__c> submittalToUpdate = new List<submittal__c>();
			List<string> ListRef = new List<string>();
			for(Id submittalID:submittalWithSpecsHTML.KeySet()){
			   
    				submittal__c submittal = new submittal__c(); 
    				// submittal.ID = submittalID;
    				// submittal.Specs_Details__c = submittalWithSpecsHTML.get(submittalID);
    				// submittalToUpdate.add(submittal);
    				ListRef.add(submittalID);
			    
			}
			 if(Schema.sObjectType.submittal__c.fields.Specs_Details__c.isAccessible() && Schema.sObjectType.submittal__c.fields.Id.isAccessible()){
			submittalToUpdate =[select id,Specs_Details__c from submittal__c where id IN :ListRef];
			 }
			for(submittal__c SB :submittalToUpdate){
			    SB.Specs_Details__c =submittalWithSpecsHTML.get(SB.Id);
			}
			 if(Schema.sObjectType.submittal__c.fields.Specs_Details__c.isUpdateable()){
			update submittalToUpdate;
			 }
			
		}
    	
 	}
     
 	public void OnBeforeUpdate(Submittal__c[] oldSubmittals, Submittal__c[] newSubmittals, Map<Id, Submittal__c> newMap){
     	
     	Map<Id, Set<Id>> specFileIds = new Map<Id,Set<Id>>();
    	for(Submittal__c Submittal :newSubmittals) {
    		if(Submittal.Spec__c != null){
    			if(specFileIds.containsKey(Submittal.id)) {
    				specFileIds.get(Submittal.id).add(Submittal.Spec__c);
    			} else {
    				specFileIds.put(Submittal.id, new set<Id>{Submittal.Spec__c});
    			}
    		}
    		
    		if(Submittal.Spec_1__c != null){
    			if(specFileIds.containsKey(Submittal.id)) {
    				specFileIds.get(Submittal.id).add(Submittal.Spec_1__c);
    			} else {
    				specFileIds.put(Submittal.id, new set<Id>{Submittal.Spec_1__c});
    			}
    		}
    		
    		if(Submittal.Spec_2__c != null){
    			if(specFileIds.containsKey(Submittal.id)) {
    				specFileIds.get(Submittal.id).add(Submittal.Spec_2__c);
    			} else {
    				specFileIds.put(Submittal.id, new set<Id>{Submittal.Spec_2__c});
    			}
    		}
    		
    		if(Submittal.Spec_3__c != null){
    			if(specFileIds.containsKey(Submittal.id)) {
    				specFileIds.get(Submittal.id).add(Submittal.Spec_3__c);
    			} else {
    				specFileIds.put(Submittal.id, new set<Id>{Submittal.Spec_3__c});
    			}
    		}
    		
    	}
    	
    	if(!specFileIds.isEmpty()){ 
    		
    		Map<Id,String> submittalWithSpecsHTML = new Map<Id, String>();
    		for(Id submittalID:specFileIds.keySet()) {
    			Set<Id> selectedFileIds = specFileIds.get(submittalID);
			    List<String> fields = new List<String>{'Id','Name', 'OwnerId', 'Amazon_File_Key__c', 'File_Presigned_URL__c', 'Bucket_Name__c', 'Access_Type__c', 'Track_Download_History__c'};
	            SOQLManager.checkFieldAccess(File__c.sObjectType, fields);
				List<File__c> selectedFiles = Database.query(String.escapeSingleQuotes('SELECT '+ BT_Utils.buildSelectListFragment(BT_EmailFilesToUsersController.fileEmailFields(), null, fields)+' FROM File__c where Id In: selectedFileIds'));
				
				submittalWithSpecsHTML.put(submittalID, prepareEmailContentForFilesDownloadLink(selectedFiles, System.now().addDays(10)));
    		}
			for(submittal__c submittal:newSubmittals){
				if(submittalWithSpecsHTML.containsKey(submittal.id)) {
					submittal.Specs_Details__c = submittalWithSpecsHTML.get(submittal.id);
				}
			}
		}
 	}
 	
 	public static string prepareEmailContentForFilesDownloadLink(List<File__c> files, DateTime expiryDate){
		// Get AWS credentials
    	AmazonS3Credential s3Credentials = new AmazonS3Credential();
    	
		String emailContent = '';
		emailContent +='<table cellpadding="5"><tr style="background-color:#007fcc;color:white;font-weight:bold;">';
		List<Schema.FieldSetMember> emailFileFields = BT_EmailFilesToUsersController.fileEmailFields();
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
		return emailContent;
	}
   
}