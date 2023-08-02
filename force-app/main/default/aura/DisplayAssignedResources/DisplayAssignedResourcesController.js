({
	doInit : function(component, event, helper) {
        helper.getDataFromFieldSet(component, event, helper);
		helper.getAssignedResources(component, event, helper);
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
})