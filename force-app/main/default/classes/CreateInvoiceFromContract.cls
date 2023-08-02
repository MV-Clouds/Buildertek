public without sharing class CreateInvoiceFromContract {
    @AuraEnabled
    public Static ResponseBase CreateInvoiceMethod(string ContractId){
        ResponseBase response = new ResponseBase();
        //try {
            buildertek__Contract__c co;
            system.debug('ContractId**'+ContractId);
            /* if(Schema.sObjectType.buildertek__Contract__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Contract__c.fields.Name.isAccessible()&&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Project__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Change_Order_Amount__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Change_Order__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Status__c.isAccessible() &&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Vendor__c.isAccessible() &&
                Schema.sObjectType.buildertek__Change_Order__c.fields.Name.isAccessible() &&
                Schema.sObjectType.buildertek__Change_Order__c.fields.Tax_Rate__c.isAccessible()){*/
                                        co= [select Id, 
                                                 Name, 
                                                 buildertek__Project__c, 
                                                 buildertek__Change_Order_Amount__c, 
                                                 buildertek__Change_Order__c,
                                                 buildertek__Change_Order__r.Name,
                                                 buildertek__Change_Order__r.Tax_Rate__c,
                                                 buildertek__Tax_Rate__c,
                                                 buildertek__Status__c,buildertek__Vendor__c,RecordTypeId,recordType.Name
                                                 from buildertek__Contract__c 
                                                 where Id =: ContractId];
        string prid = '';
        list<buildertek__Purchase_Order__c> purchaselist = [select id,Name,buildertek__Project__c from buildertek__Purchase_Order__c where buildertek__Sub_Contract__c =: co.id order by CreatedDate limit 1];
         for(buildertek__Purchase_Order__c purchaseRec : purchaselist){
                if(purchaseRec.id != null){
                  prid =   purchaseRec.id;
                }
         }
              //  }
        if(co.recordType.Name == 'Prime Contract'){
            Billings__c AR = new Billings__c();
            AR.buildertek__Project__c = co.buildertek__Project__c;
            AR.buildertek__Status__c = 'Open';
            AR.buildertek__Customer_Account__c = co.buildertek__Vendor__c;
            AR.Change_order__c = co.buildertek__Change_Order__c;
            AR.Tax_Rate__c = co.buildertek__Change_Order__r.Tax_Rate__c;
            AR.buildertek__Approved_CO__c = co.buildertek__Change_Order_Amount__c;
            AR.buildertek__Tax_Rate__c = co.buildertek__Tax_Rate__c;
            Ar.Name = co.Name;
            Ar.Contract__c = co.Id;
            /*if(Schema.sObjectType.Billings__c.isCreateable() &&
            Schema.sObjectType.Billings__c.fields.buildertek__Project__c.isCreateable() &&
            Schema.sObjectType.Billings__c.fields.buildertek__Status__c.isCreateable() &&
            Schema.sObjectType.Billings__c.fields.buildertek__Customer_Account__c.isCreateable() &&
            Schema.sObjectType.Billings__c.fields.Change_order__c.isCreateable()&&
            Schema.sObjectType.Billings__c.fields.Tax_Rate__c.isCreateable() &&
            Schema.sObjectType.Billings__c.fields.buildertek__Approved_CO__c.isCreateable() &&
            Schema.sObjectType.Billings__c.fields.Name.isCreateable() &&
            Schema.sObjectType.Billings__c.fields.Contract__c.isCreateable()){*/
            insert AR;
            //}
            
            List<Billable_Lines__c> arLines = new List<Billable_Lines__c>();
            List<buildertek__Contract_Item__c> coItemList;
           /* if(Schema.sObjectType.buildertek__Contract_Item__c.fields.id.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.Cost_Code__c.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.Description__c.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.Item_Name__c.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.Product__c.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.Quantity__c.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.Unit_Price__c.isAccessible()
                && Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract__c.isAccessible()){*/
                coItemList =  [select Id, 
                                         Name,
                                         Cost_Code__c,
                                         Description__c,
                                         Item_Name__c,
                                         Product__c,
                                         Quantity__c,
                                         Unit_Price__c,
                                         Notes__c ,
                                         buildertek__Tax__c
                                         from buildertek__Contract_Item__c 
                                         where buildertek__Contract__c =:co.Id];   
            //}
            for(buildertek__Contract_Item__c coItem : coItemList){
                
                Billable_Lines__c arItem = new Billable_Lines__c();
                
                arItem.Billings__c = AR.Id;
                arItem.Line_Title__c = coItem.Item_Name__c;
                arItem.Cost_Code__c = coItem.Cost_Code__c;
                arItem.Description__c = coItem.Name;
                arItem.Product__c = coItem.Product__c;
                arItem.Unit_Price__c = coItem.Unit_Price__c;
                arItem.Quantity__c = coItem.Quantity__c;
                arItem.Notes__c = coItem.Notes__c;
                arItem.Contract_Line__c = coItem.Id;
                arItem.buildertek__Tax_Rate__c = coItem.buildertek__Tax__c;

                arLines.add(arItem);
            }
           /*  if(Schema.sObjectType.Billable_Lines__c.isCreateable() &&
            Schema.sObjectType.Billable_Lines__c.fields.Billings__c.isCreateable() &&
            Schema.sObjectType.Billable_Lines__c.fields.Line_Title__c.isCreateable() &&
            Schema.sObjectType.Billable_Lines__c.fields.Description__c.isCreateable() &&
            Schema.sObjectType.Billable_Lines__c.fields.Cost_Code__c.isCreateable()&&
            Schema.sObjectType.Billable_Lines__c.fields.Product__c.isCreateable() &&
            Schema.sObjectType.Billable_Lines__c.fields.Contract_Line__c.isCreateable() &&
            Schema.sObjectType.Billable_Lines__c.fields.Quantity__c.isCreateable() &&
            Schema.sObjectType.Billable_Lines__c.fields.Unit_Price__c.isCreateable()){*/
            insert arLines;
            
            response.strMessage = 'Success';
            response.strRecordId = AR.Id;
           // }
        }else if(co.recordType.Name == 'Sub Contract'){
            buildertek__Account_Payable__c AP = new buildertek__Account_Payable__c();
           // for(buildertek__Purchase_Order__c purchaseRec : purchaselist){
                if(prid != null && prid != ''){
                AP.buildertek__Project__c = co.buildertek__Project__c;
                AP.buildertek__Status__c = 'Open';
                AP.buildertek__Vendor__c = co.buildertek__Vendor__c;
                // AP.Change_order__c = co.buildertek__Change_Order__c;
                AP.buildertek__Tax__c = co.buildertek__Change_Order__r.Tax_Rate__c;
                //   AP.buildertek__Approved_CO__c = co.buildertek__Change_Order_Amount__c;
                AP.buildertek__Description__c = co.Name;
                AP.buildertek__Contract__c = co.Id;
                AP.buildertek__Purchase_Order__c = prid;
           // }
            insert AP;
            List<buildertek__Account_Payable_Item__c> apLines = new List<buildertek__Account_Payable_Item__c>();
            List<buildertek__Contract_Item__c> coItemList;
            coItemList =  [select Id, 
                           Name,
                           Cost_Code__c,
                           Description__c,
                           Item_Name__c,
                           Product__c,
                           Quantity__c,
                           Unit_Price__c,
                           Notes__c 
                           from buildertek__Contract_Item__c 
                           where buildertek__Contract__c =:co.Id];   
            for(buildertek__Contract_Item__c coItem : coItemList){
                buildertek__Account_Payable_Item__c apItem = new buildertek__Account_Payable_Item__c();
                apItem.buildertek__Account_Payable__c = AP.Id;
                apItem.buildertek__Item_Title__c = coItem.Item_Name__c;
                apItem.Cost_Code__c = coItem.Cost_Code__c;
                apItem.Description__c = coItem.Name;
                apItem.Product__c = coItem.Product__c;
                apItem.Unit_Price__c = coItem.Unit_Price__c;
                apItem.Quantity__c = coItem.Quantity__c;
                // apItem.Notes__c = coItem.Notes__c;
                apItem.Contract_Line__c = coItem.Id;
                apLines.add(apItem);
            }
                insert apLines;
                response.strMessage = 'Success';
                response.strRecordId = AP.Id;
            }else{
                response.strMessage = 'No PR';
                response.strRecordId = '';
            }
        }
            return response;
       /* } 
        catch(Exception ex){
            system.debug(ex + ' ex.getMessage() ' + ex.getMessage());
            response.strMessage = ex.getMessage();
            return response;
        }*/
    }
    
    public virtual class ResponseBase {
        @AuraEnabled public Boolean isSuccess;
        @AuraEnabled public String strMessage;
        @AuraEnabled public String strRecordId;
    }

}