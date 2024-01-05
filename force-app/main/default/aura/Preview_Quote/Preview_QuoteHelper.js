({
    getTemplateBody: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getQuoteLines");
        action.setParams({
            recordId: recordId,
            templateId: component.get("v.selectedTemplate")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('get template body');
                console.log({ result });
                component.set("v.quoteLines", result);
            }
        });
        $A.enqueueAction(action);
    },

    getContact: function(component, event, helper) {
        var action = component.get("c.getObjectContact");
        action.setParams({
            "recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                //alert('result ---------> '+result);
                var selectedContact = component.get("v.selectedToContact");
                if (result != undefined) {
                    result.forEach(function(elem){
                        console.log(elem.buildertek__Primary_Contact__c);
                        if(elem.buildertek__Primary_Contact__c){
                            selectedContact.push(elem);
                        }
                    })
                }
                component.set("v.selectedToContact", selectedContact);
                console.log(component.get("v.selectedToContact"));
            }
        });
        $A.enqueueAction(action);
    },

    getProposalImagesList: function(component, event, helper) {
        var recordId = component.get("v.recordId");
        var action = component.get("c.getProposalImages");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {

                var result = response.getReturnValue();
                // alert(JSON.stringify(result));
                component.set("v.ProposalImages", result);
                console.log(component.get("v.ProposalImages"));
                //  alert('*****'+component.get("v.ProposalImages"));
            }
        });
        $A.enqueueAction(action);
    },

    getuploadSignature: function(component, event) {
        component.set("v.parentId", component.get("v.recordId"));
        var recId = component.get("v.parentId");

        var signName = component.get("v.SignatureName");
        var signatureaction = component.get("c.saveSign");
        var toastEvent = $A.get('e.force:showToast');
        var vSplit = document.getElementById("divsign").toDataURL().split(',')[1];

        signatureaction.setParams({
            base64Data: encodeURIComponent(vSplit),
            contentType: "image/png",
            recId: recId,
            signName: signName,
        });
        signatureaction.setCallback(this, function(e) {
            if (e.getState() == 'SUCCESS') {
                var result = e.getReturnValue();
                component.set("v.Spinner", false);
                component.set("v.fileimageId", result);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": 'success',
                    "message": "Signature Saved Successfully"
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire();
                // location.reload();

            } else {
                alert(JSON.stringify(e.getError()));
            }
        });
        $A.enqueueAction(signatureaction);

    },

    acceptandsendemailhelper: function(component, event) {
        //alert('hi2');
        var toIds = [];
        var ccIds = [];
        var to = component.get("v.selectedToContact");
        var cc = component.get("v.selectedCcContact");
        var emailIds = component.get("v.emailIds");

        to.forEach(function(v) {
            toIds.push(v.Id)
        });
        cc.forEach(function(v) {
            ccIds.push(v.Id)
        });

        var signid = component.get("v.fileimageId");
        // alert('imageId'+component.get("v.fileimageId"));
        var action = component.get("c.acceptandsendProposal");
        action.setParams({
            htmlBody: component.get("v.quoteLines"),
            recordId: component.get("v.recordId"),
            templateId: component.get("v.selectedTemplate"),
            to: toIds,
            cc: ccIds,
            fileid: signid,
            emailIds: emailIds,
            memovalue: component.get("v.memoquote"),
            emailBodyValue: component.get("v.templateEmailBody")

        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            // var subject = 'Quote[ref:' + component.get("v.recordId") + ']';
            if (state === "SUCCESS") {
                component.set("v.Spinner", false);
                var result = response.getReturnValue();
                if (result === 'Success') {
                    $A.get('e.force:refreshView').fire();
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "type": 'success',
                        "message": "Email Sent Successfully"
                    });
                    toastEvent.fire();
                    // location.reload();
                } else {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": 'error',
                        "message": result
                    });
                    toastEvent.fire();
                }
                $A.get("e.force:closeQuickAction").fire();
            }
        });

        $A.enqueueAction(action);

    },

    AcceptSignature: function(component, event) {
        component.set("v.Spinner", true);
        component.set("v.parentId", component.get("v.recordId"));
        var recId = component.get("v.parentId");

        var signName = component.get("v.SignatureName");
        var signatureaction = component.get("c.saveSign");
        var toastEvent = $A.get('e.force:showToast');
        var vSplit = document.getElementById("divsign").toDataURL().split(',')[1];

        signatureaction.setParams({
            base64Data: encodeURIComponent(vSplit),
            contentType: "image/png",
            recId: recId,
            signName: signName
        });
        signatureaction.setCallback(this, function(e) {
            if (e.getState() == 'SUCCESS') {
                var result = e.getReturnValue();

                component.set("v.fileimageId", result);
                setTimeout(
                    function() {
                        component.acceptandSendMethod();
                    }, 2000);


                /* var toastEvent = $A.get("e.force:showToast");
                   toastEvent.setParams({
                       "title": "Success!",
                       "type": 'success',
                       "message": "Signature Saved Successfully"
                   });
                   toastEvent.fire();*/


            } else {
                alert(JSON.stringify(e.getError()));
            }
        });
        $A.enqueueAction(signatureaction);

    },
    getmemovalue: function(component, event, helper) {
        try {
            var action = component.get("c.getmemoval");
            action.setParams({
                recordId: component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                var result = response.getReturnValue();
                console.log('result-->',result);
                if (state === "SUCCESS") {
                    var result = JSON.parse(response.getReturnValue());
                    if (result.memo != null) {
                        component.set("v.memoquote", result.memo);
                    }
                    if (result.companyname != null) {
                        component.set("v.companyName", result.companyname);
                    }
                    if (result.siteUrl != null) {
                        component.set("v.siteURL", result.siteUrl);
                    }
                    if (result.salesRepName != null) {
                        component.set("v.salesRep", result.salesRepName);
                    }
                    if (result.orgName != null) {
                        component.set("v.orgName", result.orgName);
                    }                   
                    if (result.emailBody != null) {
                        component.set("v.templateEmailBody", result.emailBody);
                    }
                    
                } else{
                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": 'error',
                            "message": result
                        });
                        toastEvent.fire();
                }
            });

            $A.enqueueAction(action);
        } catch (error) {
            console.log('error-->',error);
        }
        
    },

})