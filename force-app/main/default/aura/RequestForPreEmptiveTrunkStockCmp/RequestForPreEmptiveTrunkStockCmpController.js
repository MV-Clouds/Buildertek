({
    // To prepopulate the seleted value pill if value attribute is filled
	doInit : function( component, event, helper ) {
    	// create a Default RowItem [Contact Instance] on first time Component Load
        // by call this helper function  
        helper.createObjectData(component, event);
	},

    // When a keyword is entered in search box
	searchRecords : function( component, event, helper ) {
        if( !$A.util.isEmpty(component.get('v.searchString')) ) {
		    helper.searchRecordsHelper( component, event, helper, '' );
        } else {
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
	},
    
    openProductLookupModal : function( component, event, helper ) {
		
		var keyCode = event.which;
		console.log( 'openProductLookup-key', keyCode );
		if( keyCode == 13 ) {
			
			var recordIndex = event.target.id;
			console.log( 'openProductLookup-recordIndex', recordIndex );
			
			var searchKeyword = event.target.value;
			console.log( 'openProductLookup-searchKeyword', searchKeyword );
		
			helper.openProductLookupModal( component, helper, 'Product Selection', recordIndex, searchKeyword,
										   'CSS', 'listOfPartRequestedWrappers', 'Product','','');
		}
	},
    
    handleProductSelectEvt : function( component, event, helper ) {
		//debugger;
		var recordIndex = event.getParam( "recordIndex" );
		console.log( 'handleProductSelectEvt-recordIndex', recordIndex );
		if( recordIndex < 0 ) {
			return;
		}
		
		var listName = event.getParam( "listName" );
		console.log( 'handleProductSelectEvt-listName', listName );
		if( !listName ) {
			return;
		}
		
		var fieldName = event.getParam( "fieldName" );
		console.log( 'handleProductSelectEvt-fieldName', fieldName );
		if( !fieldName ) {
			return;
		}
		
		var recordProductWrapper = JSON.parse( JSON.stringify( event.getParam( "recordProductWrapper" ) ) );
		console.log( 'handleProductSelectEvt-recordProductWrapper', recordProductWrapper );
		if( !recordProductWrapper ) {
			return;
		}
		
		helper.handleProductSelectEvt( component, helper, recordIndex, listName, fieldName, recordProductWrapper );
	},
    
    handleComponentEvent : function(component,event,helper)
    {
        var trunkProdPre = event.getParam("returnProduct");
        var trunkProdId = event.getParam("productId");
        component.set("v.partRequestList.Product",trunkProdId);
		var vProdId = component.get("v.productId");
			vProdId.push(trunkProdId);
        
        console.log('Prod ID ',component.get("v.productId"));
        
        // Delete rows 
        console.log('Product Id\'s ' + component.get("v.productId")); // Event
        var prodIdSelected = component.get("v.productId"); // 1 array
        var quantityAndDesSel = component.get("v.partRequestList"); // 2 array
        
        console.log('Product Id\'s ', prodIdSelected ,' Quantity and Desc ', quantityAndDesSel);
        
        for(var i=0; i < prodIdSelected.length; i++ )
        {
            quantityAndDesSel[i].Product__c = prodIdSelected[i];
        }
        
        console.log("***", quantityAndDesSel)
        component.set("v.partRequestList",quantityAndDesSel);        
    },
    
    removeRow: function(component, event, helper) {
        //Get the account list
        var prList = component.get("v.partRequestList");
     	console.log('Before delete ', prList);
        //Get the target object
        var selectedItem = event.currentTarget;
        //Get the selected item index
        var index = selectedItem.dataset.record;
        console.log('Index ',index);
        prList.splice(index, 1);
        component.set("v.partRequestList", prList);
        console.log('After delete ', component.get("v.partRequestList"));
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
       helper.submitForPreEmpProductRequest(component,event,helper);
    },
    
    cancelPartRequest : function(component,event,helper)
    {
       helper.cancelPartRequest(component,event,helper); 
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
        
        /*
        var spinner = component.find('spinner');
        var evt = spinner.get("e.toggle");
        evt.setParams({ isVisible : false });
        evt.fire();  */  
         component.set("v.Spinner", false);
    },
    
    addRow: function(component, event, helper) {
        helper.addProdRecord(component, event);
    },
    
    
})