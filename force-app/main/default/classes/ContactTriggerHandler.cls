public with sharing class ContactTriggerHandler {
    public void onAfterUpdate(List<Contact> newconRecList, Map<Id, Contact> oldconRecMap) {
        try {
            Map<Id, Decimal> hourlyRateMap = new Map<Id, Decimal>();
    
            for (Contact conRec : newconRecList) {
                Contact oldconRec = oldconRecMap.get(conRec.Id);
    
                if (conRec.buildertek__Hourly_Rate__c != oldconRec.buildertek__Hourly_Rate__c ||
                    conRec.buildertek__Base_Weekly_Pay__c != oldconRec.buildertek__Base_Weekly_Pay__c ||
                    conRec.buildertek__Daily_Over_Time_Threshold__c != oldconRec.buildertek__Daily_Over_Time_Threshold__c ||
                    conRec.buildertek__Overtime__c != oldconRec.buildertek__Overtime__c ||
                    conRec.buildertek__Weekly__c != oldconRec.buildertek__Weekly__c ||
                    conRec.buildertek__Weekly_Overtime_Premium__c != oldconRec.buildertek__Weekly_Overtime_Premium__c ||
                    conRec.buildertek__Hours_Worked_This_Week__c != oldconRec.buildertek__Hours_Worked_This_Week__c) {                       
                        if(conRec.Id != null){
                            hourlyRateMap.put(conRec.Id, conRec.buildertek__Hourly_Rate__c);
                        }
                }
            }
    
            if (!hourlyRateMap.isEmpty()) {
                List<buildertek__Time_Cards__c> timeCardsToUpdate = new List<buildertek__Time_Cards__c>();

                List<buildertek__Time_Cards__c>  getAllTimeCards = [SELECT Id, buildertek__Hourly_Rate__c, buildertek__Resource__c FROM buildertek__Time_Cards__c WHERE buildertek__Resource__c IN :hourlyRateMap.keySet()];

                for (buildertek__Time_Cards__c timeCard : getAllTimeCards) {
                    timeCard.buildertek__Hourly_Rate__c = hourlyRateMap.get(timeCard.buildertek__Resource__c);
                    timeCardsToUpdate.add(timeCard);
                }

                if (!timeCardsToUpdate.isEmpty()) {
                    update timeCardsToUpdate;
                }
            }
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
    
            List<buildertek__Exception_Log_Store_Option__c> storeExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            
            if (!storeExcCustomSetting.isEmpty() && storeExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
        }
    }    
}