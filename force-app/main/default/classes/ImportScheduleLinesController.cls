public with sharing class ImportScheduleLinesController{
    @AuraEnabled
    public static string insertData(String recordId, String strFileData){
        system.debug('strFileData--------------------------------------'+strFileData);
         system.debug('recordId--------------------------------------'+recordId);
        String returnresponse = '';
        List<buildertek__Project_Task__c> schItemToInsert = new List<buildertek__Project_Task__c>();
        List<fieldWrapper> datalist = (List<fieldWrapper>)JSON.deserialize(strFileData, List<fieldWrapper>.class);
        Map<String, String> myMap = new Map<String, String>();
        Map<String, Decimal> durationMap = new Map<String, Decimal>();

        Date FirstTaskDate;
        ProjectTaskTriggerHandler.isFromImport = true;
        system.debug('strFileData::::'+strFileData);
        buildertek__Schedule__c mainScheduleRec;
        if(String.isNotBlank(recordId)){
            mainScheduleRec = [SELECT Id,
                               Name,
                               buildertek__Initial_Start_Date__c,
                               buildertek__Start_Date__c,
                               buildertek__End_Date__c,
                               buildertek__Original_Start_Date__c,
                               buildertek__Original_End_Date__c
                               FROM buildertek__Schedule__c WHERE Id =:recordId limit 1];
        }
        list<buildertek__Project_Task__c> existedScheduleitems = new list<buildertek__Project_Task__c>();
        existedScheduleitems = [select Id, buildertek__Completion__c, buildertek__Full_Name__c,buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Duration__c, buildertek__Finish__c, buildertek__Resource__c, buildertek__Lag__c, buildertek__Milestone__c, buildertek__Notes__c, buildertek__Order__c, buildertek__Original_End_Date__c, buildertek__Original_Start_Date__c, buildertek__Phase__c, buildertek__Type__c, buildertek__Dependency__c, buildertek__Project__c, buildertek__Purchase_Order__c, buildertek__Reason_for_Date_Change__c, buildertek__Reason_for_Date_Change_PL__c, buildertek__Required_Completion_Date__c, buildertek__Schedule__c, buildertek__Start__c, Name
                                from buildertek__Project_Task__c
                                where buildertek__Schedule__c  =:recordId AND buildertek__Milestone__c =: false order by buildertek__Order__c,CreatedDate NULLS LAST];

        Integer lastIndex = -1;
        Set<Id> existingSchItemId = new Set<Id>();
        /*for(buildertek__Project_Task__c item : existedScheduleitems){
            existingSchItemId.add(item.Id);
        }*/
        if(existedScheduleitems.Size() > 0){
            lastIndex = existedScheduleitems.Size() - 1;
            if(lastIndex >=0){
                system.debug('one '+existedScheduleitems[lastIndex]);
            }
        }
        Integer count = 1;
        if(lastIndex >=0){
            if(Integer.valueOf(existedScheduleitems[lastIndex].buildertek__Order__c) == null){
                existedScheduleitems[lastIndex].buildertek__Order__c = 0;
            }
            count = Integer.valueOf(existedScheduleitems[lastIndex].buildertek__Order__c)+1;
            system.debug(existedScheduleitems[lastIndex]);
        }

        for (fieldWrapper wrapper : datalist){
            if (wrapper.Name != null && String.isNotBlank(wrapper.Name)){
                System.debug('wrapper::'+wrapper);
                Date startDate = Date.valueOf(wrapper.StartDate);
                buildertek__Project_Task__c schItem = new buildertek__Project_Task__c();
                //schItem.Name = wrapper.Name;
                String sizeString = wrapper.Name;
                Integer maxSize = 79;
                String des = wrapper.Name;
                if(sizeString.length() > maxSize ){
                    //des = sizeString;
                    sizeString = sizeString.substring(0, maxSize);

                }
                schItem.Name = sizeString;
                schItem.buildertek__Long_Description__c = wrapper.Name;
                schItem.buildertek__Full_Name__c = wrapper.Name;
                schItem.buildertek__Schedule__c = recordId;
                schItem.buildertek__Completion__c = wrapper.percentComplete;
                system.debug('dateinWrapper-->'+wrapper.StartDate);
                system.debug('dateInExcel-->'+wrapper.StartDate+'date in record-->'+mainScheduleRec.buildertek__Initial_Start_Date__c);

                //assigin date in schedule record to alls task that are importing
                if(mainScheduleRec.buildertek__Initial_Start_Date__c !=null){
                    schItem.buildertek__Start__c = mainScheduleRec.buildertek__Initial_Start_Date__c;
                    wrapper.StartDate = Date.valueOf(mainScheduleRec.buildertek__Initial_Start_Date__c);
                    FirstTaskDate = Date.valueOf(mainScheduleRec.buildertek__Initial_Start_Date__c);
                    startDate = Date.valueOf(wrapper.StartDate);
                }else{
                    Date today = system.today();
                    schItem.buildertek__Start__c = today;
                    wrapper.StartDate = Date.valueOf(schItem.buildertek__Start__c);
                    FirstTaskDate = Date.valueOf(schItem.buildertek__Start__c);
                    startDate = Date.valueOf(wrapper.StartDate);
                }

                // assigin date in schedule record to 1st task that is importing
                /*if(count == 0 && mainScheduleRec.buildertek__Initial_Start_Date__c !=null){
                    schItem.buildertek__Start__c = mainScheduleRec.buildertek__Initial_Start_Date__c;
                    wrapper.StartDate = Date.valueOf(mainScheduleRec.buildertek__Initial_Start_Date__c);
                    FirstTaskDate = Date.valueOf(mainScheduleRec.buildertek__Initial_Start_Date__c);
                    startDate = Date.valueOf(wrapper.StartDate);
                    //Date changeDate = new Date(mainScheduleRec.buildertek__Initial_Start_Date__c);
                    //system.debug(changeDate);
                }else{
                    schItem.buildertek__Start__c = Date.valueOf(wrapper.StartDate);
                }*/
                system.debug('schItem.buildertek__Start__c--->'+schItem.buildertek__Start__c);


                /*String sizeString = wrapper.Name;
                Integer maxSize = 79;
                String des = '';
                if(sizeString.length() > maxSize ){
                    des = sizeString;
                    sizeString = sizeString.substring(0, maxSize);

                }
                schItem.Name = sizeString;
                schItem.buildertek__Long_Description__c = des;*/
                system.debug('Two '+schItem);
                schItem.buildertek__Duration__c = wrapper.Duration;
                schItem.buildertek__Original_Start_Date__c = Date.valueOf(wrapper.StartDate);
                schItem.buildertek__Original_End_Date__c = startDate.addDays(wrapper.Duration);
                schItem.buildertek__Phase__c = wrapper.Phase;
                 schItem.buildertek__Notes__c = wrapper.Notes;
                schItem.buildertek__Lag__c = Double.valueOf(wrapper.Lag != null && String.isNotBlank(wrapper.Lag) ? wrapper.Lag : '0');
                schItem.buildertek__Order__c = count;
                //schItem.buildertek__Required_Completion_Date__c = Date.valueOf(wrapper.StartDate).addDays(Integer.valueOf(wrapper.Duration));
                count++;
                schItemToInsert.add(schItem);
            }
        }
        system.debug('@@@ schItemToInsert = ' + schItemToInsert);
        if (schItemToInsert.size() > 0){
            try{
                ProjectTaskTriggerHandler.isFromImport = true;
                if (Schema.sObjectType.buildertek__Project_Task__c.fields.Name.isCreateable() && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Duration__c.isCreateable() && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Schedule__c.isCreateable() && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Start__c.isCreateable() && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Phase__c.isCreateable()){
                    insert schItemToInsert;
                   //mainScheduleRec.buildertek__Original_Start_Date__c=mainScheduleRec.buildertek__Start_Date__c;
                    //mainScheduleRec.buildertek__Original_End_Date__c=mainScheduleRec.buildertek__End_Date__c;
                   // futureContoller.updateScheduleRec(mainScheduleRec.Id);
                    //System.enqueueJob(new CallQueueable(mainScheduleRec));
                }
                List<buildertek__Project_Task__c> schItemToUpdate = new List<buildertek__Project_Task__c>();
                Set<String> taskNameSet = new Set<String>();
                Set<Id> schItemIds = new Set<Id>();
                for (buildertek__Project_Task__c schItems : schItemToInsert){
                    taskNameSet.add(schItems.buildertek__Full_Name__c);
                    schItemIds.add(schItems.Id);
                }
                System.debug('Query Started 123 ------------------------------->  0000');
                List<buildertek__Project_Task__c> schItemList;
                if (Schema.sObjectType.buildertek__Project_Task__c.fields.Id.isAccessible() && Schema.sObjectType.buildertek__Project_Task__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Dependency__c.isAccessible() && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Duration__c.isAccessible() && Schema.sObjectType.buildertek__Project_Task__c.fields.Schedule__c.isAccessible()){
                    schItemList = [select Id, Name, buildertek__Dependency__c, buildertek__Duration__c,buildertek__Start__c,buildertek__Full_Name__c
                                   from buildertek__Project_Task__c
                                   where buildertek__Full_Name__c IN :taskNameSet and Schedule__c = :recordId AND Id IN:schItemIds];
                }
                system.debug('schItemList -----------> ' + schItemList);
                Integer i =0 ;
                List<String> nameStringList = new List<String>();
                for (buildertek__Project_Task__c items : schItemToInsert){
                    myMap.put(items.buildertek__Full_Name__c+'__'+i, items.Id);
                    durationMap.put(items.buildertek__Full_Name__c+'__'+i, items.buildertek__Duration__c);
                    nameStringList.add(items.buildertek__Full_Name__c);
                    i++;
                }
                system.debug('durationMap -------------> ' + durationMap);
                i=0;
                for (fieldWrapper wrapper : datalist){
                    Integer completionDays;
                    system.debug('Three '+myMap.get(wrapper.Dependency+'__'+i));
                    system.debug('durationMap List  -------------> ' + durationMap.get(wrapper.Dependency+'__'+i));
                    buildertek__Project_Task__c schItem = new buildertek__Project_Task__c();
                    system.debug('four '+wrapper.Name+'__'+i);
                     system.debug('five '+wrapper.Dependency+'__'+i);
                      system.debug('six '+myMap.get(wrapper.Name+'__'+i));
                    schItem.Id = myMap.get(wrapper.Name+'__'+i);
                    if(String.isNotBlank(wrapper.Dependency)){
                        Integer dependencyIndex = nameStringList.indexOf(wrapper.Dependency);
                        system.debug('Seven '+nameStringList.indexOf(wrapper.Dependency));
                        system.debug('Eight '+myMap.get(wrapper.Dependency+'__'+dependencyIndex));
                        system.debug('Nine '+myMap.get(wrapper.Dependency+'__'+i));
                        system.debug('wrapper.Name-->'+wrapper.Name );
                        system.debug('wrapper.Dependency-->'+wrapper.Dependency);
                         if(wrapper.Dependency != wrapper.Name){
                            schItem.Dependency__c = myMap.get(wrapper.Dependency+'__'+dependencyIndex);
                        }
                        //schItem.Dependency__c = myMap.get(wrapper.Dependency+'__'+dependencyIndex);
                        if (durationMap.get(wrapper.Dependency+'__'+dependencyIndex) == null){
                            completionDays = wrapper.Duration;

                        } else{
                            completionDays = Integer.valueOf(durationMap.get(wrapper.Dependency+'__'+dependencyIndex))+wrapper.Duration;
                        }
                        schItem.buildertek__Required_Completion_Date__c = Date.valueOf(wrapper.StartDate).addDays(completionDays);
                    }


                    if(FirstTaskDate != null){
                        schItem.buildertek__Start__c = FirstTaskDate;
                    }

                    if(schItem.Id != null){
                        schItemToUpdate.add(schItem);
                    }
                    system.debug('Ten '+schItemToUpdate);
                    //schItemToUpdate.add(schItem);
                    system.debug('Eleven '+schItem+' '+schItem.buildertek__Required_Completion_Date__c);
                    system.debug('Twelve '+wrapper.StartDate+' '+schItem.buildertek__Start__c);
                    i++;
                }
                /*if(schItemIds.size() > 0){
                    UpdateScheduleItemDatesBatch updateDependency = new UpdateScheduleItemDatesBatch(schItemIds);
                     Database.executeBatch(updateDependency, 200);
                }*/
                if (Schema.sObjectType.buildertek__Project_Task__c.fields.Dependency__c.isUpdateable() && Schema.sObjectType.buildertek__Project_Task__c.fields.buildertek__Required_Completion_Date__c.isUpdateable()){
                   // system.debug('Thirty '+[Select Id,Name,buildertek__Start__c FROM buildertek__Project_Task__c WHERE Id =: schItemToUpdate[0].Id]);
                    system.debug('Thirteen '+schItemToUpdate[0]);
                    ProjectTaskTriggerHandler.isFromImport = true;
                    update schItemToUpdate;
                   //  futureContoller.updateScheduleRec(mainScheduleRec.Id);
                }

                system.debug('Fouteen '+schItemToUpdate[0]);
                returnresponse = 'SUCCESS';
            } catch (Exception e){
                System.debug('Error::' + e.getMessage());
                System.debug('Error::' + e.getLineNumber());
                returnresponse = 'ERROR'+' '+e.getMessage()+' '+e.getLineNumber();
            }
        }
        return returnresponse;
    }


    public class fieldWrapper{
        public String Name;
        public String Dependency;
        //public Date CompletionDate;
        public Date StartDate;
        public Integer Duration;
        public Decimal percentComplete;
        public String Phase;
        public String Notes;
        public String Lag;
    }


     /* public class CallQueueable implements System.Queueable{
        buildertek__Schedule__c schedulerec;
        public CallQueueable(buildertek__Schedule__c scheRecQue){
            schedulerec = scheRecQue;
        }

        public void execute(System.QueueableContext ctx) {
            try{
                system.debug('schedulerec--->'+schedulerec);
                update schedulerec;
            }catch(Exception e){
                system.debug('exception --->'+e.getMessage());
            }
        }

    }*/



}