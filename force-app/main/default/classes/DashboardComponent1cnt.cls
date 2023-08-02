public with sharing class DashboardComponent1cnt {
    
    @AuraEnabled
    public static List<buildertek__Contract__c> getContract(){
        Id currentuserId = UserInfo.getUserId();
         System.debug('@currentuserId@'+ currentuserId);
        List<buildertek__Contract__c > ContractLst;
         if(Schema.sObjectType.buildertek__Contract__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Contract__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Contract__c.fields.CreatedDate.isAccessible() && 
            Schema.sObjectType.User.fields.Name.isAccessible() &&
            Schema.sObjectType.User.fields.Id.isAccessible()){
            ContractLst= [SELECT Id, Name, CreatedDate, CreatedBy.Name FROM buildertek__Contract__c Where CreatedBy.Id =: currentuserId];
			}
        System.debug('@ContractLst@'+ ContractLst);
        return ContractLst;
    }
    
}