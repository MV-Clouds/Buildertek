trigger InspectionTrigger on Inspection__c (Before Insert, After Insert) {
    if(Trigger.isBefore) {
        
        if(Trigger.isInsert){
            BT_Utils.genrateAutoNumber([Select Id, Auto_Number1__c from Inspection__c
                                     where Project__c =:trigger.New[0].Project__c 
                                     ORDER BY CREATEDDATE DESC  LIMIT 1], trigger.New, 'Auto_Number1__c');
        }
    }
    if(Trigger.isInsert && Trigger.isAfter){
    	SET<Id> InspectionIdSet = new SET<Id>();
    	SET<Id> projectIdSet = new SET<Id>();
    	List<buildertek__Inspection__c> inspectionToUpdate = new List<buildertek__Inspection__c>();
    	
    	for(buildertek__Inspection__c masterBud : trigger.new){
    		projectIdSet.add(masterBud.buildertek__Project__c);        
    	}                                                            
    	List<buildertek__Inspection__c> inspectionsList;
    	if(projectIdSet.size() > 0){
    	    if(Schema.sObjectType.buildertek__Inspection__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Inspection__c.fields.Name.isAccessible()&&
            Schema.sObjectType.buildertek__Inspection__c.fields.buildertek__Project__c.isAccessible()){	
    		inspectionsList = [SELECT Id,
    									Name
    									FROM buildertek__Inspection__c
    									WHERE buildertek__Project__c IN: projectIdSet
    									ORDER BY CreatedDate ASC];   
            }
    	}else{
    	    if(Schema.sObjectType.buildertek__Inspection__c.fields.Id.isAccessible()&&
            Schema.sObjectType.buildertek__Inspection__c.fields.Name.isAccessible()){	
    		inspectionsList = [SELECT Id,
    									Name
    									FROM buildertek__Inspection__c
    									ORDER BY CreatedDate ASC LIMIT 50000];
            }
    	}                                                            
    	
    	
    	String inspectionId;
    	Integer i = 0;
    	for(buildertek__Inspection__c inspection : inspectionsList){
    		system.debug('increment --------> '+i);
    		if(i > 9){
    			inspectionId = 'IS-0000';      
    		}else if(i > 99){
    			inspectionId = 'IS-000';    
    		}else if(i > 999){
    			inspectionId = 'IS-00';    
    		}else if(i > 9999){
    			inspectionId = 'IS-0';    
    		}else{
    			inspectionId = 'IS-00000';    
    		}
    		inspection.buildertek__Inspection_Id__c = inspectionId + i;
    		inspectionToUpdate.add(inspection);
    		i++;    
    	}
    	if(Schema.sObjectType.buildertek__Inspection__c.isUpdateable()&&
            Schema.sObjectType.buildertek__Inspection__c.fields.buildertek__Inspection_Id__c.isUpdateable()){
    	    update inspectionToUpdate;    
            }
    }
}