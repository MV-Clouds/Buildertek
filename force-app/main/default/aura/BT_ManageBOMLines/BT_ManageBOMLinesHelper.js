({

    getPoLinesList: function (component, event, helper, pageNumber, pageSize, headerIndex) {
        console.time('getPoLinesList');
        component.set("v.isLoading", true);
        var recId = component.get("v.recordId");

        var action = component.get("c.getProductOptionLines");
        action.setParams({
            pageNumber: pageNumber,
            pageSize: pageSize,
            recordId: recId,
        });
        action.setCallback(this, function (response) {

            var state = response.getState();
            if (state === "SUCCESS") {
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();

                component.set("v.bomLineFieldsSettings", result.bomLineFieldSettings);
                component.set("v.recordsList", result.recordList);
                component.set("v.fieldValues", JSON.parse(result.fieldValues));
                var fieldValues = JSON.parse(result.fieldValues)
                for (var i in fieldValues) {
                    if (fieldValues[i].name == 'buildertek__UOM_Picklist__c') {
                        var field = fieldValues[i];
                        if (field.pickListValuesList != undefined) {
                            component.set('v.UOMpickListValues', field.pickListValuesList);
                        }
                    }
                }
                // // console.log(component.get("v.fieldValues"));
                component.set("v.PageNumber", result.pageNumber);
                component.set("v.TotalRecords", result.totalRecords);
                component.set("v.RecordStart", result.recordStart);
                component.set("v.RecordEnd", result.recordEnd);
                component.set(
                    "v.TotalPages",
                    Math.ceil(result.totalRecords / pageSize)
                );

                var resultData = [];
                result.recordList.forEach(function (item, index) {
                    resultData.push(item);
                });
                var rows = resultData;
                if (rows != undefined) {
                    for (var i = 0; i < rows.length; i++) {
                        var row = rows[i];

                        if (row.buildertek__Vendor__c) {
                            row.VendorName = row.buildertek__Vendor__r.Name;
                        }
                        if (row.buildertek__Purchase_Order__c) {
                            row.PurchaseOrder = row.buildertek__Purchase_Order__r.Name;
                        }
                        if (row.buildertek__Product_Type__c) {
                            row.ProductType = row.buildertek__Product_Type__r.Name;
                        }
                        if (row.buildertek__Category__c) {
                            row.CategoryName = row.buildertek__Category__r.Name;
                        }
                        if (row.buildertek__Trade_Type__c) {
                            row.Tradetype = row.buildertek__Trade_Type__r.Name;
                        }
                        if (row.buildertek__Build_Phase__c) {
                            row.BuildPhase = row.buildertek__Build_Phase__r.Name;
                        }
                        if (row.buildertek__Product__c) {
                            row.ProductName = row.buildertek__Product__r.Name;
                        }
                        if (row.Name) {
                            row.linkName = "/" + row.Id;
                        }
                    }
                }
                component.set("v.orgData", rows);
                component.set("v.data", rows);
                component.set("v.cloneDataByGroup", result.priceBookMap);
                var groupByData = component.get("v.orgData");
                component.set("v.fieldmaptype", result.fieldtypemap);
                component.set(
                    "v.sObjectRecords",
                    JSON.parse(result.sObjectRecordsList)
                );

                helper.formatDataByGroups(
                    component,
                    event,
                    helper,
                    groupByData,
                    result.fieldtypemap,
                    JSON.parse(result.sObjectRecordsList),
                    headerIndex
                );

                component.set("v.isLoading", false);
                console.timeEnd('getPoLinesList');
            } else {
                component.set("v.isLoading", false);
            }
        });
        $A.enqueueAction(action);
    },

    formatDataByGroups: function (
        component,
        event,
        helper,
        mapData,
        fieldtypemap,
        sObjectRecordsList,
        headerIndex
    ) {
        console.time('formatDataByGroups');

        try {
            let recordsMap = new Map();
            let sObjectRecordsMap = new Map();
            for (var kkk in sObjectRecordsList) {
                sObjectRecordsMap.set(
                    sObjectRecordsList[kkk].Id,
                    sObjectRecordsList[kkk]
                );
            }

            for (var i in mapData) {
                if (mapData[i].sheetrecord.buildertek__Vendor__c) {
                    if (
                        !recordsMap.has(
                            mapData[i].sheetrecord.buildertek__Vendor__r.Id +
                            "(#&%*)" +
                            mapData[i].sheetrecord.buildertek__Vendor__r.Name
                        )
                    ) {
                        recordsMap.set(
                            mapData[i].sheetrecord.buildertek__Vendor__r.Id +
                            "(#&%*)" +
                            mapData[i].sheetrecord.buildertek__Vendor__r.Name,
                            []
                        );
                    }
                    mapData[i]["sheetrecord"]["showIcon"] = mapData[i]["isShowIcon"];
                    recordsMap
                        .get(
                            mapData[i].sheetrecord.buildertek__Vendor__r.Id +
                            "(#&%*)" +
                            mapData[i].sheetrecord.buildertek__Vendor__r.Name
                        )
                        .push(mapData[i].sheetrecord);
                } else {
                    if (!recordsMap.has("No Vendor")) {
                        recordsMap.set("No Vendor", []);
                    }
                    mapData[i]["sheetrecord"]["showIcon"] = mapData[i]["isShowIcon"];
                    recordsMap
                        .get("No Vendor")
                        .push(mapData[i].sheetrecord);
                }
            }

            var result = Array.from(recordsMap.entries());
            var groupData = [];
            var totalRecords = 0;
            var totalCost = 0;
            var totalSalesPrice = 0;

            console.log('mapData ', mapData);
            console.log('sObjectRecordsMap ', sObjectRecordsMap);
            console.log('result ', result);


            for (var i in result) {
                var newObj = {};
                if (result[i][0].indexOf("(#&%*)") > -1) {
                    newObj["groupName"] = result[i][0].split("(#&%*)")[1];
                } else {
                    newObj["groupName"] = result[i][0];
                }
                var newObj_groupData = result[i][1];

                var sObjectRecordsList = [];
                for (var j in newObj_groupData) {
                    sObjectRecordsList.push(
                        sObjectRecordsMap.get(newObj_groupData[j].Id)
                    );
                    totalCost += newObj_groupData[j].buildertek__Extended_Cost__c;
                    totalSalesPrice += newObj_groupData[j].buildertek__Total_Sales_Price__c;
                }

                newObj.sObjectRecordsList = sObjectRecordsList;

                let costCodeArray = [];

                sObjectRecordsList.forEach(row => {
                    let costCode = row.buildertek__Cost_Code__c ? row.buildertek__Cost_Code__r.Name : 'No Cost Code';
                    const existingIndex = costCodeArray.findIndex(item => item.costCode === costCode);
                    if (existingIndex === -1) {
                        // If the cost code doesn't exist in the array, add a new entry
                        costCodeArray.push({
                            costCode: costCode,
                            records: [row]
                        });
                    } else {
                        // If the cost code already exists in the array, push the record to its records array
                        costCodeArray[existingIndex].records.push(row);
                    }
                });

                newObj["sObjectListWithCostCodeGroup"] = costCodeArray;

                newObj["massUpdate"] = false;

                groupData.push(newObj);
            }


            console.log('totalCost : ', totalCost);
            component.set("v.totalCost", totalCost);
            component.set("v.totalSalesPrice", totalSalesPrice);

            component.set("v.totalBOMlines", totalRecords);
            component.set("v.dataByGroup", groupData);
            component.set("v.Init_dataByGroup", groupData);
            console.log('From formatDataByGroups >> ', component.get("v.dataByGroup"));
            component.set("v.isLoading", false);
        }
        catch (error) {
            console.log('error in formatDataByGroups : ', error.stack);
        }
        console.timeEnd('formatDataByGroups');
    },

    showToast: function (component, event, helper, title, message, type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            mode: "pester",
            message: message,
            type: type,
            duration: 2,
        });
        toastEvent.fire();
        component.set("v.isLoading", false);
    },

    MassUpdateHelper: function (component, event, helper, headerIndex) {
        // debugger;
        console.time('MassUpdateHelper');
        component.set("v.isLoading", true);
        var data = component.get("v.dataByGroup");
        let priceBookMap = component.get("v.cloneDataByGroup");
        var BOMlinesWithoutName = [];
        var groupName = '';
        var newList = [];
        for (var i in data) {
            if (headerIndex == i) {
                for (var j in data[i].sObjectRecordsList) {
                    if (data[i].sObjectRecordsList[j].Name == null || (data[i].sObjectRecordsList[j].Name).trim() == '') {
                        BOMlinesWithoutName.push(parseInt(j) + 1);
                        groupName = data[i].groupName;
                    }
                    else {
                        console.log('data[i].sObjectRecordsList[j] : ', data[i].sObjectRecordsList[j]);
                        newList.push(data[i].sObjectRecordsList[j]);
                    }

                    // When you use RecordEdit form, for black value it shows emptly list instead of null value....
                    // If Vendor or Takeoff line is null it shows empty list, that need to in null value...
                    if (data[i].sObjectRecordsList[j].buildertek__Vendor__c && data[i].sObjectRecordsList[j].buildertek__Vendor__c.length == 0) {
                        data[i].sObjectRecordsList[j].buildertek__Vendor__c = null;
                    }
                    if (data[i].sObjectRecordsList[j].buildertek__Takeoff_Line__c && data[i].sObjectRecordsList[j].buildertek__Takeoff_Line__c.length == 0) {
                        data[i].sObjectRecordsList[j].buildertek__Takeoff_Line__c = null;
                    }

                }
            }
        }
        if (BOMlinesWithoutName.length > 0) {
            var Title = 'Error at line no. - ' + BOMlinesWithoutName.join(', ') + '.';
            var Message = 'You can not update items without Product Name Proposal. Phase Name : ' + groupName + '.'
            helper.ToastMessageUtilityMethod(component, Title, Message, 'error', 7000);
            component.set("v.isLoading", false);
        }
        else {

            console.log('update records : ', newList);
            var action = component.get("c.updateBOMlines");
            action.setParams({
                recordId: component.get("v.recordId"),
                updatedRecords: JSON.stringify(newList),
            });

            action.setCallback(this, function (response) {
                var Result = response.getReturnValue();
                if (Result === "successfull") {
                    var pageNumber = component.get("v.PageNumber");
                    var pageSize = component.get("v.pageSize");

                    var groupData = component.get("v.dataByGroup");
                    console.log('groupData : ', groupData);
                    groupData.forEach(vendorGroup => {
                        vendorGroup.sObjectListWithCostCodeGroup.forEach(costCodeGroup => {
                            costCodeGroup.records.forEach(record => {
                                console.log('map value : ', priceBookMap[record.buildertek__BT_Price_Book__c]);
                                record.buildertek__BT_Price_Book__r = priceBookMap[record.buildertek__BT_Price_Book__c];
                                console.log('record value : ', record.buildertek__BT_Price_Book__r);
                            });
                        });
                    });
                    groupData[headerIndex].massUpdate = false;
                    component.set("v.dataByGroup", groupData);

                    // helper.getPoLinesList(component, event, helper, pageNumber, pageSize, headerIndex);
                    helper.ToastMessageUtilityMethod(component, "Success", 'Lines updated successfully', 'success', 3000);
                    component.set("v.isLoading", false);
                    // $A.get('e.force:refreshView').fire();
                    console.timeEnd('MassUpdateHelper');
                }
                else {
                    helper.ToastMessageUtilityMethod(component, "Error", 'Something Went Wrong', 'error', 3000);
                    component.set("v.isLoading", false);
                }
            });
            $A.enqueueAction(action);
        }
    },

    ToastMessageUtilityMethod: function (component, Title, Message, Type, Duration) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: Title,
            message: Message,
            type: Type,
            duration: Duration,
        });
        toastEvent.fire();
    },

    setProduct: function (component, event, helper, setProduct) {
        try {

            var index = event.getParam("index");
            var headerIndex0 = event.getParam("phaseIndex");
            var headerIndex = event.getParam("phaseIndexValue");

            var groupData = component.get("v.dataByGroup");
            debugger
            if (setProduct) {
                console.log("product : ", JSON.parse(JSON.stringify(event.getParam("recordByEvent"))));
                var product = JSON.parse(JSON.stringify(event.getParam("recordByEvent")));
                if (product) {
                    console.log('pricebookEntrybyProd : ', JSON.parse(JSON.stringify(event.getParam("PricebookEntryrecordByEvent"))));
                    var pricebookEntry = event.getParam("PricebookEntryrecordByEvent");
                    var uom = product.QuantityUnitOfMeasure;
                    var unitCost = pricebookEntry != null ? (pricebookEntry.buildertek__Unit_Cost__c != null ? pricebookEntry.buildertek__Unit_Cost__c : 0) : 0;
                    var markupPrecentage = pricebookEntry != null ? (pricebookEntry.buildertek__Markup__c != null ? pricebookEntry.buildertek__Markup__c : 0) : 0;
                    var markup = markupPrecentage != 0 ? markupPrecentage / 100 : 0;
                    var quantity = groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__Quantity__c;
                    var UOMpickListValues = component.get("v.UOMpickListValues");
                    uom = UOMpickListValues.includes(uom) ? uom : null;

                    console.log('phase 2');

                    groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__Product__r = product;
                    groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__Product__c = product.Id;
                    groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].Name = product.Name;
                    groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__Vendor__c = product.buildertek__Vendor__c;
                    groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__UOM_Picklist__c = uom;
                    groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__BL_UNIT_COST__c = unitCost;
                    groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__BL_MARKUP__c = markupPrecentage;
                    groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__Extended_Cost__c = (quantity * unitCost);
                    groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__BL_LIST_PRICE_F__c = ((unitCost * markup) + unitCost);
                    groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__Total_Sales_Price__c = ((unitCost * markup) + unitCost) * quantity;
                    console.log('phase 3');

                }
            }
            else {
                groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__Product__r = null;
                groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__Product__c = null;
                groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].Name = null;
                groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__Vendor__c = null;
                groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__UOM_Picklist__c = null;
                groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__BL_UNIT_COST__c = 0;
                groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__BL_MARKUP__c = 0;
                groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__Extended_Cost__c = 0;
                groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__BL_LIST_PRICE_F__c = 0;
                groupData[headerIndex0].sObjectListWithCostCodeGroup[headerIndex].records[index].buildertek__Total_Sales_Price__c = 0;
            }
            component.set("v.dataByGroup", groupData);

            window.setTimeout(
                $A.getCallback(function () {
                    component.set("v.isLoading", false);
                }),
                500
            );
        } catch (error) {
            console.log('error in setProduct : ', error);

        }
    },

    //   valueChnagedInFildsetMassUpdateHelper : function(component, event, helper){
    onInputChangeHelper: function (component, event, helper, updatedValue, changedField, index, headerIndex) {
        try {

            var groupData = component.get("v.dataByGroup");
            var quantity = 0;
            var markupPrecentage = 0;
            var unitCost = 0;
            if (changedField == 'buildertek__Quantity__c') {
                //  quantity =  parseFloat(event.getParam("changedValueByEnvent_Integer"));
                quantity = updatedValue;
                markupPrecentage = groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_MARKUP__c;
                unitCost = groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_UNIT_COST__c;
            }
            else if (changedField == 'buildertek__BL_MARKUP__c') {
                //  markup =  parseFloat(event.getParam("changedValueByEnvent_Integer"));
                markupPrecentage = updatedValue;
                quantity = groupData[headerIndex].sObjectRecordsList[index].buildertek__Quantity__c;
                unitCost = groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_UNIT_COST__c;

            }
            else if (changedField == 'buildertek__BL_UNIT_COST__c') {
                //  unitCost = parseFloat(event.getParam("changedValueByEnvent_Integer"));
                unitCost = updatedValue;
                quantity = groupData[headerIndex].sObjectRecordsList[index].buildertek__Quantity__c;
                markupPrecentage = groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_MARKUP__c;
            }

            markupPrecentage = markupPrecentage != null ? markupPrecentage : 0;
            var markup = markupPrecentage != 0 ? markupPrecentage / 100 : 0;
            unitCost = unitCost != null ? parseFloat(unitCost) : 0;
            quantity = quantity != null ? parseFloat(quantity) : 0;

            // console.log('unitCost : ', unitCost);
            // console.log('quantity : ', quantity);
            // console.log('markup : ', markup);
            groupData[headerIndex].sObjectRecordsList[index].buildertek__Extended_Cost__c = (quantity * unitCost);
            groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_LIST_PRICE_F__c = ((unitCost * markup) + unitCost);
            groupData[headerIndex].sObjectRecordsList[index].buildertek__Total_Sales_Price__c = ((unitCost * markup) + unitCost) * quantity;

            component.set("v.dataByGroup", groupData);
            // console.log('dataByGroup : ', JSON.parse(JSON.stringify(component.get("v.dataByGroup"))));

            window.setTimeout(
                $A.getCallback(function () {
                    component.set("v.isLoading", false);
                }),
                500
            );
        }
        catch (error) {
            console.log('error in valueChnagedInFildsetMassUpdate : ', error.stack);

        }
    },

})