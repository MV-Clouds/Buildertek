({
	getdata: function(component, event, helper, isDelete){
		var rfq, actionRfqConfig, navigateToStep, rfqToVendorList, config, actionRfqToVendorList;
	    actionRfqToVendorList = component.get("c.getRfqToVendors");
	    actionRfqToVendorList.setParams({
	        rfqId: component.get("v.recordId")
	    });
	    actionRfqToVendorList.setCallback(this, function (response) {
	    	if (component.isValid() && response.getState() === "SUCCESS") {
	    		var rfqToVendorList = response.getReturnValue();
	    		//alert('rfqToVendorList ------> '+JSON.stringify(rfqToVendorList));
	    		component.set("v.rfqToVendorList",rfqToVendorList);
	    		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE"}).fire();    	
	    		
	    		if(!isDelete) {
	                var selectedVendor = document.getElementsByClassName('selectedVendor');
	                if(selectedVendor[0]){
	                	try{
	                		selectedVendor[0].click();
	                    }catch(e){
	                    }
	                }
                }else{
                	component.set("v.showVendorActions",false);
                }
                
                var selectedVendor = document.getElementsByClassName('selectedVendor');
                    		
        		for(var i = 0; i < selectedVendor.length; i++) {
        			selectedVendor[i].classList.remove("selectedVendor");
        		}
        		var selectedVendors = [];
                
                for(var i=0;i< rfqToVendorList.length;i++){
                    if(rfqToVendorList[i].buildertek__RFQ__r.buildertek__Status__c == 'Awarded' || rfqToVendorList[i].buildertek__RFQ__r.buildertek__Status__c == 'Accepted'){
                            if(rfqToVendorList[i].buildertek__Status__c == 'Awarded' || rfqToVendorList[i].buildertek__Status__c == 'Accepted'){
                                $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                                component.set("v.isDisabled", true);
                         		//var record = rfqToVendorList[i];
                        		//var recordId = rfqToVendorList[i].Id;
                        		selectedVendors.push(rfqToVendorList[i]);
                        		/*$A.createComponents(
                                    [
                                        ["force:recordView", {
                                            "recordId": recordId
                                        }],
                                        
                                    ], function(components, status) {
                                        if (status === 'SUCCESS') {
                                             var body = component.get("v.recordViewForm");
                                             components.forEach(function(item){
                                                body.push(item);
                                             });
                        	                 component.set("v.recordViewForm",body);
                        	                 component.set("v.IsOnLoad",true);
                        	                 component.set("v.showVendorActions",false);
                        	                 component.set("v.activeRFQVendor",record);
                        	                 component.set("v.activeRFQVendor",record);
                        	                 component.set("v.linedata",record.buildertek__Vendor_Items__r);
                        	                 $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                        	                 
                                        }
                                    }); */ 
                                    component.set("v.selectedVendorList", selectedVendors);
                                    component.set("v.isCompare",true);
                                    component.set("v.showVendorActions",false);
                                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                                    
                            }
                    }else{
                        component.set("v.isDisabled", false);
                        selectedVendors.push(rfqToVendorList[i]);
                        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                        component.set("v.selectedVendorList", selectedVendors);
                        component.set("v.isCompare",true);
                        component.set("v.showVendorActions",false);
                        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                    } 
                    
                }
	    	}
	    });

	    actionRfqConfig = component.get("c.getRfqConfig");
	    actionRfqConfig.setParams({
	        rfqId: component.get("v.recordId")
	    });
	    actionRfqConfig.setCallback(this, function (response) {
    	if (component.isValid() && response.getState() === "SUCCESS"){
    		console.log(response.getReturnValue());
    		
	    		var rfqConfig = response.getReturnValue();
	    		rfq = rfqConfig.rfq;
	    		config = rfqConfig.config;
	    		
	    		helper.updateInfoMessage(component, event, helper, rfq.buildertek__Status__c);
	    		
    		}
		});
		
    	$A.enqueueAction(actionRfqConfig);
	    $A.enqueueAction(actionRfqToVendorList);
        console.log('selectedVendorList::',component.get('v.selectedVendorList'));
	},
	moreDetails:function(component, event, helper, record, index){
		
		var selectedVendor = document.getElementsByClassName('selectedVendor');
		
		for(var i = 0; i < selectedVendor.length; i++) {
			selectedVendor[i].classList.remove("selectedVendor");
		}
		
		document.getElementById(index).classList.add("selectedVendor");
		$A.createComponents(
            [
                ["force:recordView", {
                    "recordId": record.Id
                }],
                
            ], function(components, status) {
                if (status === 'SUCCESS') {
	                 component.set("v.recordViewForm",components);
	                 component.set("v.showVendorActions",true);
	                 component.set("v.activeRFQVendor",record);
	                 component.set("v.linedata",record.buildertek__Vendor_Items__r);
	                 $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
	                 
                }
            });
	},
	

	updateStatus: function(component, event, helper, rfqtovendorId, statusToUpdate, subject, contactId){
    	var actionUpdateStatus;
        actionUpdateStatus = component.get("c.updateRFQToVendorStatus");
        actionUpdateStatus.setParams({
            rfqToVendorLinkIds: rfqtovendorId,
            Status: statusToUpdate
        });
        actionUpdateStatus.setCallback(this, function (response) {
        	var toastEvent = $A.get("e.force:showToast");
	        if (component.isValid() && response.getState() === "SUCCESS") {
		            
		        if(response.getReturnValue() !== ''){
		            toastEvent.setParams({
		                "type":"success",
		                "title": "",
		                "message": response.getReturnValue()
		            });
		            $A.get("e.force:refreshView").fire();
		            
		            helper.getdata(component, event, helper);
		            var action = component.get("c.createTask");
		            action.setParams({
		                "whoId" : contactId,
		                "whatId" : component.get("v.recordId"),
		                "emailSubject" : subject
		            });
		            $A.enqueueAction(action);
		            
		        } else {
		            toastEvent.setParams({
		                "type":"error",
		                "title": "Error!",
		                "message": response.getReturnValue()
		            });
		        	
		    	}
			}else {
	    		toastEvent.setParams({
	                "type":"error",
	                "title": "error",
	                "message": response.getError()[0].message
	            });
	    	}
	        toastEvent.fire();
	        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
        });
        
        $A.enqueueAction(actionUpdateStatus);
    },
    
    sendRFQEmail: function (component, event, helper, selectedVendorIds) {
    	var action;
        action = component.get("c.sendRFQEmailToVendor");
        action.setParams({
            rfqToVendorLinkIds: JSON.stringify(selectedVendorIds)
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
	        $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
        });
        
        $A.enqueueAction(action);
    },
    
    
    createVendorLink: function (component, event, helper, selectedVendorIds) {
        var actionCreateLink;
        //Prepare actoin to retrive column header Json
        actionCreateLink = component.get("c.linkVendors");
        actionCreateLink.setParams({
            rfqId: component.get("v.recordId"),
            vendorIds: selectedVendorIds
        });
        actionCreateLink.setCallback(this, function (response) {
        	var toastEvent = $A.get("e.force:showToast");
	        if (component.isValid() && response.getState() === "SUCCESS") {
		            
		        if(response.getReturnValue() == 'success'){
		            toastEvent.setParams({
		                "type":"success",
		                "title": "",
		                "message": "Vendor Added Successfully."
		            });
		            
		            helper.getdata(component, event, helper);
		            
		            var eventToFire = $A.get("e.c:AppEvent");
		            eventToFire.fire();
		            
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
	            $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
	    	}
	    	
	    	
	        toastEvent.fire();
        });
        
        $A.enqueueAction(actionCreateLink);
    },
    
    removeVendorLink: function (component, event, helper, selectedVendorIds) {
        var actionDeleteLink;
        actionDeleteLink = component.get("c.deleteVendorLinks");
        actionDeleteLink.setParams({
            vendorIds: JSON.stringify(selectedVendorIds)
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
		            helper.getdata(component, event, helper, true);
		             var eventToFire = $A.get("e.c:AppEvent");
		            eventToFire.fire();
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
    
     updateInfoMessage: function(component, event, helper, status) {
    	 console.log('---status---',status);
    	// Set the info message
    	if(status == 'Awarded'){
    		component.find("infoMessage").set("v.type", "success");
    		component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Review_info_message_with_Awarded_Status"));
    	} else if(status == 'Accepted'){
    		component.find("infoMessage").set("v.type", "success");
    		component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Review_info_message_with_Accepted_Status"));
    	}else {
    		component.find("infoMessage").set("v.type", "info");
    		component.find("infoMessage").set("v.Message", $A.get("$Label.c.RFQ_Review_info_message_with_New_Status"));
    	}
    },
     
})