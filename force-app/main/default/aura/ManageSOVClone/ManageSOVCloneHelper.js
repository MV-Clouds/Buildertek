({
    getApprovedLinesList: function(component,event,helper){
        var action = component.get("c.getApprovedSovData");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var result = response.getReturnValue();
                component.set("v.ApprovedrecordsList",result);
            }
        });
        $A.enqueueAction(action);

                
    },
    
    getPendingLinesList: function(component,event,helper){
        var action = component.get("c.getPendingSovData");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                debugger;
                var result = response.getReturnValue();
                component.set("v.PendingrecordsList",result);
                var ManageSovTotal = 0;  
                for(var i=0;i<result.length;i++){
                    if(result[i].ScheduleValue != undefined && result[i].ScheduleValue != null)
                    ManageSovTotal += result[i].ScheduleValue;
                }
                component.set("v.ManageSovTotal",ManageSovTotal) 
            }
        });
        $A.enqueueAction(action);
    },
    
})