/*
	@ PURPOSE : 1. CONTROLS THE LIGHTNING COMPONENT => AssetLookupCmp.xml
				2. CONTROLS EVENTS FIRED FROM SCREEN/COMPONENT.
	@ Name    : AssetLookupCmpController.js
*/
({
	doInit : function( component, event, helper ) {
        
		var searchKeyword = component.get( "v.searchKeyword" );
		var opportunityId = component.get( "v.opportunityId" );
        helper.setAssetToIssueShape( component );
		helper.getAssets( component, helper, searchKeyword, opportunityId ); 
    },
	keyCheck : function( component, event, helper ) {
		
		console.log( 'keyCheck-which', event.which );
		if( event.which == 13 ) {
            var searchKeyword = component.get( "v.searchKeyword" );
		var opportunityId = component.get( "v.opportunityId" );
		helper.getAssets( component, helper, searchKeyword, opportunityId ); 
        }else{
             var searchKeyword = component.get( "v.searchKeyword" );
		var opportunityId = component.get( "v.opportunityId" );
		helper.getAssets( component, helper, searchKeyword, opportunityId );
        }
	},
	handleAssetSelect : function( component, event, helper ) {
		
		var index = event.target.id;
		var listOfAssetSearchedResults = JSON.parse( JSON.stringify( component.get( "v.listOfAssetSearchedResults" ) ) );
		helper.handleAssetSelect( component, helper, index, listOfAssetSearchedResults );
	},
	
	closeModal : function( component, event, helper ) {
		
		helper.closeModal( component );
	},
})