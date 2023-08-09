({
	init: function (component, event, helper) {
		component.set("v.COData", true);
		component.set("v.myColumns", [
			{ label: "Option Name", fieldName: "Name", type: "text" },
			{
				label: "Quantity",
				fieldName: "buildertek__Quantity__c",
				type: "number",
				cellAttributes: { alignment: "left" },
			},
			{
				label: "Total Cost Per Unit",
				fieldName: "buildertek__Total_Cost_Per_Unit__c",
				type: "currency",
				cellAttributes: { alignment: "left" },
			},
			{
				label: "Total Cost",
				fieldName: "buildertek__Total_Cost__c",
				type: "currency",
				cellAttributes: { alignment: "left" },
			},
			{ 
                label: 'Markup',
                fieldName: 'buildertek__Markup__c',
                // type: 'percent',
                // typeAttributes: { 
				// 	step: '.001', minimumFractionDigits: '1', maximumFractionDigits: '2'

                // },
                cellAttributes: { alignment: 'left' },
                
            },
			// {
			// 	label: "Sales Price",
			// 	fieldName: "buildertek__Cost__c",
			// 	type: "currency",
			// 	cellAttributes: { alignment: "left" },
			// },
			{
				label: "Total Sales Price",
				fieldName: "buildertek__Total_Sales_Price__c",
				type: "currency",
				cellAttributes: { alignment: "left" },
			},
			{
				label: "Manufacturer",
				fieldName: "ManufacturerName",
				type: "text",
			},
			
			{
				label: "Upgrade Cost",
				fieldName: "buildertek__Upgrade_Costs__c",
				type: "currency",
				cellAttributes: { alignment: "left" },
			},
		]);
	},

	upgradeOption: function (component, event, helper) {
		component.set("v.COData", false);
		component.set("v.Upgrade", true);
		helper.getData(component);
	},

	upgradeAllOption: function (component, event, helper) {
		component.set("v.COData", false);
		component.set("v.Upgrade", true);
		helper.getAllData(component);
	},

	updateSelectedText: function (component, event, helper) {
		var selectedRows = event.getParam("selectedRows");
		console.log("selectedRows => ", { selectedRows });
		component.set("v.selectedRowList", selectedRows);
	},

	createRecord: function (component, event, helper) {
		var coData = component.get('v.changeOrder');
		console.log('CO Data ==> ' + coData.Name);
		if (coData.Name != '') {
			var selectedRowList = component.get("v.selectedRowList");
			console.log('selectedRowList =>', { selectedRowList });
			if (selectedRowList.length != 0) {
				component.set("v.Spinner", true);
				var action = component.get("c.createCO");
				action.setParams({
					coData: coData,
					selectedRowList: selectedRowList
				});
				action.setCallback(this, function (response) {
					var state = response.getState();
					console.log('State => ' + state);
					if (state == "SUCCESS") {
						var result = response.getReturnValue();
						helper.showToast("Success", "Success", "New CO and CO Lines Created.", "5000");
						$A.get("e.force:closeQuickAction").fire();
						var navEvt = $A.get("e.force:navigateToSObject");
						navEvt.setParams({
							"recordId": result,
							"slideDevName": "Detail"
						});
						navEvt.fire();
					} else {
						helper.showToast("Error", "Error", "Something Went Wrong", "5000");
						var error = response.getError();
						console.log('Error =>', { error });
					}
					component.set("v.Spinner", false);
				});
				$A.enqueueAction(action);
			} else {
				helper.showToast("Error", "Error", "Please Select Options", "5000");
			}
		} else {
			helper.showToast("Error", "Error", "Change Order Name is required", "5000");
		}
	},
	closeModal: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},
});