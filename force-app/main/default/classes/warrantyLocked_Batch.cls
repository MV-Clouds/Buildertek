global class warrantyLocked_Batch implements Database.Batchable<sObject>,Database.Stateful {
    public list <string> warantyid;
    global warrantyLocked_Batch (list<buildertek__Warranty__c> warrantylst) {
        warantyid = new list<string>();
        for(buildertek__Warranty__c warnty : warrantylst){
            warantyid.add(warnty.id);   
        }
    }
    //Query method.
    global Database.QueryLocator start(Database.BatchableContext BC) {
        //System.debug('***************** 2');
        String Query = 'SELECT id,name,buildertek__Due_Date__c,buildertek__Locked__c from buildertek__Warranty__c  WHERE id IN: warantyid';
        return DataBase.getQueryLocator(Query);        
    }
    //Execute Method.
    global void execute(Database.BatchableContext BC,List<buildertek__Warranty__c> warrantyrecs) {
        list<buildertek__Warranty__c> warrantylockrecs = new list<buildertek__Warranty__c>();
        date lockdate = system.today()-1;
        for(buildertek__Warranty__c war : warrantyrecs){
            system.debug(war.buildertek__Due_Date__c+'-----------datecheck'+lockdate);
            if( war.buildertek__Due_Date__c == lockdate ){
                war.buildertek__Locked__c = true;
                warrantylockrecs.add(war);
            }
        }
        if(warrantylockrecs.size() > 0){
            update warrantylockrecs;
        }
    }
    //finish method
    global void finish(Database.BatchableContext BC) {
        
    }
}