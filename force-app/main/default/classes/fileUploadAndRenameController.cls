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
                contentDbList = [SELECT DistributionPublicUrl, ContentDownloadUrl, Name, ContentDocumentId
                                 FROM ContentDistribution
                                 WHERE ContentDocumentId IN:contentDocumentIds];

                for (ContentDistribution content : contentDbList){
                    wrpClass wrp = new wrpClass();
                    wrp.title = content.Name;
                    wrp.image = content.ContentDownloadUrl;
                    wrpList.add(wrp);
                }
            }

            return wrpList;

        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
    }

    public class wrpClass{

        @AuraEnabled
        public String title{ get; set; }

        @AuraEnabled
        public String image{ get; set; }
    }
}