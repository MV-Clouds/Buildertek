({
	doInit : function(component, event, helper) {
	    component.set("v.Spinner", true);
	    var recordId = component.get("v.mainObjectId");
		component.find('MBId').set("v.value", recordId);
		component.set("v.Spinner", false);
	},
	
	handleComponentEvent : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent"); 
	    component.set("v.newBudgetItem.buildertek__Budget_Item_Name__c",selectedAccountGetFromEvent.Name);
	    component.set("v.newBudgetItem.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	    component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
	    helper.getProductDetails(component, event, helper);
    },
    
    handleComponentEvents : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.newBudgetItem.buildertek__Budget_Item_Name__c",selectedAccountGetFromEvent.Name);
	    component.set("v.newBudgetItem.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	    component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
	    helper.getProductDetails(component, event, helper);
    },
    
    clearLookupValue: function (component, event, helper) {
		var childCmp = component.find("groupId");
		var retnMsg = childCmp.clearLookup();
		var childCmp = component.find("tradeTypeId");
		var retnMsg = childCmp.clearLookup();
		var childCmp = component.find("costCodeId");
		var retnMsg = childCmp.clearLookup();
		var childCmp = component.find("accountId");
		var retnMsg = childCmp.clearLookup();
	},
	
	doCancel : function(component, event, helper) {
        component.get("v.onCancel")();    
    },
   
    doSaveAndNew : function(component, event, helper) {
        component.set("v.Spinner", true);
        var selectedCostCode = component.get("v.selectedCostCode");
        var costcode;
        if(selectedCostCode != undefined){
            costcode = selectedCostCode.Id;     
        }else{
            costcode = null;
        }
        var selectedAccount = component.get("v.selectedAccount");
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
        var selectedGroup = component.get("v.selectedGroup");
        var selGroup;
        if(selectedGroup != undefined){
            selGroup = selectedGroup.Id;
        }else{
            selGroup = null;
        } 
        component.set("v.newBudgetItem.buildertek__Contractor__c", selAccount);
        component.set("v.newBudgetItem.buildertek__Trade_Type__c", selTradeType);
        component.set("v.newBudgetItem.buildertek__Group__c", selGroup);
        component.set("v.newBudgetItem.buildertek__Cost_Code__c", costcode);
        var MBLineToInsert = JSON.stringify(component.get("v.newBudgetItem"));
        var MBId = component.get("v.mainObjectId");
        var action = component.get("c.saveMBItem");
        action.setParams({
           MBLines : MBLineToInsert,
           MBId : MBId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var product = component.get('v.selectedLookUpRecord');
                var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
                compEvent.setParams({"recordByEvent" : product });  
                compEvent.fire();
                component.set("v.newBudgetItem.buildertek__Quantity__c", '');
                component.set("v.newBudgetItem.buildertek__Budget_Item_Name__c", '');
                
                //component.set("v.newPOItem.buildertek__Expense_GL_Account__c", null);
                //component.set("v.newPOItem.buildertek__Liability_GL_Account__c", null);
                //component.set("v.newPOItem.buildertek__Budget_Item__c", null);
                //component.set("v.newPOItem.buildertek__Cost_Code__c", null);
                component.set("v.newBudgetItem.buildertek__Unit_Price__c", null);
                component.set("v.newBudgetItem.buildertek__UOM__c", '');
                $A.enqueueAction(component.get("c.clearLookupValue"));
                component.set("v.Spinner", false);
                //$A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'Master Budget Line was created',
                    type : 'success',
                    duration: '10000',
                    mode: 'dismissible'
                });
                toastEvent.fire();
            }
        });
        $A.enqueueAction(action);      
    },
    doSave : function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        var selectedCostCode = component.get("v.selectedCostCode");
        var costcode;
        if(selectedCostCode != undefined){
            costcode = selectedCostCode.Id;     
        }else{
            costcode = null;
        }
        var selectedAccount = component.get("v.selectedAccount");
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
        var selectedGroup = component.get("v.selectedGroup");
        var selGroup;
        if(selectedGroup != undefined){
            selGroup = selectedGroup.Id;
        }else{
            selGroup = null;
        } 
        component.set("v.newBudgetItem.buildertek__Contractor__c", selAccount);
        component.set("v.newBudgetItem.buildertek__Trade_Type__c", selTradeType);
        component.set("v.newBudgetItem.buildertek__Group__c", selGroup);
        component.set("v.newBudgetItem.buildertek__Cost_Code__c", costcode);
        var MBLineToInsert = JSON.stringify(component.get("v.newBudgetItem"));
        var MBId = component.get("v.mainObjectId");
        var action = component.get("c.saveMBItem");
        action.setParams({
           MBLines : MBLineToInsert,
           MBId : MBId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.get("v.onSuccess")();  
            }
        });
        $A.enqueueAction(action);   
    },
   
})