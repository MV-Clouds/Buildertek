trigger CustomerReferenceRequestTrigger on Customer_Reference_Request__c (after insert, after update, after delete) 
{
    Set<Id> contactIds = new Set<Id>();
    if (trigger.isInsert || trigger.isUpdate)
    {
        for(Customer_Reference_Request__c crr : trigger.new)
        {
            if (crr.Reference_Contact_Name__c != null)
            {
                contactIds.add(crr.Reference_Contact_Name__c);
                System.debug('***Insert/Update - Contact 1 ID Added: ' + String.valueOf(crr.Reference_Contact_Name__c) );    
            }                          
            if (crr.Reference_Contact_Name_2__c != null)
            {
                contactIds.add(crr.Reference_Contact_Name_2__c);    
                System.debug('***Insert/Update - Contact 2 ID Added: ' + String.valueOf(crr.Reference_Contact_Name_2__c) );   
            }       
            if (crr.Reference_Contact_Name_3__c != null)
            {
                contactIds.add(crr.Reference_Contact_Name_3__c);    
                System.debug('***Insert/Update - Contact 3 ID Added: ' + String.valueOf(crr.Reference_Contact_Name_3__c) );    
            }       


        }
    }
    if (trigger.isUpdate || trigger.isDelete)
    {
        for (Customer_Reference_Request__c crr : trigger.old)
        {
            if (crr.Reference_Contact_Name__c != null)
            {
                contactIds.add(crr.Reference_Contact_Name__c);    
                System.debug('***Delete - Contact 1 ID Added: ' + String.valueOf(crr.Reference_Contact_Name__c) );    
            }                          
            if (crr.Reference_Contact_Name_2__c != null)
            {
                contactIds.add(crr.Reference_Contact_Name_2__c);    
                System.debug('***Delete - Contact 2 ID Added: ' + String.valueOf(crr.Reference_Contact_Name_2__c) );    
             }       
            if (crr.Reference_Contact_Name_3__c != null)
            {
                contactIds.add(crr.Reference_Contact_Name_3__c);    
                System.debug('***Delete - Contact 3 ID Added: ' + String.valueOf(crr.Reference_Contact_Name_3__c) );    
            }       
        }
    }
    if (contactIDs.size() > 0)
    {
        Map<Id, Contact> contactsToUpdate = new Map<Id, Contact> ([SELECT Id,Customer_Reference_Requests_Overall__c FROM Contact WHERE Id IN :contactIDs]);
        for(Contact ctc: contactsToUpdate.values())
        {
            System.debug('**Contact to Update: ' + String.valueOf(ctc.Id));
        }
        for(Contact ctc : contactsToUpdate.values())
        {
            ctc.Customer_Reference_Requests_Overall__c = 0;
        }
            
        for (Customer_Reference_Request__c crr : [SELECT Id, Reference_Contact_Name__c,
            Reference_Contact_Name_2__c, Reference_Contact_Name_3__c from Customer_Reference_Request__c WHERE Reference_Contact_Name__c IN :contactIds 
            OR Reference_Contact_Name_2__c IN :contactIds OR Reference_Contact_Name_3__c IN :contactIds])
        {
            System.Debug('***Processing CRR: Reference 1 = ' + String.valueOf(crr.Reference_Contact_Name__c) + '; Reference 2 = ' + String.valueOf(crr.Reference_Contact_Name_2__c) +
                '; Reference 3 = ' + String.valueOf(crr.Reference_Contact_Name_3__c));
            if (crr.Reference_Contact_Name__c != null && contactsToUpdate.containsKey(crr.Reference_Contact_Name__c))
            {
                contactsToUpdate.get(crr.Reference_Contact_Name__c).Customer_Reference_Requests_Overall__c++;
            }
            if (crr.Reference_Contact_Name_2__c != null && contactsToUpdate.containsKey(crr.Reference_Contact_Name_2__c))
            {
                contactsToUpdate.get(crr.Reference_Contact_Name_2__c).Customer_Reference_Requests_Overall__c++;
            }
            if (crr.Reference_Contact_Name_3__c != null && contactsToUpdate.containsKey(crr.Reference_Contact_Name_3__c))
            {
                contactsToUpdate.get(crr.Reference_Contact_Name_3__c).Customer_Reference_Requests_Overall__c++;
            }
        }
        update contactsToUpdate.values();
    }            
}