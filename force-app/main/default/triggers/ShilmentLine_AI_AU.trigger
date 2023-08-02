trigger ShilmentLine_AI_AU on Shipment_Line__c (After insert,After update) 
{
    if(trigger.isInsert)
        Order_Line_Fulfillment_Create_Update.oerlFullFillment(trigger.new);
       
    if(trigger.isUpdate)
        Order_Line_Fulfillment_Create_Update.updateOelFullMent(trigger.newMap, trigger.oldMap);

}