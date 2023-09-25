({  
	init: function(component, event, helper) {
        component.set("v.Spinner", true);
        var dbAction = component.get("c.getTemplatesOptions");
        dbAction.setParams({
            recordId: component.get("v.recordId")
        });
        dbAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.templates", response.getReturnValue());
                component.set("v.Spinner", false);
            }
        });

        $A.enqueueAction(dbAction);
    },

    preiewEmailTemplate: function (component, event, helper) {
		var selectedTemplate = component.get("v.selectedTemplate");
		console.log({selectedTemplate});
		if (selectedTemplate != undefined) {
			component.set("v.isTemplateSelected", true);
			helper.getTemplateBody(component, event, helper);
		}
	},

    closeModel: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},

	sendEmail: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
		helper.sendEmail(component, event, helper);
	}

})