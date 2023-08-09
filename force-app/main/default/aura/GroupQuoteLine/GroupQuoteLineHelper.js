({
    // *** BOM Grouping ***

    // submitDetails: function(component, event, helper) {
    //     var valueofField1 = component.get("v.valueofField1")
    //     var valueofField2 = component.get("v.valueofField2")
    //     var valueofField3 = component.get("v.valueofField3")
    //     var valueofField4 = component.get("v.valueofField4")

    //     if(valueofField1 == "" && valueofField2 == "" && valueofField3 == "" && valueofField4 == ""){
    //         var toastEvent = $A.get("e.force:showToast");
    //         toastEvent.setParams({
    //             "type": "Error",
    //             "title": "Error!",
    //             "message": 'Please Select At Least One Field'
    //         });
    //         toastEvent.fire();           
    //     } else{
    //         var selectedFieldList = [];
    //         if (valueofField1 != "") {
    //             selectedFieldList.push(valueofField1)
    //         }
    //         if (valueofField2 != "") {
    //             selectedFieldList.push(valueofField2)
    //         }
    //         if (valueofField3 != "") {
    //             selectedFieldList.push(valueofField3)
    //         }
    //         if (valueofField4 != "") {
    //             selectedFieldList.push(valueofField4)
    //         }
    //         console.log('selectedFieldList ==> ',{selectedFieldList});
    //         component.set("v.isBOMmodalOpen", false); 
    //         component.set("v.displayGrouping", true);

    //         component.set("v.groupFieldList", selectedFieldList);
    //         helper.getQuoteGrouping(component, event, helper);

    //     }

    // },
    getQuoteGrouping : function(component, event, helper) {
        console.log('*** getQuoteGrouping Method ***');
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var page = component.get("v.page") || 1
        var groupFieldList = component.get("v.groupFieldList");
        console.log({groupFieldList});
        if (groupFieldList[3] != undefined) {
            component.set("v.forthGrouping", true);
        } else if (groupFieldList[2] != undefined) {
            component.set("v.thirdGrouping", true);
        } else if (groupFieldList[1] != undefined) {
            component.set("v.secondGrouping", true);
        } else if(groupFieldList[0] != undefined){
            component.set("v.firstGrouping", true);
        }
        var action = component.get("c.getQuoteData");
        action.setParams({
            quoteId: component.get("v.recordId"),
            pageNumber: page,   // It's for future use, currnetly it's not in used
            recordToDisply: 50, // It's for future use, currnetly it's not in used
            groupingList: groupFieldList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('getting result ', response.getReturnValue());
                var quoteLineWrapper = response.getReturnValue();
                var quoteLineList = quoteLineWrapper.quoteLineList;
                component.set("v.totalColumn", quoteLineWrapper.columns.length);
                if (quoteLineList.length > 0) {
                    component.set("v.TotalRecordCount", quoteLineList.length);
                    var columns = quoteLineWrapper.columns;
                    quoteLineList.forEach(element => {
                        var quoteLineFieldData = []
                        columns.forEach(ele => {
                            if (ele.type == 'currency' && element[ele.fieldName] == undefined) {
                                element[ele.fieldName] = 0;
                            }
                            var fieldData = {fieldName: ele.fieldName, fieldType: ele.type, fieldValue: element[ele.fieldName]};
                            quoteLineFieldData.push(fieldData);
                        });
                        element.FieldDataList = quoteLineFieldData;
                        if (element.buildertek__Build_Phase__c != undefined) {
                            element.buildertek__Build_Phase__c = element.buildertek__Build_Phase__r.Name;
                        }
                        if (element.buildertek__Sub_Group__c != undefined) {
                            element.buildertek__Sub_Group__c = element.buildertek__Sub_Group__r.Name;
                        }
                        if (element.buildertek__Grouping__c != undefined) {
                            element.buildertek__Grouping__c = element.buildertek__Grouping__r.Name;
                        }
                    });
                    var group1Wrapper = [];
                    var group1Value = quoteLineList[0][groupFieldList[0]];
                    var quoteLines1 = [];
                    let totalObj = {};
                    columns.forEach(ele => {
                        totalObj[ele.fieldName] = 0;
                    });
                    quoteLineList.forEach((element, index) => {
                        if (group1Value == element[groupFieldList[0]]) {
                            totalObj = helper.countTotal(component, helper, totalObj, element);
                            quoteLines1.push(element);
                            if (quoteLineList.length == index+1) {
                                if (groupFieldList[1] != undefined) {
                                    quoteLines1 = helper.addSecondGrouping(component, helper, quoteLines1, groupFieldList, columns);
                                }
                                totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                                var wrapperData = {groupIndex: group1Wrapper.length+1, groupName : group1Value, quoteLineList: quoteLines1, fieldTotals: totalObj};
                                group1Wrapper.push(wrapperData);
                            }
                        } else{
                            if (groupFieldList[1] != undefined){
                                quoteLines1 = helper.addSecondGrouping(component, helper, quoteLines1, groupFieldList, columns);
                            }
                            totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                            var wrapperData = {groupIndex: group1Wrapper.length+1, groupName : group1Value, quoteLineList: quoteLines1, fieldTotals: totalObj};
                            group1Wrapper.push(wrapperData);

                            totalObj = {};
                            columns.forEach(ele => {
                                totalObj[ele.fieldName] = 0;
                            });
                            totalObj = helper.countTotal(component, helper, totalObj, element);

                            quoteLines1 = [];
                            group1Value = element[groupFieldList[0]];
                            quoteLines1.push(element);

                            if (quoteLineList.length == index+1) {
                                if (groupFieldList[1] != undefined) {
                                    quoteLines1 = helper.addSecondGrouping(component, helper, quoteLines1, groupFieldList, columns);
                                }
                                totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                                var wrapperData = {groupIndex: group1Wrapper.length+1, groupName : group1Value, quoteLineList: quoteLines1, fieldTotals: totalObj};
                                group1Wrapper.push(wrapperData);
                            }
                        }
                    });
                    quoteLineWrapper.groupWrapper = group1Wrapper;
                    console.log('*** Quote Wrapper Data ***');
                    console.log('Quote Wrapper Data => ',{ quoteLineWrapper });
                    component.set("v.QuoteLineWrapper", quoteLineWrapper);
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }
            } else{
                var error = response.getError();
                console.log('Error => ',{error});
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
            }                
        });
        $A.enqueueAction(action);
    }, 
    addSecondGrouping : function(component, helper, quoteLines1, groupFieldList, columns){
        var group2Wrapper = [];
        if (quoteLines1.length > 0) {
            var group2Value = quoteLines1[0][groupFieldList[1]];
            var quoteLines2 = [];
            let totalObj = {};
            columns.forEach(ele => {
                totalObj[ele.fieldName] = 0;
            });
            quoteLines1.forEach((element, index) => {
                if (group2Value == element[groupFieldList[1]]){
                    totalObj = helper.countTotal(component, helper, totalObj, element);
                    quoteLines2.push(element);
                    if (quoteLines1.length == index+1){
                        if (groupFieldList[2] != undefined) {
                            quoteLines2 = helper.addThirdGrouping(component, helper, quoteLines2, groupFieldList, columns);
                        }
                        totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                        var wrapperData = {groupIndex: group2Wrapper.length+1, groupName : group2Value, quoteLineList: quoteLines2, fieldTotals: totalObj};
                        group2Wrapper.push(wrapperData);
                    }
                } else{
                    if (groupFieldList[2] != undefined) {
                        quoteLines2 = helper.addThirdGrouping(component, helper, quoteLines2, groupFieldList, columns);
                    }
                    totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                    var wrapperData = {groupIndex: group2Wrapper.length+1, groupName : group2Value, quoteLineList: quoteLines2, fieldTotals: totalObj};
                    group2Wrapper.push(wrapperData);

                    totalObj = {};
                    columns.forEach(ele => {
                        totalObj[ele.fieldName] = 0;
                    });
                    totalObj = helper.countTotal(component, helper, totalObj, element);

                    quoteLines2 = [];
                    group2Value = element[groupFieldList[1]];
                    quoteLines2.push(element);

                    if (quoteLines1.length == index+1){
                        if (groupFieldList[2] != undefined) {
                            quoteLines2 = helper.addThirdGrouping(component, helper, quoteLines2, groupFieldList, columns);
                        }
                        totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                        var wrapperData = {groupIndex: group2Wrapper.length+1, groupName : group2Value, quoteLineList: quoteLines2, fieldTotals: totalObj};
                        group2Wrapper.push(wrapperData);
                    }
                }
            });
            return group2Wrapper;
        }
    },

    addThirdGrouping : function(component, helper, quoteLines2, groupFieldList, columns){
        var group3Wrapper = [];
        if (quoteLines2.length > 0) {
            var group3Value = quoteLines2[0][groupFieldList[2]];
            var quoteLines3 = [];
            let totalObj = {};
            columns.forEach(ele => {
                totalObj[ele.fieldName] = 0;
            });
            quoteLines2.forEach((element, index) => {
                if (group3Value == element[groupFieldList[2]]){
                    totalObj = helper.countTotal(component, helper, totalObj, element);
                    quoteLines3.push(element);
                    if (quoteLines2.length == index+1){
                        if (groupFieldList[3] != undefined) {
                            quoteLines3 = helper.addFourthGrouping(component, helper, quoteLines3, groupFieldList, columns);
                        }
                        totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                        var wrapperData = {groupIndex: group3Wrapper.length+1, groupName : group3Value, quoteLineList: quoteLines3, fieldTotals: totalObj};
                        group3Wrapper.push(wrapperData);
                    }
                } else{
                    if (groupFieldList[3] != undefined) {
                        quoteLines3 = helper.addFourthGrouping(component, helper, quoteLines3, groupFieldList, columns);
                    }
                    totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                    var wrapperData = {groupIndex: group3Wrapper.length+1, groupName : group3Value, quoteLineList: quoteLines3, fieldTotals: totalObj};
                    group3Wrapper.push(wrapperData);

                    totalObj = {};
                    columns.forEach(ele => {
                        totalObj[ele.fieldName] = 0;
                    });
                    totalObj = helper.countTotal(component, helper, totalObj, element);

                    quoteLines3 = [];
                    group3Value = element[groupFieldList[2]]
                    quoteLines3.push(element);

                    if (quoteLines2.length == index+1){
                        if (groupFieldList[3] != undefined) {
                            quoteLines3 = helper.addFourthGrouping(component, helper, quoteLines3, groupFieldList, columns);
                        }
                        totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                        var wrapperData = {groupIndex: group3Wrapper.length+1, groupName : group3Value, quoteLineList: quoteLines3, fieldTotals: totalObj};
                        group3Wrapper.push(wrapperData);
                    }
                }
            });
            return group3Wrapper;
        }
    }, 

    addFourthGrouping : function(component, helper, quoteLines3, groupFieldList, columns){
        var group4Wrapper = [];
        if (quoteLines3.length > 0) {
            var group4Value = quoteLines3[0][groupFieldList[3]];
            var quoteLines4 = [];
            let totalObj = {};
            columns.forEach(ele => {
                totalObj[ele.fieldName] = 0;
            });
            quoteLines3.forEach((element, index) => {
                if (group4Value == element[groupFieldList[3]]){
                    totalObj = helper.countTotal(component, helper, totalObj, element);
                    quoteLines4.push(element);
                    if (quoteLines3.length == index+1){
                        totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                        var wrapperData = {groupIndex: group4Wrapper.length+1, groupName : group4Value, quoteLineList: quoteLines4, fieldTotals: totalObj};
                        group4Wrapper.push(wrapperData);
                    }
                } else{
                    totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                    var wrapperData = {groupIndex: group4Wrapper.length+1, groupName : group4Value, quoteLineList: quoteLines4, fieldTotals: totalObj};
                    group4Wrapper.push(wrapperData);

                    totalObj = {};
                    columns.forEach(ele => {
                        totalObj[ele.fieldName] = 0;
                    });
                    totalObj = helper.countTotal(component, helper, totalObj, element);

                    quoteLines4 = [];
                    group4Value = element[groupFieldList[3]];
                    quoteLines4.push(element);

                    if (quoteLines3.length == index+1){
                        totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                        var wrapperData = {groupIndex: group4Wrapper.length+1, groupName : group4Value, quoteLineList: quoteLines4, fieldTotals: totalObj};
                        group4Wrapper.push(wrapperData);
                    }
                }
            });
            return group4Wrapper;
        }
    }, 

    countTotal : function(component, helper, totalObj, element){
        console.log('element', element)
        element.FieldDataList.forEach(ele => {
            if (ele.fieldType == 'currency') {
                totalObj[ele.fieldName] += Number(ele.fieldValue);
            }
        });
        return totalObj;
    }, 

    createTotalWrapper : function(component, helper, totalObj, columns){
        var quoteLineTotalData = [];
        columns.forEach(ele => {
            let fieldData;
            if (ele.type == 'currency') {
                fieldData = {fieldName: ele.fieldName, fieldType: ele.type, fieldValue: totalObj[ele.fieldName]};
            } else if(ele.fieldName == 'Name'){
                fieldData = {fieldName: 'Total', fieldType: ele.type, fieldValue: totalObj[ele.fieldName]};
            }else{
                fieldData = {fieldName: ele.fieldName, fieldType: ele.type, fieldValue: ''};
            }
            quoteLineTotalData.push(fieldData);
        });
        totalObj['fieldTotalList'] = quoteLineTotalData;
        return totalObj;
    }, 

    expandRecordsHelper : function(component, event, helper, spanGroupId){
        let recordDivList = document.getElementsByClassName('record_'+spanGroupId);
        let collapeallIcon = document.getElementById("collapeseGroupBtn_" + spanGroupId);
        let expandallIcon = document.getElementById("expandGroupBtn_" + spanGroupId);

        collapeallIcon.style.display = 'block';
        expandallIcon.style.display = 'none';
        for(let index = 0; index < recordDivList.length; index++) {
            recordDivList[index].style.display = 'table-row';
        }
    }, 

    collapeRecordsHelper : function(component, event, helper, spanGroupId){
        let recordDivList = document.getElementsByClassName('record_'+spanGroupId);
        let collapeallIcon = document.getElementById("collapeseGroupBtn_" + spanGroupId);
        let expandallIcon = document.getElementById("expandGroupBtn_" + spanGroupId);
        
        collapeallIcon.style.display = 'none';
        expandallIcon.style.display = 'block';
        for(let index = 0; index < recordDivList.length; index++) {
            recordDivList[index].style.display = 'none';
        }
    },
    updateSelectedRecords: function(component, event, helper) {
        var tempSelected = JSON.parse(JSON.stringify(component.get('v.selectedRows')));
        component.get('v.data1').forEach(function(row) {
            if (tempSelected[row.Id]) {
                tempSelected[row.Id] = true;
            }
        });
        component.set('v.selectedRows', tempSelected);

        console.log(component.get('v.selectedRows') + '>>>>>>>');
    },
})