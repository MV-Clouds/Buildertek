({
    createRecord: function(component, event, helper){
        helper.createRecord(component, event, helper);
    },

    closeModal: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    }, 

    upgradeOption: function (component, event, helper) {
        component.set("v.DisplayUpgraded", true);
		helper.getOptionData(component, event, helper);
	},

	upgradeAllOption: function (component, event, helper) {

        component.set("v.DisplayUpgraded", false);
		helper.getOptionData(component, event, helper);
	},

    selectCheck : function(component, event, helper){
        helper.selectCheck(component, event, helper);
    },

    selectAll: function(component, event, helper){
        helper.selectAll(component, event, helper);
    },
})