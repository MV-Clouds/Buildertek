({
    doInit : function(component, event, helper) {

    },

    handleCreateVoidPO: function(component, event, helper) {
        component.set("v.createVoidPoFlag", true);
    },

    handleCancel: function(component, event, helper){
        $A.get("e.force:closeQuickAction").fire() 
    },
})
