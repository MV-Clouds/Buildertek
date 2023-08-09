({
    getEmailMessages: function (component, event, currentRec) {
        debugger;
        console.log('###helper record id##' + currentRec);
        var action = component.get("c.getEmailMessages");
        action.setParams({
            "RecId": currentRec
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var list = response.getReturnValue();
                for (var i in list) {
                    if (list[i].emMessageList != undefined) {
                        for (var j in list[i].emMessageList) {
                            if (list[i].emMessageList[j].IsTracked != undefined && list[i].emMessageList[j].IsTracked &&
                                list[i].emMessageList[j].IsOpened != undefined && list[i].emMessageList[j].IsOpened) {
                                var lastOpenDate = new Date(list[i].emMessageList[j].LastOpenedDate);
                                var currentDate = new Date();
                                var diff = (currentDate.getTime() - lastOpenDate.getTime()) / 1000;
                                diff /= 60;
                                console.log('Difference::', Math.abs(Math.round(diff)));
                                //lastOpenDate = lastOpenDate.replace('T',' ');
                                //lastOpenDate = lastOpenDate.replace('Z',' ');
                                if (list[i].emMessageList[j].lastOpenTime == undefined) {
                                    list[i].emMessageList[j].lastOpenTime = '';
                                }
                                if (Math.abs(Math.round(diff)) > 0 && Math.abs(Math.round(diff)) < 2) {
                                    list[i].emMessageList[j].lastOpenTime = 'Last Opened few seconds ago';
                                } else if (Math.abs(Math.round(diff)) >= 2 && Math.abs(Math.round(diff)) < 60) {
                                    list[i].emMessageList[j].lastOpenTime = 'Last Opened ' + Math.abs(Math.round(diff)) + ' minutes ago.';
                                } else if (Math.abs(Math.round(diff)) >= 60 && Math.abs(Math.round(diff)) < 1440) {
                                    list[i].emMessageList[j].lastOpenTime = 'Last Opened ' + Math.abs(Math.round(Math.abs(Math.round(diff)) / 60)) + ' hour ago.';
                                } else if (Math.abs(Math.round(diff)) >= 1440) {
                                    list[i].emMessageList[j].lastOpenTime = 'Last Opened at ' + lastOpenDate + ' ago.';
                                }
                            }
                        }
                    }
                }

                component.set("v.EmailMsgs", list);
                component.set("v.AllEmailMsgs", list);
                component.set("v.Spinner", false);

            } else if (state === "INCOMPLETE") {
                console.log("No response from server or client is offline.")
                var myErrMsg = 'No response from server or client is offline.';

            } else if (state === "ERROR") {
                console.log("Error: ");
            }
        });
        $A.enqueueAction(action);
    },

    getRFIName: function (component, event, currentRec) {
        var action = component.get("c.getCurrentRFI");
        action.setParams({
            "RecId": currentRec
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.rfiNumber", response.getReturnValue());
                component.set("v.Spinner", false);
            } else if (state === "INCOMPLETE") {
                console.log("No response from server or client is offline.")
                var myErrMsg = 'No response from server or client is offline.';
            } else if (state === "ERROR") {
                console.log("Error: ");
            }
        });
        $A.enqueueAction(action);
    },

    replyEmail: function (component, event, repid, emidrply) {
        console.log('camein');
        var action = component.get("c.getemailAddress");
        action.setParams({
            "EMsgId": repid
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            var email = '';
            var subject = '';
            var htmlbody = '';
            if (state === "SUCCESS") {
                var emailMsg = response.getReturnValue();
                console.log('emailMsg[0]' + emailMsg[0]);
                console.log('@@@@emailAddress' + emailMsg);
                console.log('emailMsg.buildertek__Is_Incoming_Email__c  ' + emailMsg.buildertek__Is_Incoming_Email__c);
                console.log('emailMsg.FromAddress  ' + emailMsg.FromAddress);
                console.log('emailMsg.Subject  ' + emailMsg.Subject);
                console.log('emailMsg.HtmlBody  ' + emailMsg.HtmlBody);
                console.log('emailMsg.TextBody  ' + emailMsg.TextBody);
                var cleanText = '';
                var str = emailMsg.HtmlBody;
                var ccEmail = emailMsg.CcAddress;
                //cleanText = str.replace(/<\/?[^>]+(>|$)/g, "");
                cleanText = emailMsg.buildertek__Email_Body__c;
                component.set("v.body", cleanText);
                console.log('strip_html_tags ' + cleanText);
                if (emailMsg.buildertek__Is_Incoming_Email__c == true) {
                    console.log('called true');
                    email = emailMsg.FromAddress;
                    subject = emailMsg.Subject;
                }
                if (emailMsg.buildertek__Is_Incoming_Email__c == false) {
                    email = emailMsg.ToAddress;
                    subject = emailMsg.Subject;
                }
                console.log('email' + email);
                var modalBody;
                var overlayLib;
                $A.createComponents([
                        ["c:ReplyEmail", {
                            "email": email,
                            "ccEmail": ccEmail,
                            "subject": subject,
                            "recordId": emidrply,
                            "emailMessageId": repid,
                            "saveCallback": component.get("v.refreshGridAction"),
                            "cancelCallback": function () {
                                overlayLib.close();
                            }
                        }],

                    ],
                    function (components, status, errorMessage) {
                        if (status === "SUCCESS") {
                            component.find('overlayLib').showCustomModal({
                                header: "Reply Email",
                                body: components[0],
                                footer: components[0].find("footer").get("v.body"),
                                showCloseButton: true,
                                cssClass: 'slds-modal_medium',
                                closeCallback: function () {

                                }
                            }).then(function (overlay) {
                                overlayLib = overlay;
                            });
                        }
                    }
                );

            }
        });
        $A.enqueueAction(action);
    }

})