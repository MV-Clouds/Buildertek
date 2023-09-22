({
    doInit : function(component, event, helper) {
        var action = component.get("c.cloneScheduleRecords");
		action.setParams({
			scheduleId: component.get("v.recordId")
		});
		action.setCallback(this, function(response) {
			var state = response.getState();
			if (state === "SUCCESS") {

                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": response.getReturnValue()
                });
                navEvt.fire();

                var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"type": "Success",
					"title": "Success!",
					"message": "Schedule was created successfully."
				});
				toastEvent.fire();
                $A.get("e.force:closeQuickAction");
			}
			else {
                $A.get("e.force:closeQuickAction");

				console.log(response.getError());

                var toastEvent = $A.get("e.force:showToast");
				toastEvent.setParams({
					"type": "Error",
					"title": "Error!",
					"message": "Something Went Wrong."
				});
				toastEvent.fire();

                $A.get("e.force:closeQuickAction");
			}
		});
		$A.enqueueAction(action);

    }
})
