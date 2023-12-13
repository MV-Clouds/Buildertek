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

        this.processOperation(component, vendorList, scheduleItemList);
        console.log('scheduleItemList ', { scheduleItemList });

        this.updateScheduleItemListHelper(component, scheduleItemList);

        $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "HIDE" }).fire();
    },

    processOperation: function (component, listOfVendors, listOfScheduleItems) {

        for (let j = 0; j < listOfScheduleItems.length; j++) {
            let schItemField1 = listOfScheduleItems[j].buildertek__Cost_Code__c;
            let schItemField2 = listOfScheduleItems[j].buildertek__Trade_Type__c;
            let schItemField3 = listOfScheduleItems[j].buildertek__Vendor_Grouping__c;

            console.log('----------------------------------------------------------');

            for (let i = 0; i < listOfVendors.length; i++) {
                let vendorField1 = listOfVendors[i].buildertek__BT_Cost_Code__c;
                let vendorField2 = listOfVendors[i].buildertek__Trade_Type__c;
                let vendorField3 = listOfVendors[i].buildertek__BT_Grouping__c;

                console.log('-----');

                if (vendorField1 == schItemField1 && vendorField2 == schItemField2 && vendorField3 == schItemField3 && vendorField1 != undefined && vendorField2 != undefined && vendorField3 != undefined) {
                    console.log('Condition 1');
                    console.log('Name ==> ' + listOfVendors[i].buildertek__Account__r.Name);
                    listOfScheduleItems[j].buildertek__Contractor__c = listOfVendors[i].buildertek__Account__c;
                    break;
                } else if ((vendorField1 == schItemField1 && vendorField2 == schItemField2 && schItemField1 != undefined && schItemField2 != undefined) ||
                    (vendorField1 == schItemField1 && vendorField3 == schItemField3 && schItemField1 != undefined && schItemField3 != undefined) ||
                    (vendorField2 == schItemField2 && vendorField3 == schItemField3 && schItemField2 != undefined && schItemField3 != undefined)) {
                    console.log('Condition 2');
                    console.log('Name ==> ' + listOfVendors[i].buildertek__Account__r.Name);
                    listOfScheduleItems[j].buildertek__Contractor__c = listOfVendors[i].buildertek__Account__c;
                    break;
                } else if ((vendorField1 == schItemField1 && schItemField1 != undefined) || (vendorField2 == schItemField2 && schItemField2 != undefined) || (vendorField3 == schItemField3 && schItemField3 != undefined)) {
                    console.log('Condition 3');
                    console.log('Name ==> ' + listOfVendors[i].buildertek__Account__r.Name);
                    listOfScheduleItems[j].buildertek__Contractor__c = listOfVendors[i].buildertek__Account__c;
                    break;
                }
            }
        }
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