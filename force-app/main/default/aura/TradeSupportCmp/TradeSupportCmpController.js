/*
	@ PURPOSE : 1. CONTROLS THE LIGHTNING COMPONENT => TradeSupportCmp.xml
				2. CONTROLS EVENTS FIRED FROM SCREEN/COMPONENT.
	@ Name    : TradeSupportCmpController.js
*/
({
	selectAllCHWTradeIssues : function( component, event, helper ) {
        
		var areAllCHWTradeIssuesSelected = JSON.parse( JSON.stringify( component.get( "v.areAllCHWTradeIssuesSelected" ) ) );
        var listOfCHWTradeIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfCHWTradeIssueWrappers" ) ) );
        helper.selectAllRecordWrappers( component, areAllCHWTradeIssuesSelected, listOfCHWTradeIssueWrappers );
		component.set( "v.listOfCHWTradeIssueWrappers", listOfCHWTradeIssueWrappers );
    },
	
	selectAllIGUTradeIssues : function( component, event, helper ) {
        
		var areAllIGUTradeIssuesSelected = JSON.parse( JSON.stringify( component.get( "v.areAllIGUTradeIssuesSelected" ) ) );
        var listOfIGUTradeIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfIGUTradeIssueWrappers" ) ) );
        helper.selectAllRecordWrappers( component, areAllIGUTradeIssuesSelected, listOfIGUTradeIssueWrappers );
		component.set( "v.listOfIGUTradeIssueWrappers", listOfIGUTradeIssueWrappers );
    },
	
	updateCHWTradeIssues : function( component, event, helper ) {
		
		helper.updateTradeIssues( component, helper, "listOfCHWTradeIssueWrappers" );
    },
	
	updateIGUTradeIssues : function( component, event, helper ) {
		
		helper.updateTradeIssues( component, helper, "listOfIGUTradeIssueWrappers" );
    },
	
	openRecordInNewConsoleTab : function( component, event, helper ) {
		
		if( event && event.target && event.target.id ) {
			helper.openRecordInNewConsoleTab( component, helper, event.target.id );
		}
	},
	
	toggleSection : function( component, event, helper ) {
        
		var divId = event.target.dataset.title;
		console.log( 'divId', divId );
		
		if( !divId ) {
			return;
		}
		
		var divElement = component.find( divId );
        console.log( 'divElement', divElement );
		
		if( !divElement ) {
			return;
		}
		
		var isExpanded =  $A.util.hasClass( component.find( divId ), 'slds-is-open' );
		console.log( 'isExpanded', isExpanded );
		
		if( isExpanded ) {
			$A.util.removeClass( divElement, 'slds-section slds-is-open' );
            $A.util.addClass( divElement, 'slds-section slds-is-close' );
		}
		else {
			$A.util.removeClass( divElement, 'slds-section slds-is-close' );
            $A.util.addClass( divElement, 'slds-section slds-is-open' );
		}
    },
	
	cancel : function( component, event, helper ) {
        
		helper.cancel( component, helper )
    },
})