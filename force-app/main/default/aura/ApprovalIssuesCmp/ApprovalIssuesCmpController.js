/*
	@ PURPOSE : 1. CONTROLS THE LIGHTNING COMPONENT => ApprovalIssuesCmp.xml
				2. CONTROLS EVENTS FIRED FROM SCREEN/COMPONENT.
	@ Name    : ApprovalIssuesCmpController.js
*/
({
	doInit : function( component, event, helper ) {
        
		var listOfSubmittedIssues = JSON.parse( JSON.stringify( component.get( "v.listOfSubmittedIssues" ) ) );
		helper.doInit( component, helper, listOfSubmittedIssues ); 
    },
	
	closeModal : function( component, event, helper ) {
		
		helper.closeModal( component );
	},
    openRecordInNewConsoleTab : function( component, event, helper ) {
		
		if( event && event.target && event.target.id ) {
			helper.openRecordInNewConsoleTab( component, helper, event.target.id );
		}
	},
})