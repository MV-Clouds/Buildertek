public with sharing class DisplayProosalImages {
    public List<buildertek__Proposal_Images__c> proposalImagesList { get; set; }
    public String recordId { get; set; }
    public Boolean isRecordId { get; set; }
    public DisplayProosalImages(){
        isRecordId = false;
        if(Schema.sObjectType.buildertek__Proposal_Images__c.fields.Id.isAccessible()&&
                Schema.sObjectType.buildertek__Proposal_Images__c.fields.buildertek__Image__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Proposal_Images__c.fields.buildertek__Description__c.isAccessible() &&
    			Schema.sObjectType.buildertek__Proposal_Images__c.fields.buildertek__Proposal__c.isAccessible() ){
               proposalImagesList = [SELECT Id, 
                                     buildertek__Description__c, 
                                     buildertek__Image__c 
                                     FROM buildertek__Proposal_Images__c 
                                     WHERE buildertek__Proposal__c =: recordId]; 
    	}
        system.debug('proposalImagesList --------> '+proposalImagesList);  
        if(proposalImagesList.size() > 0){
            isRecordId = true;        
        }
    }
}