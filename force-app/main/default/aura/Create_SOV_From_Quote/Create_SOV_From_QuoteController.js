({
    doInit : function(component, event, helper) {
        var action = component.get("c.getQuoteData");
        action.setParams({
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var result = response.getReturnValue();
            if (result.buildertek__Schedule_of_Values__c != null) {
                $A.get("e.force:closeQuickAction").fire();
                helper.showToast("Error", "Error", "SOV is already exist", "5000");
            }
            
        });
        $A.enqueueAction(action); 
    }, 

    newSOV : function(component, event, helper){
        try {
            component.set("v.Spinner", true);
            var action = component.get("c.createSOV");
            action.setParams({
                recordId: component.get("v.recordId")
            });
            action.setCallback(this, function (response) {
                var status = response.getState();
                if (status == 'SUCCESS') {
                    var result = response.getReturnValue();
                    console.log('result ==> ',{result});
    
                    var navEvent = $A.get("e.force:navigateToSObject");
                    navEvent.setParams({
                        "recordId": result,
                    });
                    navEvent.fire();
                } else{
                    helper.showToast("Error", "Error", "Something Went Wrong", "5000");
                    var error = response.getError();
                    console.log('Error =>',{error});
                }
                $A.get("e.force:closeQuickAction").fire();
                component.set("v.Spinner", false);
            });
            $A.enqueueAction(action); 
        } catch (error) {
            console.log('Error ==> ',{error});
        }

    },

    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})