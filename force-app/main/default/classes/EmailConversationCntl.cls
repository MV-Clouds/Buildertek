global with sharing class EmailConversationCntl{
    @AuraEnabled
    public static List<FinalWrapperClass> getEmailMessages(String RecId){
        System.debug('RecId'+ RecId);
        Map<String, List<EmailMessage>> emailMessageMap = new Map<String, List<EmailMessage>>();
        Map<String, String> yearMap = new Map<String, String>();
        Id RecsId = RecId;
        String sObjName = RecsId.getSObjectType().getDescribe().getName();
        system.debug('sObjName:::'+sObjName);
        String ObjectName = '';
        List<String> myFilter = new List<String>();
        string filter;
        if (BT_Utils.isValidSalesforceId(RecId, buildertek__RFI__c.class)){
            ObjectName = 'buildertek__RFI__c';
        }
        Set<Id> rfqToVendorIds = new Set<Id>();
        if(sObjName == 'buildertek__RFQ__c'){
            List<buildertek__RFQ_To_Vendor__c> rfqToVendor;
            rfqToVendor = [SELECT Id, buildertek__Contact__c ,buildertek__Status__c,buildertek__Contact__r.Email,buildertek__RFQ__c
                           FROM buildertek__RFQ_To_Vendor__c
                           WHERE buildertek__RFQ__c =:RecId];
            for(buildertek__RFQ_To_Vendor__c rfqToVendorRec :rfqToVendor){
                rfqToVendorIds.add(rfqToVendorRec.Id);
            }
        }
        String queryString = 'SELECT Id,Subject,Status,IsTracked, IsOpened, FirstOpenedDate, LastOpenedDate, TextBody,buildertek__Is_Incoming_Email__c,buildertek__Email_Body__c,Incoming,HtmlBody,Headers,FromName,FromAddress,ToAddress,CcAddress,RelatedToId,MessageDate FROM EmailMessage';

        if (RecId != ''){
            String data = '2020-01-06T00:00:00Z';//This is static Date Time. Purpose of using this is to avoid Duplicate EmailMessage record.
            Datetime lastModifyDate = (DateTime)JSON.deserialize('"' + data + '"', DateTime.class);
            if(sObjName == 'buildertek__RFQ__c'){
                queryString += ' WHERE ((LastModifiedDate >: lastModifyDate AND IsTracked = true) OR (Incoming = true) OR (LastModifiedDate <=: lastModifyDate AND IsTracked = false)) AND RelatedToId  IN: rfqToVendorIds ORDER BY LastModifiedDate DESC';
            }else{
                queryString += ' WHERE ((LastModifiedDate >: lastModifyDate AND IsTracked = true) OR (Incoming = true) OR (LastModifiedDate <=: lastModifyDate AND IsTracked = false)) AND RelatedToId  =: RecId ORDER BY LastModifiedDate DESC';
            }
        } else{
            string ss = 'No Emails';
        }
        system.debug('Structured Query>>>' + queryString);
        List<EmailMessage> allEmailMessages;
        /*   if(Schema.sObjectType.EmailMessage.fields.Id.isAccessible()&&
         Schema.sObjectType.EmailMessage.fields.buildertek__Is_Incoming_Email__c.isAccessible()&&
         Schema.sObjectType.EmailMessage.fields.TextBody.isAccessible() &&
         Schema.sObjectType.EmailMessage.fields.FromAddress.isAccessible() &&
         Schema.sObjectType.EmailMessage.fields.ToAddress.isAccessible() &&
         Schema.sObjectType.EmailMessage.fields.Subject.isAccessible() &&
         Schema.sObjectType.EmailMessage.fields.HtmlBody.isAccessible() &&
         Schema.sObjectType.EmailMessage.fields.Incoming.isAccessible()
         && Schema.sObjectType.EmailMessage.fields.CcAddress.isAccessible()){*/
        allEmailMessages = database.query(queryString);
        /*}*/
        system.debug('>>>>>>>>>>All Records>>>' + allEmailMessages);
        List<EmailMessage> EmailMessageList;
        for (EmailMessage em : allEmailMessages){
            system.debug('emailId===>'+em.Id);
            if (emailMessageMap.get(em.MessageDate.format('MMMM')+' - '+string.valueOf(em.MessageDate.Year())) == null){
                EmailMessageList = new List<EmailMessage>();
                EmailMessageList.add(em);
                emailMessageMap.put(em.MessageDate.format('MMMM')+' - '+string.valueOf(em.MessageDate.Year()), EmailMessageList);
                system.debug('em.MessageDat------------>'+em.MessageDate.format('MMMM'));
                system.debug('em.MessageDate.Year------------->'+string.valueOf(em.MessageDate.Year()));
                yearMap.put(em.MessageDate.format('MMMM')+' - '+string.valueOf(em.MessageDate.Year()), string.valueOf(em.MessageDate.Year()));
            } else{
                EmailMessageList = new List<EmailMessage>();
                EmailMessageList = emailMessageMap.get(em.MessageDate.format('MMMM')+' - '+string.valueOf(em.MessageDate.Year()));
                EmailMessageList.add(em);
                emailMessageMap.put(em.MessageDate.format('MMMM')+' - '+string.valueOf(em.MessageDate.Year()), EmailMessageList);
                system.debug('em.MessageDat------------>'+em.MessageDate.format('MMMM'));
                system.debug('em.MessageDate.Year------------->'+string.valueOf(em.MessageDate.Year()));
                yearMap.put(em.MessageDate.format('MMMM')+' - '+string.valueOf(em.MessageDate.Year()), string.valueOf(em.MessageDate.Year()));
            }
        }
        system.debug('emailMessageMap ----------> ' + emailMessageMap); 
        system.debug('yearMap-------------->'+yearMap);
        system.debug('key set ----------> ' + emailMessageMap.keySet());
        List<FinalWrapperClass> FinalWrapperClassList = new List<FinalWrapperClass>();
        for (String str : emailMessageMap.keySet()){
            if (emailMessageMap.get(str) != null){
                system.debug('final wrapper-------->'+ str + '--' + yearMap.get(str));
                system.debug('yearMap.get(str)oiij------->'+yearMap.get(str));
                system.debug('yearMap.keySet()okokok--------->'+yearMap.keySet());
               // for (String str1 : yearMap.keySet()){
                FinalWrapperClassList.add(new FinalWrapperClass(emailMessageMap.get(str), str.split(' - ')[0], yearMap.get(str), str));
               // }
            }
        }
        return FinalWrapperClassList;
    }

    @AuraEnabled
    public static String getCurrentRFI(String RecId){
        if (Id.valueOf(RecId).getSObjectType().getDescribe().getName() == 'buildertek__RFI__c'){
            buildertek__RFI__c rfis = [Select Id, buildertek__RFI_Number__c
                                       FROM buildertek__RFI__c
                                       WHERE ID = :RecId];
            return String.isNotBlank(rfis.Id) ? rfis.buildertek__RFI_Number__c : null;
        }
        return null;
    }

    @AuraEnabled
    public static EmailMessage deleteItems(String recordId){
        List<EmailMessage> eMsg;
        if (Schema.sObjectType.EmailMessage.fields.Id.isAccessible()){
            eMsg = [SELECT Id
                    FROM EmailMessage
                    WHERE Id = :recordId];
        }
        if (eMsg.size() > 0){
            try{

                if (EmailMessage.sObjectType.getDescribe().isDeletable()){
                    DELETE eMsg;
                }
                return new EmailMessage();
            } catch (Exception e){

            }

        }
        return null;
    }

    /* @AuraEnabled
     global static string getpassemaildetails(String RecordId){
     system.debug('>>>>>>>>>>Id>>>'+ RecordId);
     string idm = RecordId;
     string email='';
     system.debug('>>>>>>>>>>RecordId>>>'+ idm);

     If (idm.startsWith('003')){
     List<Contact> passvalues = [select id,Name,Email from Contact WHERE id =: idm limit 1];
     for(Contact l:passvalues ){
     email= l.Email ;
     }
     return email;
     }
     else if(idm.startsWith('00Q')){
     List<Lead> passvalues = [select id,Name,Email from Lead WHERE id =: idm limit 1];
     for(Lead l:passvalues ){
     email= l.Email ;
     }
     return email;
     }
     else if(idm.startsWith('006')){
     List<OpportunityContactRole> passvalues = [select id,ContactId,IsPrimary,OpportunityId,Role,Contact.Email from OpportunityContactRole where OpportunityId=: idm limit 1];
     for(OpportunityContactRole l:passvalues ){
     email = l.Contact.Email;
     }
     return email;
     }
     return email;
     }*/
    @AuraEnabled
    public static EmailMessage getemailAddress(String EMsgId){
        system.debug('>>>>>>>>>>Id>>>' + EMsgId);
        string emid = EMsgId;
        system.debug('>>>>>>>>>>RecordId>>>' + emid);
        List<EmailMessage> passemid;

        passemid = [select id, FromAddress, IsTracked, IsOpened, FirstOpenedDate, LastOpenedDate, buildertek__Is_Incoming_Email__c, TextBody, CcAddress, ToAddress, Subject, HtmlBody, Incoming
                    from EmailMessage
                    WHERE id = :emid
                    limit 1];

        string email = '';

        return passemid.size() > 0 ? passemid[0] : null;
    }

    public class FinalWrapperClass{
        @AuraEnabled
        public List<EmailMessage> emMessageList;
        @AuraEnabled
        public String Month;
        @AuraEnabled
        public String Year;
        @AuraEnabled
        public String heading;
        public FinalWrapperClass(List<EmailMessage> emMessageList, String Month, String Year, String heading){
            this.emMessageList = emMessageList;
            this.Month = Month;
            this.Year = Year;
            this.heading = heading;
        }
    }
}