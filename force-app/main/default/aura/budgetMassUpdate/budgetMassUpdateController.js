({
    doInit: function (component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        var budgetId = myPageRef.state.c__budgetId;
        component.set("v.budgetId", budgetId);

        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then((response) => {
            let opendTab = response.tabId;
            workspaceAPI.setTabLabel({
                tabId: opendTab,
                label: 'Mass Update Budget Lines'
            });
            workspaceAPI.setTabIcon({
                tabId: opendTab,
                icon: 'custom:custom5',
                iconAlt: 'Mass Update Budget Lines'
            });
        });
        helper.getBudgetItemData(component, event, helper);
    },

    handleCancel: function (component, event, helper) {
        component.set("v.isCancelModalOpen", true);
    },

    closeScreen: function (component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getEnclosingTabId().then(function (tabId) {
            workspaceAPI.closeTab({ tabId: tabId });
        });
    },

    closeCancelModal: function (component, event, helper) {
        component.set("v.isCancelModalOpen", false);
    },

    onMassUpdate: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();

        var budgetItems = component.get("v.budgetItems");
        var isValid = true;

        for (var i = 0; i < budgetItems.length; i++) {
            if (!budgetItems[i].hasOwnProperty('Name') || budgetItems[i].Name === '') {
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
                isValid = false;
                helper.showToast("Error", "The Budget Item Name must be populated.", "error");
                break;
            }
        }

        if (isValid) {
            helper.updateBudgetItem(component, event, helper);
        }
    },

    handleLookUpEvent: function (component, event, helper) {
        console.log('SelectedHandler');
    },

    clearSelectedHandler: function (component, event, helper) {
        console.log('clearSelectedHandler');
    }
})