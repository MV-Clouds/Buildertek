({
    doInit: function (component, event, helper) {
        var action = component.get("c.get_option");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            console.log('result ==> ', { result });
            if (result.buildertek__RFQ_Line__c != null && result.buildertek__RFQ_Line__c != '') {
                helper.showToast("Error", "Error", "RFQ is already exist", "5000");
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },

    createRFQ: function (component, event, helper) {
        var rfq = component.get('v.createRfq');
        console.log('rfq ==> ' + rfq.Name);
        var action = component.get("c.RFQFrom_Option");
        if (rfq.Name != '') {
            action.setParams({
                rfq: rfq,
                optionId: component.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log('State => ' + state);
                if (state == 'SUCCESS') {
                    var result = response.getReturnValue();
                    helper.showToast("Success", "Success", "New RFQ Is Created.", "5000");
                    $A.get("e.force:closeQuickAction").fire();
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": result,
                        "slideDevName": "Detail"
                    });
                    navEvt.fire();
                } else {
                    helper.showToast("Error", "Error", "Something Went Wrong", "5000");
                }
                component.set("v.Spinner", false);
            });
            $A.enqueueAction(action);
        }
        else {
            helper.showToast("Error", "Error", "RFQ Name is required", "5000");
        }
    },
    closeModal: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})