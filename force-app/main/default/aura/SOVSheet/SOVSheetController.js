({
    doInit : function(component, event, helper) {
        
        var action1 = component.get("c.getUser");
        action1.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                var commUserId = result.Id;
                if(result.IsPortalEnabled == true){
                    //  component.set("v.communityUserId",commUserId);
                    
                    component.set("v.Iscommunity",true);
                    
                    var loc = location.href.split('id=')[1];
                    var recordId = location.href.split('id=')[1].split("&dummy=")[0];
                    component.set("v.recordId",recordId)
                    
                }else{
                    var recordId = component.get("v.recordId");
                    component.set("v.recordId",recordId)
                }
            }
        });
        $A.enqueueAction(action1);
        
        
        
        var action = component.get("c.getContinuationSheetLines");
        action.setParams({
            recordId : recordId //component.get("v.recordId")    
        });
        action.setCallback(this, function(response){
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                
                var arr = []
                var emptyObj = {
                    'SObjectType':'buildertek__Schedule_of_Value_Lines__c',
                    'buildertek__Description_of_Work__c': result.buildertek__Description_of_Work__c,
                    'buildertek__Scheduled_Value__c' : result.buildertek__Scheduled_Value__c,
                    'buildertek__Item__c': result.buildertek__Item__c
                }
                arr.push(emptyObj)
                component.set("v.continuationSheetLines",arr)
                
            }
        });
    $A.enqueueAction(action);
            
    }
})