({
    doInit : function( component, event, helper ) {
        
        //helper.doInit( component );
        var issueResult = component.get("v.newIssues");
        var wrapData = component.get("v.issueWrapperdata");
        helper.setConsoleTabSettings(component, event,helper);
        
    },
    doSelectAll: function (component, event, helper) {
        var issuesAre = component.get("v.newIssues");
        console.log(
            "component.find('selectAll').get('v.checked') ",
            component.find("selectAll").get("v.checked")
        );
        
        //   var issaveEnabled = false;
        var wrap = component.get("v.issueWrapperdata");
        var issuesAre = wrap.issuesLst;
        issuesAre.forEach(function (each) {
            each.selected = component.find("selectAll").get("v.checked");
        });
        wrap.issuesLst = issuesAre;
        component.set("v.issueWrapperdata",wrap);
        component.set("v.saveIssues", component.find("selectAll").get("v.checked"));
        //component.set("v.newIssues", issuesAre);
    },
    dosavecheck: function (component, event, helper) {
        
        var wrap = component.get("v.issueWrapperdata");
        var issuesAre = wrap.issuesLst;
        var issaveEnabled = false;
        issuesAre.forEach(function (each) {
            if (each.selected) issaveEnabled = true;
        });
        component.set("v.saveIssues", issaveEnabled);
    },
    dosaveCancel: function (component, event, helper) {
        /* var issuesAre = component.get("v.newIssues");
        var issaveEnabled = false;
        issuesAre.forEach(function (each) {
            each.selected = false;
        });
        component.set("v.saveIssues", false);
        component.set("v.newIssues", issuesAre);*/
        var wrap = component.get("v.issueWrapperdata");
        var issuesAre = wrap.issuesLst;
        var issaveEnabled = false;
        issuesAre.forEach(function (each) {
            each.selected = false;
        });
        wrap.issuesLst = issuesAre;
        component.set("v.issueWrapperdata", wrap);
        component.set("v.saveIssues", false);
        component.find("selectAll").set("v.checked",false);
    },
    handleSubitandcontinue : function(component, event, helper) {
        //var input = component.find("focusFooter"); 
        //input.focus();
        helper.handleSubitandcontinue(component, event,1);
        
    },
    handleSubitandfinish : function(component, event, helper) {
        //var input = component.find("focusFooter"); 
        //input.focus();
        helper.handleSubitandcontinue(component, event,2);
    },
    
    handleSave : function(component, event, helper) {
        
        helper.updateIssue(component, event,helper);
      //  var action =component.get("c.dosaveCancel");
      //  $A.enqueueAction(action);
        
        //document.location.href = 'focusFooter';
        // component.find("focusFooter").getElement().focus();
        //var input = component.find("focusFooter"); 
        //input.focus();
    },
    openBoxModalFromIgu : function( component, event, helper ) {
        
        var index = event.target.id;
        var issuelist=JSON.parse( JSON.stringify( component.get( "v.newIssues" ) ) );
        var currentissue=issuelist[index];
        $A.createComponent( 'c:IssueBoxFolder', {
            'headerText' : 'Box Folder - ' + currentissue.Name,
            'IssueID' : currentissue.Id
        },
                           function( modalComponent, status, errorMessage ) {
                               
                               if( status === "SUCCESS" ) {
                                   
                                   var showChildModalDiv = component.find( 'showChildModal' );
                                   if( showChildModalDiv ) {
                                       var body = showChildModalDiv.get( "v.body" );
                                       body.push( modalComponent );
                                       component.find( 'showChildModal' ).set( "v.body", body );
                                   }
                               }
                               else if ( status === "INCOMPLETE" ) {
                                   helper.showToastMessage( 'error', 'Error!', 'Internal Server issue or client is offline.' );
                               }
                                   else if ( status === "ERROR" ) {
                                       helper.showToastMessage( 'error', 'Error!', 'Something went wrong. Please try again.' );
                                   }
                           });
        
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
    
    openRecordInNewConsoleTab : function( component, event, helper ) {
        if( event && event.target && event.target.id ) {
            helper.openRecordInNewConsoleTab( component, helper, event.target.id );
        }
    },
    
    openFailureModeMultiSelectModal : function( component, event, helper ) {
        var recordIndex = event.target.id;
        var listName = event.target.dataset.title;
        var wrapData = component.get("v.issueWrapperdata");
        var selectedFailureModes = wrapData.issuesLst[recordIndex].selectedFailures;
        var resonofrep = wrapData.issuesLst[recordIndex].issueRec.Reason_for_Replacement__c;
       // var failuremode = 
       
        helper.openFailureModeMultiSelectModal( component, helper, recordIndex, 'IGU',
                                               listName, selectedFailureModes,resonofrep
                                              );
    },
    handleFailureModeMultiSelectEvt : function( component, event, helper ) {
        var recordIndex = event.getParam( "recordIndex" );
        if( recordIndex < 0 ) {
            return;
        }
        var listOfFailureModesSelected = event.getParam( "listOfFailureModesSelected" );
        console.log( 'handleFailureModeMultiSelectEvt-listOfFailureModesSelected====178==='+listOfFailureModesSelected );
        if( !listOfFailureModesSelected ) {
            return;
        }
        var wrapData = component.get("v.issueWrapperdata");
        var selectedFailureModes = wrapData.issuesLst[recordIndex].selectedFailures;
        selectedFailureModes = listOfFailureModesSelected;
        /*for(var r in listOfFailureModesSelected){
            if(!selectedFailureModes.includes(listOfFailureModesSelected[r])){
                selectedFailureModes.push(listOfFailureModesSelected[r]);
            }
        }*/
        wrapData.issuesLst[recordIndex].selectedFailures = selectedFailureModes;
        var namesOfSelectedFM = event.getParam( "NameOfFailureModesSelected" );
        wrapData.issuesLst[recordIndex].selectedFailuresNames = namesOfSelectedFM;
        wrapData.issuesLst[recordIndex].provideFMDetails = false;
        //var nameOfFM = wrapData.issuesLst[recordIndex].selectedFailuresNames;
        /*for(var r in namesOfSelectedFM){
            if(!nameOfFM.includes(namesOfSelectedFM[r])){
                nameOfFM.push(namesOfSelectedFM[r]);
            }
            
        }*/
        component.set("v.NameOfFailureModesSelected",namesOfSelectedFM);
        //wrapper.listOfSelectedFailureModes = listOfFailureModesSelected;
        console.log('===186===='+JSON.stringify(wrapData));
        component.set("v.issueWrapperdata",wrapData);
    },
    openScratchModal: function(component, event, helper){
       
        var recordIndex = event.target.id;
            var wrapData = component.get("v.issueWrapperdata");
            var selectedIssue = wrapData.issuesLst[recordIndex].issueRec;
            var sNames = wrapData.issuesLst[recordIndex].selectedFailuresNames;
           if((sNames.includes("OOS Scratches - S1/S4")) || (sNames.includes("Non-Tinting - Intermittent Tinting")) 
           || (sNames.includes("OOS Scratches - S3 / Other")) || (sNames.includes("Obstruction in Field of View - Spontaneous Breakage"))
           || (sNames.includes("Non-Tinting")) || (sNames.includes("Non-Uniformity - Within Lite")) 
           || (sNames.includes("Non-Uniformity - L2L")) ){
             
            $A.createComponent('c:ScratchFailureMode', {
                'issueWrapperdata': component.get("v.issueWrapperdata"),
                'selectedIssue': selectedIssue,
                'NameOfFailureModesSelected': sNames,
                'componentName': component.get("v.componentName")
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
            console.log("===208==="+JSON.stringify(wrapData.issuesLst[recordIndex].issueRec));
        }
    },
    handleFailureModePDEvt: function(component, event, helper){
        var sRec = event.getParam("selectedIssue");
        var wrapData = component.get("v.issueWrapperdata");
        var wrapIss = wrapData.issuesLst;
        for(var r in wrapIss){
            if(wrapIss[r].issueRec.Id === sRec.Id){
                wrapIss[r].issueRec = sRec; 
                 wrapIss[r].provideFMDetails = true;
            }
        }
        wrapData.issuesLst = wrapIss;
        //component.set("v.providedDetails",event.getParam("ValuesProvided"));
        component.set("v.issueWrapperdata",wrapData);
    },
    handleMakeUpSel: function(component, event, helper) {
    	helper.setIGUMakeUpFlags(component, event);
    },
    openAssetLookupModal : function( component, event, helper ) {
        var keyCode = event.which;
        console.log( 'openAssetLookupModal-key', keyCode );
        if( keyCode == 13 ) {
           	component.set("v.selectedAssestId",event.target.name);
            var searchKeyword = event.target.value;
            console.log( 'openAssetLookupModal-searchKeyword', searchKeyword );
            
          /*if( !logIssueCommonWrapper || !logIssueCommonWrapper.recordCase.Opportunity__c ) {
                helper.showToastMessage( 'error', 'Opportunity missing', 'This Case does not have an Opportunity.' );
                return;
            }
            if( !logIssueCommonWrapper || !logIssueCommonWrapper.common_Lite_Mockid ) {
                helper.showToastMessage( 'error', 'IGU ID Provided missing', 'Please select IGU ID Provided.' );
                return;
            }*/
            var oppId = component.get("v.opportunityId");
            helper.openAssetLookupModal( component, helper, 'Lite ID Selection', 1, searchKeyword,
                                        oppId, 'listOfIGUIssueWrappers',
                                        'common_Liteid'
                                       );
        }
    },
     handleAssetSelectEvtIGU : function( component, event, helper ) {
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
    
    Markidvalue : function( component, event, helper ) {
        
        
    },
    openProductLookupModal : function( component, event, helper ) {
        var keyCode = event.which;
        console.log( 'openProductLookup-key', keyCode );
        if(keyCode == 8)
        {
            return false;
        }
        if( keyCode == 13 ) {
            
            var recordIndex = event.target.id;
            console.log( 'openProductLookup-recordIndex', recordIndex );
            
            var searchKeyword = event.target.value;
            console.log( 'openProductLookup-searchKeyword', searchKeyword );
            
            console.log('calling helper');
            //if(logIssueCommonWrapper.selectedIssueType =="IGU"){
                helper.openProductLookupModal( component, helper, 'New Makeup Selection', recordIndex, searchKeyword,
                                              'IGU', 'listOfLogIssueWrappers', 'Product',
                                              component.get("v.priceBookId"),
                                              component.get("v.currencyISOcode")
                                             );
           
        }
    },
     disableBackspace : function(component, event, helper) {
        if(event.keyCode == 8 || event.keyCode === 46){
            event.preventDefault();
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
    showAlertMsg : function(component, event, helper) {
        var indexVal = event.getSource().get('v.label');
        var wrapData = component.get("v.issueWrapperdata");
        var issLst = wrapData.issuesLst;
        console.log('issLst298'+JSON.stringify(issLst[indexVal]));
        if(issLst[indexVal].issueRec.Want_to_Order_Existing_Makeup__c=='No')
        {
       
        issLst[indexVal].newMakeUpname = '';
        }
        if(issLst[indexVal].issueRec.Want_to_Order_Existing_Makeup__c=='Yes')
        {
        issLst[indexVal].Product__c = issLst[indexVal].issueRec.Product2Id;
        }
        wrapData.issuesLst = issLst;
        component.set("v.issueWrapperdata",wrapData);
        helper.showToastMessage('warning', 'warning', 'Are you sure you want to change');
    },
    onContinue: function(component, event, helper) {
       component.set("v.isOpenSubmitMessage", false);
       if(component.get("v.closeAndOpenCase")){
           helper.cancel(component, helper);
       }
   },
    openRecordInNewConsoleTab : function( component, event, helper ) {
        
        if( event && event.target && event.target.id ) {
            helper.openRecordInNewConsoleTab( component, helper, event.target.id );
        }
    },
    handleClick : function(component, event, helper) {
        
        component.set("v.isModalOpen",true);
        component.set("v.isQuotetoCon",true);
        component.set("v.isShiptoCon",false);
        component.set("v.isShippinginfo",false);
    },
    handleshiptoCon : function(component, event, helper) {
        
        component.set("v.isModalOpen",true);
        component.set("v.isShiptoCon",true);
        component.set("v.isQuotetoCon",false);
        
        component.set("v.isShippinginfo",false);
    },
    handleshippinginfo : function(component, event, helper) {
        
        component.set("v.isModalOpen",true);
        component.set("v.isShippinginfo",true);
        component.set("v.isShiptoCon",false);
        component.set("v.isQuotetoCon",false);
    },
    closeModel: function(component, event, helper) {
        // Set isModalOpen attribute to false  
        
        var logIssueCommonWrapper = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" ) ) );
        var logIssueCommonWrapperDupe = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapperDupe" ) ) );
        
        var isQuotetoCon=component.get("v.isQuotetoCon");
        var isShiptoCon=component.get("v.isShiptoCon");
        if(isQuotetoCon){
            
            if(logIssueCommonWrapperDupe.recordCase.ContactId){
                logIssueCommonWrapper.quoteToContactname=logIssueCommonWrapperDupe.recordCase.Contact.Name;
                logIssueCommonWrapper.quoteToContactid=logIssueCommonWrapperDupe.recordCase.ContactId;
                logIssueCommonWrapper.quoteToContactPhone=logIssueCommonWrapperDupe.recordCase.Contact.Phone;
                logIssueCommonWrapper.quoteToContactEmail=logIssueCommonWrapperDupe.recordCase.Contact.Email;
                component.set("v.logIssueCommonWrapper",logIssueCommonWrapper);
            }
            
        }
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        
        console.log('isShiptoCon--',isShiptoCon);
        if(isShiptoCon){
            
            if(logIssueCommonWrapperDupe.recordCase.ContactId ){
                logIssueCommonWrapper.shipToContactname=logIssueCommonWrapperDupe.recordCase.Contact.Name;
                logIssueCommonWrapper.shipToContactid=logIssueCommonWrapperDupe.recordCase.ContactId;
                logIssueCommonWrapper.shipToContactPhone=logIssueCommonWrapperDupe.recordCase.Contact.Phone;
                logIssueCommonWrapper.shipToContactEmail=logIssueCommonWrapperDupe.recordCase.Contact.Email;
                component.set("v.logIssueCommonWrapper",logIssueCommonWrapper);
            }
            
        }
        component.set("v.isModalOpen", false);
        component.set("v.isQuotetoCon",false);
        component.set("v.isShiptoCon",false);
    },
    submitDetails: function(component, event, helper) {
        
        var areHeaderFieldsValid = helper.validateHeaderFields( component );
        console.log('areHeaderFieldsValid---',areHeaderFieldsValid);
        if(areHeaderFieldsValid){
            component.set("v.isModalOpen", false);
        }
        
    },
    openAddressSearchModalForCommonIssue : function( component, event, helper ) {
        
        var logIssueCommonWrapper = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" ) ) );
        helper.openAddressSearchModal( component, helper, null, null, 'logIssueCommonWrapper', logIssueCommonWrapper );
    },
     clearShipToContactSearchedKeyword : function( component, event, helper ) {
        
        helper.clearShipToContactSearchedKeyword( component);
    },
     clearQuoteToContactSearchedKeyword : function( component, event, helper ) {
        
        helper.clearQuoteToContactSearchedKeyword( component);
    },
     searchcontacts : function( component, event, helper ) {
        var contactid;
        var searchKeyword = event.target.value;
        console.log( 'searchKeyword===>', searchKeyword );
        var isQuotetoCon=component.get("v.isQuotetoCon");
        var isShiptoCon=component.get("v.isShiptoCon");
        var logIssueCommonWrapper=JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" ) ) );
        var consOpenDropDown = JSON.parse( JSON.stringify( component.get( "v.consOpenDropDown" ) ) );
        console.log( 'consOpenDropDown', consOpenDropDown );
        console.log( 'case id', logIssueCommonWrapper.recordCase.Id );
        var stroppid=logIssueCommonWrapper.recordCase.Opportunity__c;
        if(isQuotetoCon){
            contactid=logIssueCommonWrapper.quoteToContactid;
        }else if(isShiptoCon){
            contactid=logIssueCommonWrapper.shipToContactid;
        }
        
        console.log( 'strcaseid', stroppid );
        if( searchKeyword && searchKeyword.length > 2 ) {
            component.set( "v.spinner", true );
            helper.searchcontacts( component, searchKeyword,stroppid,contactid );
        }
        else if( consOpenDropDown ) {
            component.set( "v.consOpenDropDown", false );
        }
    },
     handleQContOptionClick: function( component, event, helper ) {
        
        if( event.target && event.target.closest('li') && event.target.closest('li').dataset && 
           event.target.closest('li').dataset.id && event.target.closest('li').dataset.value
          ) {
            var selectedcontactId = event.target.closest('li').dataset.id;
            console.log( 'selectedcontactId', selectedcontactId );
            
            var selectedcontactname = event.target.closest('li').dataset.value;
            console.log( 'selectedcontactname', selectedcontactname );
            
            var selectedcontactphone = event.target.closest('li').dataset.phone;
            console.log( 'selectedcontactphone', selectedcontactphone );
            
            var selectedcontactemail = event.target.closest('li').dataset.email;
            console.log( 'selectedcontactemail', selectedcontactemail );
            
            
            helper.handleQContOptionClick( component, selectedcontactId, selectedcontactname,
                                          selectedcontactphone, selectedcontactemail
                                         );
            
        }
    },
     handleShipContOptionClick: function( component, event, helper ) {
        
        if( event.target && event.target.closest('li') && event.target.closest('li').dataset && 
           event.target.closest('li').dataset.id && event.target.closest('li').dataset.value
          ) {
            var selectedcontactId = event.target.closest('li').dataset.id;
            console.log( 'selectedcontactId', selectedcontactId );
            
            var selectedcontactname = event.target.closest('li').dataset.value;
            console.log( 'selectedcontactname', selectedcontactname );
            
            var selectedcontactphone = event.target.closest('li').dataset.phone;
            console.log( 'selectedcontactphone', selectedcontactphone );
            
            var selectedcontactemail = event.target.closest('li').dataset.email;
            console.log( 'selectedcontactemail', selectedcontactemail );
            
            
            helper.handleShipContOptionClick( component, selectedcontactId, selectedcontactname,
                                             selectedcontactphone, selectedcontactemail
                                            );
            
        }
    },
     handleGoogleAddressSearchModalEvt : function( component, event, helper ) {
        
        var recordIssue = JSON.parse( JSON.stringify( event.getParam( "recordIssue" ) ) );
        console.log( 'handleGoogleAddressSearchModalEvt-recordIssue', recordIssue );
        if( !recordIssue ) {
            return;
        }
        
        
        var objectName = event.getParam( "objectName" );
        console.log( 'handleGoogleAddressSearchModalEvt-objectName', objectName );
        if( !objectName ) {
            return;
        }
        
        var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v." + objectName ) ) );
        
        recordCommonIssue.Shipping_Street_1 = recordIssue.Shipping_Street_1;
        recordCommonIssue.Shipping_Street_2 = recordIssue.Shipping_Street_2;
        recordCommonIssue.Shipping_City = recordIssue.Shipping_City;
        recordCommonIssue.Shipping_State_Province = recordIssue.Shipping_State_Province;
        recordCommonIssue.Shipping_Country = recordIssue.Shipping_Country;
        recordCommonIssue.Shipping_Postal_Code = recordIssue.Shipping_Postal_Code;
        
        component.set( "v." + objectName, recordCommonIssue );
        
    },
     cancel1: function (component, helper,event) {
         var issueWrapperdata = component.get("v.issueWrapperdata"); 
         console.log(issueWrapperdata);
      
     }
})