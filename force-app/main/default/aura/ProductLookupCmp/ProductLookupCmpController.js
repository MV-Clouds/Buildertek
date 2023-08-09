/*
	@ PURPOSE : 1. CONTROLS THE LIGHTNING COMPONENT => ProductLookupCmp.xml
				2. CONTROLS EVENTS FIRED FROM SCREEN/COMPONENT.
	@ Name    : ProductLookupCmpController.js
*/
({
	doInit : function( component, event, helper ) {
        
		var searchKeyword = component.get( "v.searchKeyword" );
		var opportunityPricebook2Id = component.get( "v.opportunityPricebook2Id" );
		var productFamily = component.get( "v.productFamily" );
		var opportunityCurrencyCode = component.get( "v.opportunityCurrencyCode" );
		
		helper.getProducts( component, helper, searchKeyword, opportunityPricebook2Id, productFamily, opportunityCurrencyCode );
        helper.getTrunkProducts( component, helper, searchKeyword);
    },
	
	keyCheck : function( component, event, helper ) {
		
		console.log( 'keyCheck-which', event.which );
		if( event.which == 13 ) {
			var searchKeyword = component.get( "v.searchKeyword" );
		var opportunityPricebook2Id = component.get( "v.opportunityPricebook2Id" );
            var productFamily = component.get( "v.productFamily" );
		helper.getProducts( component, helper, searchKeyword, opportunityPricebook2Id, productFamily );
            helper.getTrunkProducts( component, helper, searchKeyword);
        }else{
            	var searchKeyword = component.get( "v.searchKeyword" );
		var opportunityPricebook2Id = component.get( "v.opportunityPricebook2Id" );
            var productFamily = component.get( "v.productFamily" );
		helper.getProducts( component, helper, searchKeyword, opportunityPricebook2Id, productFamily );
            helper.getTrunkProducts( component, helper, searchKeyword);
        }
	},
	
	handleProductSelect : function( component, event, helper ) {
		
		var index = event.target.id;
		var listOfSearchedResults = JSON.parse( JSON.stringify( component.get( "v.listOfSearchedResults" ) ) );
		helper.handleProductSelect( component, helper, index, listOfSearchedResults );
	},
	
	closeModal : function( component, event, helper ) {
		
		helper.closeModal( component );
	},
})