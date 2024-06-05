({
    doInit: function (component, event, helper) {
        helper.fetchWalkThroughs(component, event, helper, '');
    },

    handleSearchKeyChange: function (component, event, helper) {
        clearTimeout(component.searchTimeout);
        component.searchTimeout = setTimeout(() => {
            const searchKey = component.get("v.searchWT");;
            console.log(`searchKey: ${searchKey}`);
            helper.fetchWalkThroughs(component, event, helper, searchKey);
        }, 300);
    },

    handleRadioChange: function (component, event, helper) {
        var selectedWalkThroughId = event.getSource().get("v.text");
        component.set("v.selectedWalkThroughId", selectedWalkThroughId);
    },

    closeModal: function (component, event, helper) {
        helper.close(component, event, helper);
    },

    importWalkThrough: function (component, event, helper) {
        var walkThroughID = component.get("v.selectedWalkThroughId");
        if (!walkThroughID) {
            helper.showToast('error', 'Error', 'Please select Walk Through to import.');
            return;
        } else {
            $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "SHOW" }).fire();

            var action = component.get("c.importWalkThroughFromMaster");
            action.setParams({
                "importWT": walkThroughID,
                "WTId": component.get("v.recordId")
            });

            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log(`RESPONSE: ${result}`);
                    if (result === 'Success') {
                        helper.showToast('success', 'Success', 'Walk Through(s) imported successfully.');

                        var evt = $A.get("e.force:navigateToRelatedList");
                        evt.setParams({
                            "relatedListId": "buildertek__Walk_Through_Line_Items__r",
                            "parentRecordId": component.get('v.recordId')
                        });
                        evt.fire(); 
                    } else {
                        console.error("Error importing Walk Through(s)", result);
                        helper.showToast('error', 'Error', result);
                    }
                } else if (state === "ERROR") {
                    var errors = response.getError();
                    if (errors && errors[0] && errors[0].message) {
                        console.error("Error message: " + errors[0].message);
                        helper.showToast('error', 'Error', errors[0].message);
                    } else {
                        console.error("Unknown error");
                        helper.showToast('error', 'Error', 'Unknown error');
                    }
                }
                $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "HIDE" }).fire();
                helper.close(component, event, helper);
            });
            $A.enqueueAction(action);
        }
    }

})