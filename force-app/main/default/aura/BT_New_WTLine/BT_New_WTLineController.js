({
    doInit : function(component, event, helper) {
        component.set("v.spinner", true); 
        console.log('doInit');
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
        var fields = event.getParam("fields");
        var allData = JSON.parse(JSON.stringify(fields)); 
        var recordType = component.get("v.selectedRecordTypeName");
        if(recordType === 'Product'){
            if(allData.buildertek__Product__c === undefined || allData.buildertek__Product__c === '' || allData.buildertek__Product__c === null){
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error",
                    message: "Please select a Product",
                    type: "error"
                });
                toastEvent.fire();
                return;
            }
        }
        if(recordType === 'No Product'){
            if(allData.buildertek__Description__c === undefined || allData.buildertek__Description__c === '' || allData.buildertek__Description__c === null){
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
                $A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(action);

    },

    changeEvent : function(component, event, helper) {
        console.log('changeEvent in controller');
        helper.changeEvent(component, event);
    },
})