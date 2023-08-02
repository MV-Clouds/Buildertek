({
    init: function (component, event, helper) {
        component.set("v.Spinner", true);
        var dbAction = component.get("c.getTemplates");
        dbAction.setParams({
            recordId: component.get("v.recordId")
        });
        dbAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log(response.getReturnValue());
                component.set("v.templates", response.getReturnValue());
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(dbAction);
    },

    preiewEmailTemplate: function (component, event, helper) {
        var selectedTemplate = component.get("v.selectedTemplate");
        if (selectedTemplate != undefined) {
            component.set("v.isTemplateSelected", true);

            helper.getTemplateBody(component, event, helper);

            setTimeout(function () {
                var wrapper = document.getElementById("signature-pad");
                if (wrapper) {
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

                    document.getElementById("btnClear").onclick = function (event) {
                        event.preventDefault();
                        console.log(window.signaturePad);
                        window.signaturePad.clear();
                    }
                }
            }, 3000);
        }
    },

    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    sendEmail: function (component, event, helper) {
        try {

            component.set("v.Spinner", true);
            // adding new variable here for attach files 
            // var uploadedFiles = event.getParam("files");
            var Files = component.get("v.attachedFile");
            
            console.log('send this these attached files to email');
            console.log(typeof(Files[1]));
            console.log(Files[1]);

            var toIds = [];
            var ccIds = [];
            var to = component.get("v.selectedToContact");
            var cc = component.get("v.selectedCcContact");
            to.forEach(function (v) { toIds.push(v.Id) });
            cc.forEach(function (v) { ccIds.push(v.Id) });
            if (toIds.length != 0) {
                // console.log("convertedFiles ==> ",{convertedFiles});
                var action = component.get("c.sendProposal");
                action.setParams({
                    htmlBody: component.get("v.purchaseOrderLines"),
                    recordId: component.get("v.recordId"),
                    templateId: component.get("v.selectedTemplate"),
                    to: toIds,
                    cc: ccIds,
                    fileid: component.get("v.fileimageId"),
                    attacheDocs: Files,
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    var subject = 'PurchaseOrder[ref:' + component.get("v.recordId") + ']';
                    var result = response.getReturnValue();
                    console.log('Result =>', {result});
                    if (state === "SUCCESS") {
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
                                "message": 'Something Went Wrong'
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

        } catch (error) {
            console.log('error in JS controller ::');
            console.log(error);
        }
    },


    acceptandSendMethodCall: function (component, event, helper) {
        helper.acceptandsendemailhelper(component, event);
    },

    AcceptandsendEmail: function (component, event, helper) {
        component.set("v.Spinner", true);
        var toIds = [];
        var ccIds = [];
        var to = component.get("v.selectedToContact");
        var cc = component.get("v.selectedCcContact");
        to.forEach(function (v) { toIds.push(v.Id) });
        cc.forEach(function (v) { ccIds.push(v.Id) });
        if (toIds.length != 0) {
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

    rejectSendEmail: function (component, event, helper) {
        var toIds = [];
        var ccIds = [];
        var to = component.get("v.selectedToContact");
        var cc = component.get("v.selectedCcContact");
        to.forEach(function (v) { toIds.push(v.Id) });
        cc.forEach(function (v) { ccIds.push(v.Id) });
        if (toIds.length != 0) {
            if (!signaturePad.isEmpty()) {
                component.set('v.isRejected', true);
                component.set('v.isEmailSend', true);
            } else {
                component.set('v.isRejected', false);
                component.set('v.isEmailSend', false);
                component.set("v.Spinner", false);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "type": 'error',
                    "message": "Please Sign"
                });
                toastEvent.fire();
            }
        } else {
            component.set('v.isRejected', false);
            component.set("v.Spinner", false);
            component.set('v.isEmailSend', false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": "Please select To Address to send Email"
            });
            toastEvent.fire();
        }
    },

    closeModelReason: function (component, event, helper) {
        component.set('v.isRejected', false);
    },

    rejectSendEmailWithReason: function (component, event, helper) {
        component.set("v.Spinner", true);
        var rejectionReason = component.get('v.rejectReason');
        if (rejectionReason) {
            helper.rejectSignature(component, event);
        } else {
            component.set("v.Spinner", false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": "Please enter reason"
            });
            toastEvent.fire();
        }
    },

    Acceptandclose: function (component, event, helper) {
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
    },

    rejectAndClose: function (component, event, helper) {
        if (signaturePad != undefined && signaturePad) {
            component.set('v.isClose', true);
            component.set("v.isRejected", true);
        } else {
            component.set('v.isClose', false);
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": "Please Sign and Reject"
            });
            toastEvent.fire();
        }
    },

    rejectAndSave: function (component, event, helper) {
        var rejectionReason = component.get('v.rejectReason');
        if (rejectionReason) {
            component.set("v.Spinner", true);
            component.set('v.isClose', true);
            helper.getRejectAndClose(component, event);
        } else {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": "Please enter reason"
            });
            toastEvent.fire();
        }
    },

    handleUploadFinished: function (component, event, helper) {
        var uploadedFiles = event.getParam("files");
        
        console.log('please check type of uploaded files here');
        
        console.log(uploadedFiles);

        var fileDocsId = [];
        var fileName = [];
        uploadedFiles.forEach(element => {
            console.log(element.name);

            var maxCharacters = 25; // Define the maximum number of characters to display
            if (element.name.length > maxCharacters) {
                fileName.push(element.name.slice(0, maxCharacters) + "...");
            }else{
                fileName.push(element.name);
            }
            fileDocsId.push(element.documentId);

        });
        
        component.set("v.uploadedFileName",fileName);
        var temp = component.get("v.uploadedFileName");
        console.log('check this one ==> '+temp);
        component.set("v.attachedFile",fileDocsId);
        
       //helper.handleUploadFinishedHelper(component, event, helper);
    },

})