({
    doInit : function(component, event, helper) {
        helper.getVendorsAndScheduleItems(component);
    },

    processOperation : function(component, event, helper) {
        helper.syncVendorsHelper(component);
    },

    closeModelCon: function (component, event, helper) {
        helper.closeModel(component);
    }
})