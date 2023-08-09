({
    doInithelper : function(component, event, helper) {
        var action = component.get("c.getRecord");
        action.setParams({
            recordId : component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.BudgetLine", result);
            } else {
                var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"type": "Error",
					"title": "Error!",
					"message": "Something Went Wrong."
				});
				toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    unitPriceChange : function(component, event, helper){
        console.log('unitPriceChange');
        var action = component.get("c.getunitPrice");
        action.setParams({
            "productId" : component.get('v.BudgetLine.buildertek__Product__c')[0]
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Inside')
                var result = response.getReturnValue();
                console.log('Result ==> ',{result});
                if(result == null || result == undefined || result == '' || result == ' ' ){
                    component.set("v.BudgetLine.buildertek__Unit_Price__c", null);
                }
                else{
                component.set("v.BudgetLine.buildertek__Unit_Price__c", result);
                }
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "Error",
                    "title": "Error!",
                    "message": "Error in calling method."
                });
                toastEvent.fire();
            }
        }); $A.enqueueAction(action);
    }
})