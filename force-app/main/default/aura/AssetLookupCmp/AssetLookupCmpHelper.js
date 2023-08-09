/*
	@ PURPOSE : 1. PROVIDES SERVICE TO => ProductLookupCmpController.js
				2. MAKES CALLS TO APEX SERVER.
	@ Name    : ProductLookupCmpHelper.js
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
		
		component.destroy();
	},
	
	handleAssetSelect : function( component, helper, index, listOfAssetSearchedResults ) {
		
		console.log( 'handleProductSelect-index', index );
		console.log( 'handleProductSelect-listOfAssetSearchedResults', listOfAssetSearchedResults );
		if( !listOfAssetSearchedResults || listOfAssetSearchedResults.length <= index ) {
			return;
		}
		
		var recordAsset = listOfAssetSearchedResults[ index ];
		console.log( 'handleProductSelect-recordAsset', recordAsset );
		if( !recordAsset || !recordAsset.Id ) {
			return;
		}
		
        var recordIndex = JSON.parse( JSON.stringify( component.get( "v.recordIndex" ) ) );
		var listName = JSON.parse( JSON.stringify( component.get( "v.listName" ) ) );
		var fieldName = JSON.parse( JSON.stringify( component.get( "v.fieldName" ) ) );
        
        if(component.get("v.componentName") == 'IGU'){
            
            var IGUassetRecordSelectEvt = component.getEvent( "IGUassetRecordSelectEvt" );
		console.log( 'handleAssetSelect-assetRecordSelectEvt', IGUassetRecordSelectEvt );
		if( !IGUassetRecordSelectEvt ) {
			return;
		}
		
		IGUassetRecordSelectEvt.setParams({
			'recordIndex' : recordIndex,
			'listName' : listName,
			'fieldName' : fieldName,
			'recordAsset' : recordAsset
		});
		
		IGUassetRecordSelectEvt.fire();
		
            
        }else{
            var assetRecordSelectEvt = component.getEvent( "assetRecordSelectEvt" );
		console.log( 'handleAssetSelect-assetRecordSelectEvt', assetRecordSelectEvt );
		if( !assetRecordSelectEvt ) {
			return;
		}
		
		assetRecordSelectEvt.setParams({
			'recordIndex' : recordIndex,
			'listName' : listName,
			'fieldName' : fieldName,
			'recordAsset' : recordAsset
		});
		
		assetRecordSelectEvt.fire();
		
        }
		
		helper.closeModal( component );
	},
	
	getAssets : function( component, helper, searchKeyword, opportunityId ) {
		
		console.log( 'getAssets-searchKeyword', searchKeyword );
		/*if( !searchKeyword || searchKeyword.length <= 2 ) {
			return;
		}*/
		component.set( "v.listOfAssetSearchedResults", []);
		console.log( 'getAssets-opportunityId', opportunityId );
		if( !opportunityId ) {
			return;
		}
		
		var serverAction = component.get( "c.searchAssetRecords" );
		if( !serverAction ) {
			return;
		}
		component.set( "v.showSpinner", true );
			
		serverAction.setParams({ 
								"searchKeyword" : searchKeyword,
								"opportunityId" : opportunityId
							  });
							  
		serverAction.setCallback( this, function( response ) {
			
			component.set( "v.showSpinner", false );
			
			var state = response.getState();
			if ( state === "SUCCESS" ) {
				var assetToIssueShape = JSON.parse( JSON.stringify( component.get( "v.assetToIssueShape" ) ) );
				console.log( "assetToIssueShape", assetToIssueShape );
                var result = JSON.parse( response.getReturnValue() );
				console.log( "getAssets", result );
				
				if( result.isSucceeded ) {
					component.set( "v.listOfAssetSearchedResults", result.listOfAssetSearchedResults );
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
    setAssetToIssueShape : function( component ) {
		
		var assetToIssueShape = {};
		
		assetToIssueShape[ 'SH000' ] = 'Rectangle - 0';
		assetToIssueShape[ 'SH001' ] = 'Trapezoid - 1';
		assetToIssueShape[ 'SH002' ] = 'Trapezoid - 2';
		assetToIssueShape[ 'SH045' ] = 'Triangle - 45';
		assetToIssueShape[ 'SH046' ] = 'Triangle - 46';
		assetToIssueShape[ 'SH301' ] = 'Trapezoid - 301';
		assetToIssueShape[ 'SH302' ] = 'Trapezoid - 302';
		
		console.log( 'setAssetToIssueShape-assetToIssueShape', assetToIssueShape );
		
		component.set( "v.assetToIssueShape", assetToIssueShape );
	},
})