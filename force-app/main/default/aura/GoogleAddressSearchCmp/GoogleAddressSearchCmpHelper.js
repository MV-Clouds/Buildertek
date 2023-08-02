/*
	@ PURPOSE : 1. PROVIDES SERVICE TO => GoogleAddressSearchCmpController.js
				2. MAKES CALLS TO APEX SERVER.
	@ Name    : GoogleAddressSearchCmpHelper.js
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
    
    saveAddress : function( component, event, helper ) {
        var fromComponent=component.get( "v.fromComponent" );
        var recordIssue = JSON.parse( JSON.stringify( component.get( "v.recordIssue" ) ) );
        if(!fromComponent){
            if( !recordIssue || !recordIssue.Shipping_Street_1__c ||
               !recordIssue.Shipping_City__c || !recordIssue.Shipping_State_Province__c ||
               !recordIssue.Shipping_Postal_Code__c || !recordIssue.Shipping_Country__c
              ) {
                helper.showToastMessage( 'error', 'Shipping Information Missing',$A.get("$Label.c.Provide_Shipping_Address_Details") );
                return;
            }
        }else{
            if( !recordIssue || !recordIssue.Shipping_Street_1 ||
               !recordIssue.Shipping_City || !recordIssue.Shipping_State_Province ||
               !recordIssue.Shipping_Postal_Code || !recordIssue.Shipping_Country
              ) {
                helper.showToastMessage( 'error', 'Shipping Information Missing',$A.get("$Label.c.Provide_Shipping_Address_Details"));
                return;
            }
        }
        
        
        
        var recordIndex = component.get( "v.recordIndex" );
        var listName = component.get( "v.listName" );
        var objectName = component.get( "v.objectName" );
        
        if(component.get("v.componentName") === 'IGU'){
            var googleAddressSearchModalEvtForIGU = component.getEvent( "googleAddressSearchModalEvtForIGU" );
            console.log( 'saveAddress-googleAddressSearchModalEvtForIGU', googleAddressSearchModalEvtForIGU );
            if( !googleAddressSearchModalEvtForIGU ) {
                return;
            }
            googleAddressSearchModalEvtForIGU.setParams({
                'recordIndex' : recordIndex,
                'listName' : listName,
                'objectName' : objectName,
                'recordIssue' : recordIssue
            });
            
            googleAddressSearchModalEvtForIGU.fire();
        }else if(component.get("v.componentName") === 'CHW'){
            var googleAddressSearchModalEvtForCHW = component.getEvent( "googleAddressSearchModalEvtForCHW" );
            console.log( 'saveAddress-googleAddressSearchModalEvtForCHW', googleAddressSearchModalEvtForCHW );
            if( !googleAddressSearchModalEvtForCHW ) {
                return;
            }
            googleAddressSearchModalEvtForCHW.setParams({
                'recordIndex' : recordIndex,
                'listName' : listName,
                'objectName' : objectName,
                'recordIssue' : recordIssue
            });
            
            googleAddressSearchModalEvtForCHW.fire();
        }else{
			var googleAddressSearchModalEvt = component.getEvent( "googleAddressSearchModalEvt" );
            console.log( 'saveAddress-googleAddressSearchModalEvt', googleAddressSearchModalEvt );
            if( !googleAddressSearchModalEvt ) {
                return;
            }
            googleAddressSearchModalEvt.setParams({
                'recordIndex' : recordIndex,
                'listName' : listName,
                'objectName' : objectName,
                'recordIssue' : recordIssue
            });
            
            googleAddressSearchModalEvt.fire();
            
        }
        helper.closeModal( component );
    },
    
    setAddressDetailsOnIssue : function( component, helper, listOfAddressComponents ) {
        
        if( !listOfAddressComponents || listOfAddressComponents.length == 0 ) {
            return;
        }
        
        var street_number = '', route = '', subLocal1 = '', subLocal2 = '';
        var recordIssue = {};
        
        for( var index = 0; index < listOfAddressComponents.length ; index ++ ) {
            var addressComponent = listOfAddressComponents[ index ];
            var fieldLabel = addressComponent.types[ 0 ];
            console.log( 'fieldLabel,' + fieldLabel );
            
            if( fieldLabel == 'sublocality_level_2' || fieldLabel == 'sublocality_level_1' ||
               fieldLabel == 'street_number' || fieldLabel == 'route' || fieldLabel == 'locality' ||
               fieldLabel == 'country' || fieldLabel == 'postal_code' || fieldLabel == 'administrative_area_level_1'
              ) {
                switch( fieldLabel ) {
                    case 'sublocality_level_2':
                        subLocal2 = addressComponent.long_name;
                        break;
                    case 'sublocality_level_1':
                        subLocal1 = addressComponent.long_name;
                        break;
                    case 'street_number':
                        street_number = addressComponent.long_name;
                        break;
                    case 'route':
                        route = addressComponent.short_name;
                        break;
                    case 'postal_code':
                        recordIssue.Shipping_Postal_Code__c = addressComponent.long_name;
                        break;
                    case 'administrative_area_level_1':
                        recordIssue.Shipping_State_Province__c = addressComponent.short_name;
                        break;
                    case 'country':
                        recordIssue.Shipping_Country__c = addressComponent.long_name;
                        break;
                    case 'locality':
                        recordIssue.Shipping_City__c = addressComponent.long_name;
                        break;
                    default:
                        break;
                }
            }
        }
        
        recordIssue.Shipping_Street_1__c = street_number + ' ' + route;
        if( !recordIssue.Shipping_Street_1__c ) {
            recordIssue.Shipping_Street_1__c = subLocal2 + ' ' + subLocal1;
        }
        else {
            recordIssue.Shipping_Street_2__c = subLocal2 + ' ' + subLocal1;
        }
        component.set( "v.recordIssue", recordIssue );
    },
    
    getPredictions : function( component, helper, searchKeyword ) {	        
        
        console.log( 'getPredictions-searchKeyword', searchKeyword );
        
        if( !searchKeyword || searchKeyword.length < 3 ) {
            return;
        }
        
        var serverAction = component.get( "c.fetchPredictions" );
        if( !serverAction ) {
            return;
        }
        component.set( "v.showSpinner", true );
        
        serverAction.setParams({ 
            "searchKeyword" : searchKeyword
        });
        
        serverAction.setCallback( this, function( response ) {
            
            component.set( "v.showSpinner", false );
            
            var state = response.getState();
            if ( state === "SUCCESS" ) {
                
                var result = JSON.parse( response.getReturnValue() );
                console.log( "getPredictions", result );
                
                if( result.isSucceeded ) {
                    var res = JSON.parse( result.jsonPredictions );
                    console.log( 'getPredictions-res', res );
                    component.set( "v.predictions", res.predictions );
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
    
    getPlaceDetails : function( component, helper, placeId ) {
        var fromComponent=component.get("v.fromComponent");
        console.log( 'getPlaceDetails-placeId', placeId );
        
        if( !placeId ) {
            return;
        }
        
        var serverAction = component.get( "c.fetchPlaceDetails" );
        if( !serverAction ) {
            return;
        }
        component.set( "v.showSpinner", true );
        
        serverAction.setParams({ 
            "placeId" : placeId
        });
        
        serverAction.setCallback( this, function( response ) {
            
            component.set( "v.showSpinner", false );
            
            var state = response.getState();
            if ( state === "SUCCESS" ) {
                
                var result = JSON.parse( response.getReturnValue() );
                console.log( "getPlaceDetails", result );
                
                if( result.isSucceeded ) {
                    var recordPlace = JSON.parse( result.jsonPlaceDetails );
                    console.log( 'getPlaceDetails-res', recordPlace );
                    
                    if( !recordPlace || !recordPlace.result &&
                       !recordPlace.result.address_components || recordPlace.result.address_components.length == 0 ) {
                        return;
                    }
                    
                    component.set( "v.location", recordPlace.result.name );
                    component.set( "v.predictions", [] );
                    if(!fromComponent){
                        helper.setAddressDetailsOnIssue( component, helper, recordPlace.result.address_components );
                    }else{
                        helper.setAddressDetailsOnIssueLogissue( component, helper, recordPlace.result.address_components );
                        
                    }
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
    setAddressDetailsOnIssueLogissue : function( component, helper, listOfAddressComponents ) {
        
        if( !listOfAddressComponents || listOfAddressComponents.length == 0 ) {
            return;
        }
        
        var street_number = '', route = '', subLocal1 = '', subLocal2 = '';
        var recordIssue = {};
        
        for( var index = 0; index < listOfAddressComponents.length ; index ++ ) {
            var addressComponent = listOfAddressComponents[ index ];
            var fieldLabel = addressComponent.types[ 0 ];
            console.log( 'fieldLabel,' + fieldLabel );
            
            if( fieldLabel == 'sublocality_level_2' || fieldLabel == 'sublocality_level_1' ||
               fieldLabel == 'street_number' || fieldLabel == 'route' || fieldLabel == 'locality' ||
               fieldLabel == 'country' || fieldLabel == 'postal_code' || fieldLabel == 'administrative_area_level_1'
              ) {
                switch( fieldLabel ) {
                    case 'sublocality_level_2':
                        subLocal2 = addressComponent.long_name;
                        break;
                    case 'sublocality_level_1':
                        subLocal1 = addressComponent.long_name;
                        break;
                    case 'street_number':
                        street_number = addressComponent.long_name;
                        break;
                    case 'route':
                        route = addressComponent.short_name;
                        break;
                    case 'postal_code':
                        recordIssue.Shipping_Postal_Code = addressComponent.long_name;
                        break;
                    case 'administrative_area_level_1':
                        recordIssue.Shipping_State_Province = addressComponent.short_name;
                        break;
                    case 'country':
                        recordIssue.Shipping_Country = addressComponent.long_name;
                        break;
                    case 'locality':
                        recordIssue.Shipping_City = addressComponent.long_name;
                        break;
                    default:
                        break;
                }
            }
        }
        
        recordIssue.Shipping_Street_1 = street_number + ' ' + route;
        if( !recordIssue.Shipping_Street_1 ) {
            recordIssue.Shipping_Street_1 = subLocal2 + ' ' + subLocal1;
        }
        else {
            recordIssue.Shipping_Street_2 = subLocal2 + ' ' + subLocal1;
        }
        component.set( "v.recordIssue", recordIssue );
    },
    
})