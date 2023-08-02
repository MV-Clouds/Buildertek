/*
	@ PURPOSE : 1. PROVIDES SERVICE TO => dynamicIssueRowsContainerController.js
				2. MAKES CALLS TO APEX SERVER.
	@ Name    : dynamicIssueRowsContainerHelper.js
*/
({
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
    
    createObjectData: function( component ) {
        
        var issueList = JSON.parse( JSON.stringify( component.get( "v.issueList" ) ) );
        issueList.push
				  ({
					'sobjectType': 'Issue__c',
					'Window_ID__c': '',
					'Control_Panel__c': '',
					'Notes__c': '',
                    'Description__c' : '',
                    'Comments__c' : '',
					'Date_Identified__c' : null,
					'RecordTypeId' : null,
					'Case__c' : null,
					'Source_Work_Order__c' : null
				  });  
        console.log( "issueList", issueList );
        component.set( "v.issueList", issueList );
    },
   
    removeRow: function( component, event, helper ) { 
        
		var indexVar = event.getParam( "indexVar" );   
        var issueList = JSON.parse( JSON.stringify( component.get( "v.issueList" ) ) );
        issueList.splice( indexVar, 1 );
        component.set( "v.issueList", issueList );
    },
	
    validateIssues : function( component, helper, issueList ) {
        
		console.log( 'validateIssues', issueList );
		
		if( !issueList || issueList.length < 1 ) {
			return false;
		}
		
		var todayDate = helper.parseDateToString( new Date() );
		
		var recordIssue;
        for ( var index = 0; index < issueList.length; index ++ ) {
            recordIssue = issueList[ index ];
            
            if( !recordIssue.Window_ID__c && !recordIssue.Control_Panel__c ) {
                helper.showToastMessage( 'warning', 'Missing!',
                                         $A.get("$Label.c.Provide_Window_Id_Or_Control_Panel_For_Row") + ' ' + ( index + 1 ) 
                                       );
				return false;
            }
			else if ( !recordIssue.Comments__c ) {
                helper.showToastMessage( 'warning', 'Missing!',
                                          $A.get("$Label.c.Provide_Notes_Comments_For_Row") + ' ' + ( index + 1 ) 
                                       );
				return false;
            }
            else if ( !recordIssue.RecordTypeId ) {
                helper.showToastMessage( 'warning', 'Missing!',
                                         $A.get("$Label.c.Provide_Record_Type_For_Row ") + ' ' + ( index + 1 ) 
                                       );
				return false;
            }
			else if ( !recordIssue.Date_Identified__c ) {
                helper.showToastMessage( 'warning', 'Missing!',
                                         $A.get("$Label.c.Provide_Date_Identified_For_Row ")  + ' ' + ( index + 1 ) 
                                       );
				return false;
            }
			else if( recordIssue.Date_Identified__c > todayDate ) {
				helper.showToastMessage( 'warning', 'Missing!', 
                                         $A.get("$Label.c.Date_Identified_Not_Future_Date_For_Row ")  + ' ' + ( index + 1 ) 
                                       );
				return false;
			}
        }
        return true;
    },
    
	populateDefaultValuesOnIssues : function( component, helper, issueList, recordWorkOrder ) {
		
		if( !recordWorkOrder || !issueList || issueList.length < 1 ) {
			return;
		}
		
		var recordIssue;
        for ( var index = 0; index < issueList.length; index ++ ) {
            recordIssue = issueList[ index ];
			recordIssue.Case__c = recordWorkOrder.CaseId;
            recordIssue.Source_Work_Order__c = recordWorkOrder.Id;
            recordIssue.Source_Work_Order__c = recordWorkOrder.Id;
            recordIssue.Customer_Account__c = recordWorkOrder.Case.AccountId;
            recordIssue.Opportunity__c = recordWorkOrder.Case.Opportunity__c;
		}
	},
	
	showToastMessage : function( type, title, message ) {
		
		if( type && message ) {
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
	
	parseDateToString : function( dateValue ) {
			
		var todayDate = '';
		var dateValue = new Date( dateValue );
		
		if( dateValue == 'Invalid Date' || isNaN( dateValue ) ) {
			return todayDate;
		}
		
		todayDate = dateValue.getFullYear();

		var monthValue = dateValue.getMonth() + 1;
		if( monthValue < 10 ) {
			monthValue = '0'+monthValue;
		}

		var dayValue = dateValue.getDate();
		if( dayValue < 10 ) {
			dayValue = '0'+dayValue;
		}

		todayDate += '-' + monthValue + '-' + dayValue;
		return todayDate;
	},
	
	save : function( component, helper ) {
        
		var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
		if( recordWorkOrder ) {
            if( !recordWorkOrder.CaseId ) {
                helper.showToastMessage( 'error', 'Error!', $A.get( "$Label.c.Case_Id_Not_Found_Try_Again" ) );
                return;
            }
		}
        else {
            helper.showToastMessage( 'error', 'Error!', $A.get( "$Label.c.Work_Order_Id_Not_Found_Try_Again" ) );
            return;
        }
		
		var issueList = JSON.parse( JSON.stringify( component.get( "v.issueList" ) ) );
		
        if ( helper.validateIssues( component, helper, issueList ) ) { 
			
			helper.populateDefaultValuesOnIssues( component, helper, issueList, recordWorkOrder );
			
            component.set( "v.showSpinner", true );
			
            var action = component.get( "c.saveIssues" );
            action.setParams({
                "ListIssues" : issueList
            });
            
            action.setCallback(this, function(response) {
                
                component.set( "v.showSpinner", false );
				
				var state = response.getState();
                if ( state === "SUCCESS" ) { 
				
                    var result = JSON.parse( response.getReturnValue() );
                    console.log( 'save', result );
					
                    if( result.isSucceeded ) {
                        helper.showToastMessage( 'success', 'Success!', result.message );
						
						component.set( "v.issueList", [] );
						var refreshIssuesReportedTableEvt = component.getEvent( "refreshIssuesReportedTableEvt" );
                        if( refreshIssuesReportedTableEvt ) {
                            refreshIssuesReportedTableEvt.fire();
                        }
                        helper.createObjectData( component );
                    }
                    else {
                        helper.showToastMessage( 'error', 'Error!', result.message );
                    }	
                }
                else {
                    helper.showToastMessage( 'error', 'Error!', $A.get( "$Label.c.Error_Adding_Rows_Try_Again" ) );
                }
            });
            $A.enqueueAction( action );
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
				console.log( 'dynamicIssueRowsContainerHelper-closeFocusedTab', error );
			});
		}
    },
})