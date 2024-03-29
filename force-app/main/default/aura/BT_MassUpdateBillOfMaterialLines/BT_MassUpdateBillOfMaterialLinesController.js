({
    doInit: function (component, event, helper) {
        var pageRef = component.get("v.pageReference");
        if (pageRef != undefined) {
            var state = pageRef.state; // state holds any query params	        
            if (state != undefined && state.c__Id != undefined) {
                component.set("v.recordId", state.c__Id);
            }
            if (state != undefined && state.buildertek__Id != undefined) {
                component.set("v.recordId", state.buildertek__Id);
            }
        }

        component.set('v.isLoading', true);
        helper.bomRelatedInfo(component, event, helper);
        helper.helpergetProductPhase_BuildPhase(component, event, helper);
        var pageNumber = component.get("v.PageNumber");
            var pageSize = component.get("v.pageSize");
            var SearchProductType = component.find("SearchProductType").get("v.value");
            var searchLocation = component.find("searchLocation").get("v.value");
            var searchCategory = component.find("searchCategory").get("v.value");
            var searchTradeType = component.find("searchTradeType").get("v.value");
        helper.getTableRows(component, event, helper, pageNumber, pageSize, SearchProductType, searchLocation, searchCategory, searchTradeType);
        helper.getTableFieldSet(component, event, helper);
        
        window.setTimeout(
            $A.getCallback(function () {
            }), 2000
        );
    },

    refreshPage: function (component, event, helper) {
        var focusedTabId = event.getParam('currentTabId');
        var workspaceAPI = component.find("workspace");

        workspaceAPI.getEnclosingTabId().then(function (tabId) {
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
        component.set('v.isCancelModalOpen', false);
        var redirectUrl = '/one/one.app?#/sObject/' + component.get('v.recordId') + '/view';
        $A.get("e.force:navigateToURL").setParams({
            "url": redirectUrl,
            "isredirect": true
        }).fire();
        $A.get('e.force:refreshView').fire();
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
        if (records[index].Id != undefined) {
            component.set('v.selectedRecordIndex', index);
            component.set('v.bomLineName', records[index].Name);
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
        var index = component.get('v.selectedRecordIndex');
        var SearchProductType = component.find("SearchProductType").get("v.value");
        var searchLocation = component.find("searchLocation").get("v.value");
        var searchCategory = component.find("searchCategory").get("v.value");
        var searchTradeType = component.find("searchTradeType").get("v.value");
        if (records[index].Id != undefined) {
            component.set('v.listOfRecords', records);
            component.set('v.isModalOpen', false);
            helper.deleteRecord(component, event, helper, records[index].Id, SearchProductType, searchLocation, searchCategory, searchTradeType);
        }
    },

    handleNext: function (component, event, helper) {
        var SearchProductType = component.find("SearchProductType").get("v.value");
        var searchLocation = component.find("searchLocation").get("v.value");
        var searchCategory = component.find("searchCategory").get("v.value");
        var searchTradeType = component.find("searchTradeType").get("v.value");
        component.set('v.isLoading', true);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber++;
        helper.getTableRows(component, event, helper, pageNumber, pageSize, SearchProductType, searchLocation, searchCategory, searchTradeType);
    },

    handlePrev: function (component, event, helper) {
        var SearchProductType = component.find("SearchProductType").get("v.value");
        var searchLocation = component.find("searchLocation").get("v.value");
        var searchCategory = component.find("searchCategory").get("v.value");
        var searchTradeType = component.find("searchTradeType").get("v.value");
        component.set('v.isLoading', true);
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        pageNumber--;
        helper.getTableRows(component, event, helper, pageNumber, pageSize, SearchProductType, searchLocation, searchCategory, searchTradeType);
    },

    searchKeyChange: function (component, event, helper) {
        component.set('v.isLoading', true);
        var SearchProductType = component.find("SearchProductType").get("v.value");
        var searchLocation = component.find("searchLocation").get("v.value");
        var searchCategory = component.find("searchCategory").get("v.value");
        var searchTradeType = component.find("searchTradeType").get("v.value");
        var pageNumber = component.get("v.PageNumber");
        var pageSize = component.get("v.pageSize");
        helper.getTableRows(component, event, helper, pageNumber, pageSize, SearchProductType, searchLocation, searchCategory, searchTradeType);
        component.set('v.isLoading', false);
    },

    redirectBOM: function (component, event, helper) {
        var projectRecId = component.get("v.parentId");
        if(projectRecId){
            var evt = $A.get("e.force:navigateToRelatedList");
            evt.setParams({
                "relatedListId": "buildertek__Project_Selection_Sheet_Takeoff__r",
                "parentRecordId": component.get('v.parentId')
            });
            evt.fire(); 
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": 'This BOM doesn\'t have Project',
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
    
    selectAllBomLines : function (component, event, helper) {
        var checkStatus = event.getSource().get("v.checked");
        var rfqRecordList = JSON.parse(JSON.stringify(component.get("v.listOfRecords")));
        var getAllId = component.find("checkBOM");
        var recordIds = [];
        if(checkStatus){
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkBOM").set("v.checked", true);
                    var Id = component.find("checkBOM").get("v.name");
                    if(recordIds.indexOf(Id) == -1){
                        recordIds.push(Id)
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkBOM")[i].set("v.checked", true);
                        var Id = component.find("checkBOM")[i].get("v.name");
                        if(recordIds.indexOf(Id) == -1){
                            recordIds.push(Id)
                        }
                    }
                }
                component.set("v.listOfSelectedBomIds",recordIds);
            }
        }else{
            if(rfqRecordList.length){
                if (!Array.isArray(getAllId)) {
                    component.find("checkBOM").set("v.checked", false);
                    var Id = component.find("checkBOM").get("v.name");
                    if(recordIds.indexOf(Id) > -1){
                        var index = recordIds.indexOf(Id);
                        recordIds.splice(index,1);
                    }
                }else{
                    for (var i = 0; i < getAllId.length; i++) {
                        component.find("checkBOM")[i].set("v.checked", false);
                        var Id = component.find("checkBOM")[i].get("v.name");
                        if(recordIds.indexOf(Id) > -1){
                            var index = recordIds.indexOf(Id);
                            recordIds.splice(index,1);
                        }
                    }
                }
                component.set("v.listOfSelectedBomIds",recordIds);
            }
        }
    },
    
    selectBom: function (component, event, helper) {
        var checkbox = event.getSource();
        var selectedBomIds = component.get("v.listOfSelectedBomIds");
        var getAllId = component.find("checkBOM");
        if(checkbox.get("v.checked")){
            if(selectedBomIds.indexOf(checkbox.get("v.name")) == -1){
                selectedBomIds.push(checkbox.get("v.name"));
            }
            if(!Array.isArray(getAllId)) {
                if(!component.find("headCheckBOM").get("v.checked")){
                    component.find("headCheckBOM").set("v.checked",true);
                }
            }else{
                if(selectedBomIds.length == getAllId.length){
                    if(!component.find("headCheckBOM").get("v.checked")){
                        component.find("headCheckBOM").set("v.checked",true);
                    }
                }
            }      
        }else{
            if(component.find("headCheckBOM").get("v.checked")){
                component.find("headCheckBOM").set("v.checked",false);
            }
            if(selectedBomIds.indexOf(checkbox.get("v.name")) > -1){
                var index = selectedBomIds.indexOf(checkbox.get("v.name"));
                selectedBomIds.splice(index,1);
            }
        }
        component.set("v.listOfSelectedBomIds",selectedBomIds);  
    },
    
    onClickDelete : function(component, event, helper){ 
        var selectedSOVLines = component.get("v.listOfSelectedBomIds");
       
        if(selectedSOVLines.length > 0){
            component.set("v.isMassDeleteClick", true);
        }else{
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : "Error!",
                message : 'Please Select atleast One BOM Line.',
                type: 'error',
                duration: '1000',
                key: 'info_alt',
                mode: 'pester'
            });
            toastEvent.fire(); 
        }   
    },
    
    confirmDelete: function (component, event, helper) {
        var action = component.get("c.DeleteMassBOMLines");
        action.setParams({
            "bomLineIds": component.get("v.listOfSelectedBomIds")         
        });
        action.setCallback(this, function (response) {
            if (response.getState() == 'SUCCESS') {
                component.set('v.isMassDeleteClick', false);
                
                var  result = response.getReturnValue();
                
                if(result == 'success'){
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        mode: 'sticky',
                        message: 'BOM Lines are Deleted Successfully.',
                        type: 'success',
                        duration: '5000',
                        mode: 'dismissible'
                    });
                    toastEvent.fire();
                }
                else{
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": 'Something went wrong!',
                        "type": 'error'
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
            
            if(event.getParam("fieldName") == 'buildertek__BT_Price_Book__c'){
              var listOfRecords = component.get("v.listOfRecords");
              listOfRecords[index].buildertek__BT_Price_Book__c = selectedRecordId[0];
              component.set("v.rerender", !component.get("v.rerender"));
              component.set("v.listOfRecords", listOfRecords);

              var setProduct = false;   // Clear product...
              helper.setProduct(component, event, helper, setProduct, index);
            }
        } catch (error) {
            console.log(' error in handleLookUpEvent: ', error.stack);
        }
    },

    clearSelectedHandler :  function(component, event, helper){
        var index = event.getParam("index");
        console.log('field : ', event.getParam("fieldName"));
        if(event.getParam("fieldName") == 'buildertek__BT_Price_Book__c' || event.getParam("fieldName") == undefined){ 
            var setProduct = false;   // Clear product...
            helper.setProduct(component, event, helper, setProduct, index);
        }
    },

    ProductSelectHandler: function(component, event, helper){
        component.set("v.isLoading", true);
        var index = event.getParam("index");
        var setProduct = true;    
        window.setTimeout(
            $A.getCallback(function () {
              helper.setProduct(component, event, helper, setProduct, index);
          }),
          100
        );
    },
    
})