({
	getpreviousWarrantyRec: function (component, event, helper) {
         var warrantyRec = component.get("v.parentRecordId"); 
        if(warrantyRec != ''){
            var action = component.get("c.warrantydetails");
            action.setParams({
                warrantyrecId: warrantyRec
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result != ''){
                        component.set("v.warrantyList",result);
                        component.set("v.isWarranty",true); 
                    }
                }
            });
            $A.enqueueAction(action); 
        }
        else if(warrantyRec == ''){
            component.set("v.isWarranty",false);
        }
    },
})