/*
	@ PURPOSE : 1. CONTROLS THE LIGHTNING COMPONENT => GoogleAddressSearchCmp.xml
				2. CONTROLS EVENTS FIRED FROM SCREEN/COMPONENT.
	@ Name    : GoogleAddressSearchCmpController.js
*/
({
    getPredictions : function( component, event, helper ) {	        
        
		var searchKeyword = component.get( "v.location" );
		helper.getPredictions( component, helper, searchKeyword );
    },
	
	getPlaceDetails : function( component, event, helper ) {	     
		
		var placeId = event.currentTarget.dataset.placeid;
		helper.getPlaceDetails( component, helper, placeId );
	},
	
    closeModal : function( component, event, helper ) {
		
		helper.closeModal( component );
	},
    
    saveAddress: function( component, event, helper ) {
		
		helper.saveAddress( component, event, helper );
    },
})