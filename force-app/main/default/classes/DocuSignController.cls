public  class DocuSignController {
    
    @AuraEnabled
    public Static String sendDocEnv (Id recordId, List<String> SelectedDoc){
        
        String ObjName = recordId.getSObjectType().getDescribe().getLabel();
        system.debug(ObjName);
        
        If(ObjName == 'Change Order'){
            list<buildertek__Change_Order__c> contactDetails = new list<buildertek__Change_Order__c>();

            system.debug(SelectedDoc);
            contactDetails = [select Id, name , buildertek__Vendor__r.name, buildertek__Vendor__r.buildertek__Email_Address__c from buildertek__Change_Order__c WHERE Id =: recordId];
            DocuSignApi Sign = New DocuSignApi(); 
            Sign.sendEnvelope(contactDetails[0].buildertek__Vendor__r.buildertek__Email_Address__c ,contactDetails[0].buildertek__Vendor__r.name, SelectedDoc, recordId);  
            
        }else If(ObjName == 'Contact'){
            list<Contact> contactDetails = new list<Contact>();
            system.debug(SelectedDoc);
            contactDetails = [select Id, Email, Name from Contact WHERE Id =: recordId];
            
            // templates related code
            DocuSignApi Sign = New DocuSignApi(); 
            Sign.sendEnvelope(contactDetails[0].Email,contactDetails[0].Name, SelectedDoc, recordId);  
            
        }else If(ObjName == 'Quote'){
            list<buildertek__Quote__c> contactDetails = new list<buildertek__Quote__c>();
            system.debug(SelectedDoc);
            contactDetails = [select Id, Name, buildertek__Bill_To_Name__c, buildertek__Bill_To_Email_Address__c from buildertek__Quote__c WHERE Id =: recordId];
            
            // templates related code
            DocuSignApi Sign = New DocuSignApi(); 
            Sign.sendEnvelope(contactDetails[0].buildertek__Bill_To_Email_Address__c,contactDetails[0].buildertek__Bill_To_Name__c, SelectedDoc, recordId);  
            
        }else If(ObjName == 'Contract'){
            list<buildertek__Contract__c> contactDetails = new list<buildertek__Contract__c>();
            system.debug(SelectedDoc);
            contactDetails = [select Id, Name, buildertek__Vendor__r.name, buildertek__Vendor__r.buildertek__Email_Address__c from buildertek__Contract__c WHERE Id =: recordId];
            
            // templates related code
            DocuSignApi Sign = New DocuSignApi(); 
            Sign.sendEnvelope(contactDetails[0].buildertek__Vendor__r.buildertek__Email_Address__c,contactDetails[0].buildertek__Vendor__r.name, SelectedDoc, recordId);  
            
        }else If(ObjName == 'Purchase Order'){
            list<buildertek__Purchase_Order__c> contactDetails = new list<buildertek__Purchase_Order__c>();
            system.debug(SelectedDoc);
            contactDetails = [select Id, Name, buildertek__Vendor__r.name, buildertek__Vendor__r.buildertek__Email_Address__c from buildertek__Purchase_Order__c WHERE Id =: recordId];
            
            // templates related code
            DocuSignApi Sign = New DocuSignApi(); 
            Sign.sendEnvelope(contactDetails[0].buildertek__Vendor__r.buildertek__Email_Address__c,contactDetails[0].buildertek__Vendor__r.name, SelectedDoc, recordId);  
            
        }
        return null;
        
        
        
/*

// Code To Create Template

CreateTemplateApi Sign = New CreateTemplateApi(); 
Sign.sendEnvelope(contactDetails[0].CustomerSigned.Email,contactDetails[0].CustomerSigned.Name, SelectedDoc, recordId);  */
        
    }
    
    @AuraEnabled
    public static object getDocuments(String recordId){
        
        system.debug(recordId);
        List<ContentDocumentClass> MasterBudgetsClassList = new List<ContentDocumentClass>();
        List<ContentDocumentLink> rfqList;
        If(Schema.sObjectType.ContentDocument.fields.Id.isAccessible() &&
           Schema.sObjectType.ContentDocument.fields.Title.isAccessible()){
               
               rfqList = [SELECT ContentDocumentId,ContentDocument.Title, LinkedEntityId  
                          FROM ContentDocumentLink 
                          where LinkedEntityId =: recordId];
           }
        
        system.debug(rfqList);
        
        for(ContentDocumentLink bud : rfqList){
            ContentDocumentClass MasterBudgetsClassRecord = new ContentDocumentClass(); 
            MasterBudgetsClassRecord.budgetRecord = bud;
            MasterBudgetsClassRecord.budgetCheck = false;
            MasterBudgetsClassList.add(MasterBudgetsClassRecord);
        }
        return  MasterBudgetsClassList;                                               
    } 
    
    
    @AuraEnabled
    public static list<DocuTemplates> GetDocusignTemplates(Id recordId){
        
        String ObjName = recordId.getSObjectType().getDescribe().getLabel();
        
        buildertek__DocuSign_Authentication__c docusignCredentials = [SELECT buildertek__Account_Id__c, buildertek__Integration_Key__c, buildertek__Password__c, buildertek__User_Id__c FROM buildertek__DocuSign_Authentication__c];

        
        List<buildertek__Docusign_Folder_Mapping__c> FolderName = [select Id, Name, Template_Folder_Name__c from buildertek__Docusign_Folder_Mapping__c];
        
        Map<String,String> objAndFolderNameMap = new Map<String,String>();
        for(buildertek__Docusign_Folder_Mapping__c temFolderRec: FolderName){
            objAndFolderNameMap.put(temFolderRec.Name,temFolderRec.buildertek__Template_Folder_Name__c);
        }
        system.debug('Object name'+ObjName);
        
        HttpRequest req = new HttpRequest();  
        String access_token = DocuSignTGen1.getAccessToken();
        system.debug('accessToken           =>'+access_token);
        req.setMethod('GET');
        req.setEndpoint('https://demo.docusign.net/restapi/v2.1/accounts/'+docusignCredentials.buildertek__Account_Id__c+'/templates'); //tokenEndpoint
        // req.setHeader('Content-type', 'application/x-www-form-urlencoded');
        req.setHeader('Authorization', 'Bearer '+access_token);
        
        // req.setBody(body);
        Http http = new Http();               
        HTTPResponse res = http.send(req);
        if ( res.getStatusCode() == 200 ) {
            Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(res.getBody());
            system.debug('response -->'+res);
            system.debug('res.getBody()-->'+res.getBody());
            
            JsonToApexForGetTemplates templates =  (JsonToApexForGetTemplates) System.JSON.deserialize(res.getBody(), JsonToApexForGetTemplates.class);
            
            list<DocuTemplates> docuTemps = new list<DocuTemplates>();
            
            system.debug(ObjName);
            
            List<DocuTemplates> changeOrderFolderTemps = new List<DocuTemplates>();
            for(Integer i=0;i<templates.envelopeTemplates.Size();i++){
                DocuTemplates DocTemp = new DocuTemplates();
                DocTemp.templateId = templates.envelopeTemplates[i].templateId;
                DocTemp.uri = templates.envelopeTemplates[i].uri;
                DocTemp.name = templates.envelopeTemplates[i].name;
                DocTemp.folderName = templates.envelopeTemplates[i].folderName;
                System.debug(DocTemp.folderName);
                if(ObjName =='Change Order'){
                     if(objAndFolderNameMap.get(ObjName) == DocTemp.folderName){
                        changeOrderFolderTemps.add(DocTemp);
                        system.debug('Change Order temp -->'+DocTemp);
                         system.debug(DocTemp.folderName);
                    }
                    docuTemps.add(DocTemp);
                }else if(ObjName == 'Contact'){
                     if(objAndFolderNameMap.get(ObjName) == DocTemp.folderName){
                        changeOrderFolderTemps.add(DocTemp);
                        system.debug('Contact temp -->'+DocTemp);
                    }
                    docuTemps.add(DocTemp);
                }else if(ObjName == 'Quote'){
                     if(objAndFolderNameMap.get(ObjName) == DocTemp.folderName){
                        changeOrderFolderTemps.add(DocTemp);
                        system.debug('Quote temp -->'+DocTemp);
                    }
                    docuTemps.add(DocTemp);
                }else if(ObjName == 'Contract'){
                     if(objAndFolderNameMap.get(ObjName) == DocTemp.folderName){
                        changeOrderFolderTemps.add(DocTemp);
                        system.debug('Contract temp -->'+DocTemp);
                    }
                    docuTemps.add(DocTemp);
                }else if(ObjName == 'Purchase Order'){
                     if(objAndFolderNameMap.get(ObjName) == DocTemp.folderName){
                        changeOrderFolderTemps.add(DocTemp);
                        system.debug('Purchase Order temp -->'+DocTemp);
                    }
                    docuTemps.add(DocTemp);
                }
                
            }
            
            system.debug('changeOrderFolderTemps -->'+changeOrderFolderTemps);
            system.debug('templates'+templates.envelopeTemplates[0]);
            
            system.debug('templates-->'+templates);
            
            
            //return docuTemps;
            
            return changeOrderFolderTemps;
            
            //access_token = (String)responseMap.get('access_token');
        }else{
            System.debug('JWTBearerFlow Error Occurred '+res.getBody());
            System.debug( res.getStatusCode());
            list<DocuTemplates> docuTemps = new list<DocuTemplates>();
            return docuTemps;
        }
    }        
    
    
    /* @AuraEnabled
public Static Void getrecord ( string id){

}*/
    
    public class ContentDocumentClass{
        @AuraEnabled
        public ContentDocumentLink budgetRecord {get;set;}
        
        @AuraEnabled
        public boolean budgetCheck {get;set;}
    }
    
    
    public class DocuTemplates{
        @AuraEnabled
        public String templateId {get;set;}
        
        @AuraEnabled
        public String uri {get;set;}
        
        @AuraEnabled
        public String name {get;set;}
        
        @AuraEnabled
        public String folderName {get;set;}
    }
    
}