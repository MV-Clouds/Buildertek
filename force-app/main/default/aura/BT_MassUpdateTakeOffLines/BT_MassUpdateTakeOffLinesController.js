({
    doInit: function (component, event, helper) {
        var pageRef = component.get("v.pageReference");
        // console.log('pageRef--',JSON.stringify(pageRef));
        if (pageRef != undefined) {
            var state = pageRef.state; // state holds any query params	        
            // console.log('state = ' + JSON.stringify(state));
            if (state != undefined && state.c__Id != undefined) {
                component.set("v.recordId", state.c__Id);
            }
            if (state != undefined && state.buildertek__Id != undefined) {
                component.set("v.recordId", state.buildertek__Id);
            }
        }


        component.set('v.isLoading', true);

        // Optimized code for fast rendering...
        helper.takeoffRelatedInfo(component, event, helper);
        helper.helpergetProductPhase_BuildPhase(component, event, helper);
        var pageNumber = component.get("v.PageNumber");
            var pageSize = component.get("v.pageSize");
            var SearchProductType = component.find("SearchProductType").get("v.value");
            var searchLocation = component.find("searchLocation").get("v.value");
            var searchCategory = component.find("searchCategory").get("v.value");
            var searchTradeType = component.find("searchTradeType").get("v.value");
        	var searchCostCode = component.find("searchCostCode").get("v.value");
        	var searchVendor = component.find("searchVendor").get("v.value");
        	var searchPhase = component.find("searchPhase").get("v.value");
        helper.getTableRows(component, event, helper, pageNumber, pageSize, SearchProductType, searchLocation, searchCategory, searchTradeType, searchCostCode, searchVendor, searchPhase);
        helper.getTableFieldSet(component, event, helper);
        // console.log('recID--',component.get('v.recordId'));
        
        window.setTimeout(
            $A.getCallback(function () {
            }), 2000
        );
    },

    refreshPage: function (component, event, helper) {
        var focusedTabId = event.getParam('currentTabId');
        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function (tabId) {
                // console.log(tabId)
                if (tabId == focusedTabId) {
                    setTimeout(function () {
                        location.reload()
                    }, 1000);
                }
            })
            .catch(function (error) {
                console.log(error);
            });
    },

    onAddClick: function (component, event, helper) {
        var fields = component.get('v.fieldSetValues');
        var list = component.get('v.listOfRecords');
        var obj = {};
        for (var i in fields) {
            obj[fields[i].name] = '';
            if (fields[i].type == 'BOOLEAN') {
                obj[fields[i].name] = false;
            }
        }
        list.unshift(obj);
        component.set('v.listOfRecords', list);
        console.log('new raw added  : ', JSON.parse(JSON.stringify(list)));
    },

    closeScreen: function (component, event, helper) {
        var theBomId = component.get('v.bomId');
        // console.log('theBomId--',theBomId);
        component.set('v.isCancelModalOpen', false);
        if(theBomId == null || theBomId == undefined)
        {
            var redirectUrl = '/one/one.app?#/sObject/' + component.get('v.recordId') + '/view';
            $A.get("e.force:navigateToURL").setParams({
                "url": redirectUrl,
                "isredirect": true
            }).fire();
            $A.get('e.force:refreshView').fire();
        }
        else if(theBomId != null && theBomId != undefined && theBomId != '')
        {
            component.find("goToPrevious").navigate({
                type: "standard__component",
                attributes: {
                    componentName: "buildertek__DuplicateSSTLFromProducts",
                    attributes: {
                        "recordId": theBomId
                    } 
                },
                // state: { 
                //     "c__recordId": component.get("v.recordId")
                // }
            });
        }
        
    },

    closeCancelModal: function (component, event, helper) {
        component.set('v.isCancelModalOpen', false);
    },

    onMassUpdate: function (component, event, helper) {
        component.set('v.isLoading', true);
        var SearchProductType = component.find("SearchProductType").get("v.value");
        var searchLocation = component.find("searchLocation").get("v.value");
        var searchCategory = component.find("searchCategory").get("v.value");
        var searchTradeType = component.find("searchTradeType").get("v.value");
        if (!component.get('v.massUpdateEnable')) {
            component.set('v.massUpdateEnable', true);
            component.set('v.isLoading', false);
        } else if (component.get('v.massUpdateEnable')) {
            component.set('v.isLoading', true);
            component.set('v.massUpdateEnable', false);
            helper.updateMassRecords(component, event, helper, SearchProductType, searchLocation, searchCategory, searchTradeType);
        }
    },

    onMassUpdateCancel: function (component, event, helper) {
        if (component.get('v.massUpdateEnable')) {
            component.set('v.isCancelModalOpen', true);
        }
    },

    deleteRecord: function (component, event, helper) {
        var target = event.target;
        var index = target.getAttribute("data-index");
        var records = component.get('v.listOfRecords');
      //  alert(records);
        if (records[index].Id != undefined) {
            component.set('v.selectedRecordIndex', index);
            component.set('v.quoteLineName', records[index].Name);
            component.set('v.isModalOpen', true);
        } else if (records[index].Id == undefined) {
            records.splice(index, 1);
            component.set('v.listOfRecords', records);
        }
    },

    handleCancel: function (component, event, helper) {
        component.set('v.isModalOpen', false);
    },

    handleDelete: function (component, event, helper) {
        var records = component.get('v.listOfRecords');
      //  alert(records)
        var index = component.get('v.selectedRecordIndex');
        var SearchProductType = component.find("SearchProductType").get("v.value");
        var searchLocation = component.find("searchLocation").get("v.value");
        var searchCategory = component.find("searchCategory").get("v.value");
        var searchTradeType = component.find("searchTradeType").get("v.value");
        var searchCostCode = component.find("searchCostCode").get("v.value");
        var searchVendor = component.find("searchVendor").get("v.value");
        var searchPhase = component.find("searchPhase").get("v.value");
        if (records[index].Id != undefined) {
            component.set('v.listOfRecords', records);
            component.set('v.isModalOpen', false);
            helper.deleteRecord(component, event, helper, records[index].Id, SearchProductType, searchLocation, searchCategory, searchTradeType, searchVendor, searchCostCode, searchPhase);
        }
    },

    handleNext: function (component, event, helper) {
        var SearchProductType = component.find("SearchProductType").get("v.value");
        var searchLocation = component.find("searchLocation").get("v.value");
        var searchCategory = component.find("searchCategory").get("v.value");
        var searchTradeType = component.find("searchTradeType").get("v.value");
        var searchCostCode = component.find("searchCostCode").get("v.value");
        var searchVendor = component.find("searchVendor").get("v.value");
        var searchPhase = component.find("searchPhase").get("v.value");
        component.set('v.isLoading', true);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber++;
        helper.getTableRows(component, event, helper, pageNumber, pageSize, SearchProductType, searchLocation, searchCategory, searchTradeType, searchCostCode, searchVendor, searchPhase);
    },

    handlePrev: function (component, event, helper) {
        var SearchProductType = component.find("SearchProductType").get("v.value");
        var searchLocation = component.find("searchLocation").get("v.value");
        var searchCategory = component.find("searchCategory").get("v.value");
        var searchTradeType = component.find("searchTradeType").get("v.value");
        var searchVendor = component.find("searchVendor").get("v.value");
        var searchCostCode = component.find("searchCostCode").get("v.value");
        var searchPhase = component.find("searchPhase").get("v.value");

        component.set('v.isLoading', true);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber--;
        helper.getTableRows(component, event, helper, pageNumber, pageSize, SearchProductType, searchLocation, searchCategory, searchTradeType, searchCostCode, searchVendor, searchPhase);
    },

    searchKeyChange: function (component, event, helper) {
        component.set('v.isLoading', true);
        var SearchProductType = component.find("SearchProductType").get("v.value");
        var searchLocation = component.find("searchLocation").get("v.value");
        var searchCategory = component.find("searchCategory").get("v.value");
        var searchTradeType = component.find("searchTradeType").get("v.value");
        var searchCostCode = component.find("searchCostCode").get("v.value");
        var searchVendor = component.find("searchVendor").get("v.value");
        var searchPhase = component.find("searchPhase").get("v.value");
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        helper.getTableRows(component, event, helper, pageNumber, pageSize, SearchProductType, searchLocation, searchCategory, searchTradeType, searchCostCode, searchVendor, searchPhase);
    },

    redirectTakeOff: function (component, event, helper) {
        // debugger;
        var projectRecId = component.get("v.parentId");
        if(projectRecId){
            var evt = $A.get("e.force:navigateToRelatedList");
            evt.setParams({
                "relatedListId": "buildertek__Project_Takeoffs__r",
                "parentRecordId": component.get('v.parentId')
            });
            evt.fire(); 
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": 'This TakeOff doesn\'t have Project',
                        "type": 'Error'
                    });
                    toastEvent.fire(); 
        }
        
        
    },

    gotoURL: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": '/one/one.app?#/sObject/' + recordId + '/view'
        });
        urlEvent.fire();
    },
    
    selectAllRfq : function (component, event, helper) {
        // debugger;
        var checkStatus = event.getSource().get("v.checked");
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.listOfRecords")));
        var getAllId = component.find("checkRFQ");
        var recordIds = [];
        if(checkStatus){
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkRFQ").set("v.checked", true);
                    var Id = component.find("checkRFQ").get("v.name");
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkRFQ")[i].set("v.checked", true);
                        var Id = component.find("checkRFQ")[i].get("v.name");
                        if(recordIds.indexOf(Id) == -1){
                            recordIds.push(Id)
                        }
                    }
                }
                component.set("v.listOfSelectedTakeOffIds",recordIds);
            }
        }else{
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkRFQ").set("v.checked", false);
                    var Id = component.find("checkRFQ").get("v.name");
                    if(recordIds.indexOf(Id) > -1){
                        var index = recordIds.indexOf(Id);
                        recordIds.splice(index,1);
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkRFQ")[i].set("v.checked", false);
                        var Id = component.find("checkRFQ")[i].get("v.name");
                        if(recordIds.indexOf(Id) > -1){
                            var index = recordIds.indexOf(Id);
                            recordIds.splice(index,1);
                        }
                    }
                }
                component.set("v.listOfSelectedTakeOffIds",recordIds);
            }
        }
        // console.log(recordIds);
           
    },
    
    selectRfq: function (component, event, helper) {
        // debugger;
        var checkbox = event.getSource();
        
       // alert('Chechbox--------------  '+component.find("checkRFQ").get("v.name"));
        var selectedRfqIds = component.get("v.listOfSelectedTakeOffIds");
        var getAllId = component.find("checkRFQ");
        if(checkbox.get("v.checked")){
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) == -1){
                selectedRfqIds.push(checkbox.get("v.name"));
            }
            if(!Array.isArray(getAllId)) {
                if(!component.find("headCheckRFQ").get("v.checked")){
                    component.find("headCheckRFQ").set("v.checked",true);
                }
            }else{
                if(selectedRfqIds.length == getAllId.length){
                    if(!component.find("headCheckRFQ").get("v.checked")){
                        component.find("headCheckRFQ").set("v.checked",true);
                    }
                }
            }
            
          
            
        }else{
            if(component.find("headCheckRFQ").get("v.checked")){
                component.find("headCheckRFQ").set("v.checked",false);
            }
            if(selectedRfqIds.indexOf(checkbox.get("v.name")) > -1){
                var index = selectedRfqIds.indexOf(checkbox.get("v.name"));
                selectedRfqIds.splice(index,1);
            }
        }
        // console.log(selectedRfqIds);
        component.set("v.listOfSelectedTakeOffIds",selectedRfqIds);
      
        
    },
    
    onClickDelete : function(component, event, helper){
        // debugger;

        
        var selectedSOVLines = component.get("v.listOfSelectedTakeOffIds");
        console.log(`selectedSOVLines : ${selectedSOVLines}`);
        if(selectedSOVLines.length > 0){
            
            component.set("v.isMassDeleteClick", true);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Please Select atleast One TakeOff Line.',
                type: 'error',
                duration: '1000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire(); 
        }
        
        
    },
    
    confirmDelete: function (component, event, helper) {
        //var selectedSovLineIds = component.get("v.listOfSelectedSOVIds");
        var action = component.get("c.DeleteMassTakeOffLines");
        action.setParams({
            "sovLineIds": component.get("v.listOfSelectedTakeOffIds")         
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                 component.set('v.isMassDeleteClick', false);
                
              var  result = response.getReturnValue();
                
                if(result == 'success'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'TakeOff Lines are Deleted Successfully.',
                        type: 'success',
                        duration: '5000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                
                $A.get('e.force:refreshView').fire();
            } 
            else {
                console.log('Error');
            }
        });
        $A.enqueueAction(action);
        
    },

    cancelDelete: function (component, event, helper) {
        component.set('v.isMassDeleteClick', false);
    },

    handleLookUpEvent: function(component, event, helper){
        try {
            
            var selectedRecordId = event.getParam("selectedRecordId");
            var index = event.getParam('index');
            
            if(event.getParam("fieldName") == 'buildertek__Price_Book__c'){
            //   component.set("v.isLoading", true);
              var listOfRecords = component.get("v.listOfRecords");
              listOfRecords[index].buildertek__Price_Book__c = selectedRecordId[0];
              component.set("v.rerender", !component.get("v.rerender"));
              component.set("v.listOfRecords", listOfRecords);

            //   var setProduct = false;   // Clear product...
            //   helper.setProduct(component, event, helper, setProduct, index);
            }
        } catch (error) {
            console.log(' error in handleLookUpEvent: ', error.stack);
        }
    },

    clearSelectedHandler :  function(component, event, helper){
        console.log(`clearSelectedHandler`);
        var index = event.getParam("index");
        // console.log('field : ', event.getParam("fieldName"));
        if(event.getParam("fieldName") == 'buildertek__Price_Book__c' || event.getParam("fieldName") == undefined){ 
            // undefiend when function call from "BT_LightningLookup" component...
            // component.set("v.isLoading", true);

            var setPriceBook = false;   // Clear product...
            // helper.setProduct(component, event, helper, setProduct, index);
            helper.setPriceBook(component, event, helper, index, setPriceBook);
        }
    },

    ProductSelectHandler: function(component, event, helper){
        component.set("v.isLoading", true);
        var index = event.getParam("index");
        var setProduct = true;
        var setPriceBook = true;
        var fieldName = event.getParam("fieldName");
        console.log(`Takeoff ${fieldName} selected...`);
        // to avoid lag after set product...
        window.setTimeout(
            $A.getCallback(function () {
            //   helper.setProduct(component, event, helper, setProduct, index);
              helper.setPriceBook(component, event, helper, index, setPriceBook);
          }),
          100
        );

    },
    
})