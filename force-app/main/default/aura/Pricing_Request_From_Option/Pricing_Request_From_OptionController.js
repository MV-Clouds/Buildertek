({
    doInit : function(component, event, helper) {
        component.set("v.Spinner", true);
        setTimeout(function () {
            component.set("v.Spinner", false);
        }, 1000);
    }, 

    createRecord : function(component, event, helper) {
        helper.createRecord(component, event, helper);
    }, 

    closeModal : function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }, 
})