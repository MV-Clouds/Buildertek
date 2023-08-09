trigger InspectionItemTrigger on buildertek__Inspection_Line__c (after insert) {
    if(Trigger.isInsert && Trigger.isAfter){
        SET<Id> InspectionId = new SET<Id>();
        SET<Id> projectIdSet = new SET<Id>();
        List<buildertek__Inspection_Line__c> inspectionLineList = new List<buildertek__Inspection_Line__c>();
        for(buildertek__Inspection_Line__c inspectionLine : Trigger.new){
            InspectionId.add(inspectionLine.buildertek__Inspection__c);        
        }
        List<buildertek__Inspection__c> inspectionList;
        if(Schema.sObjectType.buildertek__Inspection__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Inspection__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Inspection__c.fields.buildertek__Project__c.isAccessible()){
                          inspectionList = [SELECT Id,
                                            Name,
                                            buildertek__Project__c
                                            FROM buildertek__Inspection__c
                                            WHERE Id IN: InspectionId]; 
            }
        for(buildertek__Inspection__c ins : inspectionList){
            projectIdSet.add(ins.buildertek__Project__c);        
        }                                                            
        List<buildertek__Inspection_Line__c>InspectionLineItems;
        if(projectIdSet.size() > 0){
            if(Schema.sObjectType.buildertek__Inspection_Line__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Inspection_Line__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Inspection_Line__c.fields.buildertek__Inspection__c.isAccessible() &&
			Schema.sObjectType.buildertek__Inspection__c.fields.buildertek__Project__c.isAccessible()){
            InspectionLineItems = [SELECT Id,
                                            Name
                                            FROM buildertek__Inspection_Line__c
                                            WHERE buildertek__Inspection__r.buildertek__Project__c IN: projectIdSet
                                            ORDER BY CreatedDate ASC];   
			}
        }else{
             if(Schema.sObjectType.buildertek__Inspection_Line__c.fields.Id.isAccessible()&&
              Schema.sObjectType.buildertek__Inspection_Line__c.fields.Name.isAccessible()){
              InspectionLineItems = [SELECT Id,
                                            Name
                                            FROM buildertek__Inspection_Line__c
                                            ORDER BY CreatedDate ASC LIMIT 50000];
            }
        }                                                            
        
        
        String inspectionItem;
        Integer i = 0;
        for(buildertek__Inspection_Line__c insLine : InspectionLineItems){
            system.debug('increment --------> '+i);
            if(i > 9){
                inspectionItem = 'ISL-0000';      
            }else if(i > 99){
                inspectionItem = 'ISL-000';    
            }else if(i > 999){
                inspectionItem = 'ISL-00';    
            }else if(i > 9999){
                inspectionItem = 'ISL-0';    
            }else{
                inspectionItem = 'ISL-00000';    
            }
            insLine.buildertek__Inspection_Item_Name__c = inspectionItem + i;
            inspectionLineList.add(insLine);
            i++;    
        }
        if(Schema.sObjectType.buildertek__Inspection_Line__c.isUpdateable()&&
         Schema.sObjectType.buildertek__Inspection_Line__c.fields.buildertek__Inspection_Item_Name__c.isUpdateable()){
          update inspectionLineList;       
         }
    }  
}