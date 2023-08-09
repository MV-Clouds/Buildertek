trigger QuoteAfterInsertUpdate on SBQQ__Quote__c (after insert, after update,before insert,before update) {
    system.debug('---INSIDE TRIGGER---');
    if(Trigger.isAfter) {
        if(Trigger.isInsert) {
            QuoteTriggerHandler quoteTriggerHandlerObj = new QuoteTriggerHandler();
            quoteTriggerHandlerObj.sumWinningInfoToRelatedOppty(Trigger.New);
            
        }
        if(Trigger.isUpdate) {
            list<SBQQ__Quote__c > quotesToProcessList = new list<SBQQ__Quote__c >();
            map<Id,SBQQ__Quote__c > quotesOldMap = new map<Id,SBQQ__Quote__c >();
            quotesOldMap = Trigger.oldMap;
            
            for(SBQQ__Quote__c quoteObjectRecord : Trigger.New) {
                if(quoteObjectRecord.Total_Sq_Feet__c != Trigger.oldMap.Get(quoteObjectRecord.Id).Total_Sq_Feet__c ||
                   quoteObjectRecord.Total_IGU_s_QL__c != Trigger.oldMap.Get(quoteObjectRecord.Id).Total_IGU_s_QL__c ||
                   quoteObjectRecord.IGU_Total_Amount__c != Trigger.oldMap.Get(quoteObjectRecord.Id).IGU_Total_Amount__c ||
                   quoteObjectRecord.BOS_Total_Amount__c != Trigger.oldMap.Get(quoteObjectRecord.Id).BOS_Total_Amount__c ||
                   quoteObjectRecord.Bid_Status__c != Trigger.oldMap.Get(quoteObjectRecord.Id).Bid_Status__c ||
                   quoteObjectRecord.Exclude_Sync__c != Trigger.oldMap.Get(quoteObjectRecord.Id).Exclude_Sync__c
                ) {
                    quotesToProcessList.Add(quoteObjectRecord);
                }
                
            }
            System.debug('>>>quotesToProcessList: '+quotesToProcessList);
            QuoteTriggerHandler quoteTriggerHandlerObj = new QuoteTriggerHandler();
            quoteTriggerHandlerObj.sumWinningInfoToRelatedOppty(quotesToProcessList);
            
        }
    }
   
   /*============================================================================================ 
   Description          : processQuoteRecords get calls each time when Quote Inserted/Updated in Before operation.
   @params              : newQuoteList - Holds the Trigger.New Context
                        : oldQuoteList - Holds the Trigger.Old Context
   @return              : none 
   Modification History : ENP Solutionz. 30/09/2018      
   ===============================================================================================*/  
   if(Trigger.isBefore){
        if(Trigger.isInsert){
            QuoteTriggerHandler quoteTriggerHandlerObj = new QuoteTriggerHandler();
            quoteTriggerHandlerObj.processQuoteRecords(Trigger.New, null);
        }
        if(Trigger.isUpdate){
            QuoteTriggerHandler quoteTriggerHandlerObj = new QuoteTriggerHandler();
            quoteTriggerHandlerObj.processQuoteRecords(Trigger.New, Trigger.Old);
            // JV - 20190107 - Added the following line
            quoteTriggerHandlerObj.calculateBaseCommission(Trigger.New, Trigger.OldMap);
        }
    }
}