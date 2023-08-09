trigger ContentDocumentImageDelete on ContentDocument (before delete) {
    Set<Id> productId = new Set<Id>();
    List<buildertek__Question__c> questionsMapRecs=new List<buildertek__Question__c>();
    Set<Id> contentDocRecs = new Set<Id>();
    Map<Id,ContentVersion> contentRecs = new Map<Id,ContentVersion>();
    
    if(Trigger.isBefore && Trigger.isDelete){
        for (ContentDocument content: Trigger.old) {
            if(content.FileType=='jpeg' || content.FileType=='png' || content.FileType=='jpg'){
                contentDocRecs.add(content.Id);
            }
        }
        
        List<ContentVersion> contVersion =[SELECT Id,ContentDocumentId,FirstPublishLocationId FROM ContentVersion WHERE ContentDocumentId IN : contentDocRecs];
        for(ContentVersion conV: contVersion){
            contentRecs.put(conV.FirstPublishLocationId,conV);
        }
        
        questionsMapRecs =[Select Id,buildertek__Image_Id__c,buildertek__Product__c,buildertek__Document_Id__c FROM buildertek__Question__c WHERE Product__c IN : contentRecs.keySet()];
        if(questionsMapRecs.size()>0){
            for(buildertek__Question__c question: questionsMapRecs){
                if(contentRecs.containsKey(question.buildertek__Product__c)){
                    question.Image_Id__c='';
                    question.Document_Id__c='';
                }
            }
            update questionsMapRecs;
        }
    }    
}