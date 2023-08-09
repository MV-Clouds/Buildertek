({
    preiewEmailTemplate: function (component, event, helper) {
		var selectedTemplate = component.get("v.selectedTemplate");
		console.log({selectedTemplate});
		if (selectedTemplate != undefined) {
			component.set("v.isTemplateSelected", true);
			if (selectedTemplate == 'Invoice') {
				helper.getTemplateBody(component, event, helper);
			} else if(selectedTemplate == 'Documentation'){

			}
		}
	},

    closeModel: function (component, event, helper) {
		$A.get("e.force:closeQuickAction").fire();
	},

	sendEmail: function (component, event, helper) {
		helper.sendEmail(component, event, helper);
	}

})