public with sharing class BT_AccountConfiguration {
    
    public Boolean nofityOnCertExpiration {get; set;}
    public Decimal certExpirationDays {get; set;}

    public BT_AccountConfiguration(){
        buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [Select Id, Name, buildertek__Days_pior_to_expiration__c, buildertek__Notify_on_Cert_Expiration__c from buildertek__Admin_Interface_Node_Configuration__c WHERE Name=:'Account Configuration' limit 1];
        nofityOnCertExpiration = adminInterfaceNodeConfigurations.buildertek__Notify_on_Cert_Expiration__c;
        certExpirationDays = adminInterfaceNodeConfigurations.buildertek__Days_pior_to_expiration__c;
    }
    
    public void updateAccountConfiguration(){
        buildertek__Admin_Interface_Node_Configuration__c[] adminInterfaceNodeConfigurations = [SELECT Id, Name, buildertek__Days_pior_to_expiration__c, buildertek__Notify_on_Cert_Expiration__c FROM buildertek__Admin_Interface_Node_Configuration__c WHERE Name = 'Account Configuration' LIMIT 1];
        System.debug('certExpirationDays: ' + certExpirationDays);
        if(adminInterfaceNodeConfigurations.size() > 0){
            adminInterfaceNodeConfigurations[0].buildertek__Notify_on_Cert_Expiration__c = nofityOnCertExpiration;
            adminInterfaceNodeConfigurations[0].buildertek__Days_pior_to_expiration__c = certExpirationDays;
            update adminInterfaceNodeConfigurations;
    
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Updated Successfully'));
        }
    }
}

