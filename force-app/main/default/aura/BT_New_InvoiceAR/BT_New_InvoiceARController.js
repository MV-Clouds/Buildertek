({
    doInit: function (component, event, helper) {
        
        console.log('doInit');    
        component.set("v.Spinner", true);
        var action = component.get("c.getItem");
        var coItem = JSON.stringify(component.get("v.newCOItems"));
        console.log('coItem--->>>',{coItem});
       
        action.setParams({
            coItems: coItem
        });
        action.setCallback(this, function (response) {
            debugger;
            var state = response.getState();
            var error = response.getError();
            console.log({error});
            
           
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.coItemsToInsert", result);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);   
    },

    updateProductInfo: function (component, event, helper) {
        var indexOfElementChanged = event.getParam('value');
        helper.productselectedprice(component, event, helper, indexOfElementChanged);
    },

    removeProduct: function (component, event, helper) {
        var rowIndex = event.target.dataset.name;
        var FiltersList = component.get("v.coItemsToInsert");
        FiltersList.splice(rowIndex, 1);
        for (var i = 0; i < FiltersList.length; i++) {
            FiltersList[i].rowIndex = i;
        }
        component.set("v.coItemsToInsert", FiltersList);
    },

    doSave: function (component, event, helper) {
        console.log(JSON.stringify(component.get("v.coItemsToInsert")));
        component.set("v.Spinner", true);
        var action;
        action = component.get("c.createInvoiceAR");
        action.setParams({
            coJson: component.get("v.newCO"),
            coItemsJson: JSON.stringify(component.get("v.coItemsToInsert")),
            budgetlineid: component.get("v.budgetlineid"),
            descri : component.get("v.invoiceDescription")
            
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                if (result.isSuccess === true) {
                    component.set("v.Spinner", false);
                    helper.showToast("Success", "Success", "New Invoice (AR) is created successfully", "5000");
                    var sObjectEvent = $A.get("e.force:navigateToSObject");
                    sObjectEvent.setParams({
                        "recordId": result.strRecordId,
                    })
                    sObjectEvent.fire();
                } else {
                    component.set("v.Spinner", false);
                    console.log('result.strMessage ==> '+result.strMessage);
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "Error",
                        "message": result.strMessage,
                        closeCallback: function () {}
                    });
                }
            }
        });
	    if(component.find('coName').get("v.value")){
             $A.enqueueAction(action);
        }else{
            component.set("v.Spinner", false);
            component.find('notifLib').showNotice({
                            "variant": "error",
                            "header": "Error",
                            "message": "Please enter required fields",
                            closeCallback: function () {}
                        });
        }
    },

    doCancel: function (component, event, helper) {
        component.get("v.cancelCallback")();
    },
    addProduct: function (component, event, helper) {
        var coItemsToInsert = component.get("v.coItemsToInsert");
        var lstOfFilters = JSON.stringify(coItemsToInsert);
        var action = component.get("c.addProductsToList");
        action.setParams({
            COItems: lstOfFilters,
            COItem: component.get("v.newCOItem"),
            count: coItemsToInsert.length
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.coItemsToInsert", result);
            }
        });
        $A.enqueueAction(action);
    },
})