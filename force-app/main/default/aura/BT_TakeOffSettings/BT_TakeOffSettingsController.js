({
	 
    openSettingsModel: function(component, event, helper) {
        component.set("v.isSettingsOpen",true);  
        var action = component.get("c.getDefaultSettings");        
        action.setCallback(this, function(response){
            var state = response.getState();
            if(state === "SUCCESS"){
                component.set("v.Spinner", false);
                
               
                var result = response.getReturnValue();
                
                var TakeOffFieldsSettings =  result.TakeOffFieldSettings; 
                var TakeOffFieldsAvailableOptions = result.AvailableOptions.sort((a, b) => {
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
                
                
                //alert(JSON.stringify(TakeOffFieldsAvailableOptions));
                //alert(JSON.stringify(TakeOffFieldsSettings));
                
                
                
                
                //Take Off AvailableOptions and Selected Values
                /*var CaseFieldsAvailableOptions = [              
                                                        { label: 'Case Number', value: 'CaseNumber' },
                                                        { label: 'Category', value: 'Category__c' },
                                                        { label: 'Priority', value: 'Priority' },
                                                        { label: 'Status', value: 'Status' }
                                                  ];  // sample format of fieldnames from case object
                                                  */
                component.set("v.dualListboxTakeOffFieldsOptions",TakeOffFieldsAvailableOptions);   
                
                var TakeFieldsSelectedValues = [];  //["CaseNumber","Category__c"]; // not labels, must be value 
                //generating list with values for Case Fields
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
            
            for(var i in TakeOffFieldsSettings)        
            {
                TakeFieldsSelectedValues.push(TakeOffFieldsSettings[i].value);
            }
            
            
            component.set("v.TakeOffFieldsSelectedValues",TakeFieldsSelectedValues);
            //End generating list with values for Case Fields                                            
            
            //End Take Off AvailableOptions and Selected Values
            
            
            
            //Product 
            var TakeOffFieldsSettings =  result.ProductFieldSettings; 
            var TakeOffFieldsAvailableOptions = result.AvailableProductOptions.sort((a, b) => {
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
            
            component.set("v.dualListboxProductFieldsOptions",TakeOffFieldsAvailableOptions);   
            
            var TakeFieldsSelectedValues = [];  //["CaseNumber","Category__c"]; // not labels, must be value 
            //generating list with values for Case Fields
           /* TakeOffFieldsSettings.sort((a, b) => {
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
            
            for(var i in TakeOffFieldsSettings)        
            {
                TakeFieldsSelectedValues.push(TakeOffFieldsSettings[i].value);
            }
            component.set("v.ProductFieldsSelectedValues",TakeFieldsSelectedValues);
            //End generating list with values for Case Fields                                            
            
            //End Take Off AvailableOptions and Selected Values
            
            
            
            //BOM LIne
            var TakeOffFieldsSettings =  result.BOMLineFieldSettings; 
            var TakeOffFieldsAvailableOptions = result.AvailableBOMLineOptions.sort((a, b) => {
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
                    TakeFieldsSelectedValues.push(TakeOffFieldsSettings[i].value);
                }
                component.set("v.BOMLineFieldsSelectedValues",TakeFieldsSelectedValues);
            
           //takeoff filter
                var TakeOffFieldsSettings =  result.TakeoffFilterFieldSettings; 
                var TakeOffFieldsAvailableOptions = result.AvailableTakeoffFilterOptions.sort((a, b) => {
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
                component.set("v.dualListboxTakeOffFilterFieldsOptions",TakeOffFieldsAvailableOptions);   
            
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
                component.set("v.TakeOffFilterFieldsSelectedValues",TakeFieldsSelectedValues);
               

			//Product filter
                var TakeOffFieldsSettings =  result.ProductFilterFieldSettings; 
                var TakeOffFieldsAvailableOptions = result.AvailableProductFilterOptions.sort((a, b) => {
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
                component.set("v.dualListboxProductFilterFieldsOptions",TakeOffFieldsAvailableOptions);   
            
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
                component.set("v.ProductFieldsFilterSelectedValues",TakeFieldsSelectedValues);
       

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
        
        var FieldsSelectedValues = component.get("v.TakeOffFieldsSelectedValues").toString(); //CaseNumber,Category__c
        //alert(JSON.stringify(FieldsSelectedValues));
         var FieldsSelectedValues1 = component.get("v.ProductFieldsSelectedValues").toString(); //CaseNumber,Category__c      
         var FieldsSelectedValues2 = component.get("v.BOMLineFieldsSelectedValues").toString(); //CaseNumber,Category__c
        
        var FieldsSelectedValues3 = component.get("v.TakeOffFilterFieldsSelectedValues").toString(); //CaseNumber,Category__c
        //alert(JSON.stringify(FieldsSelectedValues));
         var FieldsSelectedValues4 = component.get("v.ProductFieldsFilterSelectedValues").toString(); //CaseNumber,Category__c      
         var FieldsSelectedValues5 = component.get("v.BOMLineFilterFieldsSelectedValues").toString(); //CaseNumber,Category__c
        
        if(  FieldsSelectedValues=='') {
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
                'BOMFieldsSelectedValues': FieldsSelectedValues	,
                'ProductFieldsSelectedValues' : FieldsSelectedValues1,
                'BOMLineFieldsSelectedValues' : FieldsSelectedValues2,
                'TakeoffFilterSelectedValues': FieldsSelectedValues3,
                'ProductFilterSelectedValues' : FieldsSelectedValues4,
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