({
	getFields: function (component, event, helper) {
		var action = component.get("c.getFieldSet");
		action.setParams({
			objectName: 'buildertek__Payment__c',
			fieldSetName: 'buildertek__New_Cash_Disbursement_Field_Set'
		});
		action.setCallback(this, function (response) {
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
				var listOfFields = JSON.parse(response.getReturnValue());
                component.set("v.listOfFields", listOfFields);
			} else {
				console.log('Error');
			}
		});
		$A.enqueueAction(action);
	},
})