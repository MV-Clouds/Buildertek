/*
	@ PURPOSE : 1. CONTROLS THE LIGHTNING COMPONENT => IssuesCreatedAndUpdate.xml
				2. CONTROLS EVENTS FIRED FROM SCREEN/COMPONENT.
	@ Name    : IssuesCreateAndUpdateController.js
*/
({
    doInit : function( component, event, helper ) {
        
		var recordId = component.get( "v.recordId" );
		console.log( 'doInit-recordId', recordId );
		
		helper.setConsoleTabSettings( component );
		helper.fetchIssues( component, recordId ); 
    },
	
	refreshIssuesTable : function( component, event, helper ) {
    	
		helper.refreshIssuesTable( component, event, helper );
    },
	
	saveIssues : function( component, event, helper ) {
		
		var recordId = component.get( "v.recordId" );
		console.log( 'saveIssues-recordId', recordId );
        helper.saveIssues( component, recordId, JSON.parse( JSON.stringify( component.get( "v.listOfIssueWrappers" ) ) ), false );
    },
	
	saveIGUIssues : function( component, event, helper ) {
        
        var recordId = component.get( "v.recordId" );
		console.log( 'saveIGUIssues-recordId', recordId );
        helper.saveIssues( component, recordId, JSON.parse( JSON.stringify( component.get( "v.listOfIGUIssueWrappers" ) ) ), true );
        
    },
	
	requestParts : function( component, event, helper ) {
		
		var listOfPartRequestedWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPartRequestedWrappers" ) ) );
        console.log( 'listOfPartRequestedWrappers', listOfPartRequestedWrappers );
        
        helper.requestParts( component, listOfPartRequestedWrappers, 1 );
    },
	
	submitPartsAndContinue : function( component, event, helper ) {
		
		var listOfPartRequestedWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPartRequestedWrappers" ) ) );
        console.log( 'listOfPartRequestedWrappers', listOfPartRequestedWrappers );
        
        helper.requestParts( component, listOfPartRequestedWrappers, 2 );
    },
	
	submitPartsAndFinish: function( component, event, helper ) {
		
		var listOfPartRequestedWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPartRequestedWrappers" ) ) );
        console.log( 'listOfPartRequestedWrappers', listOfPartRequestedWrappers );
        
        helper.requestParts( component, listOfPartRequestedWrappers, 3 );
    },
	
	cancel : function( component, event, helper ) {
        
		helper.cancel( component, helper )
    },
	
	selectAllIssues : function( component, event, helper ) {
        
		var areAllIssuesSelected = JSON.parse( JSON.stringify( component.get( "v.areAllIssuesSelected" ) ) );
        var listOfIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfIssueWrappers" ) ) );
        helper.selectAllRecordWrappers( component, areAllIssuesSelected, listOfIssueWrappers );
		component.set( "v.listOfIssueWrappers", listOfIssueWrappers );
    },
	
	selectAllIGUIssues : function( component, event, helper ) {
		
		var areAllIGUIssuesSelected = JSON.parse( JSON.stringify( component.get( "v.areAllIGUIssuesSelected" ) ) );
        var listOfIGUIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfIGUIssueWrappers" ) ) );
        helper.selectAllRecordWrappers( component, areAllIGUIssuesSelected, listOfIGUIssueWrappers );
		component.set( "v.listOfIGUIssueWrappers", listOfIGUIssueWrappers );
	},
	
	selectAllParts : function( component, event, helper ) {
        
		var areAllPartsSelected = JSON.parse( JSON.stringify( component.get( "v.areAllPartsSelected" ) ) );
        var listOfPartRequestedWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPartRequestedWrappers" ) ) );
        helper.selectAllRecordWrappers( component, areAllPartsSelected, listOfPartRequestedWrappers );
		component.set( "v.listOfPartRequestedWrappers", listOfPartRequestedWrappers );
    },
	
	clearQuoteToContactSearchedKeyword : function( component, event, helper ) {
        
        helper.clearQuoteToContactSearchedKeyword( component );
    },
	
	clearShipToContactSearchedKeyword : function( component, event, helper ) {
        
        helper.clearShipToContactSearchedKeyword( component );
    },
	
	clearTrunkSearchedKeyword : function( component, event, helper ) {
        
        var index = event.target.id;
        console.log( 'index', index );
        helper.clearTrunkSearchedKeyword( component, index );
    },
	
	handleCSSIssueRecordTypeChange : function( component, event, helper ) {
		
		if( event && event.getSource() ) {
			
			var currentRowIndex = event.getSource().get( "v.labelClass" );
			console.log( 'labelClassfddc' );
			
			if( currentRowIndex == undefined ) {
				return;
			}
			
			var listOfIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfIssueWrappers" ) ) );
			if( !listOfIssueWrappers || listOfIssueWrappers.length <= currentRowIndex ) {
				return;
			}
			
			listOfIssueWrappers = helper.handleRecordTypeChange( component, currentRowIndex, listOfIssueWrappers );
			
			if( !listOfIssueWrappers ) {
				return;
			}
			component.set( "v.listOfIssueWrappers", listOfIssueWrappers );
		}
	},
	
	handleIGUIssueRecordTypeChange : function( component, event, helper ) {
		
		if( event && event.getSource() ) {
			
			var currentIGURowIndex = event.getSource().get( "v.labelClass" );
			console.log( 'labelClassfddc' );
			
			if( currentIGURowIndex == undefined ) {
				return;
			}
			
			var listOfIGUIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfIGUIssueWrappers" ) ) );
			if( !listOfIGUIssueWrappers || listOfIGUIssueWrappers.length <= currentIGURowIndex ) {
				return;
			}
			
			listOfIGUIssueWrappers = helper.handleRecordTypeChange( component, currentIGURowIndex, listOfIGUIssueWrappers );
			
			if( !listOfIGUIssueWrappers ) {
				return;
			}
			component.set( "v.listOfIGUIssueWrappers", listOfIGUIssueWrappers );
		}
	},
	
	handleProductSelectEvt : function( component, event, helper ) {
		
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
	
	handleAssetSelectEvt : function( component, event, helper ) {
		
		var recordIndex = event.getParam( "recordIndex" );
		console.log( 'handleAssetSelectEvt-recordIndex', recordIndex );
		if( recordIndex < 0 ) {
			return;
		}
		
		var listName = event.getParam( "listName" );
		console.log( 'handleAssetSelectEvt-listName', listName );
		if( !listName ) {
			return;
		}
		
		var fieldName = event.getParam( "fieldName" );
		console.log( 'handleAssetSelectEvt-fieldName', fieldName );
		if( !fieldName ) {
			return;
		}
		
		var recordAsset = JSON.parse( JSON.stringify( event.getParam( "recordAsset" ) ) );
		console.log( 'handleAssetSelectEvt-recordAsset', recordAsset );
		if( !recordAsset ) {
			return;
		}
		
		helper.handleAssetSelectEvt( component, helper, recordIndex, listName, fieldName, recordAsset );
	},
	
	handleFailureModeMultiSelectEvt : function( component, event, helper ) {
		
		var recordIndex = event.getParam( "recordIndex" );
		console.log( 'handleFailureModeMultiSelectEvt-recordIndex', recordIndex );
		if( recordIndex < 0 ) {
			return;
		}
		
		var listName = event.getParam( "listName" );
		console.log( 'handleFailureModeMultiSelectEvt-listName', listName );
		if( !listName ) {
			return;
		}
		
		var listOfFailureModesSelected = event.getParam( "listOfFailureModesSelected" );
		console.log( 'handleFailureModeMultiSelectEvt-listOfFailureModesSelected', listOfFailureModesSelected );
		if( !listOfFailureModesSelected ) {
			return;
		}
		
		var listOfIssueWrappers = JSON.parse( JSON.stringify( component.get( "v." + listName ) ) );
		console.log( 'handleFailureModeMultiSelectEvt-listOfIssueWrappers', listOfIssueWrappers );
		if( !listOfIssueWrappers || listOfIssueWrappers.length < recordIndex ) {
			return;
		}
		
		var wrapper = listOfIssueWrappers[ recordIndex ];
		if( !wrapper ) {
			return;
		}
		wrapper.listOfSelectedFailureModes = listOfFailureModesSelected;
		component.set( "v." + listName, listOfIssueWrappers );
	},
	
	handleGoogleAddressSearchModalEvt : function( component, event, helper ) {
		
		var recordIssue = JSON.parse( JSON.stringify( event.getParam( "recordIssue" ) ) );
		console.log( 'handleGoogleAddressSearchModalEvt-recordIssue', recordIssue );
		if( !recordIssue ) {
			return;
		}
		
		var listName = event.getParam( "listName" );
		console.log( 'handleGoogleAddressSearchModalEvt-listName', listName );
		if( listName ) {
			
			var recordIndex = event.getParam( "recordIndex" );
			console.log( 'handleGoogleAddressSearchModalEvt-recordIndex', recordIndex );
			if( recordIndex < 0 ) {
				return;
			}
			
			var listOfIssueWrappers = JSON.parse( JSON.stringify( component.get( "v." + listName ) ) );
			console.log( 'handleGoogleAddressSearchModalEvt-listOfIssueWrappers', listOfIssueWrappers );
			if( !listOfIssueWrappers || listOfIssueWrappers.length < recordIndex ) {
				return;
			}
			
			var wrapper = listOfIssueWrappers[ recordIndex ];
			if( !wrapper ) {
				return;
			}
			
			wrapper.recordIssue.Shipping_Street_1__c = recordIssue.Shipping_Street_1__c;
			wrapper.recordIssue.Shipping_Street_2__c = recordIssue.Shipping_Street_2__c;
			wrapper.recordIssue.Shipping_City__c = recordIssue.Shipping_City__c;
			wrapper.recordIssue.Shipping_State_Province__c = recordIssue.Shipping_State_Province__c;
			wrapper.recordIssue.Shipping_Country__c = recordIssue.Shipping_Country__c;
			wrapper.recordIssue.Shipping_Postal_Code__c = recordIssue.Shipping_Postal_Code__c;
			
			component.set( "v." + listName, listOfIssueWrappers );
		}
		else {
			var objectName = event.getParam( "objectName" );
			console.log( 'handleGoogleAddressSearchModalEvt-objectName', objectName );
			if( !objectName ) {
				return;
			}
			
			var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v." + objectName ) ) );
			
			recordCommonIssue.Shipping_Street_1__c = recordIssue.Shipping_Street_1__c;
			recordCommonIssue.Shipping_Street_2__c = recordIssue.Shipping_Street_2__c;
			recordCommonIssue.Shipping_City__c = recordIssue.Shipping_City__c;
			recordCommonIssue.Shipping_State_Province__c = recordIssue.Shipping_State_Province__c;
			recordCommonIssue.Shipping_Country__c = recordIssue.Shipping_Country__c;
			recordCommonIssue.Shipping_Postal_Code__c = recordIssue.Shipping_Postal_Code__c;
			
			component.set( "v." + objectName, recordCommonIssue );
			
			helper.populateAddressValueOnIssues( component, helper, recordCommonIssue );
		}
	},
	
	handleQuoteToContactOptionClick : function( component, event, helper ) {
		
		if( event.target && event.target.closest('li') && event.target.closest('li').dataset && 
			event.target.closest('li').dataset.id && event.target.closest('li').dataset.value
		) {
			var selectedId = event.target.closest('li').dataset.id;
			console.log( 'selectedId', selectedId );
			
			var selectedValue = event.target.closest('li').dataset.value;
			console.log( 'selectedValue', selectedValue );
			
			helper.handleQuoteToContactOptionClick( component, selectedId, selectedValue );
		}
	},
	
	handleShipToContactOptionClick : function( component, event, helper ) {
		
		if( event.target && event.target.closest('li') && event.target.closest('li').dataset && 
			event.target.closest('li').dataset.id && event.target.closest('li').dataset.value
		) {
			var selectedId = event.target.closest('li').dataset.id;
			console.log( 'selectedId', selectedId );
			
			var selectedValue = event.target.closest('li').dataset.value;
			console.log( 'selectedValue', selectedValue );
			
			helper.handleShipToContactOptionClick( component, selectedId, selectedValue );
		}
	},
	
	handleTrunkOptionClick : function( component, event, helper ) {
		
		var currentTrunkRowIndex = component.get( "v.currentTrunkRowIndex" );
		console.log( 'currentTrunkRowIndex', currentTrunkRowIndex );
		
		if( event.target && event.target.closest('li') && event.target.closest('li').dataset && 
			event.target.closest('li').dataset.id && event.target.closest('li').dataset.value
		) {
			var selectedId = event.target.closest('li').dataset.id;
			console.log( 'selectedId', selectedId );
			
			var selectedValue = event.target.closest('li').dataset.value;
			console.log( 'selectedValue', selectedValue );
			
			helper.handleTrunkOptionClick( component, currentTrunkRowIndex, selectedId, selectedValue );
		}
	},
	
	openRecordInNewConsoleTab : function( component, event, helper ) {
		
		if( event && event.target && event.target.id ) {
			helper.openRecordInNewConsoleTab( component, helper, event.target.id );
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
			
			var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
			if( !recordWorkOrder || !recordWorkOrder.Opportunity__r || !recordWorkOrder.Opportunity__r.Pricebook2Id ) {
				helper.showToastMessage( 'error', $A.get("$Label.c.Price_book_missing"), $A.get("$Label.c.Opportunity_Does_Not_Have_Price_Book") );
				return;
			}
			
			helper.openProductLookupModal( component, helper, 'Product Selection', recordIndex, searchKeyword,
										   'CSS', 'listOfPartRequestedWrappers', 'Product',
										   recordWorkOrder.Opportunity__r.Pricebook2Id,
										   recordWorkOrder.Opportunity__r.CurrencyIsoCode
										 );
		}
	},
	
	openAssetLookupModal : function( component, event, helper ) {
		
		var keyCode = event.which;
		console.log( 'openAssetLookupModal-key', keyCode );
		if( keyCode == 13 ) {
			
			var recordIndex = event.target.id;
			console.log( 'openAssetLookupModal-recordIndex', recordIndex );
			
			var searchKeyword = event.target.value;
			console.log( 'openAssetLookupModal-searchKeyword', searchKeyword );
			
			var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
			if( !recordWorkOrder || !recordWorkOrder.Opportunity__c ) {
				helper.showToastMessage( 'error', $A.get("$Label.c.Opportunity_missing"), $A.get("$Label.c.Work_Order_Does_Not_Have_Opportunity") );
				return;
			}
			
			helper.openAssetLookupModal( component, helper, 'Lite ID Selection', recordIndex, searchKeyword,
										 recordWorkOrder.Opportunity__c, 'listOfIGUIssueWrappers',
										 'Lite_ID_Mock_ID__c'
									   );
		}
	},
	
	openFailureModeMultiSelectModal : function( component, event, helper ) {
		
		var recordIndex = event.target.id;
		console.log( 'openFailureModeMultiSelectModal-recordIndex', recordIndex );
		
		var listName = event.target.dataset.title;
		console.log( 'openFailureModeMultiSelectModal-listName', listName );
		if( !listName ) {
			return;
		}
		
		var listOfIssueWrappers = JSON.parse( JSON.stringify( component.get( "v." + listName ) ) );
		console.log( 'openFailureModeMultiSelectModal-listOfIssueWrappers', listOfIssueWrappers );
		if( !listOfIssueWrappers || listOfIssueWrappers.length < recordIndex ) {
			return;
		}
		
		var wrapper = listOfIssueWrappers[ recordIndex ];
        var resonreplace = wrapper.recordIssue.Reason_for_Replacement__c;
       
		if( !wrapper || !wrapper.recordIssue || !wrapper.recordIssue.Failure_Component__c ) {
            
			helper.showToastMessage( 'error', $A.get("$Label.c.Missing_Failure_Component"), $A.get("$Label.c.Select_Failure_Component_First") );
			return;
		}
		
		helper.openFailureModeMultiSelectModal( component, helper, recordIndex, wrapper.recordIssue.Failure_Component__c,
												listName, wrapper.listOfSelectedFailureModes,resonreplace
											  );
	},
	
	openQuoteToContactModal : function( component, event, helper ) {
		
		component.set( "v.isQuoteToContactModalOpened", true );
	},
	
	saveQuoteToContactModal : function( component, event, helper ) {
		
		var areQuoteToContactFieldsValid = helper.validateQuoteToContactFields( component, helper );
		component.set( "v.isQuoteToContactModalOpened", !areQuoteToContactFieldsValid );
	},
	
	closeQuoteToContactModal : function( component, event, helper ) {
		
		var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
		var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
		
		if( recordWorkOrder && recordWorkOrder.Case && recordWorkOrder.Case.Contact ) {
			recordCommonIssue.Customer_Contact__c = recordWorkOrder.Case.Contact.Id;
			recordCommonIssue.Customer_Contact__r = { 
													 'Id' : recordWorkOrder.Case.Contact.Id,
													 'Name' : recordWorkOrder.Case.Contact.Name, 
													 'Email' : recordWorkOrder.Case.Contact.Email,
													 'Phone' : recordWorkOrder.Case.Contact.Phone
													};
		}
		
		component.set( "v.isQuoteToContactModalOpened", false );
		component.set( "v.recordCommonIssue", recordCommonIssue );
	},
	
	openShipToContactModal : function( component, event, helper ) {
		
		component.set( "v.isShipToContactModalOpened", true );
	},
	
	saveShipToContactModal : function( component, event, helper ) {
		
		var areShipToContactFieldsValid = helper.validateShipToContactFields( component, helper );
		component.set( "v.isShipToContactModalOpened", !areShipToContactFieldsValid );
	},
	
	closeShipToContactModal : function( component, event, helper ) {
		
		var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
		var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
		
		if( recordWorkOrder && recordWorkOrder.Case && recordWorkOrder.Case.Contact ) {
			recordCommonIssue.Shipping_Contact_Name__c = recordWorkOrder.Case.Contact.Name;
			recordCommonIssue.Shipping_Contact_Email__c = recordWorkOrder.Case.Contact.Email;
			recordCommonIssue.Shipping_Contact_Number__c = recordWorkOrder.Case.Contact.Phone;
		}
		
		component.set( "v.isShipToContactModalOpened", false );
		component.set( "v.recordCommonIssue", recordCommonIssue );
	},
	
	openAddressSearchModalForCommonIssue : function( component, event, helper ) {
		
		var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
		helper.openAddressSearchModal( component, helper, null, null, 'recordCommonIssue', recordCommonIssue );
	},
	
	openAddressSearchModal : function( component, event, helper ) {
		
		var listOfPartRequestedWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPartRequestedWrappers" ) ) );
		if( !listOfPartRequestedWrappers || listOfPartRequestedWrappers.length == 0 ) {
			return;
		}
		
		var recordIndex = event.target.id;
		if( recordIndex < 0 ) {
			return;
		}
		
		var recordIssue = listOfPartRequestedWrappers[ recordIndex ].recordIssue;
		helper.openAddressSearchModal( component, helper, recordIndex, 'listOfPartRequestedWrappers', null, recordIssue );
	},
	
	openBoxModalFromCSS : function( component, event, helper ) {
		
		var index = event.target.id;
		if( index < 0 ) {
			return;
		}
		
		var listOfIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfIssueWrappers" ) ) );
		if( !listOfIssueWrappers || listOfIssueWrappers.length < index ) {
			return;
		}
		
		var recordIssueWrapper = listOfIssueWrappers[ index ];
		if( recordIssueWrapper && recordIssueWrapper.recordIssue ) {
			helper.openBoxModal( component, helper, recordIssueWrapper.recordIssue );
        }
	},
	
	openBoxModalFromIGU : function( component, event, helper ) {
		
		var index = event.target.id;
		if( index < 0 ) {
			return;
		}
		
		var listOfIGUIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfIGUIssueWrappers" ) ) );
		if( !listOfIGUIssueWrappers || listOfIGUIssueWrappers.length < index ) {
			return;
		}
		
		var recordIssueWrapper = listOfIGUIssueWrappers[ index ];
		if( recordIssueWrapper && recordIssueWrapper.recordIssue ) {
			helper.openBoxModal( component, helper, recordIssueWrapper.recordIssue );
        }
	},
	
	searchQuoteToContacts : function( component, event, helper ) {
		
		var searchKeyword = event.target.value;
		var contactOpenDropDown = JSON.parse( JSON.stringify( component.get( "v.contactOpenDropDown" ) ) );
		
        if ( searchKeyword.length > 2 ) {
			
			var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
			console.log( 'searchQuoteToContacts-recordWorkOrder', recordWorkOrder );
			
			if( !recordWorkOrder || !recordWorkOrder.Opportunity__c ) {
				helper.showToastMessage( 'error', $A.get("$Label.c.Missing_Opportunity_Details"), $A.get("$Label.c.Work_Order_Do_Not_Have_Opportunity") );
				return;
			}
			
            helper.searchContacts( component, searchKeyword, recordWorkOrder.Opportunity__c, recordWorkOrder.Case.ContactId );
        }
		else if( contactOpenDropDown ) {
			component.set( "v.contactOpenDropDown", false );
		}
	},
	
	searchShipToContacts : function( component, event, helper ) {
		
		var searchKeyword = event.target.value;
		
		var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
		recordCommonIssue.Shipping_Contact_Name__c = searchKeyword;
		component.set( "v.recordCommonIssue", recordCommonIssue );
		
		var contactOpenDropDown = JSON.parse( JSON.stringify( component.get( "v.contactOpenDropDown" ) ) );
        if ( searchKeyword.length > 2 ) {
			
			var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
			console.log( 'searchShipToContacts-recordWorkOrder', recordWorkOrder );
			helper.searchContacts( component, searchKeyword, '', recordWorkOrder.Case.ContactId );
        }
		else if( contactOpenDropDown ) {
			component.set( "v.contactOpenDropDown", false );
		}
	},
	
	searchTrunks : function( component, event, helper ) {
		
		var searchKeyword = event.target.value;
        console.log( 'searchKeyword', searchKeyword );
		
		var trunkDropDown = JSON.parse( JSON.stringify( component.get( "v.trunkDropDown" ) ) );
		console.log( 'trunkDropDown', trunkDropDown );
		
        if ( searchKeyword.length > 2 ) {
            var currentTrunkRowIndex = event.target.id;
            console.log( 'currentTrunkRowIndex', currentTrunkRowIndex );
            component.set( "v.currentTrunkRowIndex", currentTrunkRowIndex );
            
            var currentTrunkRowId = event.target.dataset.row;
            console.log( 'currentTrunkRowId', currentTrunkRowId );
            component.set( "v.currentTrunkRowId", currentTrunkRowId );
            
            helper.searchTrunks( component, searchKeyword, currentTrunkRowIndex );
        }
		else if( trunkDropDown ) {
			component.set( "v.trunkDropDown", false );
		}
	},
	
	populateOwnershipOnIssues : function( component, event, helper ) {
			
		var ownershipValue = event.getSource().get( "v.value" );
		console.log( 'populateOwnershipOnIssues-ownershipValue', ownershipValue );
		helper.populateValueOnIssues( component, helper, 'Ownership__c', ownershipValue );
	},
	
	populateRequestedDeliveryDateOnIssues : function( component, event, helper ) {
			
		var requestedDeliveryDate = event.getSource().get( "v.value" );
		console.log( 'populateRequestedDeliveryDateOnIssues-requestedDeliveryDate', requestedDeliveryDate );
		helper.populateValueOnIssues( component, helper, 'Requested_Delivery_Date__c', requestedDeliveryDate );
	},
	
	populateReplacementsOnIssues : function( component, event, helper ) {
			
		var reasonForReplacement = event.getSource().get( "v.value" );
		console.log( 'populateReplacementsOnIssues-reasonForReplacement', reasonForReplacement );
		helper.populateValueOnIssues( component, helper, 'Reason_for_Replacement__c', reasonForReplacement );
	},
	
	toggleSection : function( component, event, helper ) {
        
		var divId = event.target.dataset.title;
		console.log( 'divId', divId );
		
		if( !divId ) {
			return;
		}
		
		var divElement = component.find( divId );
        console.log( 'divElement', divElement );
		
		if( !divElement ) {
			return;
		}
		
		var isExpanded =  $A.util.hasClass( component.find( divId ), 'slds-is-open' );
		console.log( 'isExpanded', isExpanded );
		
		if( isExpanded ) {
			$A.util.removeClass( divElement, 'slds-section slds-is-open' );
            $A.util.addClass( divElement, 'slds-section slds-is-close' );
		}
		else {
			$A.util.removeClass( divElement, 'slds-section slds-is-close' );
            $A.util.addClass( divElement, 'slds-section slds-is-open' );
		}
    },
    
    populateheight : function( component, event, helper ) {
       
        },
    statusChanged: function (cmp, event, helper) {
        
        helper.statusChanged(cmp, event, helper,cmp.get( "v.listOfIGUIssueWrappers" ));
    },
    statusChanged1: function (cmp, event, helper) {
        helper.statusChanged(cmp, event, helper,cmp.get( "v.listOfIssueWrappers" ));
    }
})