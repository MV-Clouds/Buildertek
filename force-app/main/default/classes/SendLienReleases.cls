public class SendLienReleases {
    @AuraEnabled
    public static object getPurchaseOrders(String recordId){
        List<buildertek__Purchase_Order__c> POList;
        
        POList = [SELECT Id, Name, buildertek__Description__c, buildertek__Date_Lien_Release_Sent__c,buildertek__Date_Lien_Release_Signed__c,buildertek__Vendor__c,buildertek__Vendor__r.Name, buildertek__Community__c,buildertek__Project__c
                  FROM buildertek__Purchase_Order__c
                  WHERE buildertek__Date_Lien_Release_Signed__c = null AND buildertek__Project__c = :recordId AND buildertek__Vendor__c != ''];
        
        List<PurchaseOrderClass> purchaseOrderList = new List<PurchaseOrderClass>();
        for (buildertek__Purchase_Order__c sch : POList){
            PurchaseOrderClass PurchaseOrderClassRecord = new PurchaseOrderClass();
            PurchaseOrderClassRecord.purchaseOrderRecord = sch;
            PurchaseOrderClassRecord.scheduleCheck = false;
            purchaseOrderList.add(PurchaseOrderClassRecord);
        }
        return purchaseOrderList;
    }
    @AuraEnabled
    public static object getapprovedPurchaseOrders(String recordId){
        List<buildertek__Purchase_Order__c> POList;
        
        POList = [SELECT Id, Name, buildertek__Description__c,buildertek__Project__r.Name,buildertek__Status__c, buildertek__Date_Lien_Release_Sent__c,buildertek__Date_Lien_Release_Signed__c,buildertek__Vendor__c,buildertek__Vendor__r.Name, buildertek__Community__c,buildertek__Project__c
                  FROM buildertek__Purchase_Order__c
                  WHERE buildertek__Status__c = 'Approved' AND buildertek__Date_Lien_Release_Sent__c != null AND buildertek__Date_Lien_Release_Signed__c = null];
        
        List<PurchaseOrderClass> purchaseOrderList = new List<PurchaseOrderClass>();
        for (buildertek__Purchase_Order__c sch : POList){
            PurchaseOrderClass PurchaseOrderClassRecord = new PurchaseOrderClass();
            PurchaseOrderClassRecord.purchaseOrderRecord = sch;
            PurchaseOrderClassRecord.scheduleCheck = false;
            purchaseOrderList.add(PurchaseOrderClassRecord);
        }
        return purchaseOrderList;
    }
    @AuraEnabled
    public static PODataTableWrapper getProducts(Integer pageNumber, Integer pageSize, String project, String vendor, String Datevalue){
        List<Product2> rfqList = new List<Product2>();
        
        Integer offset = (pageNumber -1) * pageSize; //(pageNumber - 1) * pageSize;
        //Total Records 
        Integer totalRecords = 0;
        
        
       
        
        /*list<String> pB1 = new list<String>();
        if(priceBook != '' && priceBook != null){
            system.debug('pricebookAt starting'+priceBook);
            String query1 = 'select Id, Name,Pricebook2.Name,Product2Id from PricebookEntry where Pricebook2.Name LIKE  \'%'+String.escapeSingleQuotes(priceBook)+'%\'';
            system.debug('query111111111'+query1);
            list<PricebookEntry> productIdInPB = Database.Query(query1);
            for(PricebookEntry Pricebook1 : productIdInPB){
                pB1.add(Pricebook1.Product2Id);
            }
        }*/
        if(project != '' || vendor != '' || DateValue != ''){
            String query = 'Select COUNT() FROM buildertek__Purchase_Order__c WHERE buildertek__Status__c = \'Approved\' AND buildertek__Date_Lien_Release_Sent__c != null AND buildertek__Date_Lien_Release_Signed__c = null';
            if(project != '' && project != null){
                query = query+ ' AND buildertek__Project__r.Name LIKE \'%'+String.escapeSingleQuotes(project)+'%\'';
            }
            if(vendor != '' && vendor != null){
                query = query+ ' AND buildertek__Vendor__r.Name LIKE \'%'+String.escapeSingleQuotes(vendor)+'%\'';
            }
           if(Datevalue != null && Datevalue != ''){
               Integer d = Date.valueOf(Datevalue).day();
               Integer mo = Date.valueOf(Datevalue).month();
               Integer yr = Date.valueOf(Datevalue).year();
               
               DateTime DT = DateTime.newInstance(yr, mo, d,0,0,0);
               system.debug(DateTime.valueOf(DT));
               query = query+ ' AND buildertek__Date_Lien_Release_Sent__c <=:DT';
            }
            totalRecords = Database.countQuery(query);
        }else{
            totalRecords = [SELECT COUNT() FROM buildertek__Purchase_Order__c WHERE buildertek__Status__c = 'Approved' AND buildertek__Date_Lien_Release_Sent__c != null AND buildertek__Date_Lien_Release_Signed__c = null];
        }
        Integer recordEnd = pageSize * pageNumber;
        PODataTableWrapper objDT = new PODataTableWrapper();
        objDT.pageSize = pageSize;
        objDT.pageNumber = pageNumber;
        objDT.recordStart = offset + 1;
        objDT.recordEnd = totalRecords >= recordEnd ? recordEnd : totalRecords;
        objDT.totalRecords = totalRecords;
        if(project != '' || vendor != ''|| Datevalue != null){
            system.debug(offset);
            system.debug(project);
            String queryList = 'SELECT Id, Name, buildertek__Description__c,buildertek__Project__r.Name,buildertek__Status__c, buildertek__Date_Lien_Release_Sent__c,buildertek__Date_Lien_Release_Signed__c,buildertek__Vendor__c,buildertek__Vendor__r.Name, buildertek__Community__c,buildertek__Project__c FROM buildertek__Purchase_Order__c WHERE buildertek__Status__c = \'Approved\' AND buildertek__Date_Lien_Release_Sent__c != null AND buildertek__Date_Lien_Release_Signed__c = null';
            if(project != '' && project != null){
                queryList = queryList+ ' AND (buildertek__Project__r.Name LIKE \'%'+project+'%\')';
            }
            if(vendor != '' && vendor != null){
                queryList = queryList+ ' AND (buildertek__Vendor__r.Name LIKE \'%'+vendor+'%\')';
            }
            if(Datevalue != null && Datevalue != ''){
                Integer day = Date.valueOf(Datevalue).day();
                Integer month = Date.valueOf(Datevalue).month();
                Integer year = Date.valueOf(Datevalue).year();
                
                DateTime DTime = DateTime.newInstance(year, month, day,0,0,0);
                system.debug(DateTime.valueOf(DTime));
                queryList = queryList+ ' AND buildertek__Date_Lien_Release_Sent__c <=:DTime';
            }
            queryList = queryList+ ' ORDER BY Name ';//LIMIT :pageSize OFFSET :offset
            List<buildertek__Purchase_Order__c> POList;
            
            POList = Database.query(queryList);
            List<PurchaseOrderClass> purchaseOrderList = new List<PurchaseOrderClass>();
            for (buildertek__Purchase_Order__c sch : POList){
                PurchaseOrderClass PurchaseOrderClassRecord = new PurchaseOrderClass();
                PurchaseOrderClassRecord.purchaseOrderRecord = sch;
                PurchaseOrderClassRecord.scheduleCheck = false;
                purchaseOrderList.add(PurchaseOrderClassRecord);
            }
            objDT.recordList = purchaseOrderList;
        }
        else{
             List<buildertek__Purchase_Order__c> POList;
            POList = [SELECT Id, Name, buildertek__Description__c,buildertek__Project__r.Name,buildertek__Status__c, buildertek__Date_Lien_Release_Sent__c,buildertek__Date_Lien_Release_Signed__c,buildertek__Vendor__c,buildertek__Vendor__r.Name, buildertek__Community__c,buildertek__Project__c
                                FROM buildertek__Purchase_Order__c
                      			WHERE buildertek__Status__c = 'Approved' AND buildertek__Date_Lien_Release_Sent__c != null AND buildertek__Date_Lien_Release_Signed__c = null
                      			ORDER BY Name 
                               /* LIMIT :pageSize
                                OFFSET :offset*/];
            List<PurchaseOrderClass> purchaseOrderList = new List<PurchaseOrderClass>();
             for (buildertek__Purchase_Order__c sch : POList){
                PurchaseOrderClass PurchaseOrderClassRecord = new PurchaseOrderClass();
                PurchaseOrderClassRecord.purchaseOrderRecord = sch;
                PurchaseOrderClassRecord.scheduleCheck = false;
                purchaseOrderList.add(PurchaseOrderClassRecord);
            }
            objDT.recordList = purchaseOrderList;
        }
            system.debug('purchase order list==================================>>>>>>>>>>>>>>>>>>>>'+ objDT);
   
        return objDT;
        
     }
    
    @AuraEnabled
    public static List<ListView> getListViews() {
        List<ListView> listviews =
            [SELECT Id, Name FROM ListView WHERE SobjectType = 'buildertek__Purchase_Order__c' AND Name = 'All'];
        
        // Perform isAccessible() check here
        return listviews;
    }
    
    public class PODataTableWrapper{
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
        public List<PurchaseOrderClass> recordList{ get; set; }
    }
    public class PurchaseOrderClass{
        @AuraEnabled
        public buildertek__Purchase_Order__c  purchaseOrderRecord{ get; set; }
        
        @AuraEnabled
        public boolean ScheduleCheck{ get; set; }
    }
    public class MessageClass{
        @AuraEnabled
        public String Status{ get; set; }
        
        @AuraEnabled
        public string Message{ get; set; }
    }
    @AuraEnabled
    public static string  linerelase(list<string> scheduleRecIds){
        system.debug('hii'+scheduleRecIds);
       /* Map<string,list<string>> purchaseorderMap = new Map <string,list<string>>();
        list<id> vendorIds = new list<id>();
        String htmlBody = '';
        List<String> cc = new List<String>();
         cc.add('');
        string Emailsubject = '';
        string fileid = '';
        Emailtemplate templateId = [Select Id, Name, folder.name from Emailtemplate where Name =: 'Purchase Order Lien Template']; 
        list<buildertek__Purchase_Order__c> purchaselist = [select id,Name,buildertek__Vendor__c from buildertek__Purchase_Order__c where id =: scheduleRecIds];
        for(buildertek__Purchase_Order__c purchaserec : purchaselist){
            vendorIds.add(purchaserec.buildertek__Vendor__c);
        } 
        list<Contact> conlist = [select id,Name,AccountId,buildertek__Primary_Contact__c from Contact where AccountId =: vendorIds AND buildertek__Primary_Contact__c = true];
        for(Contact conrec : conlist){
            if(purchaseorderMap.get(conrec.AccountId) != null){
                list<string> existingconids = purchaseorderMap.get(conrec.AccountId);
                existingconids.add(conrec.id);
                purchaseorderMap.put(conrec.AccountId,existingconids);
            }else{
               list<string> newconids = new list<string>();  
               newconids.add(conrec.id); 
               purchaseorderMap.put(conrec.AccountId,newconids); 
            }
        }*/
        
        
        try{
            SendLienReleaseBatch be = new SendLienReleaseBatch(scheduleRecIds);
            database.executeBatch(be,1);
            return 'SUCCESS';
        }catch(Exception e){
            String message = e.getMessage();
            system.debug(e);
            //return message;    
            return 'ERROR';
        }
        /*for(buildertek__Purchase_Order__c purchaserec : purchaselist){
          list<string> existingconids = purchaseorderMap.get(purchaserec.buildertek__Vendor__c);
           system.debug('hii'+purchaserec.id);
            system.debug(templateId.id);
            system.debug(existingconids);
            system.debug(fileid);
           Emailsubject = 'PurchaseOrder[ref:'+purchaserec.id+']';
            if(existingconids != null){
                PreviewPurchaseOrderLineController.sendPurchaseOrderLineRelease(htmlBody,purchaserec.id,templateId.id,existingconids,cc,Emailsubject,fileid);      
            }
        }*/
      //return 'Success'; 
    }
    
}