/*
	@ PURPOSE : 1. CONTROLS THE LIGHTNING COMPONENT => dynamicIssueRows.xml
				2. CONTROLS EVENTS FIRED FROM SCREEN/COMPONENT.
	@ Name    : dynamicIssueRowsController.js
*/
({
    doInit : function( component, event, helper ) {
		
    },
    
    AddNewRow : function( component, event, helper ) {
		
		var AddRowEvt = component.getEvent( "AddRowEvt" );
		if( AddRowEvt ) {
			AddRowEvt.fire();
		}
    },
    
    removeRow : function( component, event, helper ) {
		
		var userConsent = confirm( "Are you sure want to delete the row?" );
		if( !userConsent ) {
			return;
		}
		
		var DeleteRowEvt = component.getEvent( "DeleteRowEvt" );
		if( DeleteRowEvt ) {
			DeleteRowEvt.setParams( { "indexVar" : component.get( "v.rowIndex" ) } );
			DeleteRowEvt.fire();
		}
    },
})