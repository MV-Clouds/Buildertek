public with sharing class DisplayContentsController {
    public string recordId { get; set; }
    public List<buildertek__Content__c> contentList { get; set; }
    public buildertek__Admin_Interface_Node_Configuration__c node { get; set; }
    public DisplayContentsController(){
        recordId = ApexPages.currentPage().getParameters().get('id'); 
        if(recordId != '' && recordId != null){
            if(Schema.sObjectType.buildertek__Admin_Interface_Node_Configuration__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Admin_Interface_Node_Configuration__c.fields.buildertek__Header_Text__c.isAccessible() ){
              node = [SELECT Id, buildertek__Header_Text__c from buildertek__Admin_Interface_Node_Configuration__c
                                            where Id =: recordId];
           }
             if(Schema.sObjectType.buildertek__Content__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Content__c.fields.Name.isAccessible() &&
    			Schema.sObjectType.buildertek__Content__c.fields.buildertek__Image__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Content__c.fields.buildertek__Index__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Content__c.fields.buildertek__Video_URL__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Content__c.fields.buildertek__Description__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Content__c.fields.buildertek__Admin_Interface_Node_Configuration__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Content__c.fields.buildertek__Index__c.isAccessible()){                               
                contentList = [SELECT Id, Name, buildertek__Image__c, buildertek__Index__c, buildertek__Video_URL__c, buildertek__Description__c
                                        from buildertek__Content__c where buildertek__Admin_Interface_Node_Configuration__c =: recordId
                                        order by buildertek__Index__c];
    			}
            system.debug('contentList -----------> '+contentList);                            
        }
    }
}