({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.getPaymentAppData");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            console.log('paymentAppData ==> ',{result});
            if (result.buildertek__PA_Type__c == null) {
                helper.showToast("Error", "Error", "Please add PA Type in Payment Application", "5000");
                $A.get("e.force:closeQuickAction").fire();
            } else if (result.buildertek__PA_Type__c == 'AP' && result.buildertek__Invoice_AP__c != null) {       
                helper.showToast("Error", "Error", "Invoice (AP) is already exist", "5000");
                $A.get("e.force:closeQuickAction").fire();
            } else if (result.buildertek__PA_Type__c == 'AR' && result.buildertek__Invoice_AR__c != null) {       
                helper.showToast("Error", "Error", "Invoice (AR) is already exist", "5000");
                $A.get("e.force:closeQuickAction").fire();
            } else{
                component.set("v.paymentAppData", result);
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action); 
    }, 

    newInvoice : function(component, event, helper){
        component.set("v.Spinner", true);
        var action = component.get("c.createInvoice");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var status = response.getState();
            if (status == 'SUCCESS') {
                var result = response.getReturnValue();
                console.log('result ==> ',{result});

                if (result != null) {
                    var navEvent = $A.get("e.force:navigateToSObject");
                    navEvent.setParams({
                        "recordId": result,
                    });
                    navEvent.fire();
                } else {
                    helper.showToast("Error", "Error", "Something Wrong With PA Type", "5000");
                }
                $A.get("e.force:closeQuickAction").fire();

            } else{
                helper.showToast("Error", "Error", "Something Went Wrong", "5000");
                var error = response.getError();
                console.log('Error =>',{error});
            }
            component.set("v.Spinner", false);
        });
        $A.enqueueAction(action); 
    },

    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})