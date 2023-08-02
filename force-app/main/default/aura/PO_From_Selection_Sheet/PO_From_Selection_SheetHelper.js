({
    //======= Description:- This method is used to display option list =========
    doInitHelper: function(component, event, helper) {

        var recordId = component.get("v.recordId");
        console.log('recordId --> ' + recordId);
        var action = component.get("c.getOption");
        action.setParams({
            recordId: recordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            console.log('State ---> ' + state);

            if (state == "SUCCESS") {

                var result = response.getReturnValue();
                console.log("Result ---> ", { result });

                component.set('v.optionWrapper', result);
                // result.forEach(element => {
                //     element.optionDataList.forEach(res => {
                //         console.log({ res });
                //         console.log(res.option.buildertek__Product__r);
                //         for (var i in res.option.buildertek__Product__r) {
                //             console.log(res.option.buildertek__Product__r.Name.length);
                //             if (res.option.buildertek__Product__r.Name.length > 80) {
                //                 console.log(res.option.buildertek__Product__r.Name.substring(0, 80));
                //                 // res.option.buildertek__Product__r.Name = res.option.buildertek__Product__r.Name.substring(0, 80);

                //             }

                //         }

                //     });

                // });

                if (result.length != 0) {
                    component.set("v.projectId", result[0].getProjectId);
                } else {
                    component.set("v.noData", true);
                }
            } else {
                helper.showToast("Error", "Error", "Something went wrong", "5000");
            }
        });
        $A.enqueueAction(action);

    },

    //===== Description:- This method is used to create purchase order when user click on "create PO" button from Selection sheet =====
    createPOhelper: function(component, event, helper) {
        try {
            component.set("v.Spinner", true);
            var recordId = component.get("v.recordId");
            // var selectedRowList = component.get("v.selectedRowList");

            var selectedRowList = [];

            var optionWrapper = component.get("v.optionWrapper");
            console.log('optionWrapper ==> ', { optionWrapper });

            optionWrapper.forEach(optionList => {
                optionList.optionDataList.forEach(optionData => {
                    // console.log(optionData.option.buildertek__Product__r.Name);

                    if (optionData.selected == true) {
                        selectedRowList.push(optionData.option);
                    }

                });
            });

            console.log('selectedRowList ==> ', { selectedRowList });
            console.log('Project Id => ' + component.get('v.projectId'));
            if (selectedRowList.length != 0) {

                var action = component.get("c.createPO");
                action.setParams({
                    recordId: recordId,
                    selectedRowList: selectedRowList

                });
                action.setCallback(this, function(response) {
                    var state = response.getState();
                    // console.log(response.getError());
                    var prjId = component.get('v.projectId');
                    // var getError = response.getError();
                    // var setError;
                    // console.log(Object.values(getError));

                    // var object = Object.values(getError);
                    // for (const key in object) {
                    //     var item = Object.values(object[key].fieldErrors).forEach(element => {
                    //         element.forEach(e => {
                    //             console.log(e.statusCode);
                    //             setError = e.statusCode;

                    //         });

                    //     });

                    //     console.log({ setError });
                    // }

                    // console.log(state);

                    if (state == "SUCCESS") {
                        helper.showToast("Success", "Success", "New PO and PO Line Created.", "5000");
                        var urlEvent = $A.get("e.force:navigateToURL");

                        if (prjId != null && prjId != '') {
                            urlEvent.setParams({
                                "url": "/lightning/r/buildertek__Project__c/" + prjId + "/related/buildertek__Purchase_Orders__r/view?ws=%2Flightning%2Fr%2Fbuildertek__Selection__c%2F" + recordId + "%2Fview"
                            });
                            urlEvent.fire();
                        } else {
                            urlEvent.setParams({
                                "url": "/lightning/o/buildertek__Purchase_Order__c/home"
                            });
                            urlEvent.fire();

                        }

                    } else {
                        // if (setError == 'STRING_TOO_LONG') {
                        //     helper.showToast("Error", "Error", 'Poduct name is too long', "5000");
                        // } else {
                        helper.showToast("Error", "Error", 'Something went wrong', "5000");
                        // }
                    }
                    component.set("v.Spinner", false);
                    $A.get("e.force:closeQuickAction").fire();
                });
                $A.enqueueAction(action);
            } else {
                component.set("v.Spinner", false);
                helper.showToast("Error", "Error", "Please Select Options", "5000");
            }
        } catch (error) {
            console.log('error --> ', { error });
        }
    },

    selectAll: function(component, event, helper) {
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

    //===== Description:- This method is used to show toast message !!====
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