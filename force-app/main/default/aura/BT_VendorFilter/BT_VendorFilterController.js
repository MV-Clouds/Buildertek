/* BT Lightning Component Controller.
 * Copyright 2017-2018, Builder Tek.
 * All rights reserved
 *
 * Created by 
 *
 * - Modifications:
 */

/* Lightning CLI rule */
/*global JQ$*/
({
    //showSpinner: this will call on aura waiting hendler 
    showSpinner: function (component, event, helper) {
        if(document.getElementById("avsplashDiv")){
            //stop page load symbol using page level function "endSplash"
			//if component has a page level endsplash js function then use that            
			if(component.get("v.endSplash") != ''){
                component.get("v.endSplash")();
            }
			document.getElementById("avsplashDiv").style.display="block";
        }
    },

    //hideSpinner: this will call on aura doneWaiting hendler
    hideSpinner: function (component, event, helper) {
        if(document.getElementById("avsplashDiv")){
            document.getElementById("avsplashDiv").style.display="none";
        }
    },
    
    initialize: function (component, event, helper) {
        var objectName, filterConditions, globalId, fieldSetName;
        globalId = component.getGlobalId();
        //check if event is fire or not 
        if(event.getParam("objectName")){

	        	
            objectName = event.getParam("objectName");
            filterConditions = event.getParam("filterConditions");
            fieldSetName=event.getParam("fieldSetName");
            //Check if objecct Type is change or not
            //we have to destroy the grid to apply new filter
            if(document.getElementById(component.get("v.TableId"))){
                JQ$('#'+component.get("v.TableId")).GridDestroy();
                component.set("v.gridLoad",false);
            }
        }else {
            objectName = component.get("v.objectName");
        	filterConditions = component.get("v.filterConditions");
        	fieldSetName=component.get("v.fieldSetName");
        }
        helper.initializeGrid(component, event, helper, objectName, filterConditions, globalId, fieldSetName);
    },
    
    cancel:function(component, event, helper){
    	sforce.one.back(false);
    },
    addSelected:function(component, event, helper){
    	var selectedVendorIds = JQ$("input[id$='vendorFilterResultTableId_gridslectedIds']").val();
        if(selectedVendorIds && selectedVendorIds != ''){
            sforce.one.back(true);
        } else {
            JQ$("#pleaseSelectVendor").show("slow").delay(5000).fadeOut();
        }
        
    },
    hideError:function(component, event, helper){
        JQ$("#pleaseSelectVendor").hide("slow");
        return false;
    }
})