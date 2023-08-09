({
    doInit: function (component, event, helper) {
        var rfirecId = component.get("v.recordId");
        //alert(rfirecId);
        var action = component.get("c.getRFQRecord");
        //var action = component.get("c.getfields");
        action.setParams({
            recId:rfirecId
        });
        action.setCallback(this,function(response){
            var result = response.getReturnValue();
            //alert(JSON.stringify(result));
            if(response.getState() == "SUCCESS"){
                
                var state = response.getState();
                
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    
                    component.set("v.rfqRecordDetails", result);
                    
                }
            }
        })
        $A.enqueueAction(action);
        helper.getcurr(component, event, helper);
        helper.getmulticur(component, event, helper);
    },
})