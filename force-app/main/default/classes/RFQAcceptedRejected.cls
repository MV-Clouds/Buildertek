public without sharing class  RFQAcceptedRejected{
    public String recordId {get; Set;}
    public String guestUserSite{get; set;}
    public buildertek__RFQ_Template_Settings__c rfqTemplateSettings;
    
    public RFQAcceptedRejected(){        
        rfqTemplateSettings = buildertek__RFQ_Template_Settings__c.getOrgDefaults();
        system.debug('rfqTemplateSettings'+rfqTemplateSettings);
        guestUserSite = rfqTemplateSettings.buildertek__Sites_URL__c;
        system.debug('guestUserSite'+guestUserSite);
        system.debug('***'+buildertek__RFQ_Template_Settings__c.buildertek__Sites_URL__c);
    }
}