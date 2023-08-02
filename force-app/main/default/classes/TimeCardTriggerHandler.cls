/*
Developed By: laxman
Date:  26-oct-2018
*/

public class TimeCardTriggerHandler{
    //Boolean variable to allow skipping execution of trigger in certain scenarios
     public static Boolean blnSkipTrigger = false;
    public static Boolean blnSkipTimecardTrigger = false;
    private boolean m_isExecuting = false;
    private integer BatchSize = 0;
    public TimeCardTriggerHandler(boolean isExecuting, integer size){
        m_isExecuting = isExecuting;
        BatchSize = size;
    }
    
    /* public void OnBeforeInsert(list<buildertek__Time_Cards__c> newtimecardslist){
list<buildertek__Time_Cards__c> timecardlst = [select id,name,buildertek__End_Time__c,buildertek__Resource__c,createddate from buildertek__Time_Cards__c order by createddate desc limit 1];
if(timecardlst.size() > 0){
if(timecardlst[0].buildertek__End_Time__c == null){
for(buildertek__Time_Cards__c timecard : newtimecardslist){
timecard.adderror('You Need to close your last Time Card before you can create a new one');
}
}
}
}*/
    public void OnBeforeInsert(list<buildertek__Time_Cards__c> newtimecardslist){
        List<Id> owId = New List<Id>();
        //List<Id> proId = New List<Id>();
        for(buildertek__Time_Cards__c tc : newtimecardslist){
            owId.add(tc.OwnerId);
            //proId.add(tc.buildertek__Project__c);
        }
        system.debug('owId--'+owId);
        //system.debug('proId--'+proId);
        list<buildertek__Time_Cards__c> timecardlst = [select id,name,buildertek__Project__c,buildertek__End_Time__c,buildertek__Resource__c,createddate 
                                                       from buildertek__Time_Cards__c 
                                                       Where OwnerId IN: owId /*AND buildertek__Project__c IN: proId*/ AND buildertek__End_Time__c = null order by createddate desc];
        system.debug('timecardlst--'+timecardlst);
        if(timecardlst.size() > 0){
            //if(timecardlst[0].buildertek__End_Time__c == null){
            for(buildertek__Time_Cards__c timecard : newtimecardslist){
                //timecard.adderror('You have an open Time Card for this Project.  Please populate the End Time of that Project.');
                timecard.adderror('You Need to close your last Time Card before you can create a new one');
            }
            //}
        }
    }
    public void beforeInsert(list<buildertek__Time_Cards__c> newtimecardslist){
        string contactId = '';
        decimal contacthourlyrate= 0;
        decimal contactweeklypremium= 0;
        decimal contactovertime= 0;
        List<Contact> contactRec = new List<Contact>();
        User usr = [Select Name
                    From User
                    where Id = :UserInfo.getUserId()];
        contactRec = [select Name, OwnerId,buildertek__Hourly_Rate__c,buildertek__Weekly_Overtime_Premium__c,buildertek__Overtime__c
                      From Contact
                      where Name = :usr.Name];
        if (!contactRec.isEmpty()){
            if (contactRec[0].Name != null){
                contactId = contactRec[0].Id;
            }if (contactRec[0].buildertek__Hourly_Rate__c != null){
                contacthourlyrate = contactRec[0].buildertek__Hourly_Rate__c;
            }if (contactRec[0].buildertek__Weekly_Overtime_Premium__c != null){
                contactweeklypremium = contactRec[0].buildertek__Weekly_Overtime_Premium__c;
            }if (contactRec[0].buildertek__Overtime__c != null){
                contactovertime = contactRec[0].buildertek__Overtime__c;
            }
        }
        list<id> budgetlineids = new list<id>();
        for (buildertek__Time_Cards__c timecard : newtimecardslist){
            system.debug('timecard.buildertek__Budget_Line__c'+timecard.buildertek__Budget_Line__c);
            if(timecard.buildertek__Budget_Line__c != null){
                  budgetlineids.add(timecard.buildertek__Budget_Line__c);              
            }
            if (timecard.buildertek__Resource__c == null && contactId != '' && contactId != null){
                timecard.buildertek__Resource__c = contactId;
                timecard.buildertek__Old_Regular_Hourly_Rate__c =  contacthourlyrate;
                timecard.buildertek__Old_Weekly_Overtime_Hourly_Rate__c =  (1 + contactweeklypremium) * contacthourlyrate;
                timecard.buildertek__Old_Overtime_Hourly_Rate__c = contacthourlyrate + (contactovertime * contacthourlyrate);
            }
            if(timecard.buildertek__Start_Time__c == null){
                timecard.buildertek__Start_Time__c = DateTime.now();
            }
            if(timecard.buildertek__Entry_Date__c == null){
                timecard.buildertek__Entry_Date__c = Date.today();
            }
            if(timecard.buildertek__Regular_Hourly_Rate__c != 0.00){
                timecard.buildertek__Old_Regular_Hourly_Rate__c = timecard.buildertek__Regular_Hourly_Rate__c;
            }
            if(timecard.buildertek__Weekly_Overtime_Hourly_Rate__c != 0.00){
                timecard.buildertek__Old_Weekly_Overtime_Hourly_Rate__c = timecard.buildertek__Weekly_Overtime_Hourly_Rate__c;
            }
            if(timecard.buildertek__Overtime_Hourly_Rate__c != 0.00){
                timecard.buildertek__Old_Overtime_Hourly_Rate__c = timecard.buildertek__Overtime_Hourly_Rate__c;
            }
        }
        
        list<buildertek__Budget_Item__c> budgetlines = [select id,Name,buildertek__Budget__c from buildertek__Budget_Item__c where id IN : budgetlineids];
        for(buildertek__Budget_Item__c budgetRec : budgetlines){
            for(buildertek__Time_Cards__c exp : newtimecardslist){
                exp.buildertek__Budget__c  = budgetRec.buildertek__Budget__c;
                system.debug(' exp.buildertek__Budget__c'+ exp.buildertek__Budget__c);
            }
        }
        
    }
    
