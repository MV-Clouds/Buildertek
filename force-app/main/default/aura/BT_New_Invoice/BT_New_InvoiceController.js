({

    doInit: function (component, event, helper) {
        
        component.set("v.Spinner", true);
        var action = component.get("c.getProduct");
        var coItem = JSON.stringify(component.get("v.newCOItems"));
       
        action.setParams({
            coItems: coItem
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
           
            
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.coItemsToInsert", result);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
        //helper.fetchPickListVal(component, event, helper);
        //helper.fetchRecordTypes(component, event, helper);        
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

    updateProductInfo: function (component, event, helper) {
        var indexOfElementChanged = event.getParam('value');
        helper.productselectedprice(component, event, helper, indexOfElementChanged);
    },

    doSave: function (component, event, helper) {
        //alert(component.get("v.budgetId"));
       //alert(component.get("v.invoiceDescription"));
       //alert( JSON.stringify(component.get("v.coItemsToInsert")));
        console.log(JSON.stringify(component.get("v.coItemsToInsert")));
        component.set("v.Spinner", true);
        var action;
        action = component.get("c.createCO");
        //alert(component.get("v.budgetlineid"));
        action.setParams({
            coJson: component.get("v.newCO"),
            coItemsJson: JSON.stringify(component.get("v.coItemsToInsert")),
            budgetlineid: component.get("v.budgetlineid"),
           // poId: component.find('poId').get("v.value"),
            descri : component.get("v.invoiceDescription")
            
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                //$A.enqueueAction(component.get("v.saveCallback"));
                var result = response.getReturnValue();
                if (result.isSuccess === true) {
                    component.set("v.Spinner", false);
                    var sObjectEvent = $A.get("e.force:navigateToSObject");
                    sObjectEvent.setParams({
                        "recordId": result.strRecordId,
                    })
                    sObjectEvent.fire();

                    /*  component.find('notifLib').showNotice({
                        "variant": "success",
                        "header": "Success",
                        "message": 'Change Order created successfully',
                        closeCallback: function() {
                            var sObjectEvent = $A.get("e.force:navigateToSObject");
                            sObjectEvent.setParams({
                                "recordId": result.strRecordId,
                            })
                            sObjectEvent.fire(); 
                        }
                    });   */

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
	//if(component.find('poId').get("v.value") && component.find('coName').get("v.value")){
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
        
       
        /*var accountId = component.get("v.newCO.buildertek__Vendor__c");
        if(accountId != ''){
            component.set('v.newCO.buildertek__Customer_Account__c',component.get("v.newCO.buildertek__Vendor__c"));
            var action;
    		action = component.get("c.createCO");
            action.setParams({
                coJson:  component.get("v.newCO"),
                coItemsJson: JSON.stringify(component.get("v.coItemsToInsert"))
            });
            action.setCallback(this, function (response) {
                if (component.isValid() && response.getState() === "SUCCESS") {
                    $A.util.removeClass(component.find("fteErrorone"), "show");
	            	$A.enqueueAction(component.get("v.saveCallback"));
	            	var result = response.getReturnValue();
                    var sObjectEvent = $A.get("e.force:navigateToSObject");
                    sObjectEvent.setParams({
                        "recordId": response.getReturnValue().Id,
                    })
                    sObjectEvent.fire();
                    component.set("v.Spinner", false);
    			}
            });
            
            $A.enqueueAction(action);
        }else{
            alert('Please Select Vendor');
            $A.util.addClass(component.find("fteErrorone"),"show");
        }*/

    },

    doCancel: function (component, event, helper) {
        component.get("v.cancelCallback")();
    }
})