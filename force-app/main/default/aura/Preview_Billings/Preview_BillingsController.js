({
    init: function(component, event, helper) {
        component.set("v.Spinner", true);
        var dbAction = component.get("c.getTemplates");
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

    preiewEmailTemplate: function(component, event, helper) {
        var selectedTemplate = component.get("v.selectedTemplate");
        if (selectedTemplate != undefined) {
            component.set("v.isTemplateSelected", true);

            helper.getTemplateBody(component, event, helper);
        }
    },

    closeModel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    sendEmail: function(component, event, helper) {
        component.set("v.Spinner", true);
        var toIds = [];
        var ccIds = [];
        var noToIds = [];
        var war = '';
        var to = component.get("v.selectedToContact");
        var cc = component.get("v.selectedCcContact");
        console.log(to);
        to.forEach(function(v) {
            if (v.Email != null && v.Email != undefined) {
                toIds.push(v.Id)
            } else {
                noToIds.push(v.Name);
                war += v.Name
            }

        });
        cc.forEach(function(v) {
            ccIds.push(v.Id)
        });

        if (toIds.length != 0) {
            if (noToIds != undefined && to.length != undefined) {
                if (toIds.length != to.length) {
                    /*  var toastEvent = $A.get("e.force:showToast");
                      toastEvent.setParams({
                          title : 'Warning',
                          message: war+' does not have email address.',
                          duration:' 5000',
                          key: 'info_alt',
                          type: 'warning',
                          mode: 'sticky'
                      });
                      toastEvent.fire(); */
                }
            }

            var updateAction = component.get("c.updateMemo");
            updateAction.setParams({
                recordId: component.get("v.recordId"),
                memoValue: component.get("v.invoiceMemo"),
            });
            updateAction.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var action = component.get("c.sendProposal");
                    action.setParams({
                        htmlBody: component.get("v.invoiceLines"),
                        recordId: component.get("v.recordId"),
                        templateId: component.get("v.selectedTemplate"),
                        to: toIds,
                        cc: ccIds
                    });
                    action.setCallback(this, function(response1) {
                        var state = response1.getState();
                        var subject = 'Invoice[ref:' + component.get("v.recordId") + ']';
                        if (state === "SUCCESS") {
                            var result1 = response1.getReturnValue();
                            if (result1 === 'Success') {
                                component.set("v.Spinner", false);
                                $A.get("e.force:closeQuickAction").fire();
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "title": "Success!",
                                    "type": 'success',
                                    "message": "Email Sent Successfully"
                                });
                                toastEvent.fire();
                            } else {
                                $A.get("e.force:closeQuickAction").fire();
                                var toastEvent = $A.get("e.force:showToast");
                                toastEvent.setParams({
                                    "type": 'error',
                                    "message": result1
                                });
                                toastEvent.fire();
                            }
                            $A.get('e.force:refreshView').fire();
                        }
                    });
                    $A.enqueueAction(action);
                }
            });
            $A.enqueueAction(updateAction);
        } else {
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": "Please select To Address to send Email"
            });
            toastEvent.fire();
        }
    }
})