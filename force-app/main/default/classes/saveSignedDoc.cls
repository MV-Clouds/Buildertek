@RestResource(urlMapping='/Template/')
global without sharing class saveSignedDoc {
    @HttpPost
    global static String doPost() {
        system.debug('11111111111111111111111111111111');
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        system.debug('rest api'+res);
        JsonToApex pdfBytes = JsonToApex.parse(req.requestBody.toString());
        system.debug(pdfBytes.status);
        list<ContentVersion> contentV = new list<ContentVersion>();
        
        String enId = pdfBytes.envelopeId;
        
        system.debug('resfromjs'+pdfBytes.envelopeId);
        
        List<buildertek__Change_Order__c> ChangeOrderId = [select Id, Envelope_Sent__c from buildertek__Change_Order__c where Envelope_Sent__c =: pdfBytes.envelopeId];
        system.debug('matchedContract'+ChangeOrderId); 
        
        List<Contact> ContactId = [select Id, buildertek__Envelope_Sent__c from Contact where buildertek__Envelope_Sent__c =: pdfBytes.envelopeId];
        system.debug('matchedContact'+ContactId);
        
        List<buildertek__Quote__c> QuoteId = [select Id, buildertek__Envelope_Sent__c from buildertek__Quote__c where buildertek__Envelope_Sent__c =: pdfBytes.envelopeId];
        system.debug('matchedContact'+QuoteId);
        
        List<buildertek__Contract__c> ContractId = [select Id, Envelope_Sent__c from buildertek__Contract__c where Envelope_Sent__c =: pdfBytes.envelopeId];
        system.debug('matchedContract'+ContractId); 
        
        List<buildertek__Purchase_Order__c> purchaseOrderId = [select Id, Envelope_Sent__c from buildertek__Purchase_Order__c where Envelope_Sent__c =: pdfBytes.envelopeId];
        system.debug('matchedContract'+purchaseOrderId); 
        
        //   recId = EncodingUtil.base64Decode(pdfBytes).envelopeId;
        
        //   system.debug('contractId'+recordId);
        system.debug(pdfBytes.envelopeDocuments[0].name);
        
        for(Integer i=0;i<pdfBytes.envelopeDocuments.Size();i++){
            String pdf1 = pdfBytes.envelopeDocuments[i].PDFBytes;
            if(pdfBytes.status == 'completed'){
                ContentVersion contentVer = new ContentVersion();
                contentVer.ContentLocation = 'S'; 
                contentVer.PathOnClient = 'application.pdf';
                contentVer.Title = 'Signed -'+pdfBytes.envelopeDocuments[i].name;
                contentVer.VersionData = EncodingUtil.base64Decode(pdf1);
                if(ChangeOrderId.Size() >0){
                    contentVer.FirstPublishLocationId  = ChangeOrderId[0].Id;
                }
                else if(ContactId.Size() >0){
                    contentVer.FirstPublishLocationId = ContactId[0].Id;
                }
                else if(QuoteId.Size() >0){ 
                    contentVer.FirstPublishLocationId = QuoteId[0].Id;
                }
                else if(ContractId.Size() >0){ 
                    contentVer.FirstPublishLocationId = ContractId[0].Id;
                }
                else if(purchaseOrderId.Size() >0){ 
                    contentVer.FirstPublishLocationId = purchaseOrderId[0].Id;
                }
                
                if(pdfBytes.envelopeDocuments[i].documentId != 'certificate'){
                    contentV.add(contentVer);
                }
            }
            system.debug(EncodingUtil.base64Decode(pdf1)); 
            system.debug(contentV);
            system.debug(req.requestBody.toString());
        }
        insert contentV ;
        
        RestContext.response.addHeader('content-Type','application/json');
        return null;
    }
}