public class TaskScheduledashboardController {

      @AuraEnabled
    public static list<TaskdashboardWrap.ProjectTaskRecords> getWeekRecords(string fromDate, string toDate,string slectedTradetypeId,string slectedprojectId,string slectedcontactId,string selectedaccountId, string slippagePicklistvalue){
        system.debug(slippagePicklistvalue +'----slippagePicklistvalue---'+slippagePicklistvalue+'-------slippagePicklistvalue-'+ slippagePicklistvalue);
        system.debug(slectedTradetypeId +'----slectedTradetypeId---'+slectedprojectId+'-------slectedprojectId-'+ slectedcontactId);
        system.debug('===='+fromDate+'======'+toDate);
         Map <Id,list<buildertek__Project_Task__c>> scheduleitemmap = new Map<Id,list<buildertek__Project_Task__c>>();
        Map <Id, string> contactnamemap = new Map<Id,string>();

        list<buildertek__Project_Task__c> schudleitemList = new list<buildertek__Project_Task__c>();
        list<buildertek__Project_Task__c> schduleitems = new list<buildertek__Project_Task__c>();
        list<buildertek__Schedule__c> SchedulerList = new list<buildertek__Schedule__c>();
        list<contact> conresource = new list<contact>();

        system.debug('====' + fromDate + '======' + toDate);


        // date myDate = date.newInstance(1990, 11, 21);
        String str = fromDate;
        List<String> res = str.split('/');
        System.debug(Date.newInstance(Integer.valueOf(res[2]),Integer.valueOf(res[0]),Integer.valueOf(res[1])));

        String str2 = toDate;
        List<String> res2 = str2.split('/');
        System.debug(Date.newInstance(Integer.valueOf(res2[2]),Integer.valueOf(res2[0]),Integer.valueOf(res2[1])));

        date startDate  = Date.newInstance(Integer.valueOf(res[2]),Integer.valueOf(res[0]),Integer.valueOf(res[1]));
        date endDate = Date.newInstance(Integer.valueOf(res2[2]),Integer.valueOf(res2[0]),Integer.valueOf(res2[1]));


        /*date startDate = date.parse(fromDate);
        date endDate = date.parse(toDate);  */
        system.debug('-------startDate'+startDate);
        system.debug('-------endDate'+endDate);
        String dtFormat = 'yyyy-MM-dd\'T\'HH:mm:ss\'Z\'';
        string scheduletype = 'Master';

        list<contact> resources = new list<contact>();
         string Query = 'select id,Name,buildertek__Duration__c,buildertek__Slippage__c,buildertek__Completion__c,buildertek__Schedule__c,buildertek__Dependency__c,buildertek__Contractor_Resource__c,buildertek__Contractor_Resource__r.Name,';
                Query += 'buildertek__Schedule__r.buildertek__Project__c,buildertek__Schedule__r.buildertek__Type__c,buildertek__Schedule__r.buildertek__Project__r.Name,buildertek__Schedule__r.buildertek__Contractor__c,buildertek__Contractor__r.Name,buildertek__Schedule__r.buildertek__Contractor__r.Name,buildertek__Schedule__r.Name,buildertek__Dependency__r.Name,';
                Query += 'buildertek__Resource__r.Name,buildertek__Resource__c,buildertek__Notes__c,buildertek__Start__c,buildertek__Finish__c,buildertek__Trade_Type__c from ';
                Query += 'buildertek__Project_Task__c where buildertek__Milestone__c = false and ';
                Query += 'buildertek__Completion__c != 100 and buildertek__Finish__c < today '; //and (buildertek__Start__c >=:startDate OR buildertek__Finish__c <=: endDate)';
                Query += ' and buildertek__Schedule__r.buildertek__Type__c !=: scheduletype';
                if(slectedprojectId != null && slectedprojectId !=''){
                    Query += ' and buildertek__Schedule__r.buildertek__Project__c=:slectedprojectId';
                }
                 if(slectedTradetypeId != null && slectedTradetypeId !=''){
                    Query += ' and buildertek__Trade_Type__c=:slectedTradetypeId';
                }
                if(slectedcontactId != null && slectedcontactId !=''){
                    Query += ' and buildertek__Contractor_Resource__c=:slectedcontactId';
                }
        if(selectedaccountId != null && selectedaccountId !=''){
            Query += ' and buildertek__Contractor__c=:selectedaccountId';
        }
                if(slippagePicklistvalue != null && slippagePicklistvalue != '' && slippagePicklistvalue != 'None' && slippagePicklistvalue == '1-5'){
                    Query += ' and buildertek__Slippage__c <= 0 and buildertek__Slippage__c >=-5';
                }else if(slippagePicklistvalue != null && slippagePicklistvalue != '' && slippagePicklistvalue != 'None' && slippagePicklistvalue == '5-10'){
                    Query += ' and buildertek__Slippage__c <= -5 and buildertek__Slippage__c >=-10';
                }else if(slippagePicklistvalue != null && slippagePicklistvalue != '' && slippagePicklistvalue != 'None' && slippagePicklistvalue == '11-20'){
                    Query += ' and buildertek__Slippage__c <= -11 and buildertek__Slippage__c >=-20';
                }else if(slippagePicklistvalue != null && slippagePicklistvalue != '' && slippagePicklistvalue != 'None' && slippagePicklistvalue == '21-30'){
                    Query += ' and buildertek__Slippage__c <= -21 and buildertek__Slippage__c >=-30';
                }else if(slippagePicklistvalue != null && slippagePicklistvalue != '' && slippagePicklistvalue != 'None' && slippagePicklistvalue == '31+'){
                    Query += ' and buildertek__Slippage__c <= -31';
                }else if(slippagePicklistvalue != null && slippagePicklistvalue != '' && slippagePicklistvalue != 'None' && slippagePicklistvalue == '50+'){
                    Query += ' and buildertek__Slippage__c <= -50';
                }else if(slippagePicklistvalue != null && slippagePicklistvalue != '' && slippagePicklistvalue != 'None' && slippagePicklistvalue == '100+'){
                    Query += ' and buildertek__Slippage__c <= -100';
                }
                Query += ' order by buildertek__Slippage__c desc';


            schduleitems = Database.query(Query);
system.debug('schduleitems---->'+schduleitems);

       list<TaskdashboardWrap.ProjectTaskRecords> taskRecordList = new list<TaskdashboardWrap.ProjectTaskRecords>();

                                for(buildertek__Project_Task__c pse : schduleitems){
                                       TaskdashboardWrap.ProjectTaskRecords taskRec = new TaskdashboardWrap.ProjectTaskRecords();

                                        Datetime dt = (DateTime)pse.buildertek__Start__c;
                                        String dayOfWeek = dt.format('yyyy-MM-dd');
                                        taskRec.slippage = integer.valueof(pse.buildertek__Slippage__c);
                                        taskRec.title = pse.Name;
                                        taskRec.startString ='';
                                        taskRec.endString = '';
                                        string s = string.valueOfGmt(pse.buildertek__Start__c);
                                        system.debug(pse.buildertek__Start__c);
                                        system.debug(s);
                                        String strDate = s.split(' ')[0];

                                        String sMonth = String.valueof(pse.buildertek__Start__c.month());
                                        String sDay = String.valueof(pse.buildertek__Start__c.day());
                                        if(sMonth.length()==1){
                                          sMonth = '0' + sMonth;
                                        }
                                        if(sDay.length()==1){
                                          sDay = '0' + sDay;
                                        }
                                        string ndate = sMonth+'/'+sDay+'/'+String.valueof(pse.buildertek__Start__c.year());

                                        if(pse.buildertek__Finish__c != null){
                                        string FinishDate = string.valueOfGmt(pse.buildertek__Finish__c);
                                        String FinishDatestrDate = FinishDate.split(' ')[0];
                                        String FinishDatesMonth = String.valueof(pse.buildertek__Finish__c.month());
                                        String FinishDatesDay = String.valueof(pse.buildertek__Finish__c.day());
                                        if(FinishDatesMonth.length()==1){
                                          FinishDatesMonth = '0' + FinishDatesMonth;
                                        }
                                        if(FinishDatesDay.length()==1){
                                          FinishDatesDay = '0' + FinishDatesDay;
                                        }
                                        string FinishDatendate = FinishDatesMonth+'/'+FinishDatesDay+'/'+String.valueof(pse.buildertek__Finish__c.year());
                                        string ndate1 = String.valueof(pse.buildertek__Start__c.year())+'-'+sMonth+'-'+sDay;
                                        Datetime dt1 = DateTime.newInstance(date.valueOf(ndate1), Time.newInstance(0, 0, 0, 0));
                                        String dateStr = dt1.format('EEEE');
                                        taskRec.weekName =dateStr;
                                        system.debug('--dateStr--->'+dateStr);
                                         //system.debug('--dayOfWeek--->'+dayOfWeek);

                                        system.debug('--ndate--->'+ndate1);
                                        taskRec.day = ndate;
                                        taskRec.endday = FinishDatendate;
                                        taskRec.projectId = pse.buildertek__Schedule__r.buildertek__Project__r.Name;
                                        if(pse.buildertek__Contractor_Resource__r.Name !=null){
                                        taskRec.contractresourceId = pse.buildertek__Contractor_Resource__r.Name;
                                        }
                                        if(pse.buildertek__Contractor__r.Name !=null){
                                        taskRec.ContractorName = pse.buildertek__Contractor__r.Name;
                                        }
                                        if(pse.buildertek__Resource__r.Name !=null){
                                        taskRec.internelresource = pse.buildertek__Resource__r.Name;
                                        }
                                        if(pse.buildertek__Notes__c !=null && pse.buildertek__Notes__c !=''){
                                        taskRec.taskNotes = pse.buildertek__Notes__c;
                                        }
                                        taskRec.Id = pse.id;
                                        taskRec.taskdescription = pse.Name;
                                        taskRec.taskdays = integer.valueof(pse.buildertek__Duration__c);
                                        taskRec.Completion = integer.valueof(pse.buildertek__Completion__c);
                                        taskRec.startdate = pse.buildertek__Start__c;
                                        taskRec.enddate = pse.buildertek__Finish__c;
                                        taskRec.Eid = pse.buildertek__Schedule__c;
                                        //taskRec.Model = pse.buildertek__Schedule__r.Name;
                                        //taskRec.UnitId = pse.buildertek__Resource__r.Name;
                                        taskRecordList.add(taskRec);

                                        }

                                        }

           return taskRecordList;
    }


     public class Wrapper{
        @AuraEnabled public string recordId { get; set; }
        @AuraEnabled public string Name { get; set; }
        @AuraEnabled public String Tasks{ get; set; }
        @AuraEnabled public String TradeType{ get; set; }
     }
}