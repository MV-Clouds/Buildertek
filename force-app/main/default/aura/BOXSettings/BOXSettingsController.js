({
	doInit : function(component, event, helper) {
        helper.getTemplates(component, event, helper);
		var action = component.get("c.getBoxSettings");	
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
            	var result = response.getReturnValue();
                component.set("v.boxSettings", result);
            }   
        });
        $A.enqueueAction(action);
	},
    
    edit : function(component, event, helper) {
        component.set("v.isEdit", true);
    },
    
    save : function(component, event, helper) {
    	var action = component.get("c.saveSettings");
        action.setParams({
            boxSettings : component.get("v.boxSettings")   
        });
        action.setCallback(this, function(response){
            if(response.getState() === 'SUCCESS'){
            	component.set("v.isEdit", false);
                $A.enqueueAction(component.get("c.doInit"));    
            }    
        });
        $A.enqueueAction(action);
    },
    
    cancel : function(component, event, helper) {
    	component.set("v.isEdit", false);    
    },
    
    searchAll : function (component, event, helper) {
        component.set("v.openDropDown", true);
    },
    
    searchPDFAll : function (component, event, helper) {
        component.set("v.openPDFDropDown", true);
    },
    
    blur : function (component, event, helper) {
    	component.set("v.openDropDown", false);    
    },
    
    blurPDF : function (component, event, helper) {
    	component.set("v.openPDFDropDown", false);    
    },
    
    searchHandler : function (component, event, helper) {
        helper.searchTemplate(component, event, helper);
    },
    
    searchPDFHandler : function (component, event, helper) {
        helper.searchPDFTemplate(component, event, helper);
    },

    optionClickHandler : function (component, event, helper) {
        const selectedValue = event.target.closest('li').dataset.value;
        //component.set("v.boxSettings.buildertek__MSA_Template__c", selectedValue);
        component.set("v.openDropDown", false);
        component.set("v.selectedOption", selectedValue);
        
    },
    
    PDFOptionClickHandler : function (component, event, helper) {
        const selectedValue = event.target.closest('li').dataset.value;
        //component.set("v.msaSettings.buildertek__MSA_PDF_Template__c", selectedValue);
        component.set("v.openPDFDropDown", false);
        component.set("v.selectedPDFOption", selectedValue);
        
    },
})