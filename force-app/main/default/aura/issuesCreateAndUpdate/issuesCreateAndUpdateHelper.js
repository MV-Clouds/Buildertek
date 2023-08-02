/*
	@ PURPOSE : 1. PROVIDES SERVICE TO => IssuesCreateAndUpdateController.js
				2. MAKES CALLS TO APEX SERVER.
	@ Name    : IssuesCreateAndUpdateHelper.js
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
	
	setConsoleTabSettings : function( component ) {
			
		var workspaceAPI = component.find( "workspace" );
		if( workspaceAPI ) {
			workspaceAPI.isConsoleNavigation().then( function( response ) {
				console.log( 'Are you in Console Navigation?', response );
				component.set( "v.isConsoleNavigation", response );
			})
			.catch( function( error ) {
				console.log( error );
			});
			
			setTimeout( function() {
                var isConsoleNavigation = component.get( "v.isConsoleNavigation" );
                if( isConsoleNavigation ) {
                    workspaceAPI.getFocusedTabInfo().then( function( response ) {
                        var focusedTabId = response.tabId;
                        if( focusedTabId ) {
                            workspaceAPI.setTabLabel({
                                tabId : focusedTabId,
                                label : $A.get( "$Label.c.WO_Tab_Title" )
                            });
                        }
                    })
                    .catch( function( error ) {
                        console.log( error );
                    });
                }
			}, 2000 );
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
	
	setRecordTypeIdToName : function( component, listOfRecordTypes ) {
		
		if( !listOfRecordTypes || listOfRecordTypes.length == 0 ) {
			return;
		}
		
		var recordTypeIdToName = {};
		for( var index = 0; index < listOfRecordTypes.length; index ++ ) {
			var recordTypeWrapper = listOfRecordTypes[ index ];
			recordTypeIdToName[ recordTypeWrapper.id ] = recordTypeWrapper.value;
		}
		
		console.log( 'recordTypeIdToName', recordTypeIdToName );
		component.set( "v.recordTypeIdToName", recordTypeIdToName );
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
			var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
			if( recordWorkOrder && recordWorkOrder.Id ) {
				helper.refreshIssues( component, recordWorkOrder.Id );
			}
		}
    },
	
	getRecordTypeNameFromId : function( component, selectedRecordTypeId ) {
		
		var helper = this;
		var selectedRecordTypeName = null;
		
		if( !selectedRecordTypeId ) {
			return;
		}
		
		var listOfRecordTypes = JSON.parse( JSON.stringify( component.get( "v.listOfRecordTypes" ) ) );
		console.log( 'getRecordTypeNameFromId', listOfRecordTypes );
		if( !listOfRecordTypes || listOfRecordTypes.length < 1 ) {
			return;
		}
			
		listOfRecordTypes.map( function( recordType, index ) {
			if( recordType.id == selectedRecordTypeId ) {
				selectedRecordTypeName = recordType.value;
			}
		});
		console.log( 'selectedRecordTypeName', selectedRecordTypeName );
		return selectedRecordTypeName;
	},
	
	getAssetFromAssetId : function( component, assetId ) {
		
		var helper = this;
		var selectedAsset = null;
		
		if( !assetId ) {
			return selectedAsset;
		}
		
		var listOfIGULiteSearchResults = JSON.parse( JSON.stringify( component.get( "v.listOfIGULiteSearchResults" ) ) );
		console.log( 'listOfIGULiteSearchResults', listOfIGULiteSearchResults );
		if( !listOfIGULiteSearchResults || listOfIGULiteSearchResults.length < 1 ) {
			return selectedAsset;
		}
			
		listOfIGULiteSearchResults.map( function( recordAsset, index ) {
			if( recordAsset.Id == assetId ) {
				selectedAsset = recordAsset;
			}
		});
		console.log( 'selectedAsset', selectedAsset );
		return selectedAsset;
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
	
	selectAllRecordWrappers : function( component, areAllRecordWrappersSelected, listOfRecordWrappers ) {
    	
		console.log( 'areAllRecordWrappersSelected', areAllRecordWrappersSelected );
		console.log( 'selectAllRecordWrappers', listOfRecordWrappers );
        if( listOfRecordWrappers && listOfRecordWrappers.length > 0 ) {
            for( var index = 0; index < listOfRecordWrappers.length; index++ ) {
                listOfRecordWrappers[index].isSelected = areAllRecordWrappersSelected;
            }
        }
    },
	
	getListOfSelectedRecordWrappers : function( component, listOfRecordWrappers ) {
    	
        console.log( 'before-getListOfSelectedRecordWrappers', listOfRecordWrappers );
        var listOfSelectedRecordWrappers = [];
		var recordIssue;
		
        if( listOfRecordWrappers && listOfRecordWrappers.length > 0 ) {
			for( var index = 0; index  < listOfRecordWrappers.length; index ++ ) {
                if( listOfRecordWrappers[index].isSelected ) {
					
					recordIssue = listOfRecordWrappers[index].recordIssue;
					if( !recordIssue.Start_Date__c ) {
						recordIssue.Start_Date__c = null;
					}
					if( !recordIssue.End_Date__c ) {
						recordIssue.End_Date__c = null;
					}
                    listOfSelectedRecordWrappers.push( listOfRecordWrappers[ index ] );
                }
            }
        }
        console.log( 'after-getListOfSelectedRecordWrappers', listOfSelectedRecordWrappers );
        return listOfSelectedRecordWrappers;
    },
    
	getRecordTypeIdFromName : function( component, helper, recordTypeName ) {
		
		var recordTypeId;
		if( !recordTypeName ) {
			return recordTypeId;
		}
		
		var listOfRecordTypes = JSON.parse( JSON.stringify( component.get( "v.listOfRecordTypes" ) ) );
		console.log( 'getRecordTypeIdFromName-listOfRecordTypes', listOfRecordTypes );
		
		listOfRecordTypes.map( function( recordType, index ) {
			if( recordType.value == recordTypeName ) {
				recordTypeId = recordType.id;
				return recordTypeId;
			}
		});
		console.log( 'getRecordTypeIdFromName-recordTypeId', recordTypeId );
		return recordTypeId;
	},
	
	checkBoxLinkUpdated : function( component, helper, listOfSelectedIssueWrappers ) {
		
		var isBoxLinkUpdated = false;
		if( !listOfSelectedIssueWrappers || listOfSelectedIssueWrappers.length == 0 ) {
			return isBoxLinkUpdated;
		}
		
		
		for( var index = 0; index < listOfSelectedIssueWrappers.length; index ++ ) {
			var wrapper = listOfSelectedIssueWrappers[ index ];
			
			if( wrapper && wrapper.recordIssue ) {
				if( wrapper.recordIssue.Create_Box_Folder__c && !wrapper.recordIssue.BOX_Folder_Id__c ) {
					isBoxLinkUpdated = true;
					return isBoxLinkUpdated;
				}
			}
		}
		return isBoxLinkUpdated;
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
	
	clearTrunkSearchedKeyword : function( component, index ) {
        
        var listOfPartRequestedWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPartRequestedWrappers" ) ) );
        console.log( 'before-clearTrunkSearchedKeyword-listOfPartRequestedWrappers', listOfPartRequestedWrappers );
        if( listOfPartRequestedWrappers && listOfPartRequestedWrappers.length > index ) {
            var partRequestedWrapper = listOfPartRequestedWrappers[ index ];
            console.log( 'partRequestedWrapper', partRequestedWrapper );
            
            if( partRequestedWrapper && partRequestedWrapper.recordIssue ) {
				component.set( "v.trunkDropDown", false );
				
                partRequestedWrapper.recordIssue.Trunk__c = null;
                partRequestedWrapper.recordIssue.Trunk__r = null;
				partRequestedWrapper.recordTrunk.Name = null;
				partRequestedWrapper.recordTrunk.Id = null;
				
                console.log( 'after-clearTrunkSearchedKeyword-listOfPartRequestedWrappers', listOfPartRequestedWrappers );
            	component.set( "v.listOfPartRequestedWrappers", listOfPartRequestedWrappers );
            }
        }
    },
	
	handleRecordTypeChange :  function( component, currentRowIndex, listOfRecordWrappers ) {
		
		var helper = this;
		if( currentRowIndex == undefined || !listOfRecordWrappers || listOfRecordWrappers.length <= currentRowIndex ) {
			return null;
		}
		
		var issueWrapper = listOfRecordWrappers[ currentRowIndex ];
		if( !issueWrapper || !issueWrapper.recordIssue || !issueWrapper.recordIssue.RecordTypeId ) {
			return null;
		}
		
		var selectedRecordTypeName = helper.getRecordTypeNameFromId( component, issueWrapper.recordIssue.RecordTypeId );
		if( !selectedRecordTypeName ) {
			return null;
		}
		
		var recordTypeNameToListOfFailureComponents;
		recordTypeNameToListOfFailureComponents = JSON.parse( JSON.stringify( component.get( "v.recordTypeNameToListOfFailureComponents" ) ) );
		
		if( !recordTypeNameToListOfFailureComponents ) {
			return null;
		}
		
		issueWrapper.listOfFailureComponentValues = recordTypeNameToListOfFailureComponents[ selectedRecordTypeName.toLowerCase() ];
		if( issueWrapper.listOfFailureComponentValues && issueWrapper.listOfFailureComponentValues.length > 0 ) {
			issueWrapper.listOfFailureComponentValues = issueWrapper.listOfFailureComponentValues.sort();
		}
		
		var recordTypeNameToListOfWorkTypes;
		recordTypeNameToListOfWorkTypes = JSON.parse( JSON.stringify( component.get( "v.recordTypeNameToListOfWorkTypes" ) ) );
					
		if( !recordTypeNameToListOfWorkTypes ) {
			return null;
		}
		
		issueWrapper.listOfWorkTypeValues = recordTypeNameToListOfWorkTypes[ selectedRecordTypeName.toLowerCase() ];
		if( issueWrapper.listOfWorkTypeValues && issueWrapper.listOfWorkTypeValues.length > 0 ) {
			issueWrapper.listOfWorkTypeValues = issueWrapper.listOfWorkTypeValues.sort();
		}
		
		return listOfRecordWrappers;
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
		
		component.set( "v." + listName, listOfIssueRecordWrappers );
	},
	
	handleTrunkOptionClick : function( component, currentTrunkRowIndex, selectedId, selectedValue ) {
        
		var listOfPartRequestedWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPartRequestedWrappers" ) ) );
        console.log( 'before-handleTrunkOptionClick-listOfPartRequestedWrappers', listOfPartRequestedWrappers );
        if( listOfPartRequestedWrappers && listOfPartRequestedWrappers.length > currentTrunkRowIndex && selectedId && selectedValue ) {
            var partRequestedWrapper = listOfPartRequestedWrappers[ currentTrunkRowIndex ];
            console.log( 'partRequestedWrapper', partRequestedWrapper );
            
            if( partRequestedWrapper && partRequestedWrapper.recordIssue ) {
				component.set( "v.trunkDropDown", false );
                partRequestedWrapper.recordIssue.Trunk__c = selectedId;
                partRequestedWrapper.recordIssue.Trunk__r = { 'Id' : selectedId, 'Name' : selectedValue };
				partRequestedWrapper.recordTrunk = { 'Id' : selectedId, 'Name' : selectedValue };
                console.log( 'after-handleTrunkOptionClick-listOfPartRequestedWrappers', listOfPartRequestedWrappers );
            	component.set( "v.listOfPartRequestedWrappers", listOfPartRequestedWrappers );
            }
        }
	},
	
	parseDateToString : function( dateValue ) {
			
		var todayDate = '';
		var checkDate = new Date( dateValue );
		
		if( checkDate == 'Invalid Date' || isNaN( checkDate ) ) {
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
	
	validateQuoteToContactFields : function( component, helper ) {
		
		var areQuoteToContactFieldsValid = true;
		var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
		
		if( !recordCommonIssue || !recordCommonIssue.Customer_Contact__c ) {
			areQuoteToContactFieldsValid = false;
			helper.showToastMessage( 'error',  $A.get("$Label.c.Quote_Contact_Missing"), $A.get("$Label.c.Provide_Quote_To_Contact_Details") );
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
			helper.showToastMessage( 'error', $A.get( "$Label.c.Shipping_Contact_Missing" ), $A.get( "$Label.c.Provide_Shipping_Contact_Details" ) );
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
			helper.showToastMessage( 'error', $A.get("$Label.c.Shipping_Contact_Missing"), $A.get("$Label.c.Provide_Shipping_Address_Details") );
		}
		return areShippingInformationFieldsValid;
	},
	applyStatusCriteria : function( component, listOfSelectedIssueWrappers ) {
   
                     var helper = this;
                     var isStatusFailed = false;
        
        	         for( var index = 0; index < listOfSelectedIssueWrappers.length; index ++ ) {
			          var wrapper = listOfSelectedIssueWrappers[ index ];
			         console.log(' wrapper ',wrapper);
          	         if(wrapper.recordIssue.Issue_Status__c=='Resolved'
                     && wrapper.recordIssue.Product_Return__c
                     && ( !wrapper.recordIssue.Reverse_Shipment_Info__c
                      || !wrapper.recordIssue.RMA_FA_Status__c)){
                       isStatusFailed = true;
            }
                
            }
        
        return isStatusFailed;
		
    },
	applyCommonValidations : function( component, listOfSelectedIssueWrappers ) {
		
		var helper = this;
		
		if( !listOfSelectedIssueWrappers || listOfSelectedIssueWrappers.length <= 0 ) {
			return false;
		}
		var todayDate = helper.parseDateToString( new Date() );
		
		var cableId = helper.getRecordTypeIdFromName( component, helper, 'Cable' );
		
		for( var index = 0; index < listOfSelectedIssueWrappers.length; index ++ ) {
			var wrapper = listOfSelectedIssueWrappers[ index ];
			
			if( !wrapper.recordIssue.Window_ID__c && !wrapper.recordIssue.Control_Panel__c && wrapper.recordIssue.Issue_Status__c != 'Canceled') {
				helper.showToastMessage( 'error', $A.get( "$Label.c.Missing" ), 
										 $A.get( "$Label.c.Provide_Window_Id_Or_Control_Panel" ) + ' for ' + wrapper.recordIssue.Name
									   );
				return false;
			}
			else if ( !wrapper.recordIssue.Comments__c ) {
                helper.showToastMessage( 'error', $A.get( "$Label.c.Missing" ),
										 $A.get( "$Label.c.Provide_Notes_Comments" ) + ' for ' + wrapper.recordIssue.Name
									   );
				return false;
            }
			else if( !wrapper.recordIssue.Work_Type__c && wrapper.recordIssue.Issue_Status__c != 'Canceled') {
				helper.showToastMessage( 'error', $A.get( "$Label.c.Missing" ),
										 $A.get( "$Label.c.Provide_Work_Type" )  + ' for ' + wrapper.recordIssue.Name
									   );
				return false;
			}
			else if( !wrapper.recordIssue.Failure_Component__c && wrapper.recordIssue.Issue_Status__c != 'Canceled') {
				helper.showToastMessage( 'error', $A.get( "$Label.c.Missing" ), 
										 $A.get( "$Label.c.Provide_Failure_Component" ) + ' for ' + wrapper.recordIssue.Name
									   );
				return false;
			}
			else if( wrapper.recordIssue.Window_ID__c && wrapper.recordIssue.RecordTypeId == cableId &&
					 wrapper.recordIssue.RecordType.Name != 'IGU (Halos, IGU Defects)' && !wrapper.recordIssue.CAN_ID__c
			) {
				helper.showToastMessage( 'error', $A.get( "$Label.c.Missing" ),
										 $A.get( "$Label.c.Provide_Can_Id_When_Window_Id_Is_Provided_For_Cable" ) + ' for ' + wrapper.recordIssue.Name
									   );
				return false;
			}
			
			if( wrapper.recordIssue.Issue_Status__c == 'Resolved' ) {
				
				if( wrapper.recordIssue.Work_Type__c == 'Troubleshooting' ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get( "$Label.c.Issue_Status_Not_Resolved_Work_Type_is_Troubleshooting" ) + ' for ' + wrapper.recordIssue.Name
										   );
					return false;
				}
				else if( !wrapper.recordIssue.End_Date__c ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get( "$Label.c.Provide_End_Date_If_Issue_Status_Resolved" ) + ' for ' + wrapper.recordIssue.Name
										   );
					return false;
				}
				else if( !wrapper.recordIssue.Failure_Component__c ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get( "$Label.c.Provide_Failure_Component_Issue_Status_Resolved" ) + ' for ' + wrapper.recordIssue.Name
										   );
					return false;
				}
				else if( !wrapper.listOfSelectedFailureModes || wrapper.listOfSelectedFailureModes.length == 0 ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get( "$Label.c.Select_Failure_Mode_When_Issue_Is_Resolved" ) + ' for ' + wrapper.recordIssue.Name
										   );
					return false;
				}
				else if( wrapper.recordIssue.Required_Trade__c && !wrapper.recordIssue.Trade_Support_Provided__c ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get( "$Label.c.Trade_Support_Must_Be_Provided_When_Issue_Is_Resolved" ) + ' for ' + wrapper.recordIssue.Name
										   );
					return false;
				}
			}
			
			if( wrapper.recordIssue.End_Date__c && wrapper.recordIssue.Issue_Status__c != 'Canceled') {
				
				if( wrapper.recordIssue.Issue_Status__c != 'Resolved' ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get( "$Label.c.End_Date_Not_Provided_Issue_Status_Not_Resolved" ) + ' for ' + wrapper.recordIssue.Name 
										   );
					return false;
				}
				else if( wrapper.recordIssue.Start_Date__c > wrapper.recordIssue.End_Date__c ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get( "$Label.c.Issue_Start_Date_Not_Greater_Than_End_Date" ) + ' for ' + wrapper.recordIssue.Name
										   );
					return false;
				}
				else if( wrapper.recordIssue.End_Date__c > todayDate ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get("$Label.c.End_Date_Not_Greater_Than_Today_s_Date" ) + ' for ' + wrapper.recordIssue.Name
										   );
					return false;
				}				
			}
			
			if( !wrapper.recordIssue.Start_Date__c && wrapper.recordIssue.Issue_Status__c != 'Canceled') {
				helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
										 $A.get( "$Label.c.Start_Date_Not_Blank" ) + ' for ' + wrapper.recordIssue.Name
									   );
				return false;
			}
		}
		return true;
	},
	
	applyPartsValidations : function( component, listOfSelectedIssueWrappers ) {
		
		var helper = this;
		
		if( !listOfSelectedIssueWrappers || listOfSelectedIssueWrappers.length <= 0 ) {
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
			helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get( "$Label.c.Select_Quote_To_Contact" ) );
			return false;
		}
		
		if( !recordCommonIssue.Shipping_Contact_Name__c ) {
			helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get( "$Label.c.Provide_Ship_To_Contact_Details" ) );
			return false;
		}
		
		var isRequestedDeliveryDateTomorrow;
		for( var index = 0; index < listOfSelectedIssueWrappers.length; index ++ ) {
			
			var wrapper = listOfSelectedIssueWrappers[ index ];
			if( wrapper.recordIssue.Product__c && ( !wrapper.recordIssue.Quantity__c || wrapper.recordIssue.Quantity__c < 1 ) && wrapper.recordIssue.Issue_Status__c != 'Canceled') {
				helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
										 $A.get( "$Label.c.Provide_Quantity_For_Product" ) + ' for ' + wrapper.recordIssue.Name 
									   );
				return false;
			}
			
			if( wrapper.recordIssue.Requested_Delivery_Date__c && wrapper.recordIssue.Issue_Status__c != 'Canceled') {
				dateValue = new Date( wrapper.recordIssue.Requested_Delivery_Date__c );
				if( dateValue != 'Invalid Date' && isNaN( dateValue ) == false ) {
					
					dateValue = wrapper.recordIssue.Requested_Delivery_Date__c;
					if( dateValue <= todayDate ) {
						helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
												 $A.get( "$Label.c.Requested_Delivery_Date_Is_Future_Date" ) + ' for ' + wrapper.recordIssue.Name 
											   );
						return false;
					}
					else if( dateValue == tomorrowDate && isThisPostMeridiem ) {
						helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
												 $A.get( "$Label.c.Requested_Delivery_Date_Cannot_Be_Tomorrow_s_Date" ) + ' for ' + wrapper.recordIssue.Name 
											   );
						return false;
					}
				}
			}
			else {
				wrapper.recordIssue.Requested_Delivery_Date__c = null;
			}
			
			if( recordCommonIssue.Product_Replacement__c && wrapper.recordIssue.Issue_Status__c != 'Canceled') {
				if( wrapper.listOfSelectedFailureModes.length == 0 ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get( "$Label.c.Select_Failure_Mode_When_Order_Replacement_Checked" ) + ' for ' + wrapper.recordIssue.Name 
										   );
					return false;
				}
				else if( !wrapper.recordIssue.Ownership__c ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ), 
											 $A.get( "$Label.c.Select_Who_Caused_Damage_When_Order_Replacement_Checked" ) + ' for ' + wrapper.recordIssue.Name 
										   );
					return false;
				}
				else if( !wrapper.recordIssue.Product__c ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get( "$Label.c.Provide_Product_Details_When_Order_Replacement_Checked" ) + ' for ' + wrapper.recordIssue.Name 
										   );
					return false;
				}
				else if( !wrapper.recordIssue.Quantity__c || wrapper.recordIssue.Quantity__c < 1 ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ), 
											 $A.get( "$Label.c.Provide_Quantity_When_Order_Replacement_Checked" ) + ' for ' + wrapper.recordIssue.Name 
										   );
					return false;
				}
				else if( !wrapper.recordIssue.Reason_for_Replacement__c ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get( "$Label.c.Select_Reason_For_Replacement_Order_When_Replacement_Checked" ) + ' for ' + wrapper.recordIssue.Name 
										   );
					return false;
				}
				else if( !wrapper.recordIssue.Shipping_Street_1__c || !wrapper.recordIssue.Shipping_City__c ||
						 !wrapper.recordIssue.Shipping_State_Province__c || !wrapper.recordIssue.Shipping_Postal_Code__c ||
						 !wrapper.recordIssue.Shipping_Country__c
				) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get("$Label.c.Provide_Shipping_Information_Details") + ' for ' + wrapper.recordIssue.Name 
										   );
					return false;
				}
				else {
					dateValue = new Date( wrapper.recordIssue.Requested_Delivery_Date__c );
					if( wrapper.recordIssue.Requested_Delivery_Date__c == null || dateValue == 'Invalid Date' || isNaN( dateValue ) ) {
						helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ), 
												 $A.get( "$Label.c.provide_Requested_Delivery_Date_When_Order_Replacement_Checked" ) + 
												 ' for ' + wrapper.recordIssue.Name 
											   );
						return false;
					}
				}
			}
		}
		return true;
	},
	
	applyIGUValidations : function( component, listOfSelectedIssueWrappers ) {
		
		var helper = this;
		
		if( !listOfSelectedIssueWrappers || listOfSelectedIssueWrappers.length <= 0 ) {
			return false;
		}
		
		var recordWorkOrderSettings = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrderSettings" ) ) );
		
		for( var index = 0; index < listOfSelectedIssueWrappers.length; index ++ ) {
			
			var wrapper = listOfSelectedIssueWrappers[ index ];
			var errorIndex = index + 1;
			
			if( !wrapper.recordIssue.IGU_ID_Provided__c && wrapper.recordIssue.Lite_ID_Mock_ID__c && wrapper.recordIssue.Issue_Status__c != 'Canceled') {
				helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
										 $A.get( "$Label.c.Select_IGU_Id_Provided_when_Lite_ID_Mock_Id_Provided" ) + ' for ' + wrapper.recordIssue.Name 
									   );
				return false;
			}
			else if( wrapper.recordIssue.Surface_Mitigated_From__c && wrapper.recordIssue.Issue_Status__c != 'Canceled') {
				if( !wrapper.recordIssue.X_From_Logo_in__c ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get( "$Label.c.Provide_X_From_Logo_When_Mitigation_Provided" ) + ' for ' + wrapper.recordIssue.Name 
										   );
					return false;
				}
				if( !wrapper.recordIssue.Y_From_Logo_in__c ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get( "$Label.c.Provide_Y_From_Logo_When_Mitigation_Provided" ) + ' for ' + wrapper.recordIssue.Name 
										   );
					return false;
				}
			}
			
			if( wrapper.recordIssue.Halo_Type__c && wrapper.recordIssue.Issue_Status__c != 'Canceled') {
				if( !wrapper.recordIssue.Create_Box_Folder__c ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get( "$Label.c.Create_Box_Folder_When_Halo_s_Entered" ) + ' for ' + wrapper.recordIssue.Name 
										   );
					return false;
				}
				else if( wrapper.recordIssue.Halo_Type__c.startsWith( 'Edge Halo' ) &&
                         !wrapper.recordIssue.Required_Trade__c 
                ) {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 $A.get( "$Label.c.Select_Trade_Support_When_Edge_Halo_Selected" ) + ' for ' + wrapper.recordIssue.Name 
										   );
					return false;
				}
			}
			
			if( wrapper.recordIssue.Issue_Status__c == 'Resolved' && 
                ( wrapper.recordIssue.Replacement_Needed__c == 'Yes'
                  ||
                  !recordWorkOrderSettings.Avoid_Quality_Analysis_Validation__c 
            	) 
			) {
			/*	if( !wrapper.recordIssue.Replaced_SWC__c || !wrapper.recordIssue.Lite_Damaged__c || 
					!wrapper.recordIssue.Replaced_WC__c || !wrapper.recordIssue.Visible_BB_Damage__c ||
					!wrapper.recordIssue.Replaced_IGU_Cable__c || !wrapper.recordIssue.Reflection_Color_Observed__c ||
					!wrapper.recordIssue.Reflection_Color_Degree__c
				) {
					helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get("$Label.c.Provide_Quality_Analysis_Fields_When_Issue_Resolved") );
					return false;
				}*/
			}
            if((wrapper.recordIssue.Replacement_Needed__c === 'Yes') 
               && (!wrapper.recordIssue.IGU_ID_Provided__c || !wrapper.recordIssue.Lite_ID_Mock_ID__c )
               && wrapper.recordIssue.Issue_Status__c != 'Canceled'){
                helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ),
											 "IGU ID Provided and Lite Id/Mock Id is mandatory" + ' for ' + wrapper.recordIssue.Name 
										   );
					return false;
            }
		}
		return true;
	},
	
	populateValueOnIssues : function( component, helper, fieldName, fieldValue ) {
		
		if( !fieldName ) {
			return;
		}
		
		var listOfPartRequestedWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPartRequestedWrappers" ) ) );
		if( !listOfPartRequestedWrappers || listOfPartRequestedWrappers.length == 0 ) {
			return;
		}
		
		var anyRecordUpdated = false;
		
		for( var index = 0; index < listOfPartRequestedWrappers.length; index ++ ) {
			var wrapper = listOfPartRequestedWrappers[ index ];
			if( wrapper && wrapper.isSelected ) {
				wrapper.recordIssue[ fieldName ] = fieldValue;
				anyRecordUpdated = true;
			}
		}
		console.log( 'populateOwnershipOnIssues-listOfPartRequestedWrappers', listOfPartRequestedWrappers );
		
		if( anyRecordUpdated ) {
			component.set( "v.listOfPartRequestedWrappers", listOfPartRequestedWrappers );
		}
	},
	
	populateAddressValueOnIssues : function( component, helper, recordCommonIssue ) {
		
		if( !recordCommonIssue ) {
			return;
		}
		
		var listOfPartRequestedWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPartRequestedWrappers" ) ) );
		if( !listOfPartRequestedWrappers || listOfPartRequestedWrappers.length == 0 ) {
			return;
		}
		
		var anyRecordUpdated = false;
		
		for( var index = 0; index < listOfPartRequestedWrappers.length; index ++ ) {
			var wrapper = listOfPartRequestedWrappers[ index ];
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
		console.log( 'populateOwnershipOnIssues-listOfPartRequestedWrappers', listOfPartRequestedWrappers );
		
		if( anyRecordUpdated ) {
			component.set( "v.listOfPartRequestedWrappers", listOfPartRequestedWrappers );
		}
	},
	
	populateWOValuesOnIssues : function( component, recordWorkOrder, listOfIssueWrappers ) {
		
		console.log( 'populateWOValuesOnIssues-recordWorkOrder', recordWorkOrder );
		console.log( 'populateWOValuesOnIssues-before-listOfIssueWrappers', listOfIssueWrappers );
		
		if( recordWorkOrder && recordWorkOrder.Opportunity__c && listOfIssueWrappers && listOfIssueWrappers.length > 0 ) {
			for( var index = 0; index < listOfIssueWrappers.length; index ++ ) {
				var recordIssue = listOfIssueWrappers[ index ].recordIssue;
				
				if( recordIssue && !recordIssue.Opportunity__c ) {
					recordIssue.Opportunity__c = recordWorkOrder.Opportunity__c;
				}
			}
		}
		console.log( 'populateWOValuesOnIssues-after-listOfIssueWrappers', listOfIssueWrappers );
	},
	
	populateCommonDetailsOnParts : function( component, recordCommonIssue, listOfSelectedPartWrappers ) {
		
		console.log( 'populateCommonDetailsOnParts-recordCommonIssue', recordCommonIssue );
		console.log( 'populateCommonDetailsOnParts-listOfSelectedPartWrappers', listOfSelectedPartWrappers );
		
		if( recordCommonIssue && recordCommonIssue.Shipping_Contact_Name__c && 
			listOfSelectedPartWrappers && listOfSelectedPartWrappers.length > 0 
		) {
			for( var index = 0; index < listOfSelectedPartWrappers.length; index ++ ) {
				var wrapper = listOfSelectedPartWrappers[ index ];
				var recordIssue = wrapper.recordIssue;
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
					recordIssue.Product_Return__c = recordCommonIssue.Product_Return__c;
					
					if( recordIssue.Consumed_From_Trunk__c ) {
						recordIssue.Trunk__c = wrapper.recordTrunk.Id;
					}
				}
			}
		}
	},
	
	fetchIssues : function( component, workOrderId ) {
        
		var helper = this;
        
		if( !workOrderId ) {
			helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get("$Label.c.Work_Order_Record_Not_Found_Try_Again") );
			return;
		}
		
        var serverAction = component.get( "c.getIssues" );
        if( !serverAction ) {
            return;
        }
        
        component.set( "v.showSpinner", true );
		
        serverAction.setParams({ "strWorkOrderId" : workOrderId });
		
        serverAction.setCallback( this, function( response ) {
            
            component.set("v.showSpinner", false );
            
            var state = response.getState();
            if ( state === "SUCCESS" ) {
				
                var result = JSON.parse( response.getReturnValue() );
                console.log( result );
                
                if( result.recordWorkOrderSettings.Show_Create_Issues_Tab__c ) {
                    component.set( "v.activeTabId", "one" );
                }
                else if( result.recordWorkOrderSettings.Show_PM_Pending_Tab__c ) {
                    if( result.listOfPMIssueWrappers && result.listOfPMIssueWrappers.length > 0 ) {
                        component.set( "v.activeTabId", "three" );
                    }
                    else {
                        component.set( "v.activeTabId", "four" );
                    }
                }
				
				component.set( "v.recordWorkOrderSettings", result.recordWorkOrderSettings );
				component.set( "v.listOfRecordTypes", result.listOfRecordTypes );
				component.set( "v.listOfFailureComponentValues", result.listOfFailureComponentValues );
				component.set( "v.listOfWorkTypeValues", result.listOfWorkTypeValues );
				component.set( "v.listOfIGUReplacements", result.listOfIGUReplacements );
				component.set( "v.listOfCSSReplacements", result.listOfCSSReplacements );
				component.set( "v.listOfResponsibleEntities", result.listOfResponsibleEntities );
				component.set( "v.listOfTradeSupportValues", result.listOfTradeSupportValues );
				
				component.set( "v.recordTypeNameToListOfFailureComponents", result.recordTypeNameToListOfFailureComponents );
				component.set( "v.recordTypeNameToListOfWorkTypes", result.recordTypeNameToListOfWorkTypes );
				
				component.set( "v.recordWorkOrder", result.recordWorkOrder );
				
				result.recordCommonIssue.Customer_Contact__r = {
																'Name' : result.recordCommonIssue.Shipping_Contact_Name__c,
																'Phone' : result.recordCommonIssue.Shipping_Contact_Number__c,
																'Email' : result.recordCommonIssue.Shipping_Contact_Email__c
															   };
				component.set( "v.recordCommonIssue", result.recordCommonIssue );
				
				component.set( "v.listOfIssueWrappers", result.listOfIssueWrappers );
				component.set( "v.listOfIGUIssueWrappers", result.listOfIGUIssueWrappers );
				component.set( "v.listOfPartRequestedWrappers", result.listOfPartRequestedWrappers );
				component.set( "v.listOfPMIssueWrappers", result.listOfPMIssueWrappers );
				component.set( "v.listOfCHWTradeIssueWrappers", result.listOfCHWTradeIssueWrappers );
				component.set( "v.listOfIGUTradeIssueWrappers", result.listOfIGUTradeIssueWrappers );
				
				if( ( result.listOfCHWTradeIssueWrappers && result.listOfCHWTradeIssueWrappers.length > 0 )
					||
					( result.listOfIGUTradeIssueWrappers && result.listOfIGUTradeIssueWrappers.length > 0 )
				) {
					component.set( "v.areTradeSupportIssuesAvailable", true );
				}
				else {
					component.set( "v.areTradeSupportIssuesAvailable", false );
				}
					
				if( result.isSucceeded ) {
					
					helper.setRecordTypeIdToName( component, result.listOfRecordTypes );
					
					if( result.listOfRecordTypes.length == 0 ) {
						helper.showToastMessage( 'info', '', $A.get("$Label.c.Record_Types_Of_Issue_Are_Not_Found") );
					}
                }
                else {
                    helper.showToastMessage( 'info', '', result.message );
					if( result.recordWorkOrder.CaseId ) {
						component.set( "v.recordWorkOrder", result.recordWorkOrder );
					}
                }
            }
            else {
                helper.showToastMessage( 'error', $A.get("$Label.c.Error"),$A.get("$Label.c.Something_Went_Wrong_Please_Contact_Admin"));
            }
                
        });
        
        $A.enqueueAction( serverAction );
    },
	
	refreshIssues : function( component, workOrderId ) {
        
		var helper = this;
        
		if( !workOrderId ) {
			helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ), $A.get( "$Label.c.Work_Order_Record_Not_Found_Try_Again" ) );
			return;
		}
		
        var serverAction = component.get( "c.getUpdatedIssuesOnly" );
        if( !serverAction ) {
            return;
        }
        
        component.set( "v.showSpinner", true );
		
        serverAction.setParams({ "strWorkOrderId" : workOrderId });
		
        serverAction.setCallback( this, function( response ) {
            
            component.set("v.showSpinner", false );
            
            var state = response.getState();
            if ( state === "SUCCESS" ) {
				
                var result = JSON.parse( response.getReturnValue() );
                console.log( result );
                
				if( result.isSucceeded ) {
					
					var recordWorkOrderSettings = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrderSettings" ) ) );
					if( recordWorkOrderSettings.Show_Create_Issues_Tab__c ) {
						component.set( "v.activeTabId", "one" );
					}
					else if( recordWorkOrderSettings.Show_PM_Pending_Tab__c ) {
						if( result.listOfPMIssueWrappers && result.listOfPMIssueWrappers.length > 0 ) {
							component.set( "v.activeTabId", "three" );
						}
						else {
							component.set( "v.activeTabId", "four" );
						}
					}
				
					component.set( "v.listOfIssueWrappers", result.listOfIssueWrappers );
					component.set( "v.listOfIGUIssueWrappers", result.listOfIGUIssueWrappers );
					component.set( "v.listOfPartRequestedWrappers", result.listOfPartRequestedWrappers );
					component.set( "v.listOfPMIssueWrappers", result.listOfPMIssueWrappers );
					component.set( "v.listOfCHWTradeIssueWrappers", result.listOfCHWTradeIssueWrappers );
					component.set( "v.listOfIGUTradeIssueWrappers", result.listOfIGUTradeIssueWrappers );
					
					if( ( result.listOfCHWTradeIssueWrappers && result.listOfCHWTradeIssueWrappers.length > 0 )
						||
						( result.listOfIGUTradeIssueWrappers && result.listOfIGUTradeIssueWrappers.length > 0 )
					) {
						component.set( "v.areTradeSupportIssuesAvailable", true );
					}
					else {
						component.set( "v.areTradeSupportIssuesAvailable", false );
					}
                }
                else {
                    helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ), result.message );
                }
            }
            else {
                helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ), $A.get( "$Label.c.Something_Went_Wrong_Please_Contact_Admin" ) );
            }
                
        });
        
        $A.enqueueAction( serverAction );
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
						helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ), result.message );
					}
				}
				else {
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ), $A.get( "$Label.c.Something_Went_Wrong_Please_Contact_Admin" ) );
				}
			});
			
			$A.enqueueAction( serverAction );
		}
	},
	
	searchTrunks : function( component, strSearchKeyword, currentTrunkRowIndex ) {
		
		var helper = this;
		console.log( 'searchTrunks-strSearchKeyword', strSearchKeyword );
		console.log( 'searchTrunks-currentTrunkRowIndex', currentTrunkRowIndex );
		
		if( !strSearchKeyword || strSearchKeyword.length < 3 && currentTrunkRowIndex < 0 ) {
			return;
		}
		
		var serverAction = component.get( "c.searchTrunkRecords" );
		if( !serverAction ) {
			return;
		}
		component.set( "v.showSpinner", true );
			
		serverAction.setParams({ 
								"strSearchKeyword" : strSearchKeyword
							  });
							  
		serverAction.setCallback( this, function( response ) {
			
			component.set( "v.showSpinner", false );
			
			var state = response.getState();
			if ( state === "SUCCESS" ) {
				
				var result = JSON.parse( response.getReturnValue() );
				console.log( "searchTrunks", result );
				
				if( result.isSucceeded ) {
					component.set( "v.trunkDropDown", true );
					console.log( "trunkDropDown", component.get( "v.trunkDropDown" ) );
					component.set( "v.listOfTrunkSearchResults", result.listOfTrunkSearchResults );
					console.log( 'get', component.get( "v.listOfTrunkSearchResults" ) );
				}
				else {
					helper.showToastMessage( 'error', $A.get("$Label.c.Error"), result.message );
				}
			}
			else {
				helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get("$Label.c.Something_Went_Wrong_Please_Contact_Admin"));
			}
		});
			
		$A.enqueueAction( serverAction );
	},
	
	saveIssues : function( component, strWorkOrderId, listOfIssueWrappers, areTheseIGUIssues ) {
        
        var helper = this;
        
        console.log( 'saveIssues-strWorkOrderId', strWorkOrderId );
		console.log( 'saveIssues-listOfIssueWrappers', listOfIssueWrappers );
		console.log( 'saveIssues-areTheseIGUIssues', areTheseIGUIssues );
		
		var listOfSelectedIssueWrappers = helper.getListOfSelectedRecordWrappers( component, listOfIssueWrappers );
        if( !listOfSelectedIssueWrappers || listOfSelectedIssueWrappers.length == 0 ) {
            helper.showToastMessage( 'warning', $A.get("$Label.c.Warning"), $A.get("$Label.c.Select_At_Least_One"));
            return;
        }	
		
		if( !strWorkOrderId ) {
			helper.showToastMessage( 'warning', $A.get("$Label.c.Warning"), $A.get("$Label.c.Work_Order_Missing_Try_Again") );
            return;
		}
		var statusCritSatisfied = helper.applyStatusCriteria( component, listOfSelectedIssueWrappers );

                	if(statusCritSatisfied){
            		helper.showToastMessage( 'warning', $A.get("$Label.c.Warning"), 'Fill in reverse shipment info and status before resolving an RMA issue');
    
                     return;
                    }
        
		var areAllRecordsValid = helper.applyCommonValidations( component, listOfSelectedIssueWrappers );
		if( !areAllRecordsValid ) {
			return;
		}
		
		areAllRecordsValid = true;
		if( areTheseIGUIssues ) {
			areAllRecordsValid = helper.applyIGUValidations( component, listOfSelectedIssueWrappers );
		}
		
		if( !areAllRecordsValid ) {
			return;
		}
		
		var isBoxLinkUpdated = helper.checkBoxLinkUpdated( component, helper, listOfSelectedIssueWrappers );
		
		var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
		helper.populateWOValuesOnIssues( component, recordWorkOrder, listOfSelectedIssueWrappers );
		
		component.set( "v.areTradeSupportIssuesAvailable", false );
		
        var serverAction = component.get( "c.updateIssues" );
        if( !serverAction ) {
            return;
        }
		
        component.set( "v.showSpinner", true );
        
        serverAction.setParams({ 
								"strWorkOrderId" : strWorkOrderId, 
								"strJSONListOfIssuesWrappers" : JSON.stringify( listOfSelectedIssueWrappers ) 
							  });
        serverAction.setCallback( this, function( response ) {
			
			if( !isBoxLinkUpdated ) {
				component.set( "v.showSpinner", false );
            }
			
			var state = response.getState();
            if ( state === "SUCCESS" ) {
                
				var result = JSON.parse( response.getReturnValue() );
                console.log( result );
                
				if( result.isSucceeded ) {
					
					console.log( 'before refresh listOfIssueWrappers', JSON.parse( JSON.stringify( component.get( "v.listOfIssueWrappers" ) ) ) );
					console.log( 'before refresh listOfIGUIssueWrappers', JSON.parse( JSON.stringify( component.get( "v.listOfIGUIssueWrappers" ) ) ) );
					
					component.set( "v.listOfIssueWrappers", result.listOfIssueWrappers );
					component.set( "v.listOfIGUIssueWrappers", result.listOfIGUIssueWrappers );
					component.set( "v.listOfPartRequestedWrappers", result.listOfPartRequestedWrappers );
					component.set( "v.listOfPMIssueWrappers", result.listOfPMIssueWrappers );
					
					component.set( "v.listOfCHWTradeIssueWrappers", result.listOfCHWTradeIssueWrappers );
					component.set( "v.listOfIGUTradeIssueWrappers", result.listOfIGUTradeIssueWrappers );
					
					if( ( result.listOfCHWTradeIssueWrappers && result.listOfCHWTradeIssueWrappers.length > 0 )
						||
						( result.listOfIGUTradeIssueWrappers && result.listOfIGUTradeIssueWrappers.length > 0 )
					) {
						component.set( "v.areTradeSupportIssuesAvailable", true );
					}
					
					component.set( "v.areAllIssuesSelected", false );
					component.set( "v.areAllIGUIssuesSelected", false );
					component.set( "v.areAllPartsSelected", false );
					
                    helper.showToastMessage( 'success', $A.get("$Label.c.Success"), result.message );
					
					if( isBoxLinkUpdated ) {
						setTimeout( function() {
							// helper.showToastMessage( 'info', $A.get( "$Label.c.Box_Updating" ), $A.get( "$Label.c.Box_Links_Refreshing" ) );
							helper.refreshIssuesTable( component, null, helper );
						}, 5000 );
					}
                }
                else {
					component.set( "v.showSpinner", false );
                    helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ), result.message );
                }
            }
            else {
				component.set( "v.showSpinner", false );
                helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ), $A.get( "$Label.c.Something_Went_Wrong_Please_Contact_Admin" ) );
            }
        });
        
        $A.enqueueAction( serverAction );
    },
	
	requestParts : function( component, listOfPartRequestedWrappers, behaviorCode ) {
        
        var helper = this;
        
		if( !listOfPartRequestedWrappers || listOfPartRequestedWrappers.length == 0 ) {
            helper.showToastMessage( 'warning', $A.get( "$Label.c.Warning" ), $A.get( "$Label.c.Parts_Not_Requested_Try_Again" ) );
            return;
        }	
		
		var listOfPartRequestedWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfPartRequestedWrappers" ) ) );
		
		var listOfSelectedPartWrappers = helper.getListOfSelectedRecordWrappers( component, listOfPartRequestedWrappers );
        if( !listOfSelectedPartWrappers || listOfSelectedPartWrappers.length == 0 ) {
            helper.showToastMessage( 'warning', $A.get( "$Label.c.Warning" ), $A.get( "$Label.c.Select_At_Least_One" ) );
            return;
        }	
		
		var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
		helper.populateCommonDetailsOnParts( component, recordCommonIssue, listOfSelectedPartWrappers );
		
		var areAllRecordsValid = helper.applyCommonValidations( component, listOfSelectedPartWrappers );
		if( !areAllRecordsValid ) {
			return;
		}
		
		areAllRecordsValid = helper.applyPartsValidations( component, listOfSelectedPartWrappers );
		if( !areAllRecordsValid ) {
			return;
		}
		
		component.set( "v.areTradeSupportIssuesAvailable", false );
		
		var recordWorkOrder = JSON.parse( JSON.stringify( component.get( "v.recordWorkOrder" ) ) );
		
		var serverAction = component.get( "c.updatePartsRequested" );
        if( !serverAction ) {
            return;
        }
        component.set( "v.showSpinner", true );
        
        serverAction.setParams({
								"strWorkOrderId" : recordWorkOrder.Id,
								"strJSONListOfPartsWrappers" : JSON.stringify( listOfSelectedPartWrappers ),
								"behaviorCode" : behaviorCode
							  });
        serverAction.setCallback( this, function( response ) {
			
			if( behaviorCode != 2 ) {
				component.set( "v.showSpinner", false );
            }
			
			var state = response.getState();
            if ( state === "SUCCESS" ) {
                
				var result = JSON.parse( response.getReturnValue() );
                console.log( result );
                
				if( result.isSucceeded ) {
					
					helper.showToastMessage( 'success', $A.get( "$Label.c.Success" ), result.message );
					component.set( "v.areAllPartsSelected", false );
					
					recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.recordCommonIssue" ) ) );
					recordCommonIssue.Product_Replacement__c = true;
					component.set( "v.recordCommonIssue", recordCommonIssue );
					
					component.set( "v.listOfIssueWrappers", result.listOfIssueWrappers );
					component.set( "v.listOfIGUIssueWrappers", result.listOfIGUIssueWrappers );
					component.set( "v.listOfPartRequestedWrappers", result.listOfPartRequestedWrappers );
					component.set( "v.listOfPMIssueWrappers", result.listOfPMIssueWrappers );
					component.set( "v.listOfCHWTradeIssueWrappers", result.listOfCHWTradeIssueWrappers );
					component.set( "v.listOfIGUTradeIssueWrappers", result.listOfIGUTradeIssueWrappers );
					
					if( ( result.listOfCHWTradeIssueWrappers && result.listOfCHWTradeIssueWrappers.length > 0 )
						||
						( result.listOfIGUTradeIssueWrappers && result.listOfIGUTradeIssueWrappers.length > 0 )
					) {
						component.set( "v.areTradeSupportIssuesAvailable", true );
					}
					
					if( behaviorCode == 2 ) {
						var listOfSubmittedIssues = helper.getIssuesFromWrappers( component, listOfSelectedPartWrappers );
						setTimeout( function() {
							helper.showSubmittedIssuesModal( component, helper, listOfSubmittedIssues );
						}, 5000 );
					}
					else if( behaviorCode == 3 ) {
						helper.cancel( component, helper );
					}
                }
                else {
                    component.set( "v.showSpinner", false );
					helper.showToastMessage( 'error', $A.get( "$Label.c.Error" ), result.message );
                }
            }
            else {
				component.set( "v.showSpinner", false );
                helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get( "$Label.c.Something_Went_Wrong_Please_Contact_Admin" ) );
            }
        });
        
        $A.enqueueAction( serverAction );
    },
	
	openBoxModal : function( component, helper, recordIssue ) {
		
		if( recordIssue ) {
			
			$A.createComponent( 'c:IssueBoxFolder', {
				'headerText' : 'Box Folder - ' + recordIssue.Name,
				'IssueID' : recordIssue.Id
            },
            function( modalComponent, status, errorMessage ) {
                
				if( status === "SUCCESS" ) {
					
					var showChildModalDiv = component.find( 'showBoxModal' );
					if( showChildModalDiv ) {
						var body = showChildModalDiv.get( "v.body" );
						body.push( modalComponent );
						component.find( 'showBoxModal' ).set( "v.body", body );
					}
                } 
				else if ( status === "INCOMPLETE" ) {
                	helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get("$Label.c.Internal_Issue_Or_Client_Offline") );
                } 
				else if ( status === "ERROR" ) {
                	helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get("$Label.c.Something_Went_Wrong_Try_Again") );
                }
            });
		}
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
				helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get("$Label.c.Internal_Issue_Or_Client_Offline") );
			} 
			else if ( status === "ERROR" ) {
				helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get("$Label.c.Something_Went_Wrong_Try_Again") );
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
				helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get("$Label.c.Internal_Issue_Or_Client_Offline") );
			} 
			else if ( status === "ERROR" ) {
				helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get("$Label.c.Something_Went_Wrong_Try_Again") );
			}
		});
	},
	
	showSubmittedIssuesModal : function( component, helper, listOfIssues ) {
		
		if( !listOfIssues || listOfIssues.length == 0 ) {
			return listOfIssues;
		}
		
		$A.createComponent( 'c:ApprovalIssuesCmp', {
			'listOfSubmittedIssues' : listOfIssues,
			'refreshIssuesReportedTableEvt' : component.getReference( "c.refreshIssuesTable" ),
            'isConsoleNavigation' : component.get( "v.isConsoleNavigation" )
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
				helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get("$Label.c.Internal_Issue_Or_Client_Offline") );
			} 
			else if ( status === "ERROR" ) {
				helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get("$Label.c.Something_Went_Wrong_Try_Again") );
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
				helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get("$Label.c.Internal_Issue_Or_Client_Offline") );
			} 
			else if ( status === "ERROR" ) {
				helper.showToastMessage( 'error', $A.get("$Label.c.Error"), $A.get("$Label.c.Something_Went_Wrong_Try_Again") );
			}
		});
	},
	
	showToastMessage : function( type, title, message ) {
        
        if( type && message ) {
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
    statusChanged:function(cmp,event,helper,listname){
       
        var issuLst = listname; 
        console.log('issuLstissuLst'+JSON.stringify(issuLst));
        var curIssueRec = issuLst[event.getSource().get('v.label')];
         var action = cmp.get("c.getIssueInfo");
        action.setParams({
            issId : curIssueRec.recordIssue.Id
        });
        action.setCallback(this, function(response){
            var state = response.getState();
            console.log('---state--'+state);
            if (state === "SUCCESS") {
                
               var oldissueRec = response.getReturnValue();
               var currentStatus = event.getSource().get('v.value');
               	var oldStatus =oldissueRec.Issue_Status__c;
              
        var changedIssue = curIssueRec;
             if(oldStatus=='Open' && currentStatus=='Resolved' && ( changedIssue.Product_Replacement__c == true)){
            
            helper.showToastMessage( 'error', 'Warning!', 'Status cant be changed from '+oldStatus+' to '+ currentStatus);
            event.getSource().set('v.value',oldStatus);
        }
                if(currentStatus=='Resolved' && ( changedIssue.Product_Return__c == true) && (changedIssue.Reverse_Shipment_Info__c==undefined || changedIssue.RMA_FA_Status__c=='Select' ||changedIssue.RMA_FA_Status__c=='')){//&& changedIssue.Product_Replacement__c == true
            
            	helper.showToastMessage( 'error', 'Warning!', 'Can Not Change Issue status to resolve please fill   RMA / FA Status && Reverse Shipment Info Before change status');
				event.getSource().set('v.value',oldStatus);
        }
        
        if(oldStatus=='Open' && (currentStatus=='Order Shipped' ||currentStatus==''||currentStatus =='Replacement Rejected')){
            
            helper.showToastMessage( 'error', 'Warning!', 'Status cant be changed from '+oldStatus+' to '+ 'Order Shipped');
            event.getSource().set('v.value',oldStatus);
        }
        
        if(oldStatus=='Order Shipped' && (currentStatus=='Open' || currentStatus=='Canceled' ||currentStatus=='' ||currentStatus =='Replacement Rejected')){
            
            helper.showToastMessage( 'error', 'Warning!', 'Status cant be changed from '+'Order Shipped'+' to '+ currentStatus);
            event.getSource().set('v.value',oldStatus);
        }
          if(oldStatus=='Replacement Rejected' && (currentStatus=='Resolved' || currentStatus=='Order Shipped' ||currentStatus=='')){
            helper.showToastMessage( 'error', 'Warning!', 'Status cant be changed from '+oldStatus+' to '+ currentStatus);
            event.getSource().set('v.value',oldStatus);
        }
            }
        });
        $A.enqueueAction(action); 
       
    }
})