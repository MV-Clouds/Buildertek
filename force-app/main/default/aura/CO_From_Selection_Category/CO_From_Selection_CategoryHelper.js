({
    getOptionData: function(component, event, helper){
        component.set("v.Spinner", true);
        component.set("v.MainModal", false);
		component.set("v.UpgradeModal", true);
        var recordId = component.get("v.recordId");
        var action = component.get("c.getOption");
        action.setParams({
            recordId: recordId, 
            upgraded: component.get("v.DisplayUpgraded")
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State => ' + state);

            if (state == "SUCCESS") {
                var result = response.getReturnValue();
                console.log('Result =>', { result });

                if (result.length == 0) {
                    component.set("v.noData", true);
                } else{
                    component.set("v.orgCurr", result[0].orgCurr);
                }
                component.set("v.optionWrapper", result);
                component.set("v.Spinner", false);
            } else{
                component.set("v.Spinner", false);
                helper.showToast("Error", "Error", "Something Went Wrong", "5000");
                $A.get("e.force:closeQuickAction").fire();
            }
        });
        $A.enqueueAction(action);
    },

    createRecord: function(component, event, helper){
        var coData = component.get('v.changeOrder');
        console.log('CO Data ==> '+coData.Name);
        if (coData.Name != '') {
            var selectedRowList = [];

            var optionWrapper = component.get("v.optionWrapper");
            console.log('optionWrapper ==> ', { optionWrapper });

            optionWrapper.forEach(optionList => {
                optionList.optionDataList.forEach(optionData => {
                    if (optionData.selected == true) {
                        selectedRowList.push(optionData.option);
                    }
                });
            });

            console.log('selectedRowList =>', {selectedRowList});
            if (selectedRowList.length != 0) {
                component.set("v.Spinner", true);
                var action = component.get("c.createCO");
                action.setParams({
                    coData: coData,
                    selectedRowList: selectedRowList
                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    console.log('State => ' + state);
                    if (state == "SUCCESS") {
                        var result = response.getReturnValue();
                        console.log('Result ==> '+result);
                        helper.showToast("Success", "Success", "New CO and CO Lines Created.", "5000");
                        $A.get("e.force:closeQuickAction").fire();
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": result,
                            "slideDevName": "Detail"
                        });
                        navEvt.fire();
                    } else{
                        helper.showToast("Error", "Error", "Something Went Wrong", "5000");
                        var error = response.getError();
                        console.log('Error =>', {error});
                    }
                    component.set("v.Spinner", false);
                });
                $A.enqueueAction(action);
            } else {
                helper.showToast("Error", "Error", "Please Select Options", "5000");
            }
        } else{
            helper.showToast("Error", "Error", "Please Write Change Order Name", "5000");
        }

    },

    selectCheck: function(component, event, helper) {
        var optionWrapper = component.get("v.optionWrapper");

        console.log('optionWrapper ==> ', { optionWrapper });
        optionWrapper.forEach(optionList => {
            optionList.optionDataList.forEach(optionData => {
                console.log('optionData ==> ', optionData);
                optionData.selected = false;
                if (optionList.selected == true) {
                    console.log('true ====> ');
                    console.log('optionList ==> ', optionList);
                    optionData.selected = true;
                }
            });
        });
        component.set("v.optionWrapper", optionWrapper);
        console.log('End optionWrapper ==> ', { optionWrapper });
    },
    
    selectAll: function(component, event, helper){
        var checkAllData = component.find("checkAll").get("v.checked");
        console.log('checkAllData ==> '+checkAllData);

        var optionWrapper = component.get("v.optionWrapper");
        optionWrapper.forEach(optionList => {
            optionList.selected = checkAllData;
            optionList.optionDataList.forEach(optionData => {
                optionData.selected = checkAllData;
            });
        });
        component.set("v.optionWrapper", optionWrapper);
    },

    showToast: function(type, title, message, time) {
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
})