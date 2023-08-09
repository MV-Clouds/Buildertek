public with sharing class EmailPunchListsController {
    public list<buildertek__Punch_List__c> buildertekPunchList {get;set;}
    public String parentId {get;set;}
    public EmailPunchListsController(ApexPages.StandardSetController controller) {
        buildertekPunchList= (List<buildertek__Punch_List__c>) controller.getRecords();
        String referer = ApexPages.currentPage().getURL();
        if(referer != null){
            string[] parentlist = referer.split('id=');
        }
        parentId = ApexPages.currentPage().getParameters().get('id').escapeHtml4();
        // string parentids = '';
        // if(parentlist.size() > 1){
        //     string[] parentids = parentlist[1].split('');
        // }
        // system.debug(parentlist + ' Allll values ' + parentId);
        // list<string> buildertekSubmittalIdList = new list<string>();
        // for(buildertek__Submittal__c buildertekSubmit : buildertekSubmittal){
        //     buildertekSubmittalIdList.add(buildertekSubmit.Id);
        // }
        // list<buildertek__Submittal__c> buildertekSubmittalList = [select id, Name, buildertek__Responsible_Contact__c, buildertek__Responsible_Vendor__c,
        //                                                                 buildertek__Status__c,buildertek__Submitted_Date__c from buildertek__Submittal__c where Id IN: buildertekSubmittalIdList];
        
                                                                        
    }
    
    public EmailPunchListsController(){
    }
    
  
}