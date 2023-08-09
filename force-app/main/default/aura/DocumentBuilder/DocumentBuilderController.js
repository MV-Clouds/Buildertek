({
	doInit : function(component, event, helper) {
		
	},
    
    Generatedocument: function(component, event, helper) {
    
	},
	
	SendEmail: function(component, event, helper) {
		$A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": component.get("v.title"),
                    "HTMLAttributes": { 
                        "class": "slds-text-heading_medium slds-hyphenate" 
                    }
                }],
                ["c:BT_SendEmail", {
                    "objectAPI":component.get("v.objectAPI"),
                    "recordId":component.get("v.recordId"),
                    "templatefolderName": component.get("v.foldername"),
                    "pdfFileName":component.get("v.pdfFileName"),
                    "onSuccess": function() {
                    	 component.get('v.modalPromise').then(function (modal) {
	                        modal.close();
	                    }); 
	                    var showToast = $A.get("e.force:showToast"); 
						showToast.setParams({ 
							'title' : '', 
							'message' : 'Email Sent Sucessfully.',
							'type' : 'success'
						}); 
						showToast.fire(); 
                        
                    },
                    "onCancel": function() {
                    	 component.get('v.modalPromise').then(function (modal) {
	                        modal.close();
	                    });
                    }
                }], 
                
            ], function(components, status) {
                if (status === 'SUCCESS') {
                    
                    var modalPromise = component.find('overlayLib').showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer:components[1].find("footer") ,
                        showCloseButton: true,
                        cssClass: 'slds-modal_medium',
                        closeCallback: function() {
                            
                        }
                    });
                    component.set("v.modalPromise", modalPromise);
                }
            });
	}
})