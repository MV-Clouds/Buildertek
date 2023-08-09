({
	getEmailSubmittal: function(component, event, helper){
	      var RecordId =  component.get("v.RecordId");
            var action = component.get("c.getEmailSubmittals");
            action.setParams({Id : RecordId})
            action.setCallback(this, function(response) {
                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result != null){
                       
                        if(result.length > 2){
                            result = JSON.parse(result);
                            component.set("v.objInfo",result);
                        }
                        else{
                            component.set("v.objInfo",null);
                        }
                    }
                    component.set("v.Spinner",false);
                }
            });
            $A.enqueueAction(action);
	},
	
	sendEmailSubmittal: function(component, event, helper){
	    component.set("v.Spinner", true);
	    var Submittals = component.get("v.objInfo");
	    //alert('Submittals ---------> '+JSON.stringify(Submittals));
	    var SubOptions = [];
	    for(var i=0 ; i < Submittals.length;i++){
	        //alert('Submittals[i].SubmittalCheck -------> '+Submittals[i].SubmittalCheck);
	        if(Submittals[i].SubmittalCheck == true){
	            SubOptions.push(Submittals[i].buildertekSubmittalRecord.Id+'-'+Submittals[i].selectedEmail);
	        }
	    }
	    //alert('SubOptions --> '+SubOptions);
	    if(SubOptions.length > 0){
	        component.set("v.selectedobjInfo",SubOptions);
	         //component.set("v.isOpen", false);
	         
	         var action = component.get("c.SendEmail");
	            action.setParams({Id : SubOptions})
                action.setCallback(this, function(response) {
                var state = response.getState();
                if (state === "SUCCESS") {
                    var result = response.getReturnValue();
                    if(result.success > 0){
                    component.set("v.message",result.success + ' Email Sent Successfully' );
                    component.set("v.type", 'success' );
                    component.set("v.color", '#3fda3fbd' );
                    }
                    if(result.fail > 0){
                        component.set("v.message",result.fail + ' Email Sent Failed' );
                        component.set("v.type", 'error' );
                        component.set("v.color", '#ef3232d1' );
                    }
                    if(result.error != ''){
                        component.set("v.message",result.error);
                        component.set("v.type", 'error' );
                        component.set("v.color", '#ef3232d1' );
                    }
                    window.setTimeout(function() {
                        component.set("v.Spinner", true);
                        component.set("v.message", '' );
	                    component.set("v.type", 'info' );
	                    component.set("v.color", 'white' );
	                    if(((result.success > 0 && result.error > 0) || (result.success > 0)) && result.error == ''){
    	                               // var url = location.href;
                                        // var baseURL = url.substring(0, url.indexOf('--', 0));
                                         var baseURL = component.get("v.BaseURLs");
                                        window.open(baseURL+'.lightning.force.com/lightning/r/'+escape(component.get("v.RecordId"))+'/related/buildertek__Submittals__r/view','_self');
                                        
                                    }
                                    component.set("v.Spinner", false);
                    },2000);
                    component.set("v.Spinner", false);
                }
            });
            $A.enqueueAction(action);
	    }
	    else{
	        component.set("v.message", 'Please Select atleast one Submittal' );
	        component.set("v.type", 'error' );
	        component.set("v.color", '#ef3232d1' );
	        component.set("v.Spinner", false);
	        window.setTimeout($A.getCallback(function() {
	            component.set("v.message", '' );
	            component.set("v.type", 'info' );
	            component.set("v.color", 'white' );
                        
            }),5000);
	    }
	}
})