({
    getcurr: function (component, event, helper) {
        var action = component.get("c.getcurrency");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currencycode", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    getmulticur: function (component, event, helper) {
        var action = component.get("c.getmulticurrency");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.multicurrency", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
    },
    createForceRecordEditComp: function (
        component,
        event,
        helper,
        recordId,
        action,
        title,
        objAPI,
        obj
    ) {
        $A.createComponent(
            "c:BT_Force_Record_Edit", {
            "aura:id": "btNewItemEdit",
            title: title,
            objectApi: objAPI,
            parentId: component.get("v.recordId"),
            parentApi: "buildertek__Budget__c",
            newRecordName: "Budget Item",
            saveCallBack: component.get("v.refreshGridAction"),
            newRecordId: recordId,
            defaultValue: obj,
            action: action,
        },
            function (grid) {
                if (component.isValid()) {
                    var targetCmp = component.find("newItem");
                    var body = targetCmp.get("v.body");
                    body.push(grid);
                    targetCmp.set("v.body", body);
                }
            }
        );
    },
    /* helperFun : function(component,event,secId) {
       var acc = component.find(secId);
             for(var cmp in acc) {
             //$A.util.toggleClass(acc[cmp], 'slds-show');  
             $A.util.toggleClass(acc[cmp], 'slds-hide');  
        }
     },*/

    getBudgetLine: function (component, event, helper) {
        var action;
        action = component.get("c.getBudgetLineRecords");
        action.setParams({
            selectedBudgetId: component.get('v.expensebudget').toString()
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {

                var result = JSON.parse(response.getReturnValue());
                // alert( JSON.stringify(result));
                component.set('v.budgetLineItems', result);
            }
        });
        $A.enqueueAction(action);
    },

    createRFQ: function (component, event, helper) {
        var action;
        action = component.get("c.createRFQFromBudget");
        action.setParams({
            budget: component.get("v.sampleNewRecord"),
            rfq: component.get("v.newRFQ"),
            rfqItemsJson: JSON.stringify(component.get("v.newRFQItems")),
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                component.find("notifLib").showNotice({
                    variant: "success",
                    header: "RFQ has been created!",
                    message: "RFQ created",
                    closeCallback: function () { },
                });
            } else {
                component.find("notifLib").showNotice({
                    variant: "error",
                    header: "Error!",
                    message: response.getError()[0].message,
                    closeCallback: function () { },
                });
            }
        });

        $A.enqueueAction(action);
    },

    showToast : function(component, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": title,
            "message": message,
            "type": type,
            "duration": 3000
        });
        toastEvent.fire();
    },

    addSelectedProducts: function (component, event, helper, items) {
        var action;
        action = component.get("c.createBudgetItem");
        action.setParams({
            budgetItemsJSON: JSON.stringify(items),
        });
        action.setCallback(this, function (response) {
            if (component.isValid() && response.getState() === "SUCCESS") {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    title: "",
                    message: "Product Added succesfully.",
                    type: "success",
                });
                toastEvent.fire();
                component.refreshData();
            } else {
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: "error",
                    title: "Error!",
                    message: response.getError()[0].message,
                });
                toastEvent.fire();
            }
        });

        $A.enqueueAction(action);
    },

    getProductDetails: function (component, event, helper) {

        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        var pribooknames = component.get("v.pricebookName");
        /* if(productName.length > 80){
             alert("1");
                component.set("v.Spinner", false);
                component.set("v.isDescription", true);
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    message: 'please assign RFQ items size is lessthan 80.',
                    duration:' 5000',
                    key: 'info_alt',
                    type: 'error',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                //component.get("v.onCancel")(); 
                //$A.get('e.force:refreshView').fire();
                 }else{
                component.set("v.isDescription", false); 
            }
             
             if(component.get("v.isDescription") == false){*/
        var action = component.get("c.getProductPrice");

        action.setParams({
            productId: productId,
            pricebookId: pribooknames
        });
        action.setCallback(this, function (respo) {
            var res = respo.getReturnValue();
            console.log('Product List ==>',res);
            var getProductDetails = component.get("v.newBudgetLine");
            delete getProductDetails.buildertek__Group__r;
            ////console.log("@Budgetline@",component.get("v.recordId"));
            getProductDetails.buildertek__Budget__c = component.get("v.recordId");
            ////console.log("getprodct----",JSON.stringify(getProductDetails));
            if (res.length >= 1) {
                if (res[0].UnitPrice != null) {
                    getProductDetails.buildertek__Sales_Price__c = res[0].UnitPrice;
                }
                if (res[0].buildertek__Unit_Cost__c != null) {
                    getProductDetails.buildertek__Unit_Price__c =
                        res[0].buildertek__Unit_Cost__c;
                    }else{
                    getProductDetails.buildertek__Unit_Price__c =
                        res[0].UnitPrice;
                }

                if (res[0].buildertek__Discount__c != null) {
                    getProductDetails.buildertek__Discount__c =
                        res[0].buildertek__Discount__c;
                }

                if (res[0].Product2.buildertek__Cost_Code__c != null) {
                    getProductDetails.buildertek__Cost_Code__c =
                        res[0].Product2.buildertek__Cost_Code__c;
                }
            } else {
                getProductDetails.buildertek__Unit_Cost__c = 0;
                getProductDetails.buildertek__Unit_Price__c = 0;
                getProductDetails.buildertek__Discount__c = 0;
            }
            getProductDetails.buildertek__Product__c = productId;

            getProductDetails.Name = productName;
            component.set("v.newBudgetLine", getProductDetails);

            ////console.log("getprodct----",JSON.stringify(getProductDetails));

            ////console.log("----log",res);
        });
        $A.enqueueAction(action);

    },

    deleteRecord: function (component, event, helper) {
        var deleteString = component.get("v.deleteRecords");
        //alert('deleteString ----------> '+JSON.stringify(deleteString));
        var action = component.get("c.deleteLineItems");
        action.setParams({
            budgetItemIds: deleteString,
        });
        action.setCallback(this, function (response) {
            component.set("v.selectedRows", []);
            component.set("v.selectedCol", []);
            $A.get("e.force:refreshView").fire();
            var grid = component.find("ItemList");
            grid.refreshData();
            component.refreshData();
        });
        $A.enqueueAction(action);
    },

    getBudgetGroups: function (component, event, helper, page , showToast) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            action: "SHOW",
        }).fire();
        var budgetIdele = component.get("v.budgetId");
        var toggleVal = component.get("v.groupBytoggle");
        var toggleVal1 = component.get("v.groupBytoggle1");
        var toggleVal2 = component.get("v.groupBytoggle2");
        var bt1 = component.get("v.Isbtvalue");


        console.log('budgetIdele => ' + budgetIdele);
        console.log('toggleVal => ' + toggleVal);
        console.log('toggleVal1 => ' + toggleVal1);
        console.log('toggleVal2 => ' + toggleVal2);
        console.log('bt1 => ' + bt1);

        if (budgetIdele) {


            if (component.find('expandCollapeseAllBtn')) {


                if (component.find('expandCollapeseAllBtn').get('v.iconName')) {
                    var budgetIdele = component.get("v.budgetId");
                    // alert(budgetIdele);
                    var tabId = component.get("v.currentTab")
                    if (tabId) {
                        var spanEle = document.getElementsByClassName(tabId + ' expandAllBtn_' + budgetIdele);
                        // alert(spanEle);
                        if (spanEle[0]) {
                            // alert("6");
                            spanEle[0].style.display = "none";
                        }
                        if (document.getElementsByClassName(tabId + ' CollapeseAllBtn_' + budgetIdele)[0]) {
                            // alert("8");
                            document.getElementsByClassName(tabId + ' CollapeseAllBtn_' + budgetIdele)[0].style.display = "inline-block";
                        }
                    } else {
                        var spanEle = document.getElementsByClassName(' expandAllBtn_' + budgetIdele);
                        // alert(spanEle);
                        if (spanEle[0]) {
                            //alert("7");
                            spanEle[0].style.display = "inline-block";
                        }
                        if (document.getElementsByClassName(' CollapeseAllBtn_' + budgetIdele)[0]) {
                            document.getElementsByClassName(' CollapeseAllBtn_' + budgetIdele)[0].style.display = "none";
                        }
                    }

                    // console.log(spanEle[0])
                    component.find('expandCollapeseAllBtn').set("v.title", "Expand All");
                    component.find('expandCollapeseAllBtn').set("v.iconName", "utility:add");
                }
            }
        }


        // var actionTest = component.get("c.retrieveGroups");
        // actionTest.setParams({
        //     budgetId: component.get("v.recordId"),
        //     pageNumber: page,
        //     recordToDisply: 60,
        // });
        // actionTest.setCallback(this, function (response) {
        //     console.log('##############################');
        //     var result = response.getReturnValue();
        //     console.log('result ==> ', { result });
        //     console.log('##############################');
        // });
        // $A.enqueueAction(actionTest);



        if (component.get("v.recordId")) {
            // Retrieve all the section of related Ad
            var action = component.get("c.retrieveGroups");
            action.setParams({
                budgetId: component.get("v.recordId"),
                pageNumber: page,
                recordToDisply: 60,
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var originalResult = response.getReturnValue();
                    console.log('originalResult ==> ',{originalResult});
                    var result = response.getReturnValue();
                    //  alert('result---------->'+JSON.stringify(result));
                    if (result.formulaFields != undefined) {
                        var formulaField = JSON.parse(result.formulaFields);
                        for (var i in result.columns) {
                            for (var j in formulaField) {
                                if (j.toLowerCase() == result.columns[i].fieldName.toLowerCase()) {
                                    result.columns[i].title = formulaField[j];
                                }
                            }
                        }
                        if (toggleVal) {
                            if (result.tarTable != undefined && result.tarTable.ListOfEachRecord != undefined) {
                                var records = result.tarTable.ListOfEachRecord;
                                result.groupHierarchy = Object.values(groupRecords(records)).sort((a, b) => a.groupName.localeCompare(b.groupName));
                                function groupRecords(data) {
                                    var listOfRecords = [];
                                    let recordsMap = new Map();
                                    for (var i in data) {
                                        for (var j in data[i].recordList) {
                                            if (data[i].recordList[j].fieldName == 'buildertek__Contractor__c' && data[i].recordList[j].originalValue != '') {
                                                if (!recordsMap.has(data[i].recordList[j].originalValue + '(#&%*)' + data[i].recordList[j].referenceValue)) {
                                                    recordsMap.set(data[i].recordList[j].originalValue + '(#&%*)' + data[i].recordList[j].referenceValue, []);
                                                }
                                                recordsMap.get(data[i].recordList[j].originalValue + '(#&%*)' + data[i].recordList[j].referenceValue).push(JSON.parse(JSON.stringify(data[i])));
                                            } else if (data[i].recordList[j].fieldName == 'buildertek__Contractor__c' && data[i].recordList[j].originalValue == '') {
                                                data[i].recordList[j].originalValue = 'No Vendor';

                                                if (!recordsMap.has('' + '(#&%*)' + 'No Vendor')) {
                                                    recordsMap.set('' + '(#&%*)' + 'No Vendor', []);
                                                }
                                                //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                                                recordsMap.get('' + '(#&%*)' + 'No Vendor').push(JSON.parse(JSON.stringify(data[i])))
                                                //recordsMap.get('No Vendor').push(JSON.parse(JSON.stringify(data[i])));
                                            }
                                        }
                                    }
                                    var result = Array.from(recordsMap.entries());

                                    for (var i in result) {
                                        var obj = {};
                                        obj.groupId = result[i][0].split('(#&%*)')[0];
                                        obj.groupName = result[i][0].split('(#&%*)')[1];
                                        //ert('hi'+obj.groupName);
                                        obj.subGroupRecords = subGroupRecords(result[i][1]);
                                        listOfRecords.push(obj);

                                    }
                                    // alert('listOfRecords',listOfRecords)
                                    console.log('listOfRecords => ', { listOfRecords });
                                    listOfRecords = helper.countFunction(component, listOfRecords);

                                    return listOfRecords;
                                    // alert(listOfRecords);
                                }
                                function subGroupRecords(data) {
                                    var listOfRecords = [];
                                    var recordValue = [];
                                    let recordsMap = new Map();
                                    for (var i in data) {
                                        for (var j in data[i].recordList) {
                                            // console.log('data[i].recordList[j]',data[i].recordList);
                                            /*if(data[i].recordList[j].fieldName == 'buildertek__Contractor__c' && data[i].recordList[j].originalValue == ''){
                                                data[i].recordList[j].originalValue = 'No Vendor';
                                              
                                                if (!recordsMap.has('' + '(#&%*)' + 'No Vendor')) {
                                                    recordsMap.set('' + '(#&%*)' + 'No Vendor', []);
                                                }
                                                //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                                                recordsMap.get('' + '(#&%*)' + 'No Vendor').push(JSON.parse(JSON.stringify(data[i])))
                                                //recordsMap.get('No Vendor').push(JSON.parse(JSON.stringify(data[i])));
                                            }*/
                                            if (data[i].recordList[j].fieldName == 'buildertek__Contractor__c' && data[i].recordList[j].originalValue != '') {
                                                //  console.log('data[i].recordList[j].fieldName',data[i].recordList[j].fieldName);
                                                // console.log('data[i].recordList[j].originalValue',data[i].recordList[j].originalValue);
                                                if (!recordsMap.has(data[i].recordList[j].originalValue + '(#&%*)' + data[i].recordList[j].referenceValue)) {
                                                    recordsMap.set(data[i].recordList[j].originalValue + '(#&%*)' + data[i].recordList[j].referenceValue, []);
                                                }
                                                recordsMap.get(data[i].recordList[j].originalValue + '(#&%*)' + data[i].recordList[j].referenceValue).push(JSON.parse(JSON.stringify(data[i])));

                                            }
                                        }
                                    }

                                    var result = Array.from(recordsMap.entries());
                                    for (var i in result) {
                                        var obj = {};
                                        var recordValue = [];
                                        obj.recordValue = [];
                                        var sumCol = 0;
                                        obj.subGroupId = result[i][0].split('(#&%*)')[0];
                                        obj.subGroupName = result[i][0].split('(#&%*)')[1] == undefined ? 'No Grouping' : result[i][0].split('(#&%*)')[1];
                                        obj.records = result[i][1];
                                        if (obj.subGroupName != 'No Grouping') {
                                            for (var j in obj.records) {
                                                // console.log(obj.records[j].recordValue);
                                                recordValue.push(obj.records[j].recordValue);
                                            }
                                            var row = recordValue.length;
                                            var col = recordValue[0].length;
                                            for (var j = 0; j < col; j++) {
                                                sumCol = 0;
                                                for (var k = 0; k < row; k++) {
                                                    // console.log(recordValue[k][j])
                                                    sumCol += recordValue[k][j];
                                                }
                                                j == 0 ?
                                                    obj.recordValue.push(sumCol) :
                                                    obj.recordValue.push(new Intl.NumberFormat('en-US', {
                                                        style: 'currency',
                                                        currency: 'USD'
                                                    }).format(sumCol));
                                            }
                                        }
                                        listOfRecords.push(obj);
                                    }

                                    //  console.log('listOfRecords',listOfRecords);
                                    return listOfRecords;

                                }

                            }

                        }
                        else {
                            if (bt1 == true) {
                                if (toggleVal2) {
                                    if (result.tarTable != undefined && result.tarTable.ListOfEachRecord != undefined) {
                                        var records = result.tarTable.ListOfEachRecord;
                                        result.groupHierarchy = Object.values(groupRecords(records));
                                        // result.groupHierarchy = Object.values(groupRecords(records)).sort((a, b) => a.groupName.localeCompare(b.groupName));
                                        console.log("Group Name By ASC" , result.groupHierarchy);
                                        // alert(JSON.stringify(records)); 
                                        function groupRecords(data) {
                                            var listOfRecords = [];
                                            let recordsMap = new Map();
                                            for (var i in data) {
                                                //// alert(!recordsMap.has(data[i].groupId + '(#&%*)' + data[i].groupName));
                                                // if (data[i].groupId != undefined && data[i].groupName != undefined) {
                                                //     if (!recordsMap.has(data[i].groupId + '(#&%*)' + data[i].groupName)) {
                                                //         recordsMap.set(data[i].groupId + '(#&%*)' + data[i].groupName, []);
                                                //     }
                                                //     recordsMap.get(data[i].groupId + '(#&%*)' + data[i].groupName).push(JSON.parse(JSON.stringify(data[i])));
                                                // } else if (data[i].groupId == undefined && data[i].groupName == undefined) {
                                                //     data[i].groupName = 'No Grouping';
                                                // }
                                                if (data[i].groupId == undefined && data[i].groupName == undefined || data[i].groupId == '' && data[i].groupName == '') {
                                                    data[i].groupName = 'No Grouping';
                                                }
                                                if (!recordsMap.has(data[i].groupId + '(#&%*)' + data[i].groupName)) {
                                                    recordsMap.set(data[i].groupId + '(#&%*)' + data[i].groupName, []);
                                                }
                                                recordsMap.get(data[i].groupId + '(#&%*)' + data[i].groupName).push(JSON.parse(JSON.stringify(data[i])));
                                            }
                                            var result = Array.from(recordsMap.entries());
                                            for (var i in result) {
                                                var obj = {};
                                                obj.groupId = result[i][0].split('(#&%*)')[0];
                                                obj.groupName = result[i][0].split('(#&%*)')[1];
                                                //alert('group id'+obj.groupId);
                                                // alert('result'+ JSON.stringify(result[i][1]));
                                                // alert( 'gropu name'+obj.groupName);
                                                obj.subGroupRecords = subGroupRecords(result[i][1]);
                                                // alert( JSON.stringify(obj.subGroupRecords));
                                                listOfRecords.push(obj);

                                            }
                                            return listOfRecords;
                                        }

                                        function subGroupRecords(data) {
                                            var listOfRecords = [];
                                            var recordValue = [];
                                            let recordsMap = new Map();
                                            for (var i in data) {
                                                if (!recordsMap.has(data[i].subGroupId != undefined ? data[i].subGroupId + '(#&%*)' + data[i].subGroupName : 'No Grouping')) {
                                                    recordsMap.set(data[i].subGroupId != undefined ? data[i].subGroupId + '(#&%*)' + data[i].subGroupName : 'No Grouping', []);
                                                }
                                                recordsMap.get(data[i].subGroupId != undefined ? data[i].subGroupId + '(#&%*)' + data[i].subGroupName : 'No Grouping').push(JSON.parse(JSON.stringify(data[i])));
                                            }

                                            var result = Array.from(recordsMap.entries());
                                            for (var i in result) {
                                                var obj = {};
                                                var recordValue = [];
                                                obj.recordValue = [];
                                                var sumCol = 0;
                                                obj.subGroupId = result[i][0].split('(#&%*)')[0];
                                                obj.subGroupName = result[i][0].split('(#&%*)')[1] == undefined ? 'No Grouping' : result[i][0].split('(#&%*)')[1];
                                                obj.records = result[i][1];
                                                if (obj.subGroupName != 'No Grouping') {
                                                    for (var j in obj.records) {
                                                        // console.log(obj.records[j].recordValue);
                                                        recordValue.push(obj.records[j].recordValue);
                                                    }
                                                    var row = recordValue.length;
                                                    var col = recordValue[0].length;
                                                    for (var j = 0; j < col; j++) {
                                                        sumCol = 0;
                                                        for (var k = 0; k < row; k++) {
                                                            // console.log(recordValue[k][j])
                                                            sumCol += recordValue[k][j];
                                                        }
                                                        j == 0 ?
                                                            obj.recordValue.push(sumCol) :
                                                            obj.recordValue.push(new Intl.NumberFormat('en-US', {
                                                                style: 'currency',
                                                                currency: 'USD'
                                                            }).format(sumCol));
                                                    }
                                                }
                                                listOfRecords.push(obj);
                                            }
                                            return listOfRecords;
                                        }
                                    }
                                    var records = []
                                    var recordsList = [];
                                    var recordsMap = {};
                                    var subGroupRecordsMap = {};
                                    var subGroupRecords = [];
            
                                    result.groupHierarchy.forEach(element => {
                                        records = [];
                                        subGroupRecordsMap = {};
                                        subGroupRecords = [];
                        
                                        var totalObj = {};
                        
                                        totalObj['unitPrice'] = 0;
                                        totalObj['unitPricekey'] = '';
                                        totalObj['orignalbudget'] = 0;
                                        totalObj['orignalbudgetkey'] = '';
                                        totalObj['totalSalesPrice'] = 0;
                                        totalObj['totalSalesPricekey'] = '';
                                        totalObj['TotalApprovals'] = 0;
                                        totalObj['TotalApprovalskey'] = '';
                                        totalObj['TotalC0'] = 0;
                                        totalObj['TotalCOkey'] = '';    
                                        totalObj['CommittedCost'] = 0;
                                        totalObj['CommittedCostkey'] = 0;
                                        totalObj['AdditionalCosts'] = 0;
                                        totalObj['AdditionalCostsKey'] = '';
                                        totalObj['InvoiceCosts'] = 0;
                                        totalObj['InvoiceCostsKey'] = '';
                                        totalObj['ProjectedCosts'] = 0;
                                        totalObj['ProjectedCostskey'] = '';
                                        totalObj['Labor1'] = 0;
                                        totalObj['Labor1key'] = '';
                                        totalObj['Forecast'] = 0;
                                        totalObj['Forecastskey'] = '';
                                        totalObj['TotalCosts'] = 0;
                                        totalObj['TotalCostsKey'] = '';
                                        totalObj['ProfitLoss'] = 0;
                                        totalObj['ProfitLosskey'] = '';
                                        totalObj['fieldType'] = '';

                                        totalObj['unitSalesPrice'] = 0;
                                        totalObj['unitSalesPricekey'] = '';
                                        totalObj['grossMargin'] = 0;
                                        totalObj['grossMarginKey'] = '';
                                        totalObj['labor'] = 0;
                                        totalObj['laborKey'] = '';
                                        totalObj['material'] = 0;
                                        totalObj['materialKey'] = '';
                                        totalObj['laborBudget'] = 0;
                                        totalObj['laborBudgetKey'] = '';
                                        totalObj['subcontractor'] = 0;
                                        totalObj['subcontractorKey'] = '';
                                        totalObj['equipment'] = 0;
                                        totalObj['equipmentKey'] = '';
                                        totalObj['misc'] = 0;
                                        totalObj['miscKey'] = '';
                                        

                                    

                                                                
                        
                        
                                        result.tarTable.records.forEach((ele, index) => {
                                            if (element['groupId'] == ele.buildertek__Group__c) {
                                                recordsMap = {};
                                                recordsList = (result.tarTable.ListOfEachRecord[index].recordList);
                                                recordsMap['groupId'] = element['groupId'];
                                                recordsMap['groupName'] = element['groupName'];
                                                recordsMap['recordId'] = ele.Id;
                                                recordsMap['recordName'] = ele.Name;
                                                recordsMap['recordList'] = recordsList;
                                                records.push(recordsMap);
                        
                                                totalObj = helper.setTotalHelper(recordsList, totalObj);
                                            }else if(element['groupId'] == 'undefined'){
                                                recordsMap = {};
                                                recordsList = (result.tarTable.ListOfEachRecord[index].recordList);
                                                recordsMap['groupId'] = 'undefined';
                                                recordsMap['groupName'] = 'No Grouping';
                                                recordsMap['recordId'] = ele.Id;
                                                recordsMap['recordName'] = ele.Name;
                                                recordsMap['recordList'] = recordsList;
                                                records.push(recordsMap);
                        
                                                totalObj = helper.setTotalHelper(recordsList, totalObj);

                                            }
                                        });
                                        element['totals'] = totalObj;
                                        subGroupRecordsMap['records'] = records;
                                        subGroupRecords.push(subGroupRecordsMap);
                                        element['subGroupRecords'] = subGroupRecords;
                                    });
                                }
                            }
                            if (bt1 == false) {
                                if (toggleVal1) {
                                    if (result.tarTable != undefined && result.tarTable.ListOfEachRecord != undefined) {
                                        var records = result.tarTable.ListOfEachRecord;
                                        result.groupHierarchy = Object.values(groupRecords(records)).sort((a, b) => a.groupName.localeCompare(b.groupName));
                                        // alert(JSON.stringify(records)); 
                                        function groupRecords(data) {
                                            var listOfRecords = [];
                                            let recordsMap = new Map();
                                            for (var i in data) {
                                                if (data[i].groupId != undefined && data[i].groupName != undefined) {
                                                    if (!recordsMap.has(data[i].groupId + '(#&%*)' + data[i].groupName)) {
                                                        recordsMap.set(data[i].groupId + '(#&%*)' + data[i].groupName, []);
                                                    }
                                                    recordsMap.get(data[i].groupId + '(#&%*)' + data[i].groupName).push(JSON.parse(JSON.stringify(data[i])));
                                                } else if (data[i].groupId == undefined && data[i].groupName == undefined) {
                                                    data[i].groupName = 'No Grouping';
                                                }

                                            }

                                            var result = Array.from(recordsMap.entries());
                                            for (var i in result) {
                                                var obj = {};
                                                obj.groupId = result[i][0].split('(#&%*)')[0];
                                                obj.groupName = result[i][0].split('(#&%*)')[1];
                                                obj.subGroupRecords = subGroupRecords(result[i][1]);
                                                listOfRecords.push(obj);

                                            }
                                            return listOfRecords;
                                        }

                                        function subGroupRecords(data) {
                                            var listOfRecords = [];
                                            var recordValue = [];
                                            let recordsMap = new Map();
                                            for (var i in data) {
                                                if (!recordsMap.has(data[i].subGroupId != undefined ? data[i].subGroupId + '(#&%*)' + data[i].subGroupName : 'No Grouping')) {
                                                    recordsMap.set(data[i].subGroupId != undefined ? data[i].subGroupId + '(#&%*)' + data[i].subGroupName : 'No Grouping', []);
                                                }
                                                recordsMap.get(data[i].subGroupId != undefined ? data[i].subGroupId + '(#&%*)' + data[i].subGroupName : 'No Grouping').push(JSON.parse(JSON.stringify(data[i])));
                                            }

                                            var result = Array.from(recordsMap.entries());
                                            for (var i in result) {
                                                var obj = {};
                                                var recordValue = [];
                                                obj.recordValue = [];
                                                var sumCol = 0;
                                                obj.subGroupId = result[i][0].split('(#&%*)')[0];
                                                obj.subGroupName = result[i][0].split('(#&%*)')[1] == undefined ? 'No Grouping' : result[i][0].split('(#&%*)')[1];
                                                obj.records = result[i][1];
                                                if (obj.subGroupName != 'No Grouping') {
                                                    for (var j in obj.records) {
                                                        // console.log(obj.records[j].recordValue);
                                                        recordValue.push(obj.records[j].recordValue);
                                                    }
                                                    var row = recordValue.length;
                                                    var col = recordValue[0].length;
                                                    for (var j = 0; j < col; j++) {
                                                        sumCol = 0;
                                                        for (var k = 0; k < row; k++) {
                                                            // console.log(recordValue[k][j])
                                                            sumCol += recordValue[k][j];
                                                        }
                                                        j == 0 ?
                                                            obj.recordValue.push(sumCol) :
                                                            obj.recordValue.push(new Intl.NumberFormat('en-US', {
                                                                style: 'currency',
                                                                currency: 'USD'
                                                            }).format(sumCol));
                                                    }
                                                }
                                                listOfRecords.push(obj);
                                            }
                                            return listOfRecords;
                                        }
                                    }
                                }

                            }
                            if (bt1 == true && toggleVal2 == true) {
                                if (toggleVal1) {
                                    if (result.tarTable != undefined && result.tarTable.ListOfEachRecord != undefined) {
                                        console.log('-- Set groupHierarchy --');
                                        var records = result.tarTable.ListOfEachRecord;
                                        result.groupHierarchy = groupRecords(records);
                                        // alert(JSON.stringify(records)); 
                                        function groupRecords(data) {

                                            var listOfRecords = [];
                                            let recordsMap = new Map();
                                            for (var i in data) {
                                                if (data[i].groupId != undefined && data[i].groupName != undefined) {
                                                    if (!recordsMap.has(data[i].groupId + '(#&%*)' + data[i].groupName)) {
                                                        recordsMap.set(data[i].groupId + '(#&%*)' + data[i].groupName, []);
                                                    }
                                                    recordsMap.get(data[i].groupId + '(#&%*)' + data[i].groupName).push(JSON.parse(JSON.stringify(data[i])));
                                                } else if (data[i].groupId == undefined && (data[i].groupName == undefined || data[i].groupName == 'No Grouping')) {
                                                    data[i].groupName = 'No Grouping';
                                                }

                                            }

                                            for (var i in data) {
                                                if (data[i].groupId == undefined && (data[i].groupName == undefined || data[i].groupName == 'No Grouping')) {
                                                    var keyVal = '';
                                                    for (let key of recordsMap.keys()) {
                                                        if(key.includes("No Grouping")){
                                                            keyVal = key; 
                                                        }
                                                    }
                                                    recordsMap.get(keyVal).push(JSON.parse(JSON.stringify(data[i])));
                                                }
                                            }

                                            var result = Array.from(recordsMap.entries());
                                            for (var i in result) {
                                                var obj = {};
                                                obj.groupId = result[i][0].split('(#&%*)')[0];
                                                obj.groupName = result[i][0].split('(#&%*)')[1];
                                                obj.subGroupRecords = subGroupRecords(result[i][1]);
                                                listOfRecords.push(obj);

                                            }

                                            listOfRecords = helper.countFunction(component, listOfRecords);
                                            
                                            return listOfRecords;
                                        }

                                        function subGroupRecords(data) {
                                            var listOfRecords = [];
                                            var recordValue = [];
                                            let recordsMap = new Map();
                                            for (var i in data) {
                                                if (!recordsMap.has(data[i].subGroupId != undefined ? data[i].subGroupId + '(#&%*)' + data[i].subGroupName : 'No Grouping')) {
                                                    recordsMap.set(data[i].subGroupId != undefined ? data[i].subGroupId + '(#&%*)' + data[i].subGroupName : 'No Grouping', []);
                                                }
                                                recordsMap.get(data[i].subGroupId != undefined ? data[i].subGroupId + '(#&%*)' + data[i].subGroupName : 'No Grouping').push(JSON.parse(JSON.stringify(data[i])));
                                            }

                                            var result = Array.from(recordsMap.entries());
                                            for (var i in result) {
                                                var obj = {};
                                                var recordValue = [];
                                                obj.recordValue = [];
                                                var sumCol = 0;
                                                obj.subGroupId = result[i][0].split('(#&%*)')[0];
                                                obj.subGroupName = result[i][0].split('(#&%*)')[1] == undefined ? 'No Grouping' : result[i][0].split('(#&%*)')[1];
                                                obj.records = result[i][1];
                                                if (obj.subGroupName != 'No Grouping') {
                                                    for (var j in obj.records) {
                                                        // console.log(obj.records[j].recordValue);
                                                        recordValue.push(obj.records[j].recordValue);
                                                    }
                                                    var row = recordValue.length;
                                                    var col = recordValue[0].length;
                                                    for (var j = 0; j < col; j++) {
                                                        sumCol = 0;
                                                        for (var k = 0; k < row; k++) {
                                                            // console.log(recordValue[k][j])
                                                            sumCol += recordValue[k][j];
                                                        }
                                                        j == 0 ?
                                                            obj.recordValue.push(sumCol) :
                                                            obj.recordValue.push(new Intl.NumberFormat('en-US', {
                                                                style: 'currency',
                                                                currency: 'USD'
                                                            }).format(sumCol));
                                                    }
                                                }
                                                listOfRecords.push(obj);
                                            }
                                            return listOfRecords;
                                        }
                                    }
                                }
                            }
                            if (bt1 == false && toggleVal2 == false) {

                                if (toggleVal1) {
                                    if (result.tarTable != undefined && result.tarTable.ListOfEachRecord != undefined) {
                                        var records = result.tarTable.ListOfEachRecord;
                                        result.groupHierarchy = groupRecords(records);
                                        // alert(JSON.stringify(records)); 
                                        function groupRecords(data) {
                                            var listOfRecords = [];
                                            let recordsMap = new Map();
                                            for (var i in data) {
                                                if (data[i].groupId != undefined && data[i].groupName != undefined) {
                                                    if (!recordsMap.has(data[i].groupId + '(#&%*)' + data[i].groupName)) {
                                                        recordsMap.set(data[i].groupId + '(#&%*)' + data[i].groupName, []);
                                                    }
                                                    recordsMap.get(data[i].groupId + '(#&%*)' + data[i].groupName).push(JSON.parse(JSON.stringify(data[i])));
                                                } else if (data[i].groupId == undefined && data[i].groupName == undefined) {
                                                    data[i].groupName = 'No Grouping';
                                                }

                                            }
                                            var result = Array.from(recordsMap.entries());
                                            for (var i in result) {
                                                var obj = {};
                                                obj.groupId = result[i][0].split('(#&%*)')[0];
                                                obj.groupName = result[i][0].split('(#&%*)')[1];
                                                obj.subGroupRecords = subGroupRecords(result[i][1]);
                                                listOfRecords.push(obj);

                                            }
                                            return listOfRecords;
                                        }

                                        function subGroupRecords(data) {
                                            var listOfRecords = [];
                                            var recordValue = [];
                                            let recordsMap = new Map();
                                            for (var i in data) {
                                                if (!recordsMap.has(data[i].subGroupId != undefined ? data[i].subGroupId + '(#&%*)' + data[i].subGroupName : 'No Grouping')) {
                                                    recordsMap.set(data[i].subGroupId != undefined ? data[i].subGroupId + '(#&%*)' + data[i].subGroupName : 'No Grouping', []);
                                                }
                                                recordsMap.get(data[i].subGroupId != undefined ? data[i].subGroupId + '(#&%*)' + data[i].subGroupName : 'No Grouping').push(JSON.parse(JSON.stringify(data[i])));
                                            }

                                            var result = Array.from(recordsMap.entries());
                                            for (var i in result) {
                                                var obj = {};
                                                var recordValue = [];
                                                obj.recordValue = [];
                                                var sumCol = 0;
                                                obj.subGroupId = result[i][0].split('(#&%*)')[0];
                                                obj.subGroupName = result[i][0].split('(#&%*)')[1] == undefined ? 'No Grouping' : result[i][0].split('(#&%*)')[1];
                                                obj.records = result[i][1];
                                                if (obj.subGroupName != 'No Grouping') {
                                                    for (var j in obj.records) {
                                                        // console.log(obj.records[j].recordValue);
                                                        recordValue.push(obj.records[j].recordValue);
                                                    }
                                                    var row = recordValue.length;
                                                    var col = recordValue[0].length;
                                                    for (var j = 0; j < col; j++) {
                                                        sumCol = 0;
                                                        for (var k = 0; k < row; k++) {
                                                            // console.log(recordValue[k][j])
                                                            sumCol += recordValue[k][j];
                                                        }
                                                        j == 0 ?
                                                            obj.recordValue.push(sumCol) :
                                                            obj.recordValue.push(new Intl.NumberFormat('en-US', {
                                                                style: 'currency',
                                                                currency: 'USD'
                                                            }).format(sumCol));
                                                    }
                                                }
                                                listOfRecords.push(obj);
                                            }
                                            return listOfRecords;
                                        }
                                    }
                                }
                            }

                            else {
                                if (bt1 == true && toggleVal2 == false) {
                                    if (result.tarTable != undefined && result.tarTable.ListOfEachRecord != undefined) {
                                        var records = result.tarTable.ListOfEachRecord;
                                        result.groupHierarchy = groupRecords(records);
                                        function groupRecords(data) {
                                            var listOfRecords = [];
                                            let recordsMap = new Map();
                                            for (var i in data) {
                                                for (var j in data[i].recordList) {
                                                    if (data[i].recordList[j].fieldName == 'buildertek__CostCodeDivision__c' && data[i].recordList[j].originalValue != '') {

                                                        if (!recordsMap.has(data[i].recordList[j].originalValue + '(#&%*)' + data[i].recordList[j].referenceValue)) {
                                                            recordsMap.set(data[i].recordList[j].originalValue + '(#&%*)' + data[i].recordList[j].referenceValue, []);
                                                        }
                                                        recordsMap.get(data[i].recordList[j].originalValue + '(#&%*)' + data[i].recordList[j].referenceValue).push(JSON.parse(JSON.stringify(data[i])));
                                                    } else if (data[i].recordList[j].fieldName == 'buildertek__CostCodeDivision__c' && data[i].recordList[j].originalValue == '') {

                                                        data[i].recordList[j].originalValue = 'No Cost Code';
                                                        if (!recordsMap.has('No Cost Code' + '(#&%*)' + 'No Cost Code')) {
                                                            recordsMap.set('No Cost Code' + '(#&%*)' + 'No Cost Code', []);
                                                        }
                                                        recordsMap.get('No Cost Code' + '(#&%*)' + 'No Cost Code').push(JSON.parse(JSON.stringify(data[i])))
                                                    }
                                                }
                                            }
                                            var result = Array.from(recordsMap.entries());
                                            for (var i in result) {
                                                var obj = {};
                                                obj.groupId = result[i][0].split('(#&%*)')[1];
                                                // alert(obj.groupId);
                                                obj.groupName = result[i][0].split('(#&%*)')[0];
                                                //  alert(obj.groupName);
                                                obj.subGroupRecords = subGroupRecords(result[i][1]);
                                                listOfRecords.push(obj);

                                            }
                                            listOfRecords = helper.countFunction(component, listOfRecords);
                                            return listOfRecords;
                                        }
                                        function subGroupRecords(data) {
                                            var listOfRecords = [];
                                            var recordValue = [];
                                            let recordsMap = new Map();
                                            for (var i in data) {
                                                for (var j in data[i].recordList) {
                                                    //  console.log('data[i].recordList[j]',data[i].recordList);
                                                    if (data[i].recordList[j].fieldName == 'buildertek__CostCodeDivision__c' && data[i].recordList[j].originalValue != '') {
                                                        // console.log('data[i].recordList[j].fieldName',data[i].recordList[j].fieldName);
                                                        // console.log('data[i].recordList[j].originalValue',data[i].recordList[j].originalValue);
                                                        if (!recordsMap.has(data[i].recordList[j].originalValue + '(#&%*)' + data[i].recordList[j].referenceValue)) {
                                                            recordsMap.set(data[i].recordList[j].originalValue + '(#&%*)' + data[i].recordList[j].referenceValue, []);
                                                        }
                                                        recordsMap.get(data[i].recordList[j].originalValue + '(#&%*)' + data[i].recordList[j].referenceValue).push(JSON.parse(JSON.stringify(data[i])));
                                                    }
                                                }
                                            }

                                            var result = Array.from(recordsMap.entries());
                                            for (var i in result) {
                                                var obj = {};
                                                var recordValue = [];
                                                obj.recordValue = [];
                                                var sumCol = 0;
                                                obj.subGroupId = result[i][0].split('(#&%*)')[0];
                                                obj.subGroupName = result[i][0].split('(#&%*)')[1] == undefined ? 'No Grouping' : result[i][0].split('(#&%*)')[1];
                                                obj.records = result[i][1];
                                                if (obj.subGroupName != 'No Grouping') {
                                                    for (var j in obj.records) {
                                                        //  console.log(obj.records[j].recordValue);
                                                        recordValue.push(obj.records[j].recordValue);
                                                    }
                                                    var row = recordValue.length;
                                                    var col = recordValue[0].length;
                                                    for (var j = 0; j < col; j++) {
                                                        sumCol = 0;
                                                        for (var k = 0; k < row; k++) {
                                                            //  console.log(recordValue[k][j])
                                                            sumCol += recordValue[k][j];
                                                        }
                                                        j == 0 ?
                                                            obj.recordValue.push(sumCol) :
                                                            obj.recordValue.push(new Intl.NumberFormat('en-US', {
                                                                style: 'currency',
                                                                currency: 'USD'
                                                            }).format(sumCol));
                                                    }
                                                }
                                                listOfRecords.push(obj);
                                            }

                                            //  console.log('listOfRecords',listOfRecords);
                                            return listOfRecords;

                                        }

                                    }

                                }



                            }

                        }
                    }

                    for (var i in result.groupHierarchy) {
                        if (result.groupHierarchy[i].groupId == 'undefined' || result.groupHierarchy[i].groupId == null || result.groupHierarchy[i].groupId == '') {
                            result.groupHierarchy.splice(i, 1);
                        }
                    }


                    // console.log('&&&&&&&&&&&&&&&&&&&&&&&&');
                    // console.log('toggleVal ==> '+toggleVal);
                    // console.log('toggleVal1 ==> '+toggleVal1);
                    // console.log('toggleVal2 ==> '+toggleVal2);
                    // console.log('bt1 ==> '+bt1);
                    // if (toggleVal == true && toggleVal1 == true && toggleVal2 == false && bt1 == true) {
                    //     console.log('For No Vendor Condition');
                    // }




                    if (toggleVal == true && result.groupHierarchy == '') {
                        console.log('result.groupHierarchy List Null');
                        console.log('*** Result ***');
                        console.log({ result });

                        var totalRecords = {};
                        var groupHierarchy = [];
                        var groupHierarchyMap = {};
                        var subGroupRecords = [];
                        var subGroupRecordsMap = {};

                        var totalObj = {};

                        totalObj['unitPrice'] = 0;
                        totalObj['unitPricekey'] = '';
                        totalObj['orignalbudget'] = 0;
                        totalObj['orignalbudgetkey'] = '';
                        totalObj['TotalApprovals'] = 0;
                        totalObj['TotalApprovalskey'] = '';
                        totalObj['TotalC0'] = 0;
                        totalObj['TotalCOkey'] = '';
                        totalObj['CommittedCost'] = 0;
                        totalObj['CommittedCostkey'] = 0;
                        totalObj['AdditionalCosts'] = 0;
                        totalObj['AdditionalCostsKey'] = '';
                        totalObj['InvoiceCosts'] = 0;
                        totalObj['InvoiceCostsKey'] = '';
                        totalObj['ProjectedCosts'] = 0;
                        totalObj['ProjectedCostskey'] = '';
                        totalObj['Labor1'] = 0;
                        totalObj['Labor1key'] = '';
                        totalObj['Forecast'] = 0;
                        totalObj['Forecastskey'] = '';
                        totalObj['TotalCosts'] = 0;
                        totalObj['TotalCostsKey'] = '';
                        totalObj['ProfitLoss'] = 0;
                        totalObj['ProfitLosskey'] = '';
                        totalObj['fieldType'] = '';
                        totalObj['unitSalesPrice'] = 0;
                        totalObj['unitSalesPricekey'] = '';
                        totalObj['grossMargin'] = 0;
                        totalObj['grossMarginKey'] = '';
                        totalObj['labor'] = 0;
                        totalObj['laborKey'] = '';
                        totalObj['material'] = 0;
                        totalObj['materialKey'] = '';
                        totalObj['laborBudget'] = 0;
                        totalObj['laborBudgetKey'] = '';
                        totalObj['subcontractor'] = 0;
                        totalObj['subcontractorKey'] = '';
                        totalObj['equipment'] = 0;
                        totalObj['equipmentKey'] = '';
                        totalObj['misc'] = 0;
                        totalObj['miscKey'] = '';
                        

                        result.tarTable.ListOfEachRecord.forEach(element => {
                            totalObj = helper.setTotalHelper(element.recordList, totalObj);
                        });

                        groupHierarchyMap['groupName'] = 'No Grouping';
                        subGroupRecordsMap['records'] = result.tarTable.ListOfEachRecord;
                        subGroupRecords.push(subGroupRecordsMap);
                        groupHierarchyMap['subGroupRecords'] = subGroupRecords;
                        groupHierarchyMap['totals'] = totalObj;

                        groupHierarchy.push(groupHierarchyMap);
                        totalRecords['groupHierarchy'] = groupHierarchy;
                        totalRecords['columns'] = result.columns;

                        component.set("v.columns", result.columns);


                        console.log('TotalRecords ==> ', { totalRecords });
                        console.log('columns ==> ', { totalRecords });

                        component.set("v.TotalRecords", totalRecords);
                        component.set("v.TotalRecordsCopy", totalRecords);

                    } else {
                        console.log('e.recordList, totalObj --> ',{totalObj});
                        component.set("v.columns", result.columns);
                        component.set("v.page", result.page);
                        component.set("v.total", result.total);
                        //alert(result.total);
                        if (result.total == 0) {
                            component.set("v.pages", 1);
                        } else {
                            component.set("v.pages", Math.ceil(result.total / 60));
                        }
                        //component.set("v.isLoaded", true);
                        console.log('*******************************************************');
                        console.log('TotalRecords ==> ', { result });
                        component.set("v.TotalRecords", result);
                        component.set("v.TotalRecordsCopy", result);
                        console.log('budget lines::', result);
                        
                    }

                    // To set slds_tab_defaul height for responsive display ==> BUIL - 3466
                    console.log('v.total 2 => ', component.get("v.total"));
                    var total = component.get("v.total");
                    if(total > 60){
                        component.set("v.slds_tab_height_diff", '42px');
                    }
                    else{
                        component.set("v.slds_tab_height_diff", '0px');
                    }

                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        action: "HIDE",
                    }).fire();

                    showToast();
                    //var end = new Date().getTime();
                    //console.log(end - start);
                } else {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        action: "HIDE",
                    }).fire();
                    console.log('Error ',response.getError());
                }
            });
            $A.enqueueAction(action);
        }
    },

    /*getProductDetails:function(component,event,helper){
          var action = component.get("c.getProductPrice");
          var productId = component.get("v.productId");
          var productName = component.get("v.productName");
          ////console.log("----productId",productId);
          action.setParams({"productId":productId});
          action.setCallback(this,function(respo){
              var res = respo.getReturnValue(); 
              ////console.log("----respo---",res.length);
              var getProductDetails = component.get("v.newBudgetLine");
              delete getProductDetails.buildertek__Grouping__r;
              ////console.log("@Budgetline@",component.get("v.recordId"));
              getProductDetails.buildertek__Budget__c = component.get("v.recordId");
              ////console.log("getprodct----",JSON.stringify(getProductDetails));
              if(res.length>=1) {
                  getProductDetails.buildertek__Unit_Price__c = res[0].UnitPrice;
              }else{
                  getProductDetails.buildertek__Unit_Price__c = 0;
              }
              getProductDetails.buildertek__Product__c = productId;
              
              getProductDetails.Name = productName;
              component.set("v.newBudgetLine",getProductDetails);
              
              ////console.log("getprodct----",JSON.stringify(getProductDetails));
              
              ////console.log("----log",res);
          });
          $A.enqueueAction(action);
      },*/

    getGrouping: function (component, event, fieldsList, allFields, groupIds) {
        var recordId = component.get("v.recordId");

        var action = component.get("c.groupValues");
        action.setParams({
            recordId: recordId,
            currencyFields: fieldsList,
            allFields: allFields,
            groupIds: groupIds,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            //alert('state -------->'+state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                console.log('result --------> ' + JSON.stringify(result));
                component.set("v.InnerList", result);
                $A.get("e.c:BT_SpinnerEvent")
                    .setParams({
                        action: "HIDE",
                    })
                    .fire();
            }
        });
        $A.enqueueAction(action);
    },

    getTableData: function (component, event, allFields, fieldType) {
        var recordId = component.get("v.recordId");
        allFields.push("Id", "buildertek__Group__c");
        fieldType.push({
            fieldName: "Id",
            fieldType: "",
            isEditable: false,
        });
        fieldType.push({
            fieldName: "buildertek__Group__c",
            fieldType: "Reference",
            isEditable: false,
        });
        var finalString = JSON.stringify(fieldType);
        // alert(finalString);
        var action = component.get("c.getBudgetItemData");
        action.setParams({
            recordId: recordId,
            fieldsList: allFields,
            fieldString: finalString,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            // alert('state -------> '+state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                ////console.log('Final result --------> '+JSON.stringify(result));
                component.set("v.Table_header_Records", result);
            }
        });
        $A.enqueueAction(action);
    },
    fetchpricebooks: function (component, event, helper) {
        var actions = component.get("c.getpricebooks");
        actions.setParams({
            recordId: component.get("v.recordId"),
        });
        var opts = [];
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                console.log({result});
                let projectHavePricebook=result[0].defaultValue;
                var pricebookOptions = [];
                if(Object.keys(projectHavePricebook).length !=0){
                    pricebookOptions.push({ key: projectHavePricebook.Name, value: projectHavePricebook.Id });
                    result[0].priceWrapList.forEach(function(element){
                        if(projectHavePricebook.Id !== element.Id){
                            pricebookOptions.push({ key: element.Name, value: element.Id });
                        }else{
                            pricebookOptions.push({ key: "None", value: "" });

                        }
                    });
                    component.set('v.pricebookName' , projectHavePricebook.Id);

                }else{
                    pricebookOptions.push({ key: "None", value: "" });
                    result[0].priceWrapList.forEach(function(element){
                        pricebookOptions.push({ key: element.Name, value: element.Id });
                    });
                    component.set("v.pricebookName", pricebookOptions[0].value);                

                }

                if(component.get('v.pricebookName')!= undefined || component.get('v.pricebookName')!=null){
                    helper.changeEventHelper(component, event, helper);
                }
                component.set("v.pricebookoptions", pricebookOptions);
            }
        });
        $A.enqueueAction(actions);
    },


    fetchPickListVal: function (component, event, helper) {
        var actions = component.get("c.getselectOptions");
        actions.setParams({
            budgetObject: component.get("v.newBudgetLine"),
            budgetField: "buildertek__UOM__c",
        });
        var opts = [];
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                var opts = [];
                opts.push({
                    key: "None",
                    value: "",
                });
                for (var key in result) {
                    opts.push({
                        key: key,
                        value: result[key],
                    });
                }
                component.set("v.options", opts);
            }
        });
        $A.enqueueAction(actions);
    },

    fetchPriority: function (component, event, helper) {
        var actions = component.get("c.getselectOptions");
        actions.setParams({
            budgetObject: component.get("v.newBudgetLine"),
            budgetField: "buildertek__Priority__c",
        });
        var opts = [];
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                var opts = [];
                opts.push({
                    key: "None",
                    value: "",
                });
                for (var key in result) {
                    opts.push({
                        key: key,
                        value: result[key],
                    });
                }
                component.set("v.priorityOptions", opts);
            }
        });
        $A.enqueueAction(actions);
    },

    fetchproductfamily: function (component, event, helper) {
        var actions = component.get("c.getselectOptionsforproductfamily");
        actions.setParams({
            budgetObject: "Product2",
            budgetField: "Family",
        });
        var opts = [];
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                var opts = [];
                //opts.push({key: "None", value: "" });
                for (var key in result) {
                    opts.push({
                        key: key,
                        value: result[key],
                    });
                }
                component.set("v.productfamilyoptions", opts);
            }
        });
        $A.enqueueAction(actions);
    },
    isExistingPo: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        component.set("v.isNewExpense", false);
        component.set("v.duplicateExp", false);
        var expenseDescription = component.get("v.expenseDescription");
        var expensebudget = component.get("v.expensebudget");
        var expenseType = component.get("v.expenseType");
        var expenseCostCode = component.get("v.expenseCostCode");
        var expensePaymentMethod = component.get("v.expensePaymentMethod");
        var expenseRefNo = component.get("v.expenseRefNo");
        var expenseAmount = component.get("v.expenseAmount");
        var expenseNote = component.get("v.expenseNote");
        var isExpenseUpdate = component.get("v.isExpenseUpdate");
        var budgetItemId = component.get("v.budgetItemId");
        var proj = component.get("v.sampleNewRecord");
        // alert( JSON.stringify(proj));
        //  alert('kkkkk'+component.get("v.sampleNewRecord").buildertek__Project__c);
        //  alert(budgetItemId);
        if (budgetItemId) {
            // isExpenseUpdate = true;
        }
        //Update Expense  
        if (budgetItemId != undefined && isExpenseUpdate) {
            var action = component.get("c.updateBudgetItemFromExpenseItem");
            //  alert('^^^');
            action.setParams({
                "expenseDescription": expenseDescription,
                "expensebudgetId": expensebudget,
                "expenseType": expenseType,
                "expenseCostCode": expenseCostCode,
                "expensePaymentMethod": expensePaymentMethod,
                "expenseRefNo": expenseRefNo,
                "expenseAmount": expenseAmount,
                "expenseNote": expenseNote,
                "projectId": component.get("v.sampleNewRecord").buildertek__Project__c,
                'budgetItemId': budgetItemId
            });
            action.setCallback(this, function (response) {
                var responses = response.getReturnValue();
                if (responses != null) {
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                    //  alert('hai'+response.getState() );
                    //$A.getCallback(function () {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Budget Line created successfully',
                        type: 'success',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    //});
                    $A.get('e.force:refreshView').fire();
                    component.refreshData();
                    component.set("v.expenseDescription", null);
                    component.set("v.expensebudget", null);
                    component.set("v.expenseType", null);
                    component.set("v.expenseCostCode", null);
                    component.set("v.expensePaymentMethod", null);
                    component.set("v.expenseRefNo", null);
                    component.set("v.expenseAmount", null);
                    component.set("v.expenseNote", null);
                    component.set("v.budgetItemId", null);
                    var noRecord = [];
                    component.set('v.selectedRecs', noRecord);
                    //alert("@@3"+component.get("v.budgetItemId"));
                }
                else
                    /*if (response.getState() === "ERROR") {
                    let errors = response.getError();
                    let message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    // Display the message
                    console.error(message);
                    $A.getCallback(function () {*/
                    var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'We cannot create New Expense, because this Budget has not associated with the Project.',
                    type: 'ERROR',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                //});
                $A.get('e.force:refreshView').fire();
                //}
            });
            $A.enqueueAction(action);
            //alert("@@2"+component.get("v.budgetItemId"));
        }
        else {
            //  alert('hello');
            var action = component.get("c.createBudgetItemFromExpenseItem");
            action.setParams({
                "expenseDescription": expenseDescription,
                "expensebudgetId": expensebudget,
                "expenseType": expenseType,
                "expenseCostCode": expenseCostCode,
                "expensePaymentMethod": expensePaymentMethod,
                "expenseRefNo": expenseRefNo,
                "expenseAmount": expenseAmount,
                "expenseNote": expenseNote,
                "projectId": component.get("v.sampleNewRecord").buildertek__Project__c
            });
            action.setCallback(this, function (response) {
                var res = response.getReturnValue();
                //	if (response.getState() === "SUCCESS") {
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
                //$A.getCallback(function () {
                if (res != null) {
                    //alert('oye'+response.getReturnValue());
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'Budget Line created successfully',
                        type: 'success',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    //});
                    $A.get('e.force:refreshView').fire();
                    component.refreshData();
                    component.set("v.expenseDescription", null);
                    component.set("v.expensebudget", null);
                    component.set("v.expenseType", null);
                    component.set("v.expenseCostCode", null);
                    component.set("v.expensePaymentMethod", null);
                    component.set("v.expenseRefNo", null);
                    component.set("v.expenseAmount", null);
                    component.set("v.expenseNote", null);
                    component.set("v.budgetItemId", null);
                } else {
                    //  alert("helo......");
                    /*if (response.getState() === "ERROR") {
                    let errors = response.getError();
                    let message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    // Display the message
                    console.error(message);*/
                    //$A.getCallback(function () {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'We cannot create New Expense, because this Budget has not associated with the Project.',
                        type: 'ERROR',
                        duration: '10000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                    //});
                    $A.get('e.force:refreshView').fire();
                }
                //}
                //}
            });
            $A.enqueueAction(action);
        }

    },
    getpoList: function (component, pageNumber, pageSize) {
        var recId = component.get("v.recordId");
        var action = component.get("c.getBudgetData");
        action.setParams({
            pageNumber: pageNumber,
            pageSize: pageSize,
            RecId: recId
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                for (var i in resultData.recordList) {
                    resultData.recordList[i].budgetCheck = false;
                }
                component.set("v.recordList", resultData.recordList);
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecord", resultData.totalRecords);
                component.set("v.RecordStart", resultData.recordStart);
                component.set("v.RecordEnd", resultData.recordEnd);
                component.set(
                    "v.TotalPages",
                    Math.ceil(resultData.totalRecords / pageSize)
                );
            }
        });
        $A.enqueueAction(action);
    },
    getInvoiceList: function (component, pageNumber, pageSize) {
        console.log('method getInvoiceList calling ');
        var recId = component.get("v.recordId");
        var action = component.get("c.getInvioceData");
        action.setParams({
            pageNumber: pageNumber,
            pageSize: pageSize,
            RecId: recId
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                console.log('resultData --> ',{resultData});
                for (var i in resultData.recordList) {
                    resultData.recordList[i].budgetCheck = false;
                }
                component.set("v.recordList", resultData.recordList);
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecord", resultData.totalRecords);
                component.set("v.RecordStart", resultData.recordStart);
                component.set("v.RecordEnd", resultData.recordEnd);
                component.set(
                    "v.TotalPages",
                    Math.ceil(resultData.totalRecords / pageSize)
                );
            }
        });
        $A.enqueueAction(action);
    },
    gettcList: function (component, pageNumber, pageSize) {
        var recId = component.get("v.recordId");
        var action = component.get("c.getTimeCardData");
        action.setParams({
            pageNumber: pageNumber,
            pageSize: pageSize,
            RecId: recId
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                console.log('resultData --> ',{resultData});
                for (var i in resultData.recordList) {
                    resultData.recordList[i].budgetCheck = false;
                }
                component.set("v.recordList", resultData.recordList);
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecord", resultData.totalRecords);
                component.set("v.RecordStart", resultData.recordStart);
                component.set("v.RecordEnd", resultData.recordEnd);
                component.set(
                    "v.TotalPages",
                    Math.ceil(resultData.totalRecords / pageSize)
                );
            }
        });
        $A.enqueueAction(action);
    },
      doSave: function (component, event, helper) {
          $A.get("e.c:BT_SpinnerEvent").setParams({
              "action": "SHOW"
          }).fire();
          component.set("v.isNewExpense", false);
          component.set("v.duplicateExp", false);
          var expenseDescription = component.get("v.expenseDescription");
          var expensebudget = component.get("v.expensebudget");
          var expenseType = component.get("v.expenseType");
          var expenseCostCode = component.get("v.expenseCostCode");
          var expensePaymentMethod = component.get("v.expensePaymentMethod");
          var expenseRefNo = component.get("v.expenseRefNo");
          var expenseAmount = component.get("v.expenseAmount");
          var expenseNote = component.get("v.expenseNote");
          var isExpenseUpdate = component.get("v.isExpenseUpdate");
          var budgetItemId = component.get("v.budgetItemId");
          //Update Expense  
          if (budgetItemId != undefined && isExpenseUpdate) {
              var action = component.get("c.updateBudgetItemFromExpenseItem");
              action.setParams({
                  "expenseDescription": expenseDescription,
                  "expensebudgetId": expensebudget,
                  "expenseType": expenseType,
                  "expenseCostCode": expenseCostCode,
                  "expensePaymentMethod": expensePaymentMethod,
                  "expenseRefNo": expenseRefNo,
                  "expenseAmount": expenseAmount,
                  "expenseNote": expenseNote,
                  "projectId": component.get("v.sampleNewRecord").buildertek__Project__c,
                  'budgetItemId': budgetItemId
              });
              action.setCallback(this, function (response) {
                  if (response.getState() === "SUCCESS") {
                      $A.get("e.c:BT_SpinnerEvent").setParams({
                          "action": "HIDE"
                      }).fire();
                      $A.getCallback(function () {
                          var toastEvent = $A.get("e.force:showToast");
                          toastEvent.setParams({
                              mode: 'sticky',
                              message: 'Budget Line created successfully',
                              type: 'success',
                              duration: '10000',
                              mode: 'dismissible'
                          });
                          toastEvent.fire();
                      });
                      $A.get('e.force:refreshView').fire();
                      component.refreshData();
                      component.set("v.expenseDescription", null);
                      component.set("v.expensebudget", null);
                      component.set("v.expenseType", null);
                      component.set("v.expenseCostCode", null);
                      component.set("v.expensePaymentMethod", null);
                      component.set("v.expenseRefNo", null);
                      component.set("v.expenseAmount", null);
                      component.set("v.expenseNote", null);
                      component.set("v.budgetItemId", '');
                  } else if (response.getState() === "ERROR") {
                      let errors = response.getError();
                      let message = 'Unknown error'; // Default error message
                      // Retrieve the error message sent by the server
                      if (errors && Array.isArray(errors) && errors.length > 0) {
                          message = errors[0].message;
                      }
                      // Display the message
                      console.error(message);
                      $A.getCallback(function () {
                          var toastEvent = $A.get("e.force:showToast");
                          toastEvent.setParams({
                              mode: 'sticky',
                              message: 'Budget Line not created',
                              type: 'ERROR',
                              duration: '10000',
                              mode: 'dismissible'
                          });
                          toastEvent.fire();
                      });
                      $A.get('e.force:refreshView').fire();
                  }
              });
              $A.enqueueAction(action);
          } else {
              // alert('hello');
              var action = component.get("c.createBudgetItemFromExpenseItem");
              action.setParams({
                  "expenseDescription": expenseDescription,
                  "expensebudgetId": expensebudget,
                  "expenseType": expenseType,
                  "expenseCostCode": expenseCostCode,
                  "expensePaymentMethod": expensePaymentMethod,
                  "expenseRefNo": expenseRefNo,
                  "expenseAmount": expenseAmount,
                  "expenseNote": expenseNote,
                  "projectId": component.get("v.sampleNewRecord").buildertek__Project__c
              });
              action.setCallback(this, function (response) {
                  if (response.getState() === "SUCCESS") {
                      $A.get("e.c:BT_SpinnerEvent").setParams({
                          "action": "HIDE"
                      }).fire();
                      $A.getCallback(function () {
                          var toastEvent = $A.get("e.force:showToast");
                          toastEvent.setParams({
                              mode: 'sticky',
                              message: 'Budget Line created successfully',
                              type: 'success',
                              duration: '10000',
                              mode: 'dismissible'
                          });
                          toastEvent.fire();
                      });
                      $A.get('e.force:refreshView').fire();
                      component.refreshData();
                      component.set("v.expenseDescription", null);
                      component.set("v.expensebudget", null);
                      component.set("v.expenseType", null);
                      component.set("v.expenseCostCode", null);
                      component.set("v.expensePaymentMethod", null);
                      component.set("v.expenseRefNo", null);
                      component.set("v.expenseAmount", null);
                      component.set("v.expenseNote", null);
                      component.set("v.budgetItemId", '');
                  } else if (response.getState() === "ERROR") {
                      let errors = response.getError();
                      let message = 'Unknown error'; // Default error message
                      // Retrieve the error message sent by the server
                      if (errors && Array.isArray(errors) && errors.length > 0) {
                          message = errors[0].message;
                      }
                      // Display the message
                      console.error(message);
                      $A.getCallback(function () {
                          var toastEvent = $A.get("e.force:showToast");
                          toastEvent.setParams({
                              mode: 'sticky',
                              message: 'Budget Line not created',
                              type: 'ERROR',
                              duration: '10000',
                              mode: 'dismissible'
                          });
                          toastEvent.fire();
                      });
                      $A.get('e.force:refreshView').fire();
                  }
              });
              $A.enqueueAction(action);
          }
  
      },
    getUOMValues: function (component, event, helper) {
        var action = component.get("c.getProductUOM");
        var productId = component.get("v.productId");
        action.setParams({
            "productId": productId
        });
        action.setCallback(this, function (respo) {
            var res = respo.getReturnValue();
            var ProductDetails = component.get("v.newQuote");
            if (res != null) {
                var existuom = false;
                var quoteUOM = component.get("v.options");
                for (var i = 0; i < quoteUOM.length; i++) {
                    if (quoteUOM[i].value == res) {
                        existuom = true;
                        break;
                    }
                }
                if (existuom == true) {
                    component.set("v.UOMvalues", res);
                } else {
                    component.set("v.UOMvalues", 'Each');
                }
            } else {
                component.set("v.UOMvalues", 'Each');
            }
        });
        $A.enqueueAction(action);

    },

    fetchCORecordType: function (component, event, helper) {
        var actions = component.get("c.getCOCustomerRecordType");
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.COCustomerRecordType", result);
            }
        });
        $A.enqueueAction(actions);
    },
    fetchInvoiceRecordType: function (component, event, helper) {
        var actions = component.get("c.getInvoiceCustomerRecordType");
        actions.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                var result = response.getReturnValue();
                component.set("v.InvoiceCustomerRecordType", result);
            }
        });
        $A.enqueueAction(actions);
    },

    // Method for Group By Cost Code Button
    CostCodeFilterHelper: function (component, event, helper, page) {
        component.set("v.page", page);

        var action = component.get("c.retrieveGroups");
        action.setParams({
            budgetId: component.get("v.recordId"),
            pageNumber: page,
            recordToDisply: 60,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            console.log('State =>  ', { state });

            console.log('Response =>', response.getReturnValue());

            var result = response.getReturnValue()

            var TotalRecords = {};

            if (result.formulaFields != undefined) {
                var formulaField = JSON.parse(result.formulaFields);
                for (var i in result.columns) {
                    for (var j in formulaField) {
                        if (j.toLowerCase() == result.columns[i].fieldName.toLowerCase()) {
                            result.columns[i].title = formulaField[j];
                        }
                    }
                }
            }

            var costCodeList = [];
            var groupHierarchy = [];
            var groupHierarchyMap = {};

            result.tarTable.records.forEach((element, index) => {
                if (element.buildertek__Cost_Code__c == undefined) {
                    element.buildertek__Cost_Code__c == 'No Code Cost';
                }
                groupHierarchyMap = {};
                if (!costCodeList.includes(element.buildertek__Cost_Code__c)) {
                    costCodeList.push(element.buildertek__Cost_Code__c);
                    groupHierarchyMap['groupId'] = element.buildertek__Cost_Code__c;
                    if (element.buildertek__Cost_Code__c != undefined) {
                        groupHierarchyMap['groupName'] = element.buildertek__Cost_Code__r.Name;
                    } else {
                        groupHierarchyMap['groupName'] = 'No Code Cost';
                    }
                    groupHierarchy.push(groupHierarchyMap);
                }

            });

            var records = []
            var recordsList = [];
            var recordsMap = {};
            var subGroupRecordsMap = {};
            var subGroupRecords = [];

            groupHierarchy.forEach(element => {
                records = [];
                subGroupRecordsMap = {};
                subGroupRecords = [];

                var totalObj = {};

                totalObj['unitPrice'] = 0;
                totalObj['unitPricekey'] = '';
                totalObj['orignalbudget'] = 0;
                totalObj['orignalbudgetkey'] = '';
                totalObj['totalSalesPrice'] = 0;
                totalObj['totalSalesPricekey'] = '';
                totalObj['TotalApprovals'] = 0;
                totalObj['TotalApprovalskey'] = '';
                totalObj['TotalC0'] = 0;
                totalObj['TotalCOkey'] = '';
                totalObj['CommittedCost'] = 0;
                totalObj['CommittedCostkey'] = 0;
                totalObj['AdditionalCosts'] = 0;
                totalObj['AdditionalCostsKey'] = '';
                totalObj['InvoiceCosts'] = 0;
                totalObj['InvoiceCostsKey'] = '';
                totalObj['ProjectedCosts'] = 0;
                totalObj['ProjectedCostskey'] = '';
                totalObj['Labor1'] = 0;
                totalObj['Labor1key'] = '';
                totalObj['Forecast'] = 0;
                totalObj['Forecastskey'] = '';
                totalObj['TotalCosts'] = 0;
                totalObj['TotalCostsKey'] = '';
                totalObj['ProfitLoss'] = 0;
                totalObj['ProfitLosskey'] = '';
                totalObj['fieldType'] = '';
                totalObj['unitSalesPrice'] = 0;
                totalObj['unitSalesPricekey'] = '';
                totalObj['grossMargin'] = 0;
                totalObj['grossMarginKey'] = '';
                totalObj['labor'] = 0;
                totalObj['laborKey'] = '';
                totalObj['material'] = 0;
                totalObj['materialKey'] = '';
                totalObj['laborBudget'] = 0;
                totalObj['laborBudgetKey'] = '';
                totalObj['subcontractor'] = 0;
                totalObj['subcontractorKey'] = '';
                totalObj['equipment'] = 0;
                totalObj['equipmentKey'] = '';
                totalObj['misc'] = 0;
                totalObj['miscKey'] = '';
                


                result.tarTable.records.forEach((ele, index) => {
                    if (element['groupId'] == ele.buildertek__Cost_Code__c) {
                        recordsMap = {};
                        recordsList = (result.tarTable.ListOfEachRecord[index].recordList);
                        recordsMap['groupId'] = element['groupId'];
                        recordsMap['groupName'] = element['groupName'];
                        recordsMap['recordId'] = ele.Id;
                        recordsMap['recordName'] = ele.Name;
                        recordsMap['recordList'] = recordsList;
                        records.push(recordsMap);

                        totalObj = helper.setTotalHelper(recordsList, totalObj);
                        // console.log('totalObj => ',{totalObj})

                    }
                });
                element['totals'] = totalObj;
                subGroupRecordsMap['records'] = records;
                subGroupRecords.push(subGroupRecordsMap);
                element['subGroupRecords'] = subGroupRecords;
            });

            TotalRecords['groupHierarchy'] = groupHierarchy;
            TotalRecords['columns'] = result.columns;

            console.log('TotalRecords ==> ', { TotalRecords });
            component.set("v.TotalRecords", TotalRecords);

            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();

        });
        $A.enqueueAction(action);


    },

    setTotalHelper: function (ele, totalObj) {

        ele.forEach(e => {

            if (e.fieldName == 'buildertek__Unit_Price__c' && e.originalValue != '') {
                totalObj['unitPrice'] += e.originalValue;
                totalObj['unitPricekey'] = "buildertek__Unit_Price__c";
            }

            if (e.fieldName == 'buildertek__Original_Budget__c') {
                totalObj['orignalbudget'] += e.originalValue;
                totalObj['orignalbudgetkey'] = "buildertek__Original_Budget__c";
            }

            if (e.fieldName == 'buildertek__Total_Sales_Price__c') {
                totalObj['totalSalesPrice'] += e.originalValue;
                totalObj['totalSalesPricekey'] = "buildertek__Total_Sales_Price__c";
            }

            if (e.fieldName == 'buildertek__Total_Approvals_CO__c') {
                totalObj['TotalApprovals'] += e.originalValue;
                totalObj['TotalApprovalskey'] = "buildertek__Total_Approvals_CO__c";
            }

            if (e.fieldName == 'buildertek__CO_Total__c') {
                totalObj['TotalC0'] += e.originalValue;
                totalObj['TotalCOkey'] = "buildertek__CO_Total__c";
            }

            if (e.fieldName == 'buildertek__Committed_Costs__c') {
                totalObj['CommittedCost'] += e.originalValue;
                totalObj['CommittedCostkey'] = "buildertek__Committed_Costs__c";
            }

            if (e.fieldName == 'buildertek__Additional_Costs__c') {
                totalObj['AdditionalCosts'] += e.originalValue;
                totalObj['AdditionalCostsKey'] = "buildertek__Additional_Costs__c";
            }

            if (e.fieldName == 'buildertek__Invoice_total__c') {
                totalObj['InvoiceCosts'] += e.originalValue;
                totalObj['InvoiceCostsKey'] = "buildertek__Invoice_total__c";
            }

            if (e.fieldName == 'buildertek__Labor1__c') {
                totalObj['Labor1'] += e.originalValue;
                totalObj['Labor1key'] = "buildertek__Labor1__c";
            }

            if (e.fieldName == 'buildertek__Projected_Costs__c') {
                totalObj['ProjectedCosts'] += e.originalValue;
                totalObj['ProjectedCostskey'] = "buildertek__Projected_Costs__c";
            }

            if (e.fieldName == 'buildertek__Forecast_To_Complete__c') {
                totalObj['Forecast'] += e.originalValue;
                totalObj['Forecastskey'] = "buildertek__Forecast_To_Complete__c";
            }

            if (e.fieldName == 'buildertek__Total_Costs__c') {
                totalObj['TotalCosts'] += e.originalValue;
                totalObj['TotalCostsKey'] = "buildertek__Total_Costs__c";
            }

            if (e.fieldName == 'buildertek__Profit_Loss__c') {
                totalObj['ProfitLoss'] += e.originalValue;
                totalObj['ProfitLosskey'] = "buildertek__Profit_Loss__c";
            }

             if (e.fieldName == "buildertek__Sales_Price__c") {
                totalObj['unitSalesPrice'] += e.originalValue;
                totalObj['unitSalesPricekey'] = 'buildertek__Sales_Price__c'
            }

            if (e.fieldName == "buildertek__Gross_Profit__c") {
                totalObj['grossMargin'] += e.originalValue;
                totalObj['grossMarginKey'] = 'buildertek__Gross_Profit__c'
            }
            if (e.fieldName == "buildertek__Labor__c") {
                totalObj['labor'] += e.originalValue;
                totalObj['laborKey'] = 'buildertek__Labor__c'
            }
            if (e.fieldName == "buildertek__Material_Budget__c") {
                totalObj['material'] += e.originalValue;
                totalObj['materialKey'] = 'buildertek__Material_Budget__c'
            }
            if (e.fieldName == "buildertek__Labor_Budget__c") {
                totalObj['laborBudget'] += e.originalValue;
                totalObj['laborBudgetKey'] = 'buildertek__Labor_Budget__c'
            }
            if (e.fieldName == "buildertek__Subcontractor_Budget__c") {
                totalObj['subcontractor'] += e.originalValue;
                totalObj['subcontractorKey'] = 'buildertek__Subcontractor_Budget__c'
            }
            if (e.fieldName == "buildertek__Equipment_Budget__c") {
                totalObj['equipment'] += e.originalValue;
                totalObj['equipmentKey'] = 'buildertek__Equipment_Budget__c'
            }
            if (e.fieldName == "buildertek__Misc_Budget__c") {
                totalObj['misc'] += e.originalValue;
                totalObj['miscKey'] = 'buildertek__Misc_Budget__c'
            }


            totalObj['fieldType'] = "currency";

        });

        return totalObj;

    },


    countFunction: function (component, listOfRecords){
        console.log('::::::::countFunction:::::::::::::::::::');
        console.log({listOfRecords});
        for (var i in listOfRecords) {
            var obj = {}
            obj['unitPrice'] = 0;
            obj['unitPricekey'] = '';
            obj['orignalbudget'] = 0;
            obj['orignalbudgetkey'] = '';
            obj['totalSalesPrice'] = 0;
            obj['totalSalesPricekey'] = '';
            obj['TotalApprovals'] = 0;
            obj['TotalApprovalskey'] = '';
            obj['CommittedCost'] = 0;
            obj['CommittedCostkey'] = 0;
            obj['AdditionalCosts'] = 0;
            obj['AdditionalCostsKey'] = '';
            obj['InvoiceCosts'] = 0;
            obj['InvoiceCostsKey'] = '';
            obj['ProjectedCosts'] = 0;
            obj['ProjectedCostskey'] = '';
            obj['Labor1'] = 0;
            obj['Labor1key'] = '';
            obj['Forecast'] = 0;
            obj['Forecastskey'] = '';
            obj['TotalCosts'] = 0;
            obj['TotalCostsKey'] = '';
            obj['ProfitLoss'] = 0;
            obj['ProfitLosskey'] = '';
            obj['fieldType'] = '';
            
            obj['unitSalesPrice'] = 0;
            obj['unitSalesPricekey'] = '';

            obj['grossMargin'] = 0;
            obj['grossMarginKey'] = '';

            obj['labor'] = 0;
            obj['laborKey'] = '';

            obj['material'] = 0;
            obj['materialKey'] = '';

            obj['laborBudget'] = 0;
            obj['laborBudgetKey'] = '';

            obj['subcontractor'] = 0;
            obj['subcontractorKey'] = '';

            obj['equipment'] = 0;
            obj['equipmentKey'] = '';

            obj['misc'] = 0;
            obj['miscKey'] = '';

            // obj['amountIn'] = 0;
            // obj['amountInKey'] = '';
            // obj['amountOut'] = 0;
            // obj['amountOutKey'] = '';            
            // obj['foreCastToComplete'] = 0;
            // obj['foreCastToCompleteKey'] = '';
            // obj['coTotal'] = 0;
            // obj['coTotalKey'] = '';
            // obj['eligibleAmount'] = 0;
            // obj['eligibleAmountKey'] = '';
            // obj['invoiceTotal'] = 0;
            // obj['invoiceTotalKey'] = '';
            // obj['previousBilled'] = 0;
            // obj['previousBilledKey'] = '';
            // obj['upgrades'] = 0;
            // obj['upgradesKey'] = '';

            for (var j = 0; j < listOfRecords[i].subGroupRecords[0].records.length; j++) {
                var recList = listOfRecords[i].subGroupRecords[0].records[j].recordList;
                for (var k = 0; k < recList.length; k++) {
                    if (recList[k].fieldType == "currency") {
                        // console.log('recList[k].fieldName ' , recList[k].fieldName);
                        if (recList[k].fieldName == "buildertek__Unit_Price__c") {
                            obj['unitPrice'] += Number(recList[k].originalValue);
                            obj['unitPricekey'] = "buildertek__Unit_Price__c"
                        }
                        if (recList[k].fieldName == "buildertek__Original_Budget__c") {
                            obj['orignalbudget'] += recList[k].originalValue;
                            obj['orignalbudgetkey'] = "buildertek__Original_Budget__c"
                        }
                        if (recList[k].fieldName == "buildertek__Total_Sales_Price__c") {
                            obj['totalSalesPrice'] += recList[k].originalValue;
                            obj['totalSalesPricekey'] = "buildertek__Total_Sales_Price__c"
                        }
                        if (recList[k].fieldName == "buildertek__Total_Approvals_CO__c") {
                            obj['TotalApprovals'] += recList[k].originalValue;
                            obj['TotalApprovalskey'] = 'buildertek__Total_Approvals_CO__c'
                        }
                        if (recList[k].fieldName == "buildertek__Committed_Costs__c") {
                            obj['CommittedCost'] += recList[k].originalValue;
                            obj['CommittedCostkey'] = 'buildertek__Committed_Costs__c'
                        }
                        if (recList[k].fieldName == "buildertek__Additional_Costs__c") {
                            obj['AdditionalCosts'] += recList[k].originalValue;
                            obj['AdditionalCostsKey'] = "buildertek__Additional_Costs__c"
                        }
                        if (recList[k].fieldName == "buildertek__Invoice_total__c") {
                            obj['InvoiceCosts'] += recList[k].originalValue;
                            obj['InvoiceCostsKey'] = "buildertek__Invoice_total__c"
                        }
                        if (recList[k].fieldName == "buildertek__Labor1__c") {
                            obj['Labor1'] += recList[k].originalValue;
                            obj['Labor1key'] = 'buildertek__Labor1__c'
                        }
                        if (recList[k].fieldName == "buildertek__Projected_Costs__c") {
                            obj['ProjectedCosts'] += recList[k].originalValue;
                            obj['ProjectedCostskey'] = 'buildertek__Projected_Costs__c'
                        }
                        if (recList[k].fieldName == "buildertek__Forecast_To_Complete__c") {
                            obj['Forecast'] += recList[k].originalValue;
                            obj['Forecastskey'] = 'buildertek__Forecast_To_Complete__c'
                        }
                        if (recList[k].fieldName == "buildertek__Total_Costs__c") {
                            obj['TotalCosts'] += recList[k].originalValue;
                            obj['TotalCostsKey'] = 'buildertek__Total_Costs__c'
                        }
                        if (recList[k].fieldName == "buildertek__Profit_Loss__c") {
                            obj['ProfitLoss'] += recList[k].originalValue;
                            obj['ProfitLosskey'] = 'buildertek__Profit_Loss__c'
                        }

                        if (recList[k].fieldName == "buildertek__Sales_Price__c") {
                            obj['unitSalesPrice'] += recList[k].originalValue;
                            obj['unitSalesPricekey'] = 'buildertek__Sales_Price__c'
                        }

                        if (recList[k].fieldName == "buildertek__Gross_Profit__c") {
                            obj['grossMargin'] += recList[k].originalValue;
                            obj['grossMarginKey'] = 'buildertek__Gross_Profit__c'
                        }

                        if (recList[k].fieldName == "buildertek__Labor__c") {
                            obj['labor'] += recList[k].originalValue;
                            obj['laborKey'] = 'buildertek__Labor__c'
                        }

                        if (recList[k].fieldName == "buildertek__Material_Budget__c") {
                            obj['material'] += recList[k].originalValue;
                            obj['materialKey'] = 'buildertek__Material_Budget__c'
                        }

                        if (recList[k].fieldName == "buildertek__Labor_Budget__c") {
                            obj['laborBudget'] += recList[k].originalValue;
                            obj['laborBudgetKey'] = 'buildertek__Labor_Budget__c'
                        }

                        if (recList[k].fieldName == "buildertek__Subcontractor_Budget__c") {
                            obj['subcontractor'] += recList[k].originalValue;
                            obj['subcontractorKey'] = 'buildertek__Subcontractor_Budget__c'
                        }

                        if (recList[k].fieldName == "buildertek__Equipment_Budget__c") {
                            obj['equipment'] += recList[k].originalValue;
                            obj['equipmentKey'] = 'buildertek__Equipment_Budget__c'
                        }

                        if (recList[k].fieldName == "buildertek__Misc_Budget__c") {
                            obj['misc'] += recList[k].originalValue;
                            obj['miscKey'] = 'buildertek__Misc_Budget__c'
                        }

                        

                        obj['fieldType'] = recList[k].fieldType;
                    }
                }
    
                listOfRecords[i]['totals'] = obj;
            }
        }
        component.set("v.listOfRecords", listOfRecords);
        console.log({listOfRecords});
        return listOfRecords;
    },

    getcoList: function (component, pageNumber, pageSize) {
        var recId = component.get("v.recordId");
        var action = component.get("c.getCoData");
        action.setParams({
            RecId: recId
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (state === "SUCCESS") {
                var resultData = result.getReturnValue();
                console.log("resultData ---> ", {resultData});
                component.set("v.coRecordList", resultData);
                component.set("v.addcosection", true);
            } else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'ERROR',
                    message: 'There are no project on Budget',
                    duration: '5000',
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    getExpenseList: function (component, pageNumber, pageSize) {
        var recId = component.get("v.recordId");
        var action = component.get("c.getExpenseData");
        action.setParams({
            RecId: recId
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (state === "SUCCESS") {
                var resultData = result.getReturnValue();
                console.log("resultData ---> ", {resultData});
                component.set("v.ExpenseRecordList", resultData);
                component.set("v.addExpenseSection", true);
            } else{
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'ERROR',
                    message: 'There are no project on Budget',
                    duration: '5000',
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);
    },

    //  ************ For Add Sales Invoice Button *************
    getsalesInvoiceHelper: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var budgetId = component.get('v.recordId');
        console.log('Budget record in => ', component.get('v.recordId'));

        var action = component.get("c.getSalesInvoice");
        action.setParams({
            "budgetId" : budgetId
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
                let salesInvoiceList = response.getReturnValue();
                
                salesInvoiceList.forEach(element => {
                    if(element.Name.length > 30){
                        element.Name = element.Name.slice(0, 40) + '...';
                    }
                });

                component.set('v.salesInvoices', salesInvoiceList);
                component.set("v.addSalesInvoiceSection", true);
                console.log('SalesInvoice List => ',response.getReturnValue());
            }
            else if(response.getState() === "ERROR"){
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
                console.log('Error => ',response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    AddNewSalesInvoicesHelper: function(component, event, SLlist){
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        console.log('into update');
        var BudgetId = component.get('v.recordId');
        var action = component.get("c.UpdateSalesInvoices");
        action.setParams({
            'SLIDlist': SLlist,
            'BudgetId': BudgetId
        })
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
                console.log('Response =: ', response.getReturnValue());
                // if(response.getReturnValue() ==  'success'){
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    type: 'SUCCESS',
                    message: 'Sales Invoice added Successfully',
                    duration: '5000',
                });
                toastEvent.fire();
                component.set("v.addSalesInvoiceSection", false); // to close popup
                component.set("v.selectedSalesInvoices", []); // to clear selected sales invoics
                component.set('v.allSLChecked', false); // for check-all checkbox
                $A.get("e.force:refreshView").fire();
                document.location.reload(true);    
                // window.location.reload();



            }
            else if (response.getState() == 'Error') {
                $A.get("e.c:BT_SpinnerEvent").setParams({
                    "action": "HIDE"
                }).fire();
                console.log('Error to Add Sales Invoice => ', response.getError());
            }
        });
        $A.enqueueAction(action);
    },

    handleSelectAll: function(component, event, helper) {
        console.log(event.target.name);
        console.log(event.target.checked);

        var selectedIndex = event.target.name;
        var isSelected = event.target.checked;
        var parentIndex = selectedIndex.split('-')[0];
        var childIndex = selectedIndex.split('-')[1];
        var totalRecords = component.get('v.TotalRecords');

        var tabId = component.get("v.currentTab")
        var budgetId = component.get("v.budgetId");
        console.log('totalRecords::::::', totalRecords);
        var selectedRecs = component.get('v.selectedRecs');
        console.log(selectedRecs);
        console.log('records:', totalRecords.groupHierarchy[parentIndex].subGroupRecords[0].records);

        for (var i in totalRecords.groupHierarchy[parentIndex].subGroupRecords[0].records) {
            console.log({i});
            console.log(totalRecords.groupHierarchy[parentIndex].subGroupRecords[0].records);
            if (isSelected) {
                document.getElementById(parentIndex + '-0-' + i + '-' + tabId + '-' + budgetId).checked = true;
                console.log('true or false::::::', totalRecords.groupHierarchy[parentIndex].subGroupRecords[0].records[i].isSelected);
                totalRecords.groupHierarchy[parentIndex].subGroupRecords[0].records[i].isSelected = true;
                if(!selectedRecs.includes(totalRecords.groupHierarchy[parentIndex].subGroupRecords[0].records[i].recordId)){
                    selectedRecs.push(totalRecords.groupHierarchy[parentIndex].subGroupRecords[0].records[i].recordId);
                }
            } else {
                console.log('no selected');
                totalRecords.groupHierarchy[parentIndex].subGroupRecords[0].records[i].isSelected = false;
                document.getElementById(parentIndex + '-0-' + i + '-' + tabId + '-' + budgetId).checked = false;
                selectedRecs.forEach((element , index)=>{
                    if(element ==  totalRecords.groupHierarchy[parentIndex].subGroupRecords[0].records[i].recordId){
                        selectedRecs.splice( index , 1);
                    }
                })
            }
        }
        console.log({selectedRecs});
        component.set('v.selectedRecs', selectedRecs);

    },
    changeEventHelper: function(component, event, helper) {
        // var group = component.find('costCodeId');
        // group.set("v._text_value", '');
        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({
            "recordByEvent": product
        });
        compEvent.fire();
        component.set('v.productfamily', undefined);
        component.set('v.newBudgetLine.Name', '');
        component.set('v.selectedContractor', null);
        component.set('v.newBudgetLine.buildertek__Group__c', '');
        component.set('v.newBudgetLine.buildertek__Sub_Grouping__c', null);
        component.set('v.options', '');
        component.set('v.newBudgetLine.buildertek__Sales_Price__c', '');
        component.set('v.newBudgetLine.buildertek__Markup__c', '');
        component.set('v.newBudgetLine.buildertek__Unit_Price__c', '');
        component.set('v.newBudgetLine.buildertek__Quantity__c', '1');
        component.set('v.newBudgetLine.buildertek__Cost_Code__c', '');
        $A.enqueueAction(component.get("c.clearLookupValue"));
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "HIDE"
        }).fire();

        //$A.get('e.force:refreshView').fire();

        var action = component.get("c.getProductfamilyRecords");
        var pribooknames = component.get("v.pricebookName");
        console.log('pribooknames',pribooknames);
        // set param to method  
        action.setParams({
            'ObjectName': "Product2",
            'parentId': component.get("v.pricebookName")
        });
        // set a callBack    
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                helper.fetchPickListVal(component, event, helper);
                var storeResponse = response.getReturnValue();
                console.log('storeResponse --> ', storeResponse);
                // if storeResponse size is equal 0 ,display No Result Found... message on screen.                }
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                // set searchResult list with return value from server.
                component.set("v.listofproductfamily", storeResponse);
                if (component.get("v.listofproductfamily").length > 0) {
                    component.set("v.productfamily", component.get("v.listofproductfamily")[0].productfamilyvalues);
                }
                console.log('productfamily --> ', component.get("v.productfamily"));
                console.log('listofproductfamily --> ', component.get("v.listofproductfamily"));
            }

        });
        // enqueue the Action  
        $A.enqueueAction(action);
    },
    
    applyCSSBasedOnURL: function(component) {
        var isBudget = component.get("v.isbudget");
        console.log('isBudget',isBudget);
        var headerDiv = component.find("headerDiv");
        var headerDiv1 = component.find("headerDiv1");
        console.log('headerDiv',headerDiv1);
        console.log('v.total => ', component.get("v.total"));
        
        // Check if the current URL contains a specific keyword or phrase
        // To set slds_tab_defaul height for responsive display ==> BUIL - 3466
        if (isBudget) {
            console.log('in if');
            $A.util.addClass(headerDiv, "divconts1");
            $A.util.removeClass(headerDiv, "divconts2");
            $A.util.addClass(headerDiv1, "divconts1");
        } else {
            console.log('in else');
            $A.util.addClass(headerDiv, "divconts2");
            $A.util.removeClass(headerDiv, "divconts1");
            $A.util.addClass(headerDiv1, "mainBomDiv");
        }
    },

    addInvoicePOHelper:function (component, event, helper) {

        component.set('v.addInvoicePOSection' , true);

        var action = component.get("c.getInvoicePOData");
        action.setParams({
            "RecId": component.get("v.recordId")
        });
        action.setCallback(this, function (response) {
            var state= response.getState();
            var error= response.getError();
            console.log(state);
            console.log(error);

            if(state === 'SUCCESS'){
                console.log(response.getReturnValue());
                var result=response.getReturnValue();
                component.set('v.invoicePORecordList', result);
            }

            $A.get("e.c:BT_SpinnerEvent").setParams({
                "action": "HIDE"
            }).fire();

        });
        $A.enqueueAction(action);

    },

    // >>>>>>>>>>>>>> CHB - 78, 80 <<<<<<<<<<<<<<<<<<<
    Check_Create_User_Access: function(component, event, helper){
        var action1 = component.get("c.CheckUserAccess");
        action1.setParams({
            AccessType: 'Create'
        });
        action1.setCallback(this, function(response) {
            console.log('CheckUserHaveAcces >> ',response.getReturnValue());
            if(response.getReturnValue() == 'True'){
               component.set("v.HaveCreateAccess", true);
            }
            else if(response.getReturnValue() == 'False'){
                component.set("v.HaveCreateAccess", false);
            }
        });
        $A.enqueueAction(action1);
    },

    // >>>>>>>>>>>>>>>>>>> CHB - 79 <<<<<<<<<<<<<<<<<<<<<<<<,,
    Check_Update_User_Access: function(component, event, helper){
        var action1 = component.get("c.CheckUserAccess");
        action1.setParams({
            AccessType: 'Update'
        });
        action1.setCallback(this, function(response) {
            console.log('CheckUserHaveAcces >> ',response.getReturnValue());
            if(response.getReturnValue() == 'True'){
               component.set("v.HaveUpdateAccess", true);
            }
            else if(response.getReturnValue() == 'False'){
                component.set("v.HaveUpdateAccess", false);
            }
        });
        $A.enqueueAction(action1);
    },

    Check_Delete_User_Access: function(component, event, helper){
        var action1 = component.get("c.CheckUserAccess");
        action1.setParams({
            AccessType: 'Delete'
        });
        action1.setCallback(this, function(response) {
            console.log('CheckUserHaveAcces >> ',response.getReturnValue());
            if(response.getReturnValue() == 'True'){
               component.set("v.HaveDeleteAccess", true);
            }
            else if(response.getReturnValue() == 'False'){
                component.set("v.HaveDeleteAccess", false);
            }
        });
        $A.enqueueAction(action1);
    },

    submitDetails: function(component, event, helper) {
        var valueofField1 = component.get("v.valueofField1");
        var valueofField2 = component.get("v.valueofField2");
        // var valueofField1 = 'buildertek__Group__c';
        // var valueofField2 = 'buildertek__Sub_Grouping__c';
        // var valueofField3 = component.get("v.valueofField3")
        // var valueofField4 = component.get("v.valueofField4")

        console.log(valueofField1);
        console.log(valueofField2);
        // console.log({valueofField3});
        // console.log({valueofField4});


        if(valueofField1 == "" && valueofField2 == ""){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "Error",
                "title": "Error!",
                "message": 'Please Select At Least One Field'
            });
            toastEvent.fire();           
        } else{
            var selectedFieldList = [];
            if (valueofField1 != "") {
                selectedFieldList.push(valueofField1)
            }
            if (valueofField2 != "") {
                selectedFieldList.push(valueofField2)
            }
            // if (valueofField3 != "") {
            //     selectedFieldList.push(valueofField3)
            // }
            // if (valueofField4 != "") {
            //     selectedFieldList.push(valueofField4)
            // }
            console.log('selectedFieldList ==> ',{selectedFieldList});
            component.set("v.isBOMmodalOpen", false); 
            component.set("v.displayGrouping", true);

            component.set("v.groupFieldList", selectedFieldList);
            helper.getBudgetGrouping(component, event, helper);
            helper.applyCSSBasedOnURL(component);

        }

     },

     getBudgetGrouping : function(component, event, helper) {
        console.log('*** getBudgetGrouping Method ***');
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var page = component.get("v.page") || 1
        var groupFieldList = component.get("v.groupFieldList");
        if (groupFieldList[3] != undefined) {
            component.set("v.forthGrouping", true);
        } else if (groupFieldList[2] != undefined) {
            component.set("v.thirdGrouping", true);
        } else if (groupFieldList[1] != undefined) {
            component.set("v.secondGrouping", true);
        } else if(groupFieldList[0] != undefined){
            component.set("v.firstGrouping", true);
        }
        var action = component.get("c.getBudgetLineData");
        action.setParams({
            budgetId: component.get("v.recordId"),
            pageNumber: page,   // It's for future use, currnetly it's not in used
            recordToDisply: 50, // It's for future use, currnetly it's not in used
            groupingList: groupFieldList
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('getting result ', response.getReturnValue());                
                var budgetLineWrapper = response.getReturnValue();
                var budgetLineList = budgetLineWrapper.budgetLineList;
                component.set("v.totalColumn", budgetLineWrapper.columns.length);
                if (budgetLineList.length > 0) {
                    component.set("v.TotalRecordCount", budgetLineList.length);
                    var columns = budgetLineWrapper.columns;
                    budgetLineList.forEach(element => {
                        var budgetLineFieldData = []
                        columns.forEach(ele => {
                            if (ele.type == 'currency' && element[ele.fieldName] == undefined) {
                                element[ele.fieldName] = 0;
                            }
                            var fieldData = {fieldName: ele.fieldName, fieldType: ele.type, fieldValue: element[ele.fieldName]};
                            budgetLineFieldData.push(fieldData);
                        });
                        element.FieldDataList = budgetLineFieldData;
                        // if (element.buildertek__Build_Phase__c != undefined) {
                        //     element.buildertek__Build_Phase__c = element.buildertek__Build_Phase__r.Name;
                        // }
                        if (element.buildertek__Sub_Grouping__c != undefined) {
                            element.buildertek__Sub_Grouping__c = element.buildertek__Sub_Grouping__r.Name;
                        }
                        if (element.buildertek__Group__c != undefined) {
                            element.buildertek__Group__c = element.buildertek__Group__r.Name;
                        }
                        if (element.buildertek__Category__c != undefined) {
                            element.buildertek__Category__c = element.buildertek__Category__r.Name;
                        }
                    });
                    var group1Wrapper = [];
                    var group1Value = budgetLineList[0][groupFieldList[0]];
                    var budgetLines1 = [];
                    let totalObj = {};
                    columns.forEach(ele => {
                        totalObj[ele.fieldName] = 0;
                    });
                    budgetLineList.forEach((element, index) => {
                        if (group1Value == element[groupFieldList[0]]) {
                            totalObj = helper.countTotal(component, helper, totalObj, element);
                            budgetLines1.push(element);
                            if (budgetLineList.length == index+1) {
                                if (groupFieldList[1] != undefined) {
                                    budgetLines1 = helper.addSecondGrouping(component, helper, budgetLines1, groupFieldList, columns);
                                }
                                totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                                var wrapperData = {groupIndex: group1Wrapper.length+1, groupName : group1Value, budgetLineList: budgetLines1, fieldTotals: totalObj};
                                group1Wrapper.push(wrapperData);
                            }
                        } else{
                            if (groupFieldList[1] != undefined){
                                budgetLines1 = helper.addSecondGrouping(component, helper, budgetLines1, groupFieldList, columns);
                            }
                            totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                            var wrapperData = {groupIndex: group1Wrapper.length+1, groupName : group1Value, budgetLineList: budgetLines1, fieldTotals: totalObj};
                            group1Wrapper.push(wrapperData);

                            totalObj = {};
                            columns.forEach(ele => {
                                totalObj[ele.fieldName] = 0;
                            });
                            totalObj = helper.countTotal(component, helper, totalObj, element);

                            budgetLines1 = [];
                            group1Value = element[groupFieldList[0]];
                            budgetLines1.push(element);

                            if (budgetLineList.length == index+1) {
                                if (groupFieldList[1] != undefined) {
                                    budgetLines1 = helper.addSecondGrouping(component, helper, budgetLines1, groupFieldList, columns);
                                }
                                totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                                var wrapperData = {groupIndex: group1Wrapper.length+1, groupName : group1Value, budgetLineList: budgetLines1, fieldTotals: totalObj};
                                group1Wrapper.push(wrapperData);
                            }
                        }
                    });
                    budgetLineWrapper.groupWrapper = group1Wrapper;
                    console.log('*** Budget Wrapper Data ***');
                    console.log('Budget Wrapper Data => ',{ budgetLineWrapper });
                    component.set("v.BudgetLineWrapper", budgetLineWrapper);
                    $A.get("e.c:BT_SpinnerEvent").setParams({
                        "action": "HIDE"
                    }).fire();
                }else{
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
    addSecondGrouping : function(component, helper, budgetLines1, groupFieldList, columns){
        var group2Wrapper = [];
        if (budgetLines1.length > 0) {
            var group2Value = budgetLines1[0][groupFieldList[1]];
            var budgetLines2 = [];
            let totalObj = {};
            columns.forEach(ele => {
                totalObj[ele.fieldName] = 0;
            });
            budgetLines1.forEach((element, index) => {
                if (group2Value == element[groupFieldList[1]]){
                    totalObj = helper.countTotal(component, helper, totalObj, element);
                    budgetLines2.push(element);
                    if (budgetLines1.length == index+1){
                        if (groupFieldList[2] != undefined) {
                            budgetLines2 = helper.addThirdGrouping(component, helper, budgetLines2, groupFieldList, columns);
                        }
                        totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                        var wrapperData = {groupIndex: group2Wrapper.length+1, groupName : group2Value, budgetLineList: budgetLines2, fieldTotals: totalObj};
                        group2Wrapper.push(wrapperData);
                    }
                } else{
                    if (groupFieldList[2] != undefined) {
                        budgetLines2 = helper.addThirdGrouping(component, helper, budgetLines2, groupFieldList, columns);
                    }
                    totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                    var wrapperData = {groupIndex: group2Wrapper.length+1, groupName : group2Value, budgetLineList: budgetLines2, fieldTotals: totalObj};
                    group2Wrapper.push(wrapperData);

                    totalObj = {};
                    columns.forEach(ele => {
                        totalObj[ele.fieldName] = 0;
                    });
                    totalObj = helper.countTotal(component, helper, totalObj, element);

                    budgetLines2 = [];
                    group2Value = element[groupFieldList[1]];
                    budgetLines2.push(element);

                    if (budgetLines1.length == index+1){
                        if (groupFieldList[2] != undefined) {
                            budgetLines2 = helper.addThirdGrouping(component, helper, budgetLines2, groupFieldList, columns);
                        }
                        totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                        var wrapperData = {groupIndex: group2Wrapper.length+1, groupName : group2Value, budgetLineList: budgetLines2, fieldTotals: totalObj};
                        group2Wrapper.push(wrapperData);
                    }
                }
            });
            return group2Wrapper;
        }
    },
    addThirdGrouping : function(component, helper, budgetLines2, groupFieldList, columns){
        var group3Wrapper = [];
        if (budgetLines2.length > 0) {
            var group3Value = budgetLines2[0][groupFieldList[2]];
            var budgetLines3 = [];
            let totalObj = {};
            columns.forEach(ele => {
                totalObj[ele.fieldName] = 0;
            });
            budgetLines2.forEach((element, index) => {
                if (group3Value == element[groupFieldList[2]]){
                    totalObj = helper.countTotal(component, helper, totalObj, element);
                    budgetLines3.push(element);
                    if (budgetLines2.length == index+1){
                        if (groupFieldList[3] != undefined) {
                            budgetLines3 = helper.addFourthGrouping(component, helper, budgetLines3, groupFieldList, columns);
                        }
                        totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                        var wrapperData = {groupIndex: group3Wrapper.length+1, groupName : group3Value, budgetLineList: budgetLines3, fieldTotals: totalObj};
                        group3Wrapper.push(wrapperData);
                    }
                } else{
                    if (groupFieldList[3] != undefined) {
                        budgetLines3 = helper.addFourthGrouping(component, helper, budgetLines3, groupFieldList, columns);
                    }
                    totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                    var wrapperData = {groupIndex: group3Wrapper.length+1, groupName : group3Value, budgetLineList: budgetLines3, fieldTotals: totalObj};
                    group3Wrapper.push(wrapperData);

                    totalObj = {};
                    columns.forEach(ele => {
                        totalObj[ele.fieldName] = 0;
                    });
                    totalObj = helper.countTotal(component, helper, totalObj, element);

                    budgetLines3 = [];
                    group3Value = element[groupFieldList[2]]
                    budgetLines3.push(element);

                    if (budgetLines2.length == index+1){
                        if (groupFieldList[3] != undefined) {
                            budgetLines3 = helper.addFourthGrouping(component, helper, budgetLines3, groupFieldList, columns);
                        }
                        totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                        var wrapperData = {groupIndex: group3Wrapper.length+1, groupName : group3Value, budgetLineList: budgetLines3, fieldTotals: totalObj};
                        group3Wrapper.push(wrapperData);
                    }
                }
            });
            return group3Wrapper;
        }
    }, 

    addFourthGrouping : function(component, helper, budgetLines3, groupFieldList, columns){
        var group4Wrapper = [];
        if (budgetLines3.length > 0) {
            var group4Value = budgetLines3[0][groupFieldList[3]];
            var budgetLines4 = [];
            let totalObj = {};
            columns.forEach(ele => {
                totalObj[ele.fieldName] = 0;
            });
            budgetLines3.forEach((element, index) => {
                if (group4Value == element[groupFieldList[3]]){
                    totalObj = helper.countTotal(component, helper, totalObj, element);
                    budgetLines4.push(element);
                    if (budgetLines3.length == index+1){
                        totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                        var wrapperData = {groupIndex: group4Wrapper.length+1, groupName : group4Value, budgetLineList: budgetLines4, fieldTotals: totalObj};
                        group4Wrapper.push(wrapperData);
                    }
                } else{
                    totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                    var wrapperData = {groupIndex: group4Wrapper.length+1, groupName : group4Value, budgetLineList: budgetLines4, fieldTotals: totalObj};
                    group4Wrapper.push(wrapperData);

                    totalObj = {};
                    columns.forEach(ele => {
                        totalObj[ele.fieldName] = 0;
                    });
                    totalObj = helper.countTotal(component, helper, totalObj, element);

                    budgetLines4 = [];
                    group4Value = element[groupFieldList[3]];
                    budgetLines4.push(element);

                    if (budgetLines3.length == index+1){
                        totalObj = helper.createTotalWrapper(component, helper, totalObj, columns);
                        var wrapperData = {groupIndex: group4Wrapper.length+1, groupName : group4Value, budgetLineList: budgetLines4, fieldTotals: totalObj};
                        group4Wrapper.push(wrapperData);
                    }
                }
            });
            return group4Wrapper;
        }
    },
    countTotal : function(component, helper, totalObj, element){
        element.FieldDataList.forEach(ele => {
            if (ele.fieldType == 'currency') {
                totalObj[ele.fieldName] += Number(ele.fieldValue);
            }
        });
        return totalObj;
    },
    createTotalWrapper : function(component, helper, totalObj, columns){
        var budgetLineTotalData = [];
        columns.forEach(ele => {
            let fieldData;
            if (ele.type == 'currency') {
                fieldData = {fieldName: ele.fieldName, fieldType: ele.type, fieldValue: totalObj[ele.fieldName]};
            } else if(ele.fieldName == 'Name'){
                fieldData = {fieldName: 'Total', fieldType: ele.type, fieldValue: totalObj[ele.fieldName]};
            }else{
                fieldData = {fieldName: ele.fieldName, fieldType: ele.type, fieldValue: ''};
            }
            budgetLineTotalData.push(fieldData);
        });
        totalObj['fieldTotalList'] = budgetLineTotalData;
        return totalObj;
    }, 
    expandRecordsHelper : function(component, event, helper, spanGroupId){
        console.log('in expandrec===>',spanGroupId);
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
        console.log('in collaperec===>',spanGroupId);
        let recordDivList = document.getElementsByClassName('record_'+spanGroupId);
        let collapeallIcon = document.getElementById("collapeseGroupBtn_" + spanGroupId);
        let expandallIcon = document.getElementById("expandGroupBtn_" + spanGroupId);
        
        collapeallIcon.style.display = 'none';
        expandallIcon.style.display = 'block';
        for(let index = 0; index < recordDivList.length; index++) {
            recordDivList[index].style.display = 'none';
        }
    },
    getGroupingLevels:function(component, event, helper){
        var action = component.get("c.groupingLevels");
        action.setCallback(this, function(response) {

            if(response.getState() == 'SUCCESS'){
                console.log('Testing');
                console.log(response.getReturnValue());
                let groupingLevel=response.getReturnValue();

                component.set('v.valueofField1' , groupingLevel[0]);
                component.set('v.valueofField2' , groupingLevel[1]);

               
            }else{
                console.log(response.getError());
            }
        });
        $A.enqueueAction(action);
    
    },
    getCostCodes : function(component, event, helper) {
        var action = component.get("c.getCostCodes");
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === "SUCCESS") {
                var costCodes = response.getReturnValue();
                var costCodeList = [];
                costCodeList.push({
                    label: 'Select Cost Code',
                    value: ''
                });
                for(var i = 0; i < costCodes.length; i++) {
                    costCodeList.push({
                        label: costCodes[i].Name,
                        value: costCodes[i].Id
                    });
                }
                component.set("v.costCodeList", costCodeList);
            } else{
                console.log('Error calling Apex method: ' + state);
            }
        }
        );
        $A.enqueueAction(action);
    },

    getFieldsFromFieldset:function(component, event, helper){
        let action = component.get("c.getFieldsFromFieldset");
        action.setParams({
            budgetId: component.get("v.recordId")
        });
        action.setCallback(this, function(response) {
            if(response.getState() == 'SUCCESS'){
                let result = response.getReturnValue();
                component.set("v.budgetFields", result);

                console.log('compactLayout ==>',response.getReturnValue());

            } else{
                console.log('Error calling Apex method: ' + state);
            }
        });
        $A.enqueueAction(action);
    } 

})