    public void afterInsert(List<buildertek__Time_Cards__c> newTimeCard, Map<Id, buildertek__Time_Cards__c> timeCardMap){
        Set<ID> budgetLineId = new Set<ID>();
        string RegularHourlyRate = '';
        List<buildertek__Budget_Item__c> budgetItemLines = new List<buildertek__Budget_Item__c>();
        for (buildertek__Time_Cards__c timecard : newTimeCard){
            budgetLineId.add(timeCard.buildertek__Budget_Line__c);
        }
        if (budgetLineId.size() > 0){
            budgetItemLines = [Select Id, Name, buildertek__Labor__c, (Select Id, buildertek__Daily_Expense__c
                                                                       FROM buildertek__Time_Cards__r)
                               FROM buildertek__Budget_Item__c
                               WHERE Id IN :budgetLineId];
        }
        for (buildertek__Budget_Item__c budgetItemLine : budgetItemLines){
            Double val = 0;
            for (buildertek__Time_Cards__c timecard : budgetItemLine.buildertek__Time_Cards__r){
                val += timecard.buildertek__Daily_Expense__c;
            }
            budgetItemLine.buildertek__Labor__c = val;
        }
        update budgetItemLines;
    }
    
    public void afterUpdate(List<buildertek__Time_Cards__c> oldTimeCard, List<buildertek__Time_Cards__c> newTimeCard, Map<Id, buildertek__Time_Cards__c> oldTimeCardMap, Map<Id, buildertek__Time_Cards__c> newTimeCardMap){
        Set<ID> budgetLineId = new Set<ID>();
        List<buildertek__Time_Cards__c> timecardList= new List<buildertek__Time_Cards__c>();
        List<buildertek__Time_Cards__c> timeCardWOBL= new List<buildertek__Time_Cards__c>();
        List<buildertek__Time_Cards__c> timecardWithBudandBudL= new List<buildertek__Time_Cards__c>();



        List<buildertek__Budget_Item__c> newBudgetLineList= new List<buildertek__Budget_Item__c>();

        List<buildertek__Budget_Item__c> budgetItemLines = new List<buildertek__Budget_Item__c>();
        for (buildertek__Time_Cards__c timecard : newTimeCard){
            budgetLineId.add(timeCard.buildertek__Budget_Line__c);

            if(oldTimeCardMap.get(timecard.Id).buildertek__Budget__c != timecard.buildertek__Budget__c && timecard.buildertek__Budget__c!= null && timecard.buildertek__Budget_Line__c == null ){
                timecardList.add(timecard);
            }
            if(oldTimeCardMap.get(timecard.Id).buildertek__Budget_Line__c != null && timecard.buildertek__Budget_Line__c == null){
                System.debug('yes ! Budget line is equal to nullllll!!!!!!');
                timeCardWOBL.add(timecard);
            }

            if(timecard.buildertek__Budget__c != null && timecard.buildertek__Budget_Line__c != null){
                timecardWithBudandBudL.add(timecard);
            }

        }
        if(timecardList.size() > 0){
            for(buildertek__Time_Cards__c timeCard : timecardList){
                CreateBudgetLineItemForTimeCard.updateBudgetItem(timeCard.Id); 
            }
        }

        System.debug('timeCardWOBL' + timeCardWOBL.size());
        if(!blnSkipTrigger && timeCardWOBL.size() > 0){
            for(buildertek__Time_Cards__c timeCard : timeCardWOBL){
                CreateBudgetLineItemForTimeCard.deleteBudgetItem(timeCard.Id, oldTimeCardMap.get(timeCard.Id).buildertek__Budget_Line__c);
                System.debug('after delte method!!!');
            }
        }

        if(timecardWithBudandBudL.size() > 0){
            for(buildertek__Time_Cards__c timeCard : timecardWithBudandBudL){
                CreateBudgetLineItemForTimeCard.updateIt(timeCard.Id ,timeCard.buildertek__Budget__c , timecard.buildertek__Budget_Line__c);
            }
        }



        if (budgetLineId.size() > 0){
            budgetItemLines = [Select Id, Name, buildertek__Labor__c, (Select Id, buildertek__Daily_Expense__c
                                                                       FROM buildertek__Time_Cards__r)
                               FROM buildertek__Budget_Item__c
                               WHERE Id IN :budgetLineId];
        }
        for (buildertek__Budget_Item__c budgetItemLine : budgetItemLines){
            Double val = 0;
            for (buildertek__Time_Cards__c timecard : budgetItemLine.buildertek__Time_Cards__r){
                val += timecard.buildertek__Daily_Expense__c;
            }
            budgetItemLine.buildertek__Labor__c = val;
        }
        update budgetItemLines;
        
        budgetLineId = new Set<ID>();
        budgetItemLines = new List<buildertek__Budget_Item__c>();
        for (buildertek__Time_Cards__c timecard : oldTimeCard){
            if (timecard.buildertek__Budget_Line__c != newTimeCardMap.get(timecard.Id).buildertek__Budget_Line__c){
                budgetLineId.add(timeCard.buildertek__Budget_Line__c);
            }
        }
        if (budgetLineId.size() > 0){
            budgetItemLines = [Select Id, Name, buildertek__Labor__c, (Select Id, buildertek__Daily_Expense__c
                                                                       FROM buildertek__Time_Cards__r)
                               FROM buildertek__Budget_Item__c
                               WHERE Id IN :budgetLineId];
        }
        for (buildertek__Budget_Item__c budgetItemLine : budgetItemLines){
            Double val = 0;
            for (buildertek__Time_Cards__c timecard : budgetItemLine.buildertek__Time_Cards__r){
                val += timecard.buildertek__Daily_Expense__c;
            }
            budgetItemLine.buildertek__Labor__c = val;
        }
        update budgetItemLines;


         // Just remove etra budget from Time Card 
         List<buildertek__Time_Cards__c> newUpdatedTimeCard = [SELECT Id, Name, buildertek__Budget__c, buildertek__Budget_Line__c FROM buildertek__Time_Cards__c WHERE Id IN: newTimeCardMap.keySet() AND buildertek__Budget__c != null AND buildertek__Budget_Line__c = null];
         List<buildertek__Time_Cards__c> newUpdatedTimeCardList = new List<buildertek__Time_Cards__c>();
         for (buildertek__Time_Cards__c timeCard : newUpdatedTimeCard) {
             if (oldTimeCardMap.get(timeCard.Id).buildertek__Budget_Line__c != null) {
                timeCard.buildertek__Budget__c = null;
                newUpdatedTimeCardList.add(timeCard);
             }
         }
         if (newUpdatedTimeCardList.size() > 0) {
             update newUpdatedTimeCardList;
         }
        
        //date weekStartDate;
        //date weekEndDate;
       /* Set<Id> ContactId = new Set<Id>();
        List<Contact> con = new List<Contact>();
        Set<String> timecardid = new Set<String>();
        List<String> dayNames = new List<String>();
        dayNames.add('Sunday');
        dayNames.add('Monday');
        dayNames.add('Tuesday');
        dayNames.add('Wednesday');
        dayNames.add('Thursday');
        dayNames.add('Friday');
        dayNames.add('Saturday');
        
        list<buildertek__Time_Cards__c> timecards = new List<buildertek__Time_Cards__c>();
        for (buildertek__Time_Cards__c timecard : newTimeCard){
            timecardid.add(timecard.buildertek__Resource__c);
        } 
        con = [Select Id, Name,buildertek__Weekly_Overtime_Premium__c, buildertek__Weekly__c,buildertek__Hourly_Rate__c, (Select Id,buildertek__Resource__c,buildertek__Resource__r.buildertek__Weekly__c,buildertek__Resource__r.buildertek__Hourly_Rate__c,
                                                        buildertek__Resource__r.buildertek__Weekly_Overtime_Premium__c,buildertek__Hours_Worked__c,buildertek__Start_Time__c FROM buildertek__Time_Cards__r)
               FROM Contact WHERE Id IN :timecardid];
        
        Map<String,List<buildertek__Time_Cards__c>> contactTimeCardMap = new Map<String,List<buildertek__Time_Cards__c>>();
        for(Contact conRec: con){
            contactTimeCardMap.put(conRec.Id, conRec.buildertek__Time_Cards__r);
        }
        system.debug(contactTimeCardMap.keySet());
        
        List<buildertek__Time_Cards__c> updateTimeCardList = new List<buildertek__Time_Cards__c>();
        
        for (buildertek__Time_Cards__c timecard : newTimeCard){
             List<buildertek__Time_Cards__c> timeCardsForContact = new List<buildertek__Time_Cards__c>();
            
            //if contact has weekly threshold then only calculation will execute
            if(timecard.buildertek__Resource__r.buildertek__Weekly__c != null && (timecard.buildertek__Resource__r.buildertek__Daily_Over_Time_Threshold__c == null || timecard.buildertek__Resource__r.buildertek__Daily_Over_Time_Threshold__c == 0)){
                system.debug('176-->'+'only weekly threshold');
                timeCardsForContact = contactTimeCardMap.get(timecard.buildertek__Resource__c);
                Date timeCardStDate=(timeCard.buildertek__Start_Time__c == null) ? null : timeCard.buildertek__Start_Time__c.date(); 
                system.debug(timeCardStDate);
                DateTime currDate = DateTime.newInstance(timeCardStDate.year(), timeCardStDate.month(), timeCardStDate.day()); 
                system.debug(currDate);
                String todayDay = currDate.format('EEEE');
                system.debug(todayDay);
                DateTime weekStartDate = DateTime.newInstance(timeCardStDate.year(), timeCardStDate.month(), timeCardStDate.day()- dayNames.indexOf(todayDay));
                system.debug(weekStartDate);
                DateTime weekEndDate = DateTime.newInstance(timeCardStDate.year(), timeCardStDate.month(), timeCardStDate.day()+6- dayNames.indexOf(todayDay));
                system.debug(weekEndDate);
                Double sum = 0;
                List<buildertek__Time_Cards__c> currentWeekTimeCards  = new List<buildertek__Time_Cards__c>();
                for(buildertek__Time_Cards__c weekTimeCard : timeCardsForContact){
                    if(weekTimeCard.buildertek__Resource__r.buildertek__Weekly__c != null && weekTimeCard.buildertek__Resource__r.buildertek__Daily_Over_Time_Threshold__c == null){
                        if(weekTimeCard.buildertek__Start_Time__c <= weekEndDate && weekTimeCard.buildertek__Start_Time__c >= weekStartDate){
                            currentWeekTimeCards.add(weekTimeCard);
                            system.debug(weekTimeCard);
                            sum += weekTimeCard.buildertek__Hours_Worked__c != null ? weekTimeCard.buildertek__Hours_Worked__c : 0 ;
                            if(sum > weekTimeCard.buildertek__Resource__r.buildertek__Weekly__c){
                                if(weekTimeCard.buildertek__Resource__r.buildertek__Hourly_Rate__c != null){
                                    system.debug((weekTimeCard.buildertek__Resource__r.buildertek__Hourly_Rate__c + ((weekTimeCard.buildertek__Resource__r.buildertek__Weekly_Overtime_Premium__c)*weekTimeCard.buildertek__Resource__r.buildertek__Hourly_Rate__c))*(sum - weekTimeCard.buildertek__Resource__r.buildertek__Weekly__c));
                                    //system.debug(weekTimeCard.buildertek__Resource__r.buildertek__Hourly_Rate__c*((100+weekTimeCard.buildertek__Resource__r.buildertek__Weekly_Overtime_Premium__c)/100)*(sum - weekTimeCard.buildertek__Resource__r.buildertek__Weekly__c));//*(extra hours worked)
                                    updateTimeCardList.add(weekTimeCard);
                                    system.debug(weekTimeCard);
                                }
                                
                            }else{
                                if(weekTimeCard.buildertek__Hours_Worked__c != null){
                                    system.debug(weekTimeCard.buildertek__Hours_Worked__c);
                                    system.debug(weekTimeCard.buildertek__Resource__r.buildertek__Hourly_Rate__c);
                                    if(weekTimeCard.buildertek__Resource__r.buildertek__Hourly_Rate__c != null){
                                        system.debug(weekTimeCard.buildertek__Resource__r.buildertek__Hourly_Rate__c*weekTimeCard.buildertek__Hours_Worked__c);
                                    }
                                    
                                }
                                
                            }
                            system.debug(sum);
                        }
                    }
                }
                system.debug(currentWeekTimeCards.Size());
                system.debug(currentWeekTimeCards);
                system.debug(updateTimeCardList); 
            }else{
                system.debug('223--> no weekly threshold or has value for daily threshold');
            }
            
        }*/
        
    }
    public void onafterUpdate(List<buildertek__Time_Cards__c> newTimeCard,Map<Id, buildertek__Time_Cards__c> oldTimeCardMap){
        list<Id> expenseids = new list<Id>();
        list<Id> expenseprojectids = new list<Id>();
        list<Id> projectids = new list<Id>();
        list<Id> budgetids = new list<Id>();
        list<Id> expids = new list<Id>();
        string BudgetId = '';
        list<buildertek__Admin_Interface_Node_Configuration__c> adminInterfaceNodeConfigurations = [Select Id,
                                                                                                    buildertek__Automatically_add_Expense_to_Budget__c,
                                                                                                    buildertek__Automatically_add_Time_Card_to_Budget__c
                                                                                                    from buildertek__Admin_Interface_Node_Configuration__c
                                                                                                    WHERE Name=:'Budget Configuration' and buildertek__Automatically_add_Time_Card_to_Budget__c !=false limit 1];
        if(adminInterfaceNodeConfigurations.size()>0 ){
            if(adminInterfaceNodeConfigurations[0].buildertek__Automatically_add_Time_Card_to_Budget__c == true){
                for(buildertek__Time_Cards__c exprec : newTimeCard){
                    system.debug('hii'+oldTimeCardMap.get(exprec.Id).buildertek__End_Time__c);
                    if(exprec.buildertek__Project__c != null && exprec.buildertek__Daily_Expense__c != null && exprec.buildertek__End_Time__c != null
                       && oldTimeCardMap.get(exprec.Id).buildertek__Daily_Expense__c == 0 && oldTimeCardMap.get(exprec.Id).buildertek__End_Time__c == null){
                           expenseprojectids.add(exprec.buildertek__Project__c);
                           expenseids.add(exprec.id);
                       }else if(exprec.buildertek__Daily_Expense__c != null && exprec.buildertek__End_Time__c != null && oldTimeCardMap.get(exprec.Id).buildertek__Daily_Expense__c == 0
                                && oldTimeCardMap.get(exprec.Id).buildertek__End_Time__c == null){
                                    expids.add(exprec.id); 
                                }
                } 
                if(expenseprojectids.size()>0){
                    list<buildertek__Budget__c> budgetist = [select id,Name from buildertek__Budget__c where buildertek__Project__c =: expenseprojectids ORDER BY CreatedDate ASC limit 1];
                    list<buildertek__Time_Cards__c> expList = [select id,Name from buildertek__Time_Cards__c Where ID IN: expenseids];
                    for(buildertek__Budget__c budgetRec : budgetist){
                        for(buildertek__Time_Cards__c exp : expList){
                            BudgetId  = budgetRec.id;
                            budgetids.add(budgetRec.id);
                            system.debug('budgetids'+budgetids);
                             system.debug('exp.id'+exp.id);
                            createBudgetlineitemForTimeCard_AC.createBudgetLinerecs(budgetids,exp.id);                  
                        }
                    }
                }
                if(expids.size()>0){
                    list<buildertek__Budget__c> budgetist = [select id,Name from buildertek__Budget__c ORDER BY CreatedDate ASC limit 1];
                    list<buildertek__Time_Cards__c> expList = [select id,Name from buildertek__Time_Cards__c Where Id IN: expids];
                    for(buildertek__Time_Cards__c exp : expList){
                        for(buildertek__Budget__c budgetRec : budgetist){
                            BudgetId  = budgetRec.id;
                            budgetids.add(budgetRec.id);
                            createBudgetlineitemForTimeCard_AC.createBudgetLinerecs(budgetids,exp.id);                  
                        }
                    }
                }
            }
        }
    }
    
