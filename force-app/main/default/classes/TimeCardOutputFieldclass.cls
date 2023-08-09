public with sharing class TimeCardOutputFieldclass {
    
    public static string SYSADMIN_PROFILENAME = 'System Administrator';
    @AuraEnabled
    public static boolean getowner(string recId){
        buildertek__Time_Cards__c timecardRec = [SELECT Id, Name, OwnerId FROM buildertek__Time_Cards__c WHERE Id =:recId];
        List<Profile> profileDetails = [SELECT Name, PermissionsModifyAllData FROM Profile WHERE Id =: Userinfo.getProfileId()];
        system.debug('timecardRec.OwnerId'+timecardRec.OwnerId);
        system.debug('userinfo.getUserId()'+userinfo.getUserId());
        if(!profileDetails.isEmpty()){
            if(timecardRec.OwnerId == userinfo.getUserId() || profileDetails[0].Name == SYSADMIN_PROFILENAME){
                return true;
            }
            else{
                return false;
            }
        }
        else{
            return false;
        }
    }
    @AuraEnabled
    public static buildertek__Time_Cards__c gettimecardRec(string recId){
        buildertek__Time_Cards__c timecardRec = [SELECT Id, Name, OwnerId,buildertek__Previous_Project__c,buildertek__Project__c,buildertek__Project_Changed__c,buildertek__Budget__c
                                                 FROM buildertek__Time_Cards__c WHERE Id =:recId];
        return timecardRec;
    }
    @AuraEnabled
    public static string updatetimecardRecforcancel(string recId,string oldproject){
        buildertek__Time_Cards__c timecardRec = [SELECT Id, Name, OwnerId,buildertek__Previous_Project__c,buildertek__Daily_Expense__c,buildertek__Project__c,buildertek__Project_Changed__c,buildertek__Budget__c
                                                 FROM buildertek__Time_Cards__c WHERE Id =:recId];
        system.debug(timecardRec);
        if(oldproject == 'setoldproject' ){
            timecardRec.buildertek__Project__c = timecardRec.buildertek__Previous_Project__c;
            timecardRec.buildertek__Previous_Project__c= null;
            timecardRec.buildertek__Project_Changed__c= false;
            update timecardRec;
            return 'nobudgetlist';
        }
        return null;
    }
    @AuraEnabled
    public static string updatetimecardRec(string recId){
      /*  buildertek__Time_Cards__c timecardRec = [SELECT Id, Name, OwnerId,buildertek__Previous_Project__c,buildertek__Project__c,buildertek__Project_Changed__c,buildertek__Budget__c
                                                 FROM buildertek__Time_Cards__c WHERE Id =:recId];
        timecardRec.buildertek__Project_Changed__c = false;
        //timecardRec.buildertek__Project__c = timecardRec.buildertek__Previous_Project__c;
        update timecardRec;
        return timecardRec;*/
         buildertek__Time_Cards__c timecardRec = [SELECT Id, Name, OwnerId,buildertek__Previous_Project__c,buildertek__Daily_Expense__c,buildertek__Project__c,buildertek__Project_Changed__c,buildertek__Budget__c
                                                 FROM buildertek__Time_Cards__c WHERE Id =:recId];
        system.debug(timecardRec);
        list<buildertek__Budget__c> budgetlist = [select id,Name,buildertek__Project__c from buildertek__Budget__c where buildertek__Project__c =: timecardRec.buildertek__Project__c ORDER BY CreatedDate Limit 1];
        if(budgetlist.size() == 0){
            timecardRec.buildertek__Project__c = timecardRec.buildertek__Previous_Project__c;
            timecardRec.buildertek__Previous_Project__c= null;
            timecardRec.buildertek__Project_Changed__c= false;
            update timecardRec;
            return 'nobudgetlist';
        }else{ 
            list<buildertek__Budget_Item__c> budgetline = [select id,Name,buildertek__Budget__c from buildertek__Budget_Item__c where buildertek__Budget__c =:budgetlist[0].id ORDER BY CreatedDate limit 1]; 
            if(budgetline.size() == 0){
                timecardRec.buildertek__Project__c = timecardRec.buildertek__Previous_Project__c;
                timecardRec.buildertek__Previous_Project__c= null;
                timecardRec.buildertek__Project_Changed__c= false;
                update timecardRec;
                return 'nobudgetlist';
            }else{
                //val += timecardRec.buildertek__Daily_Expense__c;
                //budgetline[0].buildertek__Labor__c = val;
                //update budgetline[0];
                timecardRec.buildertek__Previous_Project__c= null;
                timecardRec.buildertek__Project_Changed__c= false;
                timecardRec.buildertek__Budget_Line__c = budgetline[0].id;
                timecardRec.buildertek__Budget__c = budgetline[0].buildertek__Budget__c;
                update timecardRec;
                return 'success';
            }           
        }
        //timecardRec.buildertek__Project_Changed__c = false;
        //update timecardRec;
      
       
        
    }

   /* @AuraEnabled
    public static buildertek__Time_Cards__c getfields(String recId){
        List<buildertek__Time_Cards__c> cardRec = [SELECT Id, Name, buildertek__Daily_Expense__c,buildertek__Regular_Hourly_Rate__c,buildertek__Overtime_Hourly_Rate__c,buildertek__Standard_Expense__c,buildertek__Overtime_Expense__c
                                                    FROM buildertek__Time_Cards__c
                                                    WHERE Id = :recId];
                                                    
        
            return cardRec[0];
        
    
    }*/
}