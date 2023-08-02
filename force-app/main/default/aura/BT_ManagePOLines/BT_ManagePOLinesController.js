({
  doInit: function (component, event, helper) {
    var pageReference = component.get("v.pageReference");
    //var bomIdFromParentCmp = pageReference.attributes.attributes.recordId;
    var urlBomId = pageReference.state.buildertek__bomRecordId;

    if (urlBomId != null && urlBomId != undefined && urlBomId != "") {
      component.set("v.recordId", urlBomId);
    }

    helper.checkFabricationTaxes(component, event, helper);
    component.set("v.massUpdateEnable", false);
    var pageNumber = component.get("v.PageNumber");
    var pageSize = component.get("v.pageSize");
    var action = component.get("c.getProject");
    action.setParams({
      recordId: component.get("v.recordId"),
    });
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS") {
        console.log("response.getReturnValue()-->" + response.getReturnValue());
        var projectData = JSON.parse(JSON.stringify(response.getReturnValue()));
        console.log("projectData-->" + projectData);
        if (projectData.buildertek__Project__c) {
          component.set(
            "v.projectName",
            projectData.buildertek__Project__r.Name
          );
          component.set("v.projectId", projectData.buildertek__Project__r.Id);
        }
        if (projectData.buildertek__Opportunity__c) {
          component.set(
            "v.opportunityName",
            projectData.buildertek__Opportunity__r.Name
          );
          component.set(
            "v.opportunityId",
            projectData.buildertek__Opportunity__r.Id
          );
        }
        component.set("v.BOMName", projectData.Name);
        setTimeout(function () {
          var workspaceAPI = component.find("workspace");
          workspaceAPI
            .getFocusedTabInfo()
            .then(function (response) {
              var focusedTabId = response.tabId;
              workspaceAPI.setTabLabel({
                tabId: focusedTabId,
                label: "Product Lines",
              });
              workspaceAPI.setTabIcon({
                tabId: focusedTabId,
                icon: "custom:custom70",
              });
            })
            .catch(function (error) {
              console.log("sub tab error::", error);
              // alert(error);
            });
        }, 100);
        //changed on 17-dec 11:17 only 2 lines
        // component.set("v.projectName",projectData.buildertek__Project__r.Name);
        // component.set("v.projectId",projectData.buildertek__Project__r.Id);
      }
    });
    $A.enqueueAction(action);
    helper.fetchTakeOffLinesData(component, event, helper);
    helper.setColumns(component);
    // helper.getPoLinesList(component, event, helper,pageNumber,pageSize);

    window.setTimeout(
      $A.getCallback(function () {
        helper.getPoLinesList(component, event, helper, pageNumber, pageSize);
      }),
      1500
    );

    var billOfMeterialId = component.get("v.recordId");
    component.set("v.bomId", billOfMeterialId);

    //  helper.getPoList(component, event, helper);
  },
  redirect: function (component, event, helper) {
    // var workspaceAPI = component.find("workspace");
    // workspaceAPI.getFocusedTabInfo().then(function(response) {
    //     var focusedTabId = response.tabId;
    //     var recId = component.get("v.recordId");
    //     workspaceAPI.closeTab({tabId: focusedTabId}).then(function(response) {
    //         var navEvt = $A.get("e.force:navigateToSObject");
    //         navEvt.setParams({
    //             "recordId": component.get("v.recordId"),
    //             "slideDevName": "related"
    //         });
    //         navEvt.fire();
    //     })
    // })
    // .catch(function(error) {
    //     var navEvt = $A.get("e.force:navigateToSObject");
    //     navEvt.setParams({
    //         "recordId": component.get("v.recordId"),
    //         "slideDevName": "related"
    //     });
    //     navEvt.fire();
    //     console.log(error);
    // });

    var navEvt = $A.get("e.force:navigateToSObject");
    navEvt.setParams({
      recordId: component.get("v.recordId"),
      slideDevName: "related",
    });
    navEvt.fire();

    var workspaceAPI = component.find("workspace");
    workspaceAPI
      .getFocusedTabInfo()
      .then(function (response) {
        var focusedTabId = response.tabId;
        workspaceAPI.closeTab({
          tabId: focusedTabId,
        });
      })
      .catch(function (error) {
        console.log("Error", error);
      });
  },

  doSearch: function (component, event, helper) {
    //var value = component.get("v.searchRfqFilter");//event.getSource().get("v.value");
    var pageNumber = component.get("v.PageNumber");
    var pageSize = component.get("v.pageSize");
    helper.getPoLinesList(component, event, helper, pageNumber, pageSize);
  },
  handleNext: function (component, event, helper) {
    var pageNumber = component.get("v.PageNumber");
    var pageSize = component.get("v.pageSize");
    pageNumber++;
    helper.getPoLinesList(component, event, helper, pageNumber, pageSize);
    //helper.getRfqList(component, event, helper, pageNumber, pageSize, vendorValue, tradeValue, descriptionValue);
  },

  handlePrev: function (component, event, helper) {
    var pageNumber = component.get("v.PageNumber");
    var pageSize = component.get("v.pageSize");
    pageNumber--;
    helper.getPoLinesList(component, event, helper, pageNumber, pageSize);
    //helper.getRfqList(component, event, helper, pageNumber, pageSize, vendorValue, tradeValue, descriptionValue);
  },

  /*doGroupByVendorPhase: function(component, event, helper) {
        var data = component.get("v.orgData");
        var toggleVal = component.get("v.groupBytoggle");
        component.set("v.selectedTableRows", []);
        component.set("v.selectedTableRowIds", []);
       	helper.formatDataByGroups(component,event,helper,data); 
    },*/
  /*checkToogle: function(component, event, helper) {
        event.preventDefault();
        var data = component.get("v.orgData");
        var checked = event.getSource().get("v.name");
        component.set("v.selectedTableRows", []);
        component.set("v.selectedTableRowIds", []);
        component.set("v.selectedRecords",[]);
        component.set("v.Spinner", true);
        if(checked == "Group By Phase"){
            if(!event.getSource().get("v.checked")){
                //event.getSource().set("v.checked",true);
                component.find("phase").set("v.checked",true);
                component.find("vendor").set("v.checked",false);
                //component.set("v.groupByVendortoggle",false);
                component.set("v.groupBytoggle",false);
                
            }else{
                component.find("phase").set("v.checked",false);
                //component.set("v.groupByVendortoggle",true);
                component.find("vendor").set("v.checked",true);
                component.set("v.groupBytoggle",true);
                
            }
        }else if(checked == "Group By Vendor"){
            if(!event.getSource().get("v.checked")){
                component.find("vendor").set("v.checked",true);
                component.find("phase").set("v.checked",false);
                //component.set("v.groupByPhasetoggle",false);
                component.set("v.groupBytoggle",true);
            }else{
                component.find("vendor").set("v.checked",false);
                component.find("phase").set("v.checked",true);
                //component.set("v.groupByPhasetoggle",true);
                component.set("v.groupBytoggle",false);
            }
        }
        var toggleVal = component.get("v.groupBytoggle");
        helper.formatDataByGroups(component,event,helper,data); 
    },*/

  checkToogle: function (component, event, helper) {
    event.preventDefault();
    var data = component.get("v.orgData");

    var checked = event.getSource().get("v.name");
    component.set("v.selectedTableRows", []);
    component.set("v.selectedTableRowIds", []);
    component.set("v.selectedRecords", []);
    component.set("v.Spinner", true);
    if (checked == "Group By Phase") {
      if (!event.getSource().get("v.checked")) {
        //event.getSource().set("v.checked",true);
        component.find("phase").set("v.checked", true);
        // component.find("vendor").set("v.checked",false);
        component.find("category").set("v.checked", false);
        //component.set("v.groupByVendortoggle",false);
        component.set("v.groupByPhasetoggle", true);
        component.set("v.groupByVendortoggle", false);
        component.set("v.groupByCategorytoggle", false);
        component.set("v.groupByBuildChecked", true);
        component.set("v.groupByServiceCategorytoggle", false);
      }
    } else if (checked == "Group By Vendor") {
      if (!event.getSource().get("v.checked")) {
        component.find("vendor").set("v.checked", true);
        component.find("phase").set("v.checked", false);
        component.find("category").set("v.checked", false);
        //component.set("v.groupByPhasetoggle",false);

        component.set("v.groupByPhasetoggle", false);
        component.set("v.groupByVendortoggle", true);
        component.set("v.groupByCategorytoggle", false);
      }
    } else if (checked == "Group By Category") {
      if (!event.getSource().get("v.checked")) {
        // component.find("vendor").set("v.checked",false);
        component.find("phase").set("v.checked", false);
        component.find("category").set("v.checked", true);
        //component.set("v.groupByPhasetoggle",false);

        component.set("v.groupByPhasetoggle", false);
        component.set("v.groupByVendortoggle", false);
        component.set("v.groupByCategorytoggle", true);
        component.set("v.groupByServiceCategorytoggle", false);
      }
    } else if (checked == "Group By Service Category") {
      if (!event.getSource().get("v.checked")) {
        // component.find("vendor").set("v.checked",false);
        component.find("phase").set("v.checked", false);
        component.find("category").set("v.checked", false);
        component.find("service_category").set("v.checked", true);
        //component.set("v.groupByPhasetoggle",false);

        component.set("v.groupByPhasetoggle", false);
        component.set("v.groupByVendortoggle", false);
        component.set("v.groupByCategorytoggle", false);
        component.set("v.groupByServiceCategorytoggle", true);
      }
    }
    var toggleVal = component.get("v.groupBytoggle");
    console.log("@@Toggle Data--" + JSON.stringify(data));
    helper.formatDataByGroups(
      component,
      event,
      helper,
      data,
      component.get("v.fieldmaptype"),
      component.get("v.sObjectRecords")
    );
  },

  handleSort: function (component, event, helper) {
    event.preventDefault();
    var classIndex = event.currentTarget.dataset.sortgroupindex;
    var ele = event.currentTarget;
    var data = JSON.parse(JSON.stringify(component.get("v.dataByGroup")))[
      classIndex
    ]["groupedRecordsTmp"];
    var sortBy = event.currentTarget.dataset.sortby;
    var sortDirection = component.get("v.sortDirection");
    if (!sortDirection) {
      sortDirection = component.get("v.defaultSortDirection");
    }

    let arrayFields = component.get("v.bomLineFieldsSettings");
    let firstChild = event.currentTarget.firstChild;
    if (firstChild && !sortBy) {
      let firstChildText = firstChild.innerHTML;
      for (let fieldElem of arrayFields) {
        if (fieldElem["label"] === firstChildText) {
          if (fieldElem["value"]) {
            sortBy = fieldElem["value"];
          } else {
            sortBy = fieldElem["name"];
          }
        }
      }
    }

    helper.sortData(component, event, sortBy, sortDirection, data);
  },

  selectAll: function (component, event, helper) {
    var checkStatus = event.currentTarget.checked;
    var classIndex = event.currentTarget.className.split("_")[1];
    var rowIndex = [];
    var rfqRecordList = JSON.parse(
      JSON.stringify(component.get("v.dataByGroup"))
    )[classIndex]["groupData"]; //JSON.parse(JSON.stringify(component.get("v.recordsList")));
    var getAllId = document.getElementsByClassName("selectCheck_" + classIndex); //component.find("checkRFQ");
    var recordIds = component.get("v.JselectedRecordsIds");
    var selectedRecordMap = JSON.parse(
      JSON.stringify(component.get("v.selectedRecordMap"))
    );
    var vendors = [];
    if (checkStatus) {
      if (rfqRecordList.length) {
        if (selectedRecordMap == null) {
          selectedRecordMap = new Map();
        }
        for (var i = 0; i < getAllId.length; i++) {
          document.getElementsByClassName("selectCheck_" + classIndex)[
            i
          ].checked = true;
          rowIndex.push(
            document
              .getElementsByClassName("selectCheck_" + classIndex)
              [i].id.split("rowId_")[1]
          );
          var Id = document.getElementsByClassName("selectCheck_" + classIndex)[
            i
          ].value;

          if (recordIds.indexOf(Id) == -1) {
            recordIds.push(Id);
          }
        }
        var filteredData = rfqRecordList.filter(function (item, index) {
          if (rowIndex.indexOf(String(index)) > -1) {
            return item;
          }
        });
        /*for(var i in filteredData){
                        if(filteredData[i].buildertek__Vendor__c){
                            if (!selectedRecordMap.has(filteredData[i].buildertek__Vendor__c)) {
                                selectedRecordMap.set(filteredData[i].buildertek__Vendor__c, []);
                                vendors.push(filteredData[i].buildertek__Vendor__c);
                            }
                            selectedRecordMap.get(filteredData[i].buildertek__Vendor__c).push(JSON.parse(JSON.stringify(filteredData[i])));
                        }else{
                            vendors.push("No Vendor");
                            //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                            if (!selectedRecordMap.has('No Vendor')) {
                                selectedRecordMap.set('No Vendor', []);
                            }
                            //console.log(recordsMap.has('No vendor'),recordsMap.get("No vendor"))
                            selectedRecordMap.get('No Vendor').push(JSON.parse(JSON.stringify(filteredData[i])));
                            //console.log(recordsMap.get("No vendor"))
                        }
                    }*/
        //console.log(selectedRecordMap);
        //component.set("v.vendors",vendors);
        component.set("v.JselectedRecordsIds", recordIds);
        //component.set("v.selectedRecordMap",selectedRecordMap);
      }
    } else {
      if (rfqRecordList.length) {
        for (var i = 0; i < getAllId.length; i++) {
          document.getElementsByClassName("selectCheck_" + classIndex)[
            i
          ].checked = false;
          var Id = document.getElementsByClassName("selectCheck_" + classIndex)[
            i
          ].value;
          if (recordIds.indexOf(Id) > -1) {
            var index = recordIds.indexOf(Id);
            recordIds.splice(index, 1);
          }
          var selectedRecordMap = new Map();
          component.set("v.vendors", []);
          component.set("v.JselectedRecordsIds", []);
          component.set("v.selectedRecordMap", selectedRecordMap);
        }
        component.set("v.JselectedRecordsIds", recordIds);
      }
    }
    console.log(recordIds);
    if (recordIds.length == 0) {
      event.currentTarget.checked = false;
    }
  },
  selectRow: function (component, event, helper) {
    var checkbox = event.currentTarget;
    var classIndex = event.currentTarget.className.split("_")[1];
    var headCheckBox = document.getElementsByClassName(
      "checkSelectAll_" + classIndex
    )[0];
    var selectedRfqIds = component.get("v.JselectedRecordsIds");
    var getAllId = document.getElementsByClassName("selectCheck_" + classIndex);
    var selectedRecordMap = JSON.parse(
      JSON.stringify(component.get("v.selectedRecordMap"))
    );
    var vendors = [];
    var rowIndex = JSON.parse(
      JSON.stringify(component.get("v.selectedRowIndex"))
    );
    var currentTableRowIds = [];
    if (checkbox.checked) {
      if (selectedRfqIds.indexOf(checkbox.value) == -1) {
        selectedRfqIds.push(checkbox.value);
      }
      var checkIndex = 0;
      if (selectedRfqIds.length >= getAllId.length) {
        for (var i = 0; i < getAllId.length; i++) {
          currentTableRowIds.push(getAllId[i].value);
          if (selectedRfqIds.indexOf(getAllId[i].value) > -1) {
            checkIndex++;
          }
        }
        if (!headCheckBox.checked && checkIndex == getAllId.length) {
          headCheckBox.checked = true;
        }
      }
    } else {
      if (headCheckBox.checked) {
        headCheckBox.checked = false;
      }
      if (selectedRfqIds.indexOf(checkbox.value) > -1) {
        var index = selectedRfqIds.indexOf(checkbox.value);
        selectedRfqIds.splice(index, 1);
      }
    }

    console.log(selectedRfqIds);
    component.set("v.JselectedRecordsIds", selectedRfqIds);
  },

  newPO: function (component, event, helper) {
    var selectedIds = JSON.parse(
      JSON.stringify(component.get("v.JselectedRecordsIds"))
    );
    if (selectedIds.length > 0) {
      var action = component.get("c.createPO");
      component.set("v.Spinner", true);
      component.set("v.showMessage", true);
      action.setParams({
        selectedIds: selectedIds,
        recordId: component.get("v.recordId"),
      });
      action.setCallback(this, function (response) {
        if (response.getState() == "SUCCESS") {
          component.set("v.Spinner", false);
          component.set("v.showMessage", false);
          location.reload();
        } else {
          console.log(response);
        }
      });
      $A.enqueueAction(action);
    } else {
      var toastEvent = $A.get("e.force:showToast");
      toastEvent.setParams({
        message: "No Selected Product Option Lines",
        type: "ERROR",
        duration: "5000",
        mode: "dismissible",
      });
      toastEvent.fire();
    }
  },
  showVendor: function (component, event, helper) {
    var action = component.get("c.getVendors");
    var Id = event.currentTarget.id;
    component.set("v.optionLineId", Id);
    event.preventDefault();
    component.set("v.Spinner", true);
    action.setParams({
      optionLineID: Id, //,"recordId": component.get("v.recordId")
    });
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS") {
        console.log(response.getReturnValue());
        component.set("v.Spinner", false);
        if (JSON.parse(JSON.stringify(response.getReturnValue())).length) {
          component.set(
            "v.vendorList",
            JSON.parse(JSON.stringify(response.getReturnValue()))
          );
          component.set("v.showModal", true);
        } else {
          component.find("notifLib").showNotice({
            variant: "error",
            header: "No Vendor",
            message: "No other Vendors found for this product",
            closeCallback: function () {},
          });
        }

        //component.set("v.showMessage",false);
        //location.reload();
      } else {
        console.log(response);
      }
    });
    $A.enqueueAction(action);
  },
  closeVendor: function (component, event, helper) {
    event.preventDefault();
    component.set("v.showModal", false);
  },
  deleteVendor: function (component, event, helper) {
    event.preventDefault();
    component.set("v.showModal", false);
    component.set("v.isDeletetakeoffLines", false);
    component.set("v.Spinner", true);
    var action = component.get("c.deleteOptionLine");
    //  var Id= event.currentTarget.id;
    //  alert(Id);
    var id1 = component.get("v.storeId");
    //  alert(id1)
    action.setParams({
      productId: component.get("v.selectedVendor"),
      projectId: component.get("v.projectId"),
      optionLineId: id1,
    });
    action.setCallback(this, function (response) {
      if (response.getState() == "SUCCESS") {
        //  alert('success state');
        component.set("v.Spinner", false);
        var pageNumber = component.get("v.PageNumber");
        console.log(response.getReturnValue());
        var pageSize = component.get("v.pageSize");

        if (response.getReturnValue() == "Deleted") {
          $A.get("e.force:refreshView").fire();
          //  alert('return value is deleted');
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Success",
            message: "This Product is Deleted Successfully",
            duration: " 5000",
            key: "info_alt",
            type: "success",
            mode: "pester",
          });
          toastEvent.fire();
        } else {
          //  alert('po is there');
          var toastEvent = $A.get("e.force:showToast");
          toastEvent.setParams({
            title: "Error",
            message:
              "Please Delete the Purchase Order for this Product Line before deletion",
            duration: " 5000",
            key: "info_alt",
            type: "error",
            mode: "pester",
          });
          toastEvent.fire();
        }
      }
    });
    $A.enqueueAction(action);
  },

  saveVendor: function (component, event, helper) {
    event.preventDefault();
    component.set("v.showModal", false);
    if (component.get("v.selectedVendor")) {
      component.set("v.Spinner", true);
      var action = component.get("c.createNewOptionLine");
      action.setParams({
        productId: component.get("v.selectedVendor"),
        projectId: component.get("v.projectId"),
        optionLineId: component.get("v.optionLineId"),
      });
      action.setCallback(this, function (response) {
        if (response.getState() == "SUCCESS") {
          var pageNumber = component.get("v.PageNumber");
          console.log(response.getReturnValue());
          var pageSize = component.get("v.pageSize");
          //component.set()
          helper.getPoLinesList(component, event, helper, pageNumber, pageSize);
          component.set("v.optionLineId", "");
        }
      });
      $A.enqueueAction(action);
    }
  },
  selectedVendorItem: function (component, event, helper) {
    var selectedVendor = event.currentTarget.value; //component.get("v.selectedVendor");
    component.set("v.selectedVendor", selectedVendor);
  },

  onMassUpdate: function (component, event, helper) {
    component.set("v.isLoading", true);
    var checkFabrication = component.get("v.showFabricationDetails");
    console.log("@@Mass update--", component.get("v.massUpdateEnable"));
    if (!component.get("v.massUpdateEnable")) {
      component.set("v.massUpdateEnable", true);
      component.set("v.isLoading", false);
      if (checkFabrication == true) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        helper.getPoLinesList(component, event, helper, pageNumber, pageSize);
      }
    } else if (component.get("v.massUpdateEnable")) {
      component.set("v.isLoading", true);
      component.set("v.massUpdateEnable", false);
      helper.updateMassRecords(component, event, helper);
      helper.calculateCostAdjustment(component, event, helper);
      if (checkFabrication == true) {
        window.setTimeout(
          $A.getCallback(function () {
            helper.calculateCostAdjustment(component, event, helper);
          }),
          2000
        );
      }
    }
  },

  onMassUpdateCancel: function (component, event, helper) {
    var checkFabrication = component.get("v.showFabricationDetails");
    if (component.get("v.massUpdateEnable")) {
      // component.set('v.listOfRecords', JSON.parse(JSON.stringify(component.get('v.cloneListOfRecords'))));
      component.set("v.dataByGroup", component.get("v.cloneDataByGroup"));

      component.set("v.massUpdateEnable", false);
      if (checkFabrication == true) {
        helper.calculateCostAdjustment(component, event, helper);
      }
    }
  },

  onAddClick: function (component, event, helper) {
    var fields = component.get("v.fieldValues");
    var list = component.get("v.listOfRecords");
    var obj = {};
    for (var i in fields) {
      obj[fields[i].name] = "";
      if (fields[i].type == "BOOLEAN") {
        obj[fields[i].name] = false;
      }
    }
    list.unshift(obj);
    component.set("v.listOfRecords", list);
  },

  deleteRecord: function (component, event, helper) {
    var target = event.target;
    var index = target.getAttribute("data-index");
    var records = component.get("v.listOfRecords");
    if (records[index].Id != undefined) {
      component.set("v.selectedRecordIndex", index);
      component.set("v.quoteLineName", records[index].Name);
      component.set("v.isModalOpen", true);
    } else if (records[index].Id == undefined) {
      records.splice(index, 1);
      component.set("v.listOfRecords", records);
    }
  },

  handleCancel: function (component, event, helper) {
    component.set("v.isModalOpen", false);
  },

  handleDelete: function (component, event, helper) {
    var records = component.get("v.listOfRecords");
    var index = component.get("v.selectedRecordIndex");
    if (records[index].Id != undefined) {
      component.set("v.listOfRecords", records);
      component.set("v.isModalOpen", false);
      helper.deleteRecord(component, event, helper, records[index].Id);
    }
  },
  redirectToPreviousCmp: function (component, event, helper) {
    // var evt = $A.get("e.force:navigateToComponent");
    // evt.setParams({
    //     componentDef: "c:DuplicateSSTLFromProducts",
    //     componentAttributes: {
    //         recordId: component.get("v.recordId")
    //     }
    // });
    // evt.fire();

    component.find("goToPrevious").navigate({
      type: "standard__component",
      attributes: {
        componentName: "buildertek__DuplicateSSTLFromProducts",
        attributes: {
          recordId: component.get("v.recordId"),
        },
      },
      // state: {
      //     "c__recordId": component.get("v.recordId")
      // }
    });
  },
  handleBTAdmin: function (component, event, helper) {
    console.log("<--handleBTAdmin-->");
    component.set("v.isLoading", true);
    var BOMID = component.get("v.recordId");
    var action = component.get("c.getBTAdminRecorDetails");
    var slabDiscount;
    var taxRate1;
    var savedSelectedCountry;

    action.setParams({
      recordId: BOMID,
    });

    action.setCallback(this, function (response) {
      var state = response.getState();

      if (state === "SUCCESS") {
        var bomRecords = response.getReturnValue();
        console.log('seee bomRecords ', bomRecords);
        //If the records present then we will show the table otherwise we will let the user to fill the field values
        if (
          bomRecords != null &&
          bomRecords != undefined &&
          bomRecords.length > 0
        ) {
          //Set the LastModifiedBy value
          for (var i = 0; i < bomRecords.length; i++) {
            bomRecords[i].LastModifiedByName =
              bomRecords[i].LastModifiedBy.Name;
            // slabDiscount = bomRecords[i].buildertek__Slab_Discount_Rate__c;
            taxRate1 = bomRecords[i].buildertek__Tax_Rate_1__c;
            console.log("<--taxRate1-->" + taxRate1);
            savedSelectedCountry =
              bomRecords[i].buildertek__Region_State_Country_County__c;
          }

          component.set("v.bomList", bomRecords);
          component.set("v.showAdjustmentTable", true);
          component.set("v.isLoading", false);

          helper.getExtendedCosts(component, event, helper);
          console.log("GL====" + component.get("v.generalLiabilityCost"));

          // //helper.getCountryOptions(component, event, helper);
          // if(savedSelectedCountry != null && savedSelectedCountry != undefined)
          // {
          //     component.set('v.selectedCountry',savedSelectedCountry);
          //     component.set("v.selectedCountryDB",savedSelectedCountry);
          // }
          console.log("adjustmentTableColumns call ******************");

          helper.setCostAdjustmentTableColumns(component, event, helper);
          console.log("adjustmentTableColumns call ******************");

          //helper.calculateCostAdjustment(component, event, helper);
          window.setTimeout(
            $A.getCallback(function () {
              var isUpdated = component.get("v.adjustCostUpdated");
              console.log("isUpdated--", isUpdated);
              if (isUpdated == true) {
                component.set("v.adjustCostUpdated", false);
                var pageNumber = component.get("v.PageNumber");
                var pageSize = component.get("v.pageSize");
                helper.getPoLinesList(
                  component,
                  event,
                  helper,
                  pageNumber,
                  pageSize
                );
              } else {
                helper.calculateCostAdjustment(component, event, helper);
              }
            }),
            2000
          );
          console.log(
            "adjustmentTableColumns call *******-------------------***********"
          );

          //helper.getProductCodes(component, event, helper);
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
        console.log("Not success");
        component.set("v.isLoading", false);
      }
    });

    $A.enqueueAction(action);
  },

  onAdjustmentTableSave: function (component, event, helper) {
    console.log('onAdjustmentTableSave');

    var updatedRecords = component.find("adjustmentTaxesTable") .get("v.draftValues");

    console.log(updatedRecords , '_________________update Records are______________')
    // var successfullValidation = helper.validateData( component, event, helper );
    // console.log('successfullValidation--',successfullValidation);

    // if (successfullValidation != null && successfullValidation != undefined && successfullValidation == true)
    // {
    var action = component.get("c.updateBomRecords");
    action.setParams({
      updatedBomList: updatedRecords,
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var result = response.getReturnValue();
        console.log("result***", result);

        if (result.isSuccess) {
          helper.showToast(
            component,
            event,
            helper,
            "Success",
            "Record Saved Successfully.",
            "success"
          );
          component.find("adjustmentTaxesTable").set("v.draftValues", null);
          component.set("v.bomList", null);
          var action = component.get("c.handleBTAdmin");
          $A.enqueueAction(action);
        } else {
          console.log("@@Return Value False");
          helper.showToast(component,event,helper,
              "Error!",
              result.message,
              "error"
          );
        }
      } else {
        console.log("@@Not Success");
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
    // $A.get("e.force:refreshView").fire();
    $A.enqueueAction(action);
    // }
  },
  closeCountryModal: function (component, event, helper) {
    component.set("v.showCountryModal", false);
  },
  closeProductCodeModal: function (component, event, helper) {
    console.log("@@API---", component.get("v.fieldAPINameToPass"));
    component.set("v.showProductCodeModal", false);
    var fieldApiName = component.get("v.fieldAPINameToPass");
    if (
      fieldApiName != null &&
      fieldApiName != undefined &&
      fieldApiName != "" &&
      (fieldApiName == "buildertek__General_Liability_Insurance_Long__c" ||
        fieldApiName == "buildertek__Workers_Comp__c" ||
        fieldApiName == "buildertek__Textura_Fee__c")
    ) {
      var action = component.get("c.handleBTAdmin");
      $A.enqueueAction(action);
    }
  },
  handleAfterSaveProductCode: function (component, event, helper) {
    component.set("v.showProductCodeModal", false);
    var action = component.get("c.handleBTAdmin");
    $A.enqueueAction(action);
  },
  handleExtendedCost: function (component, event, helper) {
    component.set("v.showProductCodeModal", false);
    component.set("v.adjustCostUpdated", true);
    var passedFieldAPIName = component.get("v.fieldAPINameToPass");

    var params = event.getParam("arguments");

    helper.getExtendedCosts(component, event, helper);
    console.log("GL====" + component.get("v.generalLiabilityCost"));

    var action = component.get("c.handleBTAdmin");
    $A.enqueueAction(action);

    // helper.getExtendedCosts(component, event, helper);
    // console.log('GL===='+component.get('v.generalLiabilityCost'));

    if (params) {
      // var allExtendedCosts = params.extendedCosts;
      // if(passedFieldAPIName == 'buildertek__Fabrication_Install_Rate__c')
      // {
      //     component.set('v.fabInstallExtndCost',allExtendedCosts);
      // }
      // if(passedFieldAPIName == 'buildertek__Fab_Only_Rate__c')
      // {
      //     component.set('v.fabOnlyExtndCost',allExtendedCosts);
      // }
      // if(passedFieldAPIName == 'buildertek__Install_Only__c')
      // {
      //     component.set('v.installOnlyExtndCost',allExtendedCosts);
      // }
      // if(passedFieldAPIName == 'buildertek__Mark_Up_Non_Slab_or_Labor__c')
      // {
      //     component.set('v.nonSlabExtndCost',allExtendedCosts);
      // }
    }
  },
  openDeleteBox: function (component, event, helper) {
    var Id = event.currentTarget.id;
    component.set("v.storeId", Id);
    component.set("v.isDeletetakeoffLines", true);
  },

  cancelDelete: function (component, event, helper) {
    component.set("v.isDeletetakeoffLines", false);
  },
  handleRowAction: function (component, event, helper) {
    var actionName = event.getParam("action").name;
    console.log("@@actionName--", actionName);

    if (actionName == "state_Country") {
      component.set("v.showCountryModal", true);
    } else if (actionName == "fabrication_Install_Rate") {
      component.set(
        "v.fieldAPINameToPass",
        "buildertek__Fabrication_Install_Rate__c"
      );
      component.set("v.fieldLabelToShow", "Fabrication and Install Rate");
      component.set("v.showProductCodeModal", true);
    } else if (actionName == "fabrication_Only_Rate") {
      component.set("v.fieldAPINameToPass", "buildertek__Fab_Only_Rate__c");
      component.set("v.fieldLabelToShow", "Fabrication Only Rate");
      component.set("v.showProductCodeModal", true);
    } else if (actionName == "Install_Only_Rate") {
      component.set("v.fieldAPINameToPass", "buildertek__Install_Only__c");
      component.set("v.fieldLabelToShow", "Install Only Rate");
      component.set("v.showProductCodeModal", true);
    } else if (actionName == "MarkUp_nonSlab_Labor_Rate") {
      component.set(
        "v.fieldAPINameToPass",
        "buildertek__Mark_Up_Non_Slab_or_Labor__c"
      );
      component.set(
        "v.fieldLabelToShow",
        "Mark Up (Non Slab) or (Non Labor) Rate"
      );
      component.set("v.showProductCodeModal", true);
    } else if (actionName == "Miscellaneous_Rates") {
      component.set(
        "v.fieldAPINameToPass",
        "buildertek__Miscellaneous_Rates__c"
      );
      component.set("v.fieldLabelToShow", "Miscellaneous Rates");
      component.set("v.showProductCodeModal", true);
    } else if (actionName == "Edge_Rate") {
      component.set("v.fieldAPINameToPass", "buildertek__Edge__c");
      component.set("v.fieldLabelToShow", "Edge Rates");
      component.set("v.showProductCodeModal", true);
    } else if (actionName == "Options_Rate") {
      component.set("v.fieldAPINameToPass", "buildertek__Options_Rate__c");
      component.set("v.fieldLabelToShow", "Options");
      component.set("v.showProductCodeModal", true);
    } else if (actionName == "Workers_Comp") {
      component.set("v.fieldAPINameToPass", "buildertek__Workers_Comp__c");
      component.set("v.fieldLabelToShow", "Workers Comp");
      component.set("v.showProductCodeModal", true);
    } else if (actionName == "General_Liability_Insurance") {
      component.set(
        "v.fieldAPINameToPass",
        "buildertek__General_Liability_Insurance_Long__c"
      );
      component.set("v.fieldLabelToShow", "General Liability Insurance");
      component.set("v.showProductCodeModal", true);
    } else if (actionName == "Textura_Fee") {
      component.set("v.fieldAPINameToPass", "buildertek__Textura_Fee__c");
      component.set("v.fieldLabelToShow", "Textura Fee");
      component.set("v.showProductCodeModal", true);
    } else if (actionName == "Slab_Discount_Rate") {
      component.set(
        "v.fieldAPINameToPass",
        "buildertek__Slab_Discount_Rate_LongText__c"
      );
      component.set("v.fieldLabelToShow", "Slab Discount Rate");
      component.set("v.showProductCodeModal", true);
    } else if (actionName == "Fabrication_Labor_Markup") {
      component.set(
        "v.fieldAPINameToPass",
        "buildertek__Fabrication_Labor_Mark_up_LongText__c"
      );
      component.set("v.fieldLabelToShow", "Fabrication / Labor Mark-up");
      component.set("v.showProductCodeModal", true);
    } else if (actionName == "OCIP_CCIP_Required") {
      component.set(
        "v.fieldAPINameToPass",
        "buildertek__OCIP_CCIP_Required__c"
      );
      component.set("v.fieldLabelToShow", "OCIP/CCIP Required");
      component.set("v.showProductCodeModal", true);
    }
  },
  submitCountryDetails: function (component, event, helper) {
    component.set("v.Spinner", true);
    var updatedRecords = component.get("v.bomList");
    var countrySelected = component.get("v.selectedCountry");

    for (var i = 0; i < updatedRecords.length; i++) {
      if (countrySelected != null && countrySelected != undefined) {
        updatedRecords[i].buildertek__Region_State_Country_County__c =
          countrySelected;
      }
    }

    var action = component.get("c.updateBomRecords");
    action.setParams({
      updatedBomList: updatedRecords,
    });
    action.setCallback(this, function (response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        if (response.getReturnValue() === true) {
          helper.showToast(
            component,
            event,
            helper,
            "Success",
            "Record Saved Successfully.",
            "success"
          );
          component.set("v.showCountryModal", false);
          var action = component.get("c.handleBTAdmin");
          $A.enqueueAction(action);
          component.set("v.Spinner", false);
        } else {
          console.log("@@Return Value False");
          helper.showToast(
            component,
            event,
            helper,
            "Error!",
            "Something went wrong!",
            "error"
          );
          component.set("v.Spinner", false);
        }
      } else {
        console.log("@@Not Success");
        helper.showToast(
          component,
          event,
          helper,
          "Error!",
          "Something went wrong!",
          "error"
        );
        component.set("v.Spinner", false);
      }
    });
    $A.enqueueAction(action);
  },
  validateProposal: function (component, event, helper) {
    var totoalBomList = component.get("v.bomList");
    if (
      totoalBomList != null &&
      totoalBomList != undefined &&
      totoalBomList.length > 0
    ) {
      var taxRate1Val = totoalBomList[0].buildertek__Tax_Rate_1__c;
      if (taxRate1Val != null && taxRate1Val != undefined && taxRate1Val <= 0) {
        component.set("v.openCreateProposalModal", true);
      } else {
        var action = component.get("c.createProposal");
        $A.enqueueAction(action);
      }
    } else {
      var action = component.get("c.createProposal");
      $A.enqueueAction(action);
    }
  },
  createProposal: function (component, event, helper) {
    component.set("v.openCreateProposalModal", false);
  },
  closeCreateProposalModal: function (component, event, helper) {
    component.set("v.openCreateProposalModal", false);
  },

  createQuote: function (component, event, helper) {
    helper.quote(component, event, helper);
  },
});