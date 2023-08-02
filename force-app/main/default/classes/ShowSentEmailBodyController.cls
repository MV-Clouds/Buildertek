public with sharing class ShowSentEmailBodyController {
    /*
     * @Created Date:- 9th OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : getInitialEmailBody
     * @ReturnType : EmailMessage
     * @param : recordId
     * @Description : Get the EmailMessage based on MessageDate in ascending oder
    */
    @AuraEnabled
    public static EmailMessage getInitialEmailBody(String recordId){
        EmailMessage email ;
        if(Schema.sObjectType.EmailMessage.isAccessible()&&
            Schema.sObjectType.EmailMessage.fields.Id.isAccessible()&&
            Schema.sObjectType.EmailMessage.fields.Subject.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.Status.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.TextBody.isAccessible()&&
			Schema.sObjectType.EmailMessage.fields.Incoming.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.HtmlBody.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.Headers.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.FromName.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.FromAddress.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.ToAddress.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.MessageDate.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.RelatedToId.isAccessible()){
           email = [SELECT Id,Subject,Status,TextBody,Incoming,BccIds,CcIds,HtmlBody,Headers,FromName,
                                        FromAddress,ToAddress,MessageDate,RelatedToId FROM EmailMessage 
                                        where RelatedToId =: recordId AND Status = '3' ORDER by MessageDate ASC LIMIT 1];
			}
        return email;                              
    }
    
    /*
     * @Created Date:- 9th OCTOBER 2018
     * @Author : PAVAN KUMAR UDDARRAJU
     * @Name : getFinalEmailBody
     * @ReturnType : EmailMessage
     * @param : recordId
     * @Description : Get the EmailMessage based on MessageDate in descending oder
    */
    @AuraEnabled
    public static EmailMessage getFinalEmailBody(String recordId){
        EmailMessage email;
       if(Schema.sObjectType.EmailMessage.isAccessible()&&
            Schema.sObjectType.EmailMessage.fields.Id.isAccessible()&&
            Schema.sObjectType.EmailMessage.fields.Subject.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.Status.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.TextBody.isAccessible()&&
			Schema.sObjectType.EmailMessage.fields.Incoming.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.HtmlBody.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.Headers.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.FromName.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.FromAddress.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.ToAddress.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.MessageDate.isAccessible() &&
			Schema.sObjectType.EmailMessage.fields.RelatedToId.isAccessible()){
           email = [SELECT Id,Subject,Status,TextBody,Incoming,BccIds,CcIds,HtmlBody,Headers,FromName,
                                        FromAddress,ToAddress,MessageDate,RelatedToId FROM EmailMessage 
                                        where RelatedToId =: recordId AND Status = '2' ORDER by MessageDate DESC LIMIT 1];
			}
        return email;                              
    }
}