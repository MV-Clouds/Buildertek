({
	doInit : function(component, event, helper) {
        helper.doChecklistHelper(component, event, helper);
		var action = component.get("c.getTSettings");
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set("v.bTSettings", result);
            }   
        });
        $A.enqueueAction(action);
	},
    
    edit : function(component, event, helper) {
        component.set("v.isEdit", true);
    },
    
    save : function(component, event, helper) {
    	var action = component.get("c.saveSettings");
        action.setParams({
            bTSettings : component.get("v.bTSettings")   
        });
        action.setCallback(this, function(response){
             //alert(response.getState());
            if(response.getState() === 'SUCCESS'){
               
            	component.set("v.isEdit", false);
                component.set("v.isSettingsSaved", true);    
                setTimeout(() => {
                   // alert("hello");
                    component.set("v.isSettingsSaved", false);    
                }, 1000);
               // $A.enqueueAction(component.get("c.doInit"));  
            }    
        });
        $A.enqueueAction(action);
    },
    
    cancel : function(component, event, helper) {
    	component.set("v.isEdit", false);    
    },
    handleClose: function(component, event, helper) {
        	component.set("v.isWarning", false);    
    },
    
    handleFilesChange: function(component, event, helper) {
        var fileName = 'No File Selected..';
        //alert(event.getSource().get("v.files").length);
        if (event.getSource().get("v.files").length > 0) {
            fileName = event.getSource().get("v.files")[0]['name'];
        }
        component.set("v.fileName", fileName);        
    },
    
    doSave: function(component, event, helper) {
        if (component.find("fileId").get("v.files") != undefined) {
            if(component.find("fileId").get("v.files").length > 0){
                helper.uploadHelper(component, event);
                
            }
            else{
                component.set("v.isWarning", true);    
                setTimeout(() => {
                    //alert("hello");
                    component.set("v.isWarning", false);    
                }, 2000);
                /*var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Error!",
                    "message": "Please Select a Valid File.",
                    "type":"error"
                });
                toastEvent.fire();*/
            }
            
        } else {
            component.set("v.isWarning", true);    
                setTimeout(() => {
                    //alert("hello");
                    component.set("v.isWarning", false);    
                }, 2000);

            /*var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "message": "Please Select a Valid File.",
                "type":"error"
            });
            toastEvent.fire();*/
        }
        var action =component.get("c.getAttachmentData");
             action.setParams({
                 "recordId" : component.get("v.recordId")
            });
             action.setCallback(this,function(a){
                if(a.getState()==='SUCCESS'){                    
                    var result = a.getReturnValue();
                     component.set("v.imgUrl",component.get("v.siteUrl")+"servlet/servlet.FileDownload?file="+result);
                   // $A.get('e.force:refreshView').fire();
                  }
            });
            $A.enqueueAction(action); 
               
    },
    
})