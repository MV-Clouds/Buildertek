/* **************************************************************************
* Copyright 2016-2017, BuilderTek
* All rights reserved
*
* Controller Class: AmazonS3Credential
* Created by Sagar: 06/05/2017
*
* - Used to fetch the AWS credentials from custom setting.

* - Modifications:
* - Sagar, 06/05/2017 – Initial Development
************************************************************************** */
public with sharing class AmazonS3Credential {
    //Exception thrown incase creadential is not available
    public class AmazonS3CredentialException extends Exception {}

    //Credential custom setting record
    public Amazon_S3_Key__c configForPublicKey{get; set;}
    public Amazon_S3_Key__c configForSecretKey{get; set;}
    public Application_Configuration__c configForMaxFileSize{get; set;}
    
    //Public Key
    public string key { 
        get { return configForPublicKey.Configured_value__c; } 
        public set; 
    }
    
    //Secret Key
    public string secret { 
        get { return configForSecretKey.Configured_value__c; } 
        private set; 
    }
  
    public AmazonS3Credential() {
        try {
            //Getting the Application Configuration.
            Map<String, Application_Configuration__c> appConfigurationMap = Application_Configuration__c.getAll();
            Map<String, Amazon_S3_Key__c> awsS3KeyMap = Amazon_S3_Key__c.getAll();
            system.debug('awsS3KeyMap ----------> '+awsS3KeyMap);
            configForPublicKey = awsS3KeyMap.get(BT_Constants.AWS_PUBLIC_KEY);
            configForSecretKey = awsS3KeyMap.get(BT_Constants.AWS_SECRET_KEY);
            configForMaxFileSize = appConfigurationMap.get(BT_Constants.MAX_FILE_SIZE);
            system.debug('awsS3KeyMapconfigForSecretKey ----------> '+configForSecretKey);
             system.debug('awsS3KeyMapconfigForPublicKey ----------> '+configForPublicKey);
            //Check that Key__c is not null
            if(configForPublicKey == null || configForPublicKey.Configured_value__c == null || configForPublicKey.Configured_value__c == ''){
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, System.label.No_Amazon_Key_Error);
                ApexPages.addMessage(errorMsg);
                throw new AmazonS3CredentialException(System.label.No_Amazon_Key_Error);   
            }
          
            //Check that Secret__c is not null
            if(configForSecretKey == null || configForSecretKey.Configured_value__c == null || configForSecretKey.Configured_value__c == ''){
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.FATAL, System.label.No_Amazon_Key_Error);
                ApexPages.addMessage(errorMsg);
                throw new AmazonS3CredentialException(System.label.No_Amazon_Key_Error);   
            }
        } catch (QueryException queryEx) {
          throw new AmazonS3CredentialException(System.label.No_Amazon_Key_Error);
        }
    }
}