public with sharing class ImagePreviewController {
    @AuraEnabled
    public String status;

    @AuraEnabled
    public List<buildertek__Question_Group__c> selectionCategory;

    public class FilesWrapper {
        @AuraEnabled
        public Map<String, List<ContentDocumentLink>> resultMap { get; set; }
        @AuraEnabled
        public String status { get; set; }
    
        public FilesWrapper(Map<String, List<ContentDocumentLink>> resultMap, String status) {
            this.resultMap = resultMap;
            this.status = status;
        }
    }

    @AuraEnabled
    public static FilesWrapper getProductFilesMap(String recordId) {
        Map<String, List<ContentDocumentLink>> resultMap = new Map<String, List<ContentDocumentLink>>();
        String status = 'Success';          
        
        try {  
            // Collect buildertek__Question__c Ids
            Set<Id> questionIds = new Set<Id>();
            List<buildertek__Question__c> options = [SELECT Id, Name, buildertek__Question_Group__c, buildertek__Product__c FROM buildertek__Question__c WHERE buildertek__Question_Group__c =: recordId];
            if (options.size() > 0) {
                for (buildertek__Question__c option : options) {
                    questionIds.add(option.buildertek__Product__c);
                }
                // Perform ContentDocumentLink query outside of the loop
                List<ContentDocumentLink> contentLinkList = [SELECT Id, ContentDocumentId, ContentDocument.title, LinkedEntityId FROM ContentDocumentLink WHERE LinkedEntityId IN :questionIds AND ContentDocument.FileType NOT IN ('HTML','CSV','PDF')];
    
                for (buildertek__Question__c option : options) {
                    List<ContentDocumentLink> contentLinks = new List<ContentDocumentLink>();
    
                    for (ContentDocumentLink link : contentLinkList) {
                        if (link.LinkedEntityId == option.buildertek__Product__c) {
                            contentLinks.add(link);
                        }
                    }
    
                    // Merge option Name and Id with a symbol for the key
                    String optionKey = option.Name + '__' + option.Id;
                    resultMap.put(optionKey, contentLinks);
                }
            } else {
                status = 'Fail';
                resultMap = new Map<String, List<ContentDocumentLink>>();
            }

        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            status = 'Fail';
            resultMap = new Map<String, List<ContentDocumentLink>>();
        }

        return new FilesWrapper(resultMap, status);
    }
    
    @AuraEnabled
    public static ImagePreviewController getSelectionCategoryFiles(String recordId) {
        try {
            List<buildertek__Question_Group__c> selectionCategoryList = [SELECT Id,Name,buildertek__Section__c FROM buildertek__Question_Group__c WHERE buildertek__Section__c =: recordId];

            if (selectionCategoryList.size() > 0) {
                ImagePreviewController files = new ImagePreviewController();
                files.status = 'success';
                files.selectionCategory = selectionCategoryList;
                return files;
            } else{
                System.debug('There Are No Files');
                ImagePreviewController files = new ImagePreviewController();
                files.status = 'There Are No Files.';
                files.selectionCategory = null;
                return files;
            }
        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            ImagePreviewController files = new ImagePreviewController();
                files.status = 'error';
                files.selectionCategory = null;
                return files;
        }
    }

    @AuraEnabled
    public static List<Map<String, String>> getSelectionCategories(String recordId) {
        try {
            List<Map<String, String>> categories = new List<Map<String, String>>();
            List<buildertek__Section__c> categoryList = [SELECT Id, Name, buildertek__Selection__c FROM buildertek__Section__c WHERE  buildertek__Selection__c =: recordId ];

            for (buildertek__Section__c category : categoryList) {
                Map<String, String> categoryMap = new Map<String, String>();
                categoryMap.put('Id', category.Id);
                categoryMap.put('Name', category.Name);
                categories.add(categoryMap);
            }

            return categories;

        } catch (Exception e) {
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if(!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true){
                BT_ExceptionHandler.Store_Exception(e);
            }
            return null;
        }
    }
    
    
}