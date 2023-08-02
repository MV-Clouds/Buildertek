public with sharing class POSubContractController {
    @AuraEnabled
    public static String createContractRec(String recordId){
        String ContractRecId='';
        List<buildertek__Purchase_Order__c> purchaseOrderRecs;
        if(Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isAccessible() &&
        Schema.sObjectType.buildertek__Purchase_Order__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Tax__c.isAccessible()&&
            Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isAccessible() &&
			Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isAccessible()){
            purchaseOrderRecs=[select id,name,buildertek__Tax__c,buildertek__Vendor__c,buildertek__Project__c from buildertek__Purchase_Order__c where id=:recordId];
			}
        if(purchaseOrderRecs.size()>0){
            Id devRecordTypeId = Schema.SObjectType.buildertek__Contract__c.getRecordTypeInfosByName().get('Sub Contract').getRecordTypeId();
            
            buildertek__Contract__c contractRec= new buildertek__Contract__c();
            contractRec.Name=purchaseOrderRecs[0].Name +' Sub Contract';
            contractRec.buildertek__Status__c='Approved';
            contractRec.buildertek__Vendor__c=purchaseOrderRecs[0].buildertek__Vendor__c;
            contractRec.buildertek__Tax_Rate__c=purchaseOrderRecs[0].buildertek__Tax__c;
            contractRec.buildertek__Project__c=purchaseOrderRecs[0].buildertek__Project__c;
            contractRec.RecordTypeId=devRecordTypeId;
            DateTime dt=System.now();
            contractRec.buildertek__Signed_Contract_Date__c=Date.newInstance(dt.year(),dt.month(),dt.day());
            if(Schema.sObjectType.buildertek__Contract__c.isCreateable()&&
                Schema.sObjectType.buildertek__Contract__c.fields.Name.isCreateable()&&
                Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Status__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Vendor__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Tax_Rate__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Project__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Contract__c.fields.RecordTypeId.isCreateable() &&
    			Schema.sObjectType.buildertek__Contract__c.fields.buildertek__Signed_Contract_Date__c.isCreateable()){ 
                insert contractRec;
    			}
            if(contractRec.Id!=null){
                ContractRecId=contractRec.Id;
                purchaseOrderRecs[0].buildertek__Sub_Contract__c=contractRec.Id;
                if(Schema.sObjectType.buildertek__Purchase_Order__c.fields.Id.isUpdateable() &&
                    Schema.sObjectType.buildertek__Purchase_Order__c.fields.Name.isUpdateable()&&
                    Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Tax__c.isUpdateable()&&
                    Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Vendor__c.isUpdateable() &&
        			Schema.sObjectType.buildertek__Purchase_Order__c.fields.buildertek__Project__c.isUpdateable()){
                   update purchaseOrderRecs;
        			}
                List<buildertek__Purchase_Order_Item__c> purchaseOrderItem = new List<buildertek__Purchase_Order_Item__c>();
                if(Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Tax__c.isAccessible()&&
                Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Product__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Purchase_Order_Item__c.fields.buildertek__Quantity__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Product__c.fields.Name.isAccessible() ){
                purchaseOrderItem=[select id,buildertek__Tax__c,buildertek__Quantity__c,buildertek__Product__r.Name,buildertek__Unit_Price__c,buildertek__Product__c from buildertek__Purchase_Order_Item__c where buildertek__Purchase_Order__c= :recordId];
    			}
                List<buildertek__Contract_Item__c> contractItem = new List<buildertek__Contract_Item__c>();
                for(buildertek__Purchase_Order_Item__c oi : purchaseOrderItem){
                    buildertek__Contract_Item__c contractItemRec = new buildertek__Contract_Item__c();
                    if(oi.buildertek__Product__r.Name != null){
                     	contractItemRec.Name= oi.buildertek__Product__r.Name;   
                    }else{
                        contractItemRec.Name= contractRec.Name +' item';
                    }
                    contractItemRec.buildertek__Contract__c=contractRec.Id;
                    contractItemRec.buildertek__Quantity__c=oi.buildertek__Quantity__c;
                    contractItemRec.buildertek__Unit_Price__c=oi.buildertek__Unit_Price__c;
                    contractItemRec.buildertek__Product__c=oi.buildertek__Product__c;
                    
                    contractItem.add(contractItemRec);
                }
                if(Schema.sObjectType.buildertek__Contract_Item__c.isCreateable()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.Name.isCreateable()&&
                Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Contract__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Quantity__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Unit_Price__c.isCreateable() &&
    			Schema.sObjectType.buildertek__Contract_Item__c.fields.buildertek__Product__c.isCreateable()){
                insert contractItem;
    			}
            }
        }
        return ContractRecId;
    }
}