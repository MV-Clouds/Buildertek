public class new_filePreviewController {

    @AuraEnabled
    public static Map<Id, list<ContentVersion>> getRelatedFiles(List<Id> lstParentIds) {
        List<buildertek__Project_Task__c> taskList = [Select Id,Name,buildertek__Reference_for_Import__c from buildertek__Project_Task__c where Id IN: lstParentIds];
        Set<String> taskIdList = new Set<String>();
        system.debug(taskList);
        if(taskList.size() > 0){
            for(buildertek__Project_Task__c item: taskList){
                taskIdList.add(item.Id);
                if(item.buildertek__Reference_for_Import__c != null){
                    taskIdList.add(item.buildertek__Reference_for_Import__c);
                }

            }

        }

        set<Id> contentDocumentIds = new Set<Id>();
        for(ContentDocumentLink conDoc : [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN: taskIdList]){
            contentDocumentIds.add(conDoc.ContentDocumentId);
        }
        //get all the content notes using contentDocumentIds
        List<ContentNote> contentNotes = [SELECT Id,Content,Title,TextPreview,CreatedDate from ContentNote where Id In: contentDocumentIds order by CreatedDate ASC];
        Set<Id> noteIds = new Set<Id>();
        for(ContentNote item : contentNotes){
            noteIds.add(item.Id);
        }


        system.debug(taskIdList);
           map<Id, list<ContentVersion>> mapParentIdAndFiles = new map<Id, list<ContentVersion>>();
           map<Id, Id> mapCntIdParentId = new map<Id, Id>();
            //lstParentIds
           for(ContentDocumentLink cntLink : [Select Id, ContentDocumentId, LinkedEntityId From ContentDocumentLink Where LinkedEntityId IN: taskIdList ]) {
              system.debug(cntLink);
                mapCntIdParentId.put(cntLink.ContentDocumentId, cntLink.LinkedEntityId);
           }

           if(!mapCntIdParentId.isEmpty()) {
               for(ContentVersion cv :  [SELECT Id,FileExtension, Title, VersionData, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :mapCntIdParentId.keySet() AND IsLatest = True]) {
                  System.debug(cv);
                if(!noteIds.contains(cv.ContentDocumentId)){
                    if(!mapParentIdAndFiles.containsKey(mapCntIdParentId.get(cv.ContentDocumentId))) {
                        mapParentIdAndFiles.put(mapCntIdParentId.get(cv.ContentDocumentId), new list<ContentVersion>());
                    }

                    mapParentIdAndFiles.get(mapCntIdParentId.get(cv.ContentDocumentId)).add(cv);
                  }

               }
           }

           return mapParentIdAndFiles;
       }
   }