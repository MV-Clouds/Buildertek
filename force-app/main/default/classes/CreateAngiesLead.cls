@RestResource(urlMapping='/CreateAngiesLead/*')
global with sharing class CreateAngiesLead {
    @HttpPost
    global static ResponseClass createLeadRecord(){
        ResponseClass rc = new ResponseClass();
        try{
            RestRequest req = RestContext.request;
            RestResponse res = Restcontext.response;
            String requestBody = RestContext.request.requestBody.toString();
            String payloadBody = '';
            LeadData leadRecordData = (LeadData)System.JSON.deserialize(requestBody, LeadData.class);
            system.debug('DESERIALIZED-----> '+ leadRecordData);
            Lead ld = new Lead();
            ld.FirstName =  leadRecordData.FirstName;
            ld.LastName = leadRecordData.LastName;
            ld.Phone = leadRecordData.PhoneNumber;
            ld.Email = leadRecordData.Email;
            ld.Company = leadRecordData.Category;
            ld.LeadSource = leadRecordData.Source;
            ld.Description = leadRecordData.Description;
            ld.buildertek__Category__c = leadRecordData.Category;
            ld.buildertek__Urgency__c = leadRecordData.Urgency;
            ld.buildertek__CorrelationId__c = leadRecordData.CorrelationId;
            ld.buildertek__ALAccountId__c = leadRecordData.ALAccountId;
            ld.Street = leadRecordData.PostalAddress.AddressFirstLine;
            ld.City = leadRecordData.PostalAddress.City;
            ld.State = leadRecordData.PostalAddress.State;
            ld.PostalCOde = leadRecordData.PostalAddress.PostalCode;
            insert ld;   
            rc.statusCode = 200;
            rc.success = true;
            rc.message = 'Lead created';
            return rc;
        }catch(Exception exp){
            rc.statusCode = 400;
            rc.success = false;
            rc.message = exp.getMessage();
            return rc;       
        }
    }
    global class LeadData{
        global string FirstName;
        global string LastName;
        global string PhoneNumber;
        global string Email;
        global string Source;
        global string Description;
        global string Category;
        global string Urgency;
        global string CorrelationId;
        global string ALAccountId;
        global PostalAddress PostalAddress;
    }
    
    global class PostalAddress{
        global string AddressFirstLine;
        global string AddressSecondLine;
        global string City;
        global string State;
        global string PostalCode;
    }
    
    global class ResponseClass{
        global Integer statusCode;
        global Boolean success;
        global String message;
    }
}