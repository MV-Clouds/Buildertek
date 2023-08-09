({
	doInit : function(component, event, helper) {
       
        var action =component.get("c.getObjectName");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {   
                var options = [];
                var allValues = response.getReturnValue();
                console.log(JSON.stringify(allValues));
                for(var i=0;i<allValues.length;i++){
                    options.push({
                        "label" : allValues[i].objectLabel,
                        "value" : allValues[i].objectName
                    });    
                }
                component.set("v.results", options);
              
            }                
        });
        $A.enqueueAction(action);
        
		
        helper.helperMethod(component, event, helper);
	},
    afterSelect : function(component, event, helper) {
    	if(component.get("v.ChecklistName") !=undefined && component.get("v.ChecklistName") !='') {
            component.set("v.isRelatedToError",false);
        }
 	},
      searchAll : function (component, event, helper) {
        var showButton = component.get("v.showButton");
        if(showButton == true){
            component.set("v.showButton", false);	    
        }
        component.set("v.openDropDown", true);
    },
    searchHandler : function (component, event, helper) {
        helper.search(component, event, helper);
    },
     optionClickHandler : function (component, event, helper) {
        const selectedValue = event.target.closest('li').dataset.value;
        const ObjectLabel = event.target.closest('li').dataset.label;
    
         component.set("v.selected",selectedValue);
         component.set("v.ObjectLabel",ObjectLabel);
        component.set("v.showButton", true);
         component.set("v.openDropDown", false);
        
    },
    
    createChecklistObject : function(component, event, helper) {
       var action =component.get("c.getObjectName");
        action.setCallback(this, function(response){
            var state = response.getState();
            if (state === "SUCCESS") {   
                var options = [];
                var allValues = response.getReturnValue();
                console.log(JSON.stringify(allValues));
                for(var i=0;i<allValues.length;i++){
                    options.push({
                        "label" : allValues[i].objectLabel,
                        "value" : allValues[i].objectName
                    });    
                }
                component.set("v.results", options);
              
            }                
        });
        $A.enqueueAction(action); 

       component.set("v.Spinner",true);
      helper.helperMethod(component, event, helper);
        //component.set("v.isShowTable",false);
        component.set("v.isShowCreatepage",true);
        component.set("v.Spinner",false);
    },
     callDeleteRecord : function(component, event, helper) {
      
       component.set("v.deleterecord",event.currentTarget.title);
       component.set('v.showConfirmDialog', true);  
	},
    saveConfigureBack : function(component, event, helper) {
      //  component.set("v.isShowTable",true);
         component.set("v.isShowCreatepage",false);
        $A.get('e.force:refreshView').fire();
    },
    saveChecklistObject :  function(component, event, helper) {
        debugger;
        var label = component.get("v.ObjectLabel");
        var apiname = component.get("v.selected");
        var errormsg = false;
        component.set("v.Spinner",true);
         
       if(apiname == undefined || apiname == ''){
            errormsg = true;
            component.set("v.isObjectAPIError",true);
            var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title: '',
                        message: 'Please select an object.',
                        duration: "5000",
                        key: "info_alt",
                        type: "error",
                        mode: "pester",
                    });
                    toastEvent.fire();
           component.set("v.Spinner",false);
       }else{
           component.set("v.isObjectAPIError",false);
           
       }
       if(errormsg == false){
           component.set("v.Spinner",true);
         var action =component.get("c.saveChecklistControllerRecord");
        action.setParams({
            "APIName" : apiname,
            "LabelName" : label
        });
        action.setCallback(this, function(a){
            
            if (a.getState() === "SUCCESS") {
                var result = a.getReturnValue();
                 component.set("v.Spinner",false);
                helper.helperMethod(component, event, helper);
                 component.set("v.isShowTable",true);
                  component.set("v.isShowCreatepage",false);
                if(result == 'SUCCESS'){
                     var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "Checklist Object Created Successfully.",
                                "type":"success"
                            });
                toastEvent.fire();
                }else if(result == 'ERROR'){
                     var toastEvent = $A.get("e.force:showToast");
                            toastEvent.setParams({
                                "title": "Success!",
                                "message": "This Object is already created",
                                "type":"error"
                            });
                toastEvent.fire();
                    
                }
                //component.sampleMethod();
            }
            component.set("v.ObjectLabel","");
            component.set("v.selected","");
        });
        $A.enqueueAction(action);
          //window.location.reload(); 
         }
    },
    
    handleConfirmDialog : function(component, event, helper) {
        component.set('v.showConfirmDialog', true);
    },
     
    handleConfirmDialogYes : function(component, event, helper) {
        
         var action = component.get("c.deleterecord");
         action.setParams({
            "recId" : component.get("v.deleterecord"),
        });
         action.setCallback(this, function(a){
             
            if (a.getState() === "SUCCESS") {
                component.sampleMethod();
                var toastEvent = $A.get("e.force:showToast");
                toastEvent.setParams({
                    "title": "Success!",
                    "message": "Checklist Object Deleted Successfully",
                    "type":"success"
                });
                toastEvent.fire();
                
               
                
                component.set("v.isEditrecord",false);
                component.set("v.isEditrecord",true);
                component.set('v.showConfirmDialog', false);
            }
        });
        $A.enqueueAction(action);
       //$A.get('e.force:refreshView').fire();  
    },
     
    handleConfirmDialogNo : function(component, event, helper) {
        console.log('No');
        component.set('v.showConfirmDialog', false);
    },
})