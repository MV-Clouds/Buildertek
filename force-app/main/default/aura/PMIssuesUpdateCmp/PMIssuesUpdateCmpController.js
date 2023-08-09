/*
	@ PURPOSE : 1. CONTROLS THE LIGHTNING COMPONENT => PMIssuesUpdateCmp.xml
				2. CONTROLS EVENTS FIRED FROM SCREEN/COMPONENT.
	@ Name    : PMIssuesUpdateCmpController.js
*/
({
	openRecordInNewConsoleTab : function( component, event, helper ) {
		
		if( event && event.target && event.target.id ) {
			helper.openRecordInNewConsoleTab( component, helper, event.target.id );
		}
	},
	
	refreshIssuesTable : function( component, event, helper ) {
    	
		helper.refreshIssuesTable( component, event, helper );
    },
	
	selectAllPMIssues : function( component, event, helper ) {
        
		var areAllPMIssuesSelected = JSON.parse( JSON.stringify( component.get( "v.areAllPMIssuesSelected" ) ) );
        var listOfPMIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPMIssueWrappers" ) ) );
        helper.selectAllRecordWrappers( component, areAllPMIssuesSelected, listOfPMIssueWrappers );
		component.set( "v.listOfPMIssueWrappers", listOfPMIssueWrappers );
    },
	
    searchQuoteToContacts : function( component, event, helper ) {
		
		var searchKeyword = event.target.value;
		var contactOpenDropDown = JSON.parse( JSON.stringify( component.get( "v.contactOpenDropDown" ) ) );
		
        if ( searchKeyword.length > 2 ) {
			
			var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
			console.log( 'searchQuoteToContacts-recordWorkOrder', recordWorkOrder );
			
			if( !recordWorkOrder || !recordWorkOrder.Opportunity__c ) {
				helper.showToastMessage( 'error', 'Opportunity details missing',$A.get("$Label.c.Work_Order_Do_Not_Have_Opportunity")  );
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
		var contactOpenDropDown = JSON.parse( JSON.stringify( component.get( "v.contactOpenDropDown" ) ) );
		
        if ( searchKeyword.length > 2 ) {
			
			var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
			console.log( 'searchShipToContacts-recordWorkOrder', recordWorkOrder );
			
			if( !recordWorkOrder || !recordWorkOrder.Opportunity__c ) {
				helper.showToastMessage( 'error', 'Opportunity details missing', $A.get("$Label.c.Work_Order_Do_Not_Have_Opportunity") );
				return;
			}
			
            helper.searchContacts( component, searchKeyword, recordWorkOrder.Opportunity__c, recordWorkOrder.Case.ContactId );
        }
		else if( contactOpenDropDown ) {
			component.set( "v.contactOpenDropDown", false );
		}
	},
    
	searchAssets : function( component, event, helper ) {
        
        var searchKeyword = event.target.value;
        console.log( 'searchKeyword', searchKeyword );
		
		var assetOpenDropDown = JSON.parse( JSON.stringify( component.get( "v.assetOpenDropDown" ) ) );
		console.log( 'assetOpenDropDown', assetOpenDropDown );
		
		if( searchKeyword && searchKeyword.length > 2 ) {
            
			var currentLiteRowIndex = event.target.id;
            console.log( 'currentLiteRowIndex', currentLiteRowIndex );
            component.set( "v.currentLiteRowIndex", currentLiteRowIndex );
            
			var currentLiteRowId = event.target.dataset.row;
			console.log( 'currentLiteRowId', currentLiteRowId );
			component.set( "v.currentLiteRowId", currentLiteRowId );
					
			var listOfPMIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPMIssueWrappers" ) ) );
			var isIGUIdProvided = helper.checkIGUIdProvided( component, currentLiteRowIndex, listOfPMIssueWrappers );
			if( isIGUIdProvided ) {
				
				var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
				console.log( 'searchQuoteToContacts-recordWorkOrder', recordWorkOrder );
			
				if( recordWorkOrder && recordWorkOrder.Opportunity__c ) {
					helper.searchAssets( component, searchKeyword, recordWorkOrder.Opportunity__c );
				}
				else {
					helper.showToastMessage( 'warning', 'Opportunity missing',$A.get("$Label.c.Work_Order_Does_Not_Have_An_Opportunity")  );
				}
			}
			else {
				currentLiteRowIndex = parseInt( currentLiteRowIndex ) + 1;
				helper.showToastMessage( 'warning', 'IGU ID missing', $A.get("$Label.c.Select_IGU_Id_Provided_For_Row") + currentLiteRowIndex );
			}
        }
		else if( assetOpenDropDown ) {
			component.set( "v.assetOpenDropDown", false );
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
				helper.showToastMessage( 'error', 'Pricebook missing', $Label.c.Opportunity_Does_Not_Have_Price_Book );
				return;
			}
			
			helper.openProductLookupModal( component, helper, 'New Makeup Selection', recordIndex, searchKeyword,
										   'IGU', 'listOfPMIssueWrappers', 'Product',
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
				helper.showToastMessage( 'error', 'Opportunity missing', $A.get("$Label.c.Work_Order_Does_Not_Have_An_Opportunity") );
				return;
			}
			
			helper.openAssetLookupModal( component, helper, 'Lite ID Selection', recordIndex, searchKeyword,
										 recordWorkOrder.Opportunity__c, 'listOfPMIssueWrappers',
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
			helper.showToastMessage( 'error', 'Failure Component Missing',$A.get("$Label.c.Select_Failure_Component_First")  );
			return;
		}
	    
		helper.openFailureModeMultiSelectModal( component, helper, recordIndex, wrapper.recordIssue.Failure_Component__c,
												listName, wrapper.listOfSelectedFailureModes,resonreplace
											  );
	},
	
	openAddressSearchModalForCommonIssue : function( component, event, helper ) {
		
		var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
		helper.openAddressSearchModal( component, helper, null, null, 'recordCommonIssue', recordCommonIssue );
	},
	
	openAddressSearchModal : function( component, event, helper ) {
		
		var listOfPMIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPMIssueWrappers" ) ) );
		if( !listOfPMIssueWrappers || listOfPMIssueWrappers.length == 0 ) {
			return;
		}
		
		var recordIndex = event.target.id;
		if( recordIndex < 0 ) {
			return;
		}
		
		var recordIssue = listOfPMIssueWrappers[ recordIndex ].recordIssue;
		helper.openAddressSearchModal( component, helper, recordIndex, 'listOfPMIssueWrappers', null, recordIssue );
	},
	
	openQualityAnalysisModal : function( component, event, helper ) {
		
		var listOfPMIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPMIssueWrappers" ) ) );
		if( !listOfPMIssueWrappers || listOfPMIssueWrappers.length == 0 ) {
			return;
		}
		
		var recordIndex = event.target.id;
		if( recordIndex < 0 ) {
			return;
		}
		
		var recordIssue = listOfPMIssueWrappers[ recordIndex ].recordIssue;
		helper.openQualityAnalysisModal( component, helper, recordIndex, 'listOfPMIssueWrappers', recordIssue );
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
		
		event.stopPropagation();
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
		
		event.stopPropagation();
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
        var nameOfFailureModesSelected = event.getParam( "NameOfFailureModesSelected" );
		wrapper.listOfSelectedFailureModes = listOfFailureModesSelected;
        wrapper.listOfSelectedFailureModesNames = nameOfFailureModesSelected;
        wrapper.provideFMDetails = false;
		component.set( "v." + listName, listOfIssueWrappers );
		
		event.stopPropagation();
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
		
		event.stopPropagation();
	},
	
	handleQualityAnalysisModalEvt : function( component, event, helper ) {
		
		var recordIssue = JSON.parse( JSON.stringify( event.getParam( "recordIssue" ) ) );
		console.log( 'handleQualityAnalysisModalEvt-recordIssue', recordIssue );
		if( !recordIssue ) {
			return;
		}
		
		var listName = event.getParam( "listName" );
		console.log( 'handleQualityAnalysisModalEvt-listName', listName );
		if( !listName ) {
			return;
		}
		
		var recordIndex = event.getParam( "recordIndex" );
		console.log( 'handleQualityAnalysisModalEvt-recordIndex', recordIndex );
		if( recordIndex < 0 ) {
			return;
		}
			
		var listOfIssueWrappers = JSON.parse( JSON.stringify( component.get( "v." + listName ) ) );
		console.log( 'handleQualityAnalysisModalEvt-listOfIssueWrappers', listOfIssueWrappers );
		if( !listOfIssueWrappers || listOfIssueWrappers.length < recordIndex ) {
			return;
		}
			
		var wrapper = listOfIssueWrappers[ recordIndex ];
		if( !wrapper ) {
			return;
		}
		
		wrapper.recordIssue.Replaced_SWC__c = recordIssue.Replaced_SWC__c;
		wrapper.recordIssue.Lite_Damaged__c = recordIssue.Lite_Damaged__c;
		wrapper.recordIssue.Replaced_WC__c = recordIssue.Replaced_WC__c;
		wrapper.recordIssue.Visible_BB_Damage__c = recordIssue.Visible_BB_Damage__c;
		wrapper.recordIssue.Replaced_IGU_Cable__c = recordIssue.Replaced_IGU_Cable__c;
		wrapper.recordIssue.Reflection_Color_Observed__c = recordIssue.Reflection_Color_Observed__c;
		wrapper.recordIssue.Reflection_Color_Degree__c = recordIssue.Reflection_Color_Degree__c;
		
		component.set( "v." + listName, listOfIssueWrappers );
	},
	
	searchPMProducts : function( component, event, helper ) {
        
        var searchKeyword = event.target.value;
        console.log( 'searchKeyword', searchKeyword );
		
		var pmProductOpenDropDown = JSON.parse( JSON.stringify( component.get( "v.pmProductOpenDropDown" ) ) );
		console.log( 'pmProductOpenDropDown', pmProductOpenDropDown );
		
        if( searchKeyword && searchKeyword.length > 2 ) {
			
			var currentPmProductRowIndex = event.target.id;
            console.log( 'currentPmProductRowIndex', currentPmProductRowIndex );
            component.set( "v.currentPmProductRowIndex", currentPmProductRowIndex );
			
			var listOfPMIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPMIssueWrappers" ) ) );
			console.log( 'before-searchAssets-listOfPMIssueWrappers', listOfPMIssueWrappers );
			
			if( listOfPMIssueWrappers && listOfPMIssueWrappers.length > currentPmProductRowIndex ) {
				var pmIssueWrapper = listOfPMIssueWrappers[ currentPmProductRowIndex ];
				console.log( 'pmIssueWrapper', pmIssueWrapper );
				
				if( pmIssueWrapper && pmIssueWrapper.orderExistingMakeUp == 'No' ) {
					
					var currentPmProductRowId = event.target.dataset.row;
					console.log( 'currentPmProductRowId', currentPmProductRowId );
					component.set( "v.currentPmProductRowId", currentPmProductRowId );
					
					helper.searchPMProducts( component, searchKeyword );
				}
			}
        }
		else if( pmProductOpenDropDown ) {
			component.set( "v.pmProductOpenDropDown", false );
		}
    },
	
	searchPmFailureModes : function( component, event, helper ) {
		
		var searchKeyword = event.target.value;
        console.log( 'searchKeyword', searchKeyword );
		
		var pmFailureModeDropDown = JSON.parse( JSON.stringify( component.get( "v.pmFailureModeDropDown" ) ) );
		console.log( 'pmFailureModeDropDown', pmFailureModeDropDown );
		
        if ( searchKeyword.length > 2 ) {
            var currentPmFmRowIndex = event.target.id;
            console.log( 'currentPmFmRowIndex', currentPmFmRowIndex );
            component.set( "v.currentPmFmRowIndex", currentPmFmRowIndex );
            
            var currentPmFmRowId = event.target.dataset.row;
            console.log( 'currentPmFmRowId', currentPmFmRowId );
            component.set( "v.currentPmFmRowId", currentPmFmRowId );
            
            helper.searchPmFailureModes( component, searchKeyword, currentPmFmRowIndex );
        }
		else if( pmFailureModeDropDown ) {
			component.set( "v.pmFailureModeDropDown", false );
		}
	},
	
	clearQuoteToContactSearchedKeyword : function( component, event, helper ) {
        
        helper.clearQuoteToContactSearchedKeyword( component );
    },
	
	clearShipToContactSearchedKeyword : function( component, event, helper ) {
        
        helper.clearShipToContactSearchedKeyword( component );
    },
	
	clearAssetSearchedKeyword : function( component, event, helper ) {
        
        var index = event.target.id;
        console.log( 'index', index );
        helper.clearAssetSearchedKeyword( component, index );
    },
	
	clearPMProductSearchedKeyword : function( component, event, helper ) {
        
        var index = event.target.id;
        console.log( 'index', index );
        helper.clearPMProductSearchedKeyword( component, index );
    },
	
	clearPmFailureModeSearchedKeyword : function( component, event, helper ) {
        
        var index = event.target.id;
        console.log( 'index', index );
        helper.clearPmFailureModeSearchedKeyword( component, index );
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
	
	updatePMIssues : function( component, event, helper ) {
		
		helper.updatePMIssues( component, JSON.parse( JSON.stringify( component.get( "v.listOfPMIssueWrappers" ) ) ), 1 );
    },
	
	submitPmIssuesAndContinue : function( component, event, helper ) {
		
		helper.updatePMIssues( component, JSON.parse( JSON.stringify( component.get( "v.listOfPMIssueWrappers" ) ) ), 2 );
    },
	
	submitPmIssuesAndFinish : function( component, event, helper ) {
		
		helper.updatePMIssues( component, JSON.parse( JSON.stringify( component.get( "v.listOfPMIssueWrappers" ) ) ), 3 );
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
	
	openQuoteToContactModal : function( component, event, helper ) {
		
		component.set( "v.isQuoteToContactModalOpened", true );
	},
	
	saveQuoteToContactModel : function( component, event, helper ) {
		
		var areQuoteToContactFieldsValid = helper.validateQuoteToContactFields( component, helper );
		component.set( "v.isQuoteToContactModalOpened", !areQuoteToContactFieldsValid );
	},
	
	closeQuoteToContactModel : function( component, event, helper ) {
		
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
	
	saveShipToContactModel : function( component, event, helper ) {
		
		var areShipToContactFieldsValid = helper.validateShipToContactFields( component, helper );
		component.set( "v.isShipToContactModalOpened", !areShipToContactFieldsValid );
	},
	
	closeShipToContactModel : function( component, event, helper ) {
		
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
	
	openShippingInformationModal : function( component, event, helper ) {
		
		component.set( "v.isShippingInformationModalOpened", true );
	},
	
	saveShippingInformationModal : function( component, event, helper ) {
		
		var areShippingInformationFieldsValid = helper.validateShippingInformationFields( component, helper );
		component.set( "v.isShippingInformationModalOpened", !areShippingInformationFieldsValid );
	},
	
	closeShippingInformationModal : function( component, event, helper ) {
		
		component.set( "v.isShippingInformationModalOpened", false );
	},
	
	cancel : function( component, event, helper ) {
        
		helper.cancel( component, helper )
    },
    openScratchModal: function(component, event, helper){
       
        var recordIndex = event.target.id;
            var wrapData = component.get("v.listOfPMIssueWrappers");
            var selectedIssue = wrapData[recordIndex].recordIssue;
            var sNames = wrapData[recordIndex].listOfSelectedFailureModesNames;
        
//return;
           if((sNames.includes("OOS Scratches - S1/S4")) || (sNames.includes("Non-Tinting - Intermittent Tinting")) 
           || (sNames.includes("OOS Scratches - S3 / Other")) || (sNames.includes("Obstruction in Field of View - Spontaneous Breakage"))
           || (sNames.includes("Non-Tinting")) || (sNames.includes("Non-Uniformity - Within Lite")) 
           || (sNames.includes("Non-Uniformity - L2L")) ){
            $A.createComponent('c:ScratchFailureMode', {
                'selectedIssue': selectedIssue,
                'NameOfFailureModesSelected': sNames,
                'componentName': 'PMUpdate'
            },function (modalComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                    //component.set("v.providedDetails",true);
                    var showFMscratchModalDiv = component.find('showFailureModeScratchModal');
                    if (showFMscratchModalDiv) {
                        var body = showFMscratchModalDiv.get("v.body");
                        body.push(modalComponent);
                        component.find('showFailureModeScratchModal').set("v.body", body);
                    }
                }else if (status === "INCOMPLETE") {
                    helper.showToastMessage('error', 'Error!', 'Internal Server issue or client is offline.');
                }else if (status === "ERROR") {
                    helper.showToastMessage('error', 'Error!', 'Something went wrong. Please try again.');
                }
           });
           // console.log("===208==="+JSON.stringify(wrapData.issuesLst[recordIndex].issueRec));
           }
    },
    handleFailureModePDEvt: function(component, event, helper){
        var sRec = event.getParam("selectedIssue");
        var wrapData = component.get("v.listOfPMIssueWrappers");
        //var wrapIss = wrapData.recordIssue;
        for(var r in wrapData){
            if(wrapData[r].recordIssue.Id === sRec.Id){
                wrapData[r].recordIssue = sRec; 
                 wrapData[r].provideFMDetails = true;
            }
        }
        //wrapData = wrapIss;
        //component.set("v.providedDetails",event.getParam("ValuesProvided"));
        component.set("v.listOfPMIssueWrappers",wrapData);
        console.log('========755===='+JSON.stringify(component.get("v.listOfPMIssueWrappers")));
    }
       
    
})