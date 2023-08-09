({
	init : function(component, event, helper) {
	    component.set("v.Spinner", true);
	    var dbAction = component.get("c.getTemplates");
	    dbAction.setParams({
	        recordId : component.get("v.recordId")
	    });
        dbAction.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                component.set("v.templates", response.getReturnValue());
                component.set("v.Spinner", false);
              //  alert(JSON.stringify(response.getReturnValue()));
              //  alert(response.getReturnValue()[0].Name);
                if(response.getReturnValue()[0].Name == 'Contract Template 1'){
                    component.set("v.Header",'Contract');
                }
                else{
                    component.set("v.Header",'Quote');
                }
                //component.set("v.selectedTemplate", response.getReturnValue()[0].Id);
            }
        });
        $A.enqueueAction(dbAction);   
	},
	
	preiewEmailTemplate : function(component, event, helper) {
	    component.set("v.Spinner", true);
	    var selectedTemplate = component.get("v.selectedTemplate");
	    //alert('selectedTemplate ----------> '+selectedTemplate);
	    if(selectedTemplate != undefined){
            component.set("v.isTemplateSelected", true);
            helper.getTemplateBody(component, event, helper);
            helper.getProposalImagesList(component, event, helper);
        }
        
        setTimeout(function(){
            var wrapper = document.getElementById("signature-pad");
                if(wrapper){
                        var canvas = wrapper.querySelector("canvas");
                        var signaturePad;
                    
                    // Adjust canvas coordinate space taking into account pixel ratio,
                    // to make it look crisp on mobile devices.
                    // This also causes canvas to be cleared.
                    function resizeCanvas() {
                        // When zoomed out to less than 100%, for some very strange reason,
                        // some browsers report devicePixelRatio as less than 1
                        // and only part of the canvas is cleared then.
                        var ratio =  Math.max(window.devicePixelRatio || 1, 1);
                        canvas.width = canvas.offsetWidth * ratio;
                        canvas.height = canvas.offsetHeight * ratio;
                        canvas.getContext("2d").scale(ratio, ratio);
                    }
                    
                    window.onresize = resizeCanvas;
                    resizeCanvas();
                    
                    window.signaturePad = new SignaturePad(canvas);  
                    
                    document.getElementById("btnClear").onclick=function(event){
                    event.preventDefault();
                    console.log(window.signaturePad);
                    window.signaturePad.clear();
                    }
                }
                component.set("v.Spinner", false);
            },3000);
	},
	
	closeModel : function(component, event, helper) {
	   $A.get("e.force:closeQuickAction").fire();    
	},
	
	sendEmail : function(component, event, helper){
	    component.set("v.Spinner", true);
	    var toIds = []; 
	    var ccIds = [];
	    var to = component.get("v.selectedToContact");
		var cc = component.get("v.selectedCcContact");
		to.forEach(function(v){ toIds.push(v.Id) });
		cc.forEach(function(v){ ccIds.push(v.Id) });
		if(toIds.length != 0){
	    var action = component.get("c.sendProposal"); 
	    action.setParams({
	        htmlBody : component.get("v.contractlines"), 
	        recordId : component.get("v.recordId"),
	        templateId : component.get("v.selectedTemplate"),
	        to : toIds,
            cc : ccIds,
	    });
	    action.setCallback(this, function(response){
	        var state = response.getState();
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
	            }else{
	                $A.get("e.force:closeQuickAction").fire();  
    	            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "type": 'error',
                        "message": result
                    });
                    toastEvent.fire();    
	            }
	            
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
	} ,
    
    acceptandSendMethodCall : function(component, event, helper){
       
        helper.acceptandsendemailhelper(component, event);
    },
	
	AcceptandsendEmail : function(component, event, helper){
	    component.set("v.Spinner", true);
         var toIds = []; 
	    var ccIds = [];
         var to = component.get("v.selectedToContact");
		var cc = component.get("v.selectedCcContact");
		to.forEach(function(v){ toIds.push(v.Id) });
		cc.forEach(function(v){ ccIds.push(v.Id) });
        if(toIds.length != 0){
        if(!signaturePad.isEmpty()){ 
        helper.AcceptSignature(component, event);
        }else{
             component.set("v.Spinner", false);
		    var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "title": "Error!",
                "type": 'error',
                "message": "Please Sign and Accept"
            });
            toastEvent.fire();   
        }
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
    
    Acceptandclose : function(component, event, helper){
        if(!signaturePad.isEmpty()){
            component.set("v.Spinner", true);
	    	helper.getuploadSignature(component, event); 
           
        }else{
             var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "title": "Error!",
            "type": 'error',
            "message": "Please Sign and Accept"
        });
        toastEvent.fire();
        }
        
        
	},

    preview : function(component, event, helper){
        try {
            component.set("v.Spinner", true);
            component.set("v.contractlines", '');
            component.set("v.selectedTemplate", "");
            component.set("v.isTemplateSelected", false);
            var dbAction = component.get("c.getTemplates");
            dbAction.setParams({
                recordId : component.get("v.recordId")
            });
            dbAction.setCallback(this, function (response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    component.set("v.templates", response.getReturnValue());
                    component.set("v.Spinner", false);
                    if(response.getReturnValue()[0].Name == 'Contract Template 1'){
                        component.set("v.Header",'Contract');
                    }
                    else{
                        component.set("v.Header",'Quote');
                    }
                }
            });
            $A.enqueueAction(dbAction);   
        } catch (error) {
            component.set("v.Spinner", false);
	        $A.get("e.force:closeQuickAction").fire();    
        }
    }
})