({
    doInit: function(component, event, helper) {
        console.log('RECORD ID IS' + component.get("v.recordId"));
        var email = component.get("v.toEmail");
        var cc = component.get("v.CC");
        var subject = component.get("v.Subject");
        var action = component.get("c.getHTML");
        action.setParams({
            "EmaiValue": "test@gmail.com",
            "ccValue": cc,
            "SubjectValue": subject,
            "recId": component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            //alert(response.getState());
            if (response.getState() === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.TextField", result.Innhtmlbody);
                component.set("v.Subject", result.Innsubject)

            }
        });
        $A.enqueueAction(action);
        var childComponent = component.find("childCmp");
        var callSearchHelper = childComponent.callSearchHelperMethod();
    },
    sendEmail: function(component, event, helper) {
        console.log(JSON.stringify(component.get("v.selectedToContact")));
        console.log(component.get("v.selectedToContact"));
        // alert(JSON.stringify(component.get("v.selectedToContact")));
        var email = component.get("v.toEmail");
        var cc = component.get("v.CC");
        var subject = component.get("v.Subject");
        var action = component.get("c.sendMail");
        action.setParams({
            "atendeeList": component.get("v.selectedToContact"),
            "ccContactList": component.get("v.selectedCcContact"),
            "EmaiValue": email,
            "ccValue": cc,
            "SubjectValue": subject,
            "bodyvalue": component.get("v.TextField")
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                // alert(response.getState());
                var result = response.getReturnValue();
                // alert(result);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": "success",
                    "message": "Email sent successfully."
                });
                toastEvent.fire();
                $A.get("e.force:closeQuickAction").fire()
            }
        });
        $A.enqueueAction(action);
    },
    cancel: function(component, event, helper) {
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
    },
})