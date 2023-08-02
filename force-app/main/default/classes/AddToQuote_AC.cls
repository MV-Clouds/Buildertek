public with sharing class AddToQuote_AC {
   @AuraEnabled
   public static list<PurchaseOrderWrap> getPurchaseOrderList(String recordId){
        list<Purchase_Order__c> getPurchaseOrderList;
        if (Schema.sObjectType.Purchase_Order__c.fields.Id.isAccessible()
            && Schema.sObjectType.Purchase_Order__c.fields.Name.isAccessible()
            && Schema.sObjectType.Purchase_Order__c.fields.Proejct_PO_Number__c.isAccessible()
            && Schema.sObjectType.Purchase_Order__c.fields.Description__c.isAccessible()
            && Schema.sObjectType.Purchase_Order__c.fields.buildertek__PO_Amount__c.isAccessible()) {
            
            getPurchaseOrderList = [select id,Name,Proejct_PO_Number__c,Description__c,buildertek__PO_Amount__c from Purchase_Order__c order by Proejct_PO_Number__c desc];        
            
        }
        
        list<PurchaseOrderWrap> PurchaseOrderWraplist = new list<PurchaseOrderWrap>();
        for(Purchase_Order__c Pur : getPurchaseOrderList){
            PurchaseOrderWrap PurchaseOrderWrapRec = new PurchaseOrderWrap();
            PurchaseOrderWrapRec.getPurchaseOrderList = Pur;
            if(Pur.Id == recordId){
                PurchaseOrderWrapRec.purcheckbox = true;    
            }else{
                PurchaseOrderWrapRec.purcheckbox = false;    
            }
            PurchaseOrderWraplist.add(PurchaseOrderWrapRec);
        }
        return PurchaseOrderWraplist;
   }
   
    @AuraEnabled
    public static list < PurchaseOrderWrap > fetchPurchaseOrders(String sortField, boolean isAsc, String recordId) {
      String sSoql = 'select id, Name, buildertek__Proejct_PO_Number__c, buildertek__Description__c, buildertek__PO_Amount__c ';
      sSoql += 'From buildertek__Purchase_Order__c';
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
      list <buildertek__Purchase_Order__c> lstResult;
      try {
         system.debug('The query is' + sSoql);
        /*if(Schema.sObjectType.buildertek__Purchase_Order__c.fields.id.isAccessible()
            && Schema.sObjectType.buildertek__Purchase_Order__c.fields.Name.isAccessible()
             && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Proejct_PO_Number__c.isAccessible()
            && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Description__c.isAccessible()
             && Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__PO_Amount__c.isAccessible()){*/
           lstResult = Database.query(sSoql);
            /*}*/
         system.debug('lstResult -----------> '+lstResult);
         /*List < Purchase_Order__c > returnPOList = new List < Purchase_Order__c > ();
    
         for (Purchase_Order__c PO: lstResult) {
            returnPOList.add(PO);
         }*/
         list<PurchaseOrderWrap> PurchaseOrderWraplist = new list<PurchaseOrderWrap>();
         for(Purchase_Order__c Pur : lstResult){
            PurchaseOrderWrap PurchaseOrderWrapRec = new PurchaseOrderWrap();
            PurchaseOrderWrapRec.getPurchaseOrderList = Pur;
            if(Pur.Id == recordId){
                PurchaseOrderWrapRec.purcheckbox = true;    
            }else{
                PurchaseOrderWrapRec.purcheckbox = false;
            }
            PurchaseOrderWraplist.add(PurchaseOrderWrapRec);
         }
         return PurchaseOrderWraplist;
      } 
      catch (Exception ex) {
         // for handle Exception
         return null;
      }
    }
   
   @AuraEnabled
   public static list<QuoteWrap> getQuotelist(){
       list<Quote__c> getQuotelist;
       if (Schema.sObjectType.Quote__c.fields.Name.isAccessible() && Schema.sObjectType.Quote__c.fields.Id.isAccessible()){
            getQuotelist = [select id,Name from Quote__c limit 50000];    
       } 
       
       
       list<QuoteWrap> QuoteWraplist = new list<QuoteWrap>();
        for(Quote__c Pur : getQuotelist){
            QuoteWrap QuoteWrapRec = new QuoteWrap();
            QuoteWrapRec.getQuotelist = Pur;
            QuoteWrapRec.Quotecheckbox = false;
            QuoteWraplist.add(QuoteWrapRec);
        }
        return QuoteWraplist;
   }
   
   @AuraEnabled
   public static void AddPurchaseOrders(string Purchaselists,string QuoteWraps){
      // list<PurchaseOrderWrap> Purchaselist = Json.deserialize(Purchaselists,PurchaseOrderWrap);
      system.debug('QuoteWraps -------> '+QuoteWraps);
      system.debug('Purchaselists --------> '+Purchaselists);
       List<PurchaseOrderWrap> Purchaselist =   (List<PurchaseOrderWrap>)System.JSON.deserialize(Purchaselists, List<PurchaseOrderWrap>.class);
       
       list<Purchase_Order__c> getPurchaseOrderLists = new list<Purchase_Order__c>();
       system.debug('Purchaselist ' + Purchaselist);
       List<Quote_Item__c> quoteItemList = new List<Quote_Item__c>();
       List<Quote_Line_Group__c> quoteGroup;
       String groupId;
       if (Schema.sObjectType.Quote_Line_Group__c.fields.Id.isAccessible() 
           && Schema.sObjectType.Quote_Line_Group__c.fields.Name.isAccessible() ){
            quoteGroup = [select Id, Name from Quote_Line_Group__c where Name = 'No Grouping'];    
       }
       if(quoteGroup.size() > 0){
            groupId = quoteGroup[0].Id;   
       }else{
            Quote_Line_Group__c qutGroup = new Quote_Line_Group__c();
            if (Schema.sObjectType.Quote_Line_Group__c.fields.Name.isCreateable()){
                qutGroup.Name = 'No Grouping';     
            }
            insert qutGroup;
            groupId = qutGroup.Id;
       }
       
       buildertek__Quote_Line_Group__c newQuoteGroup = new buildertek__Quote_Line_Group__c();
       system.debug('quoteGroup ---------> '+groupId);
       for(PurchaseOrderWrap PurchaseRec : Purchaselist){
           if(PurchaseRec.purcheckbox == true){
                Purchase_Order__c Pur = new Purchase_Order__c();
                Pur.Id = PurchaseRec.getPurchaseOrderList.Id;
                Pur.Quote__c = QuoteWraps;
                getPurchaseOrderLists.add(pur);
                
                Quote_Item__c quote = new Quote_Item__c();
                quote.Quote__c = QuoteWraps;
                quote.Grouping__c = groupId;
                quote.Name = PurchaseRec.getPurchaseOrderList.Description__c;
                quote.Quantity__c = 1;
                quote.Unit_Cost__c = PurchaseRec.getPurchaseOrderList.PO_Amount__c;
                quoteItemList.add(quote);
           }
       }
       system.debug('quoteItemList -------->  ' + quoteItemList);
       system.debug('getPurchaseOrderList ' + getPurchaseOrderLists);
       if(Schema.sObjectType.Purchase_Order__c.fields.Quote__c.isCreateable()
          && Schema.sObjectType.Purchase_Order__c.fields.Quote__c.isUpdateable()
          && Schema.sObjectType.Purchase_Order__c.fields.id.isUpdateable()){
          
          upsert getPurchaseOrderLists;
                     
       }
       if(Schema.sObjectType.Quote_Item__c.fields.Quote__c.isCreateable()
          && Schema.sObjectType.Quote_Item__c.fields.Grouping__c.isCreateable()
          && Schema.sObjectType.Quote_Item__c.fields.Name.isCreateable()
          && Schema.sObjectType.Quote_Item__c.fields.Quantity__c.isCreateable()
          && Schema.sObjectType.Quote_Item__c.fields.Unit_Cost__c.isCreateable()){
          
          insert quoteItemList;
              
       }
       
       
   }
   
   public Class PurchaseOrderWrap{
       @AuraEnabled public boolean purcheckbox;
       @AuraEnabled public Purchase_Order__c getPurchaseOrderList;
   }
   
   public Class QuoteWrap{
       @AuraEnabled public boolean Quotecheckbox;
       @AuraEnabled public Quote__c getQuotelist;
   }
}