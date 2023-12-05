({
    doInit: function (component, event, helper) {
        component.set("v.spinner", true);
        helper.getAllScheduleItems(component, event, helper);
        helper.getAllPOs(component, event, helper);
        component.set("v.spinner", false);
    },

    Save: function (component, event, helper) {
        console.log('Save');
        let selectedScheduleItems = component.get("v.selectedScheduleItems");
        console.log('Selected Schedule Items: ', selectedScheduleItems);
        if (selectedScheduleItems.length > 0) {
            component.set("v.spinner", true);
            helper.saveSchedulePO(component, event, helper);
            component.set("v.spinner", false);
        } else {
            helper.showToast('error', 'Error', 'Please select at least one Schedule Item');
        }
    },

    closeModel: function (component, event, helper) {
        $A.get("e.force:closeQuickAction").fire();
    },


    onSelectChange: function (component, event, helper) {
        let selectedItem = event.getSource();
        let selectedScheduleItemId = selectedItem.get("v.value");
        let poId = event.target.dataset.id;

        let schedulePO = {
            scheduleItemId: selectedScheduleItemId,
            poId: poId
        };

        console.log('PO Id: ' + poId);
        console.log('Selected Schedule Item Id: ' + selectedScheduleItemId);

        let selectedScheduleItems = component.get("v.selectedScheduleItems");
        let index = selectedScheduleItems.findIndex(item => item.scheduleItemId === selectedScheduleItemId);
        if (index !== -1) {
            selectedScheduleItems[index] = schedulePO;
        } else {
            selectedScheduleItems.push(schedulePO);
        }
        console.log('schedulePO', schedulePO);
        component.set("v.selectedScheduleItems", selectedScheduleItems);
    },

})

