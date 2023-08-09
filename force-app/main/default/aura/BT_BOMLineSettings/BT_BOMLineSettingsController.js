({
	 
    openSettingsModel: function(component, event, helper) {
        component.set("v.isSettingsOpen",true);  
        var action = component.get("c.getDefaultSettings");        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.Spinner", false);
                
               
                var result = response.getReturnValue();
                   
            
            //BOM LIne
            var TakeOffFieldsSettings =  result.BOMLineFieldSettings; 
            var TakeOffFieldsAvailableOptions = result.AvailableBOMLineOptions.sort((a, b) => {
                    let fa = a.label.toLowerCase(),
                    fb = b.label.toLowerCase();
                	//alert(fa);
                    if (fa < fb) {
                        return -1;
                    }
                    if (fa > fb) {
                        return 1;
                    }
                	return 0;
           		 })
            ;
            component.set("v.dualListboxBOMLineFieldsOptions",TakeOffFieldsAvailableOptions);   
            
            var TakeFieldsSelectedValues = []; 
        	/*TakeOffFieldsSettings.sort((a, b) => {
                    let fa = a.label.toLowerCase(),
                    fb = b.label.toLowerCase();
                    if (fa < fb) {
                        return -1;
                    }
                    if (fa > fb) {
                        return 1;
                    }
                	return 0;
           		 })*/
            
                for(var i in TakeOffFieldsSettings)    {
                    //alert(TakeOffFieldsSettings[i].value);
                    TakeFieldsSelectedValues.push(TakeOffFieldsSettings[i].value);
                }
                component.set("v.BOMLineFieldsSelectedValues",TakeFieldsSelectedValues);
            
 

			//BOM line filter
			 var TakeOffFieldsSettings =  result.BOMLineFilterFieldSettings; 
                var TakeOffFieldsAvailableOptions = result.AvailableBOMLineFilterOptions.sort((a, b) => {
                    let fa = a.label.toLowerCase(),
                    fb = b.label.toLowerCase();
               if (fa < fb) {
                    return -1;
                }
               if (fa > fb) {
                    return 1;
                }
                return 0;
                })
                ;
                component.set("v.dualListboxBOMLineFilterFieldsOptions",TakeOffFieldsAvailableOptions);   
            
            var TakeFieldsSelectedValues = []; 
        	/*TakeOffFieldsSettings.sort((a, b) => {
                    let fa = a.label.toLowerCase(),
                    fb = b.label.toLowerCase();
                    if (fa < fb) {
                        return -1;
                    }
                    if (fa > fb) {
                        return 1;
                    }
                	return 0;
           		 })*/
            
                for(var i in TakeOffFieldsSettings)    {
                    TakeFieldsSelectedValues.push(TakeOffFieldsSettings[i].value);
                }
                component.set("v.BOMLineFilterFieldsSelectedValues",TakeFieldsSelectedValues);
       
                
            }
        });
        $A.enqueueAction(action);
        
     },
    
    closeSettingsModel : function(component, event, helper){
        component.set("v.isSettingsOpen", false);
    },
    
    handleTakeOffFieldsChange: function (component, event) {
        var selectedOptionValues = event.getParam("value").toString();
        component.set("v.dualListboxTakeOffFieldsOptionsSelected",selectedOptionValues);
    },	
    
    handleProductFieldsChange: function (component, event) {
        var selectedOptionValues = event.getParam("value").toString();
        component.set("v.dualListboxProductFieldsOptionsSelected",selectedOptionValues);
    },
    
     handleBOMLineFieldsChange: function (component, event) {
        var selectedOptionValues = event.getParam("value").toString();
        component.set("v.dualListboxBOMLineFieldsOptionsSelected",selectedOptionValues);
    },
      
     handleTakeOffFilterFieldsChange: function (component, event) {
        var selectedOptionValues = event.getParam("value").toString();
        component.set("v.dualListboxTakeOffFilterFieldsOptionsSelected",selectedOptionValues);
    },	
    
    handleProductFilterFieldsChange: function (component, event) {
        var selectedOptionValues = event.getParam("value").toString();
        component.set("v.dualListboxProductFilterFieldsOptionsSelected",selectedOptionValues);
    },
    
     handleBOMLineFilterFieldsChange: function (component, event) {
        var selectedOptionValues = event.getParam("value").toString();
        component.set("v.dualListboxBOMLineFilterFieldsOptionsSelected",selectedOptionValues);
    },
        
    saveSettings : function(component,event,helper){
        component.set("v.SettingsSpinner",true);
         var FieldsSelectedValues2 = component.get("v.BOMLineFieldsSelectedValues").toString(); //CaseNumber,Category__c
         var FieldsSelectedValues5 = component.get("v.BOMLineFilterFieldsSelectedValues").toString(); //CaseNumber,Category__c
        
        if(  FieldsSelectedValues2=='') {
            //alert('Please Select Options in All Tabs');    
            component.set("v.SettingsSpinner", false);
            
            
            /*var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                title : 'Alert',
                message:'Please Select atleast one default Option in each Tab',
                duration:' 5000',
                key: 'info_alt',
                type: 'error',
                mode: 'pester'
            });
            toastEvent.fire();*/        
            
        }else {//111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111            
            var action = component.get("c.saveBOMSetting");
            action.setParams({
                'BOMLineFieldsSelectedValues' : FieldsSelectedValues2,
                'BOMLineFilterSelectedValues' : FieldsSelectedValues5
            }); 
            
            action.setCallback(this, function(response){
                var state = response.getState();
               // alert(state);
                if(state === "SUCCESS"){
                    var result = response.getReturnValue();                                       
                    
                    component.set("v.SettingsSpinner", false);
                    component.set("v.isSettingsOpen", false);    
                    component.set("v.isSettingsSaved", true);    
                     
                    
                     setTimeout(() => {
                   // alert("hello");
                    component.set("v.isSettingsSaved", false); 
                    component.set("v.isSettingsOpen", true); 
                }, 700);
                         
                         
                    //location.reload();
                    /*var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        title : 'Success',
                        message: 'Settings saved successfully!',
                        duration:' 3000',
                        key: 'info_alt',
                        type: 'success',
                        mode: 'pester'
                    });
                    toastEvent.fire();*/
                    
                    
                }
            });
            $A.enqueueAction(action);
            
            
            
        }
                         //111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111111
        
    },
    
})