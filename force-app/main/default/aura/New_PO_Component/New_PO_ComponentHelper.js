({
    getParameterByName: function (component, event, name) {
		name = name.replace(/[\[\]]/g, "\\$&");
		var url = window.location.href;
		var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
		var results = regex.exec(url);
		if (!results) return null;
		if (!results[2]) return '';
		return decodeURIComponent(results[2].replace(/\+/g, " "));
	},

	getCustomerId: function (component, event, helper, parentRecordId) {
		var action4 = component.get("c.getCustomerId")
		action4.setParams({
			recordId: parentRecordId
		});
		action4.setCallback(this, function (response) {
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
				component.set("v.Spinner", false);
				var customerId = response.getReturnValue();
				// console.log('customerId-->>',{customerId});
				component.set("v.customerId", customerId);
				console.log('customerId-->>',component.get("v.customerId"));
			}
		});
		$A.enqueueAction(action4); 
	},

	getFieldSetwithProject: function (component, event, helper) {
		var action3 = component.get("c.getFieldSet");
		action3.setParams({
			objectName: 'buildertek__Purchase_Order__c',
			fieldSetName: 'buildertek__NewPOfromProject'
		});
		action3.setCallback(this, function (response) {     
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
				component.set("v.Spinner", false);
				var listOfFields0 = JSON.parse(response.getReturnValue());
				console.log('listOfFields1-->>',{listOfFields0});
				component.set("v.listOfFields1", listOfFields0);
			}
		});
		$A.enqueueAction(action3);
	},

	getFieldSetforPOLine: function (component, event, helper) {
		var action5 = component.get("c.getFieldSet");
        action5.setParams({
            objectName: 'buildertek__Purchase_Order_Item__c',
            fieldSetName: 'buildertek__POLinefromProject'
        });
        action5.setCallback(this, function (response) {     
            if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                component.set("v.Spinner", false);
                var listOfFields0 = JSON.parse(response.getReturnValue());
                console.log('listOfFieldsofPOLine-->>',{listOfFields0});
                component.set("v.listOfFieldsofPOLine", listOfFields0);
            }
        });
        $A.enqueueAction(action5);
	},

	setupListofPOItem: function (component, event, helper) {
		var listofPOItems = [];
		for (var i = 1; i < 2; i++){
			listofPOItems.push({
				'index': i,
				'Name': '',
				'buildertek__Quantity__c': '',
				'buildertek__Unit_Price__c': '',
		});
		}
		console.log('listofPOItems-->>',{listofPOItems});
		component.set("v.listofPOItems", listofPOItems);
	},

	savePOLineItems : function(component, event, helper, recordId) {
		var listofPOItems = component.get("v.listofPOItems");
		var listofPOItemsToSave = [];
		for (var i = 0; i < listofPOItems.length; i++){
			if (listofPOItems[i].Name != '' && listofPOItems[i].buildertek__Quantity__c != '' && listofPOItems[i].buildertek__Unit_Price__c != '') {
				// listofPOItemsToSave.push(listofPOItems[i]);
				let poLineObj = {
					'Name' : listofPOItems[i].Name,
					'buildertek__Quantity__c' : listofPOItems[i].buildertek__Quantity__c,
					'buildertek__Unit_Price__c' : listofPOItems[i].buildertek__Unit_Price__c
				}
				listofPOItemsToSave.push(poLineObj);
			}
		}
		console.log('listofPOItemsToSave-->>',{listofPOItemsToSave});
		console.log('recordId-->>',{recordId});
		debugger;
		var action6 = component.get("c.savePOLineItems");
		action6.setParams({
			listofPOItemsToSave: listofPOItemsToSave,
			recordId: recordId
		});
		action6.setCallback(this, function (response) {
			console.log('callback');
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
				console.log('inserted')
			}
		});
		$A.enqueueAction(action6);
	},


})