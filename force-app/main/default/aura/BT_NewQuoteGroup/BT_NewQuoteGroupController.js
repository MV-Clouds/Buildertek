({
	init : function(component, event, helper) {
		//wrapper class with fields details
        helper.getGrouopFieldSet(component, event, helper);
	},
	
	/*handle the error on faild record edit form*/
    handleError: function(component, event, helper) {
        $A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "Hide"
        }).fire();
    },

    /*Close the overlay library modal*/
    close: function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    },

   
    onDelete:function(component, event, helper){
    	var section = component.get("v.section");
		$A.createComponents([
					["aura:html", {
	                    "tag": "h2",
	                    "body": "Delete Confirmation",
	                    "HTMLAttributes": { 
	                        "class": "slds-text-heading_medium slds-hyphenate" 
	                    }
	                }],
	                ["lightning:button",{
	                    "aura:id": "no_button",
	                    "label": "No",
	                    "name":"no",
	                    "onclick": component.getReference("c.deleteGroup")               
	                }],
	                ["lightning:button",{
	                    "aura:id": "Yes_button",
	                    "label": "Yes",
	                    "name":"yes",
	                    "variant":"brand",
	                    "onclick": component.getReference("c.deleteGroup")  
	                }]
	            ], function(components, status) {
	            	var buttons = [];
	            	buttons.push(components[1]);
	            	buttons.push(components[2]);
	                if (status === "SUCCESS") {
	                    var modalPromise = component.find('overlayLib').showCustomModal({
	                        header: components[0],
	                        body: "Are you sure you want to delete this quote group?",
	                        footer: buttons,
	                        showCloseButton: true
	                    });
	                    component.set("v.modalPromise", modalPromise);
	                }
	            });
    },
    
    deleteGroup: function(component, event, helper) {
    	var name = event.getSource().get("v.name");
        //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
        if (name === "yes") {
        	helper.closeModalPop(component);
        	var groups = [];
        	var group = {};
        	group.Id = component.get("v.groupId");
        	groups.push(group);
			helper.deleteGroup(component, event, helper, groups);
		} else {
			//$A.get("e.buildertek:avSpinnerEvent").setParams({"action" : "HIDE" }).fire();
			helper.closeModalPop(component);
		}
    },
    
    /*This method is for call the record edit 'onsubmit' event */
    save: function(component, event, helper) {
        var isValid;
        isValid = helper.validateInputFields(component, event, helper);
        if (isValid) {
            // submit the questionnaire record edit form
            document.getElementById('saveGroupButton').click();
            $A.enqueueAction(component.get('c.onSuccess'));
        } 

    },

    submit: function(component, event, helper) {
    	$A.get("e.c:BT_SpinnerEvent").setParams({
            "action": "SHOW"
        }).fire();
        var fields = event.getParam('fields');
        event.preventDefault(); // stop form submission
        fields["buildertek__Quote__c"] = component.get("v.quoteId");
        component.find("recordEditForm").submit(fields);
    },
    
    onSuccess: function(component, event, helper) {
    	var groupId = event.getParams().response.id, lines = component.get("v.lines");
    	//alert('groupId ---------> '+groupId);
    	if(lines.length > 0) {
	        var newQuoteItems = [];
	        for (var i = 0; i < lines.length; i++) {
	            var newQi = new Object();
	            newQi.buildertek__Product__c = lines[i].product;
	            newQi.Name =  lines[i].description && lines[i].description.length > 80 ? lines[i].description.substring(0, 76) + "..." : lines[i].description;
	            newQi.buildertek__description__c = lines[i].description;
	            newQi.buildertek__Unit_Price__c = lines[i].unitprice;
	            newQi.buildertek__quantity__c = lines[i].quantity;
	            newQi.buildertek__Grouping__c = groupId;
	            //newQi.buildertek__quote__c = component.get("v.quoteId");
	            newQuoteItems.push(newQi);
	        }
	        //alert('newQuoteItems --------> '+JSON.stringify(newQuoteItems));
	        console.log('--newQuoteItems--',newQuoteItems);
	        //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
	        helper.addSelectedProducts(component, event, helper, newQuoteItems);
        } else {
	        var toastMessage;
	
	        // Prepare a toast
	        window.setTimeout(
                $A.getCallback(function() {
                    var toastEvent = $A.get("e.force:showToast");
        	        toastEvent.setParams({
        	            message: component.get("v.groupId") ?"Quote Group Updated Successfully": "New Quote Group Added Successfully.",
        	            type: 'Success',
        	        });
        	        toastEvent.fire();
                }), 3000
            );
	        var onSuccess = component.get("v.onSuccess");
	        if (!$A.util.isUndefinedOrNull(onSuccess)) {
	            onSuccess();
	        }
	      
	        helper.closePopup(component);
        }
    },
    
})