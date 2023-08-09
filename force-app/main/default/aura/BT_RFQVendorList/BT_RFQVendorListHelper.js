({
	//showSpinner: this will call on aura waiting hendler 
    showSpinner: function (component, event, helper) {
        var spinner = component.find("BTSpinner");
       $A.util.addClass(spinner, 'slds-show');
       $A.util.removeClass(spinner, 'slds-hide');
    },

    //hideSpinner: this will call on aura doneWaiting hendler
    hideSpinner: function (component, event, helper) {
       var spinner = component.find("BTSpinner");
       $A.util.addClass(spinner, 'slds-hide');
       $A.util.removeClass(spinner, 'slds-show');
    },
    
    replaceAll: function (str, term, replacement) {
	  return str.replace(new RegExp(this.escapeRegExp(term), 'g'), replacement);
	},
	escapeRegExp: function escapeRegExp(string){
	    return string.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
	},
	
    createVendorPicker: function (component, event, helper, callback){
    		 					
    		 					
	 	$A.createComponents([
			    ["c:BT_GridComponent",{
			    	"aura:id":"vendorList",
			        "objectName": "Account",
	                "fieldSetName": "buildertek__BT_Filter_Criteria_Fields",
	                "filterConditions": "",
	                "TableId": "vendorFilterResultTableId",
	                "PagerId": "vendorFilterResultTableIdPager",
	                "Pagination": true,
	                "RecordsToShowPerPage": 10,
	                "rowList": [],
	                "multiselect": true,
	                "ColumnChooser": false,
	                "CheckAll": true,
	                "Grouping": false,
	                "parentId": component.get("v.recordId"),
	                "gridType": "RFQ_VENDOR_PICKER_LHS",
	                "showSpinner":true,
			    }],
			    ["c:BT_GridComponent",{
			    	"aura:id":"selectedVendorList",
			        "objectName": "buildertek__RFQ_To_Vendor__c",
	                "fieldSetName": "buildertek__BT_Related_List_View_Fields",
	                "filterConditions": "",
	                "TableId": "rfqToVendorTableId",
	                "PagerId": "rfqToVendorPager",
	                "Pagination": true,
	                "RecordsToShowPerPage":10,
	                "rowList": [],
	                "multiselect": true,
	                "ColumnChooser": false,
	                "CheckAll": true,
	                "Grouping": false,
	                "parentId": component.get("v.recordId"),
	                "gridType": "RFQ_VENDOR_PICKER_RHS",
	                "showSpinner":true,
			    }]
		    ],
		    function(components, status, errorMessage){
		        if (status === "SUCCESS") {
		            if (component.isValid()) {
		            
	                    var avilabelVendor = component.find('avilabelVendorList_LHS');
	                    var avilabelVendorBody = avilabelVendor.get("v.body");
	                    console.log(avilabelVendorBody);
	                    avilabelVendorBody.push(components[0]);
	                    avilabelVendor.set("v.body", avilabelVendorBody);
	                    
	                    var selectedVendor = component.find('selectedVendorList_RHS');
	                    var selectedVendorBody = selectedVendor.get("v.body");
	                    selectedVendorBody.push(components[1]);
	                    selectedVendor.set("v.body", selectedVendorBody);
	                    
	                    callback();
	                }
		        }
		        else if (status === "INCOMPLETE") {
		            console.log("No response from server or client is offline.")
		            // Show offline error
		        }
		        else if (status === "ERROR") {
		            console.log("Error: " + errorMessage);
		            // Show error message
		        }
		    }
		);
     },
     
    createVendorLink: function (component, event, helper, selectedVendorIds) {
        var actionCreateLink;
        //Prepare actoin to retrive column header Json
        actionCreateLink = component.get("c.linkVendors");
        actionCreateLink.setParams({
            rfqId: component.get("v.recordId"),
            vendorIds: JSON.stringify(selectedVendorIds.ids)
        });
        actionCreateLink.setCallback(this, function (response) {
        	var toastEvent = $A.get("e.force:showToast");
	        if (component.isValid() && response.getState() === "SUCCESS") {
		            
		        if(response.getReturnValue() == 'success'){
		            toastEvent.setParams({
		                "type":"success",
		                "title": "",
		                "message": "Vendor Selected Successfully."
		            });
		           this.refreshGrid(component, event, helper);
		           
		        } else {
		            toastEvent.setParams({
		                "type":"error",
		                "title": "Error!",
		                "message": response.getReturnValue()
		            });
		        	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
		    	}
			}else {
	    		toastEvent.setParams({
	                "type":"error",
	                "title": "error",
	                "message": response.getError()[0].message
	            });
	    	}
	        toastEvent.fire();
        });
        
        $A.enqueueAction(actionCreateLink);
    },
    
    removeVendorLink: function (component, event, helper, selectedVendorIds) {
    	 var actionDeleteLink;
        actionDeleteLink = component.get("c.deleteVendorLinks");
        actionDeleteLink.setParams({
            vendorIds: JSON.stringify(selectedVendorIds.ids)
        });
        actionDeleteLink.setCallback(this, function (response) {
        	var toastEvent = $A.get("e.force:showToast");
	        if (component.isValid() && response.getState() === "SUCCESS") {
		            
		        if(response.getReturnValue() == 'success'){
		            toastEvent.setParams({
		                "type":"success",
		                "title": "",
		                "message": "Vendor Removed Successfully."
		            });
		            this.refreshGrid(component, event, helper);
		        } else {
		            toastEvent.setParams({
		                "type":"error",
		                "title": "Error!",
		                "message": response.getReturnValue()
		            });
		            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
		        	
		    	}
			}else {
	    		toastEvent.setParams({
	                "type":"error",
	                "title": "error",
	                "message": response.getError()[0].message
	            });
	    	}
	        toastEvent.fire();
        });
        
        $A.enqueueAction(actionDeleteLink);
    },
    
    sendRFQEmail: function (component, event, helper, selectedVendorIds) {
    	var action;
        action = component.get("c.sendRFQEmailToVendor");
        action.setParams({
            rfqToVendorLinkIds: JSON.stringify(selectedVendorIds.ids)
        });
        action.setCallback(this, function (response) {
        	var toastEvent = $A.get("e.force:showToast");
	        if (component.isValid() && response.getState() === "SUCCESS") {
		            
		        if(response.getReturnValue() == 'Email Sent Successfully'){
		            toastEvent.setParams({
		                "type":"success",
		                "title": "",
		                "message": response.getReturnValue()
		            });
		            $A.get("e.force:refreshView").fire();
		            this.refreshGrid(component, event, helper);
		        } else {
		            toastEvent.setParams({
		                "type":"error",
		                "title": "Error!",
		                "message": response.getReturnValue()
		            });
		        	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
		    	}
			}else {
	    		toastEvent.setParams({
	                "type":"error",
	                "title": "error",
	                "message": response.getError()[0].message
	            });
	    	}
	        toastEvent.fire();
        });
        
        $A.enqueueAction(action);
    },
    
    refreshGrid:function(component, event, helper){
       var grid = component.find("selectedVendorList");
       grid.refreshData();
       
       grid = component.find("vendorList");
       grid.refreshData();
    }
})