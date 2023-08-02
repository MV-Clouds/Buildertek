({
    
    doInit : function(component, event, helper) {
        var recid = component.get("v.recordId");
        //var dismissActionPanel = $A.get("e.force:closeQuickAction");
        //dismissActionPanel.fire();
        
        var action = component.get("c.checkSignature");
        var recordId = component.get("v.recordId");
        action.setParams({
            recordId : component.get("v.recordId"),
            
        });
        
        action.setCallback(this, function (e) {
            //alert(e.getState());
            if (e.getState() == 'SUCCESS') {
                
                var result = e.getReturnValue();
               
                if(result.conver != null && result.conver != ''  && result.conver != undefined && result.stagename != "Fully Executed"){
                    /* var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/apex/buildertek__MSASite?id="+recid+"&bool=true"
                    });
                    urlEvent.fire();*/
                // setTimeout(function() {
                    var evt = $A.get("e.force:navigateToComponent");
                    evt.setParams({
                        componentDef : "c:MSAForm",
                        componentAttributes: {
                            recordId : recid,
                            disable : true
                           
                        }
                    });
                    evt.fire(); 
                //}, 30000);
                    
                    
                }else{
                    if(result.stagename == "Fully Executed"){
                        component.set("v.IsSignature",true);
                        component.set("v.message","This Vendor has already been Fully Executed."

);
                    }else if(result.conver == null || result.conver == '' || result.conver == undefined){
                         component.set("v.IsSignature",true);
                        component.set("v.message","You must Qualify the Account prior to executing the MSA.");
                    }
                    
                    
                    
                }
                
                
                
                
                
            }
        });
        $A.enqueueAction(action);
        
        
        
        
        
    },
    handleUploadFinished : function(component, event, helper) {
        var uploadedFiles = event.getParam("files");
        console.log('uploadedFiles ------>'+JSON.stringify(uploadedFiles));
        var documentIds = [];
        for(var i=0;i<uploadedFiles.length;i++){
            documentIds.push(uploadedFiles[i].contentVersionId);	    
        }
        component.set("v.documentIds", documentIds);
        helper.sendEmail(component, event, helper);
    },
    
    handleCancel : function(component, event, helper){
        component.set("v.showConfirmDialog",false);
        $A.get("e.force:closeQuickAction").fire()
    }
})