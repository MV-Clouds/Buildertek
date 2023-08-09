({
	addNewPOLine : function(component, event, helper) {
		$A.createComponents(
            [
                ["aura:html", {
                    "tag": "h2",
                    "body": "New Purchase Order Line",
                    "HTMLAttributes": { 
                        "class": "slds-text-heading_medium slds-hyphenate" 
                    }
                }],
                ["c:BT_New_Purchase_Order_Override", {
                    "mainObjectFieldAPI": component.get("v.objectAPI"),
                    "mainObjectId": component.get("v.recordId"),
                    "onCancel":function(){
                         //alert('hi DFL');
                         //$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                    	 component.get('v.modalPromise').then(function (modal) {
	                        modal.close();
	                    });
	                    $A.get('e.force:refreshView').fire();
                    },
                    "onSuccess":function(file){
                        //alert('hi');
                    	$A.get("e.c:BT_SpinnerEvent").setParams({"action" : "HIDE" }).fire();
                    	 component.get('v.modalPromise').then(function (modal) {
	                        modal.close();
	                    });
	                    $A.get('e.force:refreshView').fire();
	                    var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            mode: 'sticky',
                            message: 'Purchase Order Line was created',
                            type : 'success',
                            duration: '10000',
                            mode: 'dismissible'
                        });
                        toastEvent.fire();
                    }
                }], 
                
            ], function(components, status) {
                if (status === 'SUCCESS') {
                    
                   var modalPromise = component.find('overlay').showCustomModal({
                        header: components[0],
                        body: components[1],
                        footer:components[1].find("footer") ,
                        showCloseButton: true,
                        cssClass: '',
                        closeCallback: function() {
                            
                        }
                    });
                    component.set("v.modalPromise", modalPromise);
                }
            });
	},
	
})