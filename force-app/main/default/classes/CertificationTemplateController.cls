public class CertificationTemplateController {
    @AuraEnabled    
    public static void updateCourse(String id, string templatename){
        if(templatename!=null){
            system.debug('templatename-->'+templatename);
            buildertek__Course__c rec = new buildertek__Course__c();
            rec.Id= id;
            rec.buildertek__Certification_Template__c = templatename;
            update rec;
            system.debug('rec--->'+rec);
        }
        
        
    }
}