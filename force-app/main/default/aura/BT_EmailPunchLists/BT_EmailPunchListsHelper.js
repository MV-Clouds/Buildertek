({
	getEmailPunchLists: function(component, event, helper){
	      var RecordId =  component.get("v.RecordId");
            var action = component.get("c.getPunchLists");
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
	
	sendEmailPunchLists: function(component, event, helper){
	    var punchLists = component.get("v.objInfo");
	    //alert('punchLists --------> '+JSON.stringify(punchLists));
	    var SubOptions = [];
	    for(var i=0 ; i < punchLists.length;i++){
	        if(punchLists[i].punchListCheck == true){
	            SubOptions.push(punchLists[i].buildertekPunchlistRecord.Id+'-'+punchLists[i].selectedEmail);
	        }
	    }
	    
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
                        component.set("v.message", '' );
	                    component.set("v.type", 'info' );
	                    component.set("v.color", 'white' );
	                    if(((result.success > 0 && result.error > 0) || (result.success > 0)) && result.error == ''){
                            var baseURL = component.get("v.BaseURLs");
                            window.open(baseURL+'.lightning.force.com/lightning/lightning/r/'+escape(component.get("v.RecordId"))+'/related/buildertek__Punch_Lists__r/view','_self');
                            
                                    
	                    }
                    },2000);
                }
            });
            $A.enqueueAction(action);
	    }
	    else{
	        component.set("v.message", 'Please Select atleast one PunchList' );
	        component.set("v.type", 'error' );
	        component.set("v.color", '#ef3232d1' );
	        window.setTimeout($A.getCallback(function() {
	            component.set("v.message", '' );
	            component.set("v.type", 'info' );
	            component.set("v.color", 'white' );
                        
            }),2000);
	    }
	}
})