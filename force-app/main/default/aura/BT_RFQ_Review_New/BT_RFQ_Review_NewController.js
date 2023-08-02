({
	initialize : function(component, event, helper) {
    	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		    component.set('v.columns', [
						            {label: 'Line name', fieldName: 'Name', type: 'text'},
						            {label: 'Description', fieldName: 'buildertek__Description__c', type: 'text'},
						            {label: 'Quantity', fieldName: 'buildertek__Quantity__c', type: 'number', class:'slds-align-left'},
						            {label: 'Unit Price', fieldName: 'buildertek__Unit_Price__c', type: 'currency'},
						            {label: 'Total Price', fieldName: 'buildertek__Total_Price__c', type: 'currency', typeAttributes: { currencyCode: 'USD', align:'center'}},
						            {label: 'Vendor Notes', fieldName: 'buildertek__Vendor_Note__c', type: 'text'}
						        ]);
		helper.getdata(component, event, helper); 
	},
	
	vendorLoaded: function(component, event, helper) {
		//helper.moreDetails(component.get("v.rfqToVendorList")[0].Id,'0');
	},
	
	openRFQ : function(component, event, helper) {
	    var recordId = component.get("v.recordId");
	    /*var recordId = component.get("v.recordId");
	    var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": recordId,
          "slideDevName": "detail",
          "isredirect": true
        });
        navEvt.fire();*/
        window.open('/' + recordId); 
	}, 
	
	openVendor : function(component, event, helper) {
	    var recordId = event.target.dataset.name;
	    /*var navEvt = $A.get("e.force:navigateToSObject");
        navEvt.setParams({
          "recordId": recordId,
          "slideDevName": "detail",
          "isredirect": true
        });
        navEvt.fire();*/
        window.open('/' + recordId); 
	},
	
	showMoreDetails : function(component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		var record = component.get("v.rfqToVendorList")[event.currentTarget.id];
		//alert('record ---------> '+JSON.stringify(record));
		var selectedVendor = document.getElementsByClassName('selectedVendor');
		
		for(var i = 0; i < selectedVendor.length; i++) {
			selectedVendor[i].classList.remove("selectedVendor");
		}
		
		document.getElementById(event.currentTarget.id).classList.add("selectedVendor");
		$A.createComponents(
            [
                ["force:recordView", {
                    "recordId": record.Id
                }],
                
            ], function(components, status) {
                if (status === 'SUCCESS') {
                     component.set("v.IsOnLoad",false);
	                 component.set("v.recordViewForm",components);
	                 component.set("v.isCompare",false);
	                 component.set("v.showVendorActions",true);
	                 component.set("v.activeRFQVendor",record);
	                 component.set("v.linedata",record.buildertek__Vendor_Items__r);
	                 $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
	                 
                }
            });
            
           
	},
	
	uncheckAll:function(component, event, helper){
		 component.find("vendorCheckall").set("v.checked", false);
	},
	
	awardRFQ : function(component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		//alert('Active Vendor ---------> '+component.get("v.activeRFQVendor"));
		var subject = 'Quote has been awarded to you [ref:'+component.get("v.recordId")+']';
		var selectedVendor = component.get("v.activeRFQVendor");
		//alert('selectedVendor ---------> '+selectedVendor);
		var recordId;
		if(selectedVendor != null && selectedVendor != undefined){
    		var contactId = selectedVendor.buildertek__Contact__c;
    		recordId = selectedVendor.Id;
    		helper.updateStatus(component, event, helper, recordId, "Awarded", subject, contactId);
		}
		else{
		     var toastEvent = $A.get("e.force:showToast");
			 toastEvent.setParams({
		                "type":"error",
		                "title": "Error!",
		                "message": "Please Select Vendors"
		            });
		    toastEvent.fire();
		    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
		}
	},
	
	awardSelectedVendor : function(component, event, helper) {
	    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		//alert('Active Vendor ---------> '+component.get("v.activeRFQVendor"));
		var subject = 'Quote has been awarded to you [ref:'+component.get("v.recordId")+']';
	    var selectedVendor = event.target.dataset.name; 
	    //alert('selectedVendor ----------> '+selectedVendor);
	    var contactId;
	    var action = component.get("c.getSelectedVendorData");
	    action.setParams({
	        vendorId : selectedVendor
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result = response.getReturnValue();
	            //alert('result --------> '+result);
	            if(result.buildertek__Contact__c != undefined){
	                contactId = result.buildertek__Contact__c;        
	            }
	            helper.updateStatus(component, event, helper, selectedVendor, "Awarded", subject, contactId);
	        }
	    });
	    $A.enqueueAction(action);
	},
	
	rejectRFQ : function(component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		helper.updateStatus(component, event, helper, component.get("v.activeRFQVendor").Id, "Rejected");
	},
	
	acceptedRFQ : function(component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		helper.updateStatus(component, event, helper, component.get("v.activeRFQVendor").Id, "Accepted");
	},
	
	canceledRFQ : function(component, event, helper) {
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		helper.updateStatus(component, event, helper, component.get("v.activeRFQVendor").Id, "Canceled");
	},
	
	sendRFQ : function(component, event, helper) {
		var selectedvendors = [];
		selectedvendors.push(component.get("v.activeRFQVendor").Id);
		//alert('selectedvendors -------> '+selectedvendors);
		$A.createComponents(
	            [
	                ["aura:html", {
	                    "tag": "h2",
	                    "body": "RFQ Email Preview",
	                    "HTMLAttributes": { 
	                        "class": "slds-text-heading_medium slds-hyphenate" 
	                    }
	                }],
	                ["c:BT_RFQ_Email_Preview", {
	                    "rfqId":component.get("v.recordId"),
	                    "vendorIds":selectedvendors,
	                    "onSuccess": function(object, contactId){
	                    	component.get('v.modalPromise').then(function (modal) {
		                        modal.close();
		                    });
	                    	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                    		helper.updateStatus(component, event, helper, component.get("v.activeRFQVendor").Id, "Email Sent", object, contactId);
	                    },
	                }], 
	                
	            ], function(components, status) { 
	                if (status === 'SUCCESS') {
	                    var modalPromise =  component.find('overlayLib').showCustomModal({
	                        header: components[0],
	                        body: components[1],
	                        footer:components[1].find("footer") ,
	                        showCloseButton: true,
	                        cssClass: 'slds-modal_medium'
	                    });
	                    component.set("v.modalPromise", modalPromise);
	                }
	            });
		
	},
	
	sendMassEmails : function(component, event, helper) {
	    var isDisabled = component.get("v.isDisabled"); 
		if(isDisabled == true){
		    var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "message": "You cannot Email this RFQ because this RFQ is already Awarded"
            });
            toastEvent.fire();    
		}else{
		    var vendorList = component.get("v.rfqToVendorList");
		
    		var allcheckbox = component.find("vendorselection");
    		
    		
    		var selectedvendors = [];
    		if(vendorList.length > 1){
    		    for(var i = 0; i < allcheckbox.length; i++) {
        			console.log(allcheckbox[i].get("v.checked"));
        			if(allcheckbox[i].get("v.checked")){
        				selectedvendors.push(vendorList[allcheckbox[i].get("v.value")].Id);
        			}
        		}    
    		}else{
    		    if(allcheckbox.get("v.checked")){
    				selectedvendors.push(vendorList[allcheckbox.get("v.value")].Id);
    			}    
    		}
    		
    		
    		console.log(selectedvendors);
    		
    		if(selectedvendors.length > 0) { 
    		
    			$A.createComponents(
    	            [
    	                ["aura:html", {
    	                    "tag": "h2",
    	                    "body": "RFQ Email Preview",
    	                    "HTMLAttributes": { 
    	                        "class": "slds-text-heading_medium slds-hyphenate" 
    	                    }
    	                }],
    	                ["c:BT_RFQ_Email_Preview", {
    	                    "rfqId":component.get("v.recordId"),
    	                    "vendorIds":selectedvendors,
    	                    "onSuccess": function(object){
    	                    	component.get('v.modalPromise').then(function (modal) {
    		                        modal.close();
    		                    });
    	                    	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
    	                    	helper.sendRFQEmail(component, event, helper, selectedvendors);
    	                    },
    	                }], 
    	                
    	            ], function(components, status) { 
    	                if (status === 'SUCCESS') {
    	                   var modalPromise =  component.find('overlayLib').showCustomModal({
    	                        header: components[0],
    	                        body: components[1],
    	                        footer:components[1].find("footer") ,
    	                        showCloseButton: true,
    	                        cssClass: 'mymodal'
    	                    });
    	                    
    	                    component.set("v.modalPromise", modalPromise);
    	                    
    	                }
    	            });
    			
    		}else {
    			 var toastEvent = $A.get("e.force:showToast");
    			 toastEvent.setParams({
    		                "type":"error",
    		                "title": "Error!",
    		                "message": "Please Select Vendors"
    		            });
    		    toastEvent.fire();
    		    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
    		}    
		}
	},
	
	deleteVendors:function(component, event, helper){
	    var isDisabled = component.get("v.isDisabled");
	    if(isDisabled == true){
	        var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": "error",
                "message": "You cannot delete this RFQ as this RFQ is already Awarded"
            });
            toastEvent.fire();       
	    }else{
	        var vendorList = component.get("v.rfqToVendorList");
    		var allcheckbox = component.find("vendorselection");
    		var selectedvendors = [];
    		/*for(var i = 0; i < allcheckbox.length; i++) {
    			console.log(allcheckbox[i].get("v.checked"));
    			if(allcheckbox[i].get("v.checked")){
    				selectedvendors.push(vendorList[allcheckbox[i].get("v.value")].Id);
    			}
    		}*/
    		
    		if(vendorList.length > 1){
    		    for(var i = 0; i < allcheckbox.length; i++) {
        			console.log(allcheckbox[i].get("v.checked"));
        			if(allcheckbox[i].get("v.checked")){
        				selectedvendors.push(vendorList[allcheckbox[i].get("v.value")].Id);
        			}
        		}    
    		}else{
    		    if(allcheckbox.get("v.checked")){
    				selectedvendors.push(vendorList[allcheckbox.get("v.value")].Id);
    			}    
    		}
    		
    		if(selectedvendors.length > 0) { 
    			$A.createComponents(
    	            [
    	                ["aura:html", {
    		                    "tag": "h2",
    		                    "body": "Confirmation",
    		                    "HTMLAttributes": { 
    		                        "class": "slds-text-heading_medium slds-hyphenate" 
    		                    }
    		            }],
    	                ["lightning:button",{
    	                    "aura:id": "no_button",
    	                    "label": "Cancel",
    	                    "name":"no",
    	                    "onclick": component.getReference("c.closeRemoveVendor")               
    	                }],
    	                ["lightning:button",{
    	                    "aura:id": "Yes_button",
    	                    "label": "Yes",
    	                    "name":"yes",
    	                    "variant":"brand",
    	                    "onclick": component.getReference("c.removeVendors")  
    	                }]
    	            ], function(contant, status) {
    	                if (status === "SUCCESS") {
    	                    var footer = [];
    	                	footer.push(contant[1]);
    	                    footer.push(contant[2]);
    	                    var overlayLib = component.find('overlayLib').showCustomModal({
    	                        header: contant[0],
    	                        body: "Are you sure you want to delete this vendor?",
    	                        footer: footer,
    	                        showCloseButton: true
    	                    });
    	                    component.set("v.modalPromise",overlayLib);
    	                }
    	            }
    	        );
    		}else {
    			 var toastEvent = $A.get("e.force:showToast");
    			 toastEvent.setParams({
    		                "type":"error",
    		                "title": "Error!",
    		                "message": "Please Select Vendors"
    		            });
    		    toastEvent.fire();
    		    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
    		}    
	    }
		
	},
	
	closeRemoveVendor:function(component, event, helper) {
		 component.get('v.modalPromise').then(function (modal) {
                modal.close();
            });
	},
	
	
	removeVendors : function(component, event, helper) {
		 component.get('v.modalPromise').then(function (modal) {
                modal.close();
            });
            
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		var vendorList = component.get("v.rfqToVendorList");
		
		var allcheckbox = component.find("vendorselection");
		
		
		var selectedvendors = [];
		if(vendorList.length > 1){
    		for(var i = 0; i < allcheckbox.length; i++) {
    			console.log(allcheckbox[i].get("v.checked"));
    			if(allcheckbox[i].get("v.checked")){
    				selectedvendors.push(vendorList[allcheckbox[i].get("v.value")].Id);
    			}
    		}
		}else{
		    if(allcheckbox.get("v.checked")){
				selectedvendors.push(vendorList[allcheckbox.get("v.value")].Id);
			}
		}
		
		console.log(selectedvendors);
		
		if(selectedvendors.length > 0) { 
			helper.removeVendorLink(component, event, helper, selectedvendors);
		}else {
			 var toastEvent = $A.get("e.force:showToast");
			 toastEvent.setParams({
		                "type":"error",
		                "title": "Error!",
		                "message": "Please Select Vendors"
		            });
		    toastEvent.fire();
		    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
		}
		
	},
	
	addVendors: function(component, event, helper){
		var overlayLib;
		$A.createComponents(
            [
                ["aura:html", {
	                    "tag": "h2",
	                    "body": "Add Vendors",
	                    "HTMLAttributes": { 
	                        "class": "slds-text-heading_medium slds-hyphenate" 
	                    }
	            }],
                ["c:BT_VendorAdder",{
                    "aura:id": "vendorAdder",
                    "onCancel" : function(){
                        overlayLib.close();    
                    },
                    "savecallback":function(items){
                    	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                    	overlayLib.close();
                    	var selectedvendors = [];
						for(var i = 0; i < items.length; i++) {
							selectedvendors.push(items[i].Id);
						}
                    	helper.createVendorLink(component, event, helper, selectedvendors);
                    },
                    "parentId":component.get("v.recordId")
                }],
               
            ], function(contant, status) {
                if (status === "SUCCESS") {
                    component.find('overlayLib').showCustomModal({
                        header: contant[0],
                        body:  contant[1],
                        showCloseButton: true,
                        cssClass: 'uiModal--large'
                    }).then(function (overlay) {
	            	   overlayLib = overlay;
	               });
                    component.set("v.overlayLib",overlayLib);
                    $A.get('e.force:refreshView').fire();

                }
            }
        );
	
	},
	
	checkAll:function(component, event, helper){
		var allcheckbox = component.find("vendorselection");
		var vendorCheckall = component.find("vendorCheckall").get("v.checked");
		var vendorList = component.get("v.rfqToVendorList");
		if(vendorList.length > 0){
		    if(vendorList.length > 1){
    		    for(var i = 0; i < allcheckbox.length; i++) {
    		        if(vendorCheckall == true){
    		            allcheckbox[i].set("v.checked", vendorCheckall);    
    		        }else{
    		            allcheckbox[i].set("v.checked", false);
    		        }
        			//allcheckbox[i].set("v.checked", vendorCheckall);
        		}    
		    }else{
		        if(vendorCheckall == true){
		            allcheckbox.set("v.checked", true); 
		        }else{
		            allcheckbox.set("v.checked", false); 
		        }
		    }
		        
		}
		
	},
	
	compare:function(component, event, helper){
		$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
		component.set("v.IsOnLoad", false);
		var vendorList = component.get("v.rfqToVendorList");
		var selectedvendors = [];
		var allcheckbox = component.find("vendorselection");
		if(vendorList.length > 1){
		    for(var i = 0; i < allcheckbox.length; i++) {
    			console.log(allcheckbox[i].get("v.checked"));
    			if(allcheckbox[i].get("v.checked")){
    				selectedvendors.push(vendorList[allcheckbox[i].get("v.value")]);
    			}
    		}    
		}else{
		    if(allcheckbox.get("v.checked")){
				selectedvendors.push(vendorList[allcheckbox.get("v.value")]);
			}    
		}
		console.log(selectedvendors);
		
		if(selectedvendors.length > 0) { 
			
			component.set("v.selectedVendorList",selectedvendors);
			component.set("v.isCompare",true);
			component.set("v.showVendorActions",false);
			 $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
		}else {
			 var toastEvent = $A.get("e.force:showToast");
			 toastEvent.setParams({
		                "type":"error",
		                "title": "Error!",
		                "message": "Please Select Vendors"
		            });
		    toastEvent.fire();
		    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
		}
		
	},
        
    uploadFile1: function(component, event, helper) {
            $A.createComponents(
                [
                    ["aura:html", {
                        "tag": "h2",
                        "body": "Upload File",
                        "HTMLAttributes": { 
                            "class": "slds-text-heading_medium slds-hyphenate" 
                        }
                    }],
                    ["c:BT_AddFiles", {
                        "mainObjectFieldAPI": component.get("v.objectAPI"),
                        "mainObjectId": component.get("v.recordId"),
                        "selectedFiles": component.get("v.selectedFiles"),
                        "onCancel":function(){
                            component.get('v.modalPromise').then(function (modal) {
                                modal.close();
                            });
                            $A.get('e.force:refreshView').fire();
                        },
                        "onSuccess":function(file){
                            component.get('v.modalPromise').then(function (modal) {
                                modal.close();
                            });
                            
                            var selectedFiles = [];
    	                    for(var i=0; i<file.length; i++){
    	                        selectedFiles.push({
    	                            "Id" : file[i].Id,
    	                            "Name" : file[i].Name
    	                        });    
    	                    }
    	                    //alert('selectedFiles ---------> '+selectedFiles.length);
    			            //component.set("v.selectedFiles", selectedFiles);

                            var action;
                            action = component.get("c.linkRFQDocuments");
                            action.setParams({
                                "files" : selectedFiles,
                                "RFQid":component.get("v.recordId")
                            });
                            action.setCallback(this, function(response){
                                if(response.getState() === "SUCCESS"){
                                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                                    helper.getdata(component, event, helper);
                                    
                                }
                            });
                            $A.enqueueAction(action);
                            
                            $A.get('e.force:refreshView').fire();
                        }
                    }], 
                    
                ], function(components, status) {
                    if (status === 'SUCCESS') {
                        
                        var modalPromise = component.find('overlayLib').showCustomModal({
                            header: components[0],
                            body: components[1],
                            footer:components[1].find("footer") ,
                            showCloseButton: true,
                            closeCallback: function() {
                                
                            }
                        });
                        component.set("v.modalPromise", modalPromise);
                    }
                });
    },
    
    uploadFileToVendor: function(component, event, helper) {
    		var activeRFQVendor = component.get("v.activeRFQVendor");
            $A.createComponents(
                [
                    ["aura:html", {
                        "tag": "h2",
                        "body": "Upload File",
                        "HTMLAttributes": { 
                            "class": "slds-text-heading_medium slds-hyphenate" 
                        }
                    }],
                    ["c:BT_UploadFiles", {
                        "mainObjectFieldAPI": component.get("v.objectAPI"),
                        "mainObjectId": component.get("v.recordId"),
                        "onCancel":function(){
                            component.get('v.modalPromise').then(function (modal) {
                                modal.close();
                            });
                        },
                        "onSuccess":function(file){
                            component.get('v.modalPromise').then(function (modal) {
                                modal.close();
                            });

                            var action;
                            action = component.get("c.linkRFQDocumentToVendor");
                            action.setParams({
                                "fileId" : file.Id,
                                "vendorId":activeRFQVendor.Id
                            });
                            action.setCallback(this, function(response){
                                if(response.getState() === "SUCCESS"){
                                    $A.get("e.c:BT_SpinnerEvent").setParams({"action" : "SHOW" }).fire();
                                    helper.getdata(component, event, helper);
                                    
                                }
                            });
                            $A.enqueueAction(action);
                            
                            $A.get('e.force:refreshView').fire();
                        }
                    }], 
                    
                ], function(components, status) { 
                    if (status === 'SUCCESS') {
                        
                        var modalPromise = component.find('overlayLib').showCustomModal({
                            header: components[0],
                            body: components[1],
                            footer:components[1].find("footer") ,
                            showCloseButton: true,
                            closeCallback: function() {
                                
                            }
                        });
                        component.set("v.modalPromise", modalPromise);
                    }
                });
    }
	
})