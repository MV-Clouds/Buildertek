({  
    doInit : function(component, event, helper) {
        helper.Check_Create_User_Access(component, event, helper);
    },
    save : function(component, event, helper) {
        if(component.get("v.HaveCreateAccess")){
            helper.save(component, helper);     
        }
        else{
            var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "type": "error",
                    "title": "Error!",
                    "message": 'You don\'t have the necessary privileges to create this record.'
                });
                toastEvent.fire();
        }
    },
    closeModel : function(component, event, helper){
	    $A.get("e.force:closeQuickAction").fire();    
	},
    
    onSelectFileHandler : function(component,event,helper){
        console.log('onfile select');
        var MAX_FILE_SIZE = 750000; 
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        
        
         if(file != undefined){
             if (file.size > MAX_FILE_SIZE) {
                 helper.showToast(component, "warning", 'File size cannot exceed ' + MAX_FILE_SIZE + ' bytes.\n' +
                      'Selected file size: ' + file.size);
                 return;
             }
             var re = /(?:\.([^.]+))?$/;
             var ext = re.exec(file.name)[1];
             if(ext!='csv'){
                 helper.showToast(component, "warning",'Please Select .csv file.'); 
             }else{
                 $A.util.addClass(component.find("btn").getElement(), "slds-hide");
                 $A.util.removeClass(component.find("btn").getElement(), "slds-show");
                 component.set("v.selectedFile",file.name);
                 component.set("v.isSelect",true);
             }
             
         } 
       
    },
    handleRemove :function(component,event,helper){
        component.set("v.selectedFile",'');
        component.set("v.isSelect",false);
        $A.util.addClass(component.find("btn").getElement(), "slds-show");
        $A.util.removeClass(component.find("btn").getElement(), "slds-hide"); 
        component.find("file").getElement().value='';
    },
    /*
    waiting: function(component, event, helper) {
        component.set("v.Spinner",true);
    	$A.util.addClass(component.find("uploading").getElement(), "uploading");
    	$A.util.removeClass(component.find("uploading").getElement(), "notUploading");
    },
    
    doneWaiting: function(component, event, helper) {
        component.set("v.Spinner",false);
    	$A.util.removeClass(component.find("uploading").getElement(), "uploading");
    	$A.util.addClass(component.find("uploading").getElement(), "notUploading");
    }, */
})