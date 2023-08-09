public class ImportMasterSOVsToPaymentAppController {
  
    
     @AuraEnabled
    public static buildertek__Schedule_of_Values__c getSovType(String recordId){
        
        buildertek__Schedule_of_Values__c SOVType = [select Id, Name,buildertek__Type__c,RecordTypeId, recordtype.name, buildertek__Status__c from buildertek__Schedule_of_Values__c WHERE Id =: recordId];
        
        return SOVType;
    }
    
    
    
    @AuraEnabled
    public static RfqDataTableWrapper getmasterScheduleOValues(Integer pageNumber, Integer pageSize,string recordId){
        Integer offset = (pageNumber - 1) * pageSize;
        //Total Records 
        Integer totalRecords = 0;        
        Integer recordEnd = pageSize * pageNumber;
        
        //Instance of Contact DataTable Wrapper Class
        RfqDataTableWrapper objDT = new RfqDataTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        
        
        
        
      
        
        buildertek__Schedule_of_Values__c bsc = [select id,buildertek__Project__c from buildertek__Schedule_of_Values__c where id=:recordId];
        
        objDT.recordList = [SELECT Id, Name, buildertek__Type__c, RecordTypeId, recordtype.name, buildertek__Project__c,buildertek__Project__r.Name
                            FROM buildertek__Schedule_of_Values__c
                            WHERE recordtype.name = 'Master' ORDER BY Name 
                            LIMIT :pageSize
                            OFFSET :offset];  
        
        
        return objDT;
        
    }
    
    
    @AuraEnabled
    public static list<buildertek__Schedule_of_Value_Lines__c>  importScheduleOfValueItems(List<String> IdList,  String recordId){
        
        system.debug('IdList----->'+IdList);
        
         system.debug('recordId----->'+recordId);
        
        buildertek__Schedule_of_Values__c SovRec = [select Id,Name, recordtype.name from buildertek__Schedule_of_Values__c where Id =: recordId ];
        
        list<buildertek__Schedule_of_Value_Lines__c> lastSOV = [SELECT Id,buildertek__Item__c,buildertek__Schedule_of_Values__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c =: recordId ORDER BY buildertek__Item__c DESC];
            
            
            integer itemInc = 100;
        
        if(lastSOV.size() > 0 && lastSOV[0].buildertek__Item__c != null){
            itemInc = Integer.valueOf(lastSOV[0].buildertek__Item__c)+1;
        }
        
        
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry1 = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec1 = Database.query(strQry1);
        if(userRec1.size() > 0){
            portalCode = userRec1[0].get('isPortalEnabled').toString();
        }
        
        list<buildertek__Schedule_of_Value_Lines__c> masterRFQItemToInsert = new list<buildertek__Schedule_of_Value_Lines__c>();
        list<buildertek__Schedule_of_Value_Lines__c> masterRFQList;
        if (Schema.sObjectType.buildertek__Schedule_of_Value_Lines__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__Schedule_of_Value_Lines__c.fields.Name.isAccessible() &&
            Schema.sObjectType.buildertek__Schedule_of_Value_Lines__c.fields.buildertek__Description_of_Work__c.isAccessible() && 
            Schema.sObjectType.buildertek__Schedule_of_Value_Lines__c.fields.buildertek__Scheduled_Value__c.isAccessible() &&
            Schema.sObjectType.buildertek__Schedule_of_Value_Lines__c.fields.buildertek__Schedule_of_Values__c.isAccessible() &&
            Schema.sObjectType.buildertek__Schedule_of_Value_Lines__c.fields.buildertek__Status__c.isAccessible() &&
            Schema.sObjectType.buildertek__Schedule_of_Value_Lines__c.fields.buildertek__Vendor_SOV_Line__c.isAccessible() &&
         
            Schema.sObjectType.buildertek__Schedule_of_Value_Lines__c.fields.buildertek__Item__c.isAccessible()){
                masterRFQList = [SELECT Id,
                                 Name,
                                 buildertek__Description_of_Work__c,
                                 buildertek__Schedule_of_Values__c,
                                 buildertek__Scheduled_Value__c,
                                 buildertek__Item__c,
                                 buildertek__Vendor__c,
                                 buildertek__Status__c,
                                 buildertek__Vendor_SOV_Line__c,
                                 buildertek__Schedule_of_Values__r.Name,
                                 buildertek__Schedule_of_Values__r.buildertek__Type__c
                                 FROM buildertek__Schedule_of_Value_Lines__c
                                 WHERE buildertek__Schedule_of_Values__c IN :IdList];
                
                
            }
        system.debug('masterRFQList------->'+masterRFQList);
        
        for (buildertek__Schedule_of_Value_Lines__c masterRFQItem : masterRFQList){
            if (Schema.sObjectType.buildertek__Schedule_of_Value_Lines__c .fields.Id.isAccessible() &&
                Schema.sObjectType.buildertek__Schedule_of_Value_Lines__c .fields.buildertek__Description_of_Work__c.isAccessible() &&
                // Schema.sObjectType.buildertek__Schedule_of_Value_Lines__c .fields.buildertek__SOV_Continuation_Sheet__c.isAccessible() && 
                Schema.sObjectType.buildertek__Schedule_of_Value_Lines__c .fields.buildertek__Item__c.isAccessible() && 
                Schema.sObjectType.buildertek__Schedule_of_Value_Lines__c .fields.buildertek__Status__c.isAccessible() && 
                Schema.sObjectType.buildertek__Schedule_of_Value_Lines__c .fields.buildertek__Vendor_SOV_Line__c.isAccessible() && 
                Schema.sObjectType.buildertek__Schedule_of_Value_Lines__c .fields.buildertek__Scheduled_Value__c.isAccessible()){
                    
                    buildertek__Schedule_of_Value_Lines__c rfqItem = new buildertek__Schedule_of_Value_Lines__c();
                    
                    rfqItem.buildertek__Description_of_Work__c =masterRFQItem.buildertek__Description_of_Work__c;
                    rfqItem.buildertek__Scheduled_Value__c=masterRFQItem.buildertek__Scheduled_Value__c ;
                    rfqItem.buildertek__Item__c=String.valueOf(itemInc);
                    // rfqItem.buildertek__Item__c=masterRFQItem.buildertek__Item__c;
                    rfqItem.buildertek__Vendor__c = masterRFQItem.buildertek__Vendor__c;
                    
                    system.debug('masterRFQItem.buildertek__Vendor__c------->'+masterRFQItem.buildertek__Vendor__c); 
                    
                    system.debug('portalCode------->'+portalCode);
                    if(portalCode == 'true'){
                        rfqItem.buildertek__Status__c = 'Pending';
                    }else{
                        if(SovRec.recordtype.name == 'Standard'){
                            //BUIL - 3265 
                            // rfqItem.buildertek__Status__c = 'Approved';
                            rfqItem.buildertek__Vendor_SOV_Line__c = masterRFQItem.Id;  
                        }else{
                            rfqItem.buildertek__Status__c = 'Pending';
                        }
                        
                    }
                        
                    
                    //Id sheetId = Id.valueOf(recordId);
                    system.debug(recordId);
                    rfqItem.buildertek__Schedule_of_Values__c = recordId;
                    masterRFQItemToInsert.add(rfqItem);
                    itemInc++;
                    system.debug(rfqItem);
                    
                }
            
        }
        system.debug('masterRFQItemToInsert------->'+masterRFQItemToInsert);
        system.debug(masterRFQItemToInsert.size());
        
        if (masterRFQItemToInsert.size() > 0){
            insert masterRFQItemToInsert;
        }
        system.debug('masterRFQItemToInsert------->'+masterRFQItemToInsert);
        
        return masterRFQItemToInsert;
    }
    
    public class RfqDataTableWrapper{
        @AuraEnabled
        public Integer pageSize{ get; set; }
        
        @AuraEnabled
        public Integer pageNumber{ get; set; }
        
        @AuraEnabled
        public Integer totalRecords{ get; set; }
        
        @AuraEnabled
        public Integer recordStart{ get; set; }
        
        @AuraEnabled
        public Integer recordEnd{ get; set; }
        
        @AuraEnabled
        public List<buildertek__Schedule_of_Values__c> recordList{ get; set; }
        
    }
    
    
    @AuraEnabled  
    public static User getUser(){
        String portalCode = '';
        string userName = userInfo.getUserId();
        string strQry = 'Select Id, isPortalEnabled,buildertek__Account_Id__c From User Where id=: userName';    
        list<User> userRec = Database.query(strQry);
        if(userRec.size() > 0){
            portalCode = userRec[0].get('isPortalEnabled').toString();
        }
        return  userRec[0] ;
    }
    
    
      @AuraEnabled
    public static String isSovSubmitted(String recordId){
        system.debug(recordId);
        buildertek__Schedule_of_Values__c updateStatus = [select Id, Name, buildertek__Status__c from buildertek__Schedule_of_Values__c where Id =:recordId];
        system.debug(updateStatus);
      //  updateStatus.buildertek__Status__c = 'Vendor Submitted';
        
        system.debug('updates status ------> '+ updateStatus);
        return updateStatus.buildertek__Status__c;
    }
}