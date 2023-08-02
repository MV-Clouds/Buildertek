({
    doInit : function(component, event, helper) {
        component.set("v.isOpen", true);
        
        var value = helper.getParameterByName(component , event, 'inContextOfRef');
        var context = '';
        var parentRecordId = '';
        component.set("v.parentRecordId",parentRecordId);
        if(value != null){
            context = JSON.parse(window.atob(value));
            parentRecordId = context.attributes.recordId;
            component.set("v.parentRecordId",parentRecordId);
        }else{
            var relatedList = window.location.pathname;
            var stringList = relatedList.split("/"); 
            
            parentRecordId = stringList[4];
            if(parentRecordId == 'related'){
                var stringList = relatedList.split("/");
                parentRecordId = stringList[3];
            }
            component.set("v.parentRecordId",parentRecordId);
        }
        if(parentRecordId != null && parentRecordId != ''){
            var action = component.get("c.getobjectName");
            action.setParams({
                recordId: parentRecordId,
            });
            action.setCallback(this, function (response) {
                if (response.getState() == 'SUCCESS' && response.getReturnValue()) {
                    var objName = response.getReturnValue();
                    if(objName == 'buildertek__Trade_Type__c'){
                        component.set("v.selectedTradeType", parentRecordId);
                    }
                    else if(objName == 'buildertek__Category__c'){
                        component.set("v.selectedCategoryType", parentRecordId);
                    }else if(objName == 'buildertek__Product_Type__c'){
                        component.set("v.selectedProductType", parentRecordId);
                    }else if(objName == 'buildertek__Package__c'){
                        component.set("v.budgetID", parentRecordId);
                    }
                } 
            });
            $A.enqueueAction(action);
        }
        component.find('quantityId').set("v.value", 1);
        component.find('MBId').set("v.value", parentRecordId);
        helper.fetchpricebooks(component, event, helper);
        helper.getIndustryPicklist(component, event, helper);
        helper.getUOMPicklist(component, event, helper);
    }, 
    
    handleComponentEvent : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.newPackageItem.buildertek__Products__c",selectedAccountGetFromEvent.Id);
	    component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
	    helper.getProductDetails(component, event, helper);
    },
    
    handleComponentEvents : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.newPackageItem.buildertek__Products__c",selectedAccountGetFromEvent.Id);
	    component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
	    helper.getProductDetails(component, event, helper);
    },
  
    
    closeModel: function(component, event, helper) {
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
        $A.get("e.force:closeQuickAction").fire();
        component.set("v.isOpen", false);
    },
    
    save : function(component, event, helper) {
      
        var selectedCostCode = component.get("v.selectedCategoryType");
        var costcode;
        if(selectedCostCode != undefined){
            costcode = selectedCostCode.Id;     
        }else{
            costcode = null;
        }
        var selectedAccount = component.get("v.selectedProductType");
        var selAccount;
        if(selectedAccount != undefined){
            selAccount = selectedAccount.Id;
        }else{
            selAccount = null;
        }
        var selectedTradeType = component.get("v.selectedTradeType");
        var selTradeType;
        if(selectedTradeType != undefined){
            selTradeType = selectedTradeType.Id;    
        }else{
            selTradeType = null;
        }
        var selectedBudget = component.get("v.selectedBudget");
        var parentRecordId = component.get("v.budgetID");
        var selectedMB;
        if(parentRecordId != undefined){
            selectedMB = component.get("v.parentRecordId");
        }else{
            
            if(selectedBudget != undefined){
                selectedMB = selectedBudget.Id;
            }
            else{
                selectedMB = null;
            } 
        }
        component.set("v.newPackageItem.buildertek__Product_Type__c", selAccount);
        component.set("v.newPackageItem.buildertek__Trade_Type__c", selTradeType);
        component.set("v.newPackageItem.buildertek__Category__c", costcode);
        var MBLineToInsert = JSON.stringify(component.get("v.newPackageItem"));
        component.set("v.Spinner", true);
        var action = component.get("c.saveMBItem");
        action.setParams({
            MBLines : MBLineToInsert,
            MBId : selectedMB
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                
                component.set("v.Spinner", false);
                
                var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                var result = response.getReturnValue();
               
             // $A.get("e.force:closeQuickAction").fire();
               // component.set("v.isOpen", false);
                 $A.get("e.force:closeQuickAction").fire();
                component.set("v.isOpen", false);
                  var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
       setTimeout(function () {
               
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: ' Package Line was created ',
                    messageTemplate: " package Line {0} was created",
                    type : 'success',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": result.Id,
                    "slideDevName": "related"
                });
                navEvt.fire();
              }, 1000);
            }
        });
        $A.enqueueAction(action);    
    },
    saveAndNew : function(component, event, helper) {
        component.set("v.Spinner", true);
        var selectedCostCode = component.get("v.selectedCategoryType");
        var costcode;
        if(selectedCostCode != undefined){
            costcode = selectedCostCode.Id;     
        }else{
            costcode = null;
        }
        var selectedAccount = component.get("v.selectedProductType");
        var selAccount;
        if(selectedAccount != undefined){
            selAccount = selectedAccount.Id;
        }else{
            selAccount = null;
        }
        var selectedTradeType = component.get("v.selectedTradeType");
        var selTradeType;
        if(selectedTradeType != undefined){
            selTradeType = selectedTradeType.Id;    
        }else{
            selTradeType = null;
        }
        var selectedBudget = component.get("v.selectedBudget");
        var parentRecordId = component.get("v.budgetID");
        var selectedMB;
        if(parentRecordId != undefined){
            selectedMB = component.get("v.parentRecordId");
        }else{
            
            if(selectedBudget != undefined){
                selectedMB = selectedBudget.Id;
            }
            else{
                selectedMB = null;
            } 
        }
        component.set("v.newPackageItem.buildertek__Product_Type__c", selAccount);
        component.set("v.newPackageItem.buildertek__Trade_Type__c", selTradeType);
        component.set("v.newPackageItem.buildertek__Category__c", costcode);
        var MBLineToInsert = JSON.stringify(component.get("v.newPackageItem"));
        component.set("v.Spinner", true);
        var action = component.get("c.saveMBItem");
        action.setParams({
            MBLines : MBLineToInsert,
            MBId : selectedMB
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.Spinner", false);
                var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                var result = response.getReturnValue();
                $A.get("e.force:closeQuickAction").fire();
                var workspaceAPI = component.find("workspace");
                workspaceAPI.getFocusedTabInfo().then(function(response) {
                    var focusedTabId = response.tabId;
                    workspaceAPI.closeTab({tabId: focusedTabId});
                })
                .catch(function(error) {
                    console.log(error);
                });
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: ' Package Line was created ',
                    messageTemplate: " package Line {0} was created",
                    type : 'success',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
                
                var navEvt = $A.get("e.force:navigateToSObject");
                navEvt.setParams({
                    "recordId": result.Id,
                    "slideDevName": "related"
                });
                navEvt.fire();
                window.location.reload(true);
            }
        });
        $A.enqueueAction(action);   
    },
    
    changefamily : function(component, event, helper) {
        var product = component.get('v.selectedLookUpRecord');
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({"recordByEvent" : product });  
        compEvent.fire();
        // component.set('v.newPackageItem.buildertek__Package_Name__c', '');
        component.set('v.newPackageItem.buildertek__Unit_Price__c', '');  
        
    },
    changeEvent: function(component, event, helper) {
        var product = component.get('v.selectedLookUpRecord');;
        var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
        compEvent.setParams({"recordByEvent" : product });  
        compEvent.fire();
        var pribooknames = component.get("v.pricebookName");
        var action = component.get("c.getProductfamilyRecords");
        action.setParams({ 
            'ObjectName' : "Product2",
            'parentId' : component.get("v.pricebookName")
        });
        action.setCallback(this, function(response) {
            $A.util.removeClass(component.find("mySpinner"), "slds-show");
            var state = response.getState();
            if (state === "SUCCESS") {
                var storeResponse = response.getReturnValue();
                if (storeResponse.length == 0) {
                    component.set("v.Message", 'No Result Found...');
                } else {
                    component.set("v.Message", '');
                }
                component.set("v.listofproductfamily", storeResponse);
                if(component.get("v.listofproductfamily").length >0){
                    component.set("v.productfamily",component.get("v.listofproductfamily")[0].productfamilyvalues);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
   handleCompanyOnChange : function(component, event, helper) {
        var indutry = component.get("v.newPackageItem.buildertek__Location__c");
       var UOM = component.get("v.newPackageItem.buildertek__UOM__c");
    },  
    
    
})