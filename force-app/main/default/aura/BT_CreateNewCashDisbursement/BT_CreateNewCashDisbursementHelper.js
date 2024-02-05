({
	getFields: function (component, event, helper) {
		var action = component.get("c.getFieldSet");
		action.setParams({
			objectName: 'buildertek__Payment__c',
			fieldSetName: 'buildertek__New_Cash_Disbursement_Field_Set',
			recordId: component.get("v.recordId"),
		});
		action.setCallback(this, function (response) {
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {

					let result = response.getReturnValue();
					var listOfFields = JSON.parse(result.fieldSet);
					component.set("v.listOfFields", listOfFields);
					component.set("v.vendorId", result.vendorId);
					component.set("v.projectId", result.projectId);
			} else {
				console.log('Error', response.getError());
				helper.showToast('Error', 'Something went wrong!', 'error');
			}
		});
		$A.enqueueAction(action);
	},

	showToast : function(title, message, type) {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			"title": title,
			"message": message,
			"type": type
		});
		toastEvent.fire();
	}
})