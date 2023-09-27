({  
	init: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var dbAction = component.get("c.getTemplatesOptions");
        dbAction.setParams({
            recordId: component.get("v.recordId")
        });
        dbAction.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.templates", response.getReturnValue());
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
            } else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": 'error',
                    "message": 'Something went wrong'
                });
                toastEvent.fire();
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
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