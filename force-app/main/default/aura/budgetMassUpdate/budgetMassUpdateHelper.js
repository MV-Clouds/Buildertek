({
    getBudgetItemData: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();

        var action = component.get("c.fetchDataAndFieldSetValues");
        action.setParams({
            "RecordId": component.get("v.budgetId"),
            "sObjectName": "buildertek__Budget_Item__c",
            "fieldSetName": "buildertek__Mass_Update_Budget_Item"
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result) {
                    component.set("v.budgetItems", result.budgetItemList);
                    component.set("v.budgetName", result.budgetItemList[0].buildertek__Budget__r.Name);
                    component.set("v.fieldSetValues", result.FieldSetValues);

                    let groupingOption = [];
                    for (let i = 0; i < result.BudgetItemGroupList.length; i++) {
                        groupingOption.push({ label: result.BudgetItemGroupList[i].Name, value: result.BudgetItemGroupList[i].Id });
                    }
                    component.set("v.availableGroupingOption", groupingOption);
                    helper.groupBudgetItems(component, event, helper);
                }
            } else {
                var errors = response.getError();
                var message = 'Unknown error';
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                helper.showToast("Error", message, "error");
            }
            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
        });

        $A.enqueueAction(action);
    },

    groupBudgetItems: function (component, event, helper) {
        var budgetItem = component.get("v.budgetItems");
        var groupedData = {};
        var counter = 1;

        budgetItem.forEach(item => {
            var groupName = item.buildertek__Group__r ? item.buildertek__Group__r.Name : 'No Grouping';
            var groupId = item.buildertek__Group__c ? item.buildertek__Group__c : 'no-group';
            item.Number = counter++;

            if (!groupedData[groupId]) {
                groupedData[groupId] = {
                    groupName: groupName,
                    groupId: groupId,
                    items: []
                };
            }

            groupedData[groupId].items.push(item);
        });

        component.set("v.data", Object.values(groupedData));
        let budgetItemData = Object.values(groupedData);
        var fieldSetValues = component.get("v.fieldSetValues");

        budgetItemData.forEach(group => {
            group.items.forEach(item => {
                fieldSetValues.forEach(field => {
                    item[field.name] = item[field.name] || '';
                });
            });
        });

        component.set("v.preprocessedData", budgetItemData);
    },

    showToast: function (title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type
        });
        toastEvent.fire();
    },

    updateBudgetItem: function (component, event, helper) {
        var budgetItems = component.get("v.budgetItems");

        var action = component.get("c.updatebudgetItemsList");
        action.setParams({
            "updateBudgetItems": budgetItems
        });

        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if (result === "Success") {
                    helper.showToast("Success", "Budget Items updated successfully.", "success");

                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getEnclosingTabId().then(function (tabId) {
                        window.postMessage({ action: 'closeSubtab' }, window.location.origin);
                        workspaceAPI.closeTab({ tabId: tabId });
                    });

                } else {
                    helper.showToast("Error", result, "error");
                }
            } else if (state === "ERROR") {
                var errors = response.getError();
                var message = 'Unknown error';
                if (errors && Array.isArray(errors) && errors.length > 0) {
                    message = errors[0].message;
                }
                helper.showToast("Error", message, "error");
            }

            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();
        });

        $A.enqueueAction(action);
    }
    
})