({
    doInit : function(component, event, helper) {
        helper.doInit(component, event, helper);
    }, 

    updateColumnSorting: function (component, event, helper) {
        var fieldName = event.getParam('fieldName');
        var sortDirection = event.getParam('sortDirection');
        component.set("v.sortedBy", fieldName);
        component.set("v.sortedDirection", sortDirection);
        helper.sortData(component, fieldName, sortDirection);
    },

    updateSelected: function (component, event, helper) {
        var selectedRows = event.getParam('selectedRows');
        console.log('selectedRows => ', {selectedRows});
        component.set("v.selectedRowList", selectedRows);
    },

    createRecord : function(component, event, helper) {
        helper.createRecord(component, event, helper);
    }, 

    closeModal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }, 
    
})