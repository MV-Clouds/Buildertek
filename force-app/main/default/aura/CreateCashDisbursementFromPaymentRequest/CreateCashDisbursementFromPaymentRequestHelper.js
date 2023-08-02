({
    getFields: function (component, event, helper) {
        console.log('DoInitHelper');
		console.log(component.get("v.recordId"));
        component.set('v.Spinner', true);
		var action = component.get("c.getFieldSet");
		component.set('v.Spinner', true);
		action.setParams({
			objectName: 'buildertek__Payment__c',
			fieldSetName: 'buildertek__New_Cash_Disbursement_Field_Set',
		});
		action.setCallback(this, function (response) {
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
				var listOfFields = JSON.parse(response.getReturnValue());
                component.set("v.listOfFields", listOfFields);
				component.set('v.Spinner', false);
				console.log('List Name => ', listOfFields);
			} else {
				console.log('Error');
				component.set('v.Spinner', false);
			}
		});
		$A.enqueueAction(action);
		
		var parentRecordId = component.get("v.recordId");
		var action2 = component.get("c.getParentRecord");
		component.set('v.Spinner', true);
		action2.setParams({
			parentRecordId: parentRecordId
		});
		action2.setCallback(this, function (response) {
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
					var parentRecord = response.getReturnValue();
					component.set("v.parentRecord", parentRecord);
					component.set('v.Spinner', false);
					console.log('response.getReturnValue() => '+ JSON.stringify(parentRecord));
			} else {
				console.log('Error');
				component.set('v.Spinner', false);
			}
		});

		$A.enqueueAction(action2);
        


		// console.log('FieldValue => ', component.find('inputFields1').get("v.value"));

	},
})