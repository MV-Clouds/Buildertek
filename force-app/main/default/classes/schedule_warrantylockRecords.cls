global class schedule_warrantylockRecords implements Schedulable {
global void execute(SchedulableContext SC) {
warrantyLockedBatchcontroller wlc = new warrantyLockedBatchcontroller();
wlc.batchjobexcute();

}

public static void start() { 
        
      String str = 'Warranty LockedRecords';
        string sch = ''; 
        sch = '0 08 22 * * ?';
           //sch ='0 0 1 * * ?';
           System.schedule(str, sch , new schedule_warrantylockRecords());          
             
 }  
 public static void abort(){
         List<CronTrigger> ct = [SELECT Id, CronJobDetail.Id, CronJobDetail.Name, CronJobDetail.JobType FROM CronTrigger WHERE CronJobDetail.Name = 'Warranty LockedRecords'];
         if(ct.size() >0 ){
            System.abortJob(ct[0].Id);
            
         }
         
 }
     
    }