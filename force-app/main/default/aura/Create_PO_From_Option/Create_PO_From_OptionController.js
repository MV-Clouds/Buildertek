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
            var result = response.getReturnValue();
            console.log('Result =>', { result });
            
            if(result[0] == 'Error') {
                if (result[1] == 'Duplicate') {
                    helper.showToast("Error", "Error", "PO Line is already exist", "5000");
                } else if(result[1].includes("Vendor")){
                    helper.showToast("Error", "Error", "Manufacturer is missing in current record", "5000");
                } else if(result[1].includes("Add Product")){
                    helper.showToast("Error", "Error", "Product is missing in current record", "5000");
                } else if(result[1].includes("Check Selected")){
                    helper.showToast("Error", "Error", "Selected field is not checked in record", "5000");
                } else if(result[1].includes("STRING_TOO_LONG")){
                    helper.showToast("Error", "Error", "Poduct name is too long", "5000");
                } else {
                    console.log('Error Message ==> '+result[1]);
                    helper.showToast("Error", "Error", result[1], "5000");
                }
            } else {
                helper.showToast("Success", "Success", "New PO Created.", "5000");
                var navEvent = $A.get("e.force:navigateToSObject");
                navEvent.setParams({
                    "recordId": result[1],
                });
                navEvent.fire();
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