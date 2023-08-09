({
	doInit : function(component, event, helper) {  
	   // alert(component.get("v.recordId"));
        document.title = "Project Scheduler";
        component.set("v.showSpinner", true);
        //helper.getPermission(component);

        component.set("v.displayView","workorder");
        component.set("v.showSpinner", false);
       
	},
    
    changeComponent : function(component, event, helper) { 
        var whichOne = event.getSource().getLocalId();
        component.set("v.showSpinner", true);
        component.set("v.displayView",whichOne);
        component.set("v.showSpinner", false);
       
	},
	
	
	 openpopup : function(component,event,helper){
        component.set("v.isOpen",true);
    },
    
    SaveService : function(component,event,helper){
             //alert(component.get("v.Subject"));
            // alert(component.get("v.DateSelected"))
        	 if(component.get("v.ServiceRequestRecord") != '' && component.get("v.Subject") != '' && component.get("v.SerProjectId") != ''){
        	     component.set("v.showSpinner",true);
        	     var action = component.get("c.CreateServiceRequest"); 
        		  action.setParams({
                      Datevalue : component.get("v.DateSelected"),
                      ProjectId : component.get("v.SerProjectId"),
                      ContactId : component.get("v.ServiceRequestRecord"),
                      Description : component.get("v.SerDescription"),
                      PrimaryAssign : component.get("v.SerPrimaryAssignee"),
                      Subject : component.get("v.Subject"),
                      Timevalue : component.get("v.Timevalue")
                    
                    }); 
                 action.setCallback(this, function(a) { 
                        var state = a.getState(); 
                        //alert(state + ' ' + a.getReturnValue());
                        if (state == "SUCCESS") { 
                            var result = a.getReturnValue();
                            if(result == 'Success'){
                              component.set("v.message",'Service Request Created Successfully' );
                                component.set("v.type", 'success' );
                                component.set("v.color", '#3fda3fbd' );
                                component.set("v.showSpinner",false);
                                window.setTimeout($A.getCallback(function() {
                                    
                    	            component.set("v.message", '' );
                    	            component.set("v.type", 'info' );
                    	            component.set("v.color", 'white' );
                                    component.set("v.isOpen", false); 
                                    component.set("v.Subject",'');
                                    component.set("v.SerDescription",'');
                                    component.set("v.SerPrimaryAssignee",'');
                                    component.set("v.ServiceRequestRecord",'');	
                                    component.set("v.SerProjectId",'');
                                    component.set("v.Timevalue",'');
                                    component.set("v.showSpinner",false);
                                  //  $A.get('e.force:refreshView').fire();
                                    component.reInit();
                                    
                                }),2000);
                                
                            }
                            else{
                                component.set("v.showSpinner",false);
                                component.set("v.message",'Service Request Not Created' );
                                component.set("v.type", 'error' );
                                component.set("v.color", '#ef3232d1' );
                                window.setTimeout($A.getCallback(function() {
                    	            component.set("v.message", '' );
                    	            component.set("v.type", 'info' );
                    	            component.set("v.color", 'white' );    
                                }),5000);
                             //alert(result);
                            }
                          // component.find("atcmplbox").set("v.value", a.getReturnValue());
                        }
            	    });
                   
            	    $A.enqueueAction(action);
        	 }
        	 else{
        	     component.set("v.showSpinner",false);
        	     component.set("v.message", 'Customer Name and Subject are required' );
        	        component.set("v.type", 'error' );
        	        component.set("v.color", '#ef3232d1' );
        	        window.setTimeout($A.getCallback(function() {
        	            component.set("v.message", '' );
        	            component.set("v.type", 'info' );
        	            component.set("v.color", 'white' );
                                
                    }),5000);
        	 }
    },
    
    closeModel: function(component, event, helper) {
      // for Hide/Close Model,set the "isOpen" attribute to "Fasle"  
      component.set("v.isOpen", false);
   },
 
   
   
    handleComponentEvent : function(component, event, helper) {
      //  alert('Hiiii');
        var selectedAccountGetFromEvent = event.getParam("recordByEvent"); 
        var objectType = event.getParam("recordByEventstring");
     //   alert(objectType);
        
        if(selectedAccountGetFromEvent.Id != undefined){
            if(objectType == 'Contact'){
                component.set("v.ServiceRequestRecord",selectedAccountGetFromEvent.Id);	
            }
            else{
                component.set("v.SerProjectId",selectedAccountGetFromEvent.Id);	
            }
        }
        else{
            if(objectType == 'Contact'){
                component.set("v.ServiceRequestRecord",'');	
            }
            else{
                component.set("v.SerProjectId",'');	    
            }
        }
    },
    
    
   
    
})