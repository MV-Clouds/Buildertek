({
    doInit : function(component, event, helper) {
        var action = component.get("c.getPermit");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                for(var i=0;i<result.permits.length;i++){
                    result.permits[i].buildertek__Date_Ordered__c = new Date(result.permits[i].buildertek__Date_Ordered__c).toLocaleDateString()
                    result.permits[i].buildertek__Date_Completed__c = new Date(result.permits[i].buildertek__Date_Completed__c).toLocaleDateString()
                }
                component.set("v.permitList",result.permits)
            } 
            else if (state === "INCOMPLETE") {
                console.log("Incomplete")
            }
                else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors) {
                        if (errors[0] && errors[0].message) {
                            console.log("Error message: " + 
                                        errors[0].message);
                        }
                    } else {
                        console.log("Unknown error");
                    }
                }
        });
        $A.enqueueAction(action);
    },
    
    handleCheck :  function(component, event, helper) {
        
    },
    
    selectAll :  function(component, event, helper) {
        
    }
})