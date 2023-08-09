({
    doInit : function(component, event, helper) {
        var id = component.get("v.poId");
        if(id != undefined){
            var action = component.get("c.getContactName");
            action.setParams({
                recId : component.get("v.poId")
            });
            action.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS"){
                     var result = response.getReturnValue();
                    if(result != "undefine"){
                    component.set("v.contactName",response.getReturnValue());
                    }
                    else{
                        component.set("v.contactName","undefine");
                    }
                }
                else{
                    console.log(response.getError());
                }
            });
            $A.enqueueAction(action);
        }
        else{
            component.set("v.contactName","undefine");
        }
    }
})