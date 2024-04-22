({
    doInit : function(component, event, helper) {
        component.set("v.spinner", true); 
        console.log('doInit');
        helper.getRecordType(component);
        helper.getFields(component);
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
    }
})