public class scheduleAssignResources {
    // @AuraEnabled
    // public static ScheduleDataWrapper fetchScheduleData(String vendorId){
    //     ScheduleDataWrapper wrapper = new ScheduleDataWrapper();
    //     try {
    //         wrapper.scheduleList = [SELECT Id, Name, buildertek__Schedule__c, buildertek__Schedule__r.Name, buildertek__Dependency__c,buildertek__Dependency__r.Name, buildertek__Schedule__r.buildertek__Description__c, 
    //                                         buildertek__Schedule__r.buildertek__Project__r.Name, buildertek__Contractor__c, buildertek__Contractor__r.Name, buildertek__Contractor_Resource_1__c,buildertek__Contractor_Resource_1__r.Name,
    //                                         buildertek__Contractor_Resource_2__c,buildertek__Contractor_Resource_2__r.Name, buildertek__Contractor_Resource_3__c,buildertek__Contractor_Resource_3__r.Name, buildertek__Start__c,
    //                                         buildertek__Notes__c, buildertek__Finish_Date__c 
    //                                         FROM buildertek__Project_Task__c 
    //                                         WHERE buildertek__Schedule__c = :scheduleId AND buildertek__Contractor__c = :vendorId AND buildertek__Type__c = 'Task' ORDER BY Name ASC LIMIT 10000];
    
    //         wrapper.internalResourcesList = [SELECT Id, Name FROM User WHERE isActive = TRUE ORDER BY Name ASC LIMIT 10000];
    //         wrapper.contractorAndResourcesList = [SELECT Id, Name, (SELECT Id, Name, LastName, FirstName FROM Contacts) FROM Account WHERE buildertek__BT_Account_Type__c = 'Vendor' ORDER BY Name ASC];
    //         wrapper.status = 'success';
            
    //     } catch (Exception e) {
    //         System.debug('Error in fetchScheduleData ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());

    //         wrapper.status = 'error';
    //         wrapper.returnMessge = 'Exception in fetchScheduleData' + e.getMessage();

    //         List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
    //             if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
    //                 BT_ExceptionHandler.Store_Exception(e);
    //             }
    //     }
        
    //     return wrapper;
    // }

    @AuraEnabled
    public static ScheduleDataWrapper fetchResouceData_byVendor(String vendorId){
        ScheduleDataWrapper wrapper = new ScheduleDataWrapper();
        try {
            List<resouceDataWrapper> resourceDataList = new List<resouceDataWrapper>();

            List<Contact> resourceListWithTaks = [SELECT Id, Name, 
                                                        (SELECT Id, Name, buildertek__Schedule__c, buildertek__Schedule__r.Name, buildertek__Dependency__c,buildertek__Dependency__r.Name, buildertek__Schedule__r.buildertek__Description__c, buildertek__Schedule__r.buildertek__Project__r.Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource_1__c,buildertek__Contractor_Resource_2__c, buildertek__Contractor_Resource_3__c, buildertek__Start__c,buildertek__Notes__c, buildertek__Finish_Date__c 
                                                        FROM buildertek__BT_Schedule_Items5__r WHERE buildertek__Type__c = 'Task' AND buildertek__Schedule__r.buildertek__Project__c != null ORDER BY Name ASC LIMIT 10000),       
                                                        (SELECT Id, Name, buildertek__Schedule__c, buildertek__Schedule__r.Name, buildertek__Dependency__c,buildertek__Dependency__r.Name, buildertek__Schedule__r.buildertek__Description__c, buildertek__Schedule__r.buildertek__Project__r.Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource_1__c,buildertek__Contractor_Resource_2__c, buildertek__Contractor_Resource_3__c, buildertek__Start__c,buildertek__Notes__c, buildertek__Finish_Date__c 
                                                        FROM buildertek__BT_Schedule_Items3__r WHERE buildertek__Type__c = 'Task' AND buildertek__Schedule__r.buildertek__Project__c != null ORDER BY Name ASC LIMIT 10000),
                                                        (SELECT Id, Name, buildertek__Schedule__c, buildertek__Schedule__r.Name, buildertek__Dependency__c,buildertek__Dependency__r.Name, buildertek__Schedule__r.buildertek__Description__c, buildertek__Schedule__r.buildertek__Project__r.Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource_1__c,buildertek__Contractor_Resource_2__c, buildertek__Contractor_Resource_3__c, buildertek__Start__c,buildertek__Notes__c, buildertek__Finish_Date__c 
                                                        FROM buildertek__BT_Schedule_Items4__r WHERE buildertek__Type__c = 'Task' AND buildertek__Schedule__r.buildertek__Project__c != null ORDER BY Name ASC LIMIT 10000)
                                                    FROM Contact WHERE AccountId =: vendorId];

            for(Contact con : resourceListWithTaks){
                resouceDataWrapper resouceData = new resouceDataWrapper();

                List<buildertek__Project_Task__c> taskList = new List<buildertek__Project_Task__c>();
                for(buildertek__Project_Task__c task : con.buildertek__BT_Schedule_Items5__r){    // For Vendor Resouce 1;
                    taskList.add(task);
                }
                for(buildertek__Project_Task__c task : con.buildertek__BT_Schedule_Items3__r){    // For Vendor Resouce 2;
                    taskList.add(task);
                }
                for(buildertek__Project_Task__c task : con.buildertek__BT_Schedule_Items4__r){    // For Vendor Resouce 23;
                    taskList.add(task);
                }

                resouceData.resource = con;
                resouceData.taskList = taskList;
                resourceDataList.add(resouceData);
            }                                                            

            wrapper.resourceDataList = resourceDataList;
            wrapper.status = 'success';
        } catch (Exception e) {
            System.debug('Error in fetchResouceData ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());

            wrapper.status = 'error';
            wrapper.returnMessge = 'Exception in fetchResouceData_byVendor' + e.getMessage();

            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
                }
        }
        return wrapper;
    }

