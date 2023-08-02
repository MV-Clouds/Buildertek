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
  getPoList: function (component, event, helper) {
    var action = component.get("c.getprovendors");
    var recId = component.get("v.recordId");
    action.setParams({
      optionLineID: recId,
    });
    action.setCallback(this, function (response) {
      // alert('JSON.stringify(response.getReturnValue())).length'+JSON.parse(JSON.stringify(response.getReturnValue())).length);
      if (response.getState() == "SUCCESS") {
        if (JSON.parse(JSON.stringify(response.getReturnValue())).length) {
        }
      } else {
        // console.log(response);
      }
    });
    $A.enqueueAction(action);
  },

  getPoLinesList: function (component, event, helper, pageNumber, pageSize) {
    // component.set("v.Spinner", true);
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
          // console.log(filter2);
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
      var state = response.getState();
      if (state === "SUCCESS") {
        var pageSize = component.get("v.pageSize");
        var result = response.getReturnValue();
        //component.set("v.masterBudgetsList", result);
        // alert('** result.sObjectRecordsList  ---------->:');
        console.log(
          "** result.sObjectRecordsList --------------->:" +
          JSON.parse(JSON.stringify(result.sObjectRecordsList))
        );
        console.log({ result });

        component.set("v.recordsList", result.recordList);
        component.set("v.listOfRecords", JSON.parse(result.sObjectRecordsList));
        component.set(
          "v.cloneListOfRecords",
          JSON.parse(result.sObjectRecordsList)
        );
        // component.set("v.fieldValues", blankFields);
        // console.log('@@@@@@@-',JSON.parse(result.fieldValues));
        component.set("v.fieldValues", JSON.parse(result.fieldValues));
        // console.log(component.get("v.fieldValues"));
        component.set("v.PageNumber", result.pageNumber);
        component.set("v.TotalRecords", result.totalRecords);
        component.set("v.RecordStart", result.recordStart);
        component.set("v.RecordEnd", result.recordEnd);
        component.set(
          "v.TotalPages",
          Math.ceil(result.totalRecords / pageSize)
        );
        // console.log('&**&*&*&*&*&*& ',result.recordList);
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
        console.log("rows");
        console.log({ rows });
        component.set("v.orgData", rows);
        component.set("v.data", rows);
        var groupByData = component.get("v.orgData");
        component.set("v.fieldmaptype", result.fieldtypemap);
        console.log("result.sObjectRecordsList==" + result.sObjectRecordsList);
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
          JSON.parse(result.sObjectRecordsList)
        );
        //component.set("v.totalRecords", component.get("v.masterBudgetsList").length);

        /*var PaginationList = [];
                for(var i=0; i< pageSize; i++){
                    if(component.get("v.masterBudgetsList").length> i)
                        PaginationList.push(result[i]);    
                }*/
        // component.set('v.PaginationList', PaginationList);
        component.set("v.Spinner", false);
      } else {
        component.set("v.Spinner", false);
        // console.log(response.getError())
      }
    });
    $A.enqueueAction(action);
  },
  sortData: function (component, event, fieldName, sortDirection, data) {
    /*var removeRowIndex = -1;
        var removeRowItem = data.filter(function(item,index){
            if(item.Name == 'Totals'){
                removeRowIndex = index;
                return item;
            }
        });
        if(removeRowIndex > -1){
             data.splice(removeRowIndex,1);
        }*/
    var key = function (a) {
      return a[fieldName];
    };
    var reverse = sortDirection == "asc" ? 1 : -1;

    data.sort(function (a, b) {
      var x = "";
      var y = "";
      for (var i in a) {
        var arowKey = a[i].Key.replace("__r", "__c");
        if (arowKey == fieldName) {
          x = a[i].Value + "";
          break;
        }
      }

      for (var j in b) {
        var browKey = b[j].Key.replace("__r", "__c");
        if (browKey == fieldName) {
          y = b[j].Value + "";
          break;
        }
      }
      x = x.toLowerCase();
      y = y.toLowerCase();

      return reverse * ((x > y) - (y > x));
    });

    var classIndex = event.currentTarget.dataset.sortgroupindex;
    var sortedData = JSON.parse(JSON.stringify(component.get("v.dataByGroup")));
    sortedData[classIndex]["groupedRecordsTmp"] = data;
    var ele = event.currentTarget;
    var sortEle = ele.getElementsByClassName("slds-icon-utility-arrowdown")[0];
    // console.log(sortedData,data)
    component.set("v.dataByGroup", sortedData);
    /* if(sortDirection =="asc"){
            sortEle.style.transform = "rotate(180deg)";
        }else{
            sortEle.style.transform = "rotate(0deg)";
        }*/
    component.set("v.sortedBy", fieldName);
    if (sortDirection == "asc") {
      component.set("v.sortDirection", "desc");
    } else {
      component.set("v.sortDirection", "asc");
    }
    component.set("v.sortingGroupIndex", Number(classIndex));
    /* event.getSource().set("v.data",data);
        event.getSource().set("v.sortedDirection",sortDirection);
        event.getSource().set("v.sortedBy",sortedBy);*/
  },

  /* formatDataByGroups : function(component,event,helper,mapData){
        let recordsMap = new Map();
        for (var i in mapData) {
            var toggleVal = component.get("v.groupBytoggle");
            if(!toggleVal){
                //group by phase
                if(mapData[i].buildertek__Build_Phase__c){
                    if (!recordsMap.has(mapData[i].buildertek__Build_Phase__r.Id + '(#&%*)' + mapData[i].buildertek__Build_Phase__r.Name)) {
                        recordsMap.set(mapData[i].buildertek__Build_Phase__r.Id + '(#&%*)' + mapData[i].buildertek__Build_Phase__r.Name, []);
                    }
                    recordsMap.get(mapData[i].buildertek__Build_Phase__r.Id + '(#&%*)' + mapData[i].buildertek__Build_Phase__r.Name).push(JSON.parse(JSON.stringify(mapData[i])));
                }else{
                    //// console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    if (!recordsMap.has('No Build Phase')) {
                        recordsMap.set('No Build Phase', []);
                    }
                    //// console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    recordsMap.get('No Build Phase').push(JSON.parse(JSON.stringify(mapData[i])));
                    //// console.log(recordsMap.get("No vendor"))
                }
            }else if(toggleVal){
                if(mapData[i].buildertek__Vendor__c){
                    if (!recordsMap.has(mapData[i].buildertek__Vendor__r.Id + '(#&%*)' + mapData[i].buildertek__Vendor__r.Name)) {
                        recordsMap.set(mapData[i].buildertek__Vendor__r.Id + '(#&%*)' + mapData[i].buildertek__Vendor__r.Name, []);
                    }
                    recordsMap.get(mapData[i].buildertek__Vendor__r.Id + '(#&%*)' + mapData[i].buildertek__Vendor__r.Name).push(JSON.parse(JSON.stringify(mapData[i])));
                }else{
                    //// console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    if (!recordsMap.has('No Vendor')) {
                        recordsMap.set('No Vendor', []);
                    }
                    //// console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                    recordsMap.get('No Vendor').push(JSON.parse(JSON.stringify(mapData[i])));
                    //// console.log(recordsMap.get("No vendor"))
                }
            }
            
   
    }
        var result = Array.from(recordsMap.entries());
        var groupData = [];
        for(var i in result){
            var newObj = {};
            if(result[i][0].indexOf('(#&%*)') > -1){
                newObj['groupName'] = result[i][0].split('(#&%*)')[1];
            }else{
                newObj['groupName'] = result[i][0];
            }
            newObj['groupData'] = result[i][1];
            groupData.push(newObj);
        }
        // console.log(groupData);
        component.set("v.dataByGroup",groupData);
        component.set("v.Spinner", false);
    }*/

  formatDataByGroups: function (
    component,
    event,
    helper,
    mapData,
    fieldtypemap,
    sObjectRecordsList
  ) {
    let recordsMap = new Map();
    let sObjectRecordsMap = new Map();
    for (var kkk in sObjectRecordsList) {
      sObjectRecordsMap.set(
        sObjectRecordsList[kkk].Id,
        sObjectRecordsList[kkk]
      );
    }
    //alert(sObjectRecordsMap);

    for (var i in mapData) {
      console.log("mapData-->");
      console.log({ mapData });
      var toggleVal = component.get("v.groupBytoggle");

      if (component.get("v.groupByPhasetoggle")) {
        //group by phase
        console.log(mapData[i].sheetrecord.buildertek__Build_Phase__c);
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
          //// console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
          if (!recordsMap.has("No Build Phase")) {
            recordsMap.set("No Build Phase", []);
          }
          //// console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
          mapData[i]["sheetrecord"]["showIcon"] = mapData[i]["isShowIcon"];
          recordsMap
            .get("No Build Phase")
            .push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
          //// console.log(recordsMap.get("No vendor"))
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
          //// console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
          if (!recordsMap.has("No Vendor")) {
            recordsMap.set("No Vendor", []);
          }
          //// console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
          mapData[i]["sheetrecord"]["showIcon"] = mapData[i]["isShowIcon"];
          recordsMap
            .get("No Vendor")
            .push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
          //// console.log(recordsMap.get("No vendor"))
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
          //// console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
          if (!recordsMap.has("No Category")) {
            recordsMap.set("No Category", []);
          }
          //// console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
          mapData[i]["sheetrecord"]["showIcon"] = mapData[i]["isShowIcon"];
          recordsMap
            .get("No Category")
            .push(JSON.parse(JSON.stringify(mapData[i].sheetrecord)));
          //// console.log(recordsMap.get("No vendor"))
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
    console.log("result");
    console.log({ result });
    var groupData = [];
    for (var i in result) {
      var newObj = {};
      if (result[i][0].indexOf("(#&%*)") > -1) {
        newObj["groupName"] = result[i][0].split("(#&%*)")[1];
      } else {
        newObj["groupName"] = result[i][0];
      }
      newObj["groupData"] = result[i][1];

      //dynamic field
      var selectedFields = component.get("v.bomLineselectedFields").split(",");
      var mainList = [];
      var sObjectRecordsList = [];
      //alert('arrkeys '+i+arrkeys);
      for (var j in newObj["groupData"]) {
        //alert(obj.groupedRecords[j].Name);

        let newList = [];
        if (selectedFields.indexOf("Id") < 0) {
          selectedFields.unshift("Id");
        }
        // console.log(newObj['groupData'][j])
        for (var k = 0; k < selectedFields.length; k++) {
          var AllRowListMap = new Map(Object.entries(newObj["groupData"][j]));
          // console.log('*****************',AllRowListMap);
          var keyId = Array.from(AllRowListMap.keys())[0];
          var mapKey = selectedFields[k];
          var strrecord = JSON.stringify(
            Object.entries(newObj["groupData"][j])
          );
          let indexObj = {};
          indexObj.fieldType = fieldtypemap[mapKey];
          if (strrecord.indexOf(mapKey) > 0) {
            if (mapKey.indexOf("__c") > 0) {
              indexObj.Key = mapKey;
              indexObj.Value = AllRowListMap.get(mapKey);
              indexObj.Id = AllRowListMap.get(keyId);
            }

            if (mapKey.indexOf("__r") > 0) {
              // console.log('^^^^^^^'+(mapKey));
              // console.log('^^^^^^^'+JSON.stringify(AllRowListMap.get(mapKey)));
              // console.log('^^^^^^^'+JSON.stringify(AllRowListMap));
              // console.log('^^^^^^^ out'+JSON.stringify(AllRowListMap.get(mapKey)));
              if (AllRowListMap.get(mapKey) != undefined) {
                // console.log('^^^^^^^ inn'+AllRowListMap.get(mapKey));
                var AllRowListMap2 = new Map(
                  Object.entries(AllRowListMap.get(mapKey))
                );
                var mapKey2 = Array.from(AllRowListMap2.keys())[0];
                indexObj.Key = mapKey;
                indexObj.Value = AllRowListMap2.get(mapKey2);
                indexObj.Id = AllRowListMap.get(keyId);
              }
            }
            if (mapKey == "Name") {
              indexObj.Key = mapKey;
              indexObj.Value = AllRowListMap.get(mapKey);
              indexObj.Id = AllRowListMap.get(keyId);
            }
            if (mapKey == "Id") {
              indexObj.Key = mapKey;
              indexObj.Value = AllRowListMap.get(mapKey);
              indexObj.Id = AllRowListMap.get(keyId);
              indexObj.showVendorIcon = newObj["groupData"][j]["showIcon"];
            }
          } else {
            indexObj.Key = mapKey;
            indexObj.Value = "";
            indexObj.Id = AllRowListMap.get(keyId);
            indexObj.showVendorIcon = newObj["groupData"][j]["showIcon"];
          }

          newList.push(indexObj);
        }
        /* newList.unshift({'Key':'showVenordIcon','showVenordIcon': newObj['groupData'][j]['showIcon'] })
                delete newObj['groupData'][j]['showIcon'];*/
        delete newObj["groupData"][j]["showIcon"];
        mainList.push(newList);
        sObjectRecordsList.push(
          sObjectRecordsMap.get(newObj["groupData"][j].Id)
        );
        //alert(sObjectRecordsMap.get(newObj['groupData'][j].Id));
      }

      newObj.groupedRecordsTmp = mainList;
      newObj.sObjectRecordsList = sObjectRecordsList;

      groupData.push(newObj);
    }

    component.set("v.dataByGroup", groupData);
    console.log("groupData===");
    console.log({ groupData });
    component.set("v.cloneDataByGroup", groupData);
    helper.calculateCostAdjustment(component, event, helper);
    // $A.get('e.force:refreshView').fire();
    if (
      !component.get("v.massUpdateEnable") &&
      component.get("v.showFabricationDetails") == true
    ) {
      helper.calculateCostAdjustment(component, event, helper);
    }
    // $A.get('e.force:refreshView').fire();
    component.set("v.Spinner", false);
  },
  fetchTakeOffLinesData: function (component, event, helper) {
    var action = component.get("c.getTakeOffLinesData");
    action.setCallback(this, function (response) {
      // debugger;
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        console.log("fetchTakeOffLinesData");
        console.log({ result });
        if (result != null) {
          // console.log(result);
          //alert(JSON.stringify(result.TakeOffFieldSettings));

          // bom line data
          // if(result.bomLineselectedFields != 'buildertek__Tax__c'){
          component.set("v.bomLineFieldsSettings", result.bomLineFieldSettings);
          var bomSelectedFieldsLength =
            result.bomLineselectedFields.split(",").length;
          bomSelectedFieldsLength = bomSelectedFieldsLength + 2;
          component.set(
            "v.bomLineselectedFieldsLength",
            bomSelectedFieldsLength
          );
          component.set("v.bomLineselectedFields",result.bomLineselectedFields);
          console.log('>>>>>>>>>>>>>>>>>>>>>>>>>' , component.get("v.bomLineselectedFields"));
          // }
        }
        var getBOMLineFieldMapAction = component.get(
          "c.getBOMLineFiledNameAndApi"
        );
        component.set("v.isSpinner", true);
        getBOMLineFieldMapAction.setCallback(this, function (response) {
          // debugger;
          var state = response.getState();
          if (state === "SUCCESS") {
            component.set("v.isSpinner", true);
            var result = response.getReturnValue();
            component.set("v.fieldBOMLineNameApiMap", result);
            var neList = [];
            neList = Object.values(result);
            // console.log(neList)
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
        // console.log('Error');
      }
    });
    $A.enqueueAction(action);
  },

  updateMassRecords: function (component, event, helper) {
    // debugger;
    component.set("v.isLoading", true);
    var x = component.get("v.dataByGroup");
    console.log("<-- @@ dataByGroup @@ -->");
    console.log({ x });
    var data = JSON.parse(JSON.stringify(component.get("v.dataByGroup")));
    var newList = [];
    for (var i in data) {
      //alert(JSON.stringify(data[i].sObjectRecordsList));
      for (var j in data[i].sObjectRecordsList) {
        //alert(data[i].sObjectRecordsList[j].Id);
        //alert(data[i].sObjectRecordsList[j].Name);
        newList.push(data[i].sObjectRecordsList[j]);
      }
    }
    var action = component.get("c.updateRecords");
    console.log("@@ JSON.stringifyt--", { newList });

    action.setParams({
      recordId: component.get("v.recordId"),
      updatedRecords: JSON.stringify(newList),
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.isLoading", false);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        helper.getPoLinesList(component, event, helper, pageNumber, pageSize);
      } else if (state === "ERROR") {
        component.set("v.isLoading", false);
        // console.log('A Problem Occurred: ' + JSON.stringify(response.error));
      }
    });
    $A.enqueueAction(action);
  },

  deleteRecord: function (component, event, helper, deleteRecordId) {
    component.set("v.isLoading", true);
    var action = component.get("c.deleteBOMLine");
    action.setParams({
      deleteRecordId: deleteRecordId,
    });

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        component.set("v.isLoading", false);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        helper.getPoLinesList(component, event, helper, pageNumber, pageSize);
      } else if (state === "ERROR") {
        component.set("v.isLoading", false);
        // console.log('A Problem Occurred: ' + JSON.stringify(response.error));
      }
    });
    $A.enqueueAction(action);
  },

  checkFabricationTaxes: function (component, event, helper) {
    var BOMID = component.get("v.recordId");
    var action = component.get("c.checkFabricationTaxes");

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        var fabricationCheck = response.getReturnValue();
        if (
          fabricationCheck != null &&
          fabricationCheck != undefined &&
          fabricationCheck == true
        ) {
          component.set("v.showFabricationDetails", fabricationCheck);
          var action = component.get("c.handleBTAdmin");
          $A.enqueueAction(action);
        }
      } else {
        helper.showToast(
          component,
          event,
          helper,
          "Error!",
          "Something went wrong!",
          "error"
        );
        // console.log('Not success');
      }
    });

    $A.enqueueAction(action);
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
    component.set("v.isSpinner", false);
  },
  calculateCostAdjustment: function (component, event, helper) {
    // var showFabTaxes = component.get('v.showFabricationDetails');
    // if(showFabTaxes == true)
    // {
    console.log("loop calling in calculateCostAdjustment");

    component.set("v.isLoading", true);
    // $A.get('e.force:refreshView').fire();
    //var bomLineFields = component.get("v.bomLineFieldsSettings");
    var bomLineFields = component.get("v.fieldValues");
    console.log({ bomLineFields });
    console.log("initially Fields value are*************************");
    //component.set('v.bomLineFieldsSettingsClone',bomLineFields);
    var slabDiscount = 0;
    var taxRate1 = 0;
    var taxRate2 = 0;
    var fabricationAndIstallRate = 0;
    var fabricationOnlyRate = 0;
    var installOnly = 0;
    var FabLaborMarkup = 0;
    var nonSlabMarkup = 0;
    const bomIdVsExtendCost = new Map();
    const bomIdVsUpgradedCost = new Map();
    const bomIdVslistPrice = new Map();
    var taxOnFabRequired;

    var adjustmentTableData = component.get("v.bomList");
    console.log("<-- adjustmentTableData -->");
    console.log({ adjustmentTableData });
    if (
      adjustmentTableData != null &&
      adjustmentTableData != undefined &&
      adjustmentTableData.length > 0 &&
      bomLineFields != null &&
      bomLineFields != undefined &&
      bomLineFields.length > 0
    ) {
      for (var i = 0; i < adjustmentTableData.length; i++) {
        // if (adjustmentTableData[i].buildertek__Slab_Discount_Rate__c != null && adjustmentTableData[i].buildertek__Slab_Discount_Rate__c != undefined) {
        //     slabDiscount = adjustmentTableData[i].buildertek__Slab_Discount_Rate__c;
        // }

        if (
          adjustmentTableData[i].buildertek__Tax_Rate_1__c != null &&
          adjustmentTableData[i].buildertek__Tax_Rate_1__c != undefined
        ) {
          taxRate1 = adjustmentTableData[i].buildertek__Tax_Rate_1__c;
          console.log("<--taxRate1-->" + taxRate1);
        }

        if (
          adjustmentTableData[i].buildertek__Tax_Rate_2__c != null &&
          adjustmentTableData[i].buildertek__Tax_Rate_2__c != undefined
        ) {
          taxRate2 = adjustmentTableData[i].buildertek__Tax_Rate_2__c;
          console.log("<--taxRate2-->" + taxRate2);
        }

        if (
          adjustmentTableData[i].buildertek__Fabrication_Install_Rate__c !=
          null &&
          adjustmentTableData[i].buildertek__Fabrication_Install_Rate__c !=
          undefined
        ) {
          fabricationAndIstallRate = JSON.parse(
            adjustmentTableData[i].buildertek__Fabrication_Install_Rate__c
          );
        }

        if (
          adjustmentTableData[i].buildertek__Install_Only__c != null &&
          adjustmentTableData[i].buildertek__Install_Only__c != undefined
        ) {
          installOnly = JSON.parse(
            adjustmentTableData[i].buildertek__Install_Only__c
          );
        }

        // if (adjustmentTableData[i].buildertek__Fabrication_Labor_Mark_up__c != null && adjustmentTableData[i].buildertek__Fabrication_Labor_Mark_up__c != undefined) {
        //     FabLaborMarkup = adjustmentTableData[i].buildertek__Fabrication_Labor_Mark_up__c ;
        // }

        if (
          adjustmentTableData[i].buildertek__Mark_Up_Non_Slab_or_Labor__c !=
          null &&
          adjustmentTableData[i].buildertek__Mark_Up_Non_Slab_or_Labor__c !=
          undefined
        ) {
          nonSlabMarkup = JSON.parse(
            adjustmentTableData[i].buildertek__Mark_Up_Non_Slab_or_Labor__c
          );
        }

        if (
          adjustmentTableData[i].buildertek__Tax_on_Fabrication_Required__c !=
          null &&
          adjustmentTableData[i].buildertek__Tax_on_Fabrication_Required__c !=
          undefined
        ) {
          taxOnFabRequired =
            adjustmentTableData[i].buildertek__Tax_on_Fabrication_Required__c;
        }
      }
    }

    var groupByVendor = component.get("v.groupByVendortoggle");
    var groupByCategory = component.get("v.groupByCategorytoggle");
    var groupByPhase = component.get("v.groupByPhasetoggle");
    var groupByPhaseFromToggle = component.get("v.groupByBuildChecked");
    var groupByServiceCat = component.get("v.groupByServiceCategorytoggle");

    var costAdjustmentColumnsPresent = false;
    console.log({bomLineFields} , ':::::::::::;bomLineFields::::::::::::::::');
    if ( bomLineFields != null && bomLineFields != undefined && bomLineFields.length > 0) {
      for (var i = 0; i < bomLineFields.length; i++) {
        if (bomLineFields[i].value == "buildertek__Markup") {
          costAdjustmentColumnsPresent = true;
        }
      }

      // console.log('@@costAdjustmentColumnsPresent-', costAdjustmentColumnsPresent);
      if (costAdjustmentColumnsPresent == false) {
        var discountCol =
          '{"label": "Discount", "value": "buildertek__Discount"}';
        var discountAmountCol =
          '{"label": "Discount Amount", "value": "buildertek__Discount_Amount"}';
        var markupCol = '{"label": "Markup %", "value": "buildertek__Markup"}';
        var markUpAmountCol =
          '{"label": "Markup Amount", "value": "buildertek__Markup_Amount"}';
        var subTotalCol =
          '{"label": "Sub Total Amount", "value": "buildertek__SubTotal_Amount"}';
        var grossCost =
          '{"label": "Gross Cost", "value": "buildertek__Gross_Cost"}';
        var extendedCost =
          '{"label": "Extended Cost", "value": "buildertek__Extended_Cost"}';
        var salesTaxCol =
          '{"label": "Sales Tax", "value": "buildertek__SalesTax"}';
        var totalCostCol =
          '{"label": "Total Cost", "value": "buildertek__Total_Cost"}';
        // var uom = '{"label": "UOM", "value": "buildertek__UOM_PL"}';

        bomLineFields[bomLineFields.length] = JSON.parse(discountCol);
        bomLineFields[bomLineFields.length] = JSON.parse(discountAmountCol);
        bomLineFields[bomLineFields.length] = JSON.parse(markupCol);
        bomLineFields[bomLineFields.length] = JSON.parse(markUpAmountCol);
        //bomLineFields[bomLineFields.length] = JSON.parse(subTotalCol);
        bomLineFields[bomLineFields.length] = JSON.parse(grossCost);
        bomLineFields[bomLineFields.length] = JSON.parse(extendedCost);
        bomLineFields[bomLineFields.length] = JSON.parse(salesTaxCol);
        bomLineFields[bomLineFields.length] = JSON.parse(totalCostCol);
        //  bomLineFields[bomLineFields.length] = JSON.parse(uom);

        component.set("v.fieldValues", bomLineFields);
        console.log(totalCostCol + "TOTAL COST____");
        console.log(bomLineFields);
        console.log({bomLineFields} , '********************bomLineFields****************');

      }

      if (groupByServiceCat == true && costAdjustmentColumnsPresent == true) {
        //Add New Rows
        costAdjustmentColumnsPresent = false;
      } else if (
        groupByCategory == true &&
        costAdjustmentColumnsPresent == true
      ) {
        //Add New Rows
        costAdjustmentColumnsPresent = false;
      } else if (
        groupByPhase == true &&
        costAdjustmentColumnsPresent == true &&
        groupByPhaseFromToggle == true
      ) {
        //Add New Rows
        costAdjustmentColumnsPresent = false;
        component.set("v.groupByBuildChecked", false);
      }

      // console.log('@@costAdjustmentColumnsPresent2-', costAdjustmentColumnsPresent);
      var groupByData = component.get("v.orgData");
      // console.log('@@groupByData-', groupByData);
      var allData = component.get("v.dataByGroup");
      this.storeAllData = allData;
      var v = this.storeAllData;
      console.log("storeAllData in var", { v });
      // console.log('@@dataByGroup FIRST-', allData);
      var map1 = new Map();
      var map2 = new Map();
      if (allData != null && allData != undefined) {
        console.log("all data :)-> ", { allData });
        console.log("all data length :)-> ", allData.length);
        for (var i = 0; i < allData.length; i++) {
          var groupedRecords = allData[i].groupedRecordsTmp;
          var grpData = allData[i].groupData;
          for (var j = 0; j < grpData.length; j++) {
            if (grpData[j].buildertek__Upgrade_Price__c != null) {
              bomIdVsUpgradedCost.set(
                grpData[j].Id,
                grpData[j].buildertek__Upgrade_Price__c
              );
            }
            bomIdVslistPrice.set(
              grpData[j].Id,
              grpData[j].buildertek__BL_LIST_PRICE__c
            );
          }
          // console.log('@@bomIdVsUpgradedCost FIRST-', bomIdVsUpgradedCost);
          // console.log('@@bomIdVslistPrice FIRST-', bomIdVslistPrice);
          console.log("groupedRecords :) --> ", { groupedRecords });
          console.log("groupedRecords.length :) --> ", groupedRecords.length);
          for (var j = 0; j < groupedRecords.length; j++) {
            var record = groupedRecords[j];
            console.log("record :) --> ", { record });
            var lastindex = record.length - 1;

            var productCode = "";
            var serviceCategory = "";
            var sqft = "";
            var taxedit;
            let quantity = 0;
            // var uomString = '';

            if (
              grpData[j].buildertek__Takeoff_Line__r != null &&
              grpData[j].buildertek__Takeoff_Line__r != undefined &&
              /*grpData[j].buildertek__Service_Category__c != null
                            && grpData[j].buildertek__Service_Category__c != undefined
                            && grpData[j].buildertek__Service_Category__c != ''*/
              grpData[j].buildertek__BL_SERVICE_CATEGORY__c != null &&
              grpData[j].buildertek__BL_SERVICE_CATEGORY__c != undefined &&
              grpData[j].buildertek__BL_SERVICE_CATEGORY__c != ""
            ) {
              //  serviceCategory = grpData[j].buildertek__Service_Category__c;
              serviceCategory = grpData[j].buildertek__BL_SERVICE_CATEGORY__c;
            }
            if (
              grpData[j].buildertek__Product__r != null &&
              grpData[j].buildertek__Product__r != undefined &&
              grpData[j].buildertek__Product__r.ProductCode != null &&
              grpData[j].buildertek__Product__r.ProductCode != undefined &&
              grpData[j].buildertek__Product__r.ProductCode != ""
            ) {
              productCode = grpData[j].buildertek__Product__r.ProductCode;
            }
            if (
              grpData[j].buildertek__Takeoff_Line__r != null &&
              grpData[j].buildertek__Takeoff_Line__r != undefined &&
              grpData[j].buildertek__Takeoff_Line__r.buildertek__Sq_Ft__c !=
              null &&
              grpData[j].buildertek__Takeoff_Line__r.buildertek__Sq_Ft__c !=
              undefined &&
              grpData[j].buildertek__Takeoff_Line__r.buildertek__Sq_Ft__c != ""
            ) {
              sqft =
                grpData[j].buildertek__Takeoff_Line__r.buildertek__Sq_Ft__c;
            }
            if (
              grpData[j].buildertek__Quantity__c != null &&
              grpData[j].buildertek__Quantity__c != undefined
            ) {
              quantity = grpData[j].buildertek__Quantity__c;
            }
            //  if(grpData[j].buildertek__Tax__c != undefined )
            // {
            //    taxedit = grpData[j].buildertek__Tax__c;
            // }
            // if(grpData[j].buildertek__Takeoff_Line__r != null &&
            //     grpData[j].buildertek__Takeoff_Line__r != undefined &&
            //     grpData[j].buildertek__Takeoff_Line__r.buildertek__UOM_PL__c != null
            //     && grpData[j].buildertek__Takeoff_Line__r.buildertek__UOM_PL__c != undefined
            //     && grpData[j].buildertek__Takeoff_Line__r.buildertek__UOM_PL__c != '')
            // {
            //     // uomString = grpData[j].buildertek__Takeoff_Line__r.buildertek__UOM_PL__c;
            // }
            // console.log('@@sqft-',sqft);

            //Discount Amount
            var extendedcost = 0;
            var percentageOnFab = 0;
            var properCost = 0;
            var markupPercentage = "";
            var bomLineId = "";
            let grossCost = 0;
            let grossLessCost = 0;
            let finalExtendedCost = 0;
            let totalCost = 0;
            let salestax = 0;

            var testo = grpData[j];
            console.log(
              "service category--" + testo.buildertek__BL_SERVICE_CATEGORY__c
            );
            console.log("testo===");
            console.log({ testo });

            var testoId = testo.Id;

            if (map1.size == 0) {
              var jsonstring = "";
              jsonstring =
                testo.buildertek__Selection_Sheet_Takeoff__r
                  .buildertek__Options_Rate__c;
              var arr = [];
              console.log("jsonstring==" + jsonstring);
              if (jsonstring != undefined) {
                console.log("testing");
                arr = JSON.parse(jsonstring);

                if (arr.length > 0) {
                  arr.forEach(function (item, index) {
                    var test = item;
                    map1.set(test.bomLineId, test.taxbvalue);
                  });
                }
              }
            }

            if (map2.size == 0) {
              // buildertek__Slab_Discount_Rate_LongText__c
              var jsonstringslab = "";
              jsonstringslab =
                testo.buildertek__Selection_Sheet_Takeoff__r
                  .buildertek__Slab_Discount_Rate_LongText__c;
              var arr = [];
              console.log("jsonstringslab==" + jsonstringslab);
              if (jsonstringslab != undefined) {
                console.log("testing");
                arr = JSON.parse(jsonstringslab);

                if (arr.length > 0) {
                  arr.forEach(function (item, index) {
                    var test = item;
                    map2.set(test.bomLineId, test.taxbvalue);
                  });
                }
              }
            }

            for (var k = 0; k < record.length; k++) {
              if (record[k].Key == "buildertek__Extended_Cost") {
                extendedcost = parseFloat(record[k].Value);
              }
              var testo1 = record[k];
              if (record[k].Key == "Id") {
                bomLineId = record[k].Value;
                console.log("bomLineId :) -> ", bomLineId);
              }

              if (
                bomLineId != null &&
                bomLineId != "" &&
                bomIdVsUpgradedCost != null &&
                bomIdVslistPrice != null
              ) {
                if (
                  bomIdVsUpgradedCost.has(bomLineId) &&
                  bomIdVsUpgradedCost.get(bomLineId) != null
                ) {
                  properCost = parseFloat(
                    bomIdVsUpgradedCost.get(bomLineId)
                  ).toFixed(2);
                } else if (
                  bomIdVslistPrice.has(bomLineId) &&
                  bomIdVslistPrice.get(bomLineId) != null
                ) {
                  properCost = parseFloat(
                    bomIdVslistPrice.get(bomLineId)
                  ).toFixed(2);
                }
              }

              // console.log('#@#@ bomLineId---',bomLineId);
              // console.log('#@#@ serviceCategory---',serviceCategory);
              // console.log('#@#@ quantity---',quantity);
              // console.log('#@#@ properCost---'+properCost+'-----Name---'+record[2].Value);
              /* Comment added by Harika, regarding CAES-63 ticket, Date: 09-08-2022*/
              //if(serviceCategory == 'Complete')
              //{
              if (serviceCategory == "Fab & Install") {
                var extendedCOstObj = component.get("v.fabInstallExtndCost");

                if (
                  extendedCOstObj != null &&
                  extendedCOstObj != undefined &&
                  extendedCOstObj[bomLineId] != null &&
                  extendedCOstObj[bomLineId] != undefined
                ) {
                  extendedcost = parseFloat(extendedCOstObj[bomLineId]).toFixed(
                    2
                  );
                }
              } else if (helper.isPresentInSlab(serviceCategory)) {
                var discountRateVal = component.get("v.slabDiscountRate");
                if (
                  discountRateVal != null &&
                  discountRateVal != undefined &&
                  discountRateVal[bomLineId] != null &&
                  discountRateVal[bomLineId] != undefined &&
                  discountRateVal[bomLineId] != ""
                ) {
                  slabDiscount = parseFloat(discountRateVal[bomLineId]);
                  slabDiscount = (slabDiscount * 100).toFixed(2);
                  // if (slabDiscount == 0 && serviceCategory == 'Slab - Quartz') {
                  //     slabDiscount = -45.0;
                  // }
                } else {
                  if (serviceCategory == "Slab - Quartz") {
                    slabDiscount = -45.0;
                  }
                }
              } else if (serviceCategory == "Install") {
                var extendedCOstObj = component.get("v.installOnlyExtndCost");

                if (
                  extendedCOstObj != null &&
                  extendedCOstObj != undefined &&
                  extendedCOstObj[bomLineId] != null &&
                  extendedCOstObj[bomLineId] != undefined
                ) {
                  extendedcost = parseFloat(extendedCOstObj[bomLineId]).toFixed(
                    2
                  );
                }
              } else if (serviceCategory == "Fab") {
                var extendedCOstObj = component.get("v.fabOnlyExtndCost");
                if (
                  extendedCOstObj != null &&
                  extendedCOstObj != undefined &&
                  extendedCOstObj[bomLineId] != null &&
                  extendedCOstObj[bomLineId] != undefined
                ) {
                  // extendedcost  = parseFloat(extendedCOstObj[bomLineId]).toFixed(2);
                  percentageOnFab = parseFloat(
                    extendedCOstObj[bomLineId]
                  ).toFixed(2);
                }
              } else if (serviceCategory == "Edge") {
                var extendedCOstObj = component.get("v.edgeCost");

                if (
                  extendedCOstObj != null &&
                  extendedCOstObj != undefined &&
                  extendedCOstObj[bomLineId] != null &&
                  extendedCOstObj[bomLineId] != undefined
                ) {
                  extendedcost = parseFloat(extendedCOstObj[bomLineId]).toFixed(
                    2
                  );
                }
              } else if (
                /*else if(helper.isNotPresentInSlab(serviceCategory) && serviceCategory != 'Labor' && 
                                                          serviceCategory != 'Fab' && serviceCategory != 'Edge' &&
                                                          serviceCategory != 'Install' && serviceCategory != 'Complete' &&
                                                          serviceCategory != 'Misc' && serviceCategory != 'Option')
                                                  {*/
                /* Comment added by Harika, regarding CAES-63 ticket, Date: 09-08-2022*/
                helper.isNotPresentInSlab(serviceCategory) &&
                serviceCategory != "Labor" &&
                serviceCategory != "Fab" &&
                serviceCategory != "Edge" &&
                serviceCategory != "Install" &&
                serviceCategory != "Fab & Install" &&
                serviceCategory != "Misc" &&
                serviceCategory != "Option"
              ) {
                var extendedCOstObj = component.get("v.nonSlabExtndCost");

                if (
                  extendedCOstObj != null &&
                  extendedCOstObj != undefined &&
                  extendedCOstObj[bomLineId] != null &&
                  extendedCOstObj[bomLineId] != undefined
                ) {
                  extendedcost = parseFloat(extendedCOstObj[bomLineId]).toFixed(
                    2
                  );
                }
              } else if (serviceCategory == "Misc") {
                /*else if(serviceCategory == 'Fab' || serviceCategory == 'Install' || serviceCategory == 'Edge' || 
                                                    serviceCategory == 'Fab & Install' || serviceCategory == 'Labor')
                                                  {
                                                       var extendedCOstObj = component.get('v.fabLaborMarkupRate');
                                                          
                                                          if(extendedCOstObj != null && extendedCOstObj != undefined && 
                                                              extendedCOstObj[bomLineId] != null && extendedCOstObj[bomLineId] != undefined)
                                                          {
                                                              extendedcost  = parseFloat(extendedCOstObj[bomLineId]).toFixed(2);
                                                          }
                                                  }*/
                var extendedCOstObj = component.get("v.miscExtndCost");

                if (
                  extendedCOstObj != null &&
                  extendedCOstObj != undefined &&
                  extendedCOstObj[bomLineId] != null &&
                  extendedCOstObj[bomLineId] != undefined
                ) {
                  extendedcost = parseFloat(extendedCOstObj[bomLineId]).toFixed(
                    2
                  );
                }
              } else if (serviceCategory == "Option") {
                var extendedCOstObj = component.get("v.OptionsExtndCost");

                if (
                  extendedCOstObj != null &&
                  extendedCOstObj != undefined &&
                  extendedCOstObj[bomLineId] != null &&
                  extendedCOstObj[bomLineId] != undefined
                ) {
                  extendedcost = parseFloat(extendedCOstObj[bomLineId]).toFixed(
                    2
                  );
                }
              }
              /* Comment added by Harika, regarding CAES-63 ticket, Date: 09-08-2022*/
              // if(serviceCategory == 'Fab' || serviceCategory == 'Install' || serviceCategory == 'Edge' || serviceCategory == 'Complete' || serviceCategory == 'Labor')
              if (
                serviceCategory == "Fab" ||
                serviceCategory == "Install" ||
                serviceCategory == "Edge" ||
                serviceCategory == "Fab & Install" ||
                serviceCategory == "Labor"
              ) {
                var fabLabormarkUpRateVal = component.get(
                  "v.fabLaborMarkupRate"
                );
                if (
                  fabLabormarkUpRateVal != null &&
                  fabLabormarkUpRateVal != undefined &&
                  fabLabormarkUpRateVal[bomLineId] != null &&
                  fabLabormarkUpRateVal[bomLineId] != undefined &&
                  fabLabormarkUpRateVal[bomLineId] != ""
                ) {
                  markupPercentage = parseFloat(
                    fabLabormarkUpRateVal[bomLineId]
                  );
                  markupPercentage = (markupPercentage * 100).toFixed(2);
                  if (map1.has(testoId)) {
                    if (!map1.get(testoId)) {
                      markupPercentage = 0;
                    }
                  }
                } else {
                  if (map1.has(testoId)) {
                    if (!map1.get(testoId)) {
                      markupPercentage = 0;
                    } else {
                      markupPercentage = 11.5;
                    }
                  } else {
                    markupPercentage = 11.5;
                  }
                }
              }
              /* Comment added by Harika, regarding CAES-54 ticket, Date: 26-07-2022*/
              /* if(serviceCategory != 'Fab' && serviceCategory != 'Complete' && helper.isNotPresentInSlab(serviceCategory) && serviceCategory != 'Install' && serviceCategory != 'Edge' && serviceCategory != 'Work Comp' && serviceCategory != 'Ins' &&
                              productCode != '69201198'
                             )
                             {*/
              /* Comment added by Harika, regarding CAES-63 ticket, Date: 09-08-2022*/
              if (
                serviceCategory != "Fab" /*serviceCategory != 'Complete'*/ &&
                serviceCategory != "Fab & Install" &&
                helper.isNotPresentInSlab(serviceCategory) &&
                serviceCategory != "Install" &&
                serviceCategory != "OCIP" &&
                serviceCategory != "Edge" &&
                serviceCategory != "Work Comp" &&
                serviceCategory != "Insurance" &&
                productCode != "69201198"
              ) {
                var nonSlabLaborrmarkUp = component.get("v.nonSlabExtndCost");
                if (
                  nonSlabLaborrmarkUp != null &&
                  nonSlabLaborrmarkUp != undefined &&
                  nonSlabLaborrmarkUp[bomLineId] != null &&
                  nonSlabLaborrmarkUp[bomLineId] != undefined &&
                  nonSlabLaborrmarkUp[bomLineId] != ""
                ) {
                  markupPercentage = parseFloat(nonSlabLaborrmarkUp[bomLineId]);
                  markupPercentage = (markupPercentage * 100).toFixed(2);
                  if (map1.has(testoId)) {
                    if (!map1.get(testoId)) {
                      markupPercentage = 0;
                    }
                  }
                } else {
                  // debugger;
                  if (map1.has(testoId)) {
                    if (!map1.get(testoId)) {
                      markupPercentage = 0;
                    } else {
                      markupPercentage = 11.5;
                    }
                  } else {
                    markupPercentage = 11.5;
                  }
                }
              }
              /* if(serviceCategory != 'Slab - Quartz')
                             {
                                 var slabDiscountmarkUp = component.get('v.slabDiscountRate');
                                 
                                 if(slabDiscountmarkUp != null && slabDiscountmarkUp != undefined && 
                                     slabDiscountmarkUp[bomLineId] != null && slabDiscountmarkUp[bomLineId] != undefined)
                                 {
                                     markupPercentage  = parseFloat(slabDiscountmarkUp[bomLineId]);
                                     markupPercentage = (markupPercentage * 100).toFixed(2);
                                 }
                                 else {
                                     markupPercentage = -44.5;
                                 }
                             }*/

              if (!bomIdVsExtendCost.has(bomLineId)) {
                // console.log('@@NOT FOUND--',bomLineId,'---Cost---',extendedcost);
                bomIdVsExtendCost.set(bomLineId, extendedcost);
              }
              // // console.log('@@extendedcost FINAL--',extendedcost);
              // console.log('@@markupPercentage--',markupPercentage);
              grossCost = parseFloat(properCost * parseFloat(quantity)).toFixed(
                2
              );

              var discountAmount =
                grossCost * (parseFloat(Math.abs(slabDiscount)) / 100); // added math.abs() for CAES-79
              // grossLessCost = grossCost - Math.abs(discountAmount); // commneted for CAES-79 for correct calculation
              grossLessCost = grossCost - discountAmount;
              var markupAmount = 0;
              console.log(
                "service category====++" +
                testo.buildertek__Location_Detail_Reference_1__c
              );

              console.log("markupPercentage 2===" + markupPercentage);
              markupAmount =
                grossLessCost * (parseFloat(markupPercentage) / 100);
              if (markupPercentage == "") markupAmount = 0;

              // var subTotalAmt = (extendedcost - discountAmount) + markupAmount;
              finalExtendedCost = parseFloat(
                grossLessCost + markupAmount
              ).toFixed(2);

              // console.log('testo service=='+testo.buildertek__BL_SERVICE_CATEGORY__c);
              //Extended Cost For Workers Comp and General Liability
              /* Comment added by Harika, regarding CAES-54 ticket, Date: 26-07-2022*/
              // if (serviceCategory == 'Ins' )
              if (serviceCategory == "Insurance") {
                console.log(
                  "v.generalLiabilityCost 1=====" +
                  component.get("v.generalLiabilityCost")
                );
                var extendedCOstObj = component.get("v.generalLiabilityCost");
                if (extendedCOstObj != null && extendedCOstObj != undefined) {
                  extendedCOstObj = Number(extendedCOstObj);
                  finalExtendedCost = parseFloat(extendedCOstObj).toFixed(2);
                } else {
                  finalExtendedCost = 0;
                }
              } else if (serviceCategory == "Work Comp") {
                var extendedCOstObj = component.get("v.workersCompCost");
                if (extendedCOstObj != null && extendedCOstObj != undefined) {
                  extendedCOstObj = Number(extendedCOstObj);
                  finalExtendedCost = parseFloat(extendedCOstObj).toFixed(2);
                } else {
                  finalExtendedCost = 0;
                }
              } else if (
                productCode != null &&
                productCode != undefined &&
                productCode == "69201198"
              ) {
                //Textura Fee Extended Cost
                var extendedCOstObj = component.get("v.texturaFeeCost");
                if (
                  extendedCOstObj != null &&
                  extendedCOstObj != undefined &&
                  extendedCOstObj != ""
                ) {
                  extendedCOstObj = Number(extendedCOstObj);
                  finalExtendedCost = parseFloat(extendedCOstObj).toFixed(2);
                } else {
                  finalExtendedCost = 0;
                }
              }

              // let salestax = 0;

              var final = 0.0;
              if (record[k].Key == "buildertek__Extended_Cost") {
                // record[k].value = finalExtendedCost;
                final = finalExtendedCost;
              }
              if (
                helper.isPresentInSlab(serviceCategory) ||
                serviceCategory == "Slab - Quartz" ||
                serviceCategory == "Misc" ||
                serviceCategory == "Option"
              ) {
                // if(serviceCategory == 'Option'){
                if (record[k].Key == "buildertek__Tax__c") {
                  // alert('ghgyugih'+record[k].Key);
                  taxedit = record[k].Value;
                  if (taxedit == true) {
                    salestax = finalExtendedCost * (taxRate1 / 100);
                    console.log("<<--salestax-->>" + salestax);
                  }
                }

                //   }else{
                //  alert('taxedit***->'+serviceCategory);
                //    salestax = finalExtendedCost * (taxRate1 / 100);
                //  }
              } else if (
                taxOnFabRequired == true &&
                (serviceCategory ==
                  "Fab" /*|| serviceCategory == 'Install' */ ||
                  serviceCategory == "Edge")
              ) {
                salestax = finalExtendedCost * (taxRate2 / 100);
                console.log('salestax :- ', salestax);
              }
              //These 3 service cats won't have SalesTax
              /* Comment added by Harika, regarding CAES-54 ticket, Date: 26-07-2022*/
              //if (serviceCategory == 'Ins' || serviceCategory == 'Work Comp'  || productCode == '69201198' || serviceCategory == 'Complete' || serviceCategory == 'Misc' ) // Add: serviceCategory == 'Misc'
              /* Comment added by Harika, regarding CAES-63 ticket, Date: 09-08-2022*/
              if (
                serviceCategory == "Insurance" ||
                serviceCategory == "Work Comp" ||
                productCode == "69201198" || //serviceCategory == 'Slab - Quartz' ||
                /*serviceCategory == 'Complete'*/
                serviceCategory == "Fab & Install" ||
                serviceCategory == "Misc"
              ) {
                // Add: serviceCategory == 'Misc'
                // salestax = 0;
                if (serviceCategory == "Misc") {
                  // || serviceCategory == 'Slab - Quartz') {
                  if (record[k].Key == "buildertek__Tax__c") {
                    // || record[k].Key == "buildertek__Discount_Amount") {
                    taxedit = record[k].Value;
                    if (taxedit == true) {
                      salestax = finalExtendedCost * (taxRate1 / 100);
                    }
                  }
                } else {
                  salestax = 0;
                }
              }

              // totalCost = Number(finalExtendedCost) + Number(salestax) ;
              // console.log('#@#@ totalCost---'+totalCost+'-----Name---'+record[2].Value);
              if (record[k].Key == "buildertek__Discount") {
                //alert('slabDiscount'+slabDiscount);
                record[k].Value = slabDiscount;
                record[k].fieldType = "PERCENTAGE";

                if (costAdjustmentColumnsPresent == false) {
                  costAdjustmentColumnsPresent = true;
                }
              }

              if (record[k].Key == "buildertek__Discount_Amount") {
                record[k].Value = parseFloat(discountAmount).toFixed(2);
              }

              if (record[k].Key == "buildertek__Markup_Amount") {
                record[k].Value = parseFloat(markupAmount).toFixed(2);
              }
              if (record[k].Key == "buildertek__Gross_Cost") {
                record[k].Value = parseFloat(grossCost).toFixed(2);
              }
              // if (record[k].Key == "buildertek__Extended_Cost") {
              //     var minustotal = parseFloat(finalExtendedCost) - (parseFloat(grossCost) - parseFloat(discountAmount));

              //     if (parseFloat(grossCost) < 0) {
              //         var totals = parseFloat(grossCost) + parseFloat(discountAmount);
              //         record[k].Value = totals + minustotal;
              //         finalExtendedCost = totals + minustotal;
              //     } else {
              //         record[k].Value = parseFloat(finalExtendedCost);
              //         finalExtendedCost = parseFloat(finalExtendedCost);
              //     }
              // }
              totalCost = Number(finalExtendedCost) + Number(salestax);

              if (record[k].Key == "buildertek__SalesTax") {
                console.log("salestax -> ", salestax);
                record[k].Value = parseFloat(salestax).toFixed(2);
              }

              if (record[k].Key == "buildertek__Markup") {
                console.log("markupPercentage -> ", markupPercentage);
                record[k].Value = markupPercentage;
              }

              if (record[k].Key == "buildertek__Total_Cost") {
                //  record[k].Value = parseFloat(totalCost).toFixed(2);
                //  record[k].Value = parseFloat(record[k].get(buildertek__SalesTax)).toFixed(2) + finalExtendedCost;
              }

              // if (record[k].Key == "buildertek__UOM_PL")
              // {
              //     record[k].Value = uomString;
              // }
            }
            console.log(
              "<--!costAdjustmentColumnsPresent!-->",
              costAdjustmentColumnsPresent
            );
            if (costAdjustmentColumnsPresent == false) {
              if (bomIdVsExtendCost.has(grpData[j].Id)) {
                extendedcost = parseFloat(
                  bomIdVsExtendCost.get(grpData[j].Id)
                ).toFixed(2);
              }
              //Discount Percentage
              record[lastindex + 1] = JSON.parse(
                '{"fieldType": "PERCENTAGE", "Key": "buildertek__Discount", "Value": "' +
                slabDiscount +
                '"}'
              );
              grossCost = parseFloat(properCost * parseFloat(quantity)).toFixed(
                2
              );

              var discountAmount =
                grossCost * (parseFloat(Math.abs(slabDiscount)) / 100); // added math.abs() for CAES-79
              // grossLessCost = grossCost - Math.abs(discountAmount); // commneted for CAES-79 for correct calculation
              grossLessCost = grossCost - discountAmount;
              record[lastindex + 2] = JSON.parse(
                '{"fieldType": "CURRENCY", "Key": "buildertek__Discount_Amount", "Value": "' +
                parseFloat(discountAmount).toFixed(2) +
                '"}'
              );

              //MarkUp
              var t = map1.keys();
              var testoId = testo.Id;

              record[lastindex + 3] = JSON.parse(
                '{"fieldType": "PERCENTAGE", "Key": "buildertek__Markup", "Value": "' +
                markupPercentage +
                '"}'
              );
              // * here we got the markup for all the BOM lines

              //MarkUp Amount
              console.log(
                "service category====3 ++" +
                testo.buildertek__Location_Detail_Reference_1__c
              );
              console.log("markupPercentage 3===" + markupPercentage);
              var markupAmount =
                grossLessCost * (parseFloat(markupPercentage) / 100);
              if (markupPercentage == "") markupAmount = 0;
              finalExtendedCost = parseFloat(
                grossLessCost + markupAmount
              ).toFixed(2);

              //Extended Cost For Workers Comp and General Liability
              /* Comment added by Harika, regarding CAES-54 ticket, Date: 26-07-2022*/
              // if (serviceCategory == 'Ins')

              if (serviceCategory == "Insurance") {
                console.log(
                  "v.generalLiabilityCost===" +
                  component.get("v.generalLiabilityCost")
                );
                var extendedCOstObj = component.get("v.generalLiabilityCost");
                if (extendedCOstObj != null && extendedCOstObj != undefined) {
                  extendedCOstObj = Number(extendedCOstObj);
                  finalExtendedCost = parseFloat(extendedCOstObj).toFixed(2);
                } else {
                  finalExtendedCost = 0;
                }
              } else if (serviceCategory == "Work Comp") {
                var extendedCOstObj = component.get("v.workersCompCost");
                if (extendedCOstObj != null && extendedCOstObj != undefined) {
                  extendedCOstObj = Number(extendedCOstObj);
                  finalExtendedCost = parseFloat(extendedCOstObj).toFixed(2);
                } else {
                  finalExtendedCost = 0;
                }
              } else if (
                productCode != null &&
                productCode != undefined &&
                productCode == "69201198"
              ) {
                //Textura Fee Extended Cost
                var extendedCOstObj = component.get("v.texturaFeeCost");
                if (
                  extendedCOstObj != null &&
                  extendedCOstObj != undefined &&
                  extendedCOstObj != ""
                ) {
                  extendedCOstObj = Number(extendedCOstObj);
                  finalExtendedCost = parseFloat(extendedCOstObj).toFixed(2);
                } else {
                  finalExtendedCost = 0;
                }
              }

              // var minustotal = parseFloat(finalExtendedCost) - (parseFloat(grossCost) - parseFloat(discountAmount));
              // console.log('minustotal=='+minustotal);
              // if (parseFloat(grossCost) < 0) {
              //     var totals = parseFloat(grossCost) + parseFloat(discountAmount);
              //     record[k].Value = totals + minustotal;
              //     finalExtendedCost = totals + minustotal;
              // }
              // else {
              //     record[k].Value = parseFloat(finalExtendedCost);
              //     finalExtendedCost = parseFloat(finalExtendedCost);
              // }

              record[lastindex + 4] = JSON.parse(
                '{"fieldType": "CURRENCY", "Key": "buildertek__Markup_Amount", "Value": "' +
                parseFloat(markupAmount).toFixed(2) +
                '"}'
              );
              record[lastindex + 5] = JSON.parse(
                '{"fieldType": "CURRENCY", "Key": "buildertek__Gross_Cost", "Value": "' +
                parseFloat(grossCost).toFixed(2) +
                '"}'
              );

              //Sub Total Amount
              record[lastindex + 6] = JSON.parse(
                '{"fieldType": "CURRENCY", "Key": "buildertek__Extended_Cost", "Value": "' +
                parseFloat(finalExtendedCost).toFixed(2) +
                '"}'
              );

              //Sales Tax

              if (
                helper.isPresentInSlab(serviceCategory) ||
                serviceCategory == "Slab - Quartz" ||
                serviceCategory == "Misc" ||
                serviceCategory == "Option"
              ) {
                if (serviceCategory == "Option") {
                  if (map1.has(testoId)) {
                    if (map1.get(testoId)) {
                      salestax = finalExtendedCost * (taxRate1 / 100);
                    } else {
                      salestax = 0;
                    }
                  }
                } else if (serviceCategory == "Slab - Quartz") {
                  if (map2.has(testoId)) {
                    if (map2.get(testoId)) {
                      salestax = finalExtendedCost * (taxRate1 / 100);
                    } else {
                      salestax = 0;
                    }
                  }
                } else {
                  if (record[k].Key == "buildertek__Tax__c") {
                    taxedit = record[k].Value;
                    if (taxedit == true) {
                      salestax = finalExtendedCost * (taxRate1 / 100);
                    }
                  } else {
                    salestax = finalExtendedCost * (taxRate1 / 100);
                  }
                }
                //  salestax = finalExtendedCost * (taxRate1 / 100);
              } else if (
                taxOnFabRequired == true &&
                (serviceCategory == "Fab" /*|| serviceCategory == 'Install'*/ ||
                  serviceCategory == "Edge")
              ) {
                salestax = finalExtendedCost * (taxRate2 / 100);
              }
              /* Comment added by Harika, regarding CAES-54 ticket, Date: 26-07-2022*/
              //   if (serviceCategory == 'Ins' || serviceCategory == 'Work Comp' || productCode == '69201198' || serviceCategory == 'Complete' || serviceCategory == 'Misc' )  // Add: serviceCategory == 'Misc'
              if (
                serviceCategory == "Insurance" ||
                serviceCategory == "Work Comp" ||
                productCode == "69201198" || // serviceCategory == 'Slab - Quartz'||
                /*serviceCategory == 'Complete'*/
                serviceCategory == "Fab & Install" ||
                serviceCategory == "Misc"
              ) {
                // Add: serviceCategory == 'Misc'
                // salestax = 0;
                if (serviceCategory == "Misc") {
                  //| serviceCategory == 'Slab - Quartz') {
                  if (record[k].Key == "buildertek__Tax__c") {
                    // || record[k].Key == "buildertek__Discount") {
                    taxedit = record[k].Value;
                    if (taxedit == true) {
                      salestax = finalExtendedCost * (taxRate1 / 100);
                    }
                  }
                } else {
                  salestax = 0;
                }
              }

              salestax = parseFloat(salestax).toFixed(2);
              finalExtendedCost = parseFloat(finalExtendedCost).toFixed(2);
              console.log("--salestax--" + salestax);
              console.log("--finalExtendedCost--" + finalExtendedCost);
              totalCost = Number(finalExtendedCost) + Number(salestax);
              if (serviceCategory == "Insurance") {
                console.log("finalExtendedCost==" + finalExtendedCost);
                console.log("totalCost===" + totalCost);
              }
              record[lastindex + 8] = JSON.parse(
                '{"fieldType": "CURRENCY", "Key": "buildertek__Total_Cost", "Value": "' +
                parseFloat(totalCost).toFixed(2) +
                '"}'
              );
              //    record[lastindex + 6] = JSON.parse('{"fieldType": "CURRENCY", "Key": "buildertek__SalesTax", "Value": "' + parseFloat(salestax).toFixed(2) + '"}');
              record[lastindex + 7] = JSON.parse(
                '{"fieldType": "CURRENCY", "Key": "buildertek__SalesTax", "Value": "' +
                salestax +
                '"}'
              );

              //* here we got the salestax for all the BOM lines

              //Total Cost

              /*   var minustotal = parseFloat(finalExtendedCost) - (parseFloat(grossCost) - parseFloat(discountAmount));
                               
                               if(parseFloat(grossCost) < 0){
                                   var totals = parseFloat(grossCost) + parseFloat(discountAmount);
                                   finalExtendedCost = totals + minustotal;
                               }
                               else{
                                   finalExtendedCost = parseFloat(finalExtendedCost);
                               }*/

              // salestax = parseFloat(salestax).toFixed(2);

              //alert('totalCost'+totalCost);
              // console.log('#@#@ totalCost---'+totalCost+'-----Name---'+record[2].Value);
              //       record[lastindex + 7] = JSON.parse('{"fieldType": "CURRENCY", "Key": "buildertek__Total_Cost", "Value": "' + parseFloat(totalCost).toFixed(2) + '"}');

              // record[lastindex + 8] = JSON.parse('{"fieldType": "STRING", "Key": "buildertek__UOM_PL", "Value": "' + uomString + '"}');
            }

            slabDiscount = 0;
            markupPercentage = 0;
            percentageOnFab = 0;
          }
        }
      }
    }
    component.set("v.bomLineFieldsSettings", bomLineFields);
    component.set("v.dataByGroup", allData);
    // console.log('dataByGroup Last--', component.get("v.dataByGroup"));
    component.set("v.orgData", groupByData);

    //helper.formatDataByGroups(component,event,helper,groupByDataNew,fieldMapTyp,allData[0].sObjectRecordsList);
    helper.calculateTotalCostAdjustment(component, event, helper);
    component.set("v.isLoading", false);
    // }
  },
  getProductCodeValue: function (prodCode, listOfProductCodes) {
    if (
      listOfProductCodes != null &&
      listOfProductCodes != undefined &&
      listOfProductCodes.length > 0
    ) {
      for (var i = 0; i < listOfProductCodes.length; i++) {
        if (listOfProductCodes[i].label == prodCode) {
          return listOfProductCodes[i].value;
        }
      }
    }
  },
  getProductCodes: function (component, event, helper) {
    component.set("v.isLoading", true);
    var bomDetais = component.get("v.bomList");

    //If we can't find the data from the DB then get the data from BOMLines
    if (bomDetais != null && bomDetais != undefined && bomDetais.length > 0) {
      var BOMID = component.get("v.recordId");

      var action = component.get("c.getproductCodes");
      action.setParams({
        bomId: BOMID,
      });

      action.setCallback(this, function (response) {
        var state = response.getState();

        if (state === "SUCCESS") {
          var productCodes = response.getReturnValue();
          if (
            bomDetais[0].buildertek__Fabrication_Install_Rate__c == null ||
            bomDetais[0].buildertek__Fabrication_Install_Rate__c == undefined ||
            bomDetais[0].buildertek__Fabrication_Install_Rate__c == ""
          ) {
            bomDetais[0].buildertek__Fabrication_Install_Rate__c =
              JSON.stringify(productCodes);
          } else {
            this.checkAllProductCodes(
              component,
              event,
              helper,
              "buildertek__Fabrication_Install_Rate__c",
              productCodes
            );
          }

          if (
            bomDetais[0].buildertek__Fab_Only_Rate__c == null ||
            bomDetais[0].buildertek__Fab_Only_Rate__c == undefined ||
            bomDetais[0].buildertek__Fab_Only_Rate__c == ""
          ) {
            bomDetais[0].buildertek__Fab_Only_Rate__c =
              JSON.stringify(productCodes);
          } else {
            this.checkAllProductCodes(
              component,
              event,
              helper,
              "buildertek__Fab_Only_Rate__c",
              productCodes
            );
          }

          if (
            bomDetais[0].buildertek__Install_Only__c == null ||
            bomDetais[0].buildertek__Install_Only__c == undefined ||
            bomDetais[0].buildertek__Install_Only__c == ""
          ) {
            bomDetais[0].buildertek__Install_Only__c =
              JSON.stringify(productCodes);
          } else {
            this.checkAllProductCodes(
              component,
              event,
              helper,
              "buildertek__Install_Only__c",
              productCodes
            );
          }

          if (
            bomDetais[0].buildertek__Mark_Up_Non_Slab_or_Labor__c == null ||
            bomDetais[0].buildertek__Mark_Up_Non_Slab_or_Labor__c ==
            undefined ||
            bomDetais[0].buildertek__Mark_Up_Non_Slab_or_Labor__c == ""
          ) {
            bomDetais[0].buildertek__Mark_Up_Non_Slab_or_Labor__c =
              JSON.stringify(productCodes);
          } else {
            this.checkAllProductCodes(
              component,
              event,
              helper,
              "buildertek__Mark_Up_Non_Slab_or_Labor__c",
              productCodes
            );
          }

          component.set("v.bomList", bomDetais);
          component.set("v.isLoading", false);
        } else {
          helper.showToast(
            component,
            event,
            helper,
            "Error!",
            "Something went wrong!",
            "error"
          );
          // console.log('Not success');
          component.set("v.isLoading", false);
        }
      });

      $A.enqueueAction(action);
    }
    component.set("v.isLoading", false);
  },
  checkAllProductCodes: function (
    component,
    event,
    helper,
    fieldName,
    updatedProdCodes
  ) {
    var bomDetais = component.get("v.bomList");
    var allProdCodesFromDBArray = [];
    var allUpdatedProductCodes = [];
    //buildertek__Fabrication_Install_Rate__c
    var allProdCodes = JSON.parse(bomDetais[0][fieldName]);
    for (var i = 0; i < allProdCodes.length; i++) {
      allProdCodesFromDBArray.push(allProdCodes[i].label);
    }
    for (var i = 0; i < updatedProdCodes.length; i++) {
      if (!allProdCodesFromDBArray.includes(updatedProdCodes[i].label)) {
        var jsonStr =
          '{"label": "' + updatedProdCodes[i].label + '", "value":""}';
        allProdCodes.push(JSON.parse(jsonStr));
      }
      allUpdatedProductCodes.push(updatedProdCodes[i].label);
    }

    //Check for any product code changes in the produc Table
    if (
      allProdCodes != null &&
      allProdCodes != undefined &&
      allProdCodes.length > 0
    ) {
      var allRefinedproductCodes = [];
      for (var i = 0; i < allProdCodes.length; i++) {
        if (allUpdatedProductCodes.includes(allProdCodes[i].label)) {
          allRefinedproductCodes.push(allProdCodes[i]);
        }
      }
      if (
        allRefinedproductCodes != null &&
        allRefinedproductCodes != undefined &&
        allRefinedproductCodes.length > 0
      ) {
        allProdCodes = [];
        allProdCodes = allRefinedproductCodes;
      }
    }

    if (
      allProdCodes != null &&
      allProdCodes != undefined &&
      allProdCodes.length > 0
    ) {
      bomDetais[0][fieldName] = JSON.stringify(allProdCodes);
    }
    component.set("v.bomList", bomDetais);
  },
  calculateTotalCostAdjustment: function (component, event, helper) {
    var extendedcost = 0;
    var ocipextendedcost = 0;
    var grosscost = 0;
    let totalDiscount = 0.0;
    let markup = 0.0;
    var discountAmount = 0;
    var markupAmount = 0;
    var subTotalAmt = 0;
    let salestax = 0.0;
    var totalCost = 0;
    var totalBomLinesCount = 0;
    var totalBaseTypeBomLinesCount = 0;
    var installCost = 0;
    let proposalAmount = 0;
    const serviceCatVsExtendedCost = new Map();
    const serviceCatVsTotalCostMap = new Map();
    const buildPhaseVsTotalCostMap = new Map();
    var optionValue = 0;
    var miscValue = 0;

    var totalRecords = component.get("v.listOfRecords");
    if (totalRecords != null && totalRecords != undefined) {
      if (
        totalRecords != null &&
        totalRecords != undefined &&
        totalRecords.length > 0
      ) {
        // totalBomLinesCount = totalRecords.length;
      }
    }

    var allData = component.get("v.dataByGroup");
    //  alert('allData'+allData);
    if (allData != null && allData != undefined) {
      for (var i = 0; i < allData.length; i++) {
        var recordList = allData[i].groupedRecordsTmp;
        var grpData = allData[i].groupData;
        if (recordList != null && recordList != undefined) {
          if (
            recordList != null &&
            recordList != undefined &&
            recordList.length > 0
          ) {
            //totalBomLinesCount = recordList.length;
            for (var j = 0; j < recordList.length; j++) {
              var serviceCategory = "";
              var thisProductCode = "";
              var thisBuildPhaseName = "";
              var ocipreq = "";
              if (
                grpData[j].buildertek__Takeoff_Line__r != null &&
                grpData[j].buildertek__Takeoff_Line__r != undefined &&
                /* grpData[j].buildertek__Service_Category__c != null
                                && grpData[j].buildertek__Service_Category__c != undefined
                                && grpData[j].buildertek__Service_Category__c != ''*/
                grpData[j].buildertek__BL_SERVICE_CATEGORY__c != null &&
                grpData[j].buildertek__BL_SERVICE_CATEGORY__c != undefined &&
                grpData[j].buildertek__BL_SERVICE_CATEGORY__c != ""
              ) {
                // serviceCategory = grpData[j].buildertek__Service_Category__c;
                serviceCategory = grpData[j].buildertek__BL_SERVICE_CATEGORY__c;
                /* if(!serviceCatVsExtendedCost.has(grpData[j].buildertek__Service_Category__c))
                                {
                                    serviceCatVsExtendedCost.set(grpData[j].buildertek__Service_Category__c,'0');
                                }
                                if(!serviceCatVsTotalCostMap.has(grpData[j].buildertek__Service_Category__c))
                                {
                                    serviceCatVsTotalCostMap.set(grpData[j].buildertek__Service_Category__c,'0');
                                }*/
                if (
                  !serviceCatVsExtendedCost.has(
                    grpData[j].buildertek__BL_SERVICE_CATEGORY__c
                  )
                ) {
                  serviceCatVsExtendedCost.set(
                    grpData[j].buildertek__BL_SERVICE_CATEGORY__c,
                    "0"
                  );
                }
                if (
                  !serviceCatVsTotalCostMap.has(
                    grpData[j].buildertek__BL_SERVICE_CATEGORY__c
                  )
                ) {
                  serviceCatVsTotalCostMap.set(
                    grpData[j].buildertek__BL_SERVICE_CATEGORY__c,
                    "0"
                  );
                }
              }
              if (
                grpData[j].buildertek__Product__r != null &&
                grpData[j].buildertek__Product__r != undefined &&
                grpData[j].buildertek__Product__r.ProductCode != null &&
                grpData[j].buildertek__Product__r.ProductCode != undefined &&
                grpData[j].buildertek__Product__r.ProductCode != ""
              ) {
                thisProductCode = grpData[j].buildertek__Product__r.ProductCode;
              }
              if (
                grpData[j].buildertek__Build_Phase__r != null &&
                grpData[j].buildertek__Build_Phase__r != undefined &&
                grpData[j].buildertek__Build_Phase__r.Name != null &&
                grpData[j].buildertek__Build_Phase__r.Name != undefined &&
                grpData[j].buildertek__Build_Phase__r.Name != ""
              ) {
                thisBuildPhaseName = grpData[j].buildertek__Build_Phase__r.Name;
              }
              if (
                grpData[j].buildertek__OCIP_CCIP_Required__c != null &&
                grpData[j].buildertek__OCIP_CCIP_Required__c != undefined &&
                grpData[j].buildertek__OCIP_CCIP_Required__c != null &&
                grpData[j].buildertek__OCIP_CCIP_Required__c != undefined &&
                grpData[j].buildertek__OCIP_CCIP_Required__c != ""
              ) {
                ocipreq = grpData[j].buildertek__OCIP_CCIP_Required__c;
              }
              var bomList = [];
              bomList = component.get("v.bomList");
              if (bomList != null && bomList != undefined) {
                ocipreq = bomList[0].buildertek__OCIP_CCIP_Required__c;
              }
              var record = recordList[j];
              if (record != null && record != undefined) {
                for (var k = 0; k < record.length; k++) {
                  // if (record[k].Key == "buildertek__Discount" && record[k].Value != null && record[k].Value != undefined) {
                  //     totalDiscount = Math.round((parseFloat(totalDiscount.toString()) + parseFloat(record[k].Value.toString())) * 100) / 100;
                  // }

                  // if (record[k].Key == "buildertek__Discount_Amount" && record[k].Value != null && record[k].Value != undefined) {
                  //     discountAmount = discountAmount + parseFloat(record[k].Value);
                  // }

                  if (
                    record[k].Key == "buildertek__Markup" &&
                    record[k].Value != null &&
                    record[k].Value != undefined &&
                    thisBuildPhaseName != null &&
                    thisBuildPhaseName != undefined &&
                    thisBuildPhaseName != "" &&
                    thisBuildPhaseName == "Base"
                  ) {
                    markup =
                      Math.round(
                        (parseFloat(markup.toString()) +
                          parseFloat(record[k].Value.toString())) *
                        100
                      ) / 100;
                    console.log("markup value===" + record[k].Value);

                    let theMarkUp = parseFloat(record[k].Value.toString());
                    // console.log('theMarkUp--',theMarkUp);
                    if (
                      theMarkUp != null &&
                      theMarkUp != undefined &&
                      theMarkUp != 0
                    ) {
                      totalBomLinesCount = totalBomLinesCount + 1;
                    }

                    // if(serviceCategory != null && serviceCategory != undefined && serviceCategory != '' &&
                    // thisProductCode != null && thisProductCode != undefined && thisProductCode != '' &&
                    // serviceCategory != 'Ins' && serviceCategory != 'Work Comp' && thisProductCode != '69201198')
                    // {
                    //     totalBomLinesCount = totalBomLinesCount + 1;
                    // }
                  }

                  // if (record[k].Key == "buildertek__Markup_Amount" && record[k].Value != null && record[k].Value != undefined) {
                  //     markupAmount = markupAmount + parseFloat(record[k].Value);
                  // }

                  // if (record[k].Key == "buildertek__SubTotal_Amount" && record[k].Value != null && record[k].Value != undefined) {
                  //     subTotalAmt = subTotalAmt + parseFloat(record[k].Value);
                  // }

                  if (
                    record[k].Key == "buildertek__SalesTax" &&
                    record[k].Value != null &&
                    record[k].Value != undefined &&
                    thisBuildPhaseName != null &&
                    thisBuildPhaseName != undefined &&
                    thisBuildPhaseName != "" &&
                    thisBuildPhaseName == "Base"
                  ) {
                    salestax =
                      Math.round(
                        (parseFloat(salestax.toString()) +
                          parseFloat(record[k].Value.toString())) *
                        100
                      ) / 100;
                    console.log("salestax :) -> ", record[k].Value);
                  }

                  if (
                    record[k].Key == "buildertek__Total_Cost" &&
                    record[k].Value != null &&
                    record[k].Value != undefined &&
                    thisBuildPhaseName != null &&
                    thisBuildPhaseName != undefined &&
                    thisBuildPhaseName != "" &&
                    thisBuildPhaseName == "Base"
                  ) {
                    totalCost = totalCost + parseFloat(record[k].Value);
                  }

                  if (
                    record[k].Key == "buildertek__Total_Cost" &&
                    record[k].Value != null &&
                    record[k].Value != undefined &&
                    serviceCategory != null &&
                    serviceCategory != undefined &&
                    serviceCategory != ""
                  ) {
                    /* Comment added by Harika, regarding CAES-54 ticket, Date: 26-07-2022*/
                    /*if (thisProductCode != null && thisProductCode != undefined && thisProductCode != '' &&
                                            serviceCategory != 'Ins' && serviceCategory != 'Work Comp' && thisProductCode != '69201198') 
                                            {*/
                    if (
                      thisProductCode != null &&
                      thisProductCode != undefined &&
                      thisProductCode != "" &&
                      serviceCategory != "Insurance" &&
                      serviceCategory != "Work Comp" &&
                      thisBuildPhaseName == "Base"
                    ) {
                      proposalAmount =
                        Number(proposalAmount) + Number(record[k].Value);
                      console.log("<--proposalAmount-->" + proposalAmount);
                      proposalAmount = parseFloat(proposalAmount).toFixed(2);
                      console.log("<--proposalAmount-->" + proposalAmount);
                    }

                    if (
                      serviceCatVsTotalCostMap.has(
                        serviceCategory
                      ) /*&& thisProductCode != '69201198'*/
                    ) {
                      let existingTotalCost = Number(
                        serviceCatVsTotalCostMap.get(serviceCategory)
                      );
                      let currentVal = Number(record[k].Value);
                      let updatedVal = existingTotalCost + currentVal;
                      updatedVal = parseFloat(updatedVal).toFixed(2);
                      serviceCatVsTotalCostMap.set(
                        serviceCategory,
                        String(updatedVal)
                      );
                    }
                    // else {

                    //     let currentVal = parseFloat(Number(record[k].Value)).toFixed(2);
                    //     serviceCatVsTotalCostMap.set(serviceCategory,String(currentVal));
                    // }
                  }

                  // if(record[k].Key == "buildertek__Total_Cost") {
                  //     alert("buildertek__Total_Cost");
                  // }
                  if (
                    record[k].Key == "buildertek__Total_Cost" &&
                    record[k].Value != null &&
                    record[k].Value != undefined &&
                    /*(*/
                    thisBuildPhaseName ==
                    "Option" /* || serviceCategory == 'Option') &&
                    thisProductCode != "69201198"*/
                  ) {
                    // alert('Inside');
                    optionValue = Number(optionValue) + Number(record[k].Value);
                  }
                  if (
                    record[k].Key == "buildertek__Total_Cost" &&
                    record[k].Value != null &&
                    record[k].Value != undefined &&
                    thisBuildPhaseName == "Misc"
                  ) {
                    miscValue = Number(miscValue) + Number(record[k].Value);
                  }
                  if (
                    record[k].Key == "buildertek__Extended_Cost" &&
                    record[k].Value != null &&
                    record[k].Value != undefined &&
                    thisProductCode != "69201198"
                  ) {
                    if (
                      thisBuildPhaseName != null &&
                      thisBuildPhaseName != undefined &&
                      thisBuildPhaseName != "" &&
                      thisBuildPhaseName == "Base"
                    ) {
                      extendedcost = extendedcost + parseFloat(record[k].Value);
                      console.log("extendedcost===" + extendedcost);
                    }
                    if (
                      thisBuildPhaseName != null &&
                      thisBuildPhaseName != undefined &&
                      thisBuildPhaseName != "" &&
                      serviceCategory == "OCIP"
                    ) {
                      ocipextendedcost =
                        ocipextendedcost + parseFloat(record[k].Value);
                    }

                    if (thisBuildPhaseName == "Base") {
                      component.set("v.buildPhaseName", thisBuildPhaseName);
                    }

                    if (
                      thisBuildPhaseName == "Base" &&
                      serviceCatVsExtendedCost.has(serviceCategory)
                    ) {
                      // console.log(thisBuildPhaseName + '_______________' + serviceCatVsExtendedCost.has(serviceCategory));
                      // console.log(serviceCategory);
                      // console.log('++++++++++++++++++++++++++++++++++++');
                      let existingExtendedCost = Number(
                        serviceCatVsExtendedCost.get(serviceCategory)
                      );
                      let currentVal = Number(record[k].Value);
                      let updatedVal = existingExtendedCost + currentVal;
                      updatedVal = parseFloat(updatedVal).toFixed(2);
                      console.log(updatedVal);
                      serviceCatVsExtendedCost.set(
                        serviceCategory,
                        String(updatedVal)
                      );
                    }
                  }
                  if (
                    record[k].Key == "buildertek__Gross_Cost" &&
                    record[k].Value != null &&
                    record[k].Value != undefined &&
                    thisProductCode != "69201198"
                  ) {
                    if (
                      thisBuildPhaseName != null &&
                      thisBuildPhaseName != undefined &&
                      thisBuildPhaseName != "" &&
                      thisBuildPhaseName == "Base"
                    ) {
                      // alert('parseFloat(record[k].Value);'+parseFloat(record[k].Value));
                      grosscost = grosscost + parseFloat(record[k].Value);
                    }
                  }
                }
              }

              thisBuildPhaseName = "";
            }
          }
        }
      }
    }

    //Calculate Average
    //totalDiscount = totalDiscount / totalBomLinesCount;
    // console.log('theMarkUp2--',markup);
    // console.log('theBomLines--',totalBomLinesCount);
    if (
      markup != null &&
      markup != undefined &&
      markup != 0 &&
      totalBomLinesCount != null &&
      totalBomLinesCount != undefined &&
      totalBomLinesCount != 0
    ) {
      markup = markup / totalBomLinesCount;
    }
    // console.log('theMarkUp3--',markup);
    markup = parseFloat(markup).toFixed(2);
    // salestax = salestax / totalBomLinesCount;
    salestax = parseFloat(salestax).toFixed(2);
    component.set("v.totalExtendedCost", extendedcost);
    component.set("v.totalGrossCost", grosscost);
    //component.set('v.totalDiscountPercent',totalDiscount);
    //component.set('v.totalDiscountAmount',discountAmount);
    component.set("v.totalMarkupPercent", markup);
    //component.set('v.totalMarkupAmount',markupAmount);
    //component.set('v.totalSubTotalAmount',subTotalAmt);
    component.set("v.totalSalesTax", salestax);
    component.set("v.totalAmount", totalCost);

    var custs = [];
    var servCatVsTotalCost = [];
    serviceCatVsExtendedCost.forEach(function (value, key) {
      // console.log(key + '_________' + value);
      custs.push({ value: value, key: key });
      // alert('key' +key == 'Install');
      // alert('value'+value);
      if (key == "Install") {
        if (ocipreq != false) {
          installCost = Number(installCost) + Number(value);
          // alert(installCost);
        } else {
          installCost = 0;
        }
      }
    });

    console.log(
      "**    optionValue          -------------------->: " + optionValue
    );
    if (optionValue) {
      serviceCatVsTotalCostMap.set("Option", String(optionValue));
    }
    if (miscValue) {
      serviceCatVsTotalCostMap.set("Misc", String(miscValue));
    } else {
      serviceCatVsTotalCostMap.set("Misc", 0);
    }

    serviceCatVsTotalCostMap.forEach(function (value, key) {
      console.log("key-->" + key);
      console.log("value-->" + value);
      servCatVsTotalCost.push({ value: value, key: key });
    });
    installCost = parseFloat(installCost).toFixed(2);
    // console.log('@@serviceCatVsExtendedCost--',serviceCatVsExtendedCost);
    // console.log('@@serviceCatVsTotalCostMap--',serviceCatVsTotalCostMap);
    // console.log('@@Expected Proposal Cost--',Number(serviceCatVsTotalCostMap.get("Misc")) + totalCost );
    // console.log('@@installCost--',installCost);
    // console.log('@@proposalAmount--',proposalAmount);
    // debugger;
    component.set("v.servCatVsExtendedCostMap", servCatVsTotalCost);
    component.set("v.totalInstallCost", installCost);
    component.set("v.totalProposalAmount", proposalAmount);
    console.log("<--proposalAmount-->" + proposalAmount);
    helper.reCalculateTable(
      component,
      event,
      helper,
      installCost,
      proposalAmount,
      ocipextendedcost,
      ocipreq
    );

    // alert('** Reached process');
    // debugger;
    // console.log('**      serviceCatVsTotalCostMap -------------->: ' + (JSON.stringify(serviceCatVsTotalCostMap)));

    let totalProposalBaseCost = 0 + totalCost;
    let totalProposalBaseValue = 0;
    if (serviceCatVsTotalCostMap.get("Misc")) {
      totalProposalBaseCost += Number(serviceCatVsTotalCostMap.get("Misc"));
    }

    totalProposalBaseValue = totalProposalBaseCost;
    if (serviceCatVsTotalCostMap.get("Option")) {
      totalProposalBaseValue += Number(serviceCatVsTotalCostMap.get("Option"));
    }

    component.set("v.totalProposalBaseCost", totalProposalBaseCost.toString()); // v.totalAmount
    component.set(
      "v.totalProposalBaseValue",
      totalProposalBaseValue.toString()
    );
    // $A.get('e.force:refreshView').fire();
  },
  reCalculateTable: function (
    component,
    event,
    helper,
    installCost,
    proposalAmount,
    ocipextendedcost,
    ocipreq
  ) {
    console.log(
      proposalAmount +
      "{..............}" +
      installCost +
      "Recalculate table+++++++++++++++++++++==========================="
    );
    const bomlineIdVsTexturaFee = new Map();
    const bomlineIdVsGLFee = new Map();
    const bomlineIdVsWCFee = new Map();
    var ocip_ccip_req;
    let glRateValue = 0.0;
    let wcRateValue = 0.0;
    var bomList = [];
    bomList = component.get("v.bomList");
    if (bomList != null && bomList != undefined) {
      if (
        bomList[0].buildertek__Textura_Fee__c != null &&
        bomList[0].buildertek__Textura_Fee__c != undefined &&
        bomList[0].buildertek__Textura_Fee__c.length > 0
      ) {
        var Textura = [];
        Textura = JSON.parse(bomList[0].buildertek__Textura_Fee__c);
        if (Textura != null && Textura != undefined && Textura.length > 0) {
          var rate = Textura[0].productRate;
          var theBomLine = Textura[0].bomLineId;
          if (
            rate != null &&
            rate != undefined &&
            proposalAmount != null &&
            proposalAmount != undefined
          ) {
            var texturaExtendedCost;
            console.log("rate-->" + Number(rate));
            var rateVal = Number(rate) * proposalAmount;
            console.log("rateVal==>" + rateVal);
            rateVal = parseFloat(rateVal).toFixed(2);
            console.log("rateVal==>" + rateVal);
            if (rateVal > 499.99 && rateVal < 3750.01) {
              texturaExtendedCost = parseFloat(rateVal).toFixed(2);
            } else if (rateVal < 500.0) {
              texturaExtendedCost = 500.0;
            } else if (rateVal > 3750.0) {
              texturaExtendedCost = 3750.0;
            }

            if (
              texturaExtendedCost != null &&
              texturaExtendedCost != undefined &&
              rateVal != null &&
              rateVal != undefined
            ) {
              Textura[0].extendedCostVal = texturaExtendedCost;
              Textura[0].proposalAmountVal =
                parseFloat(proposalAmount).toFixed(2);
              bomlineIdVsTexturaFee.set(theBomLine, texturaExtendedCost);
            }

            bomList[0].buildertek__Textura_Fee__c = JSON.stringify(Textura);
          }
        }
      }

      if (
        bomList[0].buildertek__General_Liability_Insurance_Long__c != null &&
        bomList[0].buildertek__General_Liability_Insurance_Long__c !=
        undefined &&
        ocipreq
      ) {
        var generalLiability = [];
        generalLiability = JSON.parse(
          bomList[0].buildertek__General_Liability_Insurance_Long__c
        );
        if (
          generalLiability != null &&
          generalLiability != undefined &&
          generalLiability.length > 0
        ) {
          var nominatorVal = generalLiability[0].productRate;
          var denominatorVal = generalLiability[0].denominatorVal;
          var theBomLine = generalLiability[0].bomLineId;
          if (
            proposalAmount != null &&
            proposalAmount != undefined &&
            nominatorVal != null &&
            nominatorVal != undefined &&
            denominatorVal != null &&
            denominatorVal != undefined
          ) {
            // proposalAmount = parseFloat(proposalAmount);
            nominatorVal = Number(nominatorVal);
            denominatorVal = Number(denominatorVal);

            var rateVal = proposalAmount * (nominatorVal / denominatorVal);
            rateVal = parseFloat(rateVal).toFixed(2);
            console.log("GL Rate----->", rateVal);
            if (rateVal != null && rateVal != undefined) {
              generalLiability[0].extendedCostVal = rateVal;
              glRateValue = rateVal;
              generalLiability[0].proposalAmountVal =
                parseFloat(proposalAmount).toFixed(2);
              bomlineIdVsGLFee.set(theBomLine, rateVal);
            }

            bomList[0].buildertek__General_Liability_Insurance_Long__c =
              JSON.stringify(generalLiability);
          }
        }
      }

      if (
        bomList[0].buildertek__Workers_Comp__c != null &&
        bomList[0].buildertek__Workers_Comp__c != undefined &&
        ocipreq
      ) {
        var workersComp = [];
        workersComp = JSON.parse(bomList[0].buildertek__Workers_Comp__c);
        if (
          workersComp != null &&
          workersComp != undefined &&
          workersComp.length > 0
        ) {
          var nominatorVal = workersComp[0].productRate;
          console.log("nominatorVal-->" + nominatorVal);
          if (!nominatorVal || nominatorVal == null) {
            nominatorVal = 1.11;
          }
          var denominatorVal = workersComp[0].denominatorVal;
          var theBomLine = workersComp[0].bomLineId;
          if (
            installCost != null &&
            installCost != undefined &&
            nominatorVal != null &&
            nominatorVal != undefined &&
            denominatorVal != null &&
            denominatorVal != undefined
          ) {
            // proposalAmount = parseFloat(proposalAmount);
            nominatorVal = Number(nominatorVal);
            denominatorVal = Number(denominatorVal);
            var rateVal = installCost * (nominatorVal / denominatorVal);
            rateVal = parseFloat(rateVal).toFixed(2);
            if (rateVal != null && rateVal != undefined) {
              workersComp[0].extendedCostVal = rateVal;
              wcRateValue = rateVal;
              workersComp[0].installCostVal =
                parseFloat(installCost).toFixed(2);
              bomlineIdVsWCFee.set(theBomLine, rateVal);
            }

            bomList[0].buildertek__Workers_Comp__c =
              JSON.stringify(workersComp);
          }
        }
      }
      /*if (wcRateValue != null && wcRateValue != undefined && glRateValue != null && glRateValue != undefined && bomList[0].buildertek__OCIP_CCIP_Required__c == true) {
                let OCIPVal = Number(wcRateValue) + Number(glRateValue) + Number(ocipextendedcost);
                console.log('OCIPVal----->', OCIPVal);
                console.log(installCost);
                console.log(nominatorVal);
                console.log(denominatorVal);
                console.log(installCost * (nominatorVal / denominatorVal));
                console.log(wcRateValue);
                console.log('------------------------------------');
                console.log(proposalAmount);
                 console.log(nominatorVal);
                console.log(denominatorVal);
                console.log(proposalAmount * (nominatorVal / denominatorVal));
                console.log(glRateValue);
              //  console.log(ocipextendedcost);
                bomList[0].buildertek__OCIP_CCIP__c = -OCIPVal;
            } else if (bomList[0].buildertek__OCIP_CCIP_Required__c == false) {
                bomList[0].buildertek__OCIP_CCIP__c = 0.00;
            }*/
      console.log(component.get("v.buildPhaseName") + "phase name is --------");
      var phaseName = component.get("v.buildPhaseName");
      let OCIPVal = 0.0;
      if (
        (phaseName == "Base" || phaseName == "Option") &&
        wcRateValue != null &&
        wcRateValue != undefined &&
        glRateValue != null &&
        glRateValue != undefined &&
        ocipreq
      ) {
        OCIPVal = (Number(wcRateValue) + Number(glRateValue)) * -1;
        bomList[0].buildertek__OCIP_CCIP__c = OCIPVal;
        console.log(OCIPVal + "Ocip vaalue is :)---------");
      } else {
        bomList[0].buildertek__OCIP_CCIP__c = 0.0;
      }

      // console.log('bomlineIdVsTexturaFee----->',bomlineIdVsTexturaFee);
      // console.log('bomlineIdVsGLFee----->',bomlineIdVsGLFee);
      // console.log('bomlineIdVsWCFee----->',bomlineIdVsWCFee);

      var allData = component.get("v.dataByGroup");
      if (allData != undefined) {
        for (var i = 0; i < allData.length; i++) {
          var groupedRecords = allData[i].groupedRecordsTmp;
          var grpData = allData[i].groupData;
          for (var j = 0; j < groupedRecords.length; j++) {
            var record = groupedRecords[j];
            var bomLineId;
            var texturaFee;
            var workrsCompFee;
            var GLFee;
            var theFInalExtendedcost;
            var productCode = "";
            var serviceCategory = "";
            var thisBuildPhaseName = "";

            if (
              grpData[j].buildertek__Takeoff_Line__r != null &&
              grpData[j].buildertek__Takeoff_Line__r != undefined &&
              /* grpData[j].buildertek__Service_Category__c != null
                             && grpData[j].buildertek__Service_Category__c != undefined
                             && grpData[j].buildertek__Service_Category__c != ''*/
              grpData[j].buildertek__BL_SERVICE_CATEGORY__c != null &&
              grpData[j].buildertek__BL_SERVICE_CATEGORY__c != undefined &&
              grpData[j].buildertek__BL_SERVICE_CATEGORY__c != ""
            ) {
              //  serviceCategory = grpData[j].buildertek__Service_Category__c;
              serviceCategory = grpData[j].buildertek__BL_SERVICE_CATEGORY__c;
            }
            if (
              grpData[j].buildertek__Build_Phase__r != null &&
              grpData[j].buildertek__Build_Phase__r != undefined &&
              grpData[j].buildertek__Build_Phase__r.Name != null &&
              grpData[j].buildertek__Build_Phase__r.Name != undefined &&
              grpData[j].buildertek__Build_Phase__r.Name != ""
            ) {
              thisBuildPhaseName = grpData[j].buildertek__Build_Phase__r.Name;
            }
            if (
              grpData[j].buildertek__Product__r != null &&
              grpData[j].buildertek__Product__r != undefined &&
              grpData[j].buildertek__Product__r.ProductCode != null &&
              grpData[j].buildertek__Product__r.ProductCode != undefined &&
              grpData[j].buildertek__Product__r.ProductCode != ""
            ) {
              productCode = grpData[j].buildertek__Product__r.ProductCode;
            }

            for (var k = 0; k < record.length; k++) {
              if (record[k].Key == "Id") {
                bomLineId = record[k].Value;
              }

              if (
                bomLineId != null &&
                bomLineId != "" &&
                bomlineIdVsTexturaFee != null &&
                bomlineIdVsTexturaFee != undefined
              ) {
                if (
                  bomlineIdVsTexturaFee.has(bomLineId) &&
                  bomlineIdVsTexturaFee.get(bomLineId) != null
                ) {
                  texturaFee = bomlineIdVsTexturaFee.get(bomLineId);
                }
              }
              if (
                bomLineId != null &&
                bomLineId != "" &&
                bomlineIdVsGLFee != null &&
                bomlineIdVsGLFee != undefined
              ) {
                if (
                  bomlineIdVsGLFee.has(bomLineId) &&
                  bomlineIdVsGLFee.get(bomLineId) != null
                ) {
                  GLFee = bomlineIdVsGLFee.get(bomLineId);
                }
              }

              // console.log('bomlineIdVsWCFee');
              // console.log(bomlineIdVsWCFee.get(bomLineId));
              if (
                bomLineId != null &&
                bomLineId != "" &&
                bomlineIdVsWCFee != null &&
                bomlineIdVsWCFee != undefined
              ) {
                if (
                  bomlineIdVsWCFee.has(bomLineId) &&
                  bomlineIdVsWCFee.get(bomLineId) != null
                ) {
                  workrsCompFee = bomlineIdVsWCFee.get(bomLineId);
                }
              }

              if (
                record[k].Key == "buildertek__Extended_Cost" &&
                productCode != null &&
                productCode != undefined &&
                productCode == "69201198" &&
                texturaFee != null &&
                texturaFee != undefined
              ) {
                record[k].Value = parseFloat(texturaFee).toFixed(2);
              }
              if (
                record[k].Key == "buildertek__Total_Cost" &&
                productCode != null &&
                productCode != undefined &&
                productCode == "69201198" &&
                texturaFee != null &&
                texturaFee != undefined
              ) {
                record[k].Value = parseFloat(texturaFee).toFixed(2);
              }
              /* Comment added by Harika, regarding CAES-54 ticket, Date: 26-07-2022*/
              /*if (record[k].Key == "buildertek__Extended_Cost" && serviceCategory != null && serviceCategory!= undefined && serviceCategory == 'Ins'
                            && GLFee != null && GLFee!= undefined)
                            {*/
              if (
                record[k].Key == "buildertek__Extended_Cost" &&
                serviceCategory != null &&
                serviceCategory != undefined &&
                serviceCategory == "Insurance" &&
                GLFee != null &&
                GLFee != undefined
              ) {
                if (
                  thisBuildPhaseName == "Base" ||
                  thisBuildPhaseName == "Option"
                ) {
                  record[k].Value = parseFloat(GLFee).toFixed(2);
                }
              }
              /* Comment added by Harika, regarding CAES-54 ticket, Date: 26-07-2022*/
              /*if (record[k].Key == "buildertek__Total_Cost" && serviceCategory != null && serviceCategory!= undefined && serviceCategory == 'Ins'
                            && GLFee != null && GLFee!= undefined)
                            {*/
              // console.log('record[k].Key=='+record[k].Key);
              // console.log('serviceCategory=='+serviceCategory);
              // console.log('GLFee=='+GLFee);
              if (
                record[k].Key == "buildertek__Total_Cost" &&
                serviceCategory != null &&
                serviceCategory != undefined &&
                serviceCategory == "Insurance" &&
                GLFee != null &&
                GLFee != undefined
              ) {
                if (
                  thisBuildPhaseName == "Base" ||
                  thisBuildPhaseName == "Option"
                ) {
                  record[k].Value = parseFloat(GLFee).toFixed(2);
                }
              }

              // console.log('OCIP=='+OCIPVal);
              if (
                record[k].Key == "buildertek__Total_Cost" &&
                serviceCategory != null &&
                serviceCategory != undefined &&
                serviceCategory == "OCIP"
              ) {
                if (
                  thisBuildPhaseName == "Base" ||
                  thisBuildPhaseName == "Option"
                ) {
                  record[k].Value = parseFloat(OCIPVal).toFixed(2);
                }
              }

              if (
                record[k].Key == "buildertek__Extended_Cost" &&
                serviceCategory != null &&
                serviceCategory != undefined &&
                serviceCategory == "Work Comp" &&
                workrsCompFee != null &&
                workrsCompFee != undefined
              ) {
                console.log("workrsCompFee val==" + workrsCompFee);
                record[k].Value = parseFloat(workrsCompFee).toFixed(2);
              }

              if (
                record[k].Key == "buildertek__Total_Cost" &&
                serviceCategory != null &&
                serviceCategory != undefined &&
                serviceCategory == "Work Comp" &&
                workrsCompFee != null &&
                workrsCompFee != undefined
              ) {
                record[k].Value = parseFloat(workrsCompFee).toFixed(2);
              }
            }

            // theFInalExtendedcost = 0;
          }
        }
      }

      component.set("v.dataByGroup", allData);

      // console.log('dataByGroup Final 2---->',allData);
      // console.log('bomList Final----->',bomList[0]);
      component.set("v.bomList", bomList);

      var action = component.get("c.calculateOCIP_CCIP");
      action.setParams({
        JSONData: JSON.stringify(component.get("v.bomList")),
      });
      action.setCallback(this, function (response) {
        var state = response.getState();
        if (state === "SUCCESS") {
          console.log("Success---");
        } else {
          console.log("@@Not Success");
        }
      });
      $A.enqueueAction(action);
    }
  },
  getCountryOptions: function (component, event, helper) {
    var action = component.get("c.getAllCountryList");

    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        // console.log('Country List---',response.getReturnValue());
        if (
          response.getReturnValue() != null &&
          response.getReturnValue() != undefined
        ) {
          component.set("v.countryoptions", response.getReturnValue());
        }
      } else {
        // console.log('@@Not Success');
        helper.showToast(
          component,
          event,
          helper,
          "Error!",
          "Something went wrong!",
          "error"
        );
      }
    });
    $A.enqueueAction(action);
  },
  getExtendedCosts: function (component, event, helper) {
    console.log("getExtendedCosts called===");
    component.set("v.isLoading", true);
    var BOMID = component.get("v.recordId");
    console.log("BOMID===" + BOMID);
    var action = component.get("c.getExtendedCosts");

    action.setParams({
      bomId: BOMID,
    });

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        var extendedCostRecords = response.getReturnValue();
        // console.log('#@#@extendedCostRecords--',extendedCostRecords);
        var nonSlab = "buildertek__Mark_Up_Non_Slab_or_Labor__c";
        var fabricationInstall = "buildertek__Fabrication_Install_Rate__c";
        var fabOnly = "buildertek__Fab_Only_Rate__c";
        var installOnly = "buildertek__Install_Only__c";
        var misc = "buildertek__Miscellaneous_Rates__c";
        var edge = "buildertek__Edge__c";
        var slabDiscount = "buildertek__Slab_Discount_Rate_LongText__c";
        var fabLaborMarkup =
          "buildertek__Fabrication_Labor_Mark_up_LongText__c";
        var optionsRate = "buildertek__Options_Rate__c";
        var workersComp = "buildertek__Workers_Comp__c";
        var generalLiability =
          "buildertek__General_Liability_Insurance_Long__c";
        var texturaFee = "buildertek__Textura_Fee__c";
        console.log("gl1=====" + extendedCostRecords[generalLiability]);
        if (
          extendedCostRecords[fabricationInstall] != null &&
          extendedCostRecords[fabricationInstall] != undefined
        ) {
          component.set(
            "v.fabInstallExtndCost",
            extendedCostRecords[fabricationInstall]
          );
        }
        if (
          extendedCostRecords[fabOnly] != null &&
          extendedCostRecords[fabOnly] != undefined
        ) {
          component.set("v.fabOnlyExtndCost", extendedCostRecords[fabOnly]);
        }
        if (
          extendedCostRecords[installOnly] != null &&
          extendedCostRecords[installOnly] != undefined
        ) {
          component.set(
            "v.installOnlyExtndCost",
            extendedCostRecords[installOnly]
          );
        }
        if (
          extendedCostRecords[nonSlab] != null &&
          extendedCostRecords[nonSlab] != undefined
        ) {
          component.set("v.nonSlabExtndCost", extendedCostRecords[nonSlab]);
        }
        if (
          extendedCostRecords[misc] != null &&
          extendedCostRecords[misc] != undefined
        ) {
          component.set("v.miscExtndCost", extendedCostRecords[misc]);
        }
        if (
          extendedCostRecords[edge] != null &&
          extendedCostRecords[edge] != undefined
        ) {
          component.set("v.edgeCost", extendedCostRecords[edge]);
        }
        if (
          extendedCostRecords[slabDiscount] != null &&
          extendedCostRecords[slabDiscount] != undefined
        ) {
          component.set(
            "v.slabDiscountRate",
            extendedCostRecords[slabDiscount]
          );
        }
        if (
          extendedCostRecords[fabLaborMarkup] != null &&
          extendedCostRecords[fabLaborMarkup] != undefined
        ) {
          component.set(
            "v.fabLaborMarkupRate",
            extendedCostRecords[fabLaborMarkup]
          );
        }
        if (
          extendedCostRecords[optionsRate] != null &&
          extendedCostRecords[optionsRate] != undefined
        ) {
          component.set("v.OptionsExtndCost", extendedCostRecords[optionsRate]);
          console.log("extendedCostRecords[optionsRate]");
          console.log(extendedCostRecords[optionsRate]);
        }
        if (
          extendedCostRecords[workersComp] != null &&
          extendedCostRecords[workersComp] != undefined
        ) {
          var recordDetail = extendedCostRecords[workersComp];
          component.set("v.workersCompCost", recordDetail[workersComp]);
        }
        if (
          extendedCostRecords[generalLiability] != null &&
          extendedCostRecords[generalLiability] != undefined
        ) {
          var recordDetail = extendedCostRecords[generalLiability];
          console.log("gl Insurance cost===" + recordDetail);
          console.log(recordDetail[generalLiability]);
          component.set(
            "v.generalLiabilityCost",
            recordDetail[generalLiability]
          );
        }
        if (
          extendedCostRecords[texturaFee] != null &&
          extendedCostRecords[texturaFee] != undefined
        ) {
          var recordDetail = extendedCostRecords[texturaFee];
          component.set("v.texturaFeeCost", recordDetail[texturaFee]);
        }
      } else {
        //helper.showToast(component, event, helper, 'Error!', 'Something went wrong!', 'error');
        // console.log('Not success extendedCostRecords');
        component.set("v.isLoading", false);
      }
    });

    $A.enqueueAction(action);
  },
  setCostAdjustmentTableColumns: function (component, event, helper) {
    var countrySelected = component.get("v.selectedCountryDB");
    if (countrySelected.includes("_")) {
      countrySelected = countrySelected.replace("_", " ");
    }
    component.set("v.adjustmentTableColumns", [
      //{label: 'Region: - State/Country/County', fieldName: 'buildertek__Region_State_Country_County__c', type: 'text', editable:'true'},
      // {label: 'Region: - State/Country/County',type: "button", typeAttributes: {
      //     //label: 'Region: - State/Country/County',
      //     label: countrySelected,
      //     name: 'state_Country',
      //     title: 'Region: - State/Country/County',
      //     disabled: false,
      //     value: 'state_Country',
      //     iconPosition: 'left'
      // }},
      {
        label: "Local Sales Tax",
        fieldName: "buildertek__Tax_Rate_1__c",
        type: "number",
        editable: "true",
        cellAttributes: { iconName: "utility:percent", iconPosition: "right" },
      },
      // {label: 'Fabrication and Install Rate', fieldName: 'buildertek__Fabrication_and_Install_rate__c', type: 'currency', editable:'true',typeAttributes: { currencyCode: 'USD', currencyDisplayAs : 'symbol',minimumFractionDigits :2,maximumFractionDigits: 2}},

      {
        label: "Fabrication and Install Rate",
        fieldName: "buildertek__Fabrication_Install_Rate__c",
        type: "button",
        typeAttributes: {
          label: "Click Here to Change Fabrication and Install Rate",
          name: "fabrication_Install_Rate",
          title: "Fabrication and Install Rate",
          disabled: false,
          value: "fabrication_Install_Rate",
          iconPosition: "left",
        },
      },
      {
        label: "Fabrication Only Rate",
        fieldName: "buildertek__Fab_Only_Rate__c",
        type: "button",
        typeAttributes: {
          label: "Click Here to Change Fabrication Only Rate",
          name: "fabrication_Only_Rate",
          title: "Fabrication Only Rate",
          disabled: false,
          value: "fabrication_Only_Rate",
          iconPosition: "left",
        },
      },
      {
        label: "Install Only",
        fieldName: "buildertek__Install_Only__c",
        type: "button",
        typeAttributes: {
          label: "Click Here to Change Install Only Rate",
          name: "Install_Only_Rate",
          title: "Install Only Rate",
          disabled: false,
          value: "Install_Only_Rate",
          iconPosition: "left",
        },
      },
      {
        label: "Edge Rate",
        fieldName: "buildertek__Edge__c",
        type: "button",
        typeAttributes: {
          label: "Click Here to Change Edge",
          name: "Edge_Rate",
          title: "Edge",
          disabled: false,
          value: "Edge_Rate",
          iconPosition: "left",
        },
      },

      // {label: 'Fabrication Only Rate', fieldName: 'buildertek__Fabrication_Only_Rate__c', type: 'currency', editable:'true',typeAttributes: { currencyCode: 'USD', currencyDisplayAs : 'symbol',minimumFractionDigits :2,maximumFractionDigits: 2}},
      // {label: 'Install Only', fieldName: 'buildertek__Install_Only__c', type: 'currency', editable:'true',typeAttributes: { currencyCode: 'USD', currencyDisplayAs : 'symbol',minimumFractionDigits :2,maximumFractionDigits: 2}},
      {
        label: "Tax on Fabrication",
        fieldName: "buildertek__Tax_on_Fabrication_Required__c",
        type: "boolean",
        cellAttributes: { class: "common-edit-col" },
        editable: "true",
      },
      {
        label: "Labor Only Sales Tax",
        fieldName: "buildertek__Tax_Rate_2__c",
        type: "number",
        editable: "true",
        cellAttributes: { iconName: "utility:percent", iconPosition: "right" },
        typeAttributes: { required: false },
      },
      // {label: 'Slab Discount Rate', fieldName: 'buildertek__Slab_Discount_Rate__c', type: 'number', editable:'true',cellAttributes: { iconName: 'utility:percent',iconPosition: 'right' }},
      {
        label: "Slab Discount Rate",
        fieldName: "buildertek__Slab_Discount_Rate_LongText__c",
        type: "button",
        typeAttributes: {
          label: "Click Here to Change Slab Discount Rate",
          name: "Slab_Discount_Rate",
          title: "Slab Discount Rate",
          disabled: false,
          value: "Slab_Discount_Rate",
          iconPosition: "left",
        },
      },
      // {label: 'Fabrication / Labor Mark-up', fieldName: 'buildertek__Fabrication_Labor_Mark_up__c', type: 'number', editable:'true',cellAttributes: { iconName: 'utility:percent',iconPosition: 'right' }},
      {
        label: "Fabrication / Labor Mark-up",
        fieldName: "buildertek__Fabrication_Labor_Mark_up_LongText__c",
        type: "button",
        typeAttributes: {
          label: "Click Here to Change Fabrication / Labor Mark-up Rate",
          name: "Fabrication_Labor_Markup",
          title: "Fabrication / Labor Mark-up",
          disabled: false,
          value: "Fabrication_Labor_Markup",
          iconPosition: "left",
        },
      },
      // {label: 'Mark Up (Non Slab) or (Labor)', fieldName: 'buildertek__Mark_Up_Non_Slab_or_Labor__c', type: 'number', editable:'true',cellAttributes: { iconName: 'utility:percent',iconPosition: 'right' }},
      {
        label: "Mark Up (Non Slab) or (Non Labor)",
        fieldName: "buildertek__Mark_Up_Non_Slab_or_Labor__c",
        type: "button",
        typeAttributes: {
          label: "Click Here to Change Mark Up (Non Slab) or (Non Labor) Rate",
          name: "MarkUp_nonSlab_Labor_Rate",
          title: "Mark Up (Non Slab) or (Labor) Rate",
          disabled: false,
          value: "MarkUp_nonSlab_Labor_Rate",
          iconPosition: "left",
        },
      },
      // {label: 'OCIP/CCIP Required', fieldName: 'buildertek__OCIP_CCIP_Required__c', type: 'boolean', editable:'true',cellAttributes: { class: 'common-edit-col' }},
      // {label: 'Workers Comp', fieldName: 'buildertek__Workers_Comp__c', type: 'number', editable:'true',cellAttributes: { iconName: 'utility:percent',iconPosition: 'right' }},
      {
        label: "OCIP/CCIP Required",
        fieldName: "buildertek__OCIP_CCIP_Required__c",
        type: "button",
        typeAttributes: {
          label: "Click Here to Change OCIP/CCIP Required Value",
          name: "OCIP_CCIP_Required",
          title: "OCIP/CCIP Required",
          disabled: false,
          value: "OCIP_CCIP_Required",
          iconPosition: "left",
        },
      },
      {
        label: "Workers Comp",
        fieldName: "buildertek__Workers_Comp__c",
        type: "button",
        typeAttributes: {
          label: "Click Here to Change Workers Comp",
          name: "Workers_Comp",
          title: "Workers Comp",
          disabled: false,
          value: "Workers_Comp",
          iconPosition: "left",
        },
      },
      // {label: 'General Liability Insurance', fieldName: 'buildertek__General_Liability_Insurance_Long__c', type: 'number', editable:'true'},
      {
        label: "General Liability Insurance",
        fieldName: "buildertek__General_Liability_Insurance_Long__c",
        type: "button",
        typeAttributes: {
          label: "Click Here to Change General Liability Insurance",
          name: "General_Liability_Insurance",
          title: "General Liability Insurance",
          disabled: false,
          value: "General_Liability_Insurance",
          iconPosition: "left",
        },
      },
      {
        label: "OCIP/CCIP",
        fieldName: "buildertek__OCIP_CCIP__c",
        type: "currency",
        typeAttributes: {
          currencyCode: "USD",
          currencyDisplayAs: "symbol",
          minimumFractionDigits: 2,
          maximumFractionDigits: 2,
        },
      },
      {
        label: "Textura Fee",
        fieldName: "buildertek__Textura_Fee__c",
        type: "button",
        typeAttributes: {
          label: "Click Here to Change Textura Fee",
          name: "Textura_Fee",
          title: "Textura Fee",
          disabled: false,
          value: "Textura_Fee",
          iconPosition: "left",
        },
      },
      // {label: 'Textura Fee', fieldName: 'buildertek__Textura_Fee__c', type: 'currency', editable:'true',typeAttributes: { currencyCode: 'USD', currencyDisplayAs : 'symbol',minimumFractionDigits :2,maximumFractionDigits: 2}},
      // {label: 'Last Modified By', fieldName: 'LastModifiedByName', type: 'text'}
      {
        label: "Miscellaneous Rates",
        fieldName: "buildertek__Miscellaneous_Rates__c",
        type: "button",
        typeAttributes: {
          label: "Click Here to Change Miscellaneous Rates",
          name: "Miscellaneous_Rates",
          title: "Miscellaneous Rates",
          disabled: false,
          value: "Miscellaneous_Rates",
          iconPosition: "left",
        },
      },
      {
        label: "Options",
        fieldName: "buildertek__Options_Rate__c",
        type: "button",
        typeAttributes: {
          label: "Click Here to Change Options Rates",
          name: "Options_Rate",
          title: "Options",
          disabled: false,
          value: "Options_Rate",
          iconPosition: "left",
        },
      },
    ]);

    console.log(component.get("v.adjustmentTableColumns"));
    console.log("-----------Table columns are----------");
  },
  validateData: function (component, event, helper) {
    var updatedRecords = component
      .find("adjustmentTaxesTable")
      .get("v.draftValues");
    var dataFromDB = component.get("v.bomList");

    if (
      updatedRecords != null &&
      updatedRecords &&
      updatedRecords.length > 0 &&
      updatedRecords[0].buildertek__Tax_on_Fabrication_Required__c != null &&
      updatedRecords[0].buildertek__Tax_on_Fabrication_Required__c == true
    ) {
      //If Tax rate 2 is blank or 0 then show error
      //Check the DB value also
      if (
        (updatedRecords[0].buildertek__Tax_Rate_2__c != null &&
          updatedRecords[0].buildertek__Tax_Rate_2__c != undefined &&
          (updatedRecords[0].buildertek__Tax_Rate_2__c == "" ||
            parseInt(updatedRecords[0].buildertek__Tax_Rate_2__c) == 0)) ||
        ((updatedRecords[0].buildertek__Tax_Rate_2__c == null ||
          updatedRecords[0].buildertek__Tax_Rate_2__c == undefined) &&
          (dataFromDB[0].buildertek__Tax_Rate_2__c == null ||
            dataFromDB[0].buildertek__Tax_Rate_2__c == undefined ||
            dataFromDB[0].buildertek__Tax_Rate_2__c == "" ||
            parseInt(dataFromDB[0].buildertek__Tax_Rate_2__c) == 0))
      ) {
        helper.showToast(
          component,
          event,
          helper,
          "Error!",
          "Tax Rate 2 cannot be 0 when Tax on Fabrication is Required.",
          "error"
        );
        return false;
      }
      // else if(dataFromDB[0].buildertek__Tax_Rate_2__c == null || dataFromDB[0].buildertek__Tax_Rate_2__c == undefined || (dataFromDB[0].buildertek__Tax_Rate_2__c == '' || parseInt(dataFromDB[0].buildertek__Tax_Rate_2__c) == 0 ) )
      // {
      //     helper.showToast(component, event, helper, 'Error!', 'Tax Rate 2 cannot be 0 when Tax on Fabrication is Required.', 'error');
      //     return false;
      // }
    }

    //If Tax Rate 2 changed and it's 0 check the Tax Fab Required is true or not
    if (
      updatedRecords != null &&
      updatedRecords &&
      updatedRecords.length > 0 &&
      updatedRecords[0].buildertek__Tax_Rate_2__c != null &&
      updatedRecords[0].buildertek__Tax_Rate_2__c != undefined &&
      (parseInt(updatedRecords[0].buildertek__Tax_Rate_2__c) == 0 ||
        updatedRecords[0].buildertek__Tax_Rate_2__c == "")
    ) {
      if (
        updatedRecords[0].buildertek__Tax_on_Fabrication_Required__c != null &&
        updatedRecords[0].buildertek__Tax_on_Fabrication_Required__c !=
        undefined &&
        updatedRecords[0].buildertek__Tax_on_Fabrication_Required__c == true
      ) {
        helper.showToast(
          component,
          event,
          helper,
          "Error!",
          "Tax Rate 2 cannot be 0 when Tax on Fabrication is Required.",
          "error"
        );
        return false;
      } else if (
        dataFromDB[0].buildertek__Tax_on_Fabrication_Required__c != null &&
        dataFromDB[0].buildertek__Tax_on_Fabrication_Required__c != undefined &&
        dataFromDB[0].buildertek__Tax_on_Fabrication_Required__c == true
      ) {
        helper.showToast(
          component,
          event,
          helper,
          "Error!",
          "Tax Rate 2 cannot be 0 when Tax on Fabrication is Required.",
          "error"
        );
        return false;
      }
    }

    if (
      updatedRecords != null &&
      updatedRecords &&
      updatedRecords.length > 0 &&
      updatedRecords[0].buildertek__OCIP_CCIP_Required__c != null &&
      updatedRecords[0].buildertek__OCIP_CCIP_Required__c == true
    ) {
      if (
        (updatedRecords[0].buildertek__Workers_Comp_Insurance_Rate__c != null &&
          updatedRecords[0].buildertek__Workers_Comp_Insurance_Rate__c !=
          undefined &&
          updatedRecords[0].buildertek__Workers_Comp_Insurance_Rate__c == "" &&
          updatedRecords[0].buildertek__General_Liability_Insurance__c !=
          null &&
          updatedRecords[0].buildertek__General_Liability_Insurance__c !=
          undefined &&
          updatedRecords[0].buildertek__General_Liability_Insurance__c == "") ||
        ((updatedRecords[0].buildertek__Workers_Comp_Insurance_Rate__c ==
          null ||
          updatedRecords[0].buildertek__Workers_Comp_Insurance_Rate__c ==
          undefined) &&
          (updatedRecords[0].buildertek__General_Liability_Insurance__c ==
            null ||
            updatedRecords[0].buildertek__General_Liability_Insurance__c ==
            undefined) &&
          (dataFromDB[0].buildertek__Workers_Comp_Insurance_Rate__c == null ||
            dataFromDB[0].buildertek__Workers_Comp_Insurance_Rate__c ==
            undefined ||
            dataFromDB[0].buildertek__Workers_Comp_Insurance_Rate__c == "" ||
            dataFromDB[0].buildertek__General_Liability_Insurance__c == null ||
            dataFromDB[0].buildertek__General_Liability_Insurance__c ==
            undefined ||
            dataFromDB[0].buildertek__General_Liability_Insurance__c == ""))
      ) {
        helper.showToast(
          component,
          event,
          helper,
          "Error!",
          '"Workers Comp Insurance Rate" and "General Liability Insurance" must be entered when OCIP/CCIP is Required.',
          "error"
        );
        return false;
      }
      // else if(dataFromDB[0].buildertek__Workers_Comp_Insurance_Rate__c == null ||
      //     dataFromDB[0].buildertek__Workers_Comp_Insurance_Rate__c == undefined ||
      //     dataFromDB[0].buildertek__Workers_Comp_Insurance_Rate__c == '' ||
      //     dataFromDB[0].buildertek__General_Liability_Insurance__c == null ||
      //     dataFromDB[0].buildertek__General_Liability_Insurance__c == undefined ||
      //     dataFromDB[0].buildertek__General_Liability_Insurance__c == '' )
      // {
      //     // console.log('2nd condition');
      //     helper.showToast(component, event, helper, 'Error!', '"Workers Comp Insurance Rate" and "General Liability Insurance" must be entered when OCIP/CCIP is Required.', 'error');
      //     return false;
      // }
    }

    if (
      (updatedRecords != null &&
        updatedRecords &&
        updatedRecords.length > 0 &&
        updatedRecords[0].buildertek__Workers_Comp_Insurance_Rate__c != null &&
        updatedRecords[0].buildertek__Workers_Comp_Insurance_Rate__c !=
        undefined &&
        updatedRecords[0].buildertek__Workers_Comp_Insurance_Rate__c == "") ||
      (updatedRecords[0].buildertek__General_Liability_Insurance__c != null &&
        updatedRecords[0].buildertek__General_Liability_Insurance__c !=
        undefined &&
        updatedRecords[0].buildertek__General_Liability_Insurance__c == "")
    ) {
      if (
        dataFromDB != null &&
        dataFromDB != undefined &&
        dataFromDB[0].buildertek__OCIP_CCIP_Required__c != null &&
        dataFromDB[0].buildertek__OCIP_CCIP_Required__c != undefined &&
        dataFromDB[0].buildertek__OCIP_CCIP_Required__c == true
      ) {
        helper.showToast(
          component,
          event,
          helper,
          "Error!",
          '"Workers Comp Insurance Rate" and "General Liability Insurance" must be entered when OCIP/CCIP is Required.',
          "error"
        );
        return false;
      }
    }

    return true;
  },

  /**
   *
   * Replaced "s*erviceCategory == 'Slab'" with "isPresentInSlab(serviceCategory)"
   */
  isPresentInSlab: function (value) {
    return [
      "Slab",
      "Slab - Quartz",
      "Slab - Granite",
      "Slab - Porcelain",
    ].includes(value);
  },

  /**
   *
   * Replaced "s*erviceCategory != 'Slab'" with "isPresentInSlab(serviceCategory)"
   */
  isNotPresentInSlab: function (value) {
    return ![
      "Slab",
      "Slab - Quartz",
      "Slab - Granite",
      "Slab - Porcelain",
    ].includes(value);
  },
  getfieldData: function (component, event, helper) {
    var allData = this.storeAllData;
    var lineMap = new Map();
    console.log("allData -> ", { allData });
    for (let i = 0; i < allData.length; i++) {
      const record = allData[i].groupedRecordsTmp;
      var groupName = allData[i].groupName;
      for (let j = 0; j < record.length; j++) {
        const singleRecord = record[j];
        var listOfLine = [];
        for (let k = 0; k < singleRecord.length; k++) {
          if (singleRecord[k].Key === "Id") {
            var id = singleRecord[k].Value;
          }
          if (singleRecord[k].Key === "buildertek__Discount") {
            listOfLine.push(String(singleRecord[k].Value));
            listOfLine.push(String(groupName));
          }
          if (singleRecord[k].Key === "buildertek__Markup") {
            listOfLine.push(String(singleRecord[k].Value));
          }
          if (singleRecord[k].Key === "buildertek__SalesTax") {
            listOfLine.push(String(singleRecord[k].Value));
          }
          if (singleRecord[k].Key === "buildertek__Total_Cost") {
            listOfLine.push(String(singleRecord[k].Value));
          }
          lineMap.set(id, listOfLine);
        }
      }
    }
    //iterate over map and if value is empty then set it to 0
    lineMap.forEach((value, key) => {
      if (value[0] == null || value[0] == undefined || value[0] == "") {
        value[0] = "0";
      }
      if (value[1] == null || value[1] == undefined || value[1] == "") {
        value[1] = "0";
      }
      if (value[2] == null || value[2] == undefined || value[2] == "") {
        value[2] = "0";
      }
      if (value[3] == null || value[3] == undefined || value[3] == "") {
        value[3] = "0";
      }
      if(value[4] == null || value[4] == undefined || value[4] == ""){
        value[4] = "0";
      }
    });
    return lineMap;
  },
  quote: function (component, event, helper) {
    var myFieldMap = helper.getfieldData(component, event, helper);
    console.log('************************************');
    myFieldMap.forEach(element => {
      // console.log('element ==> ',{element});
      element[0] = Math.abs(element[0]).toFixed(2);
    });
    console.log('myFieldMap ===> ',{myFieldMap});
    debugger;
    var obj = Object.fromEntries(myFieldMap);
    var jsonString = JSON.stringify(obj);
    console.log("myFieldMap --> ", { myFieldMap });
    console.log('myFieldMap --> ',jsonString);
    component.set("v.Spinner", true);
    var action = component.get("c.createQuoteMethod");
    action.setParams({
      recordId: component.get("v.recordId"),
      mapFieldData: jsonString,
    });
    action.setCallback(this, function (response) {
      var status = response.getState();
      console.log("status ==> " + status);
      var result = response.getReturnValue();
      console.log("result ==> " + result);
      if (result[0] === "Success") {
        helper.showToast1(
          component,
          event,
          helper,
          "Success",
          "Quote Created Successfully",
          "success"
        );
        var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          recordId: result[1],
          slideDevName: "Detail",
        });
        navEvt.fire();
      } else if (result[0] == "notNull") {
        helper.showToast1(
          component,
          event,
          helper,
          "Quote Present",
          "Quote is already Created on BOM",
          "info"
        );
      } else if (result[0] == "null") {
        helper.showToast1(
          component,
          event,
          helper,
          "No Lines",
          "There are no BOMLines",
          "info"
        );
      } else {
        console.log("Error -> ", result);
        helper.showToast1(
          component,
          event,
          helper,
          "Error",
          "Something Went Wrong",
          "error"
        );
      }

      component.set("v.Spinner", false);
    });
    $A.enqueueAction(action);
  },
  showToast1: function (component, event, helper, title, message, type) {
    console.log("title ", title);
    console.log("messge ", message);
    console.log("type ", type);
    var toastEvent = $A.get("e.force:showToast");
    toastEvent.setParams({
      title: title,
      message: message,
      type: type,
      duration: 3000,
    });
    toastEvent.fire();
  },
});