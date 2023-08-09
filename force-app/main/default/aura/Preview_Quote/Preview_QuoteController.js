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
        helper.getmemovalue(component, event, helper);
    },
    scrolldown: function(component, event, helper) {

        document.getElementById('footer').scrollIntoView();

    },
    scrollup: function(component, event, helper) {

        document.getElementById('header').scrollIntoView(true);

    },
    preiewEmailTemplate: function(component, event, helper) {
        console.log('Preview email template');

        var selectedTemplate = component.get("v.selectedTemplate");
        console.log(selectedTemplate);
        if (selectedTemplate != undefined) {
            component.set("v.isTemplateSelected", true);
            helper.getContact(component, event, helper);
            helper.getTemplateBody(component, event, helper);
            helper.getProposalImagesList(component, event, helper);
            setTimeout(function() {
                var wrapper = document.getElementById("signature-pad");
                if (wrapper != undefined) {
                    var canvas = wrapper.querySelector("canvas");
                    var signaturePad;

                    // Adjust canvas coordinate space taking into account pixel ratio,
                    // to make it look crisp on mobile devices.
                    // This also causes canvas to be cleared.
                    function resizeCanvas() {
                        // When zoomed out to less than 100%, for some very strange reason,
                        // some browsers report devicePixelRatio as less than 1
                        // and only part of the canvas is cleared then.
                        var ratio = Math.max(window.devicePixelRatio || 1, 1);
                        canvas.width = canvas.offsetWidth * ratio;
                        canvas.height = canvas.offsetHeight * ratio;
                        canvas.getContext("2d").scale(ratio, ratio);
                    }

                    window.onresize = resizeCanvas;
                    resizeCanvas();

                    window.signaturePad = new SignaturePad(canvas);

                    document.getElementById("btnClear").onclick = function(event) {
                        event.preventDefault();
                        console.log(window.signaturePad);
                        window.signaturePad.clear();
                    }
                }
            }, 3000);
        }
    },

    closeModel: function(component, event, helper) {
        // location.reload(); 
        $A.get("e.force:closeQuickAction").fire();

    },

    sendEmail: function(component, event, helper) {
        var addEmailBox = component.find('emailForm').get('v.value');
        var emailIds = component.get("v.emailIds");
        if (addEmailBox != undefined && addEmailBox != '') {
            var emailReg = /^([\w-\.]+@([\w-]+\.)+[\w-]{2,4})?$/;
            if (!emailReg.test(addEmailBox)) {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: 'Please enter valid email address in Additional Email',
                    duration: ' 3000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
                return;
            }
            if (emailIds.indexOf(addEmailBox) == -1) {
                emailIds.push(addEmailBox);
                component.set("v.emailIds", emailIds);
                component.set("v.toEmail", '');
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: 'Error',
                    message: 'Additional Email already added',
                    duration: ' 3000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'pester'
                });
                toastEvent.fire();
            }
        }
        component.set("v.Spinner", true);
        var toIds = [];
        var ccIds = [];
        var to = component.get("v.selectedToContact");
        if (to == null) {
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title: 'Error',
                message: 'Please select To Address to send Email',
                duration: ' 3000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();
            return;
        }
        var cc = component.get("v.selectedCcContact");
        var emailIds = component.get("v.emailIds");
        to.forEach(function(v) {
            toIds.push(v.Id)
        });
        cc.forEach(function(v) {
            ccIds.push(v.Id)
        });
        console.log('toIds', toIds);
        console.log('ccIds', ccIds);
        debugger;
        if (toIds.length != 0 || emailIds.length != 0) {
            var action = component.get("c.sendProposal");
            action.setParams({
                htmlBody: component.get("v.quoteLines"),
                recordId: component.get("v.recordId"),
                templateId: component.get("v.selectedTemplate"),
                to: toIds,
                cc: ccIds,
                emailIds: emailIds,
                memovalue: component.get("v.memoquote"),
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var subject = 'Quote[ref:' + component.get("v.recordId") + ']';
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if (result === 'Success') {
                        debugger;
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

    acceptandSendMethodCall: function(component, event, helper) {
        helper.acceptandsendemailhelper(component, event);
    },

    onEmailChange: function(component, event, helper) {
        var emailId = component.find('emailForm').get('v.value');
        var emailIds = component.get('v.emailIds');
        var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
        if (emailId.charAt(emailId.length - 1) == ';' || emailId.charAt(emailId.length - 1) == ',' || emailId.charAt(emailId.length - 1) == ' ') {
            emailId = emailId.replace(';', '');
            emailId = emailId.replace(',', '');
            emailId = emailId.replace(' ', '');
            console.log('hurray', emailId);
            if (reg.test(emailId)) {
                component.set("v.toEmail", '');
                if (!emailIds.includes(emailId)) {
                    emailIds.push(emailId);
                }
            }
            console.log('emailIds', emailIds);
            component.set('v.emailIds', emailIds);
        }

    },

    onAddEmail: function(component, event, helper) {
        var emailId = component.find('emailForm').get('v.value');
        console.log('emailId', emailId)
        var emailIds = component.get('v.emailIds');
        var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
        if (reg.test(emailId)) {
            component.set("v.toEmail", '');
            if (!emailIds.includes(emailId)) {
                emailIds.push(emailId);
            }
        }
        component.set('v.emailIds', emailIds);
    },

    handleEmailRemove: function(component, event, helper) {
        var removeIndex = event.getSource().get("v.name");
        var emailIds = component.get('v.emailIds');
        emailIds.splice(removeIndex, 1);
        component.set('v.emailIds', emailIds);
    },

    AcceptandsendEmail: function(component, event, helper) {
        component.set("v.Spinner", true);
        var toIds = [];
        var ccIds = [];
        var to = component.get("v.selectedToContact");
        var cc = component.get("v.selectedCcContact");
        var emailIds = component.get('v.emailIds');

        to.forEach(function(v) {
            toIds.push(v.Id)
        });
        cc.forEach(function(v) {
            ccIds.push(v.Id)
        });
        if (toIds.length != 0 || emailIds.length != 0) {
            if (!signaturePad.isEmpty()) {
                helper.AcceptSignature(component, event);
            } else {
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": 'error',
                    "message": "Please Sign and Accept"
                });
                toastEvent.fire();
            }
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

    Acceptandclose: function(component, event, helper) {
        if (!signaturePad.isEmpty()) {
            component.set("v.Spinner", true);
            helper.getuploadSignature(component, event);

        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": "Please Sign and Accept"
            });
            toastEvent.fire();
        }
        /*$A.get("e.force:closeQuickAction").fire();  
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Success!",
            "type": 'success',
            "message": "Signature Saved Successfully"
        });
        toastEvent.fire();
        $A.get("e.force:closeQuickAction").fire();*/

    }
})