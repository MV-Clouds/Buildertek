public class DocuSignApi {
    
    /* DocuSign Rest API webservice class to send an envelope. 

* Created for Demo Purpose. 

* */ 
    
    /******  Method to send docusign envelope the return the envelope status  ******/ 
    
    public String sendEnvelope(String email, String name, list<String> selectedDocuments, Id recordId){
        
        String ObjName = recordId.getSObjectType().getDescribe().getLabel();
        system.debug(ObjName);
        
        system.debug(selectedDocuments);
        
        buildertek__DocuSign_Authentication__c docusignCredentials = [SELECT buildertek__Account_Id__c, buildertek__Integration_Key__c, buildertek__Password__c, buildertek__User_Id__c FROM buildertek__DocuSign_Authentication__c];
        
        
        //Credentials are stored in variables. 
        
        String accountID = docusignCredentials.buildertek__Account_Id__c; 
        
        String userName = docusignCredentials.buildertek__User_Id__c; 
        
        String passWord = docusignCredentials.buildertek__Password__c; 
        
        String integratorKey = docusignCredentials.buildertek__Integration_Key__c; 
        
        // String templateID = '52dfeb43-ba93-4764-93e0-235b5ad9d93d'; 
        String templateID = selectedDocuments[0];
        
        //This Endpoint supports creating an envelope with the templateId. 
        
        String endPoint = 'https://demo.docusign.net/restapi/v2/accounts/'+accountID+'/envelopes'; 
        // String endPoint = '/restapi/v2.1/accounts/{accountId}/envelopes/{envelopeId}/views/recipient'; 

        
        
        
        //Apex HTTP Method Initialization. 
        
        HttpRequest req = new HttpRequest(); 
        
        req.setEndpoint(endPoint); 
        
        req.setMethod('POST'); 
        
        
        
        //Authorization header generating using DocuSign credentials. 
        
        // String authorizationHeader = '<DocuSignCredentials><Username>'+userName+'</Username><Password>'+Password+'</Password><IntegratorKey>'+integratorKey+'</IntegratorKey></DocuSignCredentials>'; 
        String access_token = DocuSignTGen1.getAccessToken();
        
        String authorizationHeader = '<DocuSignCredentials><Username>'+userName+'</Username><Password>'+Password+'</Password><IntegratorKey>'+integratorKey+'</IntegratorKey></DocuSignCredentials>'; 

        System.debug(authorizationHeader);
        // req.setHeader('X-DocuSign-Authentication', authorizationHeader); 
        req.setHeader('Authorization', 'Bearer '+access_token);
        
        req.setHeader('Accept','application/json'); 
        
        req.setHeader('Content-Length','162100'); 
        
        req.setHeader('Content-Type','application/json'); 
        
        req.setHeader('Content-Disposition','form-data'); 
        
        
        
        //JSON Request which contains template id and receivers email and name. 
        
        String json='{'+ 
            
            ' '+ 
            
            ' "emailSubject": "Agreement",'+ 
            
            ' "emailBlurb": "Please View and Sign The Document. ",'+ 
            
            ' "templateId": "'+templateID+'",'+ 
            
            ' "envelopeIdStamping": "false",'+ 
            
            ' "templateRoles": ['+ 
            
            ' {'+ 
            
            '"roleName": "Signer",'+ 
            
            '"name": "'+name+'",'+ 
            
            '"email": "'+email+'",'+ 
            
            '"recipientId": "1"'+ 
            
            '}'+ 
            
            ' ],'+ 
            
            ' "status": "sent"'+ 
            
            '}';         
        
        
        req.setBody(json); 
        
        System.debug(json);
        
        
        Http http = new Http(); 
        
        HTTPResponse res; 
        
        system.debug('Complete Response '+res);
        system.debug('Complete request '+req);

        
        try{ 
            
            //Docusign Request Callout. 
            
            res = http.send(req); 
            
            system.debug('DocuSign Response'+ res);
            system.debug('DocuSign Response'+ res.getBody());
            
            EnvelopeId envId =  (EnvelopeId) System.JSON.deserialize(res.getBody(), EnvelopeId.class);
            
            
            EnvelopeId docuTemps = new EnvelopeId();
            docuTemps.envelopeId = envId.envelopeId;
            docuTemps.uri = envId.uri;
            docuTemps.statusDateTime = envId.statusDateTime;
            docuTemps.status = envId.status;
            
            system.debug(ObjName);
            system.debug(docuTemps);

            
            If(ObjName == 'Change Order'){
                list<buildertek__Change_Order__c> contactDetails = new list<buildertek__Change_Order__c>();
                contactDetails = [select Id, name , buildertek__Vendor__r.name, buildertek__Vendor__r.buildertek__Email_Address__c, Envelope_Sent__c from buildertek__Change_Order__c WHERE Id =: recordId];
                system.debug(contactDetails);
                for(Integer i=0;i<contactDetails.Size();i++){
                    contactDetails[i].Envelope_Sent__c = docuTemps.envelopeId; 
                }
                update contactDetails;
                system.debug(contactDetails);
            } else If(ObjName == 'Contact'){
               list<Contact> contactDetails = new list<Contact>();
                contactDetails = [select Id, Email, Name, buildertek__Envelope_Sent__c from Contact WHERE Id =: recordId];
                system.debug(contactDetails);
                for(Integer i=0;i<contactDetails.Size();i++){
                    contactDetails[i].buildertek__Envelope_Sent__c = docuTemps.envelopeId;
                }
                update contactDetails;
                system.debug(contactDetails);
            }else If(ObjName == 'Quote'){
               list<buildertek__Quote__c> contactDetails = new list<buildertek__Quote__c>();
                contactDetails = [select Id, buildertek__Bill_To_Name__c, buildertek__Bill_To_Email_Address__c, buildertek__Envelope_Sent__c from buildertek__Quote__c WHERE Id =: recordId];
                system.debug(contactDetails);
                for(Integer i=0;i<contactDetails.Size();i++){
                    contactDetails[i].buildertek__Envelope_Sent__c = docuTemps.envelopeId;
                }
                update contactDetails;
                system.debug(contactDetails);
            }else If(ObjName == 'Contract'){
               list<buildertek__Contract__c> contactDetails = new list<buildertek__Contract__c>();
                contactDetails = [select Id, buildertek__Vendor__r.name, buildertek__Vendor__r.buildertek__Email_Address__c, buildertek__Envelope_Sent__c from buildertek__Contract__c WHERE Id =: recordId];
                system.debug(contactDetails);
                for(Integer i=0;i<contactDetails.Size();i++){
                    contactDetails[i].buildertek__Envelope_Sent__c = docuTemps.envelopeId;
                }
                update contactDetails;
                system.debug(contactDetails);
            }else If(ObjName == 'Purchase Order'){
               list<buildertek__Purchase_Order__c> contactDetails = new list<buildertek__Purchase_Order__c>();
                contactDetails = [select Id, buildertek__Vendor__r.name, buildertek__Vendor__r.buildertek__Email_Address__c, buildertek__Envelope_Sent__c from buildertek__Purchase_Order__c WHERE Id =: recordId];
                system.debug(contactDetails);
                for(Integer i=0;i<contactDetails.Size();i++){
                    contactDetails[i].buildertek__Envelope_Sent__c = docuTemps.envelopeId;
                }
                update contactDetails;
                system.debug(contactDetails);
            }
            
            
            
            
        } 
        
        catch(Exception e){ 
            
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage())); 
            
        } 
        
        /********The response from the Docusign is sent to wrapper class to deserialize.*********/ 
        
      /*  WrapperDocuSign wrapInst = WrapperDocuSign.parse(res.getBody()); 
        
        Return wrapInst.status;  */
        Return null;
        
    } 
    
    
    public class EnvelopeId{
        @AuraEnabled
        public String envelopeId {get;set;}
        
        @AuraEnabled
        public String uri {get;set;}
        
        @AuraEnabled
        public String statusDateTime {get;set;}
        
        @AuraEnabled
        public String status {get;set;}
    }
    
    
}