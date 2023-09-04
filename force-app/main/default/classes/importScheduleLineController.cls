public without sharing class importScheduleLineController {
    @AuraEnabled
    public static string insertData(String recordId, String strFileData){
        String returnresponse = '';
        System.debug('strFileData: ' + strFileData);
        Map<String, buildertek__Project_Task__c> projectInsertTaskMap = new Map<String, buildertek__Project_Task__c>();
        List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(strFileData, List<fieldWrapper>.class);
        Map<String, String> myMap = new Map<String, String>();
        Map<String, Decimal> durationMap = new Map<String, Decimal>();

        buildertek__Schedule__c mainScheduleRec;
        if(String.isNotBlank(recordId)){
            mainScheduleRec = [SELECT Id, Name, buildertek__Initial_Start_Date__c, buildertek__Start_Date__c, buildertek__End_Date__c, buildertek__Original_Start_Date__c, buildertek__Original_End_Date__c FROM buildertek__Schedule__c WHERE Id =:recordId limit 1];
        }

        list<buildertek__Project_Task__c> existedScheduleitems = new list<buildertek__Project_Task__c>();
        existedScheduleitems = [select Id, buildertek__Completion__c, buildertek__Full_Name__c,buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Duration__c, buildertek__Finish__c, buildertek__Resource__c, buildertek__Lag__c, buildertek__Milestone__c, buildertek__Notes__c, buildertek__Order__c, buildertek__Original_End_Date__c, buildertek__Original_Start_Date__c, buildertek__Phase__c, buildertek__Type__c, buildertek__Dependency__c, buildertek__Project__c, buildertek__Purchase_Order__c, buildertek__Reason_for_Date_Change__c, buildertek__Reason_for_Date_Change_PL__c, buildertek__Required_Completion_Date__c, buildertek__Schedule__c, buildertek__Start__c, Name
                                from buildertek__Project_Task__c
                                where buildertek__Schedule__c  =:recordId AND buildertek__Milestone__c =: false order by buildertek__Order__c,CreatedDate NULLS LAST];

        Integer lastIndex = -1;
        Set<Id> existingSchItemId = new Set<Id>();
        if(existedScheduleitems.Size() > 0){
            lastIndex = existedScheduleitems.Size() - 1;
        }
        Integer count = 1;
        if(lastIndex >=0){
            if(Integer.valueOf(existedScheduleitems[lastIndex].buildertek__Order__c) == null){
                existedScheduleitems[lastIndex].buildertek__Order__c = 0;
            }
            count = Integer.valueOf(existedScheduleitems[lastIndex].buildertek__Order__c)+1;
        }

        String businessHourId = [SELECT Id, IsDefault, IsActive FROM BusinessHours WHERE IsDefault = true LIMIT 1].Id;

        for (fieldWrapper wrapper : datalist){
            if (wrapper.Name != null && String.isNotBlank(wrapper.Name)){
                buildertek__Project_Task__c schItem = new buildertek__Project_Task__c();
                String sizeString = wrapper.Name;
                Integer maxSize = 79;
                String des = wrapper.Name;
                if(sizeString.length() > maxSize ){
                    sizeString = sizeString.substring(0, maxSize);
                }
                schItem.Name = sizeString;
                schItem.buildertek__Long_Description__c = wrapper.Name;
                schItem.buildertek__Full_Name__c = wrapper.Name;
                schItem.buildertek__Schedule__c = recordId;
                schItem.buildertek__Completion__c = wrapper.percentComplete;

                Date startDate = system.today();

                if(mainScheduleRec.buildertek__Initial_Start_Date__c != null){
                    startDate = mainScheduleRec.buildertek__Initial_Start_Date__c;
                } else if (wrapper.StartDate != null) {
                    startDate = Date.valueOf(wrapper.StartDate);
                }

                if (String.isEmpty(wrapper.Dependency) && String.isBlank(wrapper.Dependency)) {
                    startDate = Date.valueOf(wrapper.StartDate);
                }

                // if (wrapper.StartDate != null) {
                //     startDate = Date.valueOf(wrapper.StartDate);
                // } else if(mainScheduleRec.buildertek__Initial_Start_Date__c != null){
                //     startDate = mainScheduleRec.buildertek__Initial_Start_Date__c;
                // }

                DateTime currentDate = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
                String todayDay = currentDate.format('EEEE');
                if (todayDay == 'Saturday') {
                    startDate = startDate.addDays(2);
                } else if (todayDay == 'Sunday') {
                    startDate = startDate.addDays(1);
                }

                schItem.buildertek__Start__c = startDate;
                // wrapper.StartDate = Date.valueOf(startDate);

                DateTime sDate = DateTime.newInstance(schItem.buildertek__Start__c.year(), schItem.buildertek__Start__c.month(), schItem.buildertek__Start__c.day());

                schItem.buildertek__Duration__c = wrapper.Duration;
                schItem.buildertek__Finish__c = System.BusinessHours.add(businessHourId, sDate, Integer.valueOf(wrapper.Duration)*(24 * 60 * 60 * 1000L)).date();
                schItem.buildertek__Original_Start_Date__c = startDate;
                schItem.buildertek__Original_End_Date__c = startDate.addDays(wrapper.Duration);
                schItem.buildertek__Phase__c = wrapper.Phase;
                schItem.buildertek__Notes__c = wrapper.Notes;
                schItem.buildertek__Lag__c = Double.valueOf(wrapper.Lag != null && String.isNotBlank(wrapper.Lag) ? wrapper.Lag : '0');
                schItem.buildertek__Order__c = count;
                count++;

                projectInsertTaskMap.put(schItem.Name, schItem);
            }
        }
        if (projectInsertTaskMap.size() > 0){
            try{
                ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
                insert projectInsertTaskMap.values();
                ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;

                Set<Id> taskIds = new Set<Id>();
                for (String key : projectInsertTaskMap.keySet()) {
                    System.debug('projectInsertTaskMap :=>  ' + projectInsertTaskMap.get(key));
                    taskIds.add(projectInsertTaskMap.get(key).Id);
                }

                for (fieldWrapper wrapper : datalist){
                    System.debug('wrapper.Dependency ==> '+wrapper.Dependency);
                    if(String.isNotBlank(wrapper.Dependency)){
                        if(projectInsertTaskMap.containsKey(wrapper.Dependency)){
                            system.debug('inside If => ' + projectInsertTaskMap.get(wrapper.Dependency).Id);
                            projectInsertTaskMap.get(wrapper.Name).buildertek__Dependency__c = projectInsertTaskMap.get(wrapper.Dependency).Id;

                        }
                        else{
                            system.debug(wrapper.Dependency + ' This Dependany not present');
                        }
                    //     System.debug('projectInsertTaskMap.get(wrapper.Dependency).Id ==> '+projectInsertTaskMap.get(wrapper.Dependency).Id);
                    //         System.debug('Dependency If '+ projectInsertTaskMap.get(wrapper.Dependency));
                    }
                }
                ProjectTaskTriggerHandler.blnSkipTaskTrigger = true;
                update projectInsertTaskMap.values();
                ProjectTaskTriggerHandler.blnSkipTaskTrigger = false;

                Map<String, buildertek__Project_Task__c> newProjectTaskMap = new Map<String, buildertek__Project_Task__c>([SELECT Id, Name, buildertek__Start__c, buildertek__Finish__c, buildertek__Schedule__c, buildertek__Duration__c, buildertek__Milestone__c, buildertek__Dependency__c, buildertek__Order__c FROM Project_Task__c WHERE Id IN: taskIds ORDER BY buildertek__Order__c ASC]);

                for (String key : newProjectTaskMap.keySet()) {
                    System.debug('Old newProjectTaskMap.get(key) ==> '+newProjectTaskMap.get(key));
                    if (newProjectTaskMap.get(key).buildertek__Dependency__c != null) {
                        newProjectTaskMap.get(key).buildertek__Start__c = newProjectTaskMap.get(newProjectTaskMap.get(key).buildertek__Dependency__c).buildertek__Finish__c;

                        DateTime sDate = DateTime.newInstance(newProjectTaskMap.get(key).buildertek__Start__c.year(), newProjectTaskMap.get(key).buildertek__Start__c.month(), newProjectTaskMap.get(key).buildertek__Start__c.day());
                        newProjectTaskMap.get(key).buildertek__Finish__c = System.BusinessHours.add(businessHourId, sDate, Integer.valueOf(newProjectTaskMap.get(key).buildertek__Duration__c)*(24 * 60 * 60 * 1000L)).date();
                    }
                }

                for (String key : newProjectTaskMap.keySet()) {
                    System.debug('New newProjectTaskMap.get(key) ==> '+newProjectTaskMap.get(key));
                }
                update newProjectTaskMap.values();

                returnresponse = 'SUCCESS';
            } catch (Exception e){
                returnresponse = 'ERROR'+' '+e.getMessage()+' '+e.getLineNumber();
            }
        }
        return returnresponse;
    }

    // Skip weekend and calculate date
	public static Date addDaysSkippingWeekends(Date sDate, Integer days){
		Date result = sDate;
		Integer addedDays = 0;
		while (addedDays < days){
			result = result.addDays(1);
			DateTime currentDate = DateTime.newInstance(result.year(), result.month(), result.day());
			String todayDay = currentDate.format('EEEE');
			if (todayDay != 'Saturday' && todayDay != 'Sunday'){
				++addedDays;
			}
		}
		return result;
	}

    public class fieldWrapper{
        public String Name;
        public String Dependency;
        public String StartDate;
        public Integer Duration;
        public Decimal percentComplete;
        public String Phase;
        public String Notes;
        public String Lag;
    }

}