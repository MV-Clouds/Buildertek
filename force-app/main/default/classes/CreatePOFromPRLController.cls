public class CreatePOFromPRLController {

     @AuraEnabled
    public static List<InnerClassPRLD> getPRLD(String recordId){
        List<buildertek__Pricing_Request_Line_Details__c> prldList = new   List<buildertek__Pricing_Request_Line_Details__c>();
        prldList = [select buildertek__Description__c,buildertek__Vendor__c,buildertek__Cost__c,buildertek__Price__c,buildertek__Quantity__c,buildertek__Vendor__r.Name from buildertek__Pricing_Request_Line_Details__c where buildertek__Pricing_Request_Line__c =: recordId AND (buildertek__RFQ_Lines__c = NULL AND (buildertek__RFQ__c = NULL AND buildertek__Purchase_Order__c = NULL) AND buildertek__Purchase_Order_Line__c = NULL) ORDER BY buildertek__Vendor__c  ASC NULLS last];
        buildertek__Pricing_Request_Line__c[] prl = [select id,buildertek__Description__c,buildertek__Pricing_Request__r.buildertek__Project__c,buildertek__Vendor__c from buildertek__Pricing_Request_Line__c where id =: recordId];
        
        List<String> ven = new List<String>();
        for(buildertek__Pricing_Request_Line_Details__c a : prldList){
            if(a.buildertek__Vendor__r.Name != null && a.buildertek__Vendor__r.Name != ''){
                ven.add(a.buildertek__Vendor__r.Name);
            }
        }
        System.debug('Vendor List : '+ven);
        List<InnerClassPRLD> innerList = new  List<InnerClassPRLD>();
        for(buildertek__Pricing_Request_Line_Details__c a : prldList){
            InnerClassPRLD b = new InnerClassPRLD();
            b.Description = a.buildertek__Description__c;
            b.Vendor = a.buildertek__Vendor__c;
            b.Cost = a.buildertek__Cost__c;
            b.Price = a.buildertek__Price__c;
            b.Quantity = a.buildertek__Quantity__c;
            b.VendorName = a.buildertek__Vendor__r.Name;
            b.isCheck = false;
            b.Id = a.Id;
            b.VendorId = prl[0].buildertek__Vendor__c;
            innerList.add(b);
        }
        return innerList;
    }
    
    public class InnerClassPRLD{
        @AuraEnabled public Boolean isCheck;
        @AuraEnabled public String Description;
        @AuraEnabled public String Vendor;
        @AuraEnabled public Decimal Cost;
        @AuraEnabled public Decimal Price;
        @AuraEnabled public Decimal Quantity;
        @AuraEnabled public String VendorName;
        @AuraEnabled public String Id;
        @AuraEnabled public String VendorId;
    }
    
    public class groupClassPRLD{
        @AuraEnabled public List<InnerClassPRLD> Record;
        @AuraEnabled public String vendor;
    }
    
    @AuraEnabled
    public static String insertRFQ(String recordId,List<String> Ids){
        buildertek__Pricing_Request_Line__c prl = [select id,buildertek__Description__c,buildertek__Pricing_Request__r.buildertek__Project__c from buildertek__Pricing_Request_Line__c where id =: recordId];
        buildertek__RFQ__c rfq = new buildertek__RFQ__c();
        rfq.Name = prl.buildertek__Description__c;
        rfq.buildertek__Pricing_Request_Line__c = recordId;
        rfq.buildertek__Project__c = prl.buildertek__Pricing_Request__r.buildertek__Project__c;
        insert rfq;
        System.debug('Id of RFQ : '+rfq.Id);
        List<buildertek__Pricing_Request_Line_Details__c> prldList = [select buildertek__Description__c,buildertek__Product__c,buildertek__Vendor__c,buildertek__Cost__c,buildertek__Price__c,buildertek__Quantity__c,buildertek__Vendor__r.Name from buildertek__Pricing_Request_Line_Details__c where buildertek__Pricing_Request_Line__c =: recordId AND id in :ids];
        List<buildertek__RFQ_Item__c> rfqLineList = new  List<buildertek__RFQ_Item__c>();
        for(buildertek__Pricing_Request_Line_Details__c prld : prldList){
            buildertek__RFQ_Item__c rfqline = new buildertek__RFQ_Item__c();
            rfqline.Name = prld.buildertek__Description__c;
            rfqline.buildertek__RFQ_Package__c = rfq.Id;
            rfqline.buildertek__Product__c = prld.buildertek__Product__c;
            rfqline.buildertek__Vendor__c = prld.buildertek__Vendor__c;
            rfqline.buildertek__Quantity__c = prld.buildertek__Quantity__c;
            rfqLine.buildertek__Unit_Price__c = prld.buildertek__Cost__c;
            rfqLine.buildertek__Pricing_Request_Line_Detail__c = prld.Id;
            rfqLineList.add(rfqline);
        }
        insert rfqLineList;
        prl.buildertek__RFQ__c = rfq.Id;   
        update prl;
        return rfq.Id;   
    } 
    @AuraEnabled
    public static List<buildertek__Pricing_Request_Line_Details__c> getPRLDsCheck(String recordId){
        List<buildertek__Pricing_Request_Line_Details__c> prldList = [select buildertek__Description__c,buildertek__Vendor__c,buildertek__Cost__c,buildertek__Price__c,buildertek__Quantity__c from buildertek__Pricing_Request_Line_Details__c where buildertek__Pricing_Request_Line__c =: recordId];
        return prldList;
    }
    
    
    @AuraEnabled
    public static String insertPO(String recordId,List<String> Ids,String Vendor){
        buildertek__Pricing_Request_Line__c[] prl = [select id,buildertek__Description__c,buildertek__Pricing_Request__r.buildertek__Project__c,buildertek__Purchase_Order__c,buildertek__Vendor__c from buildertek__Pricing_Request_Line__c where id =: recordId];
        if(prl.size() > 0){
            buildertek__Purchase_Order__c PO = new buildertek__Purchase_Order__c();
            if(prl[0].buildertek__Description__c != null){
                PO.buildertek__Description__c = prl[0].buildertek__Description__c;
            }
            PO.buildertek__Status__c = 'Open';
            PO.buildertek__Date_Created__c = System.Today();
            PO.buildertek__Project__c = prl[0].buildertek__Pricing_Request__r.buildertek__Project__c;
            if(prl[0].buildertek__Vendor__c != null){
                PO.buildertek__Vendor__c =  prl[0].buildertek__Vendor__c;
            }
            else{
                PO.buildertek__Vendor__c = Vendor;
            }
            insert PO;
            
            prl[0].buildertek__Purchase_Order__c = PO.Id;
            
            if( prl[0].buildertek__Vendor__c == null){
                prl[0].buildertek__Vendor__c  = PO.buildertek__Vendor__c;
            }
            update prl[0];
            
            Map<buildertek__Purchase_Order_Item__c,buildertek__Pricing_Request_Line_Details__c> mapPRL = new Map<buildertek__Purchase_Order_Item__c,buildertek__Pricing_Request_Line_Details__c>();
            List<buildertek__Pricing_Request_Line_Details__c> prldList = [select buildertek__Description__c,buildertek__Purchase_Order_Line__c,buildertek__Product__c,buildertek__Vendor__c,buildertek__Purchase_Order__c,buildertek__Cost__c,buildertek__Price__c,buildertek__Quantity__c,buildertek__Vendor__r.Name from buildertek__Pricing_Request_Line_Details__c where buildertek__Pricing_Request_Line__c =: recordId AND id in :ids];
            List<buildertek__Purchase_Order_Item__c> POItem = new  List<buildertek__Purchase_Order_Item__c>();
            System.debug('prldList>>>'+prldList);
            System.debug('prldList size>>>'+prldList.size());
            for(buildertek__Pricing_Request_Line_Details__c prld : prldList){
                buildertek__Purchase_Order_Item__c inPO = new buildertek__Purchase_Order_Item__c();
                inPO.Name = prld.buildertek__Description__c;
                inPO.buildertek__Purchase_Order__c = PO.Id;
                inPO.buildertek__Unit_Price__c = prld.buildertek__Cost__c;
                inPO.buildertek__Quantity__c = prld.buildertek__Quantity__c;
                inPO.buildertek__Product__c = prld.buildertek__Product__c;
                System.debug('prld>>>'+prld);
                mapPRL.put(inPO,prld);
                POItem.add(inPO);
            }
            if(POItem.size() > 0){
                insert POItem;
            }
            System.debug('map>>>>'+mapPRL);
            system.debug('here is map mapPRL ==> '+mapPRL.keySet());
            system.debug('here is list of mapPRL ==> '+mapPRL.values());
            system.debug('In insertPO method ');
            for(buildertek__Purchase_Order_Item__c poRecd : mapPRL.keySet()){
                system.debug('mapPRL ==>>> '+mapPRL);
                system.debug('Checking for poRecd null ID ==> '+poRecd.Id);
                system.debug('Checking for PO null ID ==> '+PO.Id);
                System.debug('mapPRL.get(poRecd)>>>'+mapPRL.get(poRecd));
                if(mapPRL.get(poRecd) != null){
                mapPRL.get(poRecd).buildertek__Purchase_Order__c = PO.Id;
                mapPRL.get(poRecd).buildertek__Purchase_Order_Line__c = poRecd.Id;
                }
                system.debug('Checking for null ID ==> '+poRecd.Id);
            }
            
            update mapPRL.values();
            return PO.Id;
        }
        else{
            return 'ERROR';
        }
    }
    
    @AuraEnabled
    public static buildertek__Pricing_Request_Line__c getPRL(String recordId){
        buildertek__Pricing_Request_Line__c prl = [select id,buildertek__Description__c,buildertek__Pricing_Request__r.buildertek__Project__c,buildertek__Vendor__c from buildertek__Pricing_Request_Line__c where id =: recordId];
        return prl;
        
    }
}