({
    getWalkThroughLines: function (component, event, helper) {
        var recordId = component.get('v.recordId');
        var action = component.get("c.getWalkthroughLineItems");
        action.setParams({
            "walkthroughId": recordId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('getWalkThroughLines:', result);
                // if (result.length == 0) {
                //     window.onload = showToast();
                //     function showToast() {
                //         sforce.one.showToast({
                //             "title": "Error!",
                //             "message": "No Walk Through Line found for this Walk Through!",
                //             "type": "error"
                //         });
                //     }
                //     var appEvent = $A.get("e.c:myEvent");
                //     appEvent.setParams({
                //         "message": "Event fired"
                //     });
                //     appEvent.fire();
                //     sforce.one.navigateToSObject(component.get('v.recordId'), 'detail');
                // }
                component.set("v.walkThroughLine", result);
            }
        });
        $A.enqueueAction(action);
    },

    getDropDownValues: function (component, event, helper) {
        var action = component.get("c.getDropDown");
        action.setParams({
            "objName": 'buildertek__Walk_Through_Line_Items__c',
            "fieldName": 'buildertek__Location__c'
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.locationOptions", result);
            } else {
                console.error("Error fetching dropdown values");
            }
        });
        $A.enqueueAction(action);
        component.set("v.Spinner", false);
    },

    validateWalkThroughLines: function (component, event, helper) {
        var walkThroughLines = component.get('v.walkThroughLine');
        var isValid = true;
        for (var i = 0; i < walkThroughLines.length; i++) {
            var desc = walkThroughLines[i].buildertek__Description__c || '';
            desc = desc.replace(/^\s+|\s+$/g, '');
            console.log(`desc: ${desc}`);
            console.log(`walkThroughLines[i] ${JSON.stringify(walkThroughLines[i])}`);
            if (walkThroughLines[i].buildertek__Description__c == '' || walkThroughLines[i].buildertek__Description__c == undefined || walkThroughLines[i].buildertek__Description__c == null || desc == '' || desc == undefined || desc == null) {
                component.set("v.Spinner", false);
                isValid = false;
                window.onload = showToast();
                function showToast() {
                    sforce.one.showToast({
                        "title": "Error!",
                        "message": "Description cannot be empty ",
                        "type": "error"
                    });
                }
                break;
            }
        }
        console.log(`isValid: ${isValid}`);
        if (isValid) {
            this.updateWalkThroughLines(component, event, helper);
        }
    },

    updateWalkThroughLines: function (component, event, helper) {
        component.set("v.Spinner", true);
        console.log('updateWalkThroughLines');
        var walkThroughLines = component.get('v.walkThroughLine');
        var deletedWalkThroughLines = component.get('v.deletedWalkThroughLine');
        var action = component.get("c.updateWalkThroughLines");
        action.setParams({
            "insertWTL": JSON.stringify(walkThroughLines),
            "deleteWTL": JSON.stringify(deletedWalkThroughLines)
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result', result);
                if (result == 'Success') {
                    var appEvent = $A.get("e.c:myEvent");
                    appEvent.setParams({
                        "message": "Event fired"
                    });
                    appEvent.fire();
                    sforce.one.navigateToSObject(component.get('v.recordId'), 'detail');
                } else {
                    window.onload = showToast();
                    function showToast() {
                        sforce.one.showToast({
                            "title": "Error!",
                            "message": "Error in updating Walk Through Lines",
                            "type": "error"
                        });
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }
})