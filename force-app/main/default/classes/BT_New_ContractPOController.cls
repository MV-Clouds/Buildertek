public class BT_New_ContractPOController {
    @AuraEnabled
    public static string createlines( String conId){
        system.debug('***' +conId);
        Account accRec = [Select id, Name from Account limit 1];
        buildertek__Contract__c contract = [select id,Name,buildertek__Budget__c,buildertek__Description__c,buildertek__Project__c,buildertek__Project__r.buildertek__Customer__c,
                                              buildertek__Vendor__c from buildertek__Contract__c where id =: conId ];
        system.debug(contract);
        buildertek__Purchase_Order__c purchaserec = new buildertek__Purchase_Order__c();
        purchaserec.buildertek__Description__c = contract.buildertek__Description__c;
        purchaserec.buildertek__Project__c = contract.buildertek__Project__c; 
        purchaserec.buildertek__Sub_Contract__c = conId; 
        system.debug('contract.buildertek__Vendor__c--->'+contract.buildertek__Vendor__c);  
        if(contract.buildertek__Vendor__c != null){
          purchaserec.buildertek__Vendor__c = contract.buildertek__Vendor__c; 
        }else if(contract.buildertek__Project__r.buildertek__Customer__c != null){
             purchaserec.buildertek__Vendor__c = contract.buildertek__Project__r.buildertek__Customer__c;
        }else{
           purchaserec.buildertek__Vendor__c = accRec.id;
        }
        system.debug(purchaserec);
        insert purchaserec;
        system.debug(purchaserec);
        List<buildertek__Contract_Item__c> contactlines = [select id,Name,buildertek__Notes__c,buildertek__Description__c,buildertek__Product__c,buildertek__Contract__c,buildertek__Unit_Price__c,
                                                           buildertek__Quantity__c,buildertek__Cost_Code__c,buildertek__Item_Name__c,buildertek__Discount__c from 
                                                           buildertek__Contract_Item__c where buildertek__Contract__c =: conId ];
        list<buildertek__Purchase_Order_Item__c> polist = new list<buildertek__Purchase_Order_Item__c>();
        for(buildertek__Contract_Item__c contactlineRec : contactlines){
            buildertek__Purchase_Order_Item__c poRec = new buildertek__Purchase_Order_Item__c();
            poRec.buildertek__Item_Name__c = contactlineRec.buildertek__Item_Name__c;
            poRec.buildertek__Product__c = contactlineRec.buildertek__Product__c;
            poRec.buildertek__Unit_Price__c = contactlineRec.buildertek__Unit_Price__c;
            poRec.buildertek__Quantity__c = contactlineRec.buildertek__Quantity__c;
            poRec.buildertek__Cost_Code__c = contactlineRec.buildertek__Cost_Code__c;
            poRec.buildertek__Item_Name__c = contactlineRec.buildertek__Item_Name__c;
            poRec.buildertek__Discount__c = contactlineRec.buildertek__Discount__c;
             poRec.buildertek__Notes__c = contactlineRec.buildertek__Notes__c;
            poRec.buildertek__Description__c = contactlineRec.buildertek__Description__c;
           // poRec.buildertek__Auto_Number__c = contactlineRec.buildertek__Auto_Number__c;
            poRec.Name = contactlineRec.Name;
            poRec.buildertek__Purchase_Order__c = purchaserec.id;
            polist.add(poRec);
            system.debug(polist);
        }
        if(polist.size() > 0){
            insert polist;
            
        }
        system.debug(polist);
        return  purchaserec.id;
    }
    
    
     @AuraEnabled
    public static string create( String conId , Integer unit){
        system.debug('***' +unit);
        Account accRec = [Select id, Name from Account limit 1];
        buildertek__Contract__c contract = [select id,Name,buildertek__Budget__c,buildertek__Description__c,buildertek__Project__c,buildertek__Project__r.buildertek__Customer__c,
                                                   buildertek__Vendor__c from buildertek__Contract__c where id =: conId ];
        system.debug(contract);
        buildertek__Purchase_Order__c purchaserec = new buildertek__Purchase_Order__c();
        purchaserec.buildertek__Description__c = contract.buildertek__Description__c;
        purchaserec.buildertek__Project__c = contract.buildertek__Project__c; 
        purchaserec.buildertek__Sub_Contract__c = conId; 
        system.debug('contract.buildertek__Vendor__c--->'+contract.buildertek__Vendor__c);
        if(contract.buildertek__Vendor__c != null){
          purchaserec.buildertek__Vendor__c = contract.buildertek__Vendor__c; 
        }else if(contract.buildertek__Project__r.buildertek__Customer__c != null){
             purchaserec.buildertek__Vendor__c = contract.buildertek__Project__r.buildertek__Customer__c;
        }else{
           purchaserec.buildertek__Vendor__c = accRec.id;
        }
        system.debug(purchaserec);
        insert purchaserec;
        system.debug(purchaserec);
        List<buildertek__Contract_Item__c> contactlines = [select id,Name,buildertek__Notes__c,buildertek__Description__c,buildertek__Item_Name__c,buildertek__Product__c,buildertek__Contract__c,buildertek__Quantity__c,buildertek__Cost_Code__c,
                                                          buildertek__Unit_Price__c,buildertek__Discount__c from 
                                                           buildertek__Contract_Item__c where buildertek__Contract__c =: conId ];
        list<buildertek__Purchase_Order_Item__c> polist = new list<buildertek__Purchase_Order_Item__c>();
        for(buildertek__Contract_Item__c contactlineRec : contactlines){
            buildertek__Purchase_Order_Item__c poRec = new buildertek__Purchase_Order_Item__c();
            poRec.buildertek__Item_Name__c = contactlineRec.buildertek__Item_Name__c;
            poRec.buildertek__Product__c = contactlineRec.buildertek__Product__c;
            poRec.buildertek__Purchase_Order__c = purchaserec.id;
            porec.buildertek__Unit_Price__c = unit;
            poRec.buildertek__Quantity__c = contactlineRec.buildertek__Quantity__c;
            poRec.buildertek__Cost_Code__c = contactlineRec.buildertek__Cost_Code__c;
            poRec.buildertek__Item_Name__c = contactlineRec.buildertek__Item_Name__c;
            poRec.buildertek__Discount__c = contactlineRec.buildertek__Discount__c;
            poRec.buildertek__Notes__c = contactlineRec.buildertek__Notes__c;
            poRec.buildertek__Description__c = contactlineRec.buildertek__Description__c;
          //  poRec.buildertek__Auto_Number__c = contactlineRec.buildertek__Auto_Number__c;
            poRec.Name = contactlineRec.Name;
            system.debug( porec.buildertek__Unit_Price__c);
            polist.add(poRec);
            system.debug(polist);
        }
        if(polist.size() > 0){
            insert polist;
            
        }
        system.debug(polist);
        return  purchaserec.id;
    }
    
}