public with sharing class Product_Files {

    @AuraEnabled
    public static List<string> getProductFiles(String recordId) {
        List<String> returnList = new List<String>();          
        try {  
            List<buildertek__Question__c> option = [SELECT Id, Name, buildertek__Product__c FROM buildertek__Question__c WHERE Id =: recordId];
            System.debug('option => '+option);

            if (option.size() > 0) {
                List<ContentDocumentLink> contentLinkList = [SELECT Id, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: option[0].buildertek__Product__c];
                System.debug('contentLinkList => '+contentLinkList);

                if (contentLinkList.size() > 0) {
                    // Set<Id> contentLinkSet = new Set<Id>();
                    for (ContentDocumentLink link : contentLinkList) {
                        // contentLinkSet.add(link.ContentDocumentId);
                        returnList.add(link.ContentDocumentId);
                    }
                    // System.debug('contentLinkSet =>'+contentLinkSet);
                    // List<ContentVersion> contentList = [SELECT id, Title, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN: contentLinkSet];
                    // System.debug('contentList => '+contentList);

                    // for (ContentVersion contentDocs : contentList) {
                    //     returnList.add(contentDocs.ContentDocumentId);
                    // }
                    return returnList; 
                } else{
                    System.debug('There Are No Files');
                    returnList.add('Error');
                    returnList.add('There Are No Files');
                    return returnList;
                }
            } else{
                System.debug('There Are No Product');
                returnList.add('Error');
                returnList.add('There Are No Product');
                return returnList;
            }

        } catch (Exception e) {
            System.debug('Error => '+e.getMessage());
            returnList.add('Error');
            returnList.add(e.getMessage());
            return returnList;
        }
    }

}