({
    doInit : function(component, event, helper) {
        helper.getRecordType(component);
        helper.getFields(component);
        helper.getPriceBook(component);
    },

    closeModel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
        component.set("v.isOptionModal", false);
    },

    pageOne : function(component, event, helper) {
        console.log('pageOne');
        component.set("v.pageTwo", false);
        component.set("v.isOptionModal", true);
    },

    pageTwo : function(component, event, helper) {
        console.log('pageTwo');
        var recordType = component.get("v.selectedRecordTypeId");
        //iterate through the recordTypeList to get the selectedRecordTypeName
        var recordTypeList = component.get("v.recordTypeList");
        var selectedRecordTypeName;
        for (var i = 0; i < recordTypeList.length; i++) {
            if (recordTypeList[i].Id === recordType) {
                selectedRecordTypeName = recordTypeList[i].Name;
            }
        }
        component.set("v.selectedRecordTypeName", selectedRecordTypeName);

        console.log('recordType: ' + recordType);
        component.set("v.isOptionModal", false);
        component.set("v.pageTwo", true);
    },

    submitDetails : function(component, event, helper) {
        console.log('submitDetails');
    },

    handleSubmit : function (component, event, helper) {
        component.set("v.Spinner", true);
        event.preventDefault(); 
        var productId = component.get("v.productId");
        var priceookId = component.get("v.pricebookName");
        var description = component.get("v.description");
        var fields = event.getParam("fields");
        var recordType = component.get("v.selectedRecordTypeName");

        if(recordType === 'Product'){
            if(description === undefined || description === '' || description === null){
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error",
                    message: "Please select a Product",
                    type: "error"
                });
                toastEvent.fire();
                return;
            } else {
                fields["buildertek__Product__c"] = productId;
                fields["buildertek__Price_Book__c"] = priceookId;
            }
        } else if(recordType === 'No Product'){
            if(description === undefined || description === '' || description === null){
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error",
                    message: "Please enter a Description",
                    type: "error"
                });
                toastEvent.fire();
                return;
            }
        }
        var allData = JSON.stringify(fields);; 
        console.log('allData: ' , allData);
        var action = component.get("c.saveData");
        action.setParams({
            allData : allData
        });
        action.setCallback(this, function(response){
            console.log(response.getState());
            if(response.getState() == 'SUCCESS') {            
                var result = response.getReturnValue();
                console.log({result});
                component.set("v.Spinner", false);
                $A.get("e.force:closeQuickAction").fire();
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": result,
                    "slideDevName": "Detail"
                });
                navEvt.fire();
            } else {
                console.log('error-->',response.getError());
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);

    },

    changeEvent : function(component, event, helper) {
        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({
            "recordByEvent": product
        });
        compEvent.fire();
        helper.changeEvent(component, event);
    },

    changefamily: function (component, event, helper) {

        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({
            "recordByEvent": product
        });
        compEvent.fire();

    },

    handleComponentEvents: function (component, event, helper) {
        console.log('handleComponentEvents');
        var selectedAccountGetFromEvent = event.getParam("recordByEvent");
        component.set("v.productId", selectedAccountGetFromEvent.Id);
        component.set("v.productName", selectedAccountGetFromEvent.Name);
        helper.getProductDetails(component, event, helper);
    },
})