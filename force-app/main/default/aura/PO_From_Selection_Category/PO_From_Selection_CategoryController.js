({
    createPOrecord: function(component, event, helper){
        component.set("v.Spinner", true);
        var recordId = component.get("v.recordId");
        console.log('recordId => '+recordId);
        var action = component.get("c.createPO");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State => ' + state);
            
            if (state == "SUCCESS"){
                helper.showToast("Success", "Success", "New PO and PO Line Created.", "5000");
            } else{
                helper.showToast("Error", "Error", "Something Went Wrong", "5000");
            }
            component.set("v.Spinner", false);
            $A.get("e.force:closeQuickAction").fire();
        });
        $A.enqueueAction(action);
    },

    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})