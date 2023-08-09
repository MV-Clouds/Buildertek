global class contactTimecard_Batch implements Database.Batchable<sObject>,Database.Stateful {
    public list <string> timecardid;
    global contactTimecard_Batch (list<buildertek__Time_Cards__c> timecardlist) {
        timecardid = new list<string>();
        system.debug('hi'+timecardlist);
        for(buildertek__Time_Cards__c warnty : timecardlist){
            timecardid.add(warnty.id);   
            system.debug('h1677');
        }
    }
    //Query method.
    global Database.QueryLocator start(Database.BatchableContext BC) {
        String Query = 'SELECT id,name,buildertek__Description__c,buildertek__Complete__c,buildertek__Total_Break_Time__c,buildertek__Schedule_Item__c,buildertek__Project__c,buildertek__Resource__c,buildertek__Budget__c,buildertek__Budget_Line__c,buildertek__Details__c,buildertek__End_Time__c,buildertek__Start_Time__c,buildertek__Entry_Date__c,buildertek__Old_Weekly_Overtime_Hourly_Rate__c,buildertek__Old_Regular_Hourly_Rate__c,buildertek__Old_Overtime_Hourly_Rate__c,buildertek__Project_Changed__c from buildertek__Time_Cards__c  WHERE id IN: timecardid';
        system.debug('Query'+Query);
        return DataBase.getQueryLocator(Query);        
    }
    //Execute Method.
    global void execute(Database.BatchableContext BC,List<buildertek__Time_Cards__c> timeCardList) {
        List<String> dayNames = new List<String>();
        dayNames.add('Sunday');
        dayNames.add('Monday');
        dayNames.add('Tuesday');
        dayNames.add('Wednesday');
        dayNames.add('Thursday');
        dayNames.add('Friday');
        dayNames.add('Saturday');
        List<Contact> contactlist = new List<Contact>();
        List<Id> contactLineId = new List<Id>();
        for (buildertek__Time_Cards__c timecard : timeCardList){
            if(timecard.buildertek__Resource__c != null){
                contactLineId.add(timeCard.buildertek__Resource__c);
            }
        }
        if (contactLineId.size() > 0){
            contactlist = [Select Id, Name,buildertek__Hours_Worked_This_Week__c, (Select Id, buildertek__Daily_Expense__c,buildertek__Start_Time__c,buildertek__Hours_Worked__c,
                                                                buildertek__Total_Break_Time__c FROM buildertek__Time_Cards__r)
                               FROM Contact
                               WHERE Id IN :contactLineId];
            system.debug('&&&'+contactlist.size());
        }
        for (Contact conRec : contactlist){
            Double val = 0;
            for (buildertek__Time_Cards__c timecard : conRec.buildertek__Time_Cards__r){
                 system.debug('timeCardStDate');
               /* Date timeCardStDate=(timeCard.buildertek__Start_Time__c == null) ? null : timeCard.buildertek__Start_Time__c.date(); 
                system.debug('timeCardStDate'+timeCardStDate);
                date myDate = date.today();
                DateTime currDate = DateTime.newInstance(timeCardStDate.year(), timeCardStDate.month(), timeCardStDate.day()); 
                String todayDay = currDate.format('EEEE');
                DateTime weekStartDate = DateTime.newInstance(timeCardStDate.year(), timeCardStDate.month(), timeCardStDate.day()- dayNames.indexOf(todayDay));
                //system.debug('weekStartDate'+weekStartDate);
                DateTime weekEndDate = DateTime.newInstance(timeCardStDate.year(), timeCardStDate.month(), timeCardStDate.day()+6- dayNames.indexOf(todayDay));
                system.debug('weekEndDate'+weekEndDate);*/
                
                date myDate = date.today();
                DateTime currDate = DateTime.newInstance(myDate.year(), myDate.month(), myDate.day()); 
                String todayDay = currDate.format('EEEE');
                DateTime weekStartDate = DateTime.newInstance(currDate.year(), currDate.month(), currDate.day()- dayNames.indexOf(todayDay));
                system.debug('weekStartDate'+weekStartDate);
                DateTime weekEndDate = DateTime.newInstance(currDate.year(), currDate.month(), currDate.day()+6- dayNames.indexOf(todayDay));
                system.debug('weekEndDate'+weekEndDate);
                
               /* system.debug(myDate);
                date weekStart = myDate.toStartofWeek();
                system.debug(weekStart);
                system.debug(weekStart.addDays(7) );*/
                
                if(timeCard.buildertek__Start_Time__c <= weekEndDate && timeCard.buildertek__Start_Time__c >= weekStartDate){
                    system.debug('timeCard.buildertek__Total_Break_Time__c'+timeCard.buildertek__Total_Break_Time__c);
                    Decimal totalhours = 0;
                    if(timeCard.buildertek__Total_Break_Time__c != null && timeCard.buildertek__Hours_Worked__c != null){
                        totalhours =  timeCard.buildertek__Hours_Worked__c - timeCard.buildertek__Total_Break_Time__c;  
                    }else if(timeCard.buildertek__Total_Break_Time__c == null && timeCard.buildertek__Hours_Worked__c != null){
                        totalhours =  timeCard.buildertek__Hours_Worked__c;
                    }else if(timeCard.buildertek__Hours_Worked__c == null && timeCard.buildertek__Total_Break_Time__c != null){
                        totalhours = - timeCard.buildertek__Total_Break_Time__c ;
                    }else{
                        totalhours = 0; 
                    }
                    system.debug('totalhours'+totalhours);
                    val += totalhours;
                }
            }
            system.debug('val'+val);
            conRec.buildertek__Hours_Worked_This_Week__c = val;
        }
        update contactlist;
    }
    //finish method
    global void finish(Database.BatchableContext BC) {
        
    }
}