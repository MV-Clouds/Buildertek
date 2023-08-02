global class schedule_contacttimecardRecords implements Schedulable {
    global void execute(SchedulableContext SC) {
        contacttimecardBatchcontroller wlc = new contacttimecardBatchcontroller();
        wlc.batchjobexcute();
        
    }
    
    public static void start() { 
        
        String str = 'Time Card Records';
        string sch = ''; 
        sch = '0 0 * * 0 ?';
        //sch ='0 0 1 * * ?';
        System.schedule(str, sch , new schedule_contacttimecardRecords());          
        
    }  

}