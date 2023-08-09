({
    closePopupHelper : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.isConsoleNavigation().then(function(response) {
            if (response == true) {
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });

                    var recordId = component.get("v.recordId");
                    //get record id of parent record from 


                    if (recordId) {
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": recordId,
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                    } else {
                        var urlEvent = $A.get("e.force:navigateToURL");
                        urlEvent.setParams({
                            "url": "/lightning/o/buildertek__Pricing_Request_Line_Details__c/list?filterName=Recent"
                        });
                        urlEvent.fire();


                        $A.get("e.force:closeQuickAction").fire();
                        window.setTimeout(
                            $A.getCallback(function() {
                                $A.get('e.force:refreshView').fire();
                            }), 1000
                        );
                    }

                })
                .catch(function(error) {
                    console.log(error);
                });
            } else {
                var recordId = component.get("v.recordId");
                if (recordId) {
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        "recordId": recordId,
                        "slideDevName": "detail"
                    });
                    navEvt.fire();
                } else {
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/lightning/o/buildertek__Pricing_Request_Line_Details__c/list?filterName=Recent"
                    });
                    urlEvent.fire();


                    $A.get("e.force:closeQuickAction").fire();
                    window.setTimeout(
                        $A.getCallback(function() {
                            $A.get('e.force:refreshView').fire();
                        }), 1000
                    );
                }

            }

        });

    },

    createRecordHelper : function(component, event, helper) {
        component.set("v.Spinner", true);
        var PRLineDetails = component.get('v.PRLineDetails');

        console.log('PRLineDetails ::', JSON.stringify(PRLineDetails));

        if (PRLineDetails.buildertek__Pricing_Request_Line__c == null || PRLineDetails.buildertek__Pricing_Request_Line__c == '') {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Error",
                "title": "Error!",
                "message": "Please First Add Pricing Request Line."
            });
            toastEvent.fire();
        } else{
            var action = component.get("c.createPRLineDetails");
            action.setParams({
                "PRLineDetails": PRLineDetails
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log('response.getState() => ', response.getState());
                if (state === "SUCCESS") {

                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                            var focusedTabId = response.tabId;
                            workspaceAPI.closeTab({
                                tabId: focusedTabId
                            });
                        })
                        .catch(function(error) {
                            console.log(error);
                        });

                    var recordId = response.getReturnValue();
                    console.log(recordId);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Success",
                        "title": "Success!",
                        "message": "The record has been created successfully."
                    });
                    toastEvent.fire();

                    var saveNnew = component.get("v.isSaveNew");
                    console.log('saveNnew: ' + saveNnew);

                    if(saveNnew){
                        $A.get('e.force:refreshView').fire();
                        component.set("v.Spinner", false);

                    }
                    else{
                        var navEvent = $A.get("e.force:navigateToSObject");
                        navEvent.setParams({
                            "recordId": recordId,
                        });
                        navEvent.fire();
                    }
                } else {
                    var error = response.getError();
                    console.log('error ==> ', { error });
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": "Error",
                        "title": "Error!",
                        "message": "Something Went Wrong"
                    });
                    toastEvent.fire();
                    component.set("v.Spinner", false);

                }
            });
            $A.enqueueAction(action);
        }
    },

    searchProductHelper: function(component, event, helper){
        console.log('searchProductHelper');
        var searchProductValue = component.get("v.searchProductValue");
    
        var PRLineDetails = component.get('v.PRLineDetails');
        var priceBook = PRLineDetails.buildertek__Price_Book__c;
        priceBook = String(priceBook);

        console.log('priceBook ==> '+priceBook);

        if (priceBook != null && priceBook != '') {
            var action = component.get("c.getProductDetails");
            action.setParams({
                "priceBookId": String(priceBook),
                "searchProductFilter": searchProductValue
            });
            action.setCallback(this, function(response) {
                var productList = response.getReturnValue();
                console.log('productList ==> ',{productList});
                component.set("v.productList",productList);
                component.set("v.displayProduct", true);
            });
            $A.enqueueAction(action);
        } else{
            PRLineDetails.buildertek__Product__c = null;
            component.set("v.PRLineDetails", PRLineDetails);
        }
    },

    getOptions: function(component, event, helper, PRLId){
        var action = component.get("c.getOptions");
        action.setParams({
            "recordId": PRLId
        });
        action.setCallback(this, function(response) {
            var status = response.getState();
            if (status === "SUCCESS") {
                var options = response.getReturnValue();
                console.log('options ==> ',{options});
                component.set("v.PRLineDetails.buildertek__Option__c",options);
            }
        });
        $A.enqueueAction(action);            
    },
})