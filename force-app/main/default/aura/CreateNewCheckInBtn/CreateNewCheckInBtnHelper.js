({
    saveRecordData: function (component, event, helper) {
        try {
            component.set("v.Spinner", true);
            component.set("v.desableSaveBtn", true);

            var pressedBtn = event.target.name;
            console.log('pressedBtn =>' + pressedBtn);

            var checkInRec = component.get('v.checkInRec');
            var uploadedFileId = component.get('v.uploadedFileId');
            console.log('checkInRec ==>', JSON.parse(JSON.stringify(checkInRec)));
            if (checkInRec.buildertek__Date_Created__c != undefined && checkInRec.buildertek__Project__c != undefined && checkInRec.Name != undefined &&
                checkInRec.buildertek__Date_Created__c != '' && checkInRec.buildertek__Project__c != '' && checkInRec.Name.trim() != '') {

                console.log('uploadedFileId ==>', uploadedFileId);
                var action = component.get("c.createCheckIn");
                action.setParams({
                    record: checkInRec,
                    fileIds: uploadedFileId
                });
                action.setCallback(this, function (response) {
                    var state = response.getState();
                    console.log({ state });
                    var result = response.getReturnValue();
                    console.log({ result });

                    if (state === "SUCCESS") {
                        helper.showToast("Success", "Success", "New Check-In Created Successfully", "5000");
                        if (pressedBtn == 'saveBtn') {
                            helper.navigateToRecord(component, event, helper, result)
                        } else if (pressedBtn == 'saveAndNewBtn') {
                            component.set('v.checkInRec.Name', '');
                            component.set('v.checkInRec.buildertek__Notes__c', '');
                            component.set('v.checkInRec.buildertek__Days_Lost__c', '');
                            component.set('v.checkInRec.buildertek__Reporting_Location__c', '');
                            // component.set('v.checkInRec.buildertek__Weather__c', '');
                            // component.set('v.checkInRec.buildertek__Date_Created__c', '');
                            
                            /*  for Date Created Default value */
                            var todayDate = new Date();
                            console.log('cuurentDate with ISO string ==>' + todayDate.toISOString());
                            const offset = todayDate.getTimezoneOffset(); 
                            console.log('offset ==>' + offset);
                            todayDate = new Date(todayDate.getTime()-(offset*60*1000)); 
                            console.log('todayDate with Offset ==>' + todayDate);
                            var todayDateISO = todayDate.toISOString().split('T')[0];
                            component.set('v.checkInRec.buildertek__Date_Created__c', todayDateISO);

                            /*  for Weather Default value */
                            component.set('v.checkInRec.buildertek__Weather__c', 'Sunny');

                            /*  for Status Default value */
                            component.set('v.checkInRec.buildertek__Status__c', 'No Issues');

                            var recordId = component.get("v.recordId");
                            if (recordId == null || recordId == undefined) {
                                component.set('v.checkInRec.buildertek__Project__c', '');
                            }

                            var contentDocId = [];
                            component.set('v.uploadedFileId', contentDocId);
                            
                            component.set("v.Spinner", false);
                            component.set("v.desableSaveBtn", false);
                        }
                    } else {
                        helper.showToast("Error", "Error", "Something Went Wrong.", "5000");
                        component.set("v.Spinner", false);
                        component.set("v.desableSaveBtn", false);
                    }
                });
                $A.enqueueAction(action);
            } else {
                helper.showToast("warning", "Required Fields Missing", "Please complete required fields.", "5000");
                component.set("v.Spinner", false);
                component.set("v.desableSaveBtn", false);
            }
        } catch (error) {
            console.log("Int the catch block of saveRecordData =>");
            console.log(error);
            component.set("v.Spinner", false);
            component.set("v.desableSaveBtn", false);
        }
    },

    deleteUploadedFiles: function (component, event, helper, uploadedFileId) {
        try {
            var action = component.get("c.deleteContentVersion");
            action.setParams({
                documentId: uploadedFileId
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                console.log({ state });
                if (state === "SUCCESS") {

                } else {
                    helper.showToast("Error", "Error", "Something Went Wrong.", "5000");
                }
            });
            $A.enqueueAction(action);
        } catch (error) {
            console.log("error in helper showToast Method");
            console.log({ error });
        }
    },

    showToast: function (type, title, message, time) {
        try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type": type,
                "message": message,
                "duration": time
            });
            toastEvent.fire();
        } catch (error) {
            console.log("error in helper showToast Method");
            console.log({ error });
        }
    },

    navigateToRecord: function (component, event, helper, recordId) {
        try {
            var navEvent = $A.get("e.force:navigateToSObject");
            navEvent.setParams({
                "recordId": recordId,
            });
            navEvent.fire();
        } catch (error) {
            console.log("error in helper navigateToRecord Method");
            console.log({ error });
        }
    },

    sendBooleanValue: function (component, event, helper) {
        var compEvent = component.getEvent("popUpBooleanValue");
        compEvent.setParams({
            "booleanValue" : false
        });
        compEvent.fire();
    },
})