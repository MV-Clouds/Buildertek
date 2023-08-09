({
	getFields: function (component, event, helper) {
		var action = component.get("c.getFieldSet1");
		action.setParams({
			objectName: 'buildertek__Action_Item__c',
			fieldSetName: 'buildertek__New_Action_Item_Field_set'
		});
		action.setCallback(this, function (response) {
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
				var listOfFields = JSON.parse(response.getReturnValue());
                component.set("v.listOfFields", listOfFields);
				console.log('fields----->',{listOfFields});
			} else {
				console.log('Error');
			}
		});
		$A.enqueueAction(action);
	},
})