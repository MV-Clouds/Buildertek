({
	init : function(component, event, helper) {
	    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		helper.getBudgetGroups(component, event, helper);
		
	},
	
	groupLoaded : function(component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
	},
	
	newGroup: function(component, event, helper){
		$A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": "New Budget Group",
                    "HTMLAttributes": { 
                        "class": "slds-text-heading_medium slds-hyphenate" 
                    }
                }],
                ["c:BT_NewBudgetGroup", {
                    "budgetId" : component.get("v.budgetId"),
                    "onSuccess" : function(){
                    	helper.getBudgetGroups(component, event, helper);
                    }
                }], 
                
            ], function(components, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer:components[1].find("footer"),
                        showCloseButton: true,
                        cssClass: 'slds-modal_large'
                    });
                    
                }
            });
	},
	saveBudgetItemRecord: function (component, event, helper) {
                            
        //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
       $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        var recordId = component.get("v.budgetId");
        //alert('recordId --> '+recordId);
        component.set("v.newBudgetLine.buildertek__Budget__c",recordId);
        //alert('Budget --> '+component.get("v.newBudgetLine.buildertek__Budget__c"));
        var budgetLineObject = component.get("v.newBudgetLine");
        var tradeType;
        var contractor;
        var selectedTradetype = component.get("v.selectedTradeType");
        if(selectedTradetype != undefined){
            tradeType = selectedTradetype.Id;       
        }else{
            tradeType = null;
        }
        var selectedContractor = component.get("v.selectedContractor");
        if(selectedContractor != undefined){
            contractor = selectedContractor.Id;       
        }else{
            contractor = null;
        }
        //alert('budgetLineObject --------> '+JSON.stringify(budgetLineObject));
        var action = component.get("c.saveBudgetLineItem");
        action.setParams({"budgetLineRecord":JSON.stringify(budgetLineObject), recordId : recordId, contractor : contractor, tradeType : tradeType});
        action.setCallback(this,function(respo){
	        if (component.isValid() && respo.getState() === "SUCCESS") {
                var group = component.find('groupId');
                group.set("v._text_value", '');
                var costCode = component.find('costCodeId');
                costCode.set("v._text_value", '');
                var product = component.get('v.selectedLookUpRecord');
                var compEvent = $A.get('e.c:BT_CLearLightningLookupEvent');
                compEvent.setParams({"recordByEvent" : product });  
                compEvent.fire();
                component.set('v.newBudgetLine.Name', '');
                component.set('v.newBudgetLine.buildertek__Cost_Code__c', null);
                component.set('v.newBudgetLine.buildertek__Group__c', null);
                component.set('v.newBudgetLine.buildertek__UOM__c', '');
                component.set('v.newBudgetLine.buildertek__Unit_Price__c', '');
                component.set('v.newBudgetLine.buildertek__Quantity__c', '1');
                $A.enqueueAction(component.get("c.clearLookupValue"));
                //document.location.reload(true);
                $A.get('e.force:refreshView').fire();
                var toastEvent = $A.get("e.force:showToast");
		        toastEvent.setParams({
			        "title": "",
			        "message": "Budget Line Added succesfully.",
			        "type": "success"
		        });
		        toastEvent.fire();
                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                //component.refreshData();
	        }
        });
        $A.enqueueAction(action);
    },
    clearLookupValue : function(component, event, helper) {
        var childCmp = component.find("tradeTypeId");
        var retnMsg = childCmp.clearLookup();
        var childCmp = component.find("accountId");
        var retnMsg = childCmp.clearLookup();
    },
    handleComponentEvent : function(component, event, helper) {
	    // get the selected Account record from the COMPONETN event 	 
	    var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.productId",selectedAccountGetFromEvent.Id);
	    component.set("v.productName",selectedAccountGetFromEvent.Name);
	    helper.getProductDetails(component,event,helper);
    },
    
   handleEvent  : function(component, event, helper){
        var message = event.getParam("message");
        var toastEvent = $A.get("e.force:showToast");
		        toastEvent.setParams({
			        "title": "",
			        "message": message,
			        "type": "success"
		        });
		 component.refreshData();
		 $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
    },
    
    
    
    refresh : function(component, event, helper) {
        $A.enqueueAction(component.get('c.init'));
    },
    
     handleChange : function(component, event, helper) {
        console.log("childAttr has changed");
        console.log("old value: " + event.getParam("oldValue"));
        console.log("current value: " + event.getParam("value"));
        var previousValue = event.getParam("oldValue");
        var currentValue = event.getParam("value");
        var selectedValue = [];
        selectedValue.push(previousValue, currentValue);
        console.log('selectedValue -------> '+selectedValue);
        var sel = component.get("v.FinalSelectedList");
        if(sel != null){
            sel.push(currentValue); 
            component.set("v.FinalSelectedList", sel);
        }else{
            component.set("v.FinalSelectedList", selectedValue);
        }
        //sel.push(selectedValue);
        //component.set("v.selectedColumns", selectedValue);
    }
	
})