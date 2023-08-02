({
	doInit : function(component, event, helper) {
	    var recordId = component.get("v.mainObjectId");
		component.find('POId').set("v.value", recordId);
	    helper.fetchpricebooks(component, event, helper);
	},
	
	handleComponentEvent : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.newPOItem.Name",selectedAccountGetFromEvent.Name);
	    component.set("v.newPOItem.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	    component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
	    helper.getProductDetails(component, event, helper);
    },
    
    handleComponentEvents : function(component, event, helper) {
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.newPOItem.Name",selectedAccountGetFromEvent.Name);
	    component.set("v.newPOItem.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	    component.set("v.productId", selectedAccountGetFromEvent.Id);
		component.set("v.productName", selectedAccountGetFromEvent.Name);
	    helper.getProductDetails(component, event, helper);
    },
    
    clearLookupValue: function (component, event, helper) {
		var childCmp = component.find("expenseId");
		var retnMsg = childCmp.clearLookup();
		var childCmp = component.find("liabilityId");
		var retnMsg = childCmp.clearLookup();
		var childCmp = component.find("costCodeId");
		var retnMsg = childCmp.clearLookup();
		var childCmp = component.find("budgetItemId");
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
        var selectedGLAccount = component.get("v.selectedGLAccount");
        var expenseGLAccount;
        if(selectedGLAccount != undefined){
            expenseGLAccount = selectedGLAccount.Id;
        }else{
            expenseGLAccount = null;
        }
        var selectedLAAccount = component.get("v.selectedLAAccount");
        var liabilityGLAccount;
        if(selectedLAAccount != undefined){
            liabilityGLAccount = selectedLAAccount.Id;    
        }else{
            liabilityGLAccount = null;
        }
        var selectedBudgetItem = component.get("v.selectedBudgetItem");
        var BudgetItem;
        if(selectedBudgetItem != undefined){
            BudgetItem = selectedBudgetItem.Id;
        }else{
            BudgetItem = null;
        } 
        component.set("v.newPOItem.buildertek__Expense_GL_Account__c", expenseGLAccount);
        component.set("v.newPOItem.buildertek__Liability_GL_Account__c", liabilityGLAccount);
        component.set("v.newPOItem.buildertek__Budget_Item__c", BudgetItem);
        component.set("v.newPOItem.buildertek__Cost_Code__c", costcode);
        var POLineToInsert = JSON.stringify(component.get("v.newPOItem"));
        var POId = component.get("v.mainObjectId");
        var action = component.get("c.savePOItem");
        action.setParams({
           POLines : POLineToInsert,
           POId : POId
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                var product = component.get('v.selectedLookUpRecord');
                var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
                compEvent.setParams({"recordByEvent" : product });  
                compEvent.fire();
                component.set("v.newPOItem.buildertek__Quantity__c", '');
                component.set("v.newPOItem.Name", '');
                
                //component.set("v.newPOItem.buildertek__Expense_GL_Account__c", null);
                //component.set("v.newPOItem.buildertek__Liability_GL_Account__c", null);
                //component.set("v.newPOItem.buildertek__Budget_Item__c", null);
                //component.set("v.newPOItem.buildertek__Cost_Code__c", null);
                component.set("v.newPOItem.buildertek__Unit_Price__c", null);
                component.set("v.newPOItem.buildertek__Tax__c", null);
                component.set("v.newPOItem.buildertek__Ordered_Date__c", null);
                component.set("v.newPOItem.buildertek__UOM__c", '');
                component.set("v.pricebookName", '');
                $A.enqueueAction(component.get("c.clearLookupValue"));
                component.set("v.Spinner", false);
                //$A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    mode: 'sticky',
                    message: 'Purchase Order Line was created',
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
        var selectedGLAccount = component.get("v.selectedGLAccount");
        var expenseGLAccount;
        if(selectedGLAccount != undefined){
            expenseGLAccount = selectedGLAccount.Id;
        }else{
            expenseGLAccount = null;
        }
        var selectedLAAccount = component.get("v.selectedLAAccount");
        var liabilityGLAccount;
        if(selectedLAAccount != undefined){
            liabilityGLAccount = selectedLAAccount.Id;    
        }else{
            liabilityGLAccount = null;
        }
        var selectedBudgetItem = component.get("v.selectedBudgetItem");
        var BudgetItem;
        if(selectedBudgetItem != undefined){
            BudgetItem = selectedBudgetItem.Id;
        }else{
            BudgetItem = null;
        } 
        component.set("v.newPOItem.buildertek__Expense_GL_Account__c", expenseGLAccount);
        component.set("v.newPOItem.buildertek__Liability_GL_Account__c", liabilityGLAccount);
        component.set("v.newPOItem.buildertek__Budget_Item__c", BudgetItem);
        component.set("v.newPOItem.buildertek__Cost_Code__c", costcode);
        var POLineToInsert = JSON.stringify(component.get("v.newPOItem"));
        var POId = component.get("v.mainObjectId");
        var action = component.get("c.savePOItem");
        action.setParams({
           POLines : POLineToInsert,
           POId : POId
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