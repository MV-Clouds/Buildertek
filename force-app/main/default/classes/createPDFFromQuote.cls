public with sharing class createPDFFromQuote {
    
    @AuraEnabled
    public Static List<EmailTemplate> getTemplates(){
        List<Emailtemplate> temrec;
        if (Schema.sObjectType.Emailtemplate.fields.Id.isAccessible() && Schema.sObjectType.Emailtemplate.fields.Name.isAccessible() && Schema.sObjectType.Emailtemplate.fields.folderid.isAccessible() && Schema.sObjectType.Folder.fields.Name.isAccessible()){
            temrec = [Select Id, Name, folder.name, DeveloperName from Emailtemplate where folder.name = 'BT Quote' AND DeveloperName != 'quote_top' AND DeveloperName != 'quote_bottom' ORDER BY Name ASC];
        }

        return temrec;
    }
    
    @AuraEnabled
    public static String createPDFAndStoreInFiles(String templateId, String quoteId){
        try {
            Blob pdfBlob = previewQuoteController.setAttachmentBody(quoteId, templateId, '');
            System.debug('pdfBlob : ' + pdfBlob);

            ContentVersion cv = new ContentVersion();
            cv.Title = 'Quote_' + DateTime.now().format('yyyyMMddHHmmss');
            cv.PathOnClient = cv.Title + '.pdf';
            cv.VersionData = pdfBlob;
            insert cv;

            ContentDocumentLink conDocLink = New ContentDocumentLink();
            conDocLink.LinkedEntityId = quoteId;
            conDocLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:cv.Id].ContentDocumentId;
            conDocLink.Visibility = 'AllUsers';
            insert conDocLink;

            return 'Success';
        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            List<buildertek__Exception_Log_Store_Option__c> StoreExcCustomSetting = [SELECT Id, buildertek__Store_Exception_Log_in_Object__c FROM buildertek__Exception_Log_Store_Option__c];
            if (!StoreExcCustomSetting.isEmpty() && StoreExcCustomSetting[0].buildertek__Store_Exception_Log_in_Object__c == true) {
                BT_ExceptionHandler.Store_Exception(ex);
            }
            return ex.getMessage();
        }
    }
}