({
    doInit : function(component, event, helper) {
        var fileId = component.get("v.fileId");
    	var action = component.get("c.getFileData"); 
        action.setParams({
            contentDocumentId : fileId
        });
        action.setCallback(this, function(response){
         	component.set("v.pdfData", response.getReturnValue());  
            helper.loadpdfData(component, event);
        });
        $A.enqueueAction(action);
    },
    loadpdf : function(component, event, helper) {
		helper.loadpdfData(component, event);	
	}
})