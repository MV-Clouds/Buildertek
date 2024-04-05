public class scheduleAssignResources {


    @AuraEnabled
    public static ScheduleDataWrapper fetchResouceData(String vendorId, String vendorResourceId ){
        List<String> projectColors = new List<String>{'#ADD8E6','#DCF5E7','#FCD9D9','#DBDBF8','#A9D9FF','#A0D6B4','#FFFFC2','#E9967A','#FDD7E4','#F9B7FF','#FFF0F5','#C0C0C0','#95B9C7','#00FFFF','#55FFFF','#BBFFFF','#BBFFAA','#BBFFDD','#FFE7E7','#AAFFFF','#DDFFCC','#ADDFFF','#ABBFCC','#ABBFDD','#ABBFBE','#C9DFEC','#EBF4EA','#CCFFFF','#8EEBEC','#AAF0D1','#CDFADB','#FFE4C9','#C3E2C2','#F1EAFF','#FFDFDF','#F8E8EE','#FFCEFE','#F3CCFF','#F4EAB1','#E4FBFF','#FFCAC8','#FFDCA9','#FCDDB0','#DEF5E5','#C7F2A4','#CEE5D0','#FCF9C6','#FAD4D4','#B8F1B0', '#C6CFFF'};
        
        ScheduleDataWrapper wrapper = new ScheduleDataWrapper();
        try {
            List<resouceDataWrapper> resourceDataList = new List<resouceDataWrapper>();
            List<Account> vendor = new List<Account>();

            List<Contact> resourceListWithTaks = new List<Contact>();

            if(vendorId != null && vendorResourceId == null){
                resourceListWithTaks = [SELECT Id, Name, 
                                            (SELECT Id, Name, buildertek__Schedule__c, buildertek__Schedule__r.Name, buildertek__Dependency__c,buildertek__Dependency__r.Name, buildertek__Schedule__r.buildertek__Description__c, buildertek__Schedule__r.buildertek__Project__r.Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource_1__c,buildertek__Contractor_Resource_2__c, buildertek__Contractor_Resource_3__c, buildertek__Start__c,buildertek__Notes__c, buildertek__Finish__c 
                                            FROM buildertek__BT_Schedule_Items5__r WHERE buildertek__Type__c = 'Task' AND buildertek__Schedule__r.buildertek__Project__c != null ORDER BY buildertek__Schedule__r.buildertek__Project__r.Name ,buildertek__Schedule__r.Name, Name,buildertek__Dependency__r.Name,buildertek__Start__c,buildertek__Finish__c ASC LIMIT 10000),       
                                            (SELECT Id, Name, buildertek__Schedule__c, buildertek__Schedule__r.Name, buildertek__Dependency__c,buildertek__Dependency__r.Name, buildertek__Schedule__r.buildertek__Description__c, buildertek__Schedule__r.buildertek__Project__r.Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource_1__c,buildertek__Contractor_Resource_2__c, buildertek__Contractor_Resource_3__c, buildertek__Start__c,buildertek__Notes__c, buildertek__Finish__c 
                                            FROM buildertek__BT_Schedule_Items3__r WHERE buildertek__Type__c = 'Task' AND buildertek__Schedule__r.buildertek__Project__c != null ORDER BY buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Schedule__r.Name, Name,buildertek__Dependency__r.Name,buildertek__Start__c,buildertek__Finish__c ASC LIMIT 10000),
                                            (SELECT Id, Name, buildertek__Schedule__c, buildertek__Schedule__r.Name, buildertek__Dependency__c,buildertek__Dependency__r.Name, buildertek__Schedule__r.buildertek__Description__c, buildertek__Schedule__r.buildertek__Project__r.Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource_1__c,buildertek__Contractor_Resource_2__c, buildertek__Contractor_Resource_3__c, buildertek__Start__c,buildertek__Notes__c, buildertek__Finish__c 
                                            FROM buildertek__BT_Schedule_Items4__r WHERE buildertek__Type__c = 'Task' AND buildertek__Schedule__r.buildertek__Project__c != null ORDER BY buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Schedule__r.Name, Name,buildertek__Dependency__r.Name,buildertek__Start__c,buildertek__Finish__c ASC LIMIT 10000)
                                        FROM Contact WHERE AccountId =: vendorId];
                vendor = [SELECT Id, Name FROM Account WHERE Id =:  vendorId ];
                if (vendor.size() > 0){
                    wrapper.vendor = vendor;
                }
        }
            else if(vendorResourceId != null && vendorId == null){
                resourceListWithTaks = [SELECT Id, Name, AccountId,
                                            (SELECT Id, Name, buildertek__Schedule__c, buildertek__Schedule__r.Name, buildertek__Dependency__c,buildertek__Dependency__r.Name, buildertek__Schedule__r.buildertek__Description__c, buildertek__Schedule__r.buildertek__Project__r.Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource_1__c,buildertek__Contractor_Resource_2__c, buildertek__Contractor_Resource_3__c, buildertek__Start__c,buildertek__Notes__c, buildertek__Finish__c 
                                            FROM buildertek__BT_Schedule_Items5__r WHERE buildertek__Type__c = 'Task' AND buildertek__Schedule__r.buildertek__Project__c != null ORDER BY buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Schedule__r.Name, Name,buildertek__Dependency__r.Name,buildertek__Start__c,buildertek__Finish__c ASC LIMIT 10000),       
                                            (SELECT Id, Name, buildertek__Schedule__c, buildertek__Schedule__r.Name, buildertek__Dependency__c,buildertek__Dependency__r.Name, buildertek__Schedule__r.buildertek__Description__c, buildertek__Schedule__r.buildertek__Project__r.Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource_1__c,buildertek__Contractor_Resource_2__c, buildertek__Contractor_Resource_3__c, buildertek__Start__c,buildertek__Notes__c, buildertek__Finish__c 
                                            FROM buildertek__BT_Schedule_Items3__r WHERE buildertek__Type__c = 'Task' AND buildertek__Schedule__r.buildertek__Project__c != null ORDER BY buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Schedule__r.Name, Name,buildertek__Dependency__r.Name,buildertek__Start__c,buildertek__Finish__c ASC LIMIT 10000),
                                            (SELECT Id, Name, buildertek__Schedule__c, buildertek__Schedule__r.Name, buildertek__Dependency__c,buildertek__Dependency__r.Name, buildertek__Schedule__r.buildertek__Description__c, buildertek__Schedule__r.buildertek__Project__r.Name, buildertek__Contractor__c, buildertek__Contractor_Resource__c, buildertek__Contractor_Resource_1__c,buildertek__Contractor_Resource_2__c, buildertek__Contractor_Resource_3__c, buildertek__Start__c,buildertek__Notes__c, buildertek__Finish__c 
                                            FROM buildertek__BT_Schedule_Items4__r WHERE buildertek__Type__c = 'Task' AND buildertek__Schedule__r.buildertek__Project__c != null ORDER BY buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Schedule__r.Name, Name,buildertek__Dependency__r.Name,buildertek__Start__c,buildertek__Finish__c ASC LIMIT 10000)
                                        FROM Contact WHERE Id =: vendorResourceId];

                // if(resourceListWithTaks.size() > 0 && resourceListWithTaks[0].AccountId != null){
                    vendor = [SELECT Id, Name FROM Account WHERE Id =:  vendorId];
                    if (vendor.size() > 0){
                        wrapper.vendor = vendor;
                    }
                // }
            }
            
            Integer colorIndex = 0;
            Map<Id, String> uniqueProjectColorMap = new Map<Id, String>();

            for(Contact con : resourceListWithTaks){
                resouceDataWrapper resouceData = new resouceDataWrapper();

                Set<buildertek__Project_Task__c> taskSet = new Set<buildertek__Project_Task__c>();
                for(buildertek__Project_Task__c task : con.buildertek__BT_Schedule_Items5__r){    // For Vendor Resouce 1;
                    taskSet.add(task);
                }
                for(buildertek__Project_Task__c task : con.buildertek__BT_Schedule_Items3__r){    // For Vendor Resouce 2;
                    taskSet.add(task);
                }
                for(buildertek__Project_Task__c task : con.buildertek__BT_Schedule_Items4__r){    // For Vendor Resouce 23;
                    taskSet.add(task);
                }

                List<buildertek__Project_Task__c> taskList = new List<buildertek__Project_Task__c>(taskSet);
                for (buildertek__Project_Task__c task : taskList) {
                    if (task.buildertek__Schedule__r != null && task.buildertek__Schedule__r.buildertek__Project__c != null) {
                        Id projectId = task.buildertek__Schedule__r.buildertek__Project__c;
                        if (!uniqueProjectColorMap.containsKey(projectId)) {
                            if (colorIndex < projectColors.size()) {
                                uniqueProjectColorMap.put(projectId, projectColors[colorIndex]);
                            } else {
                                uniqueProjectColorMap.put(projectId, '#FFF');
                            }
                            colorIndex++;
                        }
                    }
                }
                

                resouceData.resource = con;
                resouceData.taskList = taskList;
                resourceDataList.add(resouceData);
            }                                                            

            wrapper.resourceDataList = resourceDataList;
            wrapper.status = 'success';
            wrapper.uniqueProjectColorMap = uniqueProjectColorMap;
        } catch (Exception e) {
            System.debug('Error in fetchResouceData ..' + e.getMessage() + '\n' + e +'\n Exception line no : '+ e.getLineNumber() +'--->'+ e.getStackTraceString());

            wrapper.status = 'error';
            wrapper.returnMessge = 'Exception in fetchResouceData' + e.getMessage();

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
        @AuraEnabled public List<Account> vendor;
        @AuraEnabled public List<resouceDataWrapper> resourceDataList;
        @AuraEnabled public Map<Id, String> uniqueProjectColorMap;
    }

    public class resouceDataWrapper{
        @AuraEnabled public Contact resource;
        @AuraEnabled public List<buildertek__Project_Task__c>  taskList;
    }    

}