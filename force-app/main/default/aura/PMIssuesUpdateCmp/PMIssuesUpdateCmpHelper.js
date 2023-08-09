/*
	@ PURPOSE : 1. PROVIDES SERVICE TO => PMIssuesUpdateCmpController.js
				2. MAKES CALLS TO APEX SERVER.
	@ Name    : PMIssuesUpdateCmpHelper.js
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
	
	refreshIssuesTable : function( component, event, helper ) {
    	
		var isConsoleNavigation = component.get( "v.isConsoleNavigation" );
		if( isConsoleNavigation ) {
			
			var workspaceAPI = component.find( "workspace" );
			if( workspaceAPI ) {
				
				workspaceAPI.getFocusedTabInfo().then( function( response ) {
					var focusedTabId = response.tabId;
					workspaceAPI.refreshTab({
						tabId: focusedTabId,
						includeAllSubtabs: true
					});
				})
				.catch( function( error ) {
					console.log( 'refreshIssuesTable-error', error );
				});
			}
		}
		else {
			helper.refreshIssues( component );
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
				console.log( 'IssuesCreateAndUpdateHelper-closeFocusedTab', error );
			});
		}
    },
	
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
	
	getIssuesFromWrappers : function( component, listOfIssueWrappers ) {
		
		var listOfIssues = [];
		if( !listOfIssueWrappers || listOfIssueWrappers.length == 0 ) {
			return listOfIssues;
		}
		
		for( var index = 0; index < listOfIssueWrappers.length; index ++ ) {
			listOfIssues.push( listOfIssueWrappers[ index ].recordIssue );
		}
		console.log( 'getIssuesFromWrappers-listOfIssues', listOfIssues );
		return listOfIssues;
	},
	
	selectAllRecordWrappers : function( component, areAllPMIssuesSelected, listOfPMIssueWrappers ) {
    	
		console.log( 'areAllPMIssuesSelected', areAllPMIssuesSelected );
		console.log( 'listOfPMIssueWrappers', listOfPMIssueWrappers );
        if( listOfPMIssueWrappers && listOfPMIssueWrappers.length > 0 ) {
            for( var index = 0; index < listOfPMIssueWrappers.length; index++ ) {
                listOfPMIssueWrappers[index].isSelected = areAllPMIssuesSelected;
            }
        }
    },
	
	clearQuoteToContactSearchedKeyword : function( component ) {
		
		var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
		console.log( 'clearQuoteToContactSearchedKeyword-recordCommonIssue', recordCommonIssue );
		if( recordCommonIssue ) {
			recordCommonIssue.Customer_Contact__c = null;
			recordCommonIssue.Customer_Contact__r = null;
			component.set( "v.recordCommonIssue", recordCommonIssue );
		}
	},
	
	clearShipToContactSearchedKeyword : function( component ) {
		
		var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
		console.log( 'clearShipToContactSearchedKeyword-recordCommonIssue', recordCommonIssue );
		if( recordCommonIssue ) {
			recordCommonIssue.Shipping_Contact_Name__c = '';
			recordCommonIssue.Shipping_Contact_Email__c = '';
			recordCommonIssue.Shipping_Contact_Number__c = '';
			recordCommonIssue.Shipping_Address__c = '';
			recordCommonIssue.Shipping_City__c = '';
			recordCommonIssue.Shipping_State_Province__c = '';
			recordCommonIssue.Shipping_Postal_Code__c = '';
			recordCommonIssue.Shipping_Country__c = '';
			component.set( "v.recordCommonIssue", recordCommonIssue );
		}
	},
	
    clearAssetSearchedKeyword : function( component, index ) {
        
        var listOfPMIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPMIssueWrappers" ) ) );
        console.log( 'before-clearValueFromList-listOfPMIssueWrappers', listOfPMIssueWrappers );
		
        if( listOfPMIssueWrappers && listOfPMIssueWrappers.length > index ) {
            var pmIssueWrapper = listOfPMIssueWrappers[ index ];
            console.log( 'pmIssueWrapper', pmIssueWrapper );
            
            if( pmIssueWrapper && pmIssueWrapper.recordIssue ) {
				
				component.set( "v.assetOpenDropDown", false );
                pmIssueWrapper.recordIssue.Lite_ID_Mock_ID__c = '';
                pmIssueWrapper.recordIssue.Height_in__c = '';
				pmIssueWrapper.recordIssue.Width_in_MM__c = 0;
				pmIssueWrapper.recordIssue.Shape__c = '';
				pmIssueWrapper.recordIssue.Existing_Makeup__c = null;
				pmIssueWrapper.recordIssue.Existing_Makeup__r = null;
                console.log( 'after-clearValueFromList-listOfPMIssueWrappers', listOfPMIssueWrappers );
            	component.set( "v.listOfPMIssueWrappers", listOfPMIssueWrappers );
            }
        }
    },
	
	clearPMProductSearchedKeyword : function( component, index ) {
        
        var listOfPMIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPMIssueWrappers" ) ) );
        console.log( 'before-clearValueFromList-listOfPMIssueWrappers', listOfPMIssueWrappers );
		
        if( listOfPMIssueWrappers && listOfPMIssueWrappers.length > index ) {
            var pmIssueWrapper = listOfPMIssueWrappers[ index ];
            console.log( 'pmIssueWrapper', pmIssueWrapper );
            
            if( pmIssueWrapper && pmIssueWrapper.recordIssue ) {
				
				component.set( "v.pmProductOpenDropDown", false );
                pmIssueWrapper.recordIssue.Product__c = null;
                pmIssueWrapper.recordIssue.Product__r = null;
				
                console.log( 'after-clearValueFromList-listOfPMIssueWrappers', listOfPMIssueWrappers );
            	component.set( "v.listOfPMIssueWrappers", listOfPMIssueWrappers );
            }
        }
    },
	
	clearPmFailureModeSearchedKeyword : function( component, index ) {
        
        var listOfPMIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPMIssueWrappers" ) ) );
        console.log( 'before-clearPmFailureModeSearchedKeyword-listOfPMIssueWrappers', listOfPMIssueWrappers );
        if( listOfPMIssueWrappers && listOfPMIssueWrappers.length > index ) {
            var pmIssueWrapper = listOfPMIssueWrappers[ index ];
            console.log( 'pmIssueWrapper', pmIssueWrapper );
            
            if( pmIssueWrapper && pmIssueWrapper.recordIssue ) {
				component.set( "v.failureModeDropDown", false );
                pmIssueWrapper.recordFailureMode.Name = null;
                pmIssueWrapper.recordFailureMode.Id = null;
                console.log( 'after-clearPmFailureModeSearchedKeyword-listOfPMIssueWrappers', listOfPMIssueWrappers );
            	component.set( "v.listOfPMIssueWrappers", listOfPMIssueWrappers );
            }
        }
    },
	
    handleQuoteToContactOptionClick : function( component, selectedId, selectedValue ) {
		
		if( selectedId && selectedValue ) {
			var listOfContactSearchedResults = JSON.parse( JSON.stringify( component.get( "v.listOfContactSearchedResults" ) ) );
			console.log( 'handleQuoteToContactOptionClick', listOfContactSearchedResults );
			
			var selectedRecordContact = null;
			listOfContactSearchedResults.map( function( recordContact, index ) {
				if( recordContact.Id == selectedId ) {
					selectedRecordContact = recordContact;
				}
			});
			
			console.log( 'selectedRecordContact', selectedRecordContact );
			if( selectedRecordContact ) {
				var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
				console.log( 'recordCommonIssue', recordCommonIssue );
				
				if( !recordCommonIssue ) {
					recordCommonIssue = {};
				}
				recordCommonIssue.Customer_Contact__c = selectedRecordContact.Id;
				recordCommonIssue.Customer_Contact__r = { 
														 'Id' : selectedRecordContact.Id,
														 'Name' : selectedRecordContact.Name,
														 'Phone' : selectedRecordContact.Phone,
														 'Email' : selectedRecordContact.Email
													    };
				component.set( "v.recordCommonIssue", recordCommonIssue );
			}
		}
		component.set( "v.contactOpenDropDown", false );
	},
	
	handleShipToContactOptionClick : function( component, selectedId, selectedValue ) {
		
		if( selectedId && selectedValue ) {
			var listOfContactSearchedResults = JSON.parse( JSON.stringify( component.get( "v.listOfContactSearchedResults" ) ) );
			console.log( 'handleShipToContactOptionClick', listOfContactSearchedResults );
			
			var selectedRecordContact = null;
			listOfContactSearchedResults.map( function( recordContact, index ) {
				if( recordContact.Id == selectedId ) {
					selectedRecordContact = recordContact;
				}
			});
			
			console.log( 'selectedRecordContact', selectedRecordContact );
			if( selectedRecordContact ) {
				var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
				console.log( 'recordCommonIssue', recordCommonIssue );
				
				if( !recordCommonIssue ) {
					recordCommonIssue = {};
				}
				
				recordCommonIssue.Shipping_Contact_Name__c = selectedRecordContact.Name;
				recordCommonIssue.Shipping_Contact_Email__c = selectedRecordContact.Email;
				recordCommonIssue.Shipping_Contact_Number__c = selectedRecordContact.Phone;
				recordCommonIssue.Shipping_Address__c = selectedRecordContact.MailingStreet;
				recordCommonIssue.Shipping_City__c = selectedRecordContact.MailingCity;
				recordCommonIssue.Shipping_State_Province__c = selectedRecordContact.MailingState;
				recordCommonIssue.Shipping_Country__c = selectedRecordContact.MailingCountry;
				recordCommonIssue.Shipping_Postal_Code__c = selectedRecordContact.MailingPostalCode;
				component.set( "v.recordCommonIssue", recordCommonIssue );
			}
		}
		component.set( "v.contactOpenDropDown", false );
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
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Internal_Issue_Or_Client_Offline' ) );
			} 
			else if ( status === "ERROR" ) {
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Something_Went_Wrong_Try_Again' ) );
			}
		});
	},
	
	openAssetLookupModal : function( component, helper, headerText, recordIndex,
									 searchKeyword, opportunityId, listName, fieldName
									   
	) {
		var listOfRecordWrappers = JSON.parse( JSON.stringify( component.get( "v." + listName ) ) );
		if( !listOfRecordWrappers || listOfRecordWrappers.length == 0 || listOfRecordWrappers.length < recordIndex ) {
			return;
		}
		
		var recordIssueWrapper = listOfRecordWrappers[ recordIndex ];
		if( !recordIssueWrapper || !recordIssueWrapper.recordIssue ) {
			return;
		}
		
		if( !recordIssueWrapper.recordIssue.IGU_ID_Provided__c ) {
			helper.showToastMessage( 'error', 'Error!', 'Please select IGU ID Provided.' );
			return;
		}
		
		$A.createComponent( 'c:AssetLookupCmp', {
			'headerText' : headerText,
			'recordIndex' : recordIndex,
			'searchKeyword' : searchKeyword,
			'opportunityId' : opportunityId,
			'listName' : listName,
			'fieldName' : fieldName
		},
		function( modalComponent, status, errorMessage ) {
			
			if( status === "SUCCESS" ) {
				
				var showChildModalDiv = component.find( 'showAssetLookupModal' );
				if( showChildModalDiv ) {
					var body = showChildModalDiv.get( "v.body" );
					body.push( modalComponent );
					component.find( 'showAssetLookupModal' ).set( "v.body", body );
				}
			} 
			else if ( status === "INCOMPLETE" ) {
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Internal_Issue_Or_Client_Offline' ) );
			} 
			else if ( status === "ERROR" ) {
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Something_Went_Wrong_Try_Again' ) );
			}
		});
	},
	
	openFailureModeMultiSelectModal : function( component, helper, recordIndex, failureComponent,
												listName, listOfAlreadySelectedFailureModes,resonreplace
									   
	) {
        
		$A.createComponent( 'c:FailureModeModalCmp', {
			'recordIndex' : recordIndex,
			'failureComponent' : failureComponent,
			'listName' : listName,
			'listOfAlreadySelectedFailureModes' : listOfAlreadySelectedFailureModes,
            'resonforreplace':resonreplace
		},
		function( modalComponent, status, errorMessage ) {
			
			if( status === "SUCCESS" ) {
				
				var showChildModalDiv = component.find( 'showFailureModeMultiSelectModal' );
				if( showChildModalDiv ) {
					var body = showChildModalDiv.get( "v.body" );
					body.push( modalComponent );
					component.find( 'showFailureModeMultiSelectModal' ).set( "v.body", body );
				}
			} 
			else if ( status === "INCOMPLETE" ) {
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Internal_Issue_Or_Client_Offline' ) );
			} 
			else if ( status === "ERROR" ) {
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Something_Went_Wrong_Try_Again' ) );
			}
		});
	},
	
	showSubmittedIssuesModal : function( component, helper, listOfIssues ) {
		
		if( !listOfIssues || listOfIssues.length == 0 ) {
			return listOfIssues;
		}
		
		$A.createComponent( 'c:ApprovalIssuesCmp', {
			'listOfSubmittedIssues' : listOfIssues,
			'refreshIssuesReportedTableEvt' : component.getReference( "c.refreshIssuesTable" )
		},
		function( modalComponent, status, errorMessage ) {
			
			if( status === "SUCCESS" ) {
				
				var showChildModalDiv = component.find( 'showSubmittedIssuesModal' );
				if( showChildModalDiv ) {
					var body = showChildModalDiv.get( "v.body" );
					body.push( modalComponent );
					component.find( 'showSubmittedIssuesModal' ).set( "v.body", body );
				}
			} 
			else if ( status === "INCOMPLETE" ) {
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Internal_Issue_Or_Client_Offline' ) );
			} 
			else if ( status === "ERROR" ) {
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Something_Went_Wrong_Try_Again' ) );
			}
		});
	},
	
	openAddressSearchModal : function( component, helper, recordIndex, listName, objectName, recordCommonIssue ) {
		
		if( !recordIndex && !listName && !objectName ) {
			return;
		}
		
		$A.createComponent( 'c:GoogleAddressSearchCmp', {
			'recordIndex' : recordIndex,
			'listName' : listName,
			'objectName' : objectName,
			'recordIssue' : recordCommonIssue,
			'googleAddressSearchModalEvt' : component.getReference( "c.handleGoogleAddressSearchModalEvt" )
		},
		function( modalComponent, status, errorMessage ) {
			
			if( status === "SUCCESS" ) {
				
				var showChildModalDiv = component.find( 'showAddressSearchModal' );
				if( showChildModalDiv ) {
					var body = showChildModalDiv.get( "v.body" );
					body.push( modalComponent );
					component.find( 'showAddressSearchModal' ).set( "v.body", body );
				}
			} 
			else if ( status === "INCOMPLETE" ) {
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Internal_Issue_Or_Client_Offline' ) );
			} 
			else if ( status === "ERROR" ) {
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Something_Went_Wrong_Try_Again' ) );
			}
		});
	},
	
	openQualityAnalysisModal : function( component, helper, recordIndex, listName, recordIssue ) {
		
		if( !recordIndex && !listName && !recordIssue ) {
			return;
		}
		
		$A.createComponent( 'c:QualityAnalysisCmp', {
			'recordIndex' : recordIndex,
			'listName' : listName,
			'recordIssue' : recordIssue,
			'qualityAnalysisModalEvt' : component.getReference( "c.handleQualityAnalysisModalEvt" )
		},
		function( modalComponent, status, errorMessage ) {
			
			if( status === "SUCCESS" ) {
				
				var showChildModalDiv = component.find( 'showQualityAnalysisModal' );
				if( showChildModalDiv ) {
					var body = showChildModalDiv.get( "v.body" );
					body.push( modalComponent );
					component.find( 'showQualityAnalysisModal' ).set( "v.body", body );
				}
			} 
			else if ( status === "INCOMPLETE" ) {
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Internal_Issue_Or_Client_Offline' ) );
			} 
			else if ( status === "ERROR" ) {
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Something_Went_Wrong_Try_Again' ) );
			}
		});
	},
	
	handleProductSelectEvt : function( component, helper, recordIndex, listName, fieldName, recordProductWrapper ) {
		
		if( recordIndex < 0 || !listName || !fieldName || !recordProductWrapper || !recordProductWrapper.recordProduct ) {
			return;
		}
		
		var listOfIssueRecordWrappers = JSON.parse( JSON.stringify( component.get( "v." + listName ) ) );
		console.log( 'handleProductSelectEvt-listOfIssueRecordWrappers', listOfIssueRecordWrappers );
		
		if( !listOfIssueRecordWrappers || listOfIssueRecordWrappers.length < recordIndex ) {
			return;
		}
		
		var recordIssueWrapper = listOfIssueRecordWrappers[ recordIndex ];
		console.log( 'handleProductSelectEvt-recordIssueWrapper', recordIssueWrapper )
		
		recordIssueWrapper.recordIssue[ fieldName + '__c' ] = recordProductWrapper.recordProduct.Id;
		recordIssueWrapper.recordIssue[ fieldName + '__r' ] = { 'Id' : recordProductWrapper.recordProduct.Id,
																'Name' : recordProductWrapper.recordProduct.Name 
															  };
		recordIssueWrapper.listPrice = recordProductWrapper.listPrice;
		
		component.set( "v." + listName, listOfIssueRecordWrappers );
	},
	
	handleAssetSelectEvt : function( component, helper, recordIndex, listName, fieldName, recordAsset ) {
		
		if( recordIndex < 0 || !listName || !fieldName || !recordAsset || !recordAsset ) {
			return;
		}
		
		var listOfIssueRecordWrappers = JSON.parse( JSON.stringify( component.get( "v." + listName ) ) );
		console.log( 'handleAssetSelectEvt-listOfIssueRecordWrappers', listOfIssueRecordWrappers );
		
		if( !listOfIssueRecordWrappers || listOfIssueRecordWrappers.length < recordIndex ) {
			return;
		}
		
		var recordIssueWrapper = listOfIssueRecordWrappers[ recordIndex ];
		console.log( 'handleAssetSelectEvt-recordIssueWrapper', recordIssueWrapper )
		
		recordIssueWrapper.recordIssue.Asset__c = recordAsset.Id;
		recordIssueWrapper.recordIssue.Lite_ID_Mock_ID__c = recordAsset.SerialNumber;
		recordIssueWrapper.recordIssue.Height_in__c = recordAsset.Lite_Height__c;
		recordIssueWrapper.recordIssue.Base_in__c = recordAsset.Lite_Width__c;
		
		recordIssueWrapper.recordIssue.H1_B1_in__c = recordAsset.H1_B1_in__c;
		recordIssueWrapper.recordIssue.Mark_ID__c = recordAsset.Mark_Id__c;
		recordIssueWrapper.recordIssue.Shape__c = recordAsset.AssetShape__c;
		recordIssueWrapper.recordIssue.Existing_Makeup__c = recordAsset.Product2Id;
		recordIssueWrapper.recordIssue.Existing_Makeup__r = { 'Id' : recordAsset.Product2Id, 'Name' : recordAsset.Product2.Name };
		
		component.set( "v." + listName, listOfIssueRecordWrappers );
	},
	
	getAssetFromAssetId : function( component, assetId ) {
		
		var helper = this;
		var selectedAsset = null;
		
		if( !assetId ) {
			return selectedAsset;
		}
		
		var listOfAssetSearchedResults = JSON.parse( JSON.stringify( component.get( "v.listOfAssetSearchedResults" ) ) );
		console.log( 'listOfAssetSearchedResults', listOfAssetSearchedResults );
		if( !listOfAssetSearchedResults || listOfAssetSearchedResults.length < 1 ) {
			return selectedAsset;
		}
			
		listOfAssetSearchedResults.map( function( recordAsset, index ) {
			if( recordAsset.Id == assetId ) {
				selectedAsset = recordAsset;
			}
		});
		console.log( 'selectedAsset', selectedAsset );
		return selectedAsset;
	},
	
	getListOfSelectedRecordWrappers : function( component, listOfRecordWrappers ) {
    	
        console.log( 'before-getListOfSelectedRecordWrappers', listOfRecordWrappers );
        var listOfSelectedRecordWrappers = [];
        if( listOfRecordWrappers && listOfRecordWrappers.length > 0 ) {
            for( var index = 0; index  < listOfRecordWrappers.length; index ++ ) {
                if( listOfRecordWrappers[index].isSelected ) {
                    listOfSelectedRecordWrappers.push( listOfRecordWrappers[index] );
                }
            }
        }
        console.log( 'after-getListOfSelectedRecordWrappers', listOfSelectedRecordWrappers );
        return listOfSelectedRecordWrappers;
    },
	
	populateValueOnIssues : function( component, helper, fieldName, fieldValue ) {
		
		if( !fieldName ) {
			return;
		}
		
		var listOfPMIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPMIssueWrappers" ) ) );
		if( !listOfPMIssueWrappers || listOfPMIssueWrappers.length == 0 ) {
			return;
		}
		
		var anyRecordUpdated = false;
		
		for( var index = 0; index < listOfPMIssueWrappers.length; index ++ ) {
			var wrapper = listOfPMIssueWrappers[ index ];
			if( wrapper && wrapper.isSelected ) {
				wrapper.recordIssue[ fieldName ] = fieldValue;
				anyRecordUpdated = true;
			}
		}
		console.log( 'populateOwnershipOnIssues-listOfPMIssueWrappers', listOfPMIssueWrappers );
		
		if( anyRecordUpdated ) {
			component.set( "v.listOfPMIssueWrappers", listOfPMIssueWrappers );
		}
	},
	
	populateAddressValueOnIssues : function( component, helper, recordCommonIssue ) {
		
		if( !recordCommonIssue ) {
			return;
		}
		
		var listOfPMIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPMIssueWrappers" ) ) );
		if( !listOfPMIssueWrappers || listOfPMIssueWrappers.length == 0 ) {
			return;
		}
		
		var anyRecordUpdated = false;
		
		for( var index = 0; index < listOfPMIssueWrappers.length; index ++ ) {
			var wrapper = listOfPMIssueWrappers[ index ];
			if( wrapper && wrapper.isSelected ) {
				wrapper.recordIssue.Shipping_Street_1__c = recordCommonIssue.Shipping_Street_1__c;
				wrapper.recordIssue.Shipping_Street_2__c = recordCommonIssue.Shipping_Street_2__c;
				wrapper.recordIssue.Shipping_City__c = recordCommonIssue.Shipping_City__c;
				wrapper.recordIssue.Shipping_State_Province__c = recordCommonIssue.Shipping_State_Province__c;
				wrapper.recordIssue.Shipping_Country__c = recordCommonIssue.Shipping_Country__c;
				wrapper.recordIssue.Shipping_Postal_Code__c = recordCommonIssue.Shipping_Postal_Code__c;
				anyRecordUpdated = true;
			}
		}
		console.log( 'populateOwnershipOnIssues-listOfPMIssueWrappers', listOfPMIssueWrappers );
		
		if( anyRecordUpdated ) {
			component.set( "v.listOfPMIssueWrappers", listOfPMIssueWrappers );
		}
	},
	
    populateCommonDetailsOnPMIssues : function( component, recordCommonIssue, listOfSelectedPMWrappers ) {
		
		console.log( 'populateCommonDetailsOnPMIssues-recordCommonIssue', recordCommonIssue );
		console.log( 'populateCommonDetailsOnPMIssues-listOfSelectedPMWrappers', listOfSelectedPMWrappers );
		
		if( recordCommonIssue && recordCommonIssue.Shipping_Contact_Name__c && 
			listOfSelectedPMWrappers && listOfSelectedPMWrappers.length > 0 
		) {
			for( var index = 0; index < listOfSelectedPMWrappers.length; index ++ ) {
				var recordIssue = listOfSelectedPMWrappers[ index ].recordIssue;
				if( recordIssue ) {
					recordIssue.Shipping_Contact_Name__c = recordCommonIssue.Shipping_Contact_Name__c;
					recordIssue.Shipping_Contact_Email__c = recordCommonIssue.Shipping_Contact_Email__c;
					recordIssue.Shipping_Contact_Number__c = recordCommonIssue.Shipping_Contact_Number__c;
					
					if( !recordIssue.Shipping_Street_1__c ) {
						recordIssue.Shipping_Street_1__c = recordCommonIssue.Shipping_Street_1__c;
						recordIssue.Shipping_Street_2__c = recordCommonIssue.Shipping_Street_2__c;
						recordIssue.Shipping_City__c = recordCommonIssue.Shipping_City__c;
						recordIssue.Shipping_State_Province__c = recordCommonIssue.Shipping_State_Province__c;
						recordIssue.Shipping_Postal_Code__c = recordCommonIssue.Shipping_Postal_Code__c;
						recordIssue.Shipping_Country__c = recordCommonIssue.Shipping_Country__c;
					}
					
					recordIssue.Customer_Contact__c = recordCommonIssue.Customer_Contact__c;
					recordIssue.Product_Replacement__c = recordCommonIssue.Product_Replacement__c;
					if(recordCommonIssue.Product_Return__c)
                    recordIssue.Product_Return__c = true;//recordCommonIssue.Product_Return__c;
					
					if( recordIssue.Want_to_Order_Existing_Makeup__c == 'Yes' ) {
						recordIssue.Product__c = recordIssue.Existing_Makeup__c;
						if( recordIssue.Existing_Makeup__r ) {
							recordIssue.Product__r = { 'Id' : recordIssue.Existing_Makeup__c, 'Name' : recordIssue.Existing_Makeup__r.Name };
						}
					}
				}
			}
		}
	},
    
	validateQuoteToContactFields : function( component, helper ) {
		
		var areQuoteToContactFieldsValid = true;
		var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
		
		if( !recordCommonIssue || !recordCommonIssue.Customer_Contact__c ) {
			areQuoteToContactFieldsValid = false;
			helper.showToastMessage( 'error', 'Quote to Contact Missing', $A.get( '$Label.c.Provide_Quote_To_Contact_Details' ) );
		}
		return areQuoteToContactFieldsValid;
	},
	
	validateShipToContactFields : function( component, helper ) {
		
		var areShipToContactFieldsValid = true;
		var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
		
		if( !recordCommonIssue || !recordCommonIssue.Shipping_Contact_Name__c ||
			!recordCommonIssue.Shipping_Contact_Number__c || !recordCommonIssue.Shipping_Contact_Email__c 
		) {
			areShipToContactFieldsValid = false;
			helper.showToastMessage( 'error', 'Shipping Contact Missing', $A.get( '$Label.c.Provide_Shipping_Contact_Details' ) );
		}
        else {
			var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
			if( !recordCommonIssue.Shipping_Contact_Email__c.match( regExpEmailformat ) ) {
				areShipToContactFieldsValid = false;
				helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ), $A.get( "$Label.c.Provide_Valid_Email_Address" ) );
			}
		}
		return areShipToContactFieldsValid;
	},
	
	validateShippingInformationFields : function( component, helper ) {
		
		var areShippingInformationFieldsValid = true;
		var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
		
		if( !recordCommonIssue || !recordCommonIssue.Shipping_Street_1__c ||
			!recordCommonIssue.Shipping_City__c || !recordCommonIssue.Shipping_State_Province__c ||
			!recordCommonIssue.Shipping_Postal_Code__c || !recordCommonIssue.Shipping_Country__c
		) {
			areShippingInformationFieldsValid = false;
			helper.showToastMessage( 'error', 'Shipping Contact Missing', $A.get( '$Label.c.Provide_Shipping_Address_Details' ) );
		}
		return areShippingInformationFieldsValid;
	},
	
	checkIGUIdProvided : function( component, currentLiteRowIndex, listOfPMIssueWrappers ) {
		
		if( !listOfPMIssueWrappers || listOfPMIssueWrappers.length < 1 || listOfPMIssueWrappers.length < currentLiteRowIndex ) {
			return false;
		}
		
		var pmIssueWrapper = listOfPMIssueWrappers[ currentLiteRowIndex ];
		if( !pmIssueWrapper || !pmIssueWrapper.recordIssue || !pmIssueWrapper.recordIssue.IGU_ID_Provided__c ) {
			return false;
		}
		
		return true;
	},
	
	applyPMValidations : function( component, listOfSelectedPMIssueWrappers ) {
		
		var helper = this;
		
		if( !listOfSelectedPMIssueWrappers || listOfSelectedPMIssueWrappers.length <= 0 ) {
			return false;
		}
		
		var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
		
        var dateValue;
		var todayDate = helper.parseDateToString( new Date() );
		console.log( 'todayDate', todayDate );
		
		var tomorrowDate = new Date();
		tomorrowDate.setDate( tomorrowDate.getDate() + 1 );
		tomorrowDate = helper.parseDateToString( tomorrowDate );
		console.log( 'tomorrowDate', tomorrowDate );
		
		var strDate = '' + $A.localizationService.formatDate( new Date(), "YYYY-MM-DD, hh:mm:ss a" );
		console.log( 'strDate', strDate );
		
		var isThisPostMeridiem = strDate.includes( 'PM' );
		console.log( 'isThisPostMeridiem', isThisPostMeridiem );
        
		if( !recordCommonIssue.Customer_Contact__c ) {
			helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Select_Quote_To_Contact' ) );
			return false;
		}
		
		if( !recordCommonIssue.Shipping_Contact_Name__c) {
			helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Provide_Ship_To_Contact_Details' ) );
			return false;
		}
		
		for( var index = 0; index < listOfSelectedPMIssueWrappers.length; index ++ ) {
			
			var wrapper = listOfSelectedPMIssueWrappers[ index ];
			if( ( wrapper.recordIssue.Product__c || wrapper.recordIssue.Existing_Makeup__c )
				&&
				( !wrapper.recordIssue.Quantity__c || wrapper.recordIssue.Quantity__c < 1 ) 
			) {
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Provide_Quantity_For_Product' ) );
				return false;
			}
			
			if( wrapper.recordIssue.Requested_Delivery_Date__c ) {
				dateValue = new Date( wrapper.recordIssue.Requested_Delivery_Date__c );
				if( dateValue != 'Invalid Date' && isNaN( dateValue ) == false ) {
					
                    dateValue = wrapper.recordIssue.Requested_Delivery_Date__c;
					if( dateValue <= todayDate ) {
						helper.showToastMessage( 'error', $A.get("$Label.c.Error"),$A.get( "$Label.c.Requested_Delivery_Date_Is_Future_Date" ) );
						return false;
					}
					else if( dateValue == tomorrowDate && isThisPostMeridiem ) {
						helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),$A.get( "$Label.c.Requested_Delivery_Date_Cannot_Be_Tomorrow_s_Date" )  );
						return false;
					}
				}
			}
			else {
				wrapper.recordIssue.Requested_Delivery_Date__c = null;
			}
			
			if( wrapper.recordIssue.Want_to_Order_Existing_Makeup__c == 'No' && !wrapper.recordIssue.Product__c ) {
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Select_New_Makeup' ) );
				return false;
			}
			
			if( recordCommonIssue.Product_Replacement__c ) {
				if( wrapper.listOfSelectedFailureModes.length == 0 ) {
					helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Select_Failure_Mode_When_Order_Replacement_Checked' ) );
					return false;
				}
				else if( !wrapper.recordIssue.Ownership__c ) {
					helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Select_Who_Caused_Damage_When_Order_Replacement_Checked' ) );
					return false;
				}
				else if( !wrapper.recordIssue.Product__c && !wrapper.recordIssue.Existing_Makeup__c ) {
					helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Provide_Product_Details_When_Order_Replacement_Checked' ) );
					return false;
				}
				else if( !wrapper.recordIssue.Quantity__c || wrapper.recordIssue.Quantity__c < 1 ) {
					helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Provide_Quantity_When_Order_Replacement_Checked' ) );
					return false;
				}
				else if( !wrapper.recordIssue.Reason_for_Replacement__c ) {
					helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Select_Reason_For_Replacement_Order_When_Replacement_Checked' ) );
					return false;
				}
				else if( !wrapper.recordIssue.Shipping_Street_1__c || !wrapper.recordIssue.Shipping_City__c ||
						 !wrapper.recordIssue.Shipping_State_Province__c || !wrapper.recordIssue.Shipping_Postal_Code__c ||
						 !wrapper.recordIssue.Shipping_Country__c
				) {
					helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Provide_Shipping_Information_Details' ) );
					return false;
				}
				else {
					dateValue = new Date( wrapper.recordIssue.Requested_Delivery_Date__c );
					if( wrapper.recordIssue.Requested_Delivery_Date__c == null || dateValue == 'Invalid Date' || isNaN( dateValue ) ) {
						helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.provide_Requested_Delivery_Date_When_Order_Replacement_Checked' ) );
						return false;
					}
				}
			}
		}
		return true;
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
	
	refreshIssues : function( component ) {
		
		var refreshPmTableEvt = component.getEvent( "refreshPmTableEvt" );
		if( refreshPmTableEvt ) {
			refreshPmTableEvt.fire();
            component.set( "v.showSpinner", false );
		}
    },
	
    searchContacts : function( component, strSearchKeyword, strOpportunityId, strContactId ) {
		
		var helper = this;
		if( strSearchKeyword && strSearchKeyword.length > 2 ) {
			
            component.set( "v.listOfContactSearchedResults", [] );
            
			var serverAction = component.get( "c.searchContactRecords" );
			if( !serverAction ) {
				return;
			}
			component.set( "v.showSpinner", true );
			
			serverAction.setParams({ 
									"strSearchKeyword" : strSearchKeyword,
									"strOpportunityId" : strOpportunityId,
									"strContactId" : strContactId
								  });
			serverAction.setCallback( this, function( response ) {
				
				component.set( "v.showSpinner", false );
				
				var state = response.getState();
				if ( state === "SUCCESS" ) {
					
					var result = JSON.parse( response.getReturnValue() );
					console.log( "searchShipToContacts", result );
					
					if( result.isSucceeded ) {
						component.set( "v.contactOpenDropDown", true );
						console.log( "contactOpenDropDown", component.get( "v.contactOpenDropDown" ) );
						component.set( "v.listOfContactSearchedResults", result.listOfContactSearchedResults );
                        console.log( 'get', component.get( "v.listOfContactSearchedResults" ) );
					}
					else {
						helper.showToastMessage( 'error', 'Error!', result.message );
					}
				}
				else {
					helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Something_Went_Wrong_Please_Contact_Admin' ) );
				}
			});
			
			$A.enqueueAction( serverAction );
		}
	},
	
	searchAssets : function( component, strSearchKeyword, opportunityId ) {
		
		var helper = this;
		if( !strSearchKeyword || strSearchKeyword.length <= 2 ) {
			return;
		}
		
		if( !opportunityId ) {
			return;
		}
			
		var serverAction = component.get( "c.searchAssetRecords" );
		if( !serverAction ) {
			return;
		}
		component.set( "v.showSpinner", true );
		
		serverAction.setParams({ 
								"strSearchKeyword" : strSearchKeyword,
								"opportunityId" : opportunityId
							  });
		serverAction.setCallback( this, function( response ) {
			
			component.set( "v.showSpinner", false );
			
			var state = response.getState();
			if ( state === "SUCCESS" ) {
				
				var result = JSON.parse( response.getReturnValue() );
				console.log( "searchAssets", result );
				
				if( result.isSucceeded ) {
					component.set( "v.assetOpenDropDown", true );
					console.log( "assetOpenDropDown", component.get( "v.assetOpenDropDown" ) );
					component.set( "v.listOfAssetSearchedResults", result.listOfAssetSearchedResults );
					console.log( 'get', component.get( "v.listOfAssetSearchedResults" ) );
				}
				else {
					helper.showToastMessage( 'error', 'Error!', result.message );
				}
			}
			else {
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Something_Went_Wrong_Please_Contact_Admin' ) );
			}
		});
		
		$A.enqueueAction( serverAction );
	},
	
	searchPMProducts : function( component, strSearchKeyword ) {
		
		var helper = this;
		if( strSearchKeyword && strSearchKeyword.length > 2 ) {
			
			var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
			console.log( 'searchPMProducts-recordWorkOrder', recordWorkOrder );
			
			if( !recordWorkOrder || !recordWorkOrder.Opportunity__c || !recordWorkOrder.Opportunity__r.Pricebook2Id ) {
				helper.showToastMessage( 'error', 'Opportunity Missing', $A.get( '$Label.c.Work_Order_Does_Not_Have_Either_Opportunity_Or_Pricebook' ) );
				return;
			}
			
			var strOpportunityPricebook2Id = recordWorkOrder.Opportunity__r.Pricebook2Id;
			console.log( 'strOpportunityPricebook2Id', strOpportunityPricebook2Id );
			
			var serverAction = component.get( "c.searchProductRecords" );
			if( !serverAction ) {
				return;
			}
			component.set( "v.showSpinner", true );
			
			serverAction.setParams({ 
									"strSearchKeyword" : strSearchKeyword,
									"strOpportunityPricebook2Id" : strOpportunityPricebook2Id
								  });
			serverAction.setCallback( this, function( response ) {
				
				component.set( "v.showSpinner", false );
				
				var state = response.getState();
				if ( state === "SUCCESS" ) {
					
					var result = JSON.parse( response.getReturnValue() );
					console.log( "searchPMProducts", result );
					
					if( result.isSucceeded ) {
						component.set( "v.pmProductOpenDropDown", true );
						console.log( "pmProductOpenDropDown", component.get( "v.pmProductOpenDropDown" ) );
						component.set( "v.listOfPMProductSearchedResults", result.listOfSearchedResults );
                        console.log( 'get', component.get( "v.listOfPMProductSearchedResults" ) );
					}
					else {
						helper.showToastMessage( 'error', 'Error!', result.message );
					}
				}
				else {
					helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Something_Went_Wrong_Please_Contact_Admin' ) );
				}
			});
			
			$A.enqueueAction( serverAction );
		}
	},
	
	searchPmFailureModes : function( component, strSearchKeyword, currentPmFmRowIndex ) {
		
		var helper = this;
		console.log( 'searchPmFailureModes-strSearchKeyword', strSearchKeyword );
		console.log( 'searchPmFailureModes-currentPmFmRowIndex', currentPmFmRowIndex );
		
		if( !strSearchKeyword || strSearchKeyword.length < 3 && currentPmFmRowIndex < 0 ) {
			return;
		}
		
		var listOfPMIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPMIssueWrappers" ) ) );
		if( !listOfPMIssueWrappers || listOfPMIssueWrappers.length < currentPmFmRowIndex ) {
			return;
		}
		
		var recordIssue = listOfPMIssueWrappers[ currentPmFmRowIndex ].recordIssue;
		if( !recordIssue || !recordIssue.Failure_Component__c ) {
			currentPmFmRowIndex = parseInt( currentPmFmRowIndex ) + 1;
			helper.showToastMessage( 'warning', 'Failure Component', $A.get( '$Label.c.Select_Failure_Component_For_Row' ) + currentPmFmRowIndex );
			return;
		}
			
		var serverAction = component.get( "c.searchFailureModeRecords" );
		if( !serverAction ) {
			return;
		}
		component.set( "v.showSpinner", true );
			
		serverAction.setParams({ 
								"strSearchKeyword" : strSearchKeyword,
								"strFailureComponent" : recordIssue.Failure_Component__c
							  });
							  
		serverAction.setCallback( this, function( response ) {
			
			component.set( "v.showSpinner", false );
			
			var state = response.getState();
			if ( state === "SUCCESS" ) {
				
				var result = JSON.parse( response.getReturnValue() );
				console.log( "searchPmFailureModes", result );
				
				if( result.isSucceeded ) {
					component.set( "v.pmFailureModeDropDown", true );
					console.log( "pmFailureModeDropDown", component.get( "v.pmFailureModeDropDown" ) );
					component.set( "v.listOfFailureModeResults", result.listOfFailureModeResults );
					console.log( 'get', component.get( "v.listOfFailureModeResults" ) );
				}
				else {
					helper.showToastMessage( 'error', 'Error!', result.message );
				}
			}
			else {
				helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Something_Went_Wrong_Please_Contact_Admin' ) );
			}
		});
			
		$A.enqueueAction( serverAction );
	},
	
	updatePMIssues : function( component, listOfPMIssueWrappers, behaviorCode ) {
        
        var helper = this;
        
		
		var listOfSelectedPMIssueWrappers = helper.getListOfSelectedRecordWrappers( component, listOfPMIssueWrappers );
        if( !listOfSelectedPMIssueWrappers || listOfSelectedPMIssueWrappers.length == 0 ) {
            helper.showToastMessage( 'warning', 'Warning!', $A.get( '$Label.c.Select_At_Least_One' ) );
            return;
        }
		
		var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
		helper.populateCommonDetailsOnPMIssues( component, recordCommonIssue, listOfSelectedPMIssueWrappers );
        
		var areAllRecordsValid = helper.applyPMValidations( component, listOfSelectedPMIssueWrappers );
		if( !areAllRecordsValid ) {
			return;
		}
        
        for(var r in listOfSelectedPMIssueWrappers){
            
            if(listOfSelectedPMIssueWrappers[r].isSelected){
                
                 var issueRecVal = listOfSelectedPMIssueWrappers[r].recordIssue;
                var fieldsMap = listOfSelectedPMIssueWrappers[r].updateSfmMap;
                var selectedFM = listOfSelectedPMIssueWrappers[r].listOfSelectedFailureModesNames;
                var checkFields = [];
                for(var p in selectedFM){
                    var fieldsVal = fieldsMap[selectedFM[p]];
                    for(var s in fieldsVal){
                        checkFields.push(fieldsVal[s]);
                    }
                }
                
                if(checkFields.length>0){
                for(var k in checkFields){
                    if( (issueRecVal[checkFields[k]] == undefined)|| (issueRecVal[checkFields[k]] == '')
                       || (issueRecVal[checkFields[k]] == null)){
                     helper.showToastMessage('error', 'Missing!', 'Please enter Failure Mode details for  '+listOfSelectedPMIssueWrappers[r].recordIssue.Name +' to continue..');
						return;
                    }
                }
            }
            }
           
        }
        
        
        //Legacy Opp
        var legacyOpp = component.get('v.recordWorkOrder.Opportunity__r.IGU_Pigtail_Style__c');
        console.log('Opp Legacy? ',legacyOpp);
        if(legacyOpp == 'Legacy' && (behaviorCode == 2 || behaviorCode == 3))
        {
            console.log('in If condition');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                'type': 'Info',
                'title': 'Legacy Opportunity!',
                'message': 'Since this is a site with legacy CSS, please create an Issue for any legacy adapter needed and submit for approval.',
                'duration': 10000
            });
            toastEvent.fire();
        }
        
        
		var serverAction = component.get( "c.updatePMIssueRecords" );
        if( !serverAction ) {
            return;
        }
        component.set( "v.showSpinner", true );
        
        serverAction.setParams({ 
								"strJSONListOfPMIssuesWrappers" : JSON.stringify( listOfSelectedPMIssueWrappers ),
								"behaviorCode" : behaviorCode
							  });
        serverAction.setCallback( this, function( response ) {
			
			if( behaviorCode != 2 ) {
				component.set("v.showSpinner", false );
            }
			
			var state = response.getState();
            if ( state === "SUCCESS" ) {
                
				var result = JSON.parse( response.getReturnValue() );
                console.log( result );
                
				if( result.isSucceeded ) {
                    component.set( "v.areAllPMIssuesSelected", false );
					helper.showToastMessage( 'success', 'Success!', result.message );
					
					if( behaviorCode == 1 ) {
						helper.refreshIssuesTable( component, null, helper );
					}
					else if( behaviorCode == 2 ) {
						var listOfSubmittedIssues = helper.getIssuesFromWrappers( component, listOfSelectedPMIssueWrappers );
						setTimeout( function() {
							helper.showSubmittedIssuesModal( component, helper, listOfSubmittedIssues );
						}, 5000 );
					}
					else if( behaviorCode == 3 ) {
						helper.cancel( component, helper );
					}
                }
                else {
					component.set("v.showSpinner", false );
                    helper.showToastMessage( 'error', 'Error!', result.message );
                }
            }
            else {
				component.set("v.showSpinner", false );
                helper.showToastMessage( 'error', 'Error!', $A.get( '$Label.c.Something_Went_Wrong_Please_Contact_Admin' ) );
            }
        });
        
        $A.enqueueAction( serverAction );
    },
})