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
                result.forEach(function(wtl) {
                if (wtl.buildertek__Quantity__c == null) {
                    wtl.buildertek__Quantity__c = 1;
                }
            });

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
    },

    validateWalkThroughLines: function (component, event, helper) {
        var walkThroughLines = component.get('v.walkThroughLine');
        var isValid = true;
        for (var i = 0; i < walkThroughLines.length; i++) {
            var product = walkThroughLines[i].buildertek__Product__c || '';
            var quantity = walkThroughLines[i].buildertek__Quantity__c;
            console.log(quantity);
            console.log(`product: ${product}`);
            console.log(`walkThroughLines[i] ${JSON.stringify(walkThroughLines[i])}`);
            if (walkThroughLines[i].buildertek__Product__c == '' || walkThroughLines[i].buildertek__Product__c == undefined || walkThroughLines[i].buildertek__Product__c == null) {
                isValid = false;
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
                window.onload = showToast();
                function showToast() {
                    sforce.one.showToast({
                        "title": "Error!",
                        "message": "Product cannot be empty ",
                        "type": "error"
                    });
                }
                break;
            }
            if (quantity<1 || quantity==null) {
                isValid = false;
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
                window.onload = showToast();
                function showToast() {
                    sforce.one.showToast({
                        "title": "Error!",
                        "message": "Quantity cannot be less than 1 ",
                        "type": "error"
                    });
                }
                break;
            }
        }
        console.log(`isValid: ${isValid}`);
        if (isValid) {
            this.updateWalkThroughLine(component, event, helper);
        }
    },

    updateWalkThroughLine: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        console.log('updateWalkThroughLine');
        var walkThroughLines = component.get('v.walkThroughLine');
        console.log(`walkThroughLines: ${JSON.stringify(walkThroughLines)}`);
        debugger
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
                    window.onload = showToast();
                    function showToast() {
                        sforce.one.showToast({
                            "title": "Success",
                            "message": "Success in updating Walk Through Lines",
                            "type": "success"
                        });
                    }
                    var appEvent = $A.get("e.c:myEvent");
                    appEvent.setParams({
                        "message": "Event fired"
                    });
                    appEvent.fire();
                    sforce.one.navigateToSObject(component.get('v.recordId'), 'detail');
                } else {
                    console.error('Error in updating Walk Through Lines', response.getError());
                    window.onload = showToast();
                    function showToast() {
                        sforce.one.showToast({
                            "title": "Error!",
                            "message": "Error in updating Walk Through Lines "+response.getError(),
                            "type": "error"
                        });
                    }
                }
            }
        });
        $A.enqueueAction(action);
    }
})