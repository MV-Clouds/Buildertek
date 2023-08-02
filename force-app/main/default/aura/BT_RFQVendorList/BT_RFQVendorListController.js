({
	
    doinit:function(component, event, helper){
    	
    },
    
    initialize:function(component, event, helper){
    	var rfq = component.get("v.rfq");
    	helper.createVendorPicker(component, event, helper, function(){
	    	
	    	// Set the info message
	    	if(rfq.buildertek__Status__c == 'Awarded'){
	    		component.find("infoMessage").set("v.type", "success");
	    		component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Vendor_info_message_with_Awarded_Status"));
	    	
	    	} else if(rfq.buildertek__Status__c == 'Accepted'){
	    		component.find("infoMessage").set("v.type", "success");
	    		component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Vendor_info_message_with_Accepted_Status"));
	    	
	    	
	    	}else {
	    		component.find("infoMessage").set("v.type", "info");
	    		component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Vendor_info_message_with_New_Status"));
	    	}
	    	
    	});
    },
    
    refreshVendorList: function(component, event, helper){
    	 //var grid = component.find("avilabelVendorList_LHS").get("v.body")[0];
		 //grid.find("vendorList").refreshData();
		 $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		 var grid = component.find("vendorList").refreshData();
    },
    
    refreshSelectedVendorList: function(component, event, helper){
    	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
    	 var grid = component.find("selectedVendorList").refreshData();
    },
    
    addVendor:function(component, event, helper){
    	var result = {};
    	component.find("vendorList").getSelectedRecords(result);
    	
        if(!result || result.ids == -1){
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"error",
                "title": "",
                "message": "Please Select Vendor."
            });
            toastEvent.fire();
        } else {
        	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
            helper.createVendorLink(component, event, helper, result);
        }
        
    },
    
    removeVendor:function(component, event, helper){
        var result = {};
    	component.find("selectedVendorList").getSelectedRecords(result);
    	
        if(!result || result.ids == -1) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"error",
                "title": "",
                "message": "Please Select Vendor."
            });
            toastEvent.fire();
        } else {
        	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
            helper.removeVendorLink(component, event, helper, result);
            
        }
    },
    
    sendEmailClick:function(component, event, helper){
        var result = {};
    	component.find("selectedVendorList").getSelectedRecords(result);
    	
        if(!result || result.ids == -1) {
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type":"error",
                "title": "",
                "message": "Please Select Vendor."
            });
            toastEvent.fire();
        } else {
        	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
            helper.sendRFQEmail(component, event, helper, result);
        }
    },
    
    recordUpdated : function(component, event, helper) {
      var params = event.getParam('arguments');
      if (params) {
            var param1 = params.param1;
            component.set("v.rfq", param1);
            //helper.updateInfoMessage(component, event, helper);
      }
    }
    
})