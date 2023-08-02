({
    doInit: function (component, event, helper) {
        debugger;
        console.log('Do Init Call');
        var recordId = component.get("v.recordId");
        console.log('Record Id:::',recordId);
        component.set('v.vendorId', '');
        component.set('v.projectId', '');
        component.set('v.billId', '');
        var value = helper.getParameterByName(component, event, 'inContextOfRef');
        var context = '';
        var parentRecordId = '';
        component.set("v.parentRecordId", parentRecordId);
        if (value != null) {
            context = JSON.parse(window.atob(value));
            parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId", parentRecordId);
        } else {
            var relatedList = window.location.pathname;
            var stringList = relatedList.split("/");
            parentRecordId = stringList[4];
            if (parentRecordId == 'related') {
                var stringList = relatedList.split("/");
                parentRecordId = stringList[3];
            }
           // console.log('projectId:::',parentRecordId);
            component.set("v.parentRecordId", parentRecordId);
        }
        if(parentRecordId != null && parentRecordId != ''){
                var action = component.get("c.getobjectName");
                action.setParams({
                    recordId: parentRecordId,
                });
                action.setCallback(this, function (response) {
                    if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                        var objName = response.getReturnValue();
                        if(objName == 'buildertek__Purchase_Order__c'){
                            component.set("v.purchaseid", parentRecordId);
                        }else if(objName == 'buildertek__Project__c'){
                            component.set("v.projectId", parentRecordId);
                        }else if(objName == 'buildertek__Account_Payable__c'){
                            component.set("v.billId", parentRecordId);
                        }else if(objName == 'Account'){
                            component.set("v.vendorId", parentRecordId);
                            if(component.get("v.vendorId") != null){
                                var vendorId = component.get("v.vendorId");
                                helper.getAllPO(component, event, helper, vendorId);
                                // alert('vendorId'+component.get("v.vendorId")); 
                            }
                        }
                    } 
                });
                $A.enqueueAction(action);
            }
    },

    saveRecord: function (component, event, helper) {
        var receiptObj = {};
        receiptObj.buildertek__Bill__c = component.get('v.billId');
        receiptObj.buildertek__Vendor__c = component.get('v.vendorId');
        receiptObj.buildertek__Project__c = component.get('v.projectId');
        receiptObj.buildertek__Purchase_Order__c = component.get('v.purchaseid');
        receiptObj.buildertek__Memo__c = 'Received Items (Bill to Follow)';
        if(component.find('datereceived').get('v.value')!='' && component.find('datereceived').get('v.value')!=undefined){
            receiptObj.buildertek__Date_Received__c = component.find('datereceived').get('v.value');
        }
        receiptObj.buildertek__Ref_No__c = component.find('refNo').get('v.value');
        console.log('Date::',component.find('datereceived').get('v.value'));
        
        var POList = component.get('v.POList');
        console.log('POList::', JSON.stringify(POList));
        var receiptLineItems = [];
        for (var i in POList) {
            if (POList[i].buildertek__Is_Selected__c != undefined && POList[i].buildertek__Is_Selected__c && POList[i].buildertek__Purchase_Order_Items__r != undefined) {
                var POItems = POList[i].buildertek__Purchase_Order_Items__r.records;
                for (var j in POItems) {
                    var receiptLineItem = {};
                    receiptLineItem.Name = POList[i].buildertek__Item_Name__c;
                    receiptLineItem.buildertek__PO__c = POList[i].Id;
                    receiptLineItem.buildertek__PO_Line__c = POItems[j].Id;
                    receiptLineItem.buildertek__Quantity__c = POItems[j].buildertek__Items_Received__c;
                    receiptLineItem.buildertek__Cost__c = POItems[j].buildertek__Unit_Price__c;
                    receiptLineItem.buildertek__Description__c = POItems[j].buildertek__Description__c;
                    receiptLineItem.buildertek__Product__c = POItems[j].buildertek__Product__c;
                    receiptLineItems.push(receiptLineItem);
                }
            }
        }

        var action = component.get('c.createReceiptItem');
        action.setParams({
            "receiptObj": JSON.stringify(receiptObj),
            "POList": JSON.stringify(JSON.parse(JSON.stringify(receiptLineItems)))
        });
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                //Close Modal
                helper.closeReceiptItemModal(component, event, helper);

                setTimeout(function () {
                    //Redirect to record
                    var navEvt = $A.get("e.force:navigateToSObject");
                    navEvt.setParams({
                        recordId: response.getReturnValue(),
                        slideDevName: "related",
                    });
                    navEvt.fire();
                    //$A.get("e.force:closeQuickAction").fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": 'success',
                        "mode": 'dismissible',
                        "title": "Success!",
                        "message": "Item Receipt created successfully!"
                    });
                    toastEvent.fire();
                }, 1000)
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": 'error',
                    "mode": 'dismissible',
                    "title": "Error!",
                    "message": "Something went Wrong!"
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    //Hide popup box
    createItemReceipt: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var POList = component.get('v.POList');
        var countSelectedPO = 0;
        for (var i in POList) {
            if (POList[i].buildertek__Is_Selected__c != undefined && POList[i].buildertek__Is_Selected__c) {
                countSelectedPO++;
            }
        }
        if (countSelectedPO > 0) {
            component.set('v.isStatusOpen', false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": 'success',
                "mode": 'dismissible',
                "title": "Success!",
                "message": "PO has been added successfully!"
            });
            toastEvent.fire();
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
        } else {
            component.set('v.isStatusOpen', true);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": 'warning',
                "mode": 'dismissible',
                "title": "Warning!",
                "message": "Please select PO before adding!"
            });
            toastEvent.fire();
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
        }
    },

    getLookUpValues: function (component, event, helper) {
        var fieldName = event.getParam("fieldName");
        var recordId = event.getParam("selectedRecordId");
        var purchaseOrderList = event.getParam('POList');

        if (fieldName == 'buildertek__Vendor__c') {
            component.set("v.vendorId", recordId);
            if (purchaseOrderList.length > 0) {
                component.set('v.POList', purchaseOrderList);
                component.set('v.isStatusOpen', true);
            }
        } else if (fieldName == 'buildertek__Project__c') {
            component.set("v.projectId", recordId);
        } else if (fieldName == 'buildertek__Bill__c') {
            component.set("v.billId", recordId);
        }
    },

    //Hide Open Po's
    closeModel: function (component, event, helper) {
        component.set('v.isStatusOpen', false);
        var POList = component.get('v.POList');
        for (var i in POList) {
            if (POList[i].buildertek__Is_Selected__c != undefined && POList[i].buildertek__Is_Selected__c && POList[i].buildertek__Purchase_Order_Items__r != undefined) {
                POList[i].buildertek__Is_Selected__c != POList[i].buildertek__Is_Selected__c;
            }
        }
        component.set('v.POList', POList);
        $A.get("e.force:closeQuickAction").fire()
    },

    closeReceiptItems: function (component, event, helper) {
        helper.closeReceiptItemModal(component, event, helper);
    }
})