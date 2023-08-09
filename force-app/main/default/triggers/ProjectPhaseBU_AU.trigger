trigger ProjectPhaseBU_AU on Project_Phase__c(after update,before insert, before update) 
{
     Map<string, string> mapRefDesc = new Map<string, string>();
     List<Order_Entry_Line__c> updateOELs=new List<Order_Entry_Line__c>();
     set<Id> orderIds=new set<Id>();
     list<Order_Entry_Release__c> lstOers= new list<Order_Entry_Release__c>();
      public Set<String> allowCRD = new Set<String>{'Draft','Planned','Change Requested'};
    if(trigger.isAfter){
    
        for(Project_Phase__c ph: trigger.new)
        {
            if(trigger.oldmap.get(ph.Id).Phase_Description__c != ph.Phase_Description__c)
            {
                mapRefDesc.put(ph.Customer_Reference_id__c,ph.Phase_Description__c);
            }
        }
        for(Order_Entry_Line__c  oel:[select id,Reference_ID__c,Order_Entry_Release__c,order_Entry_Release__r.status__c,Customer_Reference_Description__c from Order_Entry_Line__c where Reference_ID__c in:mapRefDesc.keyset()])
        {
            if(mapRefDesc.containsKey(oel.Reference_ID__c) && allowCRD.contains(oel.order_Entry_Release__r.status__c))
            {
                oel.Customer_Reference_Description__c = mapRefDesc.get(oel.Reference_ID__c);
                oel.Trigger_Source__c = 'UI';
                updateOELs.add(oel);
                if(oel.order_Entry_Release__r.status__c != 'Draft')
                orderIds.add(oel.Order_Entry_Release__c);
            }
        }
        if(!updateOELs.isEmpty() && !test.isRunningTest()){
        
            update updateOELs;
        }
        if(!orderIds.isEmpty())
        {
            for(Order_Entry_Release__c oer:[select id,status__c from Order_Entry_Release__c where Id in:orderIds])
            {
                oer.status__c = 'Change Integration Requested';
                oer.Trigger_Source__c = 'UI';
                lstOers.add(oer);
            }
            update lstOers;
        }
    }
    if(trigger.isBefore)
    {
        Map<string, string> mapDescRef = new Map<string, string>();
        //Map<string, string> mapphaseBooked = new Map<string, string>();
        set<Id> booked= new set<Id>();
        set<Id> IntegrationIds= new set<Id>();
        set<Id> curIds=new set<Id>();
        if(trigger.isupdate)
        curIds=trigger.newmap.keyset();
        for(Project_Phase__c ph: [select id,Phase_Description__c,Customer_Reference_id__c from Project_Phase__c where Phase_Description__c!=null])
        {
            if(!curIds.contains(ph.Id))
            {
                mapDescRef.put(ph.Phase_Description__c,ph.Customer_Reference_id__c);
            }
        }
        for(Phase_Order_Line__c phol:[select Id,Project_Phase__c,Customer_Reference_Description__c,Customer_Reference_id__c,Header_Status__c,Line_Status__c,Sales_Order_Status__c from Phase_Order_Line__c])
        {
            if(phol.Sales_Order_Status__c == 'Booked' || phol.Header_Status__c == 'Approved-to-Ship' || phol.Line_Status__c == 'Approved-to-Ship')
                booked.add(phol.Project_Phase__c);
            if(phol.Header_Status__c!=null && phol.Header_Status__c.contains('Integration') || !allowCRD.contains(phol.Header_Status__c))
               IntegrationIds.add(phol.Project_Phase__c);
        }
        for(Project_Phase__c ph:trigger.new)
        {
            if(mapDescRef.containskey(ph.Phase_Description__c) && mapDescRef.get(ph.Phase_Description__c)!=ph.Customer_Reference_id__c)
            ph.addError('Customer reference description should be unique');
            if(trigger.isupdate && trigger.oldmap.get(ph.Id).Phase_Description__c != ph.Phase_Description__c)
            {
                If(ph.Source_of_Change__c == null || ph.Reason_of_Change__c == null)
                ph.addError('If you change Customer reference description then you should fill Source and Reason');
                if(booked.contains(ph.Id))
                ph.addError('Customer reference description not allowed to change due to booked orders');
                if(IntegrationIds.contains(ph.Id))
                ph.addError('Customer reference description not allowed to change due to Integration orders');
            }
        }
        
    }
}