({
    // To prepopulate the seleted value pill if value attribute is filled
    doInit : function( component, event, helper ) {
        $A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
        if( !$A.util.isEmpty(component.get('v.value')) ) {
            helper.searchRecordsHelper( component, event, helper, component.get('v.value') );
            console.log('Service Resource Rec Id 7 ',component.get("v.serResRecId"));
        }
        var serRec = component.get('v.getServiceRes');
        
        component.set('v.shippingName',serRec.Shipping_Contact_Name__c);
        component.set('v.shippingPhone',serRec.Shipping_Contact_Number__c);
        
        component.set('v.addressDetailsStreet1',serRec.Shipping_Street_1__c);
        component.set('v.addressDetailsStreet2',serRec.Shipping_Street_2__c);
        component.set('v.addressDetailsCity',serRec.Shipping_City__c);
        component.set('v.addressDetailsState',serRec.Shipping_State_Province__c);
        component.set('v.addressDetailsPostalCode',serRec.Shipping_Postal_Code__c);
        component.set('v.addressDetailsCountry',serRec.Shipping_Country__c);
        
        
        console.log('Service Resource Rec Id 9 ',component.get("v.serResRecId"));
    },
    showSpinner : function (component, event, helper) {
        /*
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : true });
        evt.fire();
        */
        component.set("v.Spinner", true);
    },
    hideSpinner : function (component, event, helper) {
        /*var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();  */  
        component.set("v.Spinner", false);
    },
    
    // When a keyword is entered in search box
    searchRecords : function( component, event, helper ) {
        if( !$A.util.isEmpty(component.get('v.searchString')) ) {
            helper.searchRecordsHelper( component, event, helper, '' );
        } else {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    
    // When an item is selected
    selectItem : function( component, event, helper ) {
        console.log('Event Targer Id ',event.currentTarget.id);
        if(!$A.util.isEmpty(event.currentTarget.id)) {
            var recordsList = component.get('v.recordsList');
            var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
            if(index != -1) {
                var selectedRecord = recordsList[index];
            }
            component.set('v.selectedRecord',selectedRecord);
            component.set('v.value',selectedRecord.value);
            console.log('Selected Rec ',component.get('v.selectedRecord'));
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    
    // When an address is selected
    selectItemAddress : function( component, event, helper ) {
        console.log('Event target Id ',event.currentTarget.id);
        //if(!$A.util.isEmpty(event.currentTarget.id)) {
        var recordsList = component.get('v.predictions');
        var index = recordsList.findIndex(x => x.description )
        console.log('index ',index);
        if(index != -1) {
            var selectedRecord = recordsList[index];
        }
        component.set('v.selectedRecordAddress',selectedRecord);
        component.set('v.valueAddress',selectedRecord.description);
        console.log('selected address ',component.get("v.valueAddress"));
        console.log('selected address 2 ',component.get("v.selectedRecordAddress"));
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        // }
    },
    
    showRecords : function( component, event, helper ) {
        
        if(!$A.util.isEmpty(component.get('v.recordsList')) && !$A.util.isEmpty(component.get('v.searchString'))) {
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
            console.log('Selected Trunk User ',component.get('v.searchString'));
        }
        console.log('Selected Trunk User 59 ',component.get('v.selectedRecord.value'));
    },
    
    // To remove the selected item.
    removeItem : function( component, event, helper ){
        component.set('v.selectedRecord','');
        component.set('v.value','');
        component.set('v.searchString','');
        setTimeout( function() {
            component.find( 'inputLookup' ).focus();
        }, 250);
    },
    
    // To close the dropdown if clicked outside the dropdown.
    blurEvent : function( component, event, helper ){
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    },
    getPredictions : function( component, event, helper ) {	        
        
        var searchKeyword = component.get( "v.location" );
        console.log('Search word ',searchKeyword);
        helper.getPredictions( component, helper, searchKeyword );
    },
    
    //Show the modal window on click in the input field
    OpenModal : function(component, event, helper) {
        component.set('v.AddressList', null);
        component.set("v.showModalBox", true);
    }, 
    //close the modal window on click of cancel button
    closeModal: function(component, event, helper) {
        component.set("v.showModalBox", false);
    }, 
    //Clear the address list on the user interface
    clear: function(component, event, helper) {
        helper.clearAddressList(component, event);
    }, 
    
    //Get city, state, country and other details from selected address
    selectOption:function(component, event, helper) {
        helper.getAddressDetailsByPlaceId(component, event);
    }, 
    //On search of address get address list from the API
    keyPressController: function(component, event, helper) {
        helper.getAddressRecommendations(component,event);
    },
    
    // Submit Order 
    submitForOrderCreation : function(component,event,helper)
    {
        console.log('trunk id ',component.get('v.getServiceRes.LocationId'));
        console.log('trunk id ',component.get('v.getServiceRes.Location.Name'));
        console.log(component.get("v.requestedDate"));
        console.log('Trunk Id ',component.get('v.selectedRecord'));
        console.log('Trunk Name ',component.get('v.value'));
        console.log('SR ID ',component.get('v.serResRecId')); 
        console.log('Shipping con name ', component.get('v.shippingName'));
        console.log('Shipping con phone ', component.get('v.shippingPhone'));
        //alert('Shippdetails ');
        var serRedId = component.get('v.serResRecId');
        var trunkId = component.get('v.getServiceRes.LocationId');
        var reqDate = component.get("v.requestedDate");
        var street = component.get('v.addressDetailsStreet1');
        var city = component.get('v.addressDetailsCity');
        var state = component.get('v.addressDetailsState');
        var postalcode = component.get('v.addressDetailsPostalCode');
        var country = component.get('v.addressDetailsCountry');
        var shippingConName = component.get('v.shippingName');
        var shippingConPhone = component.get('v.shippingPhone');
        var newfseProd = component.get('v.getProducts');
        
        for(var i = 0; i < newfseProd.length; i++)
        {	
            var fsePrLst = newfseProd[i];
            if(fsePrLst.prSku == null || fsePrLst.prQuantity == null)
            {
                helper.showToastMessage('error', 'Missing!', 'Inactive Product Name - '+fsePrLst.prName+'. '+'Reachout to Salesforce Admin');
                requitedDateInvalid = false;
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
        console.log('isThisPostMeridiem', isThisPostMeridiem);
        
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
            var createNewFSE = component.get('c.createNewFseParts');
            
            createNewFSE.setParams({
                
                'srId': serRedId,
                'trunkId' : trunkId,
                'reqDate' : reqDate,
                'street' : street,
                'city' : city,
                'state' : state,
                'postcode' : postalcode,
                'country' : country,
                'shippingConName': shippingConName,
                'shippingConPhone' : shippingConPhone
                
            });
            createNewFSE.setCallback(this, function(response){
                var state = response.getState();
                if(state === "SUCCESS")
                {
                    
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Success!",
                        "message": "The record has been created successfully."
                    });
                    toastEvent.fire();

                    // Close console tab 
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
                }
                else if(state === "ERROR")
                {
                    
                    var errors = response.getError();
                    var message = 'Unknown error'; // Default error message
                    
                    
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    } 
                    console.log('error message ',message);
                    var toastEvent = $A.get("e.force:showToast");
                    toastEvent.setParams({
                        "title": "Error!",
                        "message":  "There is an inactive product in the list. Please reach out to Salesforce Team"
                    });
                    // toastEvent.fire();
                }
            });
            $A.enqueueAction(createNewFSE); 
        }
    },
    
    cancelPartCreation : function(component,event,helper)
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
    }
    
    
    
})