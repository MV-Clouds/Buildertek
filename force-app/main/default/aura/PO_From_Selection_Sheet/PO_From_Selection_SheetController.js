({
    doInit: function(component, event, helper) {
        helper.doInitHelper(component, event, helper);
    },

    createPOrecord: function(component, event, helper) {
        helper.createPOhelper(component, event, helper);
    },

    selectCheck : function(component, event, helper){
        helper.selectAll(component, event, helper);
    },

    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    demo: function(component, event, helper){
        var checkCmp = component.find("checkContractor").get("v.value");
        console.log('checkbox value ',checkCmp);
    }

})