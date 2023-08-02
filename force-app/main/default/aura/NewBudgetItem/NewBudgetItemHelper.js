({
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
                    closeCallback: function () {},
                });
            } else {
                component.find("notifLib").showNotice({
                    variant: "error",
                    header: "Error!",
                    message: response.getError()[0].message,
                    closeCallback: function () {},
                });
            }
        });

        $A.enqueueAction(action);
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
        var action = component.get("c.getProductPrice");
        var productId = component.get("v.productId");
        var productName = component.get("v.productName");
        action.setParams({
            productId: productId,
        });
        action.setCallback(this, function (respo) {
            var res = respo.getReturnValue();
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
                }

                if (res[0].buildertek__Discount__c != null) {
                    getProductDetails.buildertek__Discount__c =
                        res[0].buildertek__Discount__c;
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

    getBudgetGroups: function (component, event, helper, page) {
        if (component.get("v.recordId")) {
            // Retrieve all the section of related Ad
            var action = component.get("c.retrieveGroups");
            action.setStorable({
                ignoreExisting: true,
            });
            action.setParams({
                budgetId: component.get("v.recordId"),
                pageNumber: page,
                recordToDisply: 50,
            });
            action.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    console.log('Response::', JSON.stringify(result));
                    if (result.formulaFields != undefined) {
                        var formulaField = JSON.parse(result.formulaFields);
                        for (var i in result.columns) {
                            for (var j in formulaField) {
                                if (j.toLowerCase() == result.columns[i].fieldName.toLowerCase()) {
                                    result.columns[i].title = formulaField[j];
                                }
                            }
                        }
                        if (result.tarTable != undefined && result.tarTable.ListOfEachRecord != undefined) {
                            const groupBy = (key) => (array) =>
                                array.reduce((objectsByKeyValue, obj) => {
                                    if (obj[key] != undefined && obj[key] != "undefined") {
                                        const value = obj[key];
                                        objectsByKeyValue[value] = (
                                            objectsByKeyValue[value] || []
                                        ).concat(obj);
                                        objectsByKeyValue[value].NoGrouping = false;
                                    } else {
                                        const value = obj['recordId'];
                                        objectsByKeyValue[value] = (
                                            objectsByKeyValue[value] || []
                                        ).concat(obj);
                                        objectsByKeyValue[value].NoGrouping = true;
                                    }
                                    return objectsByKeyValue;
                                }, {});

                            let records = result.tarTable.ListOfEachRecord;

                            let grouByParent = groupBy("groupId");
                            let parenGroupRecords = grouByParent(records);
                            Object.keys(parenGroupRecords).forEach(function (key) {
                                var value = parenGroupRecords[key];
                                let subGroupById = groupBy("subGroupId");
                                parenGroupRecords[key].subGroupByIds = {};
                                parenGroupRecords[key].subGroupByIds = subGroupById(value);
                            });
                            console.log("Parent Groups::", parenGroupRecords);
                            var parentArr = [];
                            var recordCount = 0;
                            Object.keys(parenGroupRecords).forEach(function (key) {
                                var value = parenGroupRecords[key];
                                var parentObj = {};
                                var value2 = value["subGroupByIds"];
                                parentObj.groupId = key;
                                parentObj.subGroups = [];
                                parentObj.parentGroup = [];
                                Object.keys(value2).forEach(function (key2) {
                                    if (!value2[key2].NoGrouping) {
                                        parentObj.groupName = value2[key2][0].groupName;
                                        value2[key2].groupName =
                                            value2[key2][0].subGroupName != undefined ?
                                            value2[key2][0].subGroupName :
                                            "";
                                        var subGroupArray = value2[key2];
                                        for (var i in subGroupArray) {
                                            if (subGroupArray[i].recordCount != undefined) {
                                                recordCount++;
                                                subGroupArray[i].recordCount = recordCount;
                                            }
                                        }
                                        parentObj.subGroups.push(value2[key2]);
                                    } else {
                                        parentObj.groupName = value2[key2][0].groupName;
                                        var subGroupArray = value2[key2];
                                        for (var i in subGroupArray) {
                                            if (subGroupArray[i].recordCount != undefined) {
                                                recordCount++;
                                                subGroupArray[i].recordCount = recordCount;
                                            }
                                        }
                                        parentObj.parentGroup.push(value2[key2]);
                                        value2[key2].groupName = "No Sub Grouping";
                                    }
                                });
                                parentArr.push(parentObj);
                            });
                            result.groupHierarchy = parentArr;
                        }
                    }
                    component.set("v.TotalRecords", result);
                    component.set("v.columns", result.columns);
                    component.set("v.page", result.page);
                    component.set("v.total", result.total);
                    if (result.total == 0) {
                        component.set("v.pages", 1);
                    } else {
                        component.set("v.pages", Math.ceil(result.total / 50));
                    }
                    $A.get("e.c:BT_SpinnerEvent")
                        .setParams({
                            action: "HIDE",
                        })
                        .fire();
                } else {
                    $A.get("e.c:BT_SpinnerEvent")
                        .setParams({
                            action: "HIDE",
                        })
                        .fire();
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
        //alert('recordId ---------> '+recordId);
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
                ////console.log('result --------> '+JSON.stringify(result));
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
        var action = component.get("c.getBudgetItemData");
        action.setParams({
            recordId: recordId,
            fieldsList: allFields,
            fieldString: finalString,
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            //alert('state -------> '+state);
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                ////console.log('Final result --------> '+JSON.stringify(result));
                component.set("v.Table_header_Records", result);
            }
        });
        $A.enqueueAction(action);
    },

    fetchpricebooks: function (component, event, helper) {
        var action = component.get("c.getpricebook");
        action.setParams({
            BudgetId: component.get("v.recordId"),
        });
        var opts = [];
        action.setCallback(this, function (response) {
            if (response.getState() == "SUCCESS") {
                component.set("v.pricebookName", response.getReturnValue());
            }
        });
        $A.enqueueAction(action);
        var actions = component.get("c.getpricebooks");
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
                component.set("v.pricebookoptions", opts);
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
});