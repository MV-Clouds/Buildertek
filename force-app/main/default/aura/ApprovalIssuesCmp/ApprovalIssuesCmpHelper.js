/*
	@ PURPOSE : 1. PROVIDES SERVICE TO => ApprovalIssuesCmpController.js
				2. MAKES CALLS TO APEX SERVER.
	@ Name    : ApprovalIssuesCmpHelper.js
*/
({
	showToastMessage : function( type, title, message ) {
        
        if( type && title && message ) {
            var toastEvent = $A.get( "e.force:showToast" );
            
            if( toastEvent ) {
                toastEvent.setParams({
                    'type' : type,
                    'title' : title,
                    'message': message,
                    'mode' : 'dismissible',
					'duration' : 7000
                });
                toastEvent.fire();
            }
        }
    },
	
	closeModal : function( component ) {
		
		var refreshIssuesReportedTableEvt = component.getEvent( "refreshIssuesReportedTableEvt" );
		if( refreshIssuesReportedTableEvt ) {
			refreshIssuesReportedTableEvt.fire();
		}
		component.destroy();
	},
	
	doInit : function( component, helper, listOfSubmittedIssues ) {
		
		console.log( 'doInit-listOfSubmittedIssues', listOfSubmittedIssues );
		
		var serverAction = component.get( "c.fetchIssuesSubmittedForApproval" );
		if( !serverAction ) {
			return;
		}
		component.set( "v.showSpinner", true );
			
		serverAction.setParams({ 
								"strJsonOfListOfApprovalIssues" : JSON.stringify( listOfSubmittedIssues )
							  });
							  
		serverAction.setCallback( this, function( response ) {
			
			component.set( "v.showSpinner", false );
			
			var state = response.getState();
			if ( state === "SUCCESS" ) {
				
				var result = JSON.parse( response.getReturnValue() );
				console.log( "doInit", result );
				
				if( result.isSucceeded ) {
					component.set( "v.listOfApprovalIssues", result.listOfApprovalIssues );
				}
				else {
					helper.showToastMessage( 'error', 'Error!', result.message );
				}
			}
			else {
				helper.showToastMessage( 'error', 'Error!',$A.get("$Label.c.Something_Went_Wrong_Please_Contact_Admin") );
			}
		});
			
		$A.enqueueAction( serverAction );
	},
    openRecordInNewConsoleTab : function( component, event, recordid ) {
		
        if(recordid){
        var isConsoleNavigation = component.get( "v.isConsoleNavigation" );
        if( isConsoleNavigation ) {
            var workspaceAPI = component.find( "workspace" );
		if( workspaceAPI ) {
			
			
			if( recordid ) {
				workspaceAPI.openTab
				({
					recordId : recordid,
					focus : true
				}).then( function( response ) {
					workspaceAPI.getTabInfo
					({
						tabId: response
					}).then(function( tabInfo ) {
						if( tabInfo ) {
							console.log( "The url for this tab is:", tabInfo.url );
						}
					});
				})
				.catch( function( error ) {
				   console.log( 'openRecordInNewConsoleTab-error', error );
				});
			}
		}
        }else {
				window.open( '/' + recordid, '_blank' );
			}
        }
	},
})