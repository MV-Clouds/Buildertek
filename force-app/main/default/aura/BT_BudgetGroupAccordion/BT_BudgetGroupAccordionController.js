({
	twistAccordion: function(component, event, helper) {
        var groupId = component.get("v.group").Id;
        if(groupId){
            var elem = document.getElementById('accordion'+component.getGlobalId());
            
            // Check for class
            if (elem.classList.contains('slds-is-open')) { 
                
                // Add class
                elem.classList.add('slds-is-close'); 
                
                // Remove class
                elem.classList.remove('slds-is-open'); 
                
                component.set("v.icone","chevronright");
            } else {
                
                elem.classList.add('slds-is-open'); 
		        elem.classList.remove('slds-is-close');
		        component.set("v.icone","chevrondown");
            }
        }
        
    },
    
    init: function(component, event, helper) {
        
		window.setTimeout($A.getCallback(function() {
	        helper.getSummary(component, event, helper);
	        var groupFilter = "buildertek__Budget__c ='"+component.get("v.budgetId")+"'";
            component.set("v.groupFilter",groupFilter);
	    }), 100);
    },
    
    editGroup: function(component, event, helper) {
    	$A.createComponents(
            [
                ["aura:html", 
                    {
                        "tag": "h2",
                        "body": "Edit Budget Group",
                        "HTMLAttributes": { 
                            "class": "slds-text-heading_medium slds-hyphenate" 
                        }
                    }
                ],
                ["c:BT_NewBudgetGroup", 
                    {
                        "budgetId" : component.get("v.budgetId"),
                        "groupId": component.get("v.group").Id,
                        "onSuccess" : function() {
                        	helper.updateData(component, event, helper, "[]");
                        },
                        "onDelete" : function(){
                        	var initReference = component.get("v.initReference");
                        	if(initReference) {
                        		$A.enqueueAction(initReference);
                        	}
                        }
                    }
                ], 
            ], 
            function(components, status) {
                if (status === 'SUCCESS') {
                    component.find('overlayLib').showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer:components[1].find("footer"),
                        showCloseButton: true,
                        cssClass: 'slds-modal_large'
                    });
                }
            }
        );
    },
    
    handleRowAction: function (component, event, helper){
    	var action = event.getParam('action');
        var row = event.getParam('row');
        switch (action.name) {
            case 'edit':
                var Budget = component.get("v.BudgetLine");
                component.set("v.BudgetLine",row);
               /* helper.fetchPickListVal(component, event,helper);
               	setTimeout($A.getCallback(function() {
                    var Budget = component.get("v.BudgetLine");
                    component.set("v.isOpen", true);
                    var action = component.get("c.getBudgetItem");
                    action.setStorable();
                    action.setParams({"budgetLineRecord":Budget.Id});
                    action.setCallback(this,function(response){
            	        if (response.getState() === "SUCCESS") {
            	            var result = response.getReturnValue();
            		        component.set("v.BudgetLine",response.getReturnValue());
            		        var build = "buildertek__Cost_Code__c";
            		        var resultStringify = (JSON.stringify(result)).toString();
            		        var n = resultStringify.indexOf(build);
            		        if(n != -1){
            		            component.set("v.costCode",result.buildertek__Cost_Code__r.Name);
            		        }
            		        else{
            		            component.set("v.costCode",'');
            		            component.set("v.BudgetLine.buildertek__Cost_Code__c",null);
            		        }
            		         component.set("v.selectedLookUpRecord",result.buildertek__Product_Name__c);
    		            }
    		            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                    });
                    $A.enqueueAction(action);
                }),300);*/
                var editRecordEvent = $A.get("e.force:editRecord");
                editRecordEvent.setParams({
                    "recordId": row.Id
                });
                editRecordEvent.fire();
                break;
            case 'delete':
            	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                helper.deleteLine(component, event, helper, row)
                break;
        }
    
    },
    
    handleHeaderAction: function (component, event, helper){
        ////alert('Hiiiiiiiii');           
    },
    
    handleCheckboxEvent: function (cmp, event, helper){
     
    },
    
    UpdateSelectedRows:function (component, event, helper){
        //alert('Hiiiiii');
        ////alert('Selected');
    	var selectedRows = event.getParam('selectedRows'); 
    	
    	
    	//alert('group --> ' + JSON.stringify(component.get("v.group.Id")));  
    	console.log('selectedRows --> '+JSON.stringify(selectedRows));
        var setRows = [];
        var Jsonvalue = '[{"GroupId": "'+ component.get("v.group.Id") + '"';
        Jsonvalue += ',"lineItems" :[';
        for (var i = 0; i < selectedRows.length; i++){
            Jsonvalue += '{ "Id": "' + selectedRows[i].Id + '"}';
            if(i < (selectedRows.length-1)){
               Jsonvalue += ','; 
            }
        }
        Jsonvalue += ']}]';
        //alert('Initial setRows --------> '+Jsonvalue);
         var jsonparse = JSON.parse(Jsonvalue);
         setRows = jsonparse;
         console.log('Initial setRows --------> '+JSON.stringify(setRows));
         console.log(setRows);
         component.set("v.selectedRows", setRows);
    },
    
    UpdateRows:function (component, event, helper){
        var headerCheck = component.get("v.childAttribute");
        ////alert('headerCheck ------> '+headerCheck);
        if(headerCheck == true){
            var lines = component.get("v.lines");
            var setRows = [];
            for (var i = 0; i < lines.length; i++){
                setRows.push(lines[i].Id);
            }
            component.set("v.selectedColumns", setRows); 
        }else{
            component.set("v.selectedColumns", []);  
        }
         
    },
    
   
    
    onsave:function(component, event, helper){
    	var draftValues = event.getParams('draftValues');
    	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
    	helper.updateData(component, event, helper, JSON.stringify(draftValues.draftValues));
    },
    
    /* Created by Model Start */
    openModel: function(component, event, helper) {
        // for Display Model,set the "isOpen" attribute to "true"
        component.set("v.isOpen", true);
    },
    
    closeModel: function(component, event, helper) {
        // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
        component.set("v.isOpen", false);
    },
    
   
    onPicklistChange: function(component, event, helper) {
	// get the value of select option
    },

    updateBudgetItemRecord: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        var budgetLineObject = component.get("v.BudgetLine");
        var action = component.get("c.updateBudgetLineItem");
        action.setParams({"budgetLineRecord":JSON.stringify(budgetLineObject)});
        action.setCallback(this,function(respo){
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
	        if (respo.getState() === "SUCCESS") {
	            component.set("v.isOpen", false);
                var event = component.getEvent("RefreshEvent");
                event.setParam("message", "budget updated Successfully" );
                event.fire();  
	        }
        });
        $A.enqueueAction(action);
    },
    
    handleComponentEvent : function(component, event, helper) {
	     var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.BudgetLine.Name",selectedAccountGetFromEvent.Name);
	    component.set("v.BudgetLine.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	    component.set("v.BudgetLine.buildertek__Product_Name__c",selectedAccountGetFromEvent.Name);
    },
    handleComponentEvents : function(component, event, helper) {
	     var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.BudgetLine.Name",selectedAccountGetFromEvent.Name);
	    component.set("v.BudgetLine.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	    component.set("v.BudgetLine.buildertek__Product_Name__c",selectedAccountGetFromEvent.Name);
    },
    
     onChildAttributeChange : function(component, event, helper) {
         
         $A.enqueueAction(component.get("c.UpdateRows"));
         
     },
    
    /*changeValue : function(component, event, helper) {
        console.log('Final ----->'+component.get("v.selectedColumns"));
    }*/
    
    /* Created by Model end */
    
})