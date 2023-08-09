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
                console.log('-- After selected -- ',response);
                var postalCode = '', state = '', country= '', city = '', street = '', street_number = '', route = '', subLocal1 = '', subLocal2 = '';
                
                for(var i=0; i < response.result.address_components.length ; i++){
                    var FieldLabel = response.result.address_components[i].types[0];
                    var FieldLabel1 = response.result.address_components[i].types[2];
                    console.log('-- Fields -- ', FieldLabel);
                    //debugger;
                     if(FieldLabel1 ==  'political')
                     {
                       city = response.result.address_components[i].long_name;  
                     }
                    if(FieldLabel == 'sublocality_level_2' || FieldLabel == 'sublocality_level_1' || 
                       	FieldLabel == 'street_number' || FieldLabel == 'route' || FieldLabel == 'locality' || FieldLabel1 == 'political' ||
                       		FieldLabel == 'country' || FieldLabel == 'postal_code' || FieldLabel == 'administrative_area_level_1'){
                        
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
                console.log('Response before JSON ',response.getReturnValue());
                var response = JSON.parse(response.getReturnValue());
                var predictions = response.predictions;
                console.log('Predictions ',predictions);
                
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
    
    handleProductSelectEvt : function( component, helper, recordIndex, listName, fieldName, recordProductWrapper ) {
        
        if( recordIndex < 0 || !listName || !fieldName || !recordProductWrapper || !recordProductWrapper.recordProduct ) {
            return;
        }
        //debugger;
        var listOfIssueRecordWrappers = JSON.parse( JSON.stringify( component.get( "v.partRequestList") ) );
        //console.log( 'handleProductSelectEvt-listOfIssueRecordWrappers', listOfIssueRecordWrappers );
        
        if( !listOfIssueRecordWrappers || listOfIssueRecordWrappers.length < recordIndex ) {
            return;
        }
        
        var recordIssueWrapper = listOfIssueRecordWrappers[ recordIndex ];
        console.log( 'handleProductSelectEvt-recordIssueWrapper', recordIssueWrapper )
        
        recordIssueWrapper.Name = recordProductWrapper.recordProduct.Name;
        recordIssueWrapper.Product__c = recordProductWrapper.recordProduct.Id;
        //recordIssueWrapper.listPrice = recordProductWrapper.listPrice;
        
       component.set( "v.partRequestList", listOfIssueRecordWrappers );
    },
    
    openProductLookupModal : function( component, helper, headerText, recordIndex,
                                      searchKeyword, productFamily, listName, fieldName, 
                                      opportunityPricebook2Id, currencyIsoCode
                                     ) {
        
        
        $A.createComponent( 'c:ProductLookupCmp', {
            'headerText' : headerText,
            'recordIndex' : recordIndex,
            'searchKeyword' : searchKeyword,
            'productFamily' : productFamily,
            'listName' : listName,
            'fieldName' : fieldName,
            'opportunityPricebook2Id' : opportunityPricebook2Id,
            'currencyIsoCode' : currencyIsoCode
        },
                           function( modalComponent, status, errorMessage ) {
                               
                               if( status === "SUCCESS" ) {
                                   
                                   var showChildModalDiv = component.find( 'showProductLookupModal' );
                                   if( showChildModalDiv ) {
                                       var body = showChildModalDiv.get( "v.body" );
                                       body.push( modalComponent );
                                       component.find( 'showProductLookupModal' ).set( "v.body", body );
                                   }
                               } 
                               else if ( status === "INCOMPLETE" ) {
                                   helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get("$Label.c.Internal_Issue_Or_Client_Offline") );
                               } 
                                   else if ( status === "ERROR" ) {
                                       helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get("$Label.c.Something_Went_Wrong_Try_Again") );
                                   }
                           }); 
    },
    
    createObjectData: function(component, event) {
        
        var RowItemList = component.get("v.partRequestList");
        RowItemList.push({
            'sobjectType': 'ProductRequest',
            'Product__c': '',
            'Quantity__c': '',
            'Description': ''
            
        });
        // set the updated list to attribute (contactList) again    
        component.set("v.partRequestList", RowItemList);
        console.log('Add Call');
        
         var serRec = component.get('v.getServiceRes');
        component.set('v.shippingName',serRec.Shipping_Contact_Name__c);
        component.set('v.shippingPhone',serRec.Shipping_Contact_Number__c);
        component.set('v.addressDetailsStreet1',serRec.Shipping_Street_1__c);
        component.set('v.addressDetailsStreet2', serRec.Shipping_Street_2__c);
        component.set('v.addressDetailsCity',serRec.Shipping_City__c);
        component.set('v.addressDetailsState',serRec.Shipping_State_Province__c);
        component.set('v.addressDetailsPostalCode',serRec.Shipping_Postal_Code__c);
        component.set('v.addressDetailsCountry',serRec.Shipping_Country__c);
    },
    
    addProdRecord : function(component, event) {
        
        var prList = component.get("v.partRequestList");
        console.log(' Pr list ',prList);
        var prDrop =[];        
        console.log('Size ',prList.length);
       prList.push({
            'sobjectType': 'ProductRequest',
            'Product__c': '',
            'Quantity__c': '',
            'Description': ''
            
        });
        prDrop = prList;
        component.set("v.partRequestList", prDrop); 
    },
    
    submitForPreEmpProductRequest : function(component,event,helper)
    {
        console.log('Product Id\'s ' + component.get("v.productId")); // Event
        var prodIdSelected = component.get("v.productId"); // 1 array
        var quantityAndDesSel = component.get("v.partRequestList"); // 2 array
        
        console.log('Product Id\'s ', prodIdSelected ,' Quantity and Desc ', quantityAndDesSel);
        /*
        for(var i=0; i < prodIdSelected.length; i++ )
        {
            quantityAndDesSel[i].Product__c = prodIdSelected[i];
        }
        */
        console.log("***", quantityAndDesSel)
        
        console.log(component.get("v.requestedDate"));
        console.log('Trunk Id ',component.get('v.selectedRecord'));
        console.log('Trunk Name ',component.get('v.value'));
        console.log('SR ID ',component.get('v.serResRecId')); 
        
        var serRedId = component.get('v.serResRecId');
        var trunkId = component.get('v.getServiceRes.LocationId');
        var reqDate = component.get("v.requestedDate");
        var street = component.get('v.addressDetailsStreet1') + ' ' +component.get('v.addressDetailsStreet2');
        //var street2 = component.get('v.addressDetailsStreet2');
        var city = component.get('v.addressDetailsCity');
        var state = component.get('v.addressDetailsState');
        var postalcode = component.get('v.addressDetailsPostalCode');
        var country = component.get('v.addressDetailsCountry');
        var preEmpSelected = quantityAndDesSel;
        var shippingConName = component.get('v.shippingName');
        var shippingConPhone = component.get('v.shippingPhone');
        console.log('149 **** ',preEmpSelected);
        //console.log('Service Rec Id '+serRedId + 'Trunk '+ trunkId+ ' Requested Date '+reqDate+ ' street '+street +' state '+state);
		
		for(var i = 0; i < preEmpSelected.length; i++)
        {
            var prValidate = preEmpSelected[i];
            if(!prValidate.Product__c || !prValidate.Quantity__c)
            {
                helper.showToastMessage('error', 'Missing!', 'Select Product and Quantity on line '+ (i + 1));
                return false;
                
            }
        }
        // Requested date validate
        if(reqDate == null)
        {
          helper.showToastMessage('error', 'Missing!', 'Request Date cannot be blank.');
            return false;
        }
        // Shipping address
        if(street == null || street == 'undefined undefined' || street == 'undefined' || street =='')
        {
            helper.showToastMessage('error', 'Missing!', 'Delivery address is required');
            return false;
        }
                
       
        var dateValue;
        var requitedDateInvalid;
        var todayDate = helper.parseDateToString(new Date());
        console.log('todayDate', todayDate);
        
        var tomorrowDate = new Date();
        tomorrowDate.setDate(tomorrowDate.getDate() + 1);
        tomorrowDate = helper.parseDateToString(tomorrowDate);
        console.log('tomorrowDate', tomorrowDate);
        /*
        dateValue = helper.parseDateToString(reqDate);
        console.log('Required data value ', dateValue);
        */
        var strDate = '' + $A.localizationService.formatDate(new Date(), "YYYY-MM-DD, hh:mm:ss a");
        console.log('strDate', strDate);
        
        var isThisPostMeridiem = strDate.includes('PM');
        console.log('isThisPostMeridiem::', isThisPostMeridiem);
        
        dateValue = new Date(reqDate);
        
        
            
        if (dateValue != 'Invalid Date' && isNaN(dateValue) == false) {
            
            dateValue = reqDate;
            if (dateValue <= todayDate) {
                helper.showToastMessage('error', 'Error!', 'Request Date can only be a future date.');
                return false;
            }
            else if (dateValue == tomorrowDate && isThisPostMeridiem) {
                helper.showToastMessage('error', 'Error!', 'You can only request for next-day delivery before 12 PM Pacific Time. Please select a future Request Date.');
                return false;
            }
                else 
                {
                    requitedDateInvalid = true;
                }
            
        }
       
      /*  
        if (dateValue <= todayDate) {
            helper.showToastMessage('error', 'Error!', 'Request Date can only be a future date.');
            requitedDateInvalid = false;
            //return false;
        }
        else if (dateValue == tomorrowDate && isThisPostMeridiem) {
            helper.showToastMessage('error', 'Error!', 'You can only request for next-day delivery before 12 PM Pacific Time. Please select a future Request Date.');
            requitedDateInvalid = false;
            //return false;
        }
            else 
            {
                requitedDateInvalid = true;
            }
        
        */
        
        if(requitedDateInvalid)
        {
            
            var actionProductRequest = component.get("c.createPreEmptiveParts");
            actionProductRequest.setParams({
                'srId': serRedId,
                'trunkId' : trunkId,
                'reqDate' : reqDate,
                'street' : street,
                'city' : city,
                'state' :state,
                'postcode' : postalcode,
                'country' : country,
                'preEmpSelected' : quantityAndDesSel,
                'shippingConName': shippingConName,
                'shippingConPhone' : shippingConPhone
            });
            
            actionProductRequest.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS")
                {
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The record has been created successfully."
                    });
                    toastEvent.fire();
                    
                    // Close the tab in console
                    var workspaceAPI = component.find("workspace");
                    workspaceAPI.getFocusedTabInfo().then(function(response) {
                        var focusedTabId = response.tabId;
                        workspaceAPI.closeTab({tabId: focusedTabId});
                    })
                    .catch(function(error) {
                        console.log(error);
                    });
                    
                    var urlEvent = $A.get("e.force:navigateToURL");
                    urlEvent.setParams({
                        "url": "/"+serRedId
                    });
                    urlEvent.fire();
                    console.log('Success ');
                }
                else if(state === "ERROR")
                {
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    // Retrieve the error message sent by the server
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message": message
                    });
                    toastEvent.fire();
                }
            });
            $A.enqueueAction(actionProductRequest);
            
        }
    },
    
    cancelPartRequest : function(component,event,helper)
    {
         // Close the tab in console
        var workspaceAPI = component.find("workspace");
        workspaceAPI.getFocusedTabInfo().then(function(response) {
            var focusedTabId = response.tabId;
            workspaceAPI.closeTab({tabId: focusedTabId});
        })
        .catch(function(error) {
            console.log(error);
        });
        
        var serRedId = component.get('v.serResRecId');
        var urlEvent = $A.get("e.force:navigateToURL");
        urlEvent.setParams({
            "url": "/"+serRedId
        });
        urlEvent.fire();
        
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