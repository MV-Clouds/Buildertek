({
	getSR: function(component, event, helper, map) {
        //Get Current User ID
        var actionGetSR, state, actionGetNameSpace, actionGetOrganizationName;
        actionGetSR = component.get("c.getAllSR");
        actionGetSR.setCallback(this, function (response) {
            state = response.getState();
            if (state === "SUCCESS") {
                var recordData = response.getReturnValue();
              
                //Extend the Default marker class
                // var RedIcon = L.Icon.Default.extend({options: {iconUrl: 'marker-icon-red.png'}});
                //var redIcon = new RedIcon();
                var trailIcon = L.icon({iconUrl: '/resource/BT/assets/icons/utility/trail_60.png',
                                            iconSize: [38, 40], // size of the icon
                                         });
                var resource_territory = L.icon({iconUrl: '/resource/BT/assets/icons/utility/resource_territory_60.png',
                                            iconSize: [38, 40], // size of the icon
                                         });
                
                /*
                //Other things we could have changed
                    iconSize:     [25, 41], // size of the icon
                    shadowSize:   [50, 64], // size of the shadow
                    iconAnchor:   [12, 41]  // point of the icon which will correspond to marker's location
                    shadowAnchor: [4, 62],  // the same for the shadow
                    popupAnchor:  [-3, -76] // point from which the popup should open relative to the iconAnchor
                */
                var contactIcone = '<span class="slds-icon_container slds-icon--small slds-icon-standard-contact" title="Customer" style="margin-top: 10px;"><img src="/resource/BT/assets/icons/standard/contact_60.png"/></span>';
                var callIcone = '<span class="slds-icon_container slds-icon--small slds-icon-standard-contact" title="Pnone" style="margin-top: 10px;"><img src="/resource/BT/assets/icons/standard/call_60.png"/></span>';
                var emailIcone = '<span class="slds-icon_container slds-icon--small slds-icon-standard-contact" title="Email" style="margin-top: 10px;"><img src="/resource/BT/assets/icons/standard/email_60.png"/></span>';
                var workorderIcone = '<span class="slds-icon_container slds-icon--small slds-icon-standard-contact" title="Service Request" style="margin-top: 10px;"><img src="/resource/BT/assets/icons/standard/work_order_60.png"/></span>';
                var assignee = '<span class="slds-icon_container slds-icon--small slds-icon-standard-contact" title="Service Request Assignee" style="margin-top: 10px;"><img src="/resource/BT/assets/icons/standard/service_resource_60.png"/></span>';
                var status = '<span class="slds-icon_container slds-icon--small slds-icon-standard-contact" title="Service Request Status" style="margin-top: 10px;"><img src="/resource/BT/assets/icons/standard/goals_60.png"/></span>';
                
                
                var markers = L.markerClusterGroup();
                
                for (var i = 0; i < recordData.length; i++) { 
                   
                  
					var customerName = recordData[i].buildertek__Customer_Name__r.Name;
                    var MailingLatitude = recordData[i].buildertek__Customer_Name__r.MailingLatitude;
                    var MailingLongitude = recordData[i].buildertek__Customer_Name__r.MailingLongitude;
                    var detailInfo = '<div id="'+recordData[i].Id+'" class="SRDetailView"><strong>'+workorderIcone+'<a href="/'+escape(recordData[i].Id)+'" target="_blank">'+recordData[i].Name+' ('+recordData[i].buildertek__Subject__c+')</a></strong><br/><strong>'+contactIcone+'</strong> '+customerName+'<br/>'+'<strong>'+emailIcone+'</strong> '+recordData[i].buildertek__Customer_Email__c+'<br/>'+'<strong>'+callIcone+'</strong> '+recordData[i].buildertek__Customer_Phone__c+'<br/>'+'<strong>'+assignee+'</strong> '+recordData[i].buildertek__Primary_Assignee__c+'<br/>'+'<strong>'+status+'</strong> '+recordData[i].buildertek__Request_Status__c;;
                    
                    var marker = L.marker([MailingLatitude, MailingLongitude]).bindPopup(''+detailInfo+'</strong></div>');
                    marker.on('click', L.bind(this.markerOnClick, null, component))
					markers.addLayer(marker);
                    //L.marker(['23.033677', '72.463412'], {icon: trailIcon}).bindPopup('<strong>Bopal</strong>').addTo(map);
                }
                map.addLayer(markers);
                
            } else {
                console.log(response.getReturnValue());
            }
        });
        
        $A.enqueueAction(actionGetSR);
    },
    getProductFamily:function(component, event, helper){
    	var actionProductFamily, state, actionGetNameSpace, actionGetOrganizationName;
        actionProductFamily = component.get("c.getProductFamily");
        actionProductFamily.setCallback(this, function (response) {
            state = response.getState();
            if (state === "SUCCESS") {
            	component.set("v.productFamily", response.getReturnValue());
            }else {
            	
            }
        });
        
        $A.enqueueAction(actionProductFamily);
    },
    getProduct:function(component, event, helper){
    	var actionProductList, state, actionGetNameSpace, actionGetOrganizationName;
        actionProductList = component.get("c.getProductList");
        actionProductList.setCallback(this, function (response) {
            state = response.getState();
            if (state === "SUCCESS") {
            	component.set("v.productList", response.getReturnValue());
            }else {
            	
            }
        });
        
        $A.enqueueAction(actionProductList);
    },
    addNewProduct:function(component, event, helper){
    	var actionAddNewProduct, state, actionGetNameSpace, actionGetOrganizationName;
        actionAddNewProduct = component.get("c.addNewProduct");
        actionAddNewProduct.setCallback(this, function (response) {
            state = response.getState();
            if (state === "SUCCESS") {
            	var existingProduct = component.get("v.productList");
            	console.log(response.getReturnValue());
            	existingProduct.unshift(response.getReturnValue());
            	console.log(existingProduct);
            	component.set("v.productList", existingProduct);
            }else {
            	
            }
        });
        
        $A.enqueueAction(actionAddNewProduct);
    },
    markerOnClick: function (cmp) {
    	$( ".SRDetailView" ).droppable({
            drop: function(evt, ui) {
                var resourceId = ui.draggable.attr("id");
                var srId = this.id;
                cmp.resourceAssigned(srId, resourceId);
            }
        });
    },
    getResources: function(component, event, helper, map) {
    	var actionGetResources, state, actionGetNameSpace, actionGetOrganizationName;
        actionGetResources = component.get("c.getAllAvailableResources");
        actionGetResources.setCallback(this, function (response) {
            state = response.getState();
            if (state === "SUCCESS") {
            	component.set("v.resources", response.getReturnValue());
            }else {
            }
        });
        
        $A.enqueueAction(actionGetResources);
    },
    assigneSelectedResource: function(component, event, helper, srId, resourceId) {
    	var actionAssigneSelectedResource, state, actionGetNameSpace, actionGetOrganizationName;
    	var spinner = component.find("BTSpinner");
        actionAssigneSelectedResource = component.get("c.assignedResources");
	    actionAssigneSelectedResource.setParams({
	        srId: srId,
	        resourceId: resourceId
	    });
        actionAssigneSelectedResource.setCallback(this, function (response) {
            state = response.getState();
            if (state === "SUCCESS") {
            	alert(response.getReturnValue());
            	 var toastEvent = $A.get("e.force:showToast");
				 toastEvent.setParams({
				        "title": "Success!",
				        "type": "success",
				        "message": "The record has been updated successfully."
				 });
				 toastEvent.fire();
				  $A.util.toggleClass(spinner, "slds-hide");
            }else {
            	alert(response.getReturnValue());
            	$A.util.toggleClass(spinner, "slds-hide");
            }
        });
        
        $A.enqueueAction(actionAssigneSelectedResource);
    }
})