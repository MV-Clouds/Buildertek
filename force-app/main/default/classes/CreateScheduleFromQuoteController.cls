public without sharing class CreateScheduleFromQuoteController {
   
    @AuraEnabled
    public static void createScheduleLine(String scheduleId ,String recId , String sobjName) {
        System.debug('createScheduleLine');
        System.debug('scheduleId' + scheduleId);
        System.debug('recId' + recId);


        if(scheduleId!= null && recId!= null){
            list<buildertek__Project_Task__c> scheduleLineList = new list<buildertek__Project_Task__c>();
            buildertek__Schedule__c scheduleList=[Select Id , buildertek__Initial_Start_Date__c  From buildertek__Schedule__c where Id=:scheduleId LIMIT 1];
            List<buildertek__Quote_Item__c> quoteLineList= new List<buildertek__Quote_Item__c>();
            List<buildertek__Budget_Item__c> budgetLineList= new List<buildertek__Budget_Item__c>();    
            System.debug('sobjName' + sobjName);

            if(sobjName  == 'buildertek__Quote__c'){
               quoteLineList=[Select Id , Name , buildertek__Vendor__c, buildertek__Grouping__r.Name , buildertek__Grouping__c, buildertek__Quote__c From buildertek__Quote_Item__c where buildertek__Quote__c=:recId];
               if(quoteLineList.size() > 0){
                for(buildertek__Quote_Item__c quoteLineRec:quoteLineList){
                    buildertek__Project_Task__c scheduleLineRec = new buildertek__Project_Task__c();
                    scheduleLineRec.Name=quoteLineRec.Name;
                    scheduleLineRec.buildertek__Schedule__c=scheduleId;
                    scheduleLineRec.buildertek__Start__c=scheduleList.buildertek__Initial_Start_Date__c;
                    scheduleLineRec.buildertek__Duration__c=1;

                    scheduleLineRec.buildertek__Phase__c=quoteLineRec.buildertek__Grouping__r.Name;
                    scheduleLineRec.buildertek__Contractor__c=quoteLineRec.buildertek__Vendor__c;

                    scheduleLineList.add(scheduleLineRec);
                }
                System.debug('scheduleLineList' + scheduleLineList.size());
                System.debug('scheduleLineList' + scheduleLineList);
                if(scheduleLineList.size() > 0){
                     insert scheduleLineList;
                }
                 }
            }

            if(sobjName == 'buildertek__Budget__c'){
                budgetLineList=[Select Id , Name , buildertek__Contractor__c, buildertek__Group__r.Name , buildertek__Group__c, buildertek__Budget__c From buildertek__Budget_Item__c where buildertek__Budget__c=:recId];
                if(budgetLineList.size() > 0){
                    for(buildertek__Budget_Item__c budgetLineRec:budgetLineList){
                        buildertek__Project_Task__c scheduleLineRec = new buildertek__Project_Task__c();
                        scheduleLineRec.Name=budgetLineRec.Name;
                        scheduleLineRec.buildertek__Schedule__c=scheduleId;
                        scheduleLineRec.buildertek__Start__c=scheduleList.buildertek__Initial_Start_Date__c;
                        scheduleLineRec.buildertek__Duration__c=1;
    
                        scheduleLineRec.buildertek__Phase__c=budgetLineRec.buildertek__Group__r.Name;
                        scheduleLineRec.buildertek__Contractor__c=budgetLineRec.buildertek__Contractor__c;
    
                        scheduleLineList.add(scheduleLineRec);
                    }
                    System.debug('scheduleLineList' + scheduleLineList.size());
                    System.debug('scheduleLineList' + scheduleLineList);
    
    
                    if(scheduleLineList.size() > 0){
                         insert scheduleLineList;
                    }
                }
            }
        } 
    }
    
}