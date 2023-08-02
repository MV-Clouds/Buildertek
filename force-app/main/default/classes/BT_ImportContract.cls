/*
Copyright (c) 2017-2018, BuilderTek.
All rights reserved. 

Developed By: Sagar
Date:  02-Jul-2018
*/
public with sharing class BT_ImportContract {
	public List<masterContract> masterContracts {get;set;}
	public Project__c Project {get;set;}
	String projectId;
    public BT_ImportContract(ApexPages.StandardController controller){
    	
    	buildertek__Contract__c record = (buildertek__Contract__c)controller.getRecord();
    	projectId = record.Project__c;
    	system.debug('----------projectId---'+projectId);
    	
    	Project = new Project__c();
    	if(projectId != null) {
    	    if(Schema.sObjectType.project__c.fields.Id.isAccessible()
    	        && Schema.sObjectType.project__c.fields.Name.isAccessible()){
    	        
    	        project = [Select Id, Name from project__c where Id =:projectId];   
    	    }
    		
    	}
    	
    	masterContracts = new List<masterContract>();
    	List<buildertek__Contract__c> mcontractList;
    	if(Schema.sObjectType.buildertek__Contract__c.fields.Id.isAccessible()
    	    && Schema.sObjectType.buildertek__Contract__c.fields.Name.isAccessible()
    	    && Schema.sObjectType.buildertek__Contract__c.fields.Description__c.isAccessible()
    	    && Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Contract_Amount__c.isAccessible()){
    	
    	    mcontractList = [Select Id, Name, Description__c, buildertek__Contract_Amount__c from buildertek__Contract__c where Type__c = 'Master'];    
    	}
    	
    	for(buildertek__Contract__c con : mcontractList){
			masterContract mc = new masterContract();
			mc.contracts = con;
			mc.isSelected = false;
			masterContracts.add(mc);
		}
    }
    
    public BT_ImportContract(ApexPages.StandardSetController contract){
    	system.debug('----------26---');
    	projectId = Apexpages.currentPage().getParameters().get('Id').escapeHtml4();
    	project = new Project__c();
    	
    	if(projectId != null) {
    	    if(Schema.sObjectType.project__c.fields.Id.isAccessible()
    	        && Schema.sObjectType.project__c.fields.Name.isAccessible()){
    		    project = [Select Id, Name from project__c where Id =:projectId];
    	    }
    	}
    	
    	masterContracts = new List<masterContract>();
    	List<buildertek__Contract__c> mcontractList;
    	if(Schema.sObjectType.buildertek__Contract__c.fields.Id.isAccessible()
    	    && Schema.sObjectType.buildertek__Contract__c.fields.Name.isAccessible()
    	    && Schema.sObjectType.buildertek__Contract__c.fields.Description__c.isAccessible()
    	    && Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Contract_Amount__c.isAccessible()){
    	        mcontractList = [Select Id, Name, Description__c, buildertek__Contract_Amount__c  from buildertek__Contract__c where Type__c = 'Master'];   
    	}        
		for(buildertek__Contract__c cont : mcontractList){
			masterContract mc = new masterContract();
			mc.contracts = cont;
			mc.isSelected = false;
			masterContracts.add(mc);
		}
    }
    
    
    public void goback(){
    
    }
    public void save(){
    	List<String> selectedIds = new List<String>();
    	List<buildertek__Contract__c> masterContractList = new List<buildertek__Contract__c>();
    	for(masterContract mc : masterContracts){
    		if(mc.isSelected){
    			selectedIds.add(mc.contracts.Id); 
    			if(Schema.sObjectType.buildertek__Contract__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Project__c.isCreateable()){
        			buildertek__Contract__c cont = new buildertek__Contract__c();
    				cont.Name = mc.contracts.Name;
        			cont.buildertek__Project__c = projectId;
        			masterContractList.add(cont);
    	        }
    		}
    		
    	}
    	if(masterContractList.size() > 0){
    	    insert masterContractList;    
    	}
    	Map<String, String> contractMap = new Map<String, String>();
    	Map<String, String> contractNameMap = new Map<String, String>();
    	for(buildertek__Contract__c con : masterContractList){
    	    contractMap.put(con.Name, con.Id);
    	    contractNameMap.put(con.Id, con.Name);
    	}
    	String groupId;
    	Map<String, String> groupMap = new Map<String, String>();
    	List<buildertek__Quote_Line_Group__c> contractGroup;
    	if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible()
    	    && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()){
    	    
    	    contractGroup = [Select Id, Name from buildertek__Quote_Line_Group__c WHERE Name = 'No Grouping'];    
    	}
    	
    	if(contractGroup.size() > 0){
    	    groupId = contractGroup[0].Id;        
    	}else{
    	    buildertek__Quote_Line_Group__c contGroup = new buildertek__Quote_Line_Group__c(); 
    	    if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable()){
    	        contGroup.Name = 'No Grouping';    
    	    }
    	    insert contGroup;
    	    groupId = contGroup.Id;
    	}
    	List<buildertek__Contract_Item__c> contractItem;
    	if(Schema.sObjectType.buildertek__Contract_Item__c.fields.Id.isAccessible()
    	    && Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isAccessible()
    	    && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract__c.isAccessible()
    	    && Schema.sObjectType.buildertek__Contract__c.fields.Name.isAccessible()
    	    && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isAccessible()
    	    && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Item_Name__c.isAccessible()
    	    && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Cost_Code__c.isAccessible()
    	    && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isAccessible()
    	    && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isAccessible()
    	    && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible()
    	    && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isAccessible()){
    	    
    	    contractItem = [select Id, Name, buildertek__Contract__c, buildertek__Contract__r.Name, buildertek__Product__c, buildertek__Item_Name__c, 
		                                                          buildertek__Cost_Code__c,buildertek__Quantity__c,buildertek__Contract_Item_Group__c,buildertek__Contract_Item_Group__r.Name, 
		                                                          buildertek__Unit_Price__c from buildertek__Contract_Item__c
		                                                          where buildertek__Contract__c IN: selectedIds];    
    	}
    	
		                                                          
		List<buildertek__Contract_Item__c> contractItemToInsert = new List<buildertek__Contract_Item__c>();
		for(buildertek__Contract_Item__c contractItems : contractItem){
		    system.debug('Budget Id ----------> '+contractMap.get(contractItems.buildertek__Contract__r.Name));
		    //system.debug('Group Name ----------> '+contractItems.buildertek__Contract_Line_Group__r.Name);
		    if(Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract__c.isCreateable()
    		   && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isCreateable() && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Item_Name__c.isCreateable()
    		   && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Cost_Code__c.isCreateable() && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isCreateable()
    		   && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isCreateable() && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract_Item_Group__c.isCreateable()){
    		    
    		    buildertek__Contract_Item__c contractLine = new buildertek__Contract_Item__c();
    		    contractLine.Name = contractItems.Name;
    		    contractLine.buildertek__Contract__c = contractMap.get(contractItems.buildertek__Contract__r.Name);
                contractLine.buildertek__Product__c = contractItems.buildertek__Product__c;
                contractLine.buildertek__Item_Name__c = contractItems.buildertek__Item_Name__c;
                contractLine.buildertek__Cost_Code__c = contractItems.buildertek__Cost_Code__c;
                contractLine.buildertek__Quantity__c = contractItems.buildertek__Quantity__c;
    		    contractLine.buildertek__Unit_Price__c = contractItems.buildertek__Unit_Price__c;
    		    if(contractItems.buildertek__Contract_Item_Group__c != null){
    		        contractLine.buildertek__Contract_Item_Group__c = contractItems.buildertek__Contract_Item_Group__c;    
    		    }else{
    		        contractLine.buildertek__Contract_Item_Group__c = groupId;    
    		    }
    		    contractItemToInsert.add(contractLine);
    		}   
		}
		if(contractItemToInsert.size() > 0){
		    insert contractItemToInsert;    
		}
    	
    	/*Map<String,String> additionalFields = new Map<String,String>();
    	additionalFields.put('Project__c',projectId);
    	additionalFields.put('Type__c','Standard');
    	
		BT_Utils.CloneAny('buildertek__Contract__c', selectedIds, 'buildertek__Contract__c', 'buildertek__Contract_Item__c', additionalFields);*/
				
    }
    
    public class masterContract{
    	public buildertek__Contract__c contracts {get;set;}
    	public Boolean isSelected {get;set;}
    }
}