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
	        var groupFilter = "buildertek__Contract__c ='"+component.get("v.contractId")+"'";
             component.set("v.groupFilter",groupFilter);
	    }), 100);
    },
    
    editGroup: function(component, event, helper) {
    	$A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": "Edit Contract Group",
                    "HTMLAttributes": { 
                        "class": "slds-text-heading_medium slds-hyphenate" 
                    }
                }],
                ["c:BT_NewContractGroup", {
                    "contractId" : component.get("v.contractId"),
                    "groupId": component.get("v.group").Id,
                    "onSuccess" : function(){
                    	helper.updateData(component, event, helper, "[]");
                    },
                    "onDelete" : function(){
                    	var initReference = component.get("v.initReference");
                    	if(initReference){
                    		$A.enqueueAction(initReference);
                    	}
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
    
    handleRowAction: function (component, event, helper){
    	var action = event.getParam('action');
        var row = event.getParam('row');

        switch (action.name) {
            case 'edit':
                component.set("v.contractLine",row);
               	setTimeout($A.getCallback(function() {
                    var Budget = component.get("v.contractLine");
                    component.set("v.isOpen", true);
                    var action = component.get("c.getcontractItem");
                    action.setParams({"contractLineRecord":Budget.Id});
                    action.setCallback(this,function(response){
            	        if (response.getState() === "SUCCESS") {
            	            var result = response.getReturnValue();
            		        component.set("v.contractLine",response.getReturnValue());
            		        var build = "buildertek__Cost_Code__c";
            		        var buildProdName = "buildertek__Product__c";
            		        var resultStringify = (JSON.stringify(result)).toString();
            		        var cost = resultStringify.indexOf(build);
            		        var products = resultStringify.indexOf(buildProdName);
            		        if(cost != -1){
            		            component.set("v.costCode",result.buildertek__Cost_Code__r.buildertek__Cost_Code_Name__c);
            		        }
            		        else{
            		            component.set("v.costCode",'');
            		            component.set("v.contractLine.buildertek__Cost_Code__c",null);
            		        }
            		        
            		        if(products != -1){
            		            component.set("v.selectedLookUpRecord",result.buildertek__Product__r.Name);
            		        }
            		        else{
            		            component.set("v.selectedLookUpRecord",'');
            		        }
            		        
            		         
    		            }
    		            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                    });
                    $A.enqueueAction(action);
                }),300);
                //alert('Showing Details: ' + JSON.stringify(row));
                break;
            case 'delete':
            	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                helper.deleteLine(component, event, helper, row)
                break;
        }
    
    },
    
    handleHeaderAction: function (component, event, helper){
    	
    },
    
    UpdateSelectedRows:function (component, event, helper){
    	var selectedRows = event.getParam('selectedRows');        
        var setRows = [];
        for (var i = 0; i < selectedRows.length; i++){
            setRows.push(selectedRows[i]);
        }
        console.log(setRows);
        component.set("v.selectedRows", setRows); 
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
 
  updatecontractItemRecord: function (component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        var budgetLineObject = component.get("v.contractLine");
        var action = component.get("c.updatecontractLineItem");
        action.setParams({"contractLineRecord":budgetLineObject});
        action.setCallback(this,function(respo){
            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
	        if (respo.getState() === "SUCCESS") {
	            component.set("v.isOpen", false);
	            $A.get('e.force:refreshView').fire();
                var event = component.getEvent("RefreshEvent");
                event.setParam("message", "contract updated Successfully" );
                event.fire();  
	        }
        });
        $A.enqueueAction(action);
    },
    
    handleComponentEvent : function(component, event, helper) {
	     var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.contractLine.Name",selectedAccountGetFromEvent.Name);
	    component.set("v.contractLine.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	   // component.set("v.BudgetLine.buildertek__Product__r.Name",selectedAccountGetFromEvent.Name);
    },
    handleComponentEvents : function(component, event, helper) {
	     var selectedAccountGetFromEvent = event.getParam("recordByEvent");
	    component.set("v.contractLine.Name",selectedAccountGetFromEvent.Name);
	    component.set("v.contractLine.buildertek__Product__c",selectedAccountGetFromEvent.Id);
	   // component.set("v.BudgetLine.buildertek__Product__r.Name",selectedAccountGetFromEvent.Name);
    },
    
    onChildAttributeChange : function(component, event, helper) {
         
         $A.enqueueAction(component.get("c.UpdateRows"));
         
     },
     
     UpdateSelectedRows:function (component, event, helper){
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
    
})