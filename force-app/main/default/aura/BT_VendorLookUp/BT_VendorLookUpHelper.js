({
    getAllPO: function (component, event, helper, vendorId) {
        if (vendorId != undefined) {
            var action = component.get('c.openPO');
            var purchaseOrderList = [];
            action.setParams({
                "recordId": vendorId
            });

            action.setCallback(this, function (response) {
                if (response.getState() == "SUCCESS" && response.getReturnValue()) {
                    purchaseOrderList = JSON.parse(response.getReturnValue().purchaseOrderMap);
                    console.log('purchaseOrderList::', purchaseOrderList);
                    if (purchaseOrderList.length > 0) {
                        for (var i in purchaseOrderList) {
                            if (purchaseOrderList[i].buildertek__Is_Selected__c == undefined) {
                                purchaseOrderList[i].buildertek__Is_Selected__c = false;
                            }
                        }
                        var cmpEvent = component.getEvent("onSelectEvt");
                        cmpEvent.setParams({
                            "childObjectName": component.get("v.childObjectName"),
                            "fieldName": component.get("v.fieldName"),
                            "selectedRecordId": component.find("lookupField").get("v.value"),
                            "POList": purchaseOrderList,
                        });
                        cmpEvent.fire();
                        component.set('v.POList', purchaseOrderList);
                    }
                }
            });
            $A.enqueueAction(action);
        }
    }
})