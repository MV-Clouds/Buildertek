/* Lightning Component Controller.
 * Copyright 2018-2019, Riskonnect Inc.
 * All rights reserved
 *
 * Created by - Ravi Jangid
 *
 * - Modifications:
 */

/* Lightning CLI rule */
/*global $ sforce*/
/* eslint-disable no-console, no-alert, no-extra-boolean-cast */
({
	/*component init method, In this method get the fields from field set*/
	init: function (component, event, helper) {
		var section = component.get("v.section");

		// this flag is for citation is new or edit. 
		if (!!section && !!section.Id) {
			component.set("v.isNewCitation", false);
		}

		// Get the fieldset list from Controller.
		helper.getFieldSet(component);


		// Here prepare the section record fields like Authority_document__c and recordTypeId.
		var adId = component.get("v.adId");
		console.log('adID::', adId);
		if (!!adId) {
			var getSectionObject = component.get("c.getSectionFields");
			getSectionObject.setParams({
				adId: adId
			});
			getSectionObject.setCallback(this, function (response) {
				if (response.getState() === "SUCCESS") {
					component.set("v.sectionObjectFields", response.getReturnValue());
				} else if (response.getState() === "ERROR") {
					var errors = response.getError();
					if (errors && errors[0] && errors[0].message) {
						console.log('Error ', errors[0].message);
					} else {
						console.log("Unknown error");
					}
				}
			});
			$A.enqueueAction(getSectionObject);
		}
        debugger;
        //component.find("field").focus();
		$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "HIDE"
		}).fire();
	},

	/* Save section record*/
	save: function (component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "SHOW"
		}).fire();
		component.set('v.isSaveAndNew', false);
		// Submit the citation record Edit from 
		document.getElementById('saveSectionbutton').click();
	},
	/* Save and New*/
	saveAndNew: function (component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "SHOW"
		}).fire();
		component.set('v.isSaveAndNew', true);
		// Submit the citation record Edit from 
		document.getElementById('saveAndNewSectionbutton').click();
	},

	/* When Click on record edit submit button then this submit event fire.\
		Here save the section record.*/
	submitSectionRecord: function (component, event, helper) {
		debugger;
		console.log('test save');
		var isNewCitation = component.get("v.isNewCitation");
		debugger;
		if (isNewCitation) {
			helper.addAdditionalField(component, event);
		} else {
			var eventFields = event.getParam("fields");
			var section = component.get("v.section");
			section.Name = eventFields["buildertek__Title__c"];
			section.buildertek__Title__c = eventFields['buildertek__Title__c'];
			eventFields['buildertek__Selection__c'] = section.buildertek__Selection__c;
			component.set("v.section", section);
		}
	},

	/* when record edit from submit successfully then this event will fire
		Here prepare the success message.*/
	onSuccess: function (component, event, helper) {
		var section = component.get("v.section");

		var params = event.getParams();
		console.log("onSuccess", params.response.id);

		var isNewCitation = component.get("v.isNewCitation");
		var message = 'Selection Category "' + section.buildertek__Title__c + '" was created.';

		if (!isNewCitation) {
			message = 'Selection Category "' + section.buildertek__Title__c + '" was saved.';
		}

		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			message: message,
			type: 'Success',
		});

		toastEvent.fire();

		var onSuccess = component.get("v.onSuccess");
		if (!!onSuccess) {
			section.Id = params.response.id;
			onSuccess(section);
		}
		if (!component.get('v.isSaveAndNew')) {
			helper.closePopup(component);
		} else {
			component.find('field').forEach(function (f) {
				f.reset();
			});
            setTimeout(function(){ 
                component.find('field')[0].focus();
                component.set("v.isNewCitation", true)
            }, 500);
		}
		$A.get("e.c:BT_SpinnerEvent").setParams({
			"action": "HIDE"
		}).fire();

	},

	/* Close the overlay library modal*/
	close: function (component, event, helper) {
		helper.closePopup(component);
	},

	/* Here prepare delete confirmation modal*/
	deleteSectionModal: function (component, event, helper) {
		var section = component.get("v.section");
		$A.createComponents([
			["aura:html", {
				"tag": "h2",
				"body": "Delete Confirmation",
				"HTMLAttributes": {
					"class": "slds-text-heading_medium slds-hyphenate"
				}
			}],
			["lightning:button", {
				"aura:id": "no_button",
				"label": "No",
				"name": "no",
				"onclick": component.getReference("c.deleteRecords")
			}],
			["lightning:button", {
				"aura:id": "Yes_button",
				"label": "Yes",
				"name": "yes",
				"variant": "brand",
				"onclick": component.getReference("c.deleteRecords")
			}]
		], function (components, status) {
			var buttons = [];
			buttons.push(components[1]);
			buttons.push(components[2]);
			if (status === "SUCCESS") {
				var modalPromise = component.find('overlayLib').showCustomModal({
					header: components[0],
					body: "Are you sure you want to delete this category?",
					footer: buttons,
					showCloseButton: true
				});
				component.set("v.modalPromise", modalPromise);
			}
		});
	},


	deleteRecords: function (component, event, helper) {
		var name = event.getSource().get("v.name");
		if (name === "yes") {
			helper.deleteRecords(component, event, helper);
		} else {
			$A.get("e.c:BT_SpinnerEvent").setParams({
				"action": "HIDE"
			}).fire();
			helper.closeModalPop(component);
		}
	}

})