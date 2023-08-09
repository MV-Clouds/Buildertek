public with sharing class ImportSchedule_Clone {
    public list<buildertek__schedule__c> buildertekSchedule {get;set;}
    public String parentId {get;set;}
    public ImportSchedule_Clone(ApexPages.StandardSetController controller) {
        buildertekSchedule = (List<buildertek__schedule__c>) controller.getRecords();
        String referer = ApexPages.currentPage().getURL();
        system.debug('referer ---------> '+referer);
        if(referer != null){
            string[] parentlist = referer.split('id=');
        }
        parentId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        system.debug('parentId ---------> '+parentId);                                                                
    }
    
    public ImportSchedule_Clone(){
    }
    
  
}