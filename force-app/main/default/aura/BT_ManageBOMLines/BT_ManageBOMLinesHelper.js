({

    storeAllData: [],
    setColumns: function (component) {
        component.set("v.columns", [
            {
                label: "Name",
                fieldName: "linkName",
                type: "url",
                typeAttributes: {
                    label: { fieldName: "Name" },
                    target: "_blank",
                    tooltip: { fieldName: "Name" },
                },
                sortable: true,
            },
            {
                label: "Vendor",
                fieldName: "VendorName",
                //fieldName : 'buildertek__Vendor__r.Name',
                type: "text",
                sortable: true,
            },
            /* {
                      label : 'Product',
                      //buildertek__Product__c
                      fieldName : 'ProductName',
                      type : 'text',
                      sortable : true
                  },
                  {
                      label: 'Build Phase',
                      //buildertek__Build_Phase__c
                      fieldName : 'BuildPhase',
                      type: 'text',
                      sortable : true
                  },
                  {
                      label : 'Trade Type',
                      //buildertek__Trade_Type__c
                      fieldName : 'Tradetype',
                      type : 'text',
                      sortable : true
                  },*/
            {
                label: "Category",
                //buildertek__Category__c
                fieldName: "CategoryName",
                type: "text",
                sortable: true,
            },
            //buildertek__Purchase_Order__c,buildertek__Purchase_Order__r.Name
            {
                label: "Purchase order",
                //buildertek__Category__c
                fieldName: "PurchaseOrder",
                type: "text",
                sortable: true,
            },
            {
                label: "Product Type",
                //buildertek__Product_Type__c
                fieldName: "ProductType",
                type: "text",
                sortable: true,
            },
            {
                label: "Location",
                fieldName: "buildertek__Location_Picklist__c",
                type: "Picklist",
                sortable: true,
            },
            {
                label: "Standard",
                fieldName: "buildertek__Standard__c",
                type: "Picklist",
                sortable: true,
            },
            /* {
                      label : 'Upgrade Price',
                      fieldName : 'buildertek__Upgrade_Price__c',
                      type : 'currency',
                      sortable : true,
                      cellAttributes: { alignment: 'left' }
                  },*/
            {
                label: "Quantity",
                fieldName: "buildertek__Quantity__c",
                type: "number",
                sortable: true,
            },
            {
                label: "List Price",
                fieldName: "buildertek__BL_LIST_PRICE__c",
                type: "Currency",
                sortable: true,
            },
            {
                label: "Discount",
                fieldName: "buildertek__BL_DISCOUNT__c",
                type: "Percent",
                sortable: true,
            },
            {
                label: "Markup",
                fieldName: "buildertek__BL_MARKUP__c",
                type: "Percent",
                sortable: true,
            },
            {
                label: "Unit Cost",
                fieldName: "buildertek__BL_UNIT_COST__c",
                type: "Currency",
                sortable: true,
            },
        ]);
    },

    fetchTakeOffLinesData: function (component, event, helper) {
        var action = component.get("c.getTakeOffLinesData");
        action.setCallback(this, function (response) {
            // debugger;
            console.log('getTakeOffLinesData Response : ', response.getReturnValue());
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                // console.log("fetchTakeOffLinesData");
                // console.log({ result });
                if (result != null) {

                    component.set("v.bomLineFieldsSettings", result.bomLineFieldSettings);
                    var bomSelectedFieldsLength =
                        result.bomLineselectedFields.split(",").length;
                    bomSelectedFieldsLength = bomSelectedFieldsLength + 2;
                    component.set("v.bomLineselectedFieldsLength", bomSelectedFieldsLength);
                    component.set("v.bomLineselectedFields", result.bomLineselectedFields);
                    // console.log('>>>>>>>>>>>>>>>>>>>>>>>>>' , component.get("v.bomLineselectedFields"));
                }
                var getBOMLineFieldMapAction = component.get(
                    "c.getBOMLineFiledNameAndApi"
                );
                component.set("v.isSpinner", true);
                getBOMLineFieldMapAction.setCallback(this, function (response) {
                    console.log('getBOMLineFieldMapAction response : ', response.getReturnValue());
                    // debugger;
                    var state = response.getState();
                    if (state === "SUCCESS") {
                        component.set("v.isSpinner", true);
                        var result = response.getReturnValue();
                        component.set("v.fieldBOMLineNameApiMap", result);
                        var neList = [];
                        neList = Object.values(result);
                        // // console.log(neList)
                        component.set("v.fieldBOMLineNameApiList", neList);
                        component.set("v.isSpinner", false);
                    }
                });
                $A.enqueueAction(getBOMLineFieldMapAction);

                component.set("v.isSpinner", false);
            } else {
                helper.showToast(
                    component,
                    event,
                    helper,
                    "Error!",
                    "Something went wrong!",
                    "error"
                );
                // // console.log('Error');
            }
        });
        $A.enqueueAction(action);
    },

    getPoLinesList: function (component, event, helper, pageNumber, pageSize, headerIndex) {
        component.set("v.isLoading", true);

        var vendorValue = component.get("v.searchVendorFilter");
        var categoryValue = component.get("v.searchCategoryFilter");
        var tradeTypeValue = component.get("v.searchTradeTypeFilter");
        var productTypeValue = component.get("v.searchProductTypeFilter");
        var purchaseOrderValue = component.get("v.searchPurchaseOrderFilter");
        var buildPhaseValue = component.get("v.searchBuildPhaseFilter");
        var toggleVal = component.get("v.groupBytoggle");
        var recId = component.get("v.recordId");

        //dynamic filter
        var bomLineOptionlist = component.get("v.fieldBOMLineNameApiList");
        var filter2 = "";
        if (bomLineOptionlist != undefined) {
            for (var i = 0; i < bomLineOptionlist.length; i++) {
                if (bomLineOptionlist[i].Value) {
                    var fieldApiName = bomLineOptionlist[i]["Name"];
                    if (bomLineOptionlist[i].Type == "REFERENCE") {
                        var fieldApiName1 = fieldApiName.split("__c")[0];
                        var value = "'%" + bomLineOptionlist[i].Value + "%'";
                        filter2 += " AND " + fieldApiName1 + "__r.Name LIKE " + value;
                    } else if (
                        bomLineOptionlist[i].Type == "STRING" ||
                        bomLineOptionlist[i].Type == "PICKLIST"
                    ) {
                        var STRvalue = "'%" + bomLineOptionlist[i].Value + "%'";
                        filter2 += " AND " + fieldApiName + " LIKE " + STRvalue;
                    } else if (bomLineOptionlist[i].Type == "DOUBLE") {
                        var value1 = JSON.parse(bomLineOptionlist[i].Value);
                        filter2 += " AND " + fieldApiName + " =" + value1;
                    } else if (bomLineOptionlist[i].Type == "DATETIME") {
                        var dateVal = bomLineOptionlist[i].Value; // new Date(optionlist[i].Value);
                        filter2 += " AND " + fieldApiName + " >=" + dateVal;
                    } else if (bomLineOptionlist[i].Type == "DATE") {
                        var dateVal = bomLineOptionlist[i].Value; // new Date(optionlist[i].Value);
                        filter2 += " AND " + fieldApiName + " >=" + dateVal;
                    }
                    // // console.log(filter2);
                }
            }
        }

        var action = component.get("c.getProductOptionLines");
        action.setParams({
            pageNumber: pageNumber,
            pageSize: pageSize,
            recordId: recId,
            vendorName: vendorValue,
            category: categoryValue,
            tradeType: tradeTypeValue,
            purchaseOrder: purchaseOrderValue,
            productType: productTypeValue,
            buildPhase: buildPhaseValue,
            toggleValue: toggleVal,
            filter: filter2,
        });
        action.setCallback(this, function (response) {
            // debugger;
            console.log('getProductOptionLines response : ', response.getReturnValue());
            var state = response.getState();
            if (state === "SUCCESS") {
                var pageSize = component.get("v.pageSize");
                var result = response.getReturnValue();

                component.set("v.recordsList", result.recordList);
                component.set("v.fieldValues", JSON.parse(result.fieldValues));
                var fieldValues = JSON.parse(result.fieldValues)
                for(var i in fieldValues){
                    if(fieldValues[i].name == 'buildertek__UOM_Picklist__c'){
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
                // // console.log('&**&*&*&*&*&*& ',result.recordList);
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
                //component.set("v.totalRecords", component.get("v.masterBudgetsList").length);

                /*var PaginationList = [];
                        for(var i=0; i< pageSize; i++){
                            if(component.get("v.masterBudgetsList").length> i)
                                PaginationList.push(result[i]);    
                        }*/
                // component.set('v.PaginationList', PaginationList);
                component.set("v.isLoading", false);
            } else {
                component.set("v.isLoading", false);
                // // console.log(response.getError())
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
        try {

            let recordsMap = new Map();
            let sObjectRecordsMap = new Map();
            for (var kkk in sObjectRecordsList) {
                sObjectRecordsMap.set(
                    sObjectRecordsList[kkk].Id,
                    sObjectRecordsList[kkk]
                );
            }

            var massupdateIndex = JSON.parse(JSON.stringify(component.get("v.massupdateIndex")));
            // console.log('formate data massupdateIndex ', massupdateIndex);

            for (var i in mapData) {
                var toggleVal = component.get("v.groupBytoggle");

                // if (component.get("v.groupByPhasetoggle")) {
                    //group by phase
                    if (mapData[i].sheetrecord.buildertek__Build_Phase__c) {
                        if (
                            !recordsMap.has(
                                mapData[i].sheetrecord.buildertek__Build_Phase__r.Id +
                                "(#&%*)" +
                                mapData[i].sheetrecord.buildertek__Build_Phase__r.Name
                            )
                        ) {
                            recordsMap.set(
                                mapData[i].sheetrecord.buildertek__Build_Phase__r.Id +
                                "(#&%*)" +
                                mapData[i].sheetrecord.buildertek__Build_Phase__r.Name,
                                []
                            );
                        }
                        mapData[i]["sheetrecord"]["showIcon"] = mapData[i]["isShowIcon"];
                        recordsMap
                            .get(
                                mapData[i].sheetrecord.buildertek__Build_Phase__r.Id +
                                "(#&%*)" +
                                mapData[i].sheetrecord.buildertek__Build_Phase__r.Name
                            )
                            .push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                    } else {
                        if (!recordsMap.has("No Build Phase")) {
                            recordsMap.set("No Build Phase", []);
                        }
                        mapData[i]["sheetrecord"]["showIcon"] = mapData[i]["isShowIcon"];
                        recordsMap
                            .get("No Build Phase")
                            .push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                    }
                // }
            }
            var result = Array.from(recordsMap.entries());
            var groupData = [];
            var totalRecords = 0;
            var totalCost = 0;
            var totalSalesPrice = 0;

            for (var i in result) {
                var newObj = {};
                if (result[i][0].indexOf("(#&%*)") > -1) {
                    newObj["groupName"] = result[i][0].split("(#&%*)")[1];
                } else {
                    newObj["groupName"] = result[i][0];
                }
                var newObj_groupData = result[i][1];

                //dynamic field
                var selectedFields = component.get("v.bomLineselectedFields").split(",");
                var mainList = [];
                var sObjectRecordsList = [];
                for (var j in newObj_groupData) {
                    sObjectRecordsList.push(
                        sObjectRecordsMap.get(newObj_groupData[j].Id)
                    );
                    totalCost += newObj_groupData[j].buildertek__Extended_Cost__c;
                    totalSalesPrice += newObj_groupData[j].buildertek__Total_Sales_Price__c;
                }

                newObj.sObjectRecordsList = sObjectRecordsList;
                
                // if(massupdateIndex.includes(parseInt(i))){
                //     console.log(' Index match : ', i);
                //     newObj["massUpdate"] = true;
                // }
                // else{
                //     newObj["massUpdate"] = false;
                // }
            
                newObj["massUpdate"] = false;

                groupData.push(newObj);
            }


            console.log('totalCost : ', totalCost);
            component.set("v.totalCost", totalCost);
            component.set("v.totalSalesPrice", totalSalesPrice);

            component.set("v.totalBOMlines", totalRecords);
            component.set("v.dataByGroup", groupData);
            component.set("v.Init_dataByGroup", JSON.parse(JSON.stringify(groupData)));
            component.set("v.cloneDataByGroup", groupData);
            console.log('From formatDataByGroups >> ', JSON.parse(JSON.stringify(component.get("v.dataByGroup"))));
                component.set("v.isLoading", false);
        }
        catch (error) {
            console.log('error in formatDataByGroups : ', error.stack);

        }
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

    MassUpdateHelper: function(component, event, helper, headerIndex){
        // debugger;
        component.set("v.isLoading", true);
        var x = component.get("v.dataByGroup");
        var data = JSON.parse(JSON.stringify(component.get("v.dataByGroup")));
        var BOMlinesWithoutName = [];
        var groupName = '';
        var newList = [];
        for (var i in data) {
            if(headerIndex == i){
                for (var j in data[i].sObjectRecordsList) {
                    if(data[i].sObjectRecordsList[j].Name == null || (data[i].sObjectRecordsList[j].Name).trim()  == ''){
                        BOMlinesWithoutName.push(parseInt(j) + 1);
                        groupName = data[i].groupName;
                    }
                    else{
                        newList.push(data[i].sObjectRecordsList[j]);
                    }

                    // When you use RecordEdit form, for black value it shows emptly list instead of null value.... 
                    // If Vendor or Takeoff line is null it shows empty list, that need to in null value...
                    if(data[i].sObjectRecordsList[j].buildertek__Vendor__c && data[i].sObjectRecordsList[j].buildertek__Vendor__c.length == 0){
                        data[i].sObjectRecordsList[j].buildertek__Vendor__c = null;
                    }
                    if(data[i].sObjectRecordsList[j].buildertek__Takeoff_Line__c && data[i].sObjectRecordsList[j].buildertek__Takeoff_Line__c.length == 0){
                        data[i].sObjectRecordsList[j].buildertek__Takeoff_Line__c = null;
                    }
                  
                }
            }
        }
        if(BOMlinesWithoutName.length > 0){
            var Title = 'Error at line no. - '+ BOMlinesWithoutName.join(', ')+ '.';
            var Message = 'You can not update items without Product Name Proposal. Phase Name : '+ groupName +'.'
            helper.ToastMessageUtilityMethod(component, Title, Message, 'error', 7000);
            component.set("v.isLoading", false);
        }
        else{

            console.log('update records : ' , newList);
            var action = component.get("c.updateBOMlines");
            action.setParams({
            recordId: component.get("v.recordId"),
            updatedRecords: JSON.stringify(newList),
            });
    
            action.setCallback(this, function (response) {
            var state = response.getState();
            var Result = response.getReturnValue();
            if (Result === "successfull") {
                    var pageNumber = component.get("v.PageNumber");
                    var pageSize = component.get("v.pageSize");
    
                    var groupData = component.get("v.dataByGroup");
                    groupData[headerIndex].massUpdate = false;
                    component.set("v.dataByGroup", groupData);
                    
                    // var massupdateIndex = component.get("v.massupdateIndex");
                    // massupdateIndex = massupdateIndex.filter(ele => ele !== headerIndex)
                    // component.set("v.massupdateIndex", massupdateIndex);
                    // console.log('formate data apex call ', massupdateIndex);
                    
                    helper.getPoLinesList(component, event, helper, pageNumber, pageSize, headerIndex);
                    helper.ToastMessageUtilityMethod(component, "Success", 'Lines updated successfully', 'success', 3000);
            }
            else {
                helper.ToastMessageUtilityMethod(component, "Error", 'Something Went Wrong', 'error', 3000);
                component.set("v.isLoading", false);
            }
            });
            $A.enqueueAction(action);
        }
    },

    ToastMessageUtilityMethod: function(component, Title, Message, Type, Duration){
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : Title,
            message: Message,
            type: Type,
            duration: Duration,
        });
        toastEvent.fire();
    },

    setProduct: function(component, event, helper, setProduct){
        try {
            
            var index = event.getParam("index");
            var headerIndex = event.getParam("phaseIndex");
            
            var groupData = component.get("v.dataByGroup");
            if(setProduct){
                console.log("product : ", JSON.parse(JSON.stringify(event.getParam("recordByEvent"))));
                var product = JSON.parse(JSON.stringify(event.getParam("recordByEvent")));
                if(product){
                    console.log('pricebookEntrybyProd : ' ,  JSON.parse(JSON.stringify(event.getParam("PricebookEntryrecordByEvent"))));
                    var pricebookEntry = event.getParam("PricebookEntryrecordByEvent");
                    var uom = product.QuantityUnitOfMeasure;
                    var unitCost = pricebookEntry != null ? (pricebookEntry.buildertek__Unit_Cost__c != null ? pricebookEntry.buildertek__Unit_Cost__c : 0) : 0;
                    var markupPrecentage = pricebookEntry != null ? (pricebookEntry.buildertek__Markup__c != null ? pricebookEntry.buildertek__Markup__c : 0) : 0;
                    var markup = markupPrecentage != 0 ? markupPrecentage / 100 : 0;
                    var quantity = groupData[headerIndex].sObjectRecordsList[index].buildertek__Quantity__c;
                    var UOMpickListValues = component.get("v.UOMpickListValues");
                    uom = UOMpickListValues.includes(uom) ? uom : null;

                    console.log('phase 2');
    
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Product__r = product;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Product__c = product.Id;
                    groupData[headerIndex].sObjectRecordsList[index].Name = product.Name;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Vendor__c = product.buildertek__Vendor__c;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__UOM_Picklist__c = uom;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_UNIT_COST__c = unitCost;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_MARKUP__c = markupPrecentage;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Extended_Cost__c = (quantity * unitCost);
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_LIST_PRICE_F__c = ((unitCost * markup) + unitCost);
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Total_Sales_Price__c = ((unitCost * markup) + unitCost) * quantity;
                    console.log('phase 3');

                }
              }
              else {
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Product__r = null;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Product__c = null;
                    groupData[headerIndex].sObjectRecordsList[index].Name = null;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Vendor__c = null;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__UOM_Picklist__c = null;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_UNIT_COST__c = 0;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_MARKUP__c = 0;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Extended_Cost__c = 0;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_LIST_PRICE_F__c = 0;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Total_Sales_Price__c = 0;
              }
                component.set("v.dataByGroup", groupData);
    
                window.setTimeout(
                    $A.getCallback(function () {
                    component.set("v.isLoading", false);
                    }),
                    500
                );
        } catch (error) {
            console.log('error in setProduct : ', error.stack);
            
        }
      },

    //   valueChnagedInFildsetMassUpdateHelper : function(component, event, helper){
      onInputChangeHelper : function(component, event, helper, updatedValue, changedField, index, headerIndex){
        try{
            
            var groupData = component.get("v.dataByGroup");
            var quantity = 0;
            var markupPrecentage = 0;
            var unitCost = 0;
            if(changedField == 'buildertek__Quantity__c'){
                //  quantity =  parseFloat(event.getParam("changedValueByEnvent_Integer"));
                quantity =  updatedValue;
                markupPrecentage = groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_MARKUP__c;
                unitCost = groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_UNIT_COST__c;
            }
            else if(changedField == 'buildertek__BL_MARKUP__c'){
                //  markup =  parseFloat(event.getParam("changedValueByEnvent_Integer"));
                markupPrecentage =  updatedValue;
                 quantity = groupData[headerIndex].sObjectRecordsList[index].buildertek__Quantity__c;
                 unitCost = groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_UNIT_COST__c;

            }
            else if(changedField == 'buildertek__BL_UNIT_COST__c'){
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
        catch(error){
            console.log('error in valueChnagedInFildsetMassUpdate : ', error.stack);
            
        }
      },

})