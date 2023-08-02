({
    doInit : function(component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        var action = component.get("c.getProject");
        action.setParams({
            "recordId" : component.get("v.recordId")
        });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                console.log(JSON.parse(JSON.stringify(response.getReturnValue())));
                var projectData = JSON.parse(JSON.stringify(response.getReturnValue()))
                if(projectData.buildertek__Project__c){
                    component.set("v.projectName",projectData.buildertek__Project__r.Name);
               		component.set("v.projectId",projectData.buildertek__Project__r.Id);
                }
                //changed on 17-dec 11:17 only 2 lines
               // component.set("v.projectName",projectData.buildertek__Project__r.Name);
               // component.set("v.projectId",projectData.buildertek__Project__r.Id);
            }
        })
        $A.enqueueAction(action);
        helper.setColumns(component);
        helper.getPoLinesList(component, event, helper,pageNumber,pageSize);
        helper.getPoList(component, event, helper);
    },
    doSearch: function (component, event, helper) {
        //var value = component.get("v.searchRfqFilter");//event.getSource().get("v.value");
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        helper.getPoLinesList(component, event, helper,pageNumber,pageSize);
    },
    handleNext: function (component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber++;
        helper.getPoLinesList(component, event, helper,pageNumber,pageSize);
        //helper.getRfqList(component, event, helper, pageNumber, pageSize, vendorValue, tradeValue, descriptionValue);
    },
    
    handlePrev: function (component, event, helper) {
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber--;
        helper.getPoLinesList(component, event, helper,pageNumber,pageSize);
        //helper.getRfqList(component, event, helper, pageNumber, pageSize, vendorValue, tradeValue, descriptionValue);
    },
    
    /*doGroupByVendorPhase: function(component, event, helper) {
        var data = component.get("v.orgData");
        var toggleVal = component.get("v.groupBytoggle");
        component.set("v.selectedTableRows", []);
        component.set("v.selectedTableRowIds", []);
       	helper.formatDataByGroups(component,event,helper,data); 
    },*/
    checkToogle: function(component, event, helper) {
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
                component.find("category").set("v.checked",false);
                //component.set("v.groupByVendortoggle",false);
                component.set("v.groupByPhasetoggle",true);
                component.set("v.groupByVendortoggle",false);
                component.set("v.groupByCategorytoggle",false);
            }
        }else if(checked == "Group By Vendor"){
            
            if(!event.getSource().get("v.checked")){
                component.find("vendor").set("v.checked",true);
                component.find("phase").set("v.checked",false);
                component.find("category").set("v.checked",false);
                //component.set("v.groupByPhasetoggle",false);
                
                 component.set("v.groupByPhasetoggle",false);
                component.set("v.groupByVendortoggle",true);
                component.set("v.groupByCategorytoggle",false);
            }
        }else if(checked == "Group By Category"){
           
            if(!event.getSource().get("v.checked")){
                component.find("vendor").set("v.checked",false);
                component.find("phase").set("v.checked",false);
                component.find("category").set("v.checked",true);
                //component.set("v.groupByPhasetoggle",false);
                
                component.set("v.groupByPhasetoggle",false);
                component.set("v.groupByVendortoggle",false);
                component.set("v.groupByCategorytoggle",true);
            }
        }
        var toggleVal = component.get("v.groupBytoggle");
        helper.formatDataByGroups(component,event,helper,data); 
    },
    handleSort: function(component, event, helper) {
        event.preventDefault();
        var classIndex = event.currentTarget.dataset.sortgroupindex;
        var ele = event.currentTarget;
        var data = JSON.parse(JSON.stringify(component.get("v.dataByGroup")))[classIndex]['groupData'];
        var sortBy = event.currentTarget.dataset.sortby;
        var sortDirection = component.get("v.sortDirection");
        if(!sortDirection){
            sortDirection = component.get("v.defaultSortDirection");
        }
        helper.sortData(component,event,sortBy,sortDirection,data);
    },

    selectAll : function (component, event, helper) {
        var checkStatus = event.currentTarget.checked;
        var classIndex = event.currentTarget.className.split("_")[1];
        var rowIndex = [];
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.dataByGroup")))[classIndex]['groupData']; //JSON.parse(JSON.stringify(component.get("v.recordsList")));
        var getAllId = document.getElementsByClassName("selectCheck_"+classIndex);//component.find("checkRFQ");
        var recordIds = component.get("v.selectedRecords");
        var selectedRecordMap = JSON.parse(JSON.stringify(component.get("v.selectedRecordMap")));
        var vendors = [];
        if(checkStatus){
            if(rfqRecordList.length){
                if(selectedRecordMap == null){
                    selectedRecordMap = new Map();
                }
                for (var i = 0; i < getAllId.length; i++) {
                    document.getElementsByClassName("selectCheck_"+classIndex)[i].checked = true;
                    rowIndex.push(document.getElementsByClassName("selectCheck_"+classIndex)[i].id.split("rowId_")[1]);
                    var Id = document.getElementsByClassName("selectCheck_"+classIndex)[i].value;
                    
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                }
                var filteredData = rfqRecordList.filter(function(item,index){
                    if(rowIndex.indexOf(String(index)) > -1){
                        return item;
                    }
                })
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
                component.set("v.selectedRecords",recordIds);
                //component.set("v.selectedRecordMap",selectedRecordMap);
            }
        }else{
            if(rfqRecordList.length){
                for (var i = 0; i < getAllId.length; i++) {
                    document.getElementsByClassName("selectCheck_"+classIndex)[i].checked = false;
                    var Id = document.getElementsByClassName("selectCheck_"+classIndex)[i].value;
                    if(recordIds.indexOf(Id) > -1){
                        var index = recordIds.indexOf(Id);
                        recordIds.splice(index,1);
                    }
                    var selectedRecordMap = new Map();
                    component.set("v.vendors",[]);
                    component.set("v.selectedRecords",[]);
                    component.set("v.selectedRecordMap",selectedRecordMap);
                }
                component.set("v.selectedRecords",recordIds);
            }
        }
        console.log(recordIds);
        if(recordIds.length == 0){
            event.currentTarget.checked = false;
        }
    },
    selectRow: function (component, event, helper) {
        var checkbox = event.currentTarget;
        var classIndex = event.currentTarget.className.split("_")[1];
        var headCheckBox = document.getElementsByClassName('checkSelectAll_'+classIndex)[0];
        var selectedRfqIds = component.get("v.selectedRecords");
        var getAllId = document.getElementsByClassName("selectCheck_"+classIndex);
        var selectedRecordMap = JSON.parse(JSON.stringify(component.get("v.selectedRecordMap")));
        var vendors = [];
        var rowIndex = JSON.parse(JSON.stringify(component.get("v.selectedRowIndex")));
        var currentTableRowIds = [];
        if(checkbox.checked){
            if(selectedRfqIds.indexOf(checkbox.value) == -1){
                selectedRfqIds.push(checkbox.value);
            }
            var checkIndex = 0;
            if(selectedRfqIds.length >= getAllId.length){
                for(var i=0;i<getAllId.length;i++){
                    currentTableRowIds.push(getAllId[i].value);
                    if(selectedRfqIds.indexOf(getAllId[i].value)>-1){
                        checkIndex++;
                    }
                }
                if(!headCheckBox.checked && checkIndex == getAllId.length){
                    headCheckBox.checked = true;
                }
            }
        }else{
            if(headCheckBox.checked){
                headCheckBox.checked = false;
            }
            if(selectedRfqIds.indexOf(checkbox.value) > -1){
                var index = selectedRfqIds.indexOf(checkbox.value);
                selectedRfqIds.splice(index,1);
            }
        }
       
        console.log(selectedRfqIds);
        component.set("v.selectedRecords",selectedRfqIds);
    },
    
    newPO : function (component, event, helper) {
        var selectedIds = JSON.parse(JSON.stringify(component.get("v.selectedRecords")));
        if(selectedIds.length > 0){
            var action = component.get("c.createPO");
            component.set("v.Spinner", true);
            component.set("v.showMessage",true);
            action.setParams({
                "selectedIds" : selectedIds,
                "recordId": component.get("v.recordId")
            });
            action.setCallback(this, function(response){
                if(response.getState() == 'SUCCESS'){
                    component.set("v.Spinner", false);
                    component.set("v.showMessage",false);
                    location.reload();
                }else{
                    console.log(response);
                }
                
            });
            $A.enqueueAction(action);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                message: 'No Selected Product Option Lines',
                type: 'ERROR',
                duration: '5000',
                mode: 'dismissible'
            });
            toastEvent.fire();
        }
    },
    showVendor : function (component, event, helper) {
        var action = component.get("c.getVendors");
        var Id= event.currentTarget.id;
        component.set("v.optionLineId",Id);
        event.preventDefault();
        component.set("v.Spinner", true);
        action.setParams({
            "optionLineID" : Id //,"recordId": component.get("v.recordId")
        });
        action.setCallback(this, function(response){
            if(response.getState() == 'SUCCESS'){
                console.log(response.getReturnValue());
                component.set("v.Spinner", false);
                if(JSON.parse(JSON.stringify(response.getReturnValue())).length){
                    component.set("v.vendorList",JSON.parse(JSON.stringify(response.getReturnValue())));
                    component.set("v.showModal",true);
                }else{
                    component.find('notifLib').showNotice({
                        "variant": "error",
                        "header": "No Vendor",
                        "message": "No other Vendors found for this product",
                        closeCallback: function () {}
                    });
                }
                
                //component.set("v.showMessage",false);
                //location.reload();
            }else{
                console.log(response);
            }
            
        });
        $A.enqueueAction(action);
    },
    closeVendor: function (component, event, helper) {
        event.preventDefault();
        component.set("v.showModal",false);
    },
    deleteVendor : function (component, event, helper) {
        event.preventDefault();
        component.set("v.showModal",false);
        component.set("v.Spinner", true);
        var action = component.get("c.deleteOptionLine");
        var Id= event.currentTarget.id;
      //  alert(Id);
        action.setParams({
            "productId" : component.get("v.selectedVendor"),
            "projectId" : component.get("v.projectId"),
            "optionLineId" : Id
        })
        action.setCallback(this,function(response){
            if(response.getState() == 'SUCCESS'){
                
              //  alert('success state');
                 component.set("v.Spinner", false);
                var pageNumber = component.get("v.PageNumber");
                console.log(response.getReturnValue());
                var pageSize = component.get("v.pageSize");
                
                if(response.getReturnValue()=='Deleted'){
                    $A.get('e.force:refreshView').fire();
                  //  alert('return value is deleted');
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'PO Line Deleted Successfully',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }else{
                  //  alert('po is there');
                     var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Error',
                        message: 'Please Delete the Purchase Order for this Product Line before deletion',
                        duration:' 5000',
                        key: 'info_alt',
                        type: 'error',
                        mode: 'pester'
                    });
                    toastEvent.fire();
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    saveVendor : function (component, event, helper) {
        event.preventDefault();
        component.set("v.showModal",false);
        component.set("v.Spinner", true);
        var action = component.get("c.createNewOptionLine");
        action.setParams({
            "productId" : component.get("v.selectedVendor"),
            "projectId" : component.get("v.projectId"),
            "optionLineId" : component.get("v.optionLineId")
        })
        action.setCallback(this,function(response){
            if(response.getState() == 'SUCCESS'){
                var pageNumber = component.get("v.PageNumber");
                console.log(response.getReturnValue());
                var pageSize = component.get("v.pageSize");
                //component.set()
                helper.getPoLinesList(component, event, helper,pageNumber,pageSize);
                component.set("v.optionLineId","");
            }
        });
        $A.enqueueAction(action);
    },
    selectedVendorItem: function (component, event, helper) {
        var selectedVendor = event.currentTarget.value;//component.get("v.selectedVendor");
        component.set("v.selectedVendor",selectedVendor);
    }
})