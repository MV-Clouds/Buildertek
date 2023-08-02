/*
	@ PURPOSE : 1. PROVIDES SERVICE TO => FailureModeModalCmpController.js
				2. MAKES CALLS TO APEX SERVER.
	@ Name    : FailureModeModalCmpHelper.js
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
	
	selectAllFailureModes : function( listOfFailureModeWrappers, areFailureModesSelected ) {
		
		if( !listOfFailureModeWrappers || listOfFailureModeWrappers.length == 0 ) {
			return;
		}
		for( var index = 0; index < listOfFailureModeWrappers.length; index ++ ) {
			listOfFailureModeWrappers[ index ].isSelected = areFailureModesSelected;
		}
	},
	
	closeModal : function( component ) {
		
		component.destroy();
	},
	
	getListOfSelectedFailureModes : function( component, helper, listOfFailureModeWrappers ) {
		
		var listOfFailureModesSelected  = [];
		if( !listOfFailureModeWrappers || listOfFailureModeWrappers.length == 0 ) {
			return listOfFailureModesSelected;
		}
		
		for( var index = 0; index < listOfFailureModeWrappers.length; index ++ ) {
			var wrapper = listOfFailureModeWrappers[ index ];
			if( wrapper.isSelected ) {
				listOfFailureModesSelected.push( wrapper.recordFailureMode.Id );
			}
		}
		console.log( 'getListOfSelectedFailureModes-listOfFailureModesSelected', listOfFailureModesSelected );
		return listOfFailureModesSelected;
	},
    getSelectedFailureModesName : function( component, helper, listOfFailureModeWrappers ) {
		
		var listOfFailureModesSelected  = [];
		if( !listOfFailureModeWrappers || listOfFailureModeWrappers.length == 0 ) {
			return listOfFailureModesSelected;
		}
		
		for( var index = 0; index < listOfFailureModeWrappers.length; index ++ ) {
			var wrapper = listOfFailureModeWrappers[ index ];
			if( wrapper.isSelected ) {
				listOfFailureModesSelected.push( wrapper.recordFailureMode.Name );
			}
		}
		console.log( 'getListOfSelectedFailureModes-listOfFailureModesSelected', listOfFailureModesSelected );
		return listOfFailureModesSelected;
	},
	
	save : function( component, helper ) {
		
		
		var listOfFailureModeWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfFailureModeWrappers" ) ) );
		var listOfFailureModesSelected = helper.getListOfSelectedFailureModes( component, helper, listOfFailureModeWrappers );
		var NameOfFailureModesSelected = helper.getSelectedFailureModesName(component, helper, listOfFailureModeWrappers);
        console.log( 'NameOfFailureModesSelected========='+NameOfFailureModesSelected );
		
		
		if( !listOfFailureModesSelected || listOfFailureModesSelected.length == 0 ) {
			helper.showToastMessage( 'error', 'Error!',$A.get("$Label.c.Select_Atleast_One_Failure_Component"));
			return;
		}
		
		var failureModeMultiSelectEvt = component.getEvent( "failureModeMultiSelectEvt" );
		if( !failureModeMultiSelectEvt ) {
			return;
		}
		
		var recordIndex = component.get( "v.recordIndex" );
		var listName = component.get( "v.listName" );
		
		failureModeMultiSelectEvt.setParams({
			'recordIndex' : recordIndex,
			'listName' : listName,
			'listOfFailureModesSelected' : listOfFailureModesSelected,
            'NameOfFailureModesSelected' : NameOfFailureModesSelected
		});
		
		failureModeMultiSelectEvt.fire();
		
		helper.closeModal( component );
	},
	
	doInit : function( component, helper, searchKeyword, failureComponent, listOfAlreadySelectedFailureModes,resonfail ) {
		
		console.log( 'doInit-searchKeyword', searchKeyword );
		console.log( 'doInit-failureComponent', failureComponent );
		console.log( 'doInit-listOfAlreadySelectedFailureModes', listOfAlreadySelectedFailureModes );
		if( !failureComponent ) {
			helper.showToastMessage( 'error', 'Error!', $Label.c.Select_Failure_Component);
			return;
		}
		
		component.set( "v.listOfFailureModeWrappers", [] );
		
		var serverAction = component.get( "c.searchFailureModeRecords" );
		if( !serverAction ) {
			return;
		}
		component.set( "v.showSpinner", true );
		serverAction.setParams({
								"searchKeyword" : searchKeyword,
								"resonfail": resonfail,
                                "failureComponent" : failureComponent,
                                "jsonListOfFailureModeIDs" : JSON.stringify( listOfAlreadySelectedFailureModes )
                                
								
							  });
							  
		serverAction.setCallback( this, function( response ) {
			
			component.set( "v.showSpinner", false );
			
			var state = response.getState();
			if ( state === "SUCCESS" ) {
				var result = JSON.parse( response.getReturnValue() );
				console.log( "doInit", result );
				if( result.isSucceeded ) {
					component.set( "v.listOfFailureModeWrappers", result.listOfFailureModeWrappers );
				}
				else {
					helper.showToastMessage( 'error', 'Error!', result.message );
				}
			}
			else {
                helper.showToastMessage( 'error', 'Error!',$A.get("$Label.c.Something_Went_Wrong_Please_Contact_Admin"));
			}
		});
			
		$A.enqueueAction( serverAction );
	},
})