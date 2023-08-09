({
	searchRecordsHelper : function(component, event, helper, value) {
		$A.util.removeClass(component.find("Spinner"), "slds-hide");
        var searchString = component.get('v.searchString');
        component.set('v.message', '');
        component.set('v.recordsList', []);
		// Calling Apex Method
    	var action = component.get('c.fetchRecords');
        action.setParams({
            'objectName' : component.get('v.objectName'),
            'filterField' : component.get('v.fieldName'),
            'searchString' : searchString,
            'value' : value
        });
        action.setCallback(this,function(response){
        	var result = response.getReturnValue();
        	if(response.getState() === 'SUCCESS') {
    			if(result.length > 0) {
    				// To check if value attribute is prepopulated or not
					if( $A.util.isEmpty(value) ) {
                        component.set('v.recordsList',result);        
					} else {
                        component.set('v.selectedRecord', result[0]);
					}
    			} else {
    				component.set('v.message', "No Records Found for '" + searchString + "'");
    			}
        	} else {
                // If server throws any error
                var errors = response.getError();
                if (errors && errors[0] && errors[0].message) {
                    component.set('v.message', errors[0].message);
                }
            }
            // To open the drop down list of records
            if( $A.util.isEmpty(value) )
                $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        	$A.util.addClass(component.find("Spinner"), "slds-hide");
        });
        $A.enqueueAction(action);
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
                    console.log("Prediction address ",component.get("v.predictions"));
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
    
    clearAddressList : function(component) {
        console.log("Clearing the list!");
        component.set('v.searchKey', null)
        component.set('v.AddressList', null);
    }, 
   
    //get address details by place Id from google API 
    getAddressDetailsByPlaceId: function(component,event){
        var selectedValue = event.currentTarget.dataset.value;
        var action = component.get("c.getAddressDetailsByPlaceId");
        action.setParams({
            PlaceID:selectedValue 
        });
        action.setCallback(this, function(response){
            var res = response.getState();
            if(res == 'SUCCESS'){
                //console.log(response.getReturnValue());
                var response = JSON.parse(response.getReturnValue());
                var postalCode = '', state = '', country= '', city = '', street = '', street_number = '', route = '', subLocal1 = '', subLocal2 = '';
                
                
                for(var i=0; i < response.result.address_components.length ; i++){
                    var FieldLabel = response.result.address_components[i].types[0];
                    var FieldLabel1 = response.result.address_components[i].types[2];
                    //console.log(FieldLabel);
                    //debugger;
                    if(FieldLabel1 ==  'political')
                     {
                       city = response.result.address_components[i].long_name;  
                     }
                    
                    if(FieldLabel == 'sublocality_level_2' || FieldLabel == 'sublocality_level_1' || FieldLabel == 'street_number'
                       	|| FieldLabel == 'route' || FieldLabel == 'locality' || FieldLabel == 'country'  || FieldLabel1 == 'political'
                       		|| FieldLabel == 'postal_code' || FieldLabel == 'administrative_area_level_1'){
                        switch(FieldLabel){
                            case 'sublocality_level_2':
                                subLocal2 = response.result.address_components[i].long_name;
                                break;
                            case 'sublocality_level_1':
                                subLocal1 = response.result.address_components[i].long_name;
                                break;
                            case 'street_number':
                                street_number = response.result.address_components[i].long_name;
                                break;
                            case 'route':
                                route = response.result.address_components[i].short_name;
                                break;
                            case 'postal_code':
                                postalCode = response.result.address_components[i].long_name;
                                break;
                            case 'administrative_area_level_1':
                                state = response.result.address_components[i].short_name;
                                break;
                            case 'country':
                                country = response.result.address_components[i].long_name;
                                break;
                            case 'locality':
                                city = response.result.address_components[i].long_name;
                                break;
                            default:
                                break;
                        }
                    }
                }
                
                street = street_number + ' ' + route;
                if(street == null){
                    street = subLocal2 + ' ' + subLocal1;
                }
                console.log(street);
                component.set('v.addressDetailsStreet1', street);
                component.set('v.addressDetailsStreet2', '');
                component.set('v.addressDetailsPostalCode', postalCode);
                component.set('v.addressDetailsState', state);
                component.set('v.addressDetailsCountry', country);
                component.set('v.addressDetailsCity', city);
                component.set("v.searchKey", null);
                component.set("v.showModalBox", false);
               
            }
        });
        $A.enqueueAction(action);
    },
    getAddressRecommendations: function(component, event){
        var key = component.get("v.searchKey");
        var action = component.get("c.getAddressSet");
        action.setParams({
            "SearchText": key
        });
        
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var response = JSON.parse(response.getReturnValue());
                var predictions = response.predictions;
                var addresses = [];
                if (predictions.length > 0) {
                    for (var i = 0; i < predictions.length; i++) {
                        var bc =[];
                        addresses.push(
                            {
                                main_text: predictions[i].structured_formatting.main_text, 
                                secondary_text: predictions[i].structured_formatting.secondary_text,
                                place_id: predictions[i].place_id
                            });
                        
                    }
                }
                for(var i=0; i <addresses.length; i++){
                    console.log(addresses[i].main_text);
                    console.log(addresses[i].secondary_text);
                    console.log(addresses[i].place_id);
                }
                component.set("v.AddressList", addresses);
            }
        });
        $A.enqueueAction(action);
    },
     parseDateToString: function (dateValue) {
        
        var todayDate = '';
        var dateValue = new Date(dateValue);
        
        if (dateValue == 'Invalid Date' || isNaN(dateValue)) {
            return todayDate;
        }
        
        todayDate = dateValue.getFullYear();
        
        var monthValue = dateValue.getMonth() + 1;
        if (monthValue < 10) {
            monthValue = '0' + monthValue;
        }
        
        var dayValue = dateValue.getDate();
        if (dayValue < 10) {
            dayValue = '0' + dayValue;
        }
        
        todayDate += '-' + monthValue + '-' + dayValue;
        return todayDate;
    },
    
    showToastMessage: function (type, title, message) {
        
        if (type && title && message) {
            var toastEvent = $A.get("e.force:showToast");
            
            if (toastEvent) {
                toastEvent.setParams({
                    'type': type,
                    'title': title,
                    'message': message,
                    'duration': 8000
                });
                toastEvent.fire();
            }
        }
    },
})