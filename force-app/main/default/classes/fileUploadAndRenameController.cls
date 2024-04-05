public with sharing class fileUploadAndRenameController{
    @AuraEnabled
    public static List<wrpClass> getDataForDataTable(List<String> contentDocumentIds){
        try{
            List<wrpClass> wrpList = new List<wrpClass>();
            List<ContentVersion> cvList = [SELECT Id, Title
                                           FROM contentversion
                                           WHERE contentdocumentid IN:contentDocumentIds];
            if (cvList.size() > 0){
                List<ContentDistribution> cdList = new List<ContentDistribution>();
                for (ContentVersion cv : cvList){
                    ContentDistribution cd = new ContentDistribution();
                    cd.Name = cv.Title;
                    cd.ContentVersionId = cv.id;
                    cd.PreferencesAllowViewInBrowser = true;
                    cd.PreferencesLinkLatestVersion = true;
                    cd.PreferencesNotifyOnVisit = false;
                    cd.PreferencesPasswordRequired = false;
                    cd.PreferencesAllowOriginalDownload = true;
                    cdList.add(cd);
                }
                insert cdList;

                List<ContentDistribution> contentDbList = new List<ContentDistribution>();
                contentDbList = [SELECT DistributionPublicUrl, ContentVersionId, ContentDownloadUrl, Name, ContentDocumentId
                                 FROM ContentDistribution
                                 WHERE ContentDocumentId IN:contentDocumentIds];

                for (ContentDistribution content : contentDbList){
                    wrpClass wrp = new wrpClass();
                    wrp.title = content.Name;
                    wrp.image = content.ContentDownloadUrl;
                    wrp.id = content.ContentVersionId;
                    wrp.ContentDocumentId = content.ContentDocumentId;
                    wrpList.add(wrp);
                }
            }
            return wrpList;
        } catch (Exception ex){
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void updateFileName(String listData){

        System.debug('listData: ' + listData);
        try{
            List<wrpClass> wrpList = (List<wrpClass>)JSON.deserialize(listData, List<wrpClass>.class);

            if (wrpList.size() > 0){
                List<ContentVersion> cvList = new List<ContentVersion>();
                for (wrpClass wr : wrpList){
                    ContentVersion cv = new ContentVersion();
                    cv.Id = wr.id;
                    cv.Title = wr.title;
                    cvList.add(cv);
                }
                update cvList;
            }
        } catch (Exception ex){
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
            throw new AuraHandledException(ex.getMessage());
        }
    }

    @AuraEnabled
    public static void deleteFiles(List<String> docIds, String recordId){
        try{


            List<ContentDocumentLink> listContentLink = [Select Id, Linkedentity.name, LinkedentityId, ContentDocumentId
            from ContentDocumentLink
            Where ContentDocumentId IN:docIds AND LinkedEntityId = :recordId AND ShareType = 'V'];

            if (listContentLink.size() > 0){
                delete listContentLink;
            }
        } catch (Exception ex){
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
            throw new AuraHandledException(ex.getMessage());
        }
    }

    public class wrpClass{
        @AuraEnabled
        public String title{ get; set; }

        @AuraEnabled
        public String id{ get; set; }

        @AuraEnabled
        public String ContentDocumentId{ get; set; }

        @AuraEnabled
        public String image{ get; set; }

    }

}