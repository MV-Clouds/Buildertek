({
	doInit : function(component, event, helper) {
        var recordId = component.get("v.recordId");
	    var action = component.get("c.getBudgetInformation");
	    action.setParams({
	        budgetId : recordId
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result =  response.getReturnValue();  
	            component.set("v.budget", result);
	            var isLocked = component.get("v.budget.buildertek__Is_Budget_Locked__c");
	            if(isLocked == true){
	                component.set("v.isDisabled", true);
	                
	            }else{
	                component.set("v.isDisabled", false);
	            }
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	openImportBudgetLines : function(component, event, helper) {
	    component.set("v.isImportBudgetLines", true);
	    component.set("v.isPrintView", false);
	    component.set("v.isEdit", false);
	    component.set("v.isDelete", false);
	    var cmpTarget = component.find('Modalbox');
		var cmpBack = component.find('Modalbackdrop');
		$A.util.addClass(cmpBack,'slds-backdrop--open');
		$A.util.addClass(cmpTarget, 'slds-fade-in-open');
	},
	
	closeImportBudgetLines : function(component, event, helper) {
	    var budgetId = component.get("v.recordId");
	    var cmpTarget = component.find('Modalbox');
		var cmpBack = component.find('Modalbackdrop');
		$A.util.removeClass(cmpBack,'slds-backdrop--close');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
		$A.get('e.force:refreshView').fire();
	},
	
	printView : function(component, event, helper) {
	    component.set("v.isImportBudgetLines", false);
	    component.set("v.isPrintView", true);
	    component.set("v.isEdit", false);
	    component.set("v.isDelete", false);
	    /*var cmpTarget = component.find('PrintModalbox');
		var cmpBack = component.find('PrintModalbackdrop');
		$A.util.addClass(cmpBack,'slds-backdrop--open');
		$A.util.addClass(cmpTarget, 'slds-fade-in-open');*/
	},
	
	closePrintView : function(component, event, helper) {
	    var budgetId = component.get("v.recordId");
	    var cmpTarget = component.find('PrintModalbox');
		var cmpBack = component.find('PrintModalbackdrop');
		$A.util.removeClass(cmpBack,'slds-backdrop--close');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
		$A.get('e.force:refreshView').fire();
	},
	
	editBudget : function(component, event, helper) {
	    component.set("v.isImportBudgetLines", false);
	    component.set("v.isPrintView", false);
	    component.set("v.isEdit", true);
	    component.set("v.isDelete", false);
	    var cmpTarget = component.find('EditModalbox');
		var cmpBack = component.find('EditModalbackdrop');
		$A.util.addClass(cmpBack,'slds-backdrop--open');
		$A.util.addClass(cmpTarget, 'slds-fade-in-open');
	},
	
	closeEditModal : function(component, event, helper) {
	    component.set("v.isImportBudgetLines", false);
	    component.set("v.isPrintView", false);
	    component.set("v.isEdit", true);
	    component.set("v.isDelete", false);
	    var cmpTarget = component.find('EditModalbox');
		var cmpBack = component.find('EditModalbackdrop');
		$A.util.removeClass(cmpBack,'slds-backdrop--close');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
	},
	
	openDeleteModal : function(component, event, helper) {
	    component.set("v.isImportBudgetLines", false);
	    component.set("v.isPrintView", false);
	    component.set("v.isEdit", false);
	    component.set("v.isDelete", true);
	    var cmpTarget = component.find('DeleteModalbox');
		var cmpBack = component.find('DeleteModalbackdrop');
		$A.util.addClass(cmpBack,'slds-backdrop--open');
		$A.util.addClass(cmpTarget, 'slds-fade-in-open');
	},
	
	closeDeleteModal : function(component, event, helper) {
	    component.set("v.isImportBudgetLines", false);
	    component.set("v.isPrintView", false);
	    component.set("v.isEdit", true);
	    component.set("v.isDelete", false);
	    var cmpTarget = component.find('DeleteModalbox');
		var cmpBack = component.find('DeleteModalbackdrop');
		$A.util.removeClass(cmpBack,'slds-backdrop--close');
		$A.util.removeClass(cmpTarget, 'slds-fade-in-open');
	},
	
	deleteBudget : function(component, event, helper) {
	    var budgetId = component.get("v.recordId");
	    var action = component.get("c.deleteBudgetRecord");
	    action.setParams({
	        budgetId : budgetId
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            //$A.enqueueAction(component.get('c.gotoList'));
	            var url = location.href;
                var baseURL = url.substring(0, url.indexOf('/', 14));
                $A.get("e.force:navigateToURL").setParams({ 
                   "url": baseURL+'/one/one.app?source=aloha#/sObject/buildertek__Budget__c/home' 
                }).fire();
	        }
	    });
	    $A.enqueueAction(action);
	},
    refresh : function (component, event, helper) {
         $A.enqueueAction(component.get('c.doInit'));
    }
})