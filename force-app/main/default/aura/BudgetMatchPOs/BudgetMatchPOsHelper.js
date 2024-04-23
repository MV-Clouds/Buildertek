({
    getAllBudgetLines: function (component, event, helper) {
        let action = component.get("c.fetchBudgetLine");
        let recordId = component.get("v.recordId");
        action.setParams({
            "budgetId": recordId,
        });
        action.setCallback(this, function (response) {
            let result = response.getReturnValue();
            if (result != null && result.length > 0) {
                result.forEach(item => {
                    item.isDisabled = false;
                });
                component.set("v.budgetLineList", result);
            } else {
                helper.showToast('warning', 'Warning', 'No Budget Lines Found', '3000');
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },

    getAllPOs: function (component, event, helper) {
        component.set("v.spinner", true);
        let recordId = component.get("v.recordId");
        let action = component.get("c.fetchAllPOs");
        action.setParams({
            "budgetId": recordId,
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                component.set("v.poList", result);
            } else {
                let error = response.getError();
                console.log('Error =>', { error });
                showToast('Error', 'Error', 'Something Went Wrong', '3000');
            }
        });
        setTimeout(function () {
            component.set("v.spinner", false);
        }, 3000);
        $A.enqueueAction(action);
    },

    showToast: function (type, title, message, time) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "type": type,
            "message": message,
            "duration": time
        });
        toastEvent.fire();
    },

    saveBudgetPO: function (component, event, helper) {
        let recordId = component.get("v.recordId");
        let selectedPOItems = component.get("v.selectedPOItems");
        let jsonBudgetPO = JSON.stringify(selectedPOItems);
        let action = component.get("c.setPOForbudgetLine");
        action.setParams({
            "budgetPO": jsonBudgetPO,
            "budgetId": recordId
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                console.log('result: ' + JSON.stringify(result));
                helper.showToast('success', 'Success', 'POs assigned successfully', '3000');
                $A.get("e.force:closeQuickAction").fire();
            } else {
                let error = response.getError();
                console.log('Error =>', { error });
                helper.showToast('Error', 'Error', 'Something Went Wrong', '3000');
            }
            if (callback && typeof callback === "function") {
                callback();
            }
        });
        $A.enqueueAction(action);
    }
})
