public without sharing class CreateScheduleFromBudget {

    @AuraEnabled
    public static void createScheduleLine(String scheduleId ,String budgetId) {
        System.debug('createScheduleLine');
        System.debug('scheduleId' + scheduleId);

        if(scheduleId!= null){
            list<buildertek__Project_Task__c> scheduleLineList = new list<buildertek__Project_Task__c>();
            buildertek__Schedule__c scheduleList=[Select Id , buildertek__Initial_Start_Date__c  From buildertek__Schedule__c where Id=:scheduleId LIMIT 1];
            List<buildertek__Budget_Item__c> budgetLineList=[Select Id , Name , buildertek__Contractor__c, buildertek__Budget_Line_Group__r.Name , buildertek__Budget_Line_Group__c, buildertek__Budget__c From buildertek__Budget_Item__c where buildertek__Budget__c=:budgetId];

            System.debug('budgetLineList' + budgetLineList.size());

            if(budgetLineList.size() > 0){
                for(buildertek__Budget_Item__c budgetLineRec:budgetLineList){
                    buildertek__Project_Task__c scheduleLineRec = new buildertek__Project_Task__c();
                    scheduleLineRec.Name=budgetLineRec.Name;
                    scheduleLineRec.buildertek__Schedule__c=scheduleId;
                    scheduleLineRec.buildertek__Start__c=scheduleList.buildertek__Initial_Start_Date__c;
                    scheduleLineRec.buildertek__Duration__c=1;

                    scheduleLineRec.buildertek__Phase__c=budgetLineRec.buildertek__Budget_Line_Group__r.Name;
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