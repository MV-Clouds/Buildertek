public with sharing class AddRFQToQuote_AC {
   @AuraEnabled
   public static list<RFQWrap> getRFQList(String recordId){
        list<buildertek__RFQ__C> RFQList;
         list<buildertek__RFQ__C> RFQrecord;
         
         if (Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible() &&
            Schema.sObjectType.buildertek__RFQ__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__RFQ_Number__c.isAccessible()
            && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Description__c.isAccessible()
            && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Project__c.isAccessible()) {
             RFQrecord = [select id, Name,buildertek__Project__c, RFQ_Number__c, Description__c from buildertek__RFQ__C where Id =: recordId];
          }
         
         list<Id>projectId = new List<Id>();
         for(RFQ__C rfqrec : RFQrecord){
            if(rfqrec.buildertek__Project__c !=null){
            projectId.add(rfqrec.buildertek__Project__c);
            }
         }
        
        if (Schema.sObjectType.buildertek__RFQ__c.fields.Name.isAccessible()
            && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__RFQ_Number__c.isAccessible()
            && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Description__c.isAccessible()
            && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Vendor_Quote__c.isAccessible()
            && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Project__c.isAccessible()
            && Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible()) {
            RFQList = [select id, Name,buildertek__Project__c, buildertek__RFQ_Number__c, buildertek__Description__c, buildertek__Vendor_Quote__c from buildertek__RFQ__C  where buildertek__Project__c =:projectId order by buildertek__RFQ_Number__c desc];
        }
        
        list<RFQWrap> RFQWraplist = new list<RFQWrap>();
        for(RFQ__C rfq : RFQList){
            RFQWrap RFQWrapRec = new RFQWrap();
            RFQWrapRec.getPurchaseOrderList = rfq;
            if(rfq.Id == recordId){
                RFQWrapRec.purcheckbox = true;    
            }else{
                RFQWrapRec.purcheckbox = false;    
            }
            RFQWraplist.add(RFQWrapRec);
        }
        return RFQWraplist;
   }
   
    @AuraEnabled
    public static list < RFQWrap > fetchPurchaseOrders(String sortField, boolean isAsc, String recordId) {
      String sSoql = 'select id, Name, RFQ_Number__c, Description__c, buildertek__Vendor_Quote__c ';
      sSoql += 'From buildertek__RFQ__c';
      system.debug('sortField-->' + sortField);
    
      if (sortField != '') {
         sSoql += ' order by ' + sortField;
    
    // if isAsc is equal tp ture then set 'asc' order otherwise set 'desc' order.
         if (isAsc) {
            sSoql += ' asc';
         } else {
            sSoql += ' desc';
         }
      }
    
      System.debug('@Developer -->sSoql:' + sSoql);
      list <buildertek__RFQ__c> lstResult;
      try {
         system.debug('The query is' + sSoql);
        /*  if (Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible()
            && Schema.sObjectType.buildertek__RFQ__c.fields.Name.isAccessible() 
            && Schema.sObjectType.buildertek__RFQ__c.fields.RFQ_Number__c.isAccessible()
            && Schema.sObjectType.buildertek__RFQ__c.fields.Description__c.isAccessible()
            && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Vendor_Quote__c.isAccessible()) {*/
         lstResult = Database.query(sSoql);
            /*}*/
         system.debug('lstResult -----------> '+lstResult);
         list<RFQWrap> RFQWraplist = new list<RFQWrap>();
         for(RFQ__C rfq : lstResult){
            RFQWrap RFQWrapRec = new RFQWrap();
            RFQWrapRec.getPurchaseOrderList = rfq;
            if(rfq.Id == recordId){
                RFQWrapRec.purcheckbox = true;    
            }else{
                RFQWrapRec.purcheckbox = false;
            }
            RFQWrapRec.purcheckbox = false;
            RFQWraplist.add(RFQWrapRec);
         }
         return RFQWraplist;
      } 
      catch (Exception ex) {
         // for handle Exception
         return null;
      }
    }
   
   @AuraEnabled
   public static list<QuoteWrap> getQuotelist(String recordId){
       list<QuoteWrap> QuoteWraplist = new list<QuoteWrap>();
        buildertek__RFQ__c rfq ;
       if (Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Project__c.isAccessible()
            && Schema.sObjectType.buildertek__RFQ__c.fields.Name.isAccessible() 
             && Schema.sObjectType.buildertek__RFQ__c.fields.Id.isAccessible()) {
             rfq = [SELECT Id, buildertek__Project__c FROM buildertek__RFQ__c WHERE Id =: recordId];
            }
           list<buildertek__Quote__c> getQuotelist;
           if( Schema.sObjectType.buildertek__Quote__c.fields.Id.isAccessible() && 
           Schema.sObjectType.buildertek__Quote__c.fields.Name.isAccessible() &&
           Schema.sObjectType.buildertek__Quote__c.fields.buildertek__Project__c.isAccessible()){
                getQuotelist = [select id,Name from buildertek__Quote__c WHERE buildertek__Project__c =: rfq.buildertek__Project__c];    
           } 
            
           for(buildertek__Quote__c Pur : getQuotelist){
                QuoteWrap QuoteWrapRec = new QuoteWrap();
                QuoteWrapRec.getQuotelist = Pur;
                QuoteWrapRec.Quotecheckbox = false;
                QuoteWraplist.add(QuoteWrapRec);
           }         
       
       
        return QuoteWraplist;
   }
   
   @AuraEnabled
   public static void AddPurchaseOrders(string Purchaselists,string QuoteWraps){
      // list<RFQWrap> Purchaselist = Json.deserialize(Purchaselists,RFQWrap);
      system.debug('QuoteWraps -------> '+QuoteWraps);
      system.debug('Purchaselists --------> '+Purchaselists);
       List<RFQWrap> Purchaselist =   (List<RFQWrap>)System.JSON.deserialize(Purchaselists, List<RFQWrap>.class);
       list<buildertek__RFQ__C> getPurchaseOrderLists = new list<buildertek__RFQ__c>();
       system.debug('Purchaselist ' + Purchaselist);
       List<buildertek__Quote_Item__c> quoteItemList = new List<buildertek__Quote_Item__c>();
       List<buildertek__Quote_Line_Group__c> quoteGroup;
       String groupId;
       if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isAccessible() && Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Id.isAccessible()){
          quoteGroup = [select Id, Name from buildertek__Quote_Line_Group__c where Name = 'No Grouping'];  
       }
          if(quoteGroup.size() > 0){
            groupId = quoteGroup[0].Id;    
          }else{
            buildertek__Quote_Line_Group__c qutGroup = new buildertek__Quote_Line_Group__c();
            qutGroup.Name = 'No Grouping';
            if(Schema.sObjectType.buildertek__Quote_Line_Group__c.fields.Name.isCreateable()){ 
                insert qutGroup;
            }
            groupId = qutGroup.Id;
          }
       
       
       buildertek__Quote_Line_Group__c newQuoteGroup = new buildertek__Quote_Line_Group__c();
       for(RFQWrap PurchaseRec : Purchaselist){
           if(PurchaseRec.purcheckbox == true){
                buildertek__RFQ__c rfq = new buildertek__RFQ__c();
                rfq.Id = PurchaseRec.getPurchaseOrderList.Id;
                rfq.buildertek__Quote__c = QuoteWraps;
                rfq.buildertek__Added_to_Quote__c = QuoteWraps;
                getPurchaseOrderLists.add(rfq);
                
                buildertek__Quote_Item__c quotes = new buildertek__Quote_Item__c();
                quotes.buildertek__Quote__c = QuoteWraps;
                quotes.buildertek__Grouping__c = groupId;
                quotes.Name = PurchaseRec.getPurchaseOrderList.Name;
                quotes.buildertek__Quantity__c = 1;
                quotes.buildertek__Unit_Cost__c = PurchaseRec.getPurchaseOrderList.Vendor_Quote__c;
                quoteItemList.add(quotes);
           }
       }
       system.debug('quoteItemList -------->  ' + quoteItemList);
       system.debug('getPurchaseOrderList ' + getPurchaseOrderLists);
       if (Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Quote__c.isUpdateable()
           && Schema.sObjectType.buildertek__RFQ__c.fields.buildertek__Added_to_Quote__c.isUpdateable()){
           update getPurchaseOrderLists;
       } 
       if (Schema.sObjectType.buildertek__Quote_Item__c.isCreateable()
           && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quote__c.isCreateable()
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Grouping__c.isCreateable()
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.Name.isCreateable()
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Quantity__c.isCreateable()
            && Schema.sObjectType.buildertek__Quote_Item__c.fields.buildertek__Unit_Cost__c.isCreateable()){
            insert quoteItemList;
       }
        
   }
   
   public Class RFQWrap{
       @AuraEnabled public boolean purcheckbox;
       @AuraEnabled public RFQ__c getPurchaseOrderList;
   }
   
   public Class QuoteWrap{
       @AuraEnabled public boolean Quotecheckbox;
       @AuraEnabled public Quote__c getQuotelist;
   }
}