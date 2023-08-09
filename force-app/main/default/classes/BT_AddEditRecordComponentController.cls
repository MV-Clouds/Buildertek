/*
 Copyright (c) 2017-2018, BuilderTek.
 All rights reserved.

 Developed By: Sagar
 Date:  06-Mar-2018
 */
public with sharing class BT_AddEditRecordComponentController{
	public string objectAPI{ get; set; }

	public string fieldSet{ get; set; }

	public sObject recordObject{ get; set; }

	public Id existingRecordId{ get; set; }

	public string recordTypeName{ get; set; }

	public List<Schema.FieldSetMember> fields{ get; set; }

	public boolean saveSuccess{ get; set; }

	public sObject defaultRecord{ get; set; }

	public string saveRecordJSON{ get; set; }

	public void getinitialize(){
		//Get the sobject instance
		recordObject = Schema.getGlobalDescribe().get(BT_Utils.getNamespacePrefix()+objectAPI).newSObject();
		Date todayDate = Date.today();
		//Get the field set fields
		fields = BT_Utils.getFieldSetMembers(fieldSet, BT_Utils.getNamespacePrefix()+objectAPI);

		//If the record id is exist then retrive the record details
		recordObject = null;
		if (existingRecordId != null){
			String query = 'Select Id, Name ';
			for (Schema.FieldSetMember objField : fields){
				if (objField.FieldPath != 'Name'){
					query = query + ', ' + objField.FieldPath;
				}
			}
			query = query + ' From ' + objectAPI + ' Where Id =:existingRecordId';
			recordObject = DataBase.query(String.escapeSingleQuotes(query));
		} else{
			if (recordTypeName != null && objectAPI != null){
				String objectNameWithNameSpace = BT_Constants.OBJECT_NAMESPACE_MAP.get(objectAPI);
			}
			if (defaultRecord != null){
				defaultRecord.put('Name','New Task');
				defaultRecord.put('buildertek__Duration__c',1);
				defaultRecord.put('buildertek__Start__c',todayDate);
                defaultRecord.put('buildertek__Finish__c', todayDate);
				recordObject = defaultRecord;
			}
		}
	}

	//Update the record.
	public void saveRecord(){
		saveSuccess = true;
		saveRecordJSON = JSON.serialize(recordObject);
	}

	public void getEndData(){
       system.debug(recordObject);
        system.debug(recordObject.get('buildertek__Start__c'));
        Date startDate = Date.valueOf(recordObject.get('buildertek__Start__c'));
        Date endDate;
        String todayDay;
        DateTime currDate;
        if(Integer.valueOf(recordObject.get('buildertek__Duration__c')) > 0){
            endDate = startDate.addDays(Integer.valueOf(recordObject.get('buildertek__Duration__c')) -1);
            currDate = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());  
            todayDay = currDate.format('EEEE');
            if(todayDay == 'Saturday'){
                startDate = startDate.addDays(2);    
            }else if(todayDay == 'Sunday'){
                startDate = startDate.addDays(1);    
            }
            endDate = startDate.addDays(Integer.valueOf(recordObject.get('buildertek__Duration__c')) -1);
            for (integer j = 0; j <= startDate.daysBetween(endDate); j++){
                Date dt = startDate + j;
                DateTime currentDate = DateTime.newInstance(dt.year(), dt.month(), dt.day());
                todayDay = currentDate.format('EEEE');
                if (todayDay == 'Saturday' || todayDay == 'Sunday'){
                    endDate = endDate.addDays(1);
                }
            }
            recordObject.put('buildertek__Finish__c',endDate);
        }else{
            endDate = startDate;
            currDate = DateTime.newInstance(endDate.year(), endDate.month(), endDate.day());  
            todayDay = currDate.format('EEEE');
            if(todayDay == 'Saturday'){
                endDate = endDate.addDays(2);    
            }else if(todayDay == 'Sunday'){
                endDate = endDate.addDays(1);    
            }
            recordObject.put('buildertek__Finish__c', endDate);
        }
	}
}