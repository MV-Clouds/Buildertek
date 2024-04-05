({
    doInit: function (component, event, helper) {
        helper.getPOsAndScheduleItems(component, event, helper);
    },

    processOperation: function (component, event, helper) {
        helper.syncPOHelper(component, event, helper);
    },

    closeModelCon: function (component, event, helper) {
        helper.closeModel(component);
    },

})