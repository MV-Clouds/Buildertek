({
    doInit : function(component, event, helper) {
        console.log('doInit');
        var url = window.location.href;
        component.set("v.siteURL", url);
        component.set("v.orgName", 'Jaimin Shah');
        component.set("v.companyName", 'MV Clouds');
    },

    closeModel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    sendEmail: function(component, event, helper) {
        var toContactList = component.get("v.selectedToContact");
        console.log('toContactList: ' + toContactList);
        //iterate over the list of emailIds and add email to the list
        var toAddress = '';
        for(var i=0; i<toContactList.length; i++){
            if(toContactList[i].Email != null && toContactList[i].Email != ''){
                toAddress += toContactList[i].Email + ';';
            }
        }
        var emailIds = component.get('v.emailIds');
        console.log('emailIds: ' + emailIds);

        if(emailIds != null && emailIds != ''){
            for(var i=0; i<emailIds.length; i++){
                toAddress += emailIds[i] + ';';
            }
        }
        console.log('toAddress: ' + toAddress);

        var ccContactList = component.get("v.selectedCcContact");
        console.log('ccContactList: ' + ccContactList);
        //iterate over the list of emailIds and add email to the list
        var ccAddress = '';
        for(var i=0; i<ccContactList.length; i++){
            if(ccContactList[i].Email != null && ccContactList[i].Email != ''){
                ccAddress += ccContactList[i].Email + ';';
            }
        }
        console.log('ccAddress: ' + ccAddress);

        var subject = component.get('v.subject');
        var recordId = component.get('v.recordId');
        subject += ' (Ref No: ' + recordId + ')';
        console.log('subject: ' + subject);

        var body = component.get('v.templateBody');
        body += '<p>Here is the link to Contractor Invoice <a href="' + component.get('v.siteURL') + '" target="_blank">Link</a></p>';
        //add margin : 0 to all the below tags
        body += '<p style="margin: 0;">Thanks & Regards,</p>';
        body += '<p style="margin: 0;">' + component.get('v.orgName') + '</p>';
        body += '<p style="margin: 0;">' + component.get('v.companyName') + '</p>';

        console.log('body: ' + body);

        // helper.sendEmailHelper(component, toAddress, ccAddress, subject, body);
        var action = component.get("c.sendEmailtoContact");
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
                $A.get("e.force:closeQuickAction").fire();
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
        $A.enqueueAction(action);
    },

    onEmailChange: function (component, event, helper) {
        var emailId = component.find('emailForm').get('v.value');
        var emailIds = component.get('v.emailIds');
        var reg = /^([A-Za-z0-9_\-\.])+\@([A-Za-z0-9_\-\.])+\.([A-Za-z]{2,4})$/;
        
        if (emailId.charAt(emailId.length - 1) == ';') {
            emailId = emailId.replace(';', '');
            if (reg.test(emailId)) {
                component.set("v.toEmail", '');
                if (!emailIds.includes(emailId) && emailId.length > 1) {
                    emailIds.push(emailId);
                }
            }
        }

        if(emailIds != null && emailIds != ''){
          component.set('v.emailIds', emailIds);  
        }else{
            component.set('v.emailIds', emailId);
        }

        for(var i=0; i<emailIds.length; i++){
            if(emailIds[i].length == 1){
                emailIds.splice(i, 1);
            }
        }
        component.set('v.emailIds', emailIds);
        
    },

    handleEmailRemove: function (component, event, helper) {
        var removeIndex = event.getSource().get("v.name");
        var emailIds = component.get('v.emailIds');
        emailIds.splice(removeIndex, 1);
        component.set('v.emailIds', emailIds);
    },


})
