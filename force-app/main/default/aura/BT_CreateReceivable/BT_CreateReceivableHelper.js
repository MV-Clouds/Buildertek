({
	createInvoice: function (component, helper) {
		var action = component.get("c.createARFromCO");
		action.setParams({
			coId: component.get("v.recordId")
		});

		action.setCallback(this, function (response) {
			if (component.isValid() && response.getState() === "SUCCESS") {
				if (response.getReturnValue().strMessage == 'Success') {
					$A.get("e.force:closeQuickAction").fire();
					component.find('notifLib').showNotice({
						"variant": "success",
						"header": "Success",
						"message": "Invoice created.",
						closeCallback: function () {
							$A.get('e.force:refreshView').fire();
						}
					});
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": response.getReturnValue().strRecordId,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
				}
			} else {

				component.find('notifLib').showNotice({
					"variant": "error",
					"header": "Error",
					"message": response.getError()[0].message,
					closeCallback: function () {
						$A.get("e.force:closeQuickAction").fire();
					}
				});
			}
		});

		$A.enqueueAction(action);
	}
})