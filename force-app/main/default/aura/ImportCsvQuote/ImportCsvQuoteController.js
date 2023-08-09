({  
    save : function(component, event, helper) {
        helper.save(component, helper);     
    },
    closeModel : function(component, event, helper){
	    $A.get("e.force:closeQuickAction").fire();    
	},
    
    onSelectFileHandler : function(component,event,helper){
        try{
        console.log('onfile select');
        var MAX_FILE_SIZE = 750000; 
        var fileInput = component.find("file").getElement();
        var file = fileInput.files[0];
        // var file = event.getSource().get("v.files")[0];
        console.log('file1 =: ', file);
        
        
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
                //  $A.util.addClass(component.find("btn").getElement(), "slds-hide");
                //  $A.util.removeClass(component.find("btn").getElement(), "slds-show");
                 component.set("v.selectedFile",file.name);
                 component.set("v.isSelect",true);
             }
             
         } 
        } catch(error){
            console.log('error => ', {error})
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