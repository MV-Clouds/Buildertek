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
                $A.get('e.force:refreshView').fire();
            }

        });
        $A.enqueueAction(dbAction);


        // var cmpTarget = document.querySelector('.fixedFooter');
        // alert(cmpTarget);
        // $A.util.removeClass(cmpTarget, 'fixedFooter');
        // $A.util.addClass(cmpTarget, 'test');

    },

    //isRefreshed: function(component, event, helper) {
    //location.reload();
    //},

    preiewEmailTemplate: function(component, event, helper) {
        // var cmpTarget = component.find('changeIt');
        // $A.util.addClass(cmpTarget, 'changeMe');


        // var cmpTarget = document.querySelector('.fixedFooter');
        // alert(cmpTarget);
        // $A.util.addClass(cmpTarget, 'fixedFooter');
        // $A.util.removeClass(cmpTarget, 'test');


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
        var to = component.get("v.selectedToContact");
        var cc = component.get("v.selectedCcContact");
        var emailIds = component.get("v.emailIds");
        to.forEach(function(v) { toIds.push(v.Id) });
        cc.forEach(function(v) { ccIds.push(v.Id) });
        if (toIds.length != 0 || emailIds.length != 0) {
            var action = component.get("c.sendProposal");
            action.setParams({
                htmlBody: component.get("v.payableLines"),
                recordId: component.get("v.recordId"),
                templateId: component.get("v.selectedTemplate"),
                to: toIds,
                cc: ccIds,
                emailIds: emailIds,
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var subject = 'PunchList[ref:' + component.get("v.recordId") + ']';
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result === 'Success') {
                        component.set("v.Spinner", false);
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type": 'success',
                            "message": "Email Sent Successfully"
                        });
                        toastEvent.fire();
                        /* var taskaction = component.get("c.createTask");
    		              taskaction.setParams({
    		                "whatId" : component.get("v.recordId"),
    		                "emailSubject" : subject
    		            });
    		            $A.enqueueAction(taskaction);*/
                    } else {
                        $A.get("e.force:closeQuickAction").fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": 'error',
                            "message": result
                        });
                        toastEvent.fire();
                    }
                    $A.get('e.force:refreshView').fire();
                }
            });
            $A.enqueueAction(action);
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
    },
    onEmailChange: function(component, event, helper) {
        var emailId = component.find('emailForm').get('v.value');
        var emailIds = component.get('v.emailIds');
        var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
        if (emailId.charAt(emailId.length - 1) == ';') {
            emailId = emailId.replace(';', '');
            if (reg.test(emailId)) {
                component.set("v.toEmail", '');
                if (!emailIds.includes(emailId)) {
                    emailIds.push(emailId);
                }
            }
        }
        if (emailIds != null && emailIds != '') {
            component.set('v.emailIds', emailIds);
        } else {
            component.set('v.emailIds', emailId);
        }

    },
    handleEmailRemove: function(component, event, helper) {
        var removeIndex = event.getSource().get("v.name");
        var emailIds = component.get('v.emailIds');
        emailIds.splice(removeIndex, 1);
        component.set('v.emailIds', emailIds);
    },
})