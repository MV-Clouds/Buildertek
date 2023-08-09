({
    createInvoice: function(component, event, helper){
        component.set("v.Spinner", true);
        var recordId = component.get("v.recordId");
        console.log('recordId => '+recordId);
        var action = component.get("c.createInv");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State => ' + state);            
            if (state == "SUCCESS"){
                var result = response.getReturnValue();
                console.log('Result ==> '+result);
                helper.showToast("Success", "Success", "New Invoice and Invoice Line Created.", "5000");

                $A.get("e.force:closeQuickAction").fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": result,
                    "slideDevName": "Detail"
                });
            navEvt.fire();
            } else{
                helper.showToast("Error", "Error", "Something Went Wrong", "5000");
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action);
    },

    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})