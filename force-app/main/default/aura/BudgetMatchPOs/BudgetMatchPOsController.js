({
    doInit: function (component, event, helper) {
        helper.getAllBudgetLines(component, event, helper);
    },

    Save: function (component, event, helper) {
        let selectedPOItems = component.get("v.selectedPOItems");
        if (selectedPOItems.length > 0) {
            component.set("v.spinner", true);

            helper.saveBudgetPO(component, event, helper, function () {
                component.set("v.spinner", false);
            });
        } else {
            helper.showToast('error', 'Error', 'Please select atleast one Budget Line', '3000');
        }
    },


    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    onSelectChange: function (component, event, helper) {
        let budgetLine = event.getSource();
        let budgetLineId = budgetLine.get("v.value");
        let poId = event.target.dataset.id;
        console.log('PO Id: ' + poId);
        console.log('Selected budget Item Id: ' + budgetLineId);

        let selectedPOItems = component.get("v.selectedPOItems");

        if (budgetLineId === "") {
            let indexToRemove = selectedPOItems.findIndex(item => item.poId === poId);
            if (indexToRemove !== -1) {
                selectedPOItems.splice(indexToRemove, 1);
            }
        } else {
            let budgetPO = {
                budgetLineId: budgetLineId,
                poId: poId
            };

            let index = selectedPOItems.findIndex(item => item.poId === poId);
            if (index !== -1) {
                selectedPOItems[index] = budgetPO;
            } else {
                selectedPOItems.push(budgetPO);
            }
        }

        component.set("v.selectedPOItems", selectedPOItems);
    },

})