public with sharing class PurchaseOrderController {
    @AuraEnabled
    public static String getProject(String recordId){
        String projectName = '';
        buildertek__Purchase_Order__c Porecord = [Select Id, buildertek__Project__r.Name from buildertek__Purchase_Order__c  where buildertek__Project__c =: recordId LIMIT 1];
        projectName = Porecord.buildertek__Project__r.Name;
        return projectName;
    }
    
    @AuraEnabled
    public static object getMasterRFQs(String recordId, String vendorName, String status, String description){
        List<MasterBudgetsClass> MasterBudgetsClassList = new List<MasterBudgetsClass>();
        List<buildertek__Purchase_Order__c> PurchaseOrderList;
        String projectName = '';
        buildertek__Purchase_Order__c Porecord = [Select Id, buildertek__Project__r.Name from buildertek__Purchase_Order__c  where buildertek__Project__c =: recordId LIMIT 1];
        projectName = Porecord.buildertek__Project__r.Name;
        //Integer pageNumber, Integer pageSize, string recordId, String vendorName, String status, String description
        // Order by buildertek__Date_Created__c,buildertek__Status__c,buildertek__Vendor__r.Name
        /*Integer offset = (pageNumber - 1) * pageSize;
        //Total Records
        Integer totalRecords = 0;
        if(vendorName != '' || status != '' || description != ''){
            system.debug(description+'tradeType'+tradeType+'vendorName'+vendorName);
            String query = 'Select COUNT() FROM buildertek__Purchase_Order__c where buildertek__Project__c =: recordId ';
            if(description != '' && description != null){
                 queryList = queryList+ 'AND (buildertek__Description__c LIKE \'%'+description+'%\')'; //String.escapeSingleQuotes(description)
             }
             if(status != '' && status != null){
                 queryList = queryList+ ' AND (buildertek__Status__c LIKE \'%'+status +'%\')';
             }
             if(vendorName != '' && vendorName != null){
                 queryList = queryList+ ' AND (buildertek__Vendor__r.Name LIKE \'%'+vendorName+'%\')';
             }
            totalRecords = Database.countQuery(query);
            system.debug(totalRecords);
        }else{
            totalRecords = [SELECT COUNT() FROM buildertek__Purchase_Order__c 
                            where buildertek__Project__c =: recordId];
        }
        
        
        Integer recordEnd = pageSize * pageNumber;
        
        //Instance of Contact DataTable Wrapper Class
        PoDataTableWrapper objDT = new PoDataTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;*/
        
        
        
        
        
        if(vendorName != '' || status != '' || description != ''){
             String queryList = 'Select Id,Name,buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__Status__c,buildertek__Date_Created__c,buildertek__Description__c, buildertek__PO_Total__c,buildertek__PO_Balance__c,buildertek__Paid_Amount__c,buildertek__Schedule_Item__c, buildertek__Schedule_Item__r, buildertek__Project__r.Name from buildertek__Purchase_Order__c ';
             queryList = queryList +  ' where buildertek__Project__c =: recordId ';
             if(description != '' && description != null){
                 queryList = queryList+ 'AND (buildertek__Description__c LIKE \'%'+description+'%\')'; //String.escapeSingleQuotes(description)
             }
             if(status != '' && status != null){
                 queryList = queryList+ ' AND (buildertek__Status__c LIKE \'%'+status +'%\')';
             }
             if(vendorName != '' && vendorName != null){
                 queryList = queryList+ ' AND (buildertek__Vendor__r.Name LIKE \'%'+vendorName+'%\')';
             }
             //queryList = queryList+ ' ORDER BY Name DESC LIMIT :pageSize OFFSET :offset';
             system.debug(queryList);
            //objDT.recordList = Database.query(queryList);
             PurchaseOrderList = Database.query(queryList);
             
         }else{
             PurchaseOrderList = [Select Id,Name,buildertek__Vendor__c,buildertek__Vendor__r.Name,buildertek__Status__c,buildertek__Date_Created__c, buildertek__Project__r.Name,
                                  buildertek__Description__c, buildertek__PO_Total__c,buildertek__PO_Balance__c,buildertek__Paid_Amount__c,buildertek__Schedule_Item__c, buildertek__Schedule_Item__r.Name
                                  from buildertek__Purchase_Order__c  where buildertek__Project__c =: recordId ORDER BY Name DESC
                 				];
         }
        for(buildertek__Purchase_Order__c PORec : PurchaseOrderList){
            MasterBudgetsClass MasterBudgetsClassRecord = new MasterBudgetsClass(); 
            MasterBudgetsClassRecord.purchaseOrderRecord = PORec;
          	 MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassRecord.projectName = projectName;
            MasterBudgetsClassList.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassList;                                               
    }
    
    @AuraEnabled
    public static String sendMailToContact(List<String> PoIds){
		system.debug(PoIds);
        //SendPoMailToContact be = new SendPoMailToContact(new Set < Id > {'0015g000004kMrGAAU','0015g000004kMrHAAU'});
        try{
            SendPoMailToContact be = new SendPoMailToContact(PoIds);
            database.executeBatch(be,1);
            return 'SUCCESS';
        }catch(Exception e){
            String message = e.getMessage();
            system.debug(e);
            //return message;    
            return 'ERROR';
        }
		
    }
    
    public class MasterBudgetsClass{
        @AuraEnabled
        public String projectName {get; set;}
         @AuraEnabled
         public buildertek__Purchase_Order__c purchaseOrderRecord {get;set;}
         @AuraEnabled
         public boolean budgetCheck {get;set;}
    }
    
    /*public class PoDataTableWrapper{
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
        public List<buildertek__RFQ__c> recordList{ get; set; }
    }*/
    
    public class MessageClass{
        @AuraEnabled
        public String Status {get;set;}
         @AuraEnabled
        public string Message {get;set;}
        
    }

}