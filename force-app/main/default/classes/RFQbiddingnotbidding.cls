public without sharing class  RFQbiddingnotbidding{
    public String recordId {get; Set;}
    public String guestUserSite{get; set;}
    public String colorr { get; set;}
    public buildertek__RFQ_Template_Settings__c rfqTemplateSettings;
    
    
    public RFQbiddingnotbidding(){

    buildertek__Admin_Interface_Node_Configuration__c adminInterfaceNodeConfigurations = [SELECT Id,buildertek__Color_code__c
                                                                                              FROM buildertek__Admin_Interface_Node_Configuration__c
                                                                                              WHERE Name=:'RFQ Configuration'];
      if(adminInterfaceNodeConfigurations.buildertek__Color_code__c!=null){
      colorr=adminInterfaceNodeConfigurations.buildertek__Color_code__c;
      }
      else {
        colorr='#0176d3';
      }
      System.debug(colorr);         
        
        rfqTemplateSettings = buildertek__RFQ_Template_Settings__c.getOrgDefaults();
        system.debug('rfqTemplateSettings'+rfqTemplateSettings);
        guestUserSite = rfqTemplateSettings.buildertek__Sites_URL__c;
        system.debug('guestUserSite'+guestUserSite);
        system.debug('***'+buildertek__RFQ_Template_Settings__c.buildertek__Sites_URL__c);
    }
}