trigger VisitRequestApproval on Visit_Request__c (before update)
//After update
{
    
 If(Trigger.isUpdate)
 {
     Id VisitId;
     
    for(Visit_Request__c cr : Trigger.New)
            {
                String oldStatus = Trigger.oldMap.get(cr.Id).Status__c;
                String CR_STATUS_APPROVED = 'Approved';
               // String RecId = '0120L000000NPy7';
                Id RecId = Schema.SObjectType.Visit_Request__c.getRecordTypeInfosByName().get('Factory Visit Request (Edit)').getRecordTypeId();
                String VError = 'No Site Visit Data found. Site visit information is required to approve this request. Before approving enter the appropriate site visit data, then approve the request.';
                Boolean isValid;
              //  cr = [SELECT Id from Site_to_Visit__c Where id=:cr.Id];
                if(cr.Status__c == CR_STATUS_APPROVED && oldStatus != CR_STATUS_APPROVED && cr.RecordTypeId != RecId)
                {
                // Site to Visit data is required to approve

                    if(cr.Site_to_Visit__c == Null)
                    {

                        isValid = false;
                        cr.addError(VError,false);
                       
              
                    }
            }
                
      }
 
 }  
    
        
}