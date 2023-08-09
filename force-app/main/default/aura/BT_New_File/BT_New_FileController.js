({
	uploadFile : function(component, event, helper) {
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
	                    var selectedFiles = [];
	                    for(var i=0; i<file.length; i++){
	                        selectedFiles.push({
	                            "Id" : file[i].Id,
	                            "Name" : file[i].Name
	                        });    
	                    }
	                    //alert('selectedFiles ---------> '+selectedFiles.length);
			            component.set("v.selectedFiles", selectedFiles);
	                    $A.get('e.force:refreshView').fire();
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
	}
})