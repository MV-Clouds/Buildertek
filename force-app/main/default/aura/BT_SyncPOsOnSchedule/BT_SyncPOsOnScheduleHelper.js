({
    showToast: function (type, title, message, time) {
        try {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": title,
                "type": type,
                "message": message,
                "duration": time
            });
            toastEvent.fire();
        } catch (error) {
            console.log({ error });
        }
    },

    getPOsAndScheduleItems: function (component, event, helper) {
        var action = component.get("c.fetchPOAndScheduleItem");
        action.setParams({
            "scheduleId": component.get("v.recordId"),
        });
        action.setCallback(this, function (response) {
            let result = response.getReturnValue();
            console.log('result ', result);
            if (result.Message == 'Success') {

                if (result.poList.length == 0) {
                    this.showToast('warning', 'Warning', 'All POs have been synced to a schedule item', '3000');
                    this.closeModel(component);
                    return;
                }

                if (result.scheduleItemList.length == 0) {
                    this.showToast('warning', 'Warning', 'All schedule items have been synced to a PO', '3000');
                    this.closeModel(component);
                    return;
                }
                component.set("v.showModal", true);
                component.set("v.newPOList", result.poList);
                component.set("v.newScheduleItemList", result.scheduleItemList);
                console.log('newPOList ', component.get("v.newPOList"));
                console.log('newScheduleItemList ', component.get("v.newScheduleItemList"));
            } else if (result.Message == 'id-blank') {
                this.showToast(component, 'Warning', 'ScheduleId is blank', 'warning');
                this.closeModel(component);
            } else if (result.Message == 'project-id-blank') {
                this.showToast(component, 'Warning', 'Project is missing on current schedule.', 'warning', '3000');
                this.closeModel(component);
            } else {
                console.log('service result ', result.Message);
                this.showToast(component, 'Error', 'Something went wrong', 'error', '3000');
                this.closeModel(component);
            }
        });
        $A.enqueueAction(action);
    },

    syncPOHelper: function (component) {
        $A.get("e.c:BT_SpinnerEvent").setParams({ "action": "SHOW" }).fire();
        let poList = component.get("v.newPOList");
        let scheduleItemList = component.get("v.newScheduleItemList");
        this.processOperation(component, poList, scheduleItemList);
        this.updateHelper(component, poList, scheduleItemList);
    },

    processOperation: function (component, listOfPOs, ScheduleItemsList) {
        for (let i = 0; i < listOfPOs.length; i++) {
            for (let j = 0; j < ScheduleItemsList.length; j++) {
                if (ScheduleItemsList[j] && ScheduleItemsList[j].buildertek__Contractor__c) {
                    if ((listOfPOs[i] && listOfPOs[i].buildertek__Vendor__c === ScheduleItemsList[j].buildertek__Contractor__c) &&
                        (listOfPOs[i].buildertek__Category__c === ScheduleItemsList[j].buildertek__BT_Category__c) &&
                        (listOfPOs[i].buildertek__Cost_Code__c === ScheduleItemsList[j].buildertek__Cost_Code__c)) {

                        ScheduleItemsList[j].buildertek__Purchase_Order__c = listOfPOs[i].Id;
                        listOfPOs[i].buildertek__Schedule__c = ScheduleItemsList[j].buildertek__Schedule__c;
                        listOfPOs[i].buildertek__Schedule_Item__c = ScheduleItemsList[j].Id;
                        listOfPOs[i].buildertek__Completion__c = ScheduleItemsList[j].buildertek__Completion__c;
                        listOfPOs[i].buildertek__Projected_Start_Date__c = ScheduleItemsList[j].buildertek__Start__c;
                        listOfPOs[i].buildertek__Projected_Completion_Date__c = ScheduleItemsList[j].buildertek__Finish__c;
                        break;
                    }
                } else {
                    if ((listOfPOs[i] && listOfPOs[i].buildertek__Category__c === ScheduleItemsList[j].buildertek__BT_Category__c) &&
                        (listOfPOs[i].buildertek__Cost_Code__c === ScheduleItemsList[j].buildertek__Cost_Code__c)) {

                        ScheduleItemsList[j].buildertek__Purchase_Order__c = listOfPOs[i].Id;
                        ScheduleItemsList[j].buildertek__Contractor__c = listOfPOs[i].buildertek__Vendor__c;
                        listOfPOs[i].buildertek__Schedule__c = ScheduleItemsList[j].buildertek__Schedule__c;
                        listOfPOs[i].buildertek__Schedule_Item__c = ScheduleItemsList[j].Id;
                        listOfPOs[i].buildertek__Completion__c = ScheduleItemsList[j].buildertek__Completion__c;
                        listOfPOs[i].buildertek__Projected_Start_Date__c = ScheduleItemsList[j].buildertek__Start__c;
                        listOfPOs[i].buildertek__Projected_Completion_Date__c = ScheduleItemsList[j].buildertek__Finish__c;
                        break;
                    }
                }
            }
        }
    },

    updateHelper: function (component, poList, listOfScheduleItems) {
        var action = component.get("c.updateScheduleItemAndPOList");
        action.setParams({
            "scheduleItemList": listOfScheduleItems,
            "poList": poList
        });
        action.setCallback(this, function (response) {
            let state = response.getState();
            if (state === "SUCCESS") {
                let result = response.getReturnValue();
                console.log('result: ' + JSON.stringify(result));
                this.showToast('Success', 'Success', 'POs are successfully synced', '3000');
                window.location.reload();
                this.closeModel(component);
            } else {
                let error = response.getError();
                console.log('Error =>', { error });
                this.showToast('Error', 'Error', 'Something Went Wrong', '3000');
            }
        });
        $A.enqueueAction(action);
    },

    closeModel: function (component) {
        $A.get("e.force:closeQuickAction").fire();
    },
})