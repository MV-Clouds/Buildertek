({
    
    
    getcurr : function (component, event, helper) {
        var action = component.get("c.getRfqTo1");
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.currencycode",response.getReturnValue());
  
                
            } 
        });
        $A.enqueueAction(action);		
    },
    
    
    
    
    getrelatedrfqvendorlist : function(component, event, helper){
        
        component.set('v.mycolumns', [
            {label: 'SOV', fieldName: 'Name', type: 'text'},
            
            {label: 'Project', fieldName: 'buildertek__Project__c', type: 'text'},
            // {label: 'Total Costs', fieldName: 'buildertek__Total_Costs__c', type: 'currency'} 
            {label: 'Total Costs', fieldName: 'buildertek__Total_Costs__c', type: 'currency',
             typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" },
             cellAttributes: {
                 class: 'slds-grid slds-grid_align-spread',
             },
            }
            
        ]);
        component.set('v.mycolumns2', [
            /*{label: 'Vendor', fieldName: 'buildertek__Owner_Account__c', type: 'text'},
            {label: 'Payment App Name', fieldName: 'Name', type: 'text'},
            {label: 'Submission Date', fieldName: 'buildertek__Submission_Date__c', type: 'text'}*/
            {label: 'Project', fieldName: 'buildertek__Project__c', type: 'text'},
            {label: 'Vendor', fieldName: 'buildertek__Owner_Account__c', type: 'text'},
            {label: 'Status', fieldName: 'buildertek__Status__c', type: 'text'},
            {label: 'PaymentApp Name', fieldName: 'Name', type: 'text'},
           // { label: 'Amount', fieldName: 'buildertek__Original_Contract_Sum__c', type: 'currency', typeAttributes: { currencyCode: { fieldName: 'CurrencyIsoCode' }}}
            {label: 'Amount', fieldName: 'buildertek__Original_Contract_Sum__c', type: 'currency',
             typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" },
             cellAttributes: {
                 class: 'slds-grid slds-grid_align-spread',
             },
            }
            
            
            
        ]);
        component.set('v.CompanyApprovedmycolumns', [
            {label: 'SOV', fieldName: 'Name', type: 'text'},
            {label: 'Status', fieldName: 'buildertek__Status__c', type: 'text'},
            {label: 'Project', fieldName: 'buildertek__Project__c', type: 'text'},
           // {label: 'Total Costs', fieldName: 'buildertek__Total_Costs__c', type: 'currency',typeAttributes:{minimumFractionDigits :'1',currencyCode: { fieldName: 'CurrencyIsoCode'}}}
           
            {label: 'Total Costs', fieldName: 'buildertek__Total_Costs__c', type: 'currency',
             typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" },
             cellAttributes: {
                 class: 'slds-grid slds-grid_align-spread',
             },
            } 
            
        ]);
        
        component.set('v.CustomerApprovedmycolumns', [
            {label: 'SOV', fieldName: 'Name', type: 'text'},
            {label: 'Status', fieldName: 'buildertek__Status__c', type: 'text'},
            {label: 'Project', fieldName: 'buildertek__Project__c', type: 'text'},
           // {label: 'Total Costs', fieldName: 'buildertek__Total_Costs__c', type: 'currency',typeAttributes:{minimumFractionDigits :'1',currencyCode: { fieldName: 'CurrencyIsoCode'}}}
           
            {label: 'Total Costs', fieldName: 'buildertek__Total_Costs__c', type: 'currency',
             typeAttributes: { currencyCode: { fieldName: 'CurrencyIso' }, currencyDisplayAs: "code" },
             cellAttributes: {
                 class: 'slds-grid slds-grid_align-spread',
             },
            } 
           
            
        ]);
        
        
        
    },
    
    
    
	getRfqList: function (component, event, helper, pageNumber, pageSize){
        component.set("v.IsActive", true);
        var action = component.get("c.getmasterScheduleOValues");
        var recId = component.get("v.recordId");
        action.setParams({
            "pageNumber" : pageNumber,
            "pageSize": pageSize
        });
        action.setCallback(this, function (result) {
            debugger;
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                
                for ( var i = 0; i <  resultData.recordList.length; i++ ) {
                    if (  resultData.recordList[i].buildertek__Project__c ) {
                        resultData.recordList[i].buildertek__Project__c =  resultData.recordList[i].buildertek__Project__r.Name;
                    }
                }
                component.set("v.rfqRecordList", resultData.recordList);
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecords", resultData.totalRecords);
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
    getRfqListApproved : function (component, event, helper, pageNumber, pageSize){
       
      //  component.set("v.IsActive", true);
        var action = component.get("c.getapprovedScheduleOfValue");
        var recId = component.get("v.recordId");
        
        action.setParams({
            "pageNumber" : pageNumber,
            "pageSize": pageSize,
            "recordId": recId
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                //alert(JSON.stringify(resultData.recordList.length));
                if(resultData.recordList.length > 0){
                    component.set("v.ShowValidation",false);
                }else{
                    component.set("v.ShowValidation",true);
                }
                
                for ( var i = 0; i <  resultData.recordList.length; i++ ) {
                    if (  resultData.recordList[i].buildertek__Project__c ) {
                        resultData.recordList[i].buildertek__Project__c =  resultData.recordList[i].buildertek__Project__r.Name;
                    }
                }
                /*for(var i in resultData.recordList){
                    resultData.recordList[i].budgetCheck =false;
                }*/
                component.set("v.rfqRecordList", resultData.recordList);
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecords", resultData.totalRecords);
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
      importContinuationSheetItems : function(component, event, helper, selectedSheetIds,sheetId){
        var action = component.get("c.importScheduleOfValueItems");
          component.set("v.Spinner",true);
        
        var recid;
          if(component.get("v.Iscommunity") == true){
              recid = component.get("v.recordId");
          }else{
            recid = sheetId;
          }
        action.setParams({
            Id : selectedSheetIds,
            recordId : recid,
            isCommunity : component.get("v.Iscommunity")
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                component.set("v.Spinner",false);
                var workspaceAPI = component.find("workspace"); 
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });
                }).catch(function (error) {
                    
                    console.log('Error', JSON.stringify(error));
                }); 
                setTimeout(function () {
                component.set("v.isnew", false);
                //if(location.href.includes("fromsovsheet")){
                     var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": sheetId,
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                        $A.get('e.force:refreshView').fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": 'Payment Application Created Successfully',
                            "type": 'Success'
                        });
                        toastEvent.fire();  
                //}
                }, 200);
            }else{
                this.showErrorToast(component, event, helper, 'Error', response.getReturnValue());
            }
            
        }); 
        $A.enqueueAction(action);
    },
    
    showErrorToast: function (component, event, helper, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: "5000",
            key: "info_alt",
            type: "error",
            mode: "pester",
        });
        toastEvent.fire();
    },
    showSuccessToast: function (component, event, helper, title, message) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title: title,
            message: message,
            duration: "5000",
            key: "info_alt",
            type: "success",
            mode: "pester",
        });
        toastEvent.fire();
    },
    
    
    getSOVList: function (component, event, helper, pageNumber, pageSize){
        component.set("v.isUseMasterSOV", true);
        var action = component.get("c.getmasterScheduleOValues");
        var recId = component.get("v.recordId");
        action.setParams({
            "pageNumber" : pageNumber,
            "pageSize": pageSize
        });
        action.setCallback(this, function (result) {
            var state = result.getState();
            if (component.isValid() && state === "SUCCESS") {
                var resultData = result.getReturnValue();
                
                /*for(var i in resultData.recordList){
                    resultData.recordList[i].budgetCheck =false;
                }*/
                component.set("v.rfqRecordList", resultData.recordList);
                component.set("v.PageNumber", resultData.pageNumber);
                component.set("v.TotalRecords", resultData.totalRecords);
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
    
    
    
      importContinuationSheetItems2 : function(component, event, helper, selectedSheetIds,sheetId){
        var action = component.get("c.importScheduleOfValueItems");
        // var appId = component.get("v.paymentAppId");
        action.setParams({
            Id : selectedSheetIds,
            recordId : sheetId
        })
        action.setCallback(this, function(response) {
            var state = response.getState();
            var result = response.getReturnValue();
            if (state === "SUCCESS") {
                var workspaceAPI = component.find("workspace"); 
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({
                        tabId: focusedTabId
                    });
                }).catch(function (error) {
                    console.log('Error', JSON.stringify(error));
                }); 
                setTimeout(function () {
                component.set("v.isnew", false);
                //if(location.href.includes("fromsovsheet")){
                     var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": sheetId,
                            "slideDevName": "detail"
                        });
                        navEvt.fire();
                        $A.get('e.force:refreshView').fire();
                        var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "message": 'Payment Application Created Successfully',
                            "type": 'Success'
                        });
                        toastEvent.fire();  
                //}
                }, 200);
            }else{
                this.showErrorToast(component, event, helper, 'Error', response.getReturnValue());
            }
            
        }); 
        $A.enqueueAction(action);
    },
    
    getParameterByName: function (component, event, name) {
		name = name.replace(/[\[\]]/g, "\\$&");
		var url = window.location.href;
		var regex = new RegExp("[?&]" + name + "(=1\.([^&#]*)|&|#|$)");
		var results = regex.exec(url);
		if (!results) return null;
		if (!results[2]) return '';
		return decodeURIComponent(results[2].replace(/\+/g, " "));
	},
    closeEditPopup1 : function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        
        workspaceAPI.getFocusedTabInfo().then(function (response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({
                tabId: focusedTabId
            });
        })
        .catch(function (error) {
            console.log(error);
        });
        var action = component.get("c.getListViews1");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {
                var listviews = response.getReturnValue();
                var navEvent = $A.get("e.force:navigateToList");
                navEvent.setParams({
                    "listViewId": listviews.Id,
                    "listViewName": null,
                    "scope": "buildertek__SOV_Payment_Application__c"
                });
                navEvent.fire();
            }
        });
        $A.enqueueAction(action);
        
    },

    getPaymentTypeHelper : function(component, event, helper){
        component.set("v.Spinner", true);
        var getPatmentType = component.get("c.getPaymentTypeDetails");
        getPatmentType.setCallback(this, function (result) {
            var result = result.getReturnValue();
            console.log('Payment Type ==> ',result);
            if (result.buildertek__New_Payment_Application__c || result.buildertek__Import_Company_Accepted_Vendor_Payment_A__c || result.buildertek__Import_Approved_SOV_s_Payment_Apps__c) {
                var optionList = [];
                if (result.buildertek__New_Payment_Application__c) {
                    optionList.push( { label: 'New Payment Application', value: 'option1' });
                } 
                if (result.buildertek__Import_Company_Accepted_Vendor_Payment_A__c) {
                    optionList.push( { label: 'Import Company Accepted Vendor Payment Apps', value: 'option4' });
                }
                if (result.buildertek__Import_Approved_SOV_s_Payment_Apps__c) {
                    optionList.push( { label: 'Import Company Approved / Import Customer Approved SOVs', value: 'option5' });
                }
                console.log('optionList ==> ',optionList);
                component.set("v.options", optionList);
                if (optionList.length == 1) {
                    console.log('optionList[0].value ==> '+optionList[0].value);
                    component.set("v.checkBoxValue",optionList[0].value);
                    var action = component.get("c.isNext");
                    $A.enqueueAction(action);
                } else{
                    component.set("v.isnew", true);
                }
                component.set("v.Spinner", false);
            } else{
                component.set("v.checkBoxValue",'option1');
                var action = component.get("c.isNext");
                $A.enqueueAction(action);
                component.set("v.Spinner", false);
            }
        });  
        $A.enqueueAction(getPatmentType);
    }
    
    
})