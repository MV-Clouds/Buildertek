({
    doInit: function (component, event, helper) {
        component.set("v.Spinner", true);
        var action = component.get("c.getProduct");
        var rfqItem = JSON.stringify(component.get("v.newRFQItems"));
        action.setParams({
            rfqItems: rfqItem
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result -------> ' + JSON.stringify(result));
                component.set("v.rfqItemsToInsert", result);
                component.set("v.Spinner", false);

            }
        });
        $A.enqueueAction(action);
    },

    removeProduct: function (component, event, helper) {
        var rowIndex = event.target.dataset.name;
        var FiltersList = component.get("v.rfqItemsToInsert");
        FiltersList.splice(rowIndex, 1);
        for (var i = 0; i < FiltersList.length; i++) {
            FiltersList[i].rowIndex = i;
        }
        component.set("v.rfqItemsToInsert", FiltersList);
    },

    addProduct: function (component, event, helper) {
        var rfqItemsToInsert = component.get("v.rfqItemsToInsert");
        var lstOfFilters = JSON.stringify(rfqItemsToInsert);
        var action = component.get("c.addProductsToList");
        action.setParams({
            rfqItemsList: lstOfFilters,
            rfqItem: component.get("v.newRFQItem"),
            count: rfqItemsToInsert.length
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.rfqItemsToInsert", result);
            }
        });
        $A.enqueueAction(action);
    },

    doSave: function (component, event, helper) {
        console.log('doSave');
        component.set("v.Spinner", true);
        var action;
        action = component.get("c.createRFQ");
        var finalString = JSON.stringify(component.get("v.rfqItemsToInsert"));
        var rfqJson = JSON.stringify(component.get("v.newRFQ"));
        action.setParams({
            rfqJson: rfqJson,
            rfqItemsJson: finalString
        });
        action.setCallback(this, function (response) {
            console.log(response.getState());
            console.log(response.getError());

            if (component.isValid() && response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.isSuccess === true) {
                  /*  var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: 'Success',
                        mode: 'sticky',
                        duration: 2,
                        message: 'RFQ created successfully',
                        type: 'success'
                    });
                    toastEvent.fire(); */
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'RFQ created successfully.',
                        duration:' 3000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                    $A.enqueueAction(component.get("v.saveCallback"));
                    var sObjectEvent = $A.get("e.force:navigateToSObject");
                    sObjectEvent.setParams({
                        "recordId": result.strRecordId,
                    })
                    sObjectEvent.fire();
                    component.set("v.Spinner", false);
               } else {
                    component.set("v.Spinner", false);
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Error",
                        "message": result.strMessage,
                        closeCallback: function () {}
                    });
                }
            }
        });
        $A.enqueueAction(action);
    },

    doCancel: function (component, event, helper) {
        component.get("v.cancelCallback")();
    }
})