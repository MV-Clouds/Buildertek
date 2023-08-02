public class contacttimecardBatchcontroller {
	public list<buildertek__Time_Cards__c> timecardlst = new list<buildertek__Time_Cards__c>();
    public contacttimecardBatchcontroller(){
    }
    public void  batchjobexcute(){ 
        
        timecardlst = [select id,name,buildertek__Description__c,buildertek__Complete__c,
                       buildertek__Total_Break_Time__c,buildertek__Schedule_Item__c,buildertek__Project__c,
                       buildertek__Resource__c,buildertek__Budget__c,buildertek__Budget_Line__c,
                       buildertek__Details__c,buildertek__End_Time__c,buildertek__Start_Time__c,buildertek__Entry_Date__c,
                       buildertek__Old_Weekly_Overtime_Hourly_Rate__c,buildertek__Old_Regular_Hourly_Rate__c,
                       buildertek__Old_Overtime_Hourly_Rate__c,buildertek__Project_Changed__c
                       from buildertek__Time_Cards__c where buildertek__Resource__c != null];
        contactTimecard_Batch timecardlist =new contactTimecard_Batch(timecardlst);
        database.executebatch(timecardlist,200);
    }
}