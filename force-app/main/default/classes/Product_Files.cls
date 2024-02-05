public with sharing class Product_Files {
    @AuraEnabled
    public String status;

    @AuraEnabled
    public List<ContentDocumentLink> contentLink;


    @AuraEnabled
    public static Product_Files getProductFiles(String recordId) {
        try {  
            List<buildertek__Question__c> option = [SELECT Id, Name, buildertek__Product__c FROM buildertek__Question__c WHERE Id =: recordId];
            System.debug('option => '+option[0]);

            if (option.size() > 0 && option[0].buildertek__Product__c != null) {
                System.debug('IN IF :->'+ option[0].buildertek__Product__c);
                List<ContentDocumentLink> contentLinkList = [SELECT Id,ContentDocument.Title, ContentDocumentId, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId =: option[0].buildertek__Product__c AND ContentDocument.FileType NOT IN ('HTML','CSV','PDF')];
                System.debug('contentLinkList => '+contentLinkList);

                if (contentLinkList.size() > 0) {
                    Product_Files files = new Product_Files();
                    files.status = 'success';
                    files.contentLink = contentLinkList;
                    return files;
                } else{
                    System.debug('There Are No Files');
                    Product_Files files = new Product_Files();
                    files.status = 'There Are No Files.';
                    files.contentLink = null;
                    return files;
                }
            } else{
                System.debug('There Are No Product');
                Product_Files files = new Product_Files();
                files.status = 'There Are No Product.';
                files.contentLink = null;
                return files;
            }

        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            Product_Files files = new Product_Files();
                files.status = 'error';
                files.contentLink = null;
                return files;
        }
    }

}