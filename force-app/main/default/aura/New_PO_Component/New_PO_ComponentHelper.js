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

	afterDoInit: function (component, event, helper) {
		component.set("v.Spinner", true);
		var adminSetting
		var adminAction = component.get("c.getadminvalues");
		adminAction.setCallback(this, function (response) {
			if (response.getState() == 'SUCCESS') {
				adminSetting = response.getReturnValue();
				console.log('adminSetting-->>', { adminSetting });
				if (adminSetting == 'With PO Lines') {
					component.set("v.ProjectContainer", true);
					component.set("v.MainContainer", false);
				} else {
					component.set("v.MainContainer", true);
				}
			}
		});
		$A.enqueueAction(adminAction);

		let selectedOption = component.get("v.value");
		let splitedOption = selectedOption.split('-');
		console.log('selected option ', selectedOption);
		let fieldSetName;

		if (splitedOption[1] == 'Standard') {
			fieldSetName = 'buildertek__NewPOfromProject';
			component.set("v.recordTypeName", 'Standard');
		} else if (splitedOption[1] == 'Master') {
			fieldSetName = 'buildertek__New_Master_Po';
			component.set("v.recordTypeName", 'Master');
		} else if (splitedOption[1] == 'Variance') {
			fieldSetName = 'buildertek__New_Variance_Po';
			component.set("v.recordTypeName", 'Variance');
		} else {
			fieldSetName = 'buildertek__New_PO_ComponentFields';
		}

		var value = helper.getParameterByName(component, event, 'inContextOfRef');
		console.log('value-->>', { value });
		var context = '';
		var parentRecordId = '';
		component.set("v.parentRecordId", parentRecordId);
		var action2 = component.get("c.getFieldSet");
		action2.setParams({
			objectName: 'buildertek__Purchase_Order__c',
			fieldSetName: fieldSetName
		});
		action2.setCallback(this, function (response) {
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
				component.set("v.Spinner", false);
				var listOfFields0 = JSON.parse(response.getReturnValue());
				console.log('listOfFields0-->>', { listOfFields0 });
				component.set("v.listOfFields0", listOfFields0);
			}
		});
		if (value != null) {
			context = JSON.parse(window.atob(value));
			parentRecordId = context.attributes.recordId;
			component.set("v.parentRecordId", parentRecordId);
			console.log('parentRecordId---->>', { parentRecordId });
			component.set("v.Spinner", false);
		} else {
			var relatedList = window.location.pathname;
			var stringList = relatedList.split("/");
			parentRecordId = stringList[4];
			if (parentRecordId == 'related') {
				var stringList = relatedList.split("/");
				parentRecordId = stringList[3];
			}
			component.set("v.parentRecordId", parentRecordId);
			console.log('parentRecordId-->>', { parentRecordId });
		}
		if (parentRecordId != null && parentRecordId != '') {
			var action = component.get("c.getobjectName");
			action.setParams({
				recordId: parentRecordId,
			});
			action.setCallback(this, function (response) {
				component.set("v.Spinner", false);
				if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
					var objName = response.getReturnValue();
					if (objName == 'buildertek__Project__c') {
						component.set("v.parentprojectRecordId", parentRecordId);
						console.log('We got the parentRecordId', component.get("v.parentprojectRecordId"));
						helper.getCustomerId(component, event, helper, parentRecordId);
						helper.getFieldSetwithProject(component, event, helper);
					}
				}
			});
			$A.enqueueAction(action);
		}
		$A.enqueueAction(action2);
		helper.getPoLineFieldsetFields(component, event, helper, splitedOption[1]);
	},

	getPoLineFieldsetFields: function (component, event, helper, recordType) {
		let fieldSetName;
		var columnList = [];
		var listofPOItems2 = [];

		switch (recordType) {
			case 'Standard':
				fieldSetName = 'buildertek__Standard_PO_Lines';
				break;
			case 'Master':
				fieldSetName = 'buildertek__Master_PO_Lines';
				break;
			case 'Variance':
				fieldSetName = 'buildertek__Variance_PO_Lines';
				break;
			default:
				fieldSetName = 'buildertek__Standard_PO_Lines';
				break;
		}

		var action = component.get("c.getFieldSet");

		action.setParams({
			objectName: 'buildertek__Purchase_Order_Item__c',
			fieldSetName: fieldSetName
		});

		action.setCallback(this, function (response) {
			if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
				component.set("v.Spinner", false);
				var result = JSON.parse(response.getReturnValue());
				var keys = Object.keys(result[0]);
				component.set("v.dynamicKeys", keys);
				console.log('result-->>', { result });

				for (let i = 1; i < 2; i++) {
					let newItem = { 'index': i };
					for (let j = 0; j < result.length; j++) {
						let columnName = result[j].name;
						newItem[columnName] = '';
						columnList.push( {'name' : result[j].label});
					}
					listofPOItems2.push(newItem);

					//! checking for the type of field, if it is REFERENCE then we need to add paddingClass
					for (let k = 0; k < result.length; k++) {
						if (result[k].type == 'REFERENCE') {
							component.set('v.paddingClass','padding-below');
							break;
						}
					}
				}

				console.log('listofPOItems2-->>', { listofPOItems2 });
				console.log('columnList-->>', { columnList });

				component.set("v.PoLineFieldSet", result);
				component.set("v.listofPoLineFieldSetCol", columnList);
				component.set("v.listofPOItems", listofPOItems2);
			}
		});

		$A.enqueueAction(action);
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
				console.log('customerId-->>', component.get("v.customerId"));
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
				console.log('listOfFields1-->>', { listOfFields0 });
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
				console.log('listOfFieldsofPOLine-->>', { listOfFields0 });
				component.set("v.listOfFieldsofPOLine", listOfFields0);
			}
		});
		$A.enqueueAction(action5);
	},

	savePOLineItems: function (component, event, helper, recordId) {
		var listofPOItems = component.get("v.listofPOItems");
		console.log('listofPOItems-->>', { listofPOItems });
		let listofPOItemsToSave = [];

		for (var i = 0; i < listofPOItems.length; i++){
			let newPoToSave = {};
			if (listofPOItems[i].Name != undefined && listofPOItems[i].Name != '' ) {
				newPoToSave = listofPOItems[i];
				listofPOItemsToSave.push(newPoToSave);
			}
		}

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