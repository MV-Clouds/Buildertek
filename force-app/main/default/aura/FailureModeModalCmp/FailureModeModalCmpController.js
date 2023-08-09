/*
	@ PURPOSE : 1. CONTROLS THE LIGHTNING COMPONENT => FailureModeModalCmp.xml
				2. CONTROLS EVENTS FIRED FROM SCREEN/COMPONENT.
	@ Name    : FailureModeModalCmpController.js
*/
({
	doInit : function( component, event, helper ) {
        
		var failureComponent = component.get( "v.failureComponent" );
		var searchKeyword = component.get( "v.searchKeyword" );
        var  resonfail= component.get( "v.resonforreplace" );
       var listOfAlreadySelectedFailureModes = JSON.parse( JSON.stringify( component.get( "v.listOfAlreadySelectedFailureModes" ) ) );
		
        helper.doInit( component, helper, searchKeyword, failureComponent, listOfAlreadySelectedFailureModes,resonfail ); 
    },
	
	keyCheck : function( component, event, helper ) {
		
		console.log( 'keyCheck-which', event.which );
		if( event.which == 13 ) {
			var searchKeyword = component.get( "v.searchKeyword" );
			var failureComponent = component.get( "v.failureComponent" );
			var listOfAlreadySelectedFailureModes = JSON.parse( JSON.stringify( component.get( "v.listOfAlreadySelectedFailureModes" ) ) );
			helper.doInit( component, helper, searchKeyword, failureComponent, listOfAlreadySelectedFailureModes ); 
        }else{
            var searchKeyword = component.get( "v.searchKeyword" );
			var failureComponent = component.get( "v.failureComponent" );
			var listOfAlreadySelectedFailureModes = JSON.parse( JSON.stringify( component.get( "v.listOfAlreadySelectedFailureModes" ) ) );
			helper.doInit( component, helper, searchKeyword, failureComponent, listOfAlreadySelectedFailureModes ); 
     
        }
	},
	
	selectAllFailureModes : function( component, event, helper ) {
		
		var areFailureModesSelected = component.get( "v.areFailureModesSelected" );
		var listOfFailureModeWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfFailureModeWrappers" ) ) );
		helper.selectAllFailureModes( listOfFailureModeWrappers, areFailureModesSelected );
		component.set( "v.listOfFailureModeWrappers", listOfFailureModeWrappers );
	},
	
	save : function( component, event, helper ) {
		
		helper.save( component, helper );
	},
    handleFmSelect : function( component, event, helper ) {
		
		var index = event.target.id;
        console.log('index==',index);
		var listOfFailureModeWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfFailureModeWrappers" ) ) );
        var updatedwraper=listOfFailureModeWrappers[index];
        updatedwraper.isSelected=true;
        component.set("v.listOfFailureModeWrappers",listOfFailureModeWrappers);
		//helper.handleAssetSelect( component, helper, index, listOfAssetSearchedResults );
	},
	
	closeModal : function( component, event, helper ) {
		
		helper.closeModal( component );
	},
})