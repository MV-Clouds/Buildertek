({
    doInit : function(component, event, helper) {
        helper.getDataFromFieldSet(component, event, helper);
        helper.getCaseTeamMembers(component, event, helper);
        helper.getselectOptions(component, event, helper);
    },
    handleOnUserChange : function(component, event, helper) {
        component.set( "v.selectedUserRecordId", event.getParams( "fields" ).value );
    },
    handleGotoRelatedList : function(component, event, helper) {
        component.set("v.showInMobile",true);         
    },
    viewAllRecord : function(component, event, helper) {
        component.set("v.displayAll",true);         
    },
    viewLessRecord : function(component, event, helper) {
        component.set("v.displayAll",false);         
    },
    addMember : function(component, event, helper) {
        component.set("v.isOpen", true);       
    },
    closeModel: function(component, event, helper) {
        component.set("v.isOpen", false);       
        component.set("v.displayMessage" , false);
        component.set("v.displayMessage" , null);
        component.set( "v.selectedUserRecordId", null);
        component.set( "v.selectedContactRecordId", null );
        
    },
    showContactSelection: function(component, event, helper) {
        component.set("v.showContactSelection", true);   
    },
    showUserSelection: function(component, event, helper) {
        component.set("v.showContactSelection", false);   
    },
    createCaseTeamMember: function(component, event, helper) {
        component.set("v.displayMessage" , false);
        helper.validateData(component, event, helper);
    },
    getSelectedRecords: function(component, event, helper) {
        
        var valueRecieved = event.getParam("selectedRecordList");
        component.set("v.selectedRecordList",valueRecieved)
    },
    deleteRecords: function(component, event, helper) {
        helper.deleteRecordsHelper(component, event, helper);
    },
    handleSelect: function (component, event, helper) {
        // This will contain the string of the "value" attribute of the selected
        // lightning:menuItem
        var selectedMenuItemValue = event.getParam("value");
        if(selectedMenuItemValue == "Add Member"){
            component.set("v.isOpen", true);       
            
        }
        else if(selectedMenuItemValue == "Delete"){
            helper.deleteRecordsHelper(component, event, helper);
        }
    }
})