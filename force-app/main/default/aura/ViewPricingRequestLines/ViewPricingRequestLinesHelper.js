({
    getcurr : function (component, event, helper) {
        var action = component.get("c.getcurrency");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currencycode",response.getReturnValue());
            } 
        });
        $A.enqueueAction(action);		
    },
    
    
    
    getPricingreqLines : function (component, event, helper) {
        
        
        var action1 = component.get("c.getSovLines");
        action1.setParams({
            recordId: component.get("v.recordId")
        });
        action1.setCallback(this, function(response){
            debugger;
            
            if(response.getState() === "SUCCESS"){
                var result = response.getReturnValue();
                if(result.length > 0){
                    debugger;
                    component.set("v.continuationSheetLines",result)
                 
                    var sovlist = component.get("v.continuationSheetLines");
                    
                    component.set("v.continuationSheetLines",sovlist);
                }else{
                    var arr = []
                    var emptyObj;
                    emptyObj = {
                        'SObjectType':'buildertek__Pricing_Request_Line__c',
                        'buildertek__Description__c': "",
                        'buildertek__Notes__c' : ""
                    }  
                    
                    
                    arr.push(emptyObj)
                    component.set("v.continuationSheetLines",arr) 
                    
                }
                
                
                
                
            }
        });
        $A.enqueueAction(action1);
        
        
    }
    
})