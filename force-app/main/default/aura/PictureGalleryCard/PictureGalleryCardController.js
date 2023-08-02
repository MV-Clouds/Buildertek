({
    doInit : function(component, event, helper) {
        helper.getImages(component);
    },

	fullScreen : function(component) {
        component.set("v.fullScreen", true);
	},

	closeDialog : function(component) {
        component.set("v.fullScreen", false);
	}

})