({
    doInit : function(component, event, helper) {
        console.log('doInit');
        helper.getVendorsAndScheduleItems(component);
    },

    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }
})
