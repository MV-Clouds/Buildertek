({
    /*
    Description:- This method used for get and display all the fields of the meeting object record in modal box
    Created Date:- 30th November
    
    */
    doInit: function(component, event, helper) {
        try {
            component.set("v.Spinner", true);
            var action = component.get("c.getMeetingData");
            action.setParams({
                recordId: component.get("v.recordId")
            });
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(response);
                if (state === "SUCCESS") {
                    var resule = response.getReturnValue();
                    console.log('resule ==> ',{resule});
                    
                    // For Set Start Time
                    var startTime = resule.buildertek__Start_Time__c;
                    var startMinutes = Math.floor((startTime / (1000 * 60)) % 60);
                    var startHours = Math.floor((startTime / (1000 * 60 * 60)) % 24);
                    
                    startHours = (startHours < 10) ? "0" + startHours : startHours;
                    startMinutes = (startMinutes < 10) ? "0" + startMinutes : startMinutes;
                    resule.buildertek__Start_Time__c = startHours + ":" + startMinutes + ":00.000";

                    // For Set End Time
                    var endTime = resule.buildertek__End_Time__c;
                    var endMinutes = Math.floor((endTime / (1000 * 60)) % 60);
                    var endHours = Math.floor((endTime / (1000 * 60 * 60)) % 24);
                    
                    endHours = (endHours < 10) ? "0" + endHours : endHours;
                    endMinutes = (endMinutes < 10) ? "0" + endMinutes : endMinutes;
                    resule.buildertek__End_Time__c = endHours + ":" + endMinutes + ":00.000";

                    component.set('v.oldMeeting', resule);
                }
            });
            $A.enqueueAction(action);

            component.set("v.Spinner", false);
        } catch (error) {
            console.log('Error ==> ',{ error });
        }
    },

    /*
    Description:- This method used for close the pop up box when user click on cancel!
    Created Date:- 30th November
    
    */
    Cancel: function(component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();

    },

    /*
    Description:- This method used for Clone meeting object record and its related list (Atendee and ActionItem)
    Created Date:- 30th November
    
    */
    Save: function(component, event, helper) {

        component.set("v.Spinner", true);
        var meetingData = component.get('v.oldMeeting');
        delete meetingData['Id'];

        var action = component.get("c.cloneMeeting");
        action.setParams({
            meeting: meetingData,
            recordId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            console.log(response);
            var state = response.getState();
            var result = response.getReturnValue();
            $A.get("e.force:closeQuickAction").fire();
            if (state === "SUCCESS") {
                helper.showToast("Success", "Success", "Meeting added successfully", "5000");

                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": result,
                    "slideDevName": "related"
                });
                navEvt.fire();
            } else {
                helper.showToast("Error", "Error", "Failed to save record", "5000");
            }
            component.set("v.Spinner", false);
        });

        $A.enqueueAction(action);
    },

})