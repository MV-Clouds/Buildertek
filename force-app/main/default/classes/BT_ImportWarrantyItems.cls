/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date:  02-Jul-2018
 */
public with sharing class BT_ImportWarrantyItems{
	public List<masterWarranty> masterWarranties{ get; set; }

	public Project__c Project{ get; set; }

	String projectId;
	String warrantyId;
	@AuraEnabled
	public static WarrantyWrapper retrieveRecords(String recordId, Integer pageSize, Integer pageNumber){
		try{
			WarrantyWrapper warrantyWrapperClass = new WarrantyWrapper();
			Integer offset = (pageNumber - 1) * pageSize;
			List<buildertek__Warranty__c> warrantyList;
			if (Schema.sObjectType.buildertek__Warranty__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Warranty__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Warranty__c.fields.buildertek__Description__c.isAccessible() && Schema.sObjectType.buildertek__Warranty__c.fields.buildertek__Project__c.isAccessible() && Schema.sObjectType.buildertek__Warranty__c.fields.buildertek__Length_of_Warranty__c.isAccessible()){

				warrantyWrapperClass.records = [Select Id, Name, buildertek__Description__c, buildertek__Project__r.Name, buildertek__Length_of_Warranty__c
				                                FROM buildertek__Warranty__c
				                                WHERE buildertek__Type__c = 'Master'
				                                LIMIT :pageSize
				                                OFFSET :offset];
				warrantyWrapperClass.recordCount = [Select COUNT()
				                                    FROM buildertek__Warranty__c
				                                    WHERE buildertek__Type__c = 'Master'];
				return warrantyWrapperClass;
			}
		} catch (Exception e){
			System.debug('Error Message::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
		}
		return null;
	}

	@AuraEnabled
	public static String importMasterRecords(String projectId, String listOfIds){
		try{
			Map<String, String> additionalFields = new Map<String, String>();
			additionalFields.put('Project__c', projectId);
			additionalFields.put('Type__c', 'Standard');
			BT_Utils.CloneAny('buildertek__Warranty__c', listOfIds, 'buildertek__Warranty__c', 'buildertek__Warranty_Item__c', additionalFields);
			return 'Success';
		} catch (Exception e){
			System.debug('Error Message::' + e.getMessage());
			System.debug('Error Line::' + e.getLineNumber());
		}
		return null;
	}

	public BT_ImportWarrantyItems(ApexPages.StandardController controller){

		buildertek__Warranty__c record = (buildertek__Warranty__c)controller.getRecord();
		projectId = record.Project__c;
		system.debug('----------projectId---' + projectId);

		Project = new Project__c();
		if (projectId != null){
			if (Schema.sObjectType.buildertek__Project__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()){
				project = [Select Id, Name
				           from project__c
				           where Id = :projectId];
			}
		}

		masterWarranties = new List<masterWarranty>();
		List<buildertek__Warranty__c> warList;
		if (Schema.sObjectType.buildertek__Warranty__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Warranty__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Warranty__c.fields.buildertek__Description__c.isAccessible()){
			warList = [Select Id, Name, buildertek__Description__c
			           from buildertek__Warranty__c
			           where buildertek__Type__c = 'Master'];
		}

		for (buildertek__Warranty__c wItem : warList){
			masterWarranty MW = new masterWarranty();
			MW.warranty = wItem;
			MW.isSelected = false;
			masterWarranties.add(MW);
		}
	}

	public BT_ImportWarrantyItems(ApexPages.StandardSetController warrantyItem){
		system.debug('----------26---');
		projectId = Apexpages.currentPage().getParameters().get('Id').escapeHtml4();
		system.debug('projectId ----------> ' + projectId);
		//buildertek__Warranty__c warranty = [SELECT Id, buildertek__Project__c FROM buildertek__Warranty__c WHERE Id =: warrantyId];
		project = new Project__c();

		if (projectId != null){
			if (Schema.sObjectType.buildertek__Project__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Project__c.fields.Name.isAccessible()){
				project = [Select Id, Name
				           from project__c
				           where Id = :projectId];
			}
		}

		masterWarranties = new List<masterWarranty>();
		List<buildertek__Warranty__c> warList;
		if (Schema.sObjectType.buildertek__Warranty__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Warranty__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Warranty__c.fields.buildertek__Description__c.isAccessible()){
			warList = [Select Id, Name, buildertek__Description__c
			           from buildertek__Warranty__c
			           where buildertek__Type__c = 'Master'];
		}
		for (buildertek__Warranty__c wItem : warList){
			masterWarranty MW = new masterWarranty();
			MW.warranty = wItem;
			MW.isSelected = false;
			masterWarranties.add(MW);
		}
	}

	public void goback(){
	}

	public void save(){
		String selectedIds = '';

		for (masterWarranty mw : masterWarranties){
			if (mw.isSelected){
				selectedIds += mw.warranty.Id + ';';
			}
		}

		Map<String, String> additionalFields = new Map<String, String>();
		additionalFields.put('Project__c', projectId);
		additionalFields.put('Type__c', 'Standard');

		BT_Utils.CloneAny('buildertek__Warranty__c', selectedIds, 'buildertek__Warranty__c', 'buildertek__Warranty_Item__c', additionalFields);
	}

	public class masterWarranty{
		public buildertek__Warranty__c warranty{ get; set; }

		public Boolean isSelected{ get; set; }
	}

	public class WarrantyWrapper{
		@AuraEnabled
		public List<buildertek__Warranty__c> records;
		@AuraEnabled
		public Integer recordCount;

	}
}