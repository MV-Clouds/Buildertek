({
    getTimeSheetEntries : function(component, event, helper) {
        console.log('getTimeSheetEntries');
        var recordId = component.get('v.recordId');
        var action = component.get("c.getTimeSheetEntries");
        action.setParams({
            "recordId": recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result', result);
                if(result.length == 0){
                    window.onload = showToast();        // Show  toast message on VF page --> Aura
                    function showToast() {
                        sforce.one.showToast({
                            "title": "Error!",
                            "message": "No Time Sheet Entry found for this Time Sheet!",
                            "type": "error"
                        });
                    }     
                    var appEvent = $A.get("e.c:myEvent");
                    appEvent.setParams({
                        "message" : "Event fired"
                    });
                    appEvent.fire();
                    sforce.one.navigateToSObject(component.get('v.recordId'), 'detail');
                }
                component.set("v.timeSheetEntries", result);
                component.set("v.Spinner", false);
            }
        });
        $A.enqueueAction(action);
    },

    validateTimeSheetEntries : function(component, event, helper) {
        console.log('validateTimeSheetEntries');
        var timeSheetEntries = component.get('v.timeSheetEntries');
        var isValid = true;
        for(var i = 0; i < timeSheetEntries.length; i++){
            var name = timeSheetEntries[i].Name;
            name = name.replace(/^\s+|\s+$/g, '');

            if(timeSheetEntries[i].Name == '' || timeSheetEntries[i].Name == undefined || timeSheetEntries[i].Name == null || name == '' || name == undefined || name == null){
                component.set("v.Spinner", false);
                isValid = false;
                window.onload = showToast();        // Show  toast message on VF page --> Aura
                function showToast() {
                    sforce.one.showToast({
                        "title": "Error!",
                        "message": "Name cannot be empty on row " + (i + 1),
                        "type": "error"
                    });
                }     
                break;
            }

            //start time <= end time
            if (timeSheetEntries[i].buildertek__Start_Time__c && timeSheetEntries[i].buildertek__End_Time__c) {
                var startTime = new Date(timeSheetEntries[i].buildertek__Start_Time__c);
                var endTime = new Date(timeSheetEntries[i].buildertek__End_Time__c);
                console.log(timeSheetEntries[i].buildertek__Start_Time__c);
                console.log(timeSheetEntries[i].buildertek__End_Time__c);
                if (startTime > endTime) {
                    component.set("v.Spinner", false);
                    isValid = false;
                    window.onload = showToast();
                    function showToast() {
                        sforce.one.showToast({
                            "title": "Error!",
                            "message": "Start Time cannot be greater than End Time on row " + (i + 1),
                            "type": "error"
                        });
                    }
                    break;
                }
            }

            if (timeSheetEntries[i].buildertek__Sunday_hrs__c < 0 || timeSheetEntries[i].buildertek__Monday_hrs__c < 0 || timeSheetEntries[i].buildertek__Tuesday_hrs__c < 0 || timeSheetEntries[i].buildertek__Wednesday_hrs__c < 0 || timeSheetEntries[i].buildertek__Thursday_hrs__c < 0 || timeSheetEntries[i].buildertek__Friday_hrs__c < 0 || timeSheetEntries[i].buildertek__Saturday_hrs__c < 0 || timeSheetEntries[i].buildertek__Sunday_hrs__c > 24 || timeSheetEntries[i].buildertek__Monday_hrs__c > 24 || timeSheetEntries[i].buildertek__Tuesday_hrs__c > 24 || timeSheetEntries[i].buildertek__Wednesday_hrs__c > 24 || timeSheetEntries[i].buildertek__Thursday_hrs__c > 24 || timeSheetEntries[i].buildertek__Friday_hrs__c > 24 || timeSheetEntries[i].buildertek__Saturday_hrs__c > 24) {
                component.set("v.Spinner", false);
                isValid = false;
                window.onload = showToast();
                function showToast() {
                    sforce.one.showToast({
                        "title": "Error!",
                        "message": "Hours should be between 0 and 24 on row " + (i + 1),
                        "type": "error"
                    });
                }
                break;
            }

            if (!timeSheetEntries[i].buildertek__BT_Project__c) {
                component.set("v.Spinner", false);
                isValid = false;
                window.onload = showToast();
                function showToast() {
                    sforce.one.showToast({
                        "title": "Error!",
                        "message": "Project is empty at: " + (i + 1),
                        "type": "error"
                    });
                }
                break;
            }

            if (!timeSheetEntries[i].buildertek__Contact__c) {
                component.set("v.Spinner", false);
                isValid = false;
                window.onload = showToast();
                function showToast() {
                    sforce.one.showToast({
                        "title": "Error!",
                        "message": "Resource is empty at: " + (i + 1),
                        "type": "error"
                    });
                }
                break;
            }

        }
        
        if(isValid){
            helper.updateTimeSheetEntries(component, event, helper);
        }
    },

    isValidDateFormat: function(dateString) {
        // Define regular expression for date format (MMM D, YYYY)
        var parsedDate = new Date(dateString);
        return !isNaN(parsedDate.getTime());
    },

    updateTimeSheetEntries : function(component, event, helper) {
        var timeSheetEntries = component.get('v.timeSheetEntries');
        console.log('timeSheetEntries', timeSheetEntries);
        var deletedTimeSheetEntries = component.get('v.deletedTimeSheetEntries');
        console.log('deletedTimeSheetEntries', deletedTimeSheetEntries);

        var action = component.get("c.updateTimeSheetEntries");
        action.setParams({
            "upsertTimeSheetEntries": JSON.stringify(timeSheetEntries),
            "deletedTimeSheetEntries": JSON.stringify(deletedTimeSheetEntries)
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result', result);
                if(result == 'success'){
                    window.onload = showToast();        // Show  toast message on VF page --> Aura
                    function showToast() {
                        sforce.one.showToast({
                            "title": "Success!",
                            "message": "Time Sheet Entries updated successfully!",
                            "type": "success"
                        });
                    }     
                    var appEvent = $A.get("e.c:myEvent");
                    appEvent.setParams({
                        "message" : "Event fired"
                    });
                    appEvent.fire();
                    sforce.one.navigateToSObject(component.get('v.recordId'), 'detail');
                    windows.location.reload();
                }
            }
        });
        $A.enqueueAction(action);

        
    },
})