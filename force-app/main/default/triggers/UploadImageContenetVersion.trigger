trigger UploadImageContenetVersion on ContentVersion (after insert,after update, before delete) {
    
    Set<Id> originId = new Set<Id>();
    //Set<Id> rfqId = new Set<Id>();
    Set<Id> contenetDocId = new Set<Id>();
    Map<Id,buildertek__Question__c> questionsMapRecs=new Map<Id,buildertek__Question__c>();
    Map<Id,ContentVersion> contentRecs = new Map<Id,ContentVersion>();
    List<ContentDistribution> conDistribution = new List<ContentDistribution>();
    if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter){
        for (ContentVersion content: Trigger.new) {
            if (String.isNotBlank(content.FirstPublishLocationId)){ //&& (content.FileType=='jpeg' || content.FileType=='png' || content.FileType=='gif' || content.FileType=='jpg')
                if(Id.valueOf(content.FirstPublishLocationId).getSObjectType().getDescribe().getName() == 'Product'){
                    contenetDocId.add(content.ContentDocumentId);
                    originId.add(content.FirstPublishLocationId); 
                    contentRecs.put(content.FirstPublishLocationId,content);
                }/*else if(Id.valueOf(content.FirstPublishLocationId).getSObjectType().getDescribe().getName() == 'buildertek__RFQ__c'){
                    rfqId.add(content.Id); 
                }*/
            }
        }  
        if(ContentVersionTriggerHandler.isSkip){
            ContentVersionTriggerHandler.onAfterInsert(Trigger.new);
        }
        /*for(Id conVer : rfqId){
            ContentDistribution cd = new ContentDistribution();
            cd.name = 'PO';
            cd.ContentVersionId = conVer;
            cd.PreferencesAllowOriginalDownload = true;
            cd.PreferencesAllowPDFDownload = true;
            cd.PreferencesAllowViewInBrowser = true;
            conDistribution.add(cd);
        }
        insert conDistribution;*/
        if(contenetDocId.size()>0){
            Map<Id,buildertek__Question__c> questionsMap = new Map<Id,buildertek__Question__c>([Select Id,buildertek__Image_Id__c,buildertek__Product__c,buildertek__Document_Id__c FROM buildertek__Question__c WHERE Product__c IN : originId]);
            for(buildertek__Question__c question: questionsMap.values()){
                for(ContentVersion content:contentRecs.values()){
                    if(content.FirstPublishLocationId==question.buildertek__Product__c){
                        question.Image_Id__c=content.Id;
                        question.Document_Id__c=content.ContentDocumentId;
                        questionsMapRecs.put(question.Id, question);
                    }
                }
            }
            update questionsMapRecs.values();
            
            Map<Id,ContentDocumentLink> contenetDocLinks = new Map<Id,ContentDocumentLink>([SELECT Id, LinkedEntityId, ContentDocumentId, ShareType, Visibility FROM ContentDocumentLink  WHERE ContentDocumentId IN : contenetDocId]);
            for(ContentDocumentLink contenetDocLink : contenetDocLinks.values()){  
                contenetDocLink.Visibility ='AllUsers';
            }
            update contenetDocLinks.values();
        }
    }    
}