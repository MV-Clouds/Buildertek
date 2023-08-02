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
                console.log({result});
                component.set("v.coItemsToInsert", result);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
        helper.fetchPickListVal(component, event, helper);
        helper.fetchRecordTypes(component, event, helper);        
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
        // let checkProductId = event.getSource().get('v.value')[0];
        // if(checkProductId != undefined){
        helper.productselectedprice(component, event, helper, indexOfElementChanged);
        // }
    },

    doSave: function (component, event, helper) {
        console.log(component.get("v.newCO").Name);
        // Check:- Product inside the list of the co Item is empty or not
        let jsonArray=JSON.stringify(component.get("v.coItemsToInsert"));
        let parseJson = JSON.parse(jsonArray);
        let listCOItem=[];
        parseJson.forEach(function(value){
            // If the product is empty then remove it from the Json 
            if(typeof(value.changeOrderItem.buildertek__Product__c) != 'string'){
                delete value.changeOrderItem.buildertek__Product__c;
            }
            listCOItem.push(value);

        });
        jsonArray=JSON.stringify(listCOItem);
        if (component.get("v.newCO").Name != null && component.get("v.newCO").Name != '') {
            component.set("v.Spinner", true);
            var action;
            action = component.get("c.createCO");
            action.setParams({
                coJson: component.get("v.newCO"),
                coItemsJson: jsonArray,
                budgetlineid: component.get("v.budgetlineid")
            });
            action.setCallback(this, function (response) {
                if (component.isValid() && response.getState() === "SUCCESS") {
                    //$A.enqueueAction(component.get("v.saveCallback"));
                    var result = response.getReturnValue();
                    if (result.isSuccess === true) {

                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": "Success",
                            "title": "Success!",
                            "message": "Change Order has been created successfully."
                        });
                        toastEvent.fire();

                        var sObjectEvent = $A.get("e.force:navigateToSObject");
                        sObjectEvent.setParams({
                            "recordId": result.strRecordId,
                        })
                        sObjectEvent.fire();

                        setTimeout(function(){
                            component.set("v.Spinner", false);
                        }, 1000);
                        

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
            $A.enqueueAction(action);
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
    },
    
})