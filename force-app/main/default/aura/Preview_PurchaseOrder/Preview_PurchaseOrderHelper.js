({
	getTemplateBody : function(component, event, helper) {
        var recordId = component.get("v.recordId");
	    var action = component.get("c.getPurchaseOrderLines");
	    action.setParams({
	        recordId : recordId,
	        templateId : component.get("v.selectedTemplate")
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
	        if(state === "SUCCESS"){
	            var result =  response.getReturnValue();
	            component.set("v.purchaseOrderLines", result);
	        }
	    });
	    $A.enqueueAction(action);
	},
	
		
	 getuploadSignature : function(component, event){
	    component.set("v.parentId",component.get("v.recordId")); 
        var recId= component.get("v.parentId");
         
        var signName = component.get("v.SignatureName");
        var signatureaction = component.get("c.saveSign");
        var toastEvent = $A.get('e.force:showToast');
        var vSplit = document.getElementById("divsign").toDataURL().split(',')[1]; 
        
        signatureaction.setParams({                                  
            base64Data:encodeURIComponent(vSplit),
            contentType:"image/png",
            recId : recId,
            signName: signName,
        });
        signatureaction.setCallback(this, function(e) {          
            if(e.getState()=='SUCCESS'){
                 var result =  e.getReturnValue();
                component.set("v.Spinner", false);
	           component.set("v.fileimageId", result); 
              var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": 'success',
                    "message": "Signature Saved Successfully"
                });
                toastEvent.fire();
               $A.get("e.force:closeQuickAction").fire();
	           // location.reload();
              
            }
            else{
                alert(JSON.stringify(e.getError()));
            }
        });
        $A.enqueueAction(signatureaction); 
        
    },
    
    getRejectAndClose : function(component, event){
	    component.set("v.parentId",component.get("v.recordId")); 
        var recId= component.get("v.parentId");
         
        var signName = component.get("v.SignatureName");
        var signatureaction = component.get("c.rejectSign");
        var toastEvent = $A.get('e.force:showToast');
        var vSplit = document.getElementById("divsign").toDataURL().split(',')[1]; 
        
        signatureaction.setParams({                                  
            base64Data:encodeURIComponent(vSplit),
            contentType:"image/png",
            recId : recId,
            signName: signName,
            rejectionReason : component.get('v.rejectReason')
        });
        signatureaction.setCallback(this, function(e) {          
            if(e.getState()=='SUCCESS'){
                 var result =  e.getReturnValue();
                component.set("v.Spinner", false);
	           component.set("v.fileimageId", result); 
              var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": 'success',
                    "message": "Signature Saved Successfully"
                });
                toastEvent.fire();
               $A.get("e.force:closeQuickAction").fire();
	           // location.reload();
              
            }
            else{
                alert(JSON.stringify(e.getError()));
            }
        });
        $A.enqueueAction(signatureaction); 
        
    },
    
     acceptandsendemailhelper : function(component, event){
        
        
         var toIds = []; 
	    var ccIds = [];
	    var to = component.get("v.selectedToContact");
		var cc = component.get("v.selectedCcContact");
		 var signid = component.get("v.fileimageId");
		to.forEach(function(v){ toIds.push(v.Id) });
		cc.forEach(function(v){ ccIds.push(v.Id) });
		var subject = 'PurchaseOrder[ref:'+component.get("v.recordId")+']';
		if(toIds.length != 0){
		    
		    var action = component.get("c.acceptandsendProposal"); 
    	    action.setParams({
    	        htmlBody : component.get("v.purchaseOrderLines"),
    	        recordId : component.get("v.recordId"),
    	        templateId : component.get("v.selectedTemplate"),
    	        to : toIds,
                cc : ccIds,
                Emailsubject :subject,
                fileid: signid,
    	    });
    	    action.setCallback(this, function(response){
    	        var state = response.getState();
    	        //var subject = 'PurchaseOrder[ref:'+component.get("v.recordId")+']'; 
    	        if(state === "SUCCESS"){
    	            var result = response.getReturnValue();
    	            if(result === 'Success'){
    	                component.set("v.Spinner", false);
        	            $A.get("e.force:closeQuickAction").fire();  
        	            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "title": "Success!",
                            "type": 'success',
                            "message": "Email Sent Successfully"
                        });
                        toastEvent.fire();
                       // location.reload();
                         /* var taskaction = component.get("c.createTask");
    		              taskaction.setParams({
    		                "whatId" : component.get("v.recordId"),
    		                "emailSubject" : subject
    		            });
    		            $A.enqueueAction(taskaction);*/
    	            }else{
    	                $A.get("e.force:closeQuickAction").fire();  
        	            var toastEvent = $A.get("e.force:showToast");
                        toastEvent.setParams({
                            "type": 'error',
                            "message": result
                        });
                        toastEvent.fire();    
    	            }
    	            $A.get('e.force:refreshView').fire();
    	        }
    	    });
    	    $A.enqueueAction(action);    
		}else{
		    component.set("v.Spinner", false);
		    var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": "Please select To Address to send Email"
            });
            toastEvent.fire();    
		}
        
      },
    
     AcceptSignature : function(component, event){
	    component.set("v.parentId",component.get("v.recordId")); 
        var recId= component.get("v.parentId");
         
        var signName = component.get("v.SignatureName");
        var signatureaction = component.get("c.saveSign");
        var toastEvent = $A.get('e.force:showToast');
        var vSplit = document.getElementById("divsign").toDataURL().split(',')[1]; 
        
        signatureaction.setParams({                                  
            base64Data:encodeURIComponent(vSplit),
            contentType:"image/png",
            recId : recId,
            signName: signName,
        });
        signatureaction.setCallback(this, function(e) {          
            if(e.getState()=='SUCCESS'){
                 var result =  e.getReturnValue();
               
	           component.set("v.fileimageId", result);
                setTimeout(
                    function(){ 
                      component.acceptandSendMethod();
                    }, 1000);
                
                
             /* var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "type": 'success',
                    "message": "Signature Saved Successfully"
                });
                toastEvent.fire();*/
              
              
            }
            else{
                alert(JSON.stringify(e.getError()));
            }
        });
        $A.enqueueAction(signatureaction); 
        
    },
    
    rejectSignature : function(component, event){
	    component.set("v.parentId",component.get("v.recordId")); 
        var recId= component.get("v.parentId");
         
        var signName = component.get("v.SignatureName");
        var signatureaction = component.get("c.rejectionWithReason");
        var toastEvent = $A.get('e.force:showToast');
        var vSplit = document.getElementById("divsign").toDataURL().split(',')[1]; 
        var rejectionReason = component.get('v.rejectReason');
		
        signatureaction.setParams({                                  
            base64Data : encodeURIComponent(vSplit),
            contentType : "image/png",
            recId : recId,
            signName : signName,
            rejectionReason : component.get('v.rejectReason')		
        });
        signatureaction.setCallback(this, function(e) {          
            if(e.getState()=='SUCCESS'){
                 var result =  e.getReturnValue();
               
	           component.set("v.fileimageId", result);
                setTimeout(
                    function(){ 
                      component.acceptandSendMethod();
                    }, 1000);
            }
            else{
                alert(JSON.stringify(e.getError()));
            }
        });
        $A.enqueueAction(signatureaction); 
    },

    // handleUploadFinishedHelper : function(component, event, helper){
    //     var uploadedFiles = event.getParam("files");
    // }
	
	
})