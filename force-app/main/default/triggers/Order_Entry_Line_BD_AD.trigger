trigger Order_Entry_Line_BD_AD on Order_Entry_Line__c (Before Delete, After Delete)
{
    List<Id> oerIdsWithDeletes = new List<Id>();
    Set<String> preConfirmationStatus = new Set<String>{'Draft','Pre-Release Review', 'Confirmation Pending'};
    Map<Id, OrderEntryReleaseWrapper> oerwMap = new Map<Id, OrderEntryReleaseWrapper>();
    List<Order_Entry_Release__c> oersToUpdate = new List<Order_Entry_Release__c>();
    //Map<Id, RecordType> rtMap = Order_Entry_Trigger_Helper_2.getRecordTypeMap('Order_Entry_Line__c');
    Map<ID,Schema.RecordTypeInfo> rt_MapSchema =Schema.SObjectType.Order_Entry_Line__c.getRecordTypeInfosById();        
    if (trigger.isBefore && trigger.isDelete)
    {   
        for (Order_Entry_Line__c oel : trigger.old)
        {
            oerIdsWithDeletes.add(oel.Order_Entry_Release__c);
        }
        //Added by ENP - IGU_Cables_Total_Qty__c,IGU_Cables_Total_Price__c,Trunk_Cables_Total_Qty__c, Trunk_Cables_Total_Price__c, Terminator_and_Connectors_Total_Qty__c, Trunk_Cables_Total_Price__c,
        //Terminator_and_Connectors_Total_Qty__c, Terminator_and_Connectors_Total_Price__c, Window_Controller_Total_Qty__c, Window_Controller_Total_Price__c, Control_Panel_Total_Price__c
        //Control_Panel_Qty__c, Sensor_Total_Quantity__c, Sensor_Total_Price__c To Query Fields
        for (Order_Entry_Release__c oer : [SELECT Id, Status__c,RecordType.DeveloperName,Control_Panel_Qty__c, Control_Panel_Total_Price__c, Sensor_Total_Quantity__c, Sensor_Total_Price__c, IGU_Cables_Total_Qty__c, IGU_Cables_Total_Price__c,
             Drop_Cables_Total_Qty__c, Drop_Cables_Total_Price__c, Trunk_Cables_Total_Qty__c, Trunk_Cables_Total_Price__c, Terminator_and_Connectors_Total_Qty__c,
             Terminator_and_Connectors_Total_Price__c, Window_Controller_Total_Qty__c, Window_Controller_Total_Price__c, Extended_Price_Open__c                             
                FROM Order_Entry_Release__c WHERE Id IN :oerIdsWithDeletes])
        {
            oerwMap.put(oer.Id, new OrderEntryReleaseWrapper(oer));
        }           
        for(Order_Entry_Line__c oel: trigger.old)
        {
            if (rt_MapSchema.get(oel.RecordTypeId).getDeveloperName().contains('IGU'))
            {
                if (!(preConfirmationStatus.contains(oel.Status__c) || 
                    (preConfirmationStatus.contains(oerwMap.get(oel.Order_Entry_Release__c).oer.Status__c) && oel.Status__c == 'Cancelled')))
                {
                    oel.addError('You cannot delete an Order Entry line with Status ' + oel.Status__c);
                }
            }           
        }
        //Added by ENP as part of Project Phase Implementation
        //OrderEntryLineTriggerHandler.DeleteProjectPhaseOrderReferences(Trigger.oldMap);
    }
        
    if (trigger.isAfter && trigger.isDelete)
    {
        oerIdsWithDeletes.clear();
        oerwMap.clear();
        for (Order_Entry_Line__c oel : trigger.old)
        {
            if (rt_MapSchema.get(oel.RecordTypeId).getDeveloperName().contains('IGU') || rt_MapSchema.get(oel.RecordTypeId).getDeveloperName().contains(Label.CSS_Hardware) || rt_MapSchema.get(oel.RecordTypeId).getDeveloperName().contains(Label.CSS_Software))
            {
                oerIdsWithDeletes.add(oel.Order_Entry_Release__c);
            }           
        }   
        //Added by ENP - IGU_Cables_Total_Qty__c,IGU_Cables_Total_Price__c,Trunk_Cables_Total_Qty__c, Trunk_Cables_Total_Price__c, Terminator_and_Connectors_Total_Qty__c, Trunk_Cables_Total_Price__c,
        //Terminator_and_Connectors_Total_Qty__c, Terminator_and_Connectors_Total_Price__c, Window_Controller_Total_Qty__c, Window_Controller_Total_Price__c, Control_Panel_Total_Price__c
        //Control_Panel_Qty__c, Sensor_Total_Quantity__c, Sensor_Total_Price__c To Query Fields
        for (Order_Entry_Release__c oer : [SELECT Id,CSS_Total_Rollup_Qty__c,Status__c,RecordType.DeveloperName, IGU_Count__c, IGU_Area_Sq_Ft__c, IGU_Open_Count__c, IGU_Open_Area_Sq_Ft__c, IGU_Area_Sq_M__c, Extended_Price_Total__c,
             IGU_Open_Area_Sq_M__c, Control_Panel_Qty__c, Control_Panel_Total_Price__c, Sensor_Total_Quantity__c, Sensor_Total_Price__c, IGU_Cables_Total_Qty__c, IGU_Cables_Total_Price__c,
             Drop_Cables_Total_Qty__c, Drop_Cables_Total_Price__c, Trunk_Cables_Total_Qty__c, Trunk_Cables_Total_Price__c, Terminator_and_Connectors_Total_Qty__c,
             Terminator_and_Connectors_Total_Price__c, Window_Controller_Total_Qty__c, Window_Controller_Total_Price__c, Extended_Price_Open__c
                FROM Order_Entry_Release__c WHERE Id IN :oerIdsWithDeletes])
        {
            oerwMap.put(oer.Id, new OrderEntryReleaseWrapper(oer));
        }
        
        for(Order_Entry_Line__c oel : [SELECT Id, Order_Entry_Release__c, Status__c, RecordTypeId, Quantity__c, Area_Sq_Ft__c, Line_Number__c, Unit_Price__c,
            Open_Quantity__c, Unit_Area_Sq_Ft__c, Unit_Area_Sq_M__c, Total_Area_Sq_M__c, Extended_Price__c, Product_Component_Type__c
            FROM Order_Entry_Line__c WHERE Order_Entry_Release__c IN :oerIdsWithDeletes])
        {
            oerwMap.get(oel.Order_Entry_Release__c).addOrderEntryLine(oel, rt_MapSchema.get(oel.RecordTypeId).getDeveloperName());
        }
        for (OrderEntryReleaseWrapper oerw : oerwMap.values())
        {
            oerw.recalculateRollups();
            if (oerw.isUpdated)
            {
                oersToUpdate.add(oerw.oer);
            }
        }
        if (oersToUpdate.size() > 0)
        {
            update oersToUpdate;
        }
    }           
    
}