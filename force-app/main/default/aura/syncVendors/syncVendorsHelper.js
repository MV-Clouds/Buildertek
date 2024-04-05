({
    getVendorsAndScheduleItems: function (component) {
        var action = component.get("c.fetchVendorAndSchedulItemData");
        action.setParams({
            "schedulId": component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {
            let res = response.getReturnValue();
            console.log('res ', res);
            if (res.Message == 'success') {

                if (res.vendorList.length == 0) {
                    this.showToast(component, 'Warning', 'Vendors are not available for Sync', 'warning');
                    this.closeModel(component);
                    return;
                }

                if (res.schedulItemList.length == 0) {
                    this.showToast(component, 'Warning', 'There are no Schedule Items that match the Vendors you have set up for this Project.', 'warning');
                    this.closeModel(component);
                    return;
                }

                component.set("v.vendorList", res.vendorList);
                component.set("v.scheduleItemList", res.schedulItemList);
            } else if (res.Message == 'id-blank') {
                this.showToast(component, 'Warning', 'ScheduleId is blank', 'warning');
                this.closeModel(component);
            } else if (res.Message == 'project-id-blank') {
                this.showToast(component, 'Warning', 'Project is missing on current schedule.', 'warning');
                this.closeModel(component);
            } else {
                console.log('servce res ', res.Message);
                this.showToast(component, 'Error', 'Something went wrong', 'error');
                this.closeModel(component);
            }
        });
        $A.enqueueAction(action);
    },

    syncVendorsHelper: function (component) {

        $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "SHOW" }).fire();

        let vendorList = component.get("v.vendorList");
        let scheduleItemList = component.get("v.scheduleItemList");
        console.log('vendorList ', vendorList);
        console.log('scheduleItemList ', scheduleItemList);

        // this.processOperation(component, vendorList, scheduleItemList);
        this.assignVendorToScheduleItems(component, vendorList, scheduleItemList);
        console.log('scheduleItemList ', { scheduleItemList });

        this.updateScheduleItemListHelper(component, scheduleItemList);

        $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "HIDE" }).fire();
    },

    assignVendorToScheduleItems: function (component, vendors, scheduleItems) {
        // Loop through each schedule item
        for (const scheduleItem of scheduleItems) {
            // Initially set a flag and accumulator variable
            let isMatchFound = false;
            let possibleVendors = [];

            // Loop through each vendor
            for (const vendor of vendors) {
                // Check for potential matches based on undefined values
                const costMatch = scheduleItem.buildertek__Cost_Code__c === vendor.buildertek__BT_Cost_Code__c || !scheduleItem.buildertek__Cost_Code__c || !vendor.buildertek__BT_Cost_Code__c;
                const tradeMatch = scheduleItem.buildertek__Trade_Type__c === vendor.buildertek__Trade_Type__c || !scheduleItem.buildertek__Trade_Type__c || !vendor.buildertek__Trade_Type__c;
                const groupingMatch = scheduleItem.buildertek__Vendor_Grouping__c === vendor.buildertek__BT_Grouping__c || !scheduleItem.buildertek__Vendor_Grouping__c || !vendor.buildertek__BT_Grouping__c;

                // If all three fields match or two fields match and one is undefined, add to possibility list
                if (costMatch && tradeMatch && groupingMatch) {
                    isMatchFound = true;
                    scheduleItem.buildertek__Contractor__c = vendor.buildertek__Account__c;
                    break; // No need to check other vendors if exact match found
                } else if ((costMatch && tradeMatch) || (tradeMatch && groupingMatch) || (costMatch && groupingMatch)) {
                    possibleVendors.push(vendor); // Add possibility for further evaluation
                }
            }

            // Handle scenarios where at least two fields match but need final evaluation
            if (!isMatchFound && possibleVendors.length > 0) {
                if (possibleVendors.length === 1) {
                    scheduleItem.buildertek__Contractor__c = possibleVendors[0].buildertek__Account__c; // Only one possible match, assign its Name
                } else if (possibleVendors.length > 1) {
                    // Determine remaining undefined field and choose vendor with matching or undefined value
                    if (!scheduleItem.buildertek__Cost_Code__c) {
                        scheduleItem.buildertek__Contractor__c = possibleVendors.find(vendor => !vendor.buildertek__BT_Cost_Code__c).buildertek__Account__c;
                    } else if (!scheduleItem.buildertek__Trade_Type__c) {
                        scheduleItem.buildertek__Contractor__c = possibleVendors.find(vendor => !vendor.buildertek__Trade_Type__c).buildertek__Account__c;
                    } else {
                        scheduleItem.buildertek__Contractor__c = possibleVendors.find(vendor => !vendor.buildertek__BT_Grouping__c).buildertek__Account__c;
                    }
                }
            }

            // If no suitable match found, leave vendor Name as null
            if (!scheduleItem.buildertek__Contractor__c) {
                scheduleItem.buildertek__Contractor__c = null;
            }
        }

        // Return the updated schedule items
        return scheduleItems;
    },

    updateScheduleItemListHelper: function (component, listOfScheduleItems) {

        var action = component.get("c.updateScheduleItemList");
        action.setParams({
            "scheduleItemList": listOfScheduleItems,
        });
        action.setCallback(this, function (response) {
            let res = response.getReturnValue();
            if (res == 'success') {
                this.showToast(component, 'Success', 'Schedule Items updated successfully', 'success');
                this.closeModel(component);
            } else {
                console.log('servce res ', res);
                this.showToast(component, 'Error', 'Something went wrong', 'error');
                this.closeModel(component);
            }
        });
        $A.enqueueAction(action);
    },

    showToast: function (component, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "duration": '5000',
        });
        toastEvent.fire();
    },

    closeModel: function (component) {
        $A.get("e.force:closeQuickAction").fire();
    },

})