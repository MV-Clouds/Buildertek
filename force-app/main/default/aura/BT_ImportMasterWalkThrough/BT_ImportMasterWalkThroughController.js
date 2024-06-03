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

    handleCheckedWalkThrough: function (component, event, helper) {
        var checkbox = event.getSource();
        var isChecked = checkbox.get("v.value");
        var recordId = checkbox.get("v.text");
        var checkedRecordIds = component.get("v.checkedRecordIds");

        if (isChecked) {
            checkedRecordIds.push(recordId);
        } else {
            var index = checkedRecordIds.indexOf(recordId);
            if (index !== -1) {
                checkedRecordIds.splice(index, 1);
            }
        }
        console.log(`checked WT: ${checkedRecordIds}`);
        component.set("v.checkedRecordIds", checkedRecordIds);
    },

    closeModal: function (component, event, helper) {
        helper.close(component, event, helper);
    },

    importWalkThrough: function (component, event, helper) {
        try {
            var checkedWalkThroughIds = component.get("v.checkedRecordIds");
            if (checkedWalkThroughIds.length === 0) {
                helper.showToast('error', 'Error', 'Please check at least one record before importing.');
                return;
            } else {
                $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "SHOW" }).fire();

                var action = component.get("c.importWalkThroughFromMaster");
                action.setParams({
                    "importWT": checkedWalkThroughIds,
                    "WTId": component.get("v.recordId")
                });

                action.setCallback(this, function (response) {
                    var result = response.getReturnValue();
                    console.log(`RESPONSE: ${result}`);
                    if (result === 'Success') {
                        helper.showToast('success', 'Success', 'Walk Through(s) imported successfully.');
                    } else {
                        console.error("Error importing Walk Through(s)", result);
                        var errorMessage = result;
                        helper.showToast('error', 'Error', errorMessage);
                    }
                    $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "HIDE" }).fire();
                    helper.close(component, event, helper);
                });
                $A.enqueueAction(action);
            }
        } catch (error) {
            console.log('ERROR: ' + error);
        }
    }

})