({
    doInit: function (component, event, helper) {
        helper.getAllScheduleItems(component, event, helper);
        helper.getAllPOs(component, event, helper);
    },

    Save: function (component, event, helper) {
        console.log('Save');
        let selectedPOItems = component.get("v.selectedPOItems");
        console.log('Selected Schedule Items: ', selectedPOItems);
        debugger;
        if (selectedPOItems.length > 0) {
            component.set("v.spinner", true);

            helper.saveSchedulePO(component, event, helper, function () {
                component.set("v.spinner", false);
            });
        } else {
            helper.showToast('error', 'Error', 'Please select at least one PO to sync', '3000');
        }
    },


    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },

    onSelectChange: function (component, event, helper) {
        let poItem = event.getSource();
        let poId = poItem.get("v.value");
        let scheduleItemId = event.target.dataset.id;
        console.log('PO Id: ' + poId);
        console.log('Selected Schedule Item Id: ' + scheduleItemId);

        let selectedPOItems = component.get("v.selectedPOItems");

        if (poId === "") {
            let indexToRemove = selectedPOItems.findIndex(item => item.scheduleItemId === scheduleItemId);
            if (indexToRemove !== -1) {
                selectedPOItems.splice(indexToRemove, 1);
            }
        } else {
            let schedulePO = {
                scheduleItemId: scheduleItemId,
                poId: poId
            };

            let index = selectedPOItems.findIndex(item => item.scheduleItemId === scheduleItemId);
            if (index !== -1) {
                selectedPOItems[index] = schedulePO;
            } else {
                selectedPOItems.push(schedulePO);
            }
        }

        let poList = component.get("v.poList");
        poList.forEach(po => {
            po.isDisabled = selectedPOItems.some(item => item.poId === po.Id);
        });

        component.set("v.poList", poList);
        component.set("v.selectedPOItems", selectedPOItems);
    },

})