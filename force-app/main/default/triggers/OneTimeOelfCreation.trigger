trigger OneTimeOelfCreation on Shipment_Line__c (After update) 
{
        if(System.Label.oelfCreate == 'True')
        {
                OneTimeOelfCreationHandler.createOelf(trigger.newMap,trigger.oldMap);
        }
}