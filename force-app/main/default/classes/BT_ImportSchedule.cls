/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  02-Jul-2018
*/
public with sharing class BT_ImportSchedule {
	public List<masterschedule> masterSchedules {get;set;}
	public Project__c Project {get;set;}
	String projectId;
    String projectManagerId {get;set;}
    public BT_ImportSchedule(ApexPages.StandardController controller){
    	
    	schedule__c record = (schedule__c)controller.getRecord();
    	projectId = record.Project__c;
    	system.debug('----------projectId---'+projectId);
    	
    	Project = new Project__c();
    	if(projectId != null) {
    	    if(Schema.sObjectType.buildertek__project__c.fields.id.isAccessible()
    	        && Schema.sObjectType.buildertek__project__c.fields.Name.isAccessible()){
    	        project = [Select Id, Name,buildertek__Project_Manager__c from buildertek__project__c where Id =:projectId];   
                    projectManagerId = project.buildertek__Project_Manager__c;
    	    }
    		
    	}
    	
    	masterSchedules = new List<masterschedule>();
    	List<buildertek__Schedule__c> scList;
    	if(Schema.sObjectType.buildertek__Schedule__c.fields.id.isAccessible()
    	    && Schema.sObjectType.buildertek__Schedule__c.fields.Name.isAccessible()
    	    && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Description__c.isAccessible()
    	    && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Type__c.isAccessible()){
    	    
    	    scList = [Select Id, Name, buildertek__Description__c from buildertek__schedule__c where buildertek__Type__c = 'Master'];    
    	}
    	
    	for(Schedule__c s: scList){
			masterschedule ms = new masterschedule();
			ms.schedule = s;
			ms.isSelected = false;
			masterSchedules.add(ms);
		}
    }
    
    public BT_ImportSchedule(ApexPages.StandardSetController schedule){
    	system.debug('----------26---');
    	projectId = Apexpages.currentPage().getParameters().get('Id').escapeHtml4();
    	project = new Project__c();
    	
    	if(projectId != null) {
    	    if(Schema.sObjectType.buildertek__project__c.fields.id.isAccessible()
    	        && Schema.sObjectType.buildertek__project__c.fields.Name.isAccessible()){
    		    project = [Select Id, Name,buildertek__Project_Manager__c from buildertek__project__c where Id =:projectId];
                    projectManagerId = project.buildertek__Project_Manager__c;
    	    }
    	}
    	
    	masterSchedules = new List<masterschedule>();
    	List<buildertek__Schedule__c> scList;
    	if(Schema.sObjectType.buildertek__Schedule__c.fields.id.isAccessible()
    	    && Schema.sObjectType.buildertek__Schedule__c.fields.Name.isAccessible()
    	    && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Description__c.isAccessible()
    	    && Schema.sObjectType.buildertek__Schedule__c.fields.buildertek__Type__c.isAccessible()){
    	    
    	    scList = [Select Id, Name, buildertek__Description__c from buildertek__schedule__c where buildertek__Type__c = 'Master'];    
    	}
		for(Schedule__c s: scList){
			masterschedule ms = new masterschedule();
			ms.schedule = s;
			ms.isSelected = false;
			masterSchedules.add(ms);
		}
    }
    
    
    public void goback(){
    
    }
    public void save(){
    	String selectedIds = '';
    	
    	for(masterschedule ms:masterSchedules){
    		if(ms.isSelected){
    			selectedIds += ms.schedule.Id+';';
    		}
    	}
    	
    	Map<String,String> additionalFields = new Map<String,String>();
    	additionalFields.put('Project__c',projectId);
    	additionalFields.put('Type__c','Standard');
        if(projectManagerId != null){
    	additionalFields.put('Project_Managers__c',projectManagerId);
            }
		BT_Utils.CloneAny('buildertek__Schedule__c', selectedIds, 'buildertek__Schedule__c', 'buildertek__Project_Task__c', additionalFields);
				
    }
    
    public class masterschedule{
    	public Schedule__c schedule {get;set;}
    	public Boolean isSelected {get;set;}
    }
}