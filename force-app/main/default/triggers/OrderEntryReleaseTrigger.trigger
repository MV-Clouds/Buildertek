trigger OrderEntryReleaseTrigger on Order_Entry_Release__c (after insert, after update, before delete) {
    

    if(Trigger.IsAfter){
        if(Trigger.IsInsert){
            list<Order_Entry_Release__c> listorder = new list<Order_Entry_Release__c>();
            list<string> oppidsIGU = new list<string>();
            list<string> oppidsCSS = new list<string>();
            list<string> alloppids = new list<string>();
            
            for(Order_Entry_Release__c order : Trigger.new){
                
                	if(order.Order_Book_Date__c != null)
                			alloppids.add(order.Opportunity__c);
                
                if(order.Order_Type__c=='Standard' && order.Sales_Order_Status__c!='Cancelled' && order.Status__c !='Cancelled' && order.Scheduled_Ship_Date__c != null){
                    if(Schema.getGlobalDescribe().get('Order_Entry_Release__c').getDescribe().getRecordTypeInfosById().get(order.RecordTypeId).getName() == 'IGU')
                    {
                        oppidsIGU.add(order.Opportunity__c); 
                    }
                    if(Schema.getGlobalDescribe().get('Order_Entry_Release__c').getDescribe().getRecordTypeInfosById().get(order.RecordTypeId).getName() == 'Control Hardware')
                    {
                        oppidsCSS.add(order.Opportunity__c); 
                    }
                } 
            } 
            system.debug('listorder'+listorder);
            
            if(oppidsIGU.Size() >0 && !oppidsIGU.isEmpty())
                OrderEntryReleaseTriggerHandler.IGUshiptodatefiledUpdate(oppidsIGU);
            
            if(oppidsCSS.Size() >0 && !oppidsCSS.isEmpty())
                OrderEntryReleaseTriggerHandler.CSSshiptodatefiledUpdate(oppidsCSS);
            
            if(alloppids.Size() >0 && !alloppids.isEmpty())
                OrderEntryReleaseTriggerHandler.OpptyFirstOrderBookedUpdate(alloppids);
        }
        
        if(Trigger.Isupdate && Trigger.IsAfter){
            list<Order_Entry_Release__c> listorder = new list<Order_Entry_Release__c>();
            list<string> oppidsIGU = new list<string>();
            list<string> oppidsCSS = new list<string>();
            list<string> alloppids = new list<string>();
            
            for(Order_Entry_Release__c order : Trigger.new){
                
                if(order.Order_Book_Date__c != trigger.oldMap.get(order.Id).Order_Book_Date__c)
                {
                    alloppids.add(order.Opportunity__c);
                }
                		
                
                if(( order.Scheduled_Ship_Date__c != trigger.oldMap.get(order.Id).Scheduled_Ship_Date__c)  
                   ||  (order.Order_Type__c != trigger.oldMap.get(order.Id).Order_Type__c 
                        && trigger.oldMap.get(order.Id).Order_Type__c=='Standard') 
                   || (trigger.oldMap.get(order.Id).Status__c !=order.Status__c &&  order.Status__c =='Cancelled')){
                       
                       if(Schema.getGlobalDescribe().get('Order_Entry_Release__c').getDescribe().getRecordTypeInfosById().get(order.RecordTypeId).getName() == 'IGU')
                       {
                           oppidsIGU.add(order.Opportunity__c); 
                       }
                       if(Schema.getGlobalDescribe().get('Order_Entry_Release__c').getDescribe().getRecordTypeInfosById().get(order.RecordTypeId).getName() == 'Control Hardware')
                       {
                           oppidsCSS.add(order.Opportunity__c); 
                       }
                   }
                
                
            }
            //   system.debug('listorder'+listorder);
            
            if(oppidsIGU.Size() >0 && !oppidsIGU.isEmpty())
                OrderEntryReleaseTriggerHandler.IGUshiptodatefiledUpdate(oppidsIGU);
            
            if(oppidsCSS.Size() >0 && !oppidsCSS.isEmpty())
                OrderEntryReleaseTriggerHandler.CSSshiptodatefiledUpdate(oppidsCSS);
            
            if(alloppids.Size() >0 && !alloppids.isEmpty())
                OrderEntryReleaseTriggerHandler.OpptyFirstOrderBookedUpdate(alloppids);
            
            
        } 
    }
    
    if(Trigger.IsBefore ){
        if(Trigger.IsDelete){
            for(Order_Entry_Release__c order : Trigger.old)
            {
                if(order.Sales_Order_Status__c =='')
                {
                    order.addError('Can Not Delete Order if its integrated with Oracle');
                    
                }
            }
        }
    } 
}