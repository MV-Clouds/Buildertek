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

    // checkFabricationTaxes: function (component, event, helper) {
    //     var BOMID = component.get("v.recordId");
    //     var action = component.get("c.checkFabricationTaxes");

    //     action.setCallback(this, function (response) {
    //         var state = response.getState();
    //         console.log('checkFabricationTaxes response : ', response.getReturnValue());

    //         if (state === "SUCCESS") {
    //             var fabricationCheck = response.getReturnValue();
    //             if (
    //                 fabricationCheck != null &&
    //                 fabricationCheck != undefined &&
    //                 fabricationCheck == true
    //             ) {
    //                 component.set("v.showFabricationDetails", fabricationCheck);
    //                 var action = component.get("c.handleBTAdmin");
    //                 $A.enqueueAction(action);
    //             }
    //         } else {
    //             helper.showToast(
    //                 component,
    //                 event,
    //                 helper,
    //                 "Error!",
    //                 "Something went wrong!",
    //                 "error"
    //             );
    //             // // console.log('Not success');
    //         }
    //     });

    //     $A.enqueueAction(action);
    // },

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
                //component.set("v.masterBudgetsList", result);
                // alert('** result.sObjectRecordsList  ---------->:');
                // console.log("** result.sObjectRecordsList --------------->:" +JSON.parse(JSON.stringify(result.sObjectRecordsList)));
                // console.log({ result });

                component.set("v.recordsList", result.recordList);
                component.set("v.listOfRecords", JSON.parse(result.sObjectRecordsList));
                component.set(
                    "v.cloneListOfRecords",
                    JSON.parse(result.sObjectRecordsList)
                );
                // component.set("v.fieldValues", blankFields);
                // // console.log('@@@@@@@-',JSON.parse(result.fieldValues));
                component.set("v.fieldValues", JSON.parse(result.fieldValues));
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
                // console.log("rows");
                // console.log({ rows });
                component.set("v.orgData", rows);
                component.set("v.data", rows);
                var groupByData = component.get("v.orgData");
                component.set("v.fieldmaptype", result.fieldtypemap);
                // console.log("result.sObjectRecordsList==" + result.sObjectRecordsList);
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
            console.log('formate data massupdateIndex ', massupdateIndex);
            //alert(sObjectRecordsMap);

            for (var i in mapData) {
                // console.log("mapData-->");
                // console.log({ mapData });
                var toggleVal = component.get("v.groupBytoggle");

                if (component.get("v.groupByPhasetoggle")) {
                    //group by phase
                    // console.log(mapData[i].sheetrecord.buildertek__Build_Phase__c);
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
                        //// // console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                        if (!recordsMap.has("No Build Phase")) {
                            recordsMap.set("No Build Phase", []);
                        }
                        //// // console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                        mapData[i]["sheetrecord"]["showIcon"] = mapData[i]["isShowIcon"];
                        recordsMap
                            .get("No Build Phase")
                            .push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                        //// // console.log(recordsMap.get("No vendor"))
                    }
                } else if (component.get("v.groupByVendortoggle")) {
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
                            .push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                    } else {
                        //// // console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                        if (!recordsMap.has("No Vendor")) {
                            recordsMap.set("No Vendor", []);
                        }
                        //// // console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                        mapData[i]["sheetrecord"]["showIcon"] = mapData[i]["isShowIcon"];
                        recordsMap
                            .get("No Vendor")
                            .push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                        //// // console.log(recordsMap.get("No vendor"))
                    }
                } else if (component.get("v.groupByCategorytoggle")) {
                    if (mapData[i].sheetrecord.buildertek__Category__c) {
                        if (
                            !recordsMap.has(
                                mapData[i].sheetrecord.buildertek__Category__r.Id +
                                "(#&%*)" +
                                mapData[i].sheetrecord.buildertek__Category__r.Name
                            )
                        ) {
                            recordsMap.set(
                                mapData[i].sheetrecord.buildertek__Category__r.Id +
                                "(#&%*)" +
                                mapData[i].sheetrecord.buildertek__Category__r.Name,
                                []
                            );
                        }
                        mapData[i]["sheetrecord"]["showIcon"] = mapData[i]["isShowIcon"];
                        recordsMap
                            .get(
                                mapData[i].sheetrecord.buildertek__Category__r.Id +
                                "(#&%*)" +
                                mapData[i].sheetrecord.buildertek__Category__r.Name
                            )
                            .push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                    } else {
                        //// // console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                        if (!recordsMap.has("No Category")) {
                            recordsMap.set("No Category", []);
                        }
                        //// // console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                        mapData[i]["sheetrecord"]["showIcon"] = mapData[i]["isShowIcon"];
                        recordsMap
                            .get("No Category")
                            .push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                        //// // console.log(recordsMap.get("No vendor"))
                    }
                } else if (component.get("v.groupByServiceCategorytoggle")) {
                    if (mapData[i].sheetrecord.buildertek__Takeoff_Line__c) {
                        /* if (!recordsMap.has(mapData[i].sheetrecord.buildertek__Service_Category__c + '(#&%*)' + mapData[i].sheetrecord.buildertek__Service_Category__c)) {
                                      recordsMap.set(mapData[i].sheetrecord.buildertek__Service_Category__c + '(#&%*)' + mapData[i].sheetrecord.buildertek__Service_Category__c, []);
                                  }
                                  mapData[i]['sheetrecord']['showIcon'] = mapData[i]['isShowIcon']
                                  recordsMap.get(mapData[i].sheetrecord.buildertek__Service_Category__c + '(#&%*)' + mapData[i].sheetrecord.buildertek__Service_Category__c).push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                              */
                        if (
                            !recordsMap.has(
                                mapData[i].sheetrecord.buildertek__BL_SERVICE_CATEGORY__c +
                                "(#&%*)" +
                                mapData[i].sheetrecord.buildertek__BL_SERVICE_CATEGORY__c
                            )
                        ) {
                            recordsMap.set(
                                mapData[i].sheetrecord.buildertek__BL_SERVICE_CATEGORY__c +
                                "(#&%*)" +
                                mapData[i].sheetrecord.buildertek__BL_SERVICE_CATEGORY__c,
                                []
                            );
                        }
                        mapData[i]["sheetrecord"]["showIcon"] = mapData[i]["isShowIcon"];
                        recordsMap
                            .get(
                                mapData[i].sheetrecord.buildertek__BL_SERVICE_CATEGORY__c +
                                "(#&%*)" +
                                mapData[i].sheetrecord.buildertek__BL_SERVICE_CATEGORY__c
                            )
                            .push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                    } else {
                        if (!recordsMap.has("No Service Category")) {
                            recordsMap.set("No Service Category", []);
                        }
                        mapData[i]["sheetrecord"]["showIcon"] = mapData[i]["isShowIcon"];
                        recordsMap
                            .get("No Service Category")
                            .push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
                    }
                }
            }
            var result = Array.from(recordsMap.entries());
            // console.log("result");
            // console.log({ result });
            var groupData = [];
            var totalRecords = 0;
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


            component.set("v.totalBOMlines", totalRecords);
            component.set("v.dataByGroup", groupData);
            // var Init_dataByGroup = $A.util.json.deepClone(groupData);
            // Init_dataByGroup.push(groupData);
            component.set("v.Init_dataByGroup", JSON.parse(JSON.stringify(groupData)));
            console.log('Inside formatDataByGroups >> ', component.get("v.dataByGroup"));
            // console.log("groupData===");
            // console.log({ groupData });
            component.set("v.cloneDataByGroup", groupData);
            // helper.calculateCostAdjustment(component, event, helper);
            console.log('From formatDataByGroups >> ', JSON.parse(JSON.stringify(component.get("v.dataByGroup"))));
            // $A.get('e.force:refreshView').fire();
            if (
                !component.get("v.massUpdateEnable") &&
                component.get("v.showFabricationDetails") == true
            ) {
                //   helper.calculateCostAdjustment(component, event, helper);
            }
            // $A.get('e.force:refreshView').fire();
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
                        BOMlinesWithoutName.push(j + 1);
                        groupName = data[i].groupName;
                    }
                    else{
                        newList.push(data[i].sObjectRecordsList[j]);
                    }
                }
            }
        }
        if(BOMlinesWithoutName.length > 0){
            var Message = 'You can not update items without Product Name Proposal. Item(s) at line no: '+ BOMlinesWithoutName.join(', ') + ' dose not have Product Name Proposal. Phase : '+ groupName +'.'
            helper.ToastMessageUtilityMethod(component, 'Error', Message, 'error', 5000);
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
                    helper.ToastMessageUtilityMethod(component, "Success", 'Records Updated Succcessfully', 'success', 3000);
                // component.set("v.massUpdateEnable", false);
                // component.set("v.isLoading", false);
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
                    console.log('pricebookEntrybyProd : ' ,  event.getParam("PricebookEntryrecordByEvent"));
                    var pricebookEntry = event.getParam("PricebookEntryrecordByEvent");
                    var uom = product.QuantityUnitOfMeasure;
                    var unitCost = pricebookEntry != null ? (pricebookEntry.buildertek__Unit_Cost__c != null ? pricebookEntry.buildertek__Unit_Cost__c : 0) : 0;
                    var markup = pricebookEntry != null ? (pricebookEntry.buildertek__Markup__c != null ? pricebookEntry.buildertek__Markup__c : 0) : 0;
                    var quantity = groupData[headerIndex].sObjectRecordsList[index].buildertek__Quantity__c;
    
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Product__r = product;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Product__c = product.Id;
                    groupData[headerIndex].sObjectRecordsList[index].Name = product.Name;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Vendor__c = product.buildertek__Vendor__c;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__UOM_Picklist__c =  uom;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_UNIT_COST__c = unitCost;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_MARKUP__c = markup;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Total_Costs__c = (quantity * markup);
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_LIST_PRICE_F__c = (((unitCost * markup) + unitCost) * quantity);
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Total_Sales_Price__c = (((unitCost * markup) + unitCost) * quantity) * quantity;
                }
              }
              else {
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Product__r = null;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Product__c = null;
                    groupData[headerIndex].sObjectRecordsList[index].Name = null;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Vendor__c = null;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__UOM_Picklist__c =  null;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_UNIT_COST__c = 0;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_MARKUP__c = 0;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Total_Costs__c = 0;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__BL_LIST_PRICE_F__c = 0;
                    groupData[headerIndex].sObjectRecordsList[index].buildertek__Total_Sales_Price__c = 0;
              }
    
                groupData[headerIndex].massUpdate = false;
                component.set("v.dataByGroup", groupData);
                groupData[headerIndex].massUpdate = true;
                component.set("v.dataByGroup", groupData);
                console.log('dataByGroup : ', component.get("v.dataByGroup"));
    
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

})