    public void afterDelete(List<buildertek__Time_Cards__c> timeCardList, Map<Id, buildertek__Time_Cards__c> timeCardMap){
        Set<ID> budgetLineId = new Set<ID>();
        List<buildertek__Budget_Item__c> budgetItemLines = new List<buildertek__Budget_Item__c>();
        for (buildertek__Time_Cards__c timecard : timeCardList){
            budgetLineId.add(timeCard.buildertek__Budget_Line__c);
        }
        if (budgetLineId.size() > 0){
            budgetItemLines = [Select Id, Name, buildertek__Labor__c, (Select Id, buildertek__Daily_Expense__c
                                                                       FROM buildertek__Time_Cards__r)
                               FROM buildertek__Budget_Item__c
                               WHERE Id IN :budgetLineId];
        }
        for (buildertek__Budget_Item__c budgetItemLine : budgetItemLines){
            Double val = 0;
            for (buildertek__Time_Cards__c timecard : budgetItemLine.buildertek__Time_Cards__r){
                val += timecard.buildertek__Daily_Expense__c;
            }
            budgetItemLine.buildertek__Labor__c = val;
        }
        update budgetItemLines;
    }
    public void onbeforeUpdate(buildertek__Time_Cards__c[] oldtimecards, buildertek__Time_Cards__c[] updatedtimecards, Map<ID, buildertek__Time_Cards__c> timecardsMap){
    list<id> budgetlineids = new list<id>();
        for (buildertek__Time_Cards__c timecard : updatedtimecards){
            if(timecard.buildertek__Budget_Line__c != null && timecardsMap.get(timecard.Id).buildertek__Budget_Line__c  != timecard.buildertek__Budget_Line__c){
                      budgetlineids.add(timecard.buildertek__Budget_Line__c);              
                }
            if (timecard.buildertek__Project__c != null && timecardsMap.get(timecard.Id).buildertek__Project__c != timecard.buildertek__Project__c &&
                timecardsMap.get(timecard.Id).buildertek__Previous_Project__c == null
                /*&& timecardsMap.get(timecard.Id).buildertek__Project__c == null*/){
                     //timecardsMap.get(timecard.Id).buildertek__Previous_Project__c == timecard.buildertek__Project__c
                timecard.buildertek__Previous_Project__c = timecardsMap.get(timecard.Id).buildertek__Project__c;
                timecard.buildertek__Project_Changed__c = true;
            }
        }
        list<buildertek__Budget_Item__c> budgetlines = [select id,Name,buildertek__Budget__c from buildertek__Budget_Item__c where id IN : budgetlineids];
        for(buildertek__Budget_Item__c budgetRec : budgetlines){
            for(buildertek__Time_Cards__c timecard: updatedtimecards){
                timecard.buildertek__Budget__c  = budgetRec.buildertek__Budget__c;
                system.debug(' timecard.buildertek__Budget__c'+ timecard.buildertek__Budget__c);
            }
        }
         checkRecursion.setAlredyRun();
    }
    public void contactupdate(List<buildertek__Time_Cards__c> timeCardList){
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
                        DateTime currDate;
         String todayDay;
        DateTime weekStartDate;
        DateTime weekEndDate;
        for (buildertek__Time_Cards__c timecard : timeCardList){
            if(timecard.buildertek__Resource__c != null){
                 currDate = DateTime.newInstance(timecard.buildertek__Start_Time__c.year(), timecard.buildertek__Start_Time__c.month(), timecard.buildertek__Start_Time__c.day()); 
                 todayDay = currDate.format('EEEE');
                 weekStartDate = DateTime.newInstance(currDate.year(), currDate.month(), currDate.day()- dayNames.indexOf(todayDay));
                 weekEndDate = DateTime.newInstance(currDate.year(), currDate.month(), currDate.day()+6- dayNames.indexOf(todayDay));
                contactLineId.add(timeCard.buildertek__Resource__c);
            }
        }
        if (contactLineId.size() > 0){
            contactlist = [Select Id, Name,buildertek__Hours_Worked_This_Week__c,buildertek__Weekly__c, (Select Id,Name,buildertek__Weekly_OT__c,buildertek__Daily_Expense__c,buildertek__Start_Time__c,buildertek__Hours_Worked__c,buildertek__Weekly_Overtime__c,
                                                                buildertek__Total_Break_Time__c FROM buildertek__Time_Cards__r)
                               FROM Contact
                               WHERE Id IN :contactLineId];
        }
        list<id> tclist = new list<id>();
        Map<Id,decimal> timecardmap = new Map<Id,decimal>();
        Map<Id,decimal> timecardmap1 = new Map<Id,decimal>();
        for (Contact conRec : contactlist){
            Double val = 0;
            Double val1 = 0;
            Double val2 = 0;
           Decimal totalhours = 0;
           Integer k = 0;
          //  for (Integer i = 0; i < conRec.buildertek__Time_Cards__r.size(); i++){  
                          //  conRec.buildertek__Time_Cards__r[i].Id = rfqToVendorItemMap.get(i);
                      //  }
            for (buildertek__Time_Cards__c timecard : conRec.buildertek__Time_Cards__r){
                /*date myDate = date.today();
                DateTime currDate = DateTime.newInstance(myDate.year(), myDate.month(), myDate.day()); 
                String todayDay = currDate.format('EEEE');
                DateTime weekStartDate = DateTime.newInstance(currDate.year(), currDate.month(), currDate.day()- dayNames.indexOf(todayDay));
                DateTime weekEndDate = DateTime.newInstance(currDate.year(), currDate.month(), currDate.day()+6- dayNames.indexOf(todayDay));*/
                date myDate1 = date.today();
                DateTime currDate1 = DateTime.newInstance(myDate1.year(), myDate1.month(), myDate1.day()); 
                String todayDay1 = currDate1.format('EEEE');
                DateTime weekStartDate1 = DateTime.newInstance(currDate1.year(), currDate1.month(), currDate1.day()- dayNames.indexOf(todayDay1));
                DateTime weekEndDate1 = DateTime.newInstance(currDate1.year(), currDate1.month(), currDate1.day()+6- dayNames.indexOf(todayDay1));
                if(timecard.buildertek__Start_Time__c <= weekEndDate && timecard.buildertek__Start_Time__c >= weekStartDate){
                     if(timecard.buildertek__Start_Time__c <= weekEndDate1 && timecard.buildertek__Start_Time__c >= weekStartDate1){
                          if(timecard.buildertek__Total_Break_Time__c != null && timecard.buildertek__Hours_Worked__c != null){
                        totalhours =  timecard.buildertek__Hours_Worked__c - timecard.buildertek__Total_Break_Time__c;  
                    }else if(timecard.buildertek__Total_Break_Time__c == null && timecard.buildertek__Hours_Worked__c != null){
                        totalhours =  timecard.buildertek__Hours_Worked__c;
                    }else if(timecard.buildertek__Hours_Worked__c == null && timecard.buildertek__Total_Break_Time__c != null){
                        totalhours = totalhours - timecard.buildertek__Total_Break_Time__c ;
                    }else{
                        totalhours = 0; 
                    }
                    Decimal weeklyot = 0;
                    val += totalhours;
                    if(conRec.buildertek__Weekly__c != null){
                    if(val <= conRec.buildertek__Weekly__c){
                        if(timecard.buildertek__Weekly_OT__c != null){
                            timecardmap.put(timecard.id,0);
                        }
                     }else{
                         weeklyot  = val - conRec.buildertek__Weekly__c;
                         if(k >0){
                             if(conRec.buildertek__Time_Cards__r[k-1].buildertek__Weekly_OT__c != null && conRec.buildertek__Time_Cards__r[k-1].buildertek__Weekly_OT__c !=0){
                                 weeklyot  = totalhours;
                             }
                         }
                         timecardmap.put(timecard.id,weeklyot);
                     }
                     k++;
                    }
                    conRec.buildertek__Hours_Worked_This_Week__c = val;
                     }else{
                    if(timecard.buildertek__Total_Break_Time__c != null && timecard.buildertek__Hours_Worked__c != null){
                        totalhours =  timecard.buildertek__Hours_Worked__c - timecard.buildertek__Total_Break_Time__c;  
                    }else if(timecard.buildertek__Total_Break_Time__c == null && timecard.buildertek__Hours_Worked__c != null){
                        totalhours =  timecard.buildertek__Hours_Worked__c;
                    }else if(timecard.buildertek__Hours_Worked__c == null && timecard.buildertek__Total_Break_Time__c != null){
                        totalhours = totalhours - timecard.buildertek__Total_Break_Time__c ;
                    }else{
                        totalhours = 0; 
                    }
                    Decimal weeklyot = 0;
                    system.debug('totalhours'+totalhours);
                    val += totalhours;
                    if(conRec.buildertek__Weekly__c != null){
                        //system.debug('val'+val);
                       // system.debug('conRec.buildertek__Weekly__c'+conRec.buildertek__Weekly__c);
                    if(val <= conRec.buildertek__Weekly__c){
                        if(timecard.buildertek__Weekly_OT__c != null){
                            system.debug('val'+val);
                            system.debug('conRec.buildertek__Weekly__c'+conRec.buildertek__Weekly__c);
                            timecardmap.put(timecard.id,0);
                        }
                     }else{
                         weeklyot  = val - conRec.buildertek__Weekly__c;
                         system.debug('timecard.buildertek__Weekly_OT__c'+timecard.buildertek__Weekly_OT__c);
                         if(k >0){
                             if(conRec.buildertek__Time_Cards__r[k-1].buildertek__Weekly_OT__c != null && conRec.buildertek__Time_Cards__r[k-1].buildertek__Weekly_OT__c !=0){
                                 weeklyot  = totalhours;
                                  system.debug('timecard'+weeklyot);
                             }
                         }
                         timecardmap.put(timecard.id,weeklyot);
                        // futureContoller.updatetimecardlist(timecard.id,weeklyot);
                     }
                     k++;
                    }
                   }  
                }
                /*else{
                    System.debug('^^^^^***@#$%^&&*(*@))*&())*&&');
                    System.debug('^^^^^***'+timecard.Id+'@@@@@$$$$$'+timecard.Name);
                }*/
               }
            
        }
        update contactlist;
        futureContoller.updatetimecardlist(timecardmap);
    }
    

}