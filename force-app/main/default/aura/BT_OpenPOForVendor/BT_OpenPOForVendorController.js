({
    doInit: function (component, event, helper) {
        if (component.get('v.recordId') != undefined) {
            var action = component.get('c.openPO');
            var purchaseOrderList = [];
            action.setParams({
                "recordId": component.get('v.recordId')
            });
            console.log('Init Call::');
            action.setCallback(this, function (response) {
                if (response.getState() == "SUCCESS" && response.getReturnValue()) {
                    purchaseOrderList = JSON.parse(response.getReturnValue().purchaseOrderMap);
                    if (purchaseOrderList.length > 0) {
                        for (var i in purchaseOrderList) {
                            if (purchaseOrderList[i].buildertek__Is_Selected__c == undefined) {
                                purchaseOrderList[i].buildertek__Is_Selected__c = false;
                                purchaseOrderList[i].buildertek__Is_Option_Expanded__c = false;
                                purchaseOrderList[i].buildertek__Items_Received__c = 0; //Set default selected iItem 0
                            }
                        }
                        console.log('PO Items::', JSON.stringify(purchaseOrderList));
                        component.set('v.POList', purchaseOrderList);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    },
    expandPO: function (component, event, helper) {
        var expandedId = event.getSource().get("v.name");
        var POList = component.get('v.POList');
        POList.filter(function (selectedPO) {
            if (selectedPO.Id == expandedId) {
                selectedPO.buildertek__Is_Option_Expanded__c = true;
            }
        });
        component.set('v.POList', POList);
    },
    collapsePO: function (component, event, helper) {
        var collapsedId = event.getSource().get("v.name");
        var POList = component.get('v.POList');
        POList.filter(function (selectedPO) {
            if (selectedPO.Id == collapsedId) {
                selectedPO.buildertek__Is_Option_Expanded__c = false;
            }
        });
        component.set('v.POList', POList);
    },
    onChangeHandler: function (component, event, helper) {
        var poID = event.getSource().get("v.text");
        var purchaseOrderList = component.get('v.POList');
        purchaseOrderList.filter(function (purchaseOrder) {
            purchaseOrder.Id == poID ? purchaseOrder.buildertek__Is_Selected__c = true : '';
        });
        console.log('PurchaseOrderList::', purchaseOrderList);
        component.set('v.POList', purchaseOrderList);
    },

    createItemReceipt: function (component, event, helper) {
        var toastEvent = $A.get("e.force:showToast");
        component.set('v.loading', true);
        var purchaseOrderList = [];
        var purchaseOrders = component.get('v.POList');
        if (purchaseOrders != undefined) {
            for (var i in purchaseOrders) {
                if (purchaseOrders[i].buildertek__Is_Selected__c) {
                    var obj = {};
                    obj.buildertek__Purchase_Order__c = purchaseOrders[i].Id;
                    obj.buildertek__Vendor__c = purchaseOrders[i].buildertek__Vendor__c;
                    obj.buildertek__Memo__c = 'Received Items (Bill to Follow)';
                    purchaseOrderList.push(obj);
                }
            }
        }
        if (purchaseOrderList.length > 0) {
            helper.createItemReceipt(component, event, helper, purchaseOrderList);
        } else {
            component.set('v.loading', false);
            toastEvent.setParams({
                "type": 'error',
                "title": "Error!",
                "message": "Something went wrong!"
            });
            toastEvent.fire();
        }
    },

    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    selectAll: function (component, event, helper) {
        var selectedHeaderCheck = event.getSource().get("v.value");
        var POList = component.get("v.POList");
        var getAllId = component.find("checkPO");
        if (POList != null) {
            if (POList.length > 1) {
                if (!Array.isArray(getAllId)) {
                    if (selectedHeaderCheck == true) {
                        component.find("checkPO").set("v.value", true);
                    } else {
                        component.find("checkPO").set("v.value", false);
                    }
                } else {
                    if (selectedHeaderCheck == true) {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkPO")[i].set("v.value", true);
                            var checkbox = component.find("checkPO")[i].get("v.text");
                            POList[i].buildertek__Is_Selected__c = true;
                        }
                    } else {
                        for (var i = 0; i < getAllId.length; i++) {
                            component.find("checkPO")[i].set("v.value", false);
                            var checkbox = component.find("checkPO")[i].get("v.text");
                            var POList = component.get("v.POList");
                            POList[i].buildertek__Is_Selected__c = false;
                        }
                    }
                }
            } else {
                var i = 0;
                if (selectedHeaderCheck == true) {
                    component.find("checkPO").set("v.value", true);
                    var checkbox = component.find("checkPO").get("v.text");
                    POList[i].buildertek__Is_Selected__c = true;
                } else {
                    component.find("checkPO").set("v.value", false);
                    var checkbox = component.find("checkPO").get("v.text");
                    var POList = component.get("v.POList");
                    POList[i].buildertek__Is_Selected__c = false;
                }
            }
        }
        component.set('v.POList', POList);
    }
})