({
    sendEmailHelper: function(component, toAddress, ccAddress, subject, body) {
        console.log('sendEmailHelper');
        var action = component.get("c.sendEmail");
        action.setParams({
            toAddress: toAddress,
            ccAddress: ccAddress,
            subject: subject,
            body: body
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('Email sent successfully');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Success!",
                    message: "Email sent successfully",
                    type: "success"
                });
                toastEvent.fire();
            } else {
                console.log('Error in sending email');
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "Error!",
                    message: "Error in sending email",
                    type: "error"
                });
                toastEvent.fire();
            }
        });
    }
})
