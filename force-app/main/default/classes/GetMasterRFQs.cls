public class GetMasterRFQs {
    @AuraEnabled
    public static RfqDataTableWrapper getRFQs(string budgetId, Integer pageNumber, Integer pageSize, string RFQRecId, String vendorName, String tradeType, String description){
         List<buildertek__RFQ__c> rfqList = new List<buildertek__RFQ__c>();
        buildertek__Budget__c budgetRec = [Select Id , Name , buildertek__Project__c From buildertek__Budget__c Where Id=:budgetId  limit 1];
         
         List<String> statusList= new List<String>();
         statusList.add('Awarded');
         statusList.add('Accepted');


        //rfqList = [SELECT COUNT() FROM buildertek__RFQ__c WHERE buildertek__Status__c =:'Awarded' OR buildertek__Status__c =:'Accepted'];
        
        //system.debug(vendorName+''+tradeType+''+description+''+description!='');
        
        Integer offset = (pageNumber - 1) * pageSize;
        //Total Records
        Integer totalRecords = 0;
        if(vendorName != '' || tradeType != '' || description != ''){
            system.debug(description+'tradeType'+tradeType+'vendorName'+vendorName);
            String query = 'Select COUNT() FROM buildertek__RFQ__c WHERE (buildertek__Status__c =\'Awarded\' OR buildertek__Status__c =\'Accepted\') ';
            if(description != '' && description != null){
                query = query+ 'AND (Name LIKE \'%'+String.escapeSingleQuotes(description)+'%\')';
            }
            if(tradeType != '' && tradeType != null){
                query = query+ ' AND (buildertek__Trade_Type__r.Name LIKE \'%'+String.escapeSingleQuotes(tradeType)+'%\')';
            }
            if(vendorName != '' && vendorName != null){
                query = query+ 'AND (buildertek__Vendor__r.Name LIKE \'%'+String.escapeSingleQuotes(vendorName)+'%\')';
            }
            totalRecords = Database.countQuery(query);
            system.debug(totalRecords);
        }else{
            // totalRecords = [SELECT COUNT() FROM buildertek__RFQ__c 
            //                     WHERE (buildertek__Status__c ='Awarded' OR buildertek__Status__c ='Accepted') AND buildertek__Project__c=:budgetRec.buildertek__Project__c];


            // Changed For Ticket No BUIL - 3449
            totalRecords = [SELECT COUNT() FROM buildertek__RFQ__c 
                                WHERE buildertek__Status__c IN:statusList AND  buildertek__Project__c=:budgetRec.buildertek__Project__c];
        }
        
        
        Integer recordEnd = pageSize * pageNumber;
        
        //Instance of Contact DataTable Wrapper Class
        RfqDataTableWrapper objDT = new RfqDataTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
         if(vendorName != '' || tradeType != '' || description != ''){
             String queryList = 'Select Id,Name,buildertek__Vendor__r.Name,buildertek__Trade_Type__r.Name,buildertek__Awarded_Date__c,buildertek__Vendor_Quote__c FROM buildertek__RFQ__c';
             queryList = queryList +  ' WHERE (buildertek__Status__c =\'Awarded\' OR buildertek__Status__c =\'Accepted\') ';
             

             if(description != '' && description != null){
                 queryList = queryList+ 'AND (Name LIKE \'%'+description+'%\')'; //String.escapeSingleQuotes(description)
             }
             if(tradeType != '' && tradeType != null){
                 queryList = queryList+ ' AND (buildertek__Trade_Type__r.Name LIKE \'%'+tradeType+'%\')';
             }
             if(vendorName != '' && vendorName != null){
                 queryList = queryList+ ' AND (buildertek__Vendor__r.Name LIKE \'%'+vendorName+'%\')';
             }
             if(budgetRec.buildertek__Project__c!= null){
                queryList = queryList +  ' AND buildertek__Project__c=\''+budgetRec.buildertek__Project__c+ '\'';
            }
             queryList = queryList+ ' ORDER BY Name LIMIT :pageSize OFFSET :offset';
             system.debug(queryList);
             objDT.recordList = Database.query(queryList);
             system.debug(objDT.recordList);
             
         }else{
            //  objDT.recordList = [Select Id,Name,buildertek__Vendor__r.Name,buildertek__Trade_Type__r.Name,buildertek__Awarded_Date__c,buildertek__Vendor_Quote__c 
            //                  FROM buildertek__RFQ__c WHERE buildertek__Status__c ='Awarded' OR buildertek__Status__c ='Accepted' ORDER BY Name 
            //                 LIMIT :pageSize
            //                 OFFSET :offset];
            if(budgetRec.buildertek__Project__c!= null){
                objDT.recordList = [SELECT Id,Name,buildertek__Project__c , buildertek__Vendor__r.Name,buildertek__Trade_Type__r.Name,buildertek__Awarded_Date__c,buildertek__Vendor_Quote__c 
                                    FROM buildertek__RFQ__c WHERE buildertek__Status__c IN:statusList AND  buildertek__Project__c=:budgetRec.buildertek__Project__c ORDER BY Name 
                                    LIMIT :pageSize OFFSET :offset];

            }else{
                objDT=null;
            }

         }
         
        
        return objDT;
       //return rfqList;
    }
    
    @AuraEnabled
    public static String addRfqLinesToBudget(List<String>rfqIds, String budgetId){
        try{
            List<String> RFQrecordIds = rfqIds;
            String budgetRecId = budgetId;
            List<buildertek__RFQ_Item__c> rfqLines = [SELECT Id, Name, buildertek__RFQ_Package__r.buildertek__Vendor__r.buildertek__Vendor__c, buildertek__Description__c, buildertek__Quantity__c, buildertek__Unit_Price__c, buildertek__Total_Price__c FROM buildertek__RFQ_Item__c Where buildertek__RFQ_Package__c IN :RFQrecordIds ];
            List<buildertek__Budget_Item__c> budgetItemList = new List<buildertek__Budget_Item__c>();
            for(buildertek__RFQ_Item__c rfqLineItem : rfqLines){
                buildertek__Budget_Item__c budgetItem = new buildertek__Budget_Item__c();
                budgetItem.Name = rfqLineItem.Name;
                budgetItem.buildertek__Budget__c = budgetRecId;
                if(rfqLineItem.buildertek__RFQ_Package__r.buildertek__Vendor__r.buildertek__Vendor__c != null){
                    budgetItem.buildertek__Contractor__c = rfqLineItem.buildertek__RFQ_Package__r.buildertek__Vendor__r.buildertek__Vendor__c;
                }
                
                budgetItem.buildertek__Unit_Price__c = rfqLineItem.buildertek__Unit_Price__c;
                budgetItem.buildertek__Quantity__c = rfqLineItem.buildertek__Quantity__c;
                budgetItem.buildertek__Description__c = rfqLineItem.buildertek__Description__c;
                budgetItem.buildertek__RFQ__c = rfqLineItem.buildertek__RFQ_Package__c;
                budgetItemList.add(budgetItem);
            }
            system.debug(budgetItemList);
            insert budgetItemList;
            return 'SUCCESS';
        }catch (Exception ex){
            String error =ex.getMessage();
            return error;
        }
        
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
        public List<buildertek__RFQ__c> recordList{ get; set; }
    }
}