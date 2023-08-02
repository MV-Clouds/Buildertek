({
    init: function (component, event, helper) {
        component.set("v.myColumns", [
            { label: "Option Name", fieldName: "Name", type: "text" },
            {
                label: "Quantity",
                fieldName: "buildertek__Quantity__c",
                type: "number",
                cellAttributes: { alignment: "left" },
            },
            {
                label: "Manufacturer",
                fieldName: "ManufacturerName",
                type: "text",
            },
            {
                label: "Sales Price",
                fieldName: "buildertek__Cost__c",
                type: "currency",
                cellAttributes: { alignment: "left" },
            },
            {
                label: "Upgrade Cost",
                fieldName: "buildertek__Upgrade_Costs__c",
                type: "currency",
                cellAttributes: { alignment: "left" },
            },
        ]);
        helper.getData(component);
    },


    createRFQ: function (component, event, helper) {
        var cOrder = component.get('v.createRfq');
        console.log('cOrder ==> ' + cOrder.Name);
        if (cOrder.Name != '') {
            var selectedRowList = component.get("v.selectedRowList");
            console.log('selectedRowList =>', { selectedRowList });
            if (selectedRowList.length != 0) {
                component.set("v.Spinner", true);
                var action = component.get("c.RFQList");
                console.log('*****');
                console.log(action);
                console.log('*****');
                action.setParams({
                    cOrder: cOrder,
                    selectedRowList: selectedRowList
                });

                action.setCallback(this, function (response) {
                    console.log('*****20');
                    var state = response.getState();
                    console.log(state);
                    console.log('*****22');
                    console.log('State => ' + state);
                    if (state == "SUCCESS") {
                        var result = response.getReturnValue();
                        helper.showToast("Success", "Success", "New RFQ is created.", "5000");
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

    updateSelectedText: function (component, event, helper) {
        var selectedRows = event.getParam("selectedRows");
        console.log("selectedRows => ", { selectedRows });
        component.set("v.selectedRowList", selectedRows);
    },


    closeModal: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }, 

})