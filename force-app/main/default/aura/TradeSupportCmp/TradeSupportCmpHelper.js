/*
	@ PURPOSE : 1. PROVIDES SERVICE TO => TradeSupportCmpController.js
				2. MAKES CALLS TO APEX SERVER.
	@ Name    : TradeSupportCmpHelper.js
*/
({
	refreshIssuesTable : function( component, event, helper ) {
    	
		var refreshIssuesReportedTableEvt = component.getEvent( "refreshIssuesReportedTableEvt" );
		if( refreshIssuesReportedTableEvt ) {
			refreshIssuesReportedTableEvt.fire();
		}
    },
	
	openRecordInNewConsoleTab : function( component, helper, recordId ) {
			
		if( recordId ) {
			var isConsoleNavigation = component.get( "v.isConsoleNavigation" );
			if( isConsoleNavigation ) {
			
				var workspaceAPI = component.find( "workspace" );
				if( workspaceAPI ) {
					
					workspaceAPI.openTab
					({
						recordId : recordId,
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
			else {
				window.open( '/' + recordId, '_blank' );
			}
		}
	},
	
	selectAllRecordWrappers : function( component, areAllTradeIssuesSelected, listOfTradeIssueWrappers ) {
    	
		console.log( 'areAllTradeIssuesSelected', areAllTradeIssuesSelected );
		console.log( 'listOfTradeIssueWrappers', listOfTradeIssueWrappers );
        if( listOfTradeIssueWrappers && listOfTradeIssueWrappers.length > 0 ) {
            for( var index = 0; index < listOfTradeIssueWrappers.length; index++ ) {
                listOfTradeIssueWrappers[index].isSelected = areAllTradeIssuesSelected;
            }
        }
    },
	
	getListOfSelectedRecordWrappers : function( component, listOfRecordWrappers ) {
    	
        console.log( 'before-getListOfSelectedRecordWrappers', listOfRecordWrappers );
        var listOfSelectedRecordWrappers = [];
		var recordIssue;
		
        if( listOfRecordWrappers && listOfRecordWrappers.length > 0 ) {
			for( var index = 0; index  < listOfRecordWrappers.length; index ++ ) {
                if( listOfRecordWrappers[index].isSelected ) {
					
					recordIssue = listOfRecordWrappers[index].recordIssue;
					listOfSelectedRecordWrappers.push( listOfRecordWrappers[ index ] );
                }
            }
        }
        console.log( 'after-getListOfSelectedRecordWrappers', listOfSelectedRecordWrappers );
        return listOfSelectedRecordWrappers;
    },
	
	updateTradeIssues : function( component, helper, listName ) {
        
        var listOfTradeIssueWrappers = JSON.parse( JSON.stringify( component.get( "v." + listName ) ) );
		var listOfSelectedTradeIssueWrappers = helper.getListOfSelectedRecordWrappers( component, listOfTradeIssueWrappers );
        if( !listOfSelectedTradeIssueWrappers || listOfSelectedTradeIssueWrappers.length == 0 ) {
            helper.showToastMessage( 'warning', 'Warning!', $Label.c.Select_At_Least_One );
            return;
        }
		
		var serverAction = component.get( "c.updateTradeIssueRecords" );
        if( !serverAction ) {
            return;
        }
        component.set( "v.showSpinner", true );
        
        serverAction.setParams({ 
								"strJSONListOfTradeIssuesWrappers" : JSON.stringify( listOfSelectedTradeIssueWrappers )
							  });
							  
        serverAction.setCallback( this, function( response ) {
            component.set("v.showSpinner", false );
            
			var state = response.getState();
            if ( state === "SUCCESS" ) {
                
				var result = JSON.parse( response.getReturnValue() );
                console.log( result );
                
				if( result.isSucceeded ) {
					helper.showToastMessage( 'success', 'Success!', result.message );
					helper.refreshIssuesTable( component, null, helper );
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
	
	cancel : function( component, helper ) {
		
		var isConsoleNavigation = component.get( "v.isConsoleNavigation" );
		if( isConsoleNavigation ) {
			var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
			if( recordWorkOrder ) {
				helper.openRecordInNewConsoleTab( component, helper, recordWorkOrder.Id );
			}
			helper.closeFocusedTab( component );
		}
		else {
			var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
			if( recordWorkOrder ) {
				window.open( '/' + recordWorkOrder.Id, '_self' );
			}
		}
	},
	
	closeFocusedTab : function( component ) {
		
        var workspaceAPI = component.find( "workspace" );
		if( workspaceAPI ) {
			workspaceAPI.getFocusedTabInfo().then( function( response ) {
				var focusedTabId = response.tabId;
				workspaceAPI.closeTab({ tabId: focusedTabId });
			})
			.catch( function( error ) {
				console.log( 'TradeSupportCmpHelper-closeFocusedTab', error );
			});
		}
    },
})