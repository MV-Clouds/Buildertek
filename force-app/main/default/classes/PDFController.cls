public without sharing class PDFController {
     @AuraEnabled(cacheable=true)
    public static String getStaticResourceDescription() {
      String  staticResourceName = 'Releasenote'; 
        // Query the static resource metadata to get the description
        List<StaticResource> staticResources = [
            SELECT Description
            FROM StaticResource
            WHERE Name = :staticResourceName
            LIMIT 1
        ];

        if (!staticResources.isEmpty()) {
            return staticResources[0].Description;
        }

        return null;
    }

    @AuraEnabled
    public static String sendemail(String name, String email, String subject, String body, List<String> fname, List<String> fbase64){
        try{
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            String myCustomLabel = System.Label.supportEmail;
            List<String> toEmailAddress = new List<String>();
            if(myCustomLabel.contains(',')){
                toEmailAddress.addAll(myCustomLabel.split(','));
            }else{ 
                toEmailAddress.add(myCustomLabel); 
            }             

            List<Messaging.Emailfileattachment> fileAttachments = new List<Messaging.Emailfileattachment>();
            for (Integer i = 0; i < fname.size(); i++){

                Messaging.Emailfileattachment efat = new Messaging.Emailfileattachment();
                efat.setFileName(fname[i]);
                String fdata = fbase64[i];
                efat.setBody(EncodingUtil.base64Decode(fdata));
                fileAttachments.add(efat);
            }

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject(subject);
            mail.setplaintextbody(body + '\n\n\nFrom ' + name + '\nEmail ' + email);
            mail.setToAddresses(toEmailAddress) ;
            if (fileAttachments != null && fileAttachments.size() > 0){
                mail.setFileAttachments(fileAttachments);
            }
            emailList.add(mail);
            Messaging.sendEmail(emailList);

            return 'success';
        } catch (Exception e){
            return 'fail';
        }
    }

    @AuraEnabled
    public static String createCase(String subject, String body, List<String> fname, List<String> fbase64) {
        Case newCase = new Case();
        newCase.Subject = subject;
        newCase.Description = body;
        newCase.Origin = 'Web';
        // newCase.CurrencyIsoCode = 'USD - U.S. Dollar';
        newCase.Status = 'New';

        try {
            insert newCase;
            System.debug('Case created successfully with ID: ' + newCase.Id);
            for (Integer i = 0; i < fname.size(); i++) {
                ContentVersion conVer = new ContentVersion();
                conVer.PathOnClient = fname[i];
                conVer.Title = fname[i];
                conVer.VersionData = EncodingUtil.base64Decode(fbase64[i]);
                insert conVer;
                
                ContentDocumentLink conDocLink = New ContentDocumentLink();
                conDocLink.LinkedEntityId = newCase.Id;
                conDocLink.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id =:conVer.Id].ContentDocumentId;
                conDocLink.Visibility = 'AllUsers';
                insert conDocLink;
            }
            return newCase.Id;
        } catch (Exception ex) {
            System.debug('Error creating case: ' + ex.getMessage());
            return null;
        }
    }

}