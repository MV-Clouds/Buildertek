trigger MasterBudgetItemTrigger on buildertek__Master_Budget_Line__c (before insert, after insert, after delete) {
    if(Trigger.isInsert && Trigger.isBefore){
        List<buildertek__Master_Budget_Line__c> mbItems = new List<buildertek__Master_Budget_Line__c>(); 
        for(buildertek__Master_Budget_Line__c masterBudgetLine : Trigger.new){
            if(masterBudgetLine.buildertek__Master_Budget_Item_Group__c == null) {
     			mbItems.add(masterBudgetLine);
     		}
        }
        if(!mbItems.isEmpty()) MasterBudgetItemDAO.setDefaultGrouping(mbItems);
    }
    if(Trigger.isInsert && Trigger.isAfter){
        SET<Id> MasterBudgetId = new SET<Id>();
        SET<Id> projectIdSet = new SET<Id>();
        List<buildertek__Master_Budget_Line__c> masterBudgetLineList = new List<buildertek__Master_Budget_Line__c>();
        for(buildertek__Master_Budget_Line__c masterBudgetLine : Trigger.new){
            MasterBudgetId.add(masterBudgetLine.buildertek__Master_Budget__c);
        }
        List<buildertek__Master_Budget__c> masterBudList ;
        if(Schema.sObjectType.buildertek__Master_Budget__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Master_Budget__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Master_Budget__c.fields.buildertek__Project__c.isAccessible()){
                                        masterBudList = [SELECT Id,
                                                        Name,
                                                        buildertek__Project__c
                                                        FROM buildertek__Master_Budget__c
                                                        WHERE Id IN: MasterBudgetId]; 
            }
        
        for(buildertek__Master_Budget__c masterBud : masterBudList){
            projectIdSet.add(masterBud.buildertek__Project__c);        
        }                                                            
        List<buildertek__Master_Budget_Line__c> masterBudgetLineItems;
        if(projectIdSet.size() > 0){
            if(Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Master_Budget__c.isAccessible() &&
            Schema.sObjectType.buildertek__Master_Budget__c.fields.buildertek__Project__c.isAccessible()){
            masterBudgetLineItems = [SELECT Id,
                                            Name
                                            FROM buildertek__Master_Budget_Line__c
                                            WHERE buildertek__Master_Budget__r.buildertek__Project__c IN: projectIdSet
                                            ORDER BY CreatedDate ASC];   
            }
        }else{
            if(Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.Name.isAccessible()){
            masterBudgetLineItems = [SELECT Id,
                                            Name
                                            FROM buildertek__Master_Budget_Line__c
                                            ORDER BY CreatedDate ASC LIMIT 50000];
            }
        }                                                            
        
        
        String budgetItem;
        Integer i = 1;
        for(buildertek__Master_Budget_Line__c masterBudgetLine : masterBudgetLineItems){
            system.debug('increment --------> '+i);
            if(i > 9){
                budgetItem = 'BI-0000';      
            }else if(i > 99){
                budgetItem = 'BI-000';    
            }else if(i > 999){
                budgetItem = 'BI-00';    
            }else if(i > 9999){
                budgetItem = 'BI-0';    
            }else{
                budgetItem = 'BI-00000';    
            }
            masterBudgetLine.buildertek__Master_Budget_Item__c = budgetItem + i;
            masterBudgetLineList.add(masterBudgetLine);
            i++;    
        }
        if(Schema.sObjectType.buildertek__Master_Budget_Line__c.isUpdateable()&&
            Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Master_Budget_Item__c.isUpdateable()){
           update masterBudgetLineList;  
        }
    }
    
    if(Trigger.isDelete && Trigger.isAfter){
        SET<Id> MasterBudgetId = new SET<Id>();
        SET<Id> projectIdSet = new SET<Id>();
        List<buildertek__Master_Budget_Line__c> masterBudgetLineList = new List<buildertek__Master_Budget_Line__c>();
        for(buildertek__Master_Budget_Line__c masterBudgetLine : Trigger.old){
            MasterBudgetId.add(masterBudgetLine.buildertek__Master_Budget__c);        
        }
        List<buildertek__Master_Budget__c> masterBudList;
        if(Schema.sObjectType.buildertek__Master_Budget__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Master_Budget__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Master_Budget__c.fields.buildertek__Project__c.isAccessible()){
                        masterBudList = [SELECT Id,
                                        Name,
                                        buildertek__Project__c
                                        FROM buildertek__Master_Budget__c
                                        WHERE Id IN: MasterBudgetId]; 
            }
        
        for(buildertek__Master_Budget__c masterBud : masterBudList){
            projectIdSet.add(masterBud.buildertek__Project__c);        
        }                                                            
        List<buildertek__Master_Budget_Line__c> masterBudgetLineItems;
        if(projectIdSet.size() > 0){
            if(Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Master_Budget__c.isAccessible() &&
            Schema.sObjectType.buildertek__Master_Budget__c.fields.buildertek__Project__c.isAccessible()){
            masterBudgetLineItems = [SELECT Id,
                                            Name
                                            FROM buildertek__Master_Budget_Line__c
                                            WHERE buildertek__Master_Budget__r.buildertek__Project__c IN: projectIdSet
                                            ORDER BY CreatedDate ASC];    
            }
        }else{
             if(Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.Id.isAccessible()&&
             Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.Name.isAccessible()){
              masterBudgetLineItems = [SELECT Id,
                                            Name
                                            FROM buildertek__Master_Budget_Line__c
                                            ORDER BY CreatedDate ASC LIMIT 50000];
             }
        }                                                            
        
        
        String budgetItem;
        Integer i = 1;
        for(buildertek__Master_Budget_Line__c masterBudgetLine : masterBudgetLineItems){
            system.debug('increment --------> '+i);
            if(i > 9){
                budgetItem = 'BI-0000';      
            }else if(i > 99){
                budgetItem = 'BI-000';    
            }else if(i > 999){
                budgetItem = 'BI-00';    
            }else if(i > 9999){
                budgetItem = 'BI-0';    
            }else{
                budgetItem = 'BI-00000';    
            }
            masterBudgetLine.buildertek__Master_Budget_Item__c = budgetItem + i;
            masterBudgetLineList.add(masterBudgetLine);
            i++;    
        }
        if(Schema.sObjectType.buildertek__Master_Budget_Line__c.isUpdateable()&&
         Schema.sObjectType.buildertek__Master_Budget_Line__c.fields.buildertek__Master_Budget_Item__c.isUpdateable()){
         update masterBudgetLineList;  
         }
    }    
}