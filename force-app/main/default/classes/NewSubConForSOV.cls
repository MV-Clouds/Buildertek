public class NewSubConForSOV {
    @AuraEnabled
    public static buildertek__Schedule_of_Values__c getSOVDetails(String recordId){
        buildertek__Schedule_of_Values__c SOVRec = [select Id, buildertek__Project__c, buildertek__Vendor__c from buildertek__Schedule_of_Values__c where Id =: recordId];
        return SOVRec;
    }
    
    
    @AuraEnabled
    public static Id recTypeId(String recordId){
        
        Id recordTypeId =
            Schema.SObjectType.buildertek__Contract__c.getRecordTypeInfosByName().get('Sub Contract').getRecordTypeId();       
        return recordTypeId;
    }
    
    
    @AuraEnabled
    public static string createContract(String recordId,string SovId){
        
       list<buildertek__Schedule_of_Value_Lines__c> SOVLineList = [select Id, Name, buildertek__Description_of_Work__c,buildertek__Scheduled_Value__c, buildertek__Schedule_of_Values__c from buildertek__Schedule_of_Value_Lines__c where buildertek__Schedule_of_Values__c =:SovId];
        
        list<buildertek__Contract_Item__c> ContractLineList = new list<buildertek__Contract_Item__c>();
        for(buildertek__Schedule_of_Value_Lines__c sovLine : SOVLineList){
            buildertek__Contract_Item__c paymentRec = new buildertek__Contract_Item__c();
            paymentRec.buildertek__Item_Name__c = sovLine.Name;
            paymentRec.Name = sovLine.Name;
            paymentRec.buildertek__Quantity__c = 1;
            paymentRec.buildertek__Description__c = sovLine.buildertek__Description_of_Work__c;
            paymentRec.buildertek__Unit_Price__c = sovLine.buildertek__Scheduled_Value__c;
            paymentRec.buildertek__Contract__c = recordId;
            ContractLineList.add(paymentRec);
        }
        
        if(ContractLineList.size()>0){
            insert ContractLineList;
            return 'success';
        }else{
            return null;
        }
        
    }
    
    
}