    @AuraEnabled
    public static ScheduleDataWrapper fetchResouceData(String resourceId){
        ScheduleDataWrapper wrapper = new ScheduleDataWrapper();
        try {

            List<Contact> resource = [SELECT Id, Name FROM Contact WHERE Id =: resourceId];
            List<buildertek__Project_Task__c> scheduleItems = [SELECT Id, Name, buildertek__Schedule__c, buildertek__Schedule__r.Name, buildertek__Dependency__c,buildertek__Dependency__r.Name, buildertek__Schedule__r.buildertek__Description__c, 
                                                                buildertek__Schedule__r.buildertek__Project__r.Name, buildertek__Contractor__c, buildertek__Contractor__r.Name, buildertek__Contractor_Resource_1__c,buildertek__Contractor_Resource_1__r.Name,
                                                                buildertek__Contractor_Resource_2__c,buildertek__Contractor_Resource_2__r.Name, buildertek__Contractor_Resource_3__c,buildertek__Contractor_Resource_3__r.Name, buildertek__Start__c,
                                                                buildertek__Notes__c, buildertek__Finish_Date__c 
                                                        FROM buildertek__Project_Task__c 
                                                        WHERE  (buildertek__Contractor_Resource__c = :resourceId OR buildertek__Contractor_Resource_1__c =: resourceId OR buildertek__Contractor_Resource_3__c =: resourceId OR buildertek__Contractor_Resource_3__c =: resourceId) AND buildertek__Schedule__r.buildertek__Project__c != null];
           resouceDataWrapper resourceDat = new resouceDataWrapper();
           resourceDat.resource = resource.size() > 0 ? resource[0] : null;
           resourceDat.taskList = scheduleItems;

           wrapper.resourceData = resourceDat;
           wrapper.status = 'success';
        } catch (Exception e) {
            System.debug('Error in fetchResouceData ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());

            wrapper.status = 'error';
            wrapper.returnMessge = 'Exception in fetchScheduleData' + e.getMessage();

            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
                if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                    BT_ExceptionHandler.Store_Exception(e);
                }
        }
        return wrapper;
    }
    
    public class ScheduleDataWrapper {
        @AuraEnabled public String status;
        @AuraEnabled public String returnMessge;
        @AuraEnabled public resouceDataWrapper resourceData;
        @AuraEnabled public List<resouceDataWrapper> resourceDataList;

        @AuraEnabled public List<buildertek__Project_Task__c> scheduleList;
        @AuraEnabled public List<User> internalResourcesList;
        @AuraEnabled public List<Account> contractorAndResourcesList;

    }

    public class resouceDataWrapper{
        @AuraEnabled public Contact resource;
        @AuraEnabled public Account vendor;
        @AuraEnabled public List<buildertek__Project_Task__c>  taskList;
    }    

}