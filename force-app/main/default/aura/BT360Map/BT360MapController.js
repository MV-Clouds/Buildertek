({
	//showSpinner: this will call on aura waiting hendler 
    showSpinner: function (component, event, helper) {
        var spinner = component.find("BTSpinner");
        $A.util.addClass(spinner, "slds-show");
        $A.util.removeClass(spinner, "slds-hide");
    },

    //hideSpinner: this will call on aura doneWaiting hendler
    hideSpinner: function (component, event, helper) {
        var spinner = component.find("BTSpinner");
        $A.util.addClass(spinner, "slds-hide");
        $A.util.removeClass(spinner, "slds-show");
        
    },
	jsLoaded: function(component, event, helper) {
        setTimeout(function() {
            //$("#BT-Map-Container").layout({ applyDefaultStyles: true }).sizePane("west", 300);
			var tiles = L.tileLayer('http://{s}.tile.osm.org/{z}/{x}/{y}.png', {maxZoom: 18}),
				latlng = L.latLng(39.029711,-94.275755);
			
			var map = L.map('map', {zoomControl:false, center: latlng, zoom: 13, layers: [tiles]});
            
            map.attributionControl.setPrefix('');
			
            helper.getSR(component, event, helper, map);
            helper.getResources(component, event, helper);
            helper.getProduct(component, event, helper);
            helper.getProductFamily(component, event, helper);
        });
    },
    showResourceUtilityPanel:function(component, event, helper) {
    	var resourcePanel = component.find('resourcePanel');
    	var resourceTab = component.find('resourceTab');
        if($A.util.hasClass(resourcePanel, 'slds-is-open')){
            $A.util.addClass(resourcePanel, 'slds-is-close');
            $A.util.removeClass(resourcePanel, 'slds-is-open');
            
            $A.util.removeClass(resourceTab, 'slds-is-active');
            $A.util.addClass(resourceTab, 'slds-is-inactive');
            
        }else{
            $A.util.addClass(resourcePanel, 'slds-is-open');
            $A.util.removeClass(resourcePanel, 'slds-is-close');
            
            
            $A.util.removeClass(resourceTab, 'slds-is-inactive');
            $A.util.addClass(resourceTab, 'slds-is-active');
            
        }
        
	    $(".drag").draggable({
            helper: 'clone',
            start: function(evt, ui) {
                $('#resourses').fadeTo('fast', 0.6, function() {});
            },
            stop: function(evt, ui) {
                $('#resourses').fadeTo('fast', 1.0, function() {});
            }
        });
	        
    },
    hideResourceUtilityPanel:function(component, event, helper) {
    	var resourcePanel = component.find('resourcePanel');
    	var resourceTab = component.find('resourceTab');
    	
        $A.util.addClass(resourcePanel, 'slds-is-close');
        $A.util.removeClass(resourcePanel, 'slds-is-open');
        $A.util.removeClass(resourceTab, 'slds-is-active');
        $A.util.addClass(resourceTab, 'slds-is-inactive');
    },
    showOptions:function(component, event, helper){
    	var viewList = component.find('viewList');
    	if($A.util.hasClass(viewList, 'invisible')){
    		$A.util.removeClass(viewList, 'invisible');
    	}else {
    		$A.util.addClass(viewList, 'invisible');
    	}
    	
    },
    doAssigned:function(component, event, helper){
    	var params = event.getParam('arguments');
        if (params) {
            var srId = params.srId;
            var resourceId = params.resourceId;
            helper.assigneSelectedResource(component, event, helper, srId, resourceId);
        }
    },
    createRecordWorkOrder : function (component, event, helper) {
	    var newWorkOrder = component.find('newWorkOrder');
    	if($A.util.hasClass(newWorkOrder, 'invisible')){
    		$A.util.removeClass(newWorkOrder, 'invisible');
    	}else {
    		$A.util.addClass(newWorkOrder, 'invisible');
    	}
	},
	cancelRecordWorkOrder : function (component, event, helper) {
	    var newWorkOrder = component.find('newWorkOrder');
		$A.util.addClass(newWorkOrder, 'invisible');
	},
	doAddNewProduct: function (component, event, helper) {
	    helper.addNewProduct(component, event, helper);
	}
})