/*************************/
// Name             : ProductClassification
// Description      : This trigger is used to update the Opportunity Product Business Type Based on Product selection
// Autour           : UgaDurga Prasad
// Test Class       : ProductClassification_Test
/*************************/
trigger ProductClassification on OpportunityLineItem (before insert,before update, after insert, after update,after delete) {
    if(Trigger.isBefore && !RecursionControl.isRecursive){
        System.debug('I am at before events');
        set<Id> productIds = new set<Id>();
        for(OpportunityLineItem oli:Trigger.New){
            productIds.add(oli.Product2Id);
        }
        Map<Id,Product2> prodMap = new Map<Id,Product2>([select id,Product_Group__c,Revenue_Category__c,Product_Business_Type__c from Product2 where id in :productIds]);
        Boolean hasSmartGlass = false;
        List<OpportunityLineItem> updateBusinessType = new List<OpportunityLineItem>();
        for(OpportunityLineItem oli:Trigger.New){
            Product2 prodObj = prodMap.get(oli.Product2Id);
            if(Trigger.isUpdate){
                OpportunityLineItem oldRecord = Trigger.OldMap.get(oli.id);
            }else{
                oli.Product_Group__c = prodObj.Product_Group__c;
                oli.Business_Type__c = prodObj.Product_Business_Type__c;
                oli.Revenue_Category__c = prodObj.Revenue_Category__c;
            }
        }
    }
    if(Trigger.isAfter){
        Set<Id> opportunitID=new set<Id>();
        if(Trigger.isDelete && !RecursionControl.isDeleteRecursive){
            for( OpportunityLineItem opli:  trigger.old){
                opportunitID.add(opli.OpportunityId);
            }
            RecursionControl.isDeleteRecursive = true;
        }else if((Trigger.isInsert || Trigger.isUpdate) && !RecursionControl.isRecursive){
            for( OpportunityLineItem opli:  trigger.new){
                opportunitID.add(opli.OpportunityId);
            }
            RecursionControl.isRecursive = true;
        }/*else if(Trigger.isUpdate && !RecursionControl.isUpdateRecursive){
            for( OpportunityLineItem opli:  trigger.new){
                opportunitID.add(opli.OpportunityId);
            }
            RecursionControl.isUpdateRecursive = true;
        }*/
        if(opportunitID.Size()>0){
            List<OpportunityLineItem> lineItemsList = [select id,Business_Type__c,Product2Id from OpportunityLineItem where opportunityId IN :opportunitID];
            Boolean hasSG = false;
            Boolean hasCompute = false;
            set<Id> productIds = new set<Id>();
            //and Business_Type__c='Smart Building Platform' and BT_Manual_Update__c=false
            for(OpportunityLineItem oil:[select Product2Id from OpportunityLineItem where opportunityId IN :opportunitID]){
                productIds.add(oil.Product2Id);
            }
            map<id,Product2> prodMap = new map<id,Product2>([select id from Product2 where id in :productIds and Product_Business_Type__c ='Smart Building Platform']);
            for(OpportunityLineItem oil: lineItemsList){
                if(prodMap.get(oil.Product2Id) == null){
                    if(oil.Business_Type__c =='Smart Glass'){
                        hasSG = true;
                    }
                    if(oil.Business_Type__c =='Compute'){
                        hasCompute = true;
                    }
                }
            }
            System.debug('hasSG value:'+hasSG);
            System.debug('hasCompute value:'+hasCompute);
            List<OpportunityLineItem> itemsForUpdate = new List<OpportunityLineItem>();
            for(OpportunityLineItem oil:[select id,Business_Type__c,Product2Id from OpportunityLineItem where opportunityId IN :opportunitID and BT_Manual_Update__c=false]){
                Boolean manualBTUpdate = false;
                Boolean addForUpdate = false;
                if(Trigger.isUpdate && !RecursionControl.isDeleteRecursive){
                    OpportunityLineItem oldRec = Trigger.oldMap.get(oil.id);
                    System.debug('oldRec value:'+oldRec+' oil Id:'+oil.id+' Old mpa:'+Trigger.OldMap);
                    if(oldRec != null && (oldRec.Business_Type__c != oil.Business_Type__c)){
                        manualBTUpdate = true;
                        oil.BT_Manual_Update__c=true;
                        addForUpdate = true;
                    }
                }
                if(!manualBTUpdate && prodMap.get(oil.Product2Id) != null){
                    system.debug('Before setting the BT values');
                    if(hasCompute){
                        oil.Business_Type__c = 'Compute';
                    }
                    if(hasSG){
                        oil.Business_Type__c = 'Smart Glass';  
                    }
                    if(!hasCompute && !hasSG){
                        oil.Business_Type__c = 'Smart Building Platform';
                    }
                    addForUpdate = true;
                }
                if(addForUpdate){
                    itemsForUpdate.add(oil);
                }
            }
            System.debug('records for update:'+itemsForUpdate);
            update itemsForUpdate;
        }
    }
}