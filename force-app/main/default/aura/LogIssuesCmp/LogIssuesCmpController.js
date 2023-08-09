({
    doInit : function( component, event, helper ) {
        helper.doInit( component );
        helper.getCSSRecTypes(component, event);
        helper.setAssetToIssueShape( component );
        helper.fetchopenissuesdoinitIGU(component, event,helper);
        helper.fetchopenissuesdoinitCHW(component, event,helper);
        helper.setConsoleTabSettings(component, event,helper);
        
    },
    clearProductSearchedKeyword : function( component, event, helper ) {
        
        var index = event.target.id;
        console.log( 'index', index );
        helper.clearProductSearchedKeyword( component,index);
    },
    clearProductSearchedKeywordcss : function( component, event, helper ) {
        
        var index = event.target.id;
        console.log( 'index', index );
        helper.clearProductSearchedKeywordcss( component,index);
    },
    handleissueTypeChangeHandler : function( component, event, helper ) {    
        var logIssueCommonWrapper = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" ) ) );
        var listOfLogIssueWrappers = JSON.parse(  JSON.stringify(component.get( "v.listOfLogIssueWrappers" )) );
        console.log( 'logIssueCommonWrapper', logIssueCommonWrapper );
        console.log( '$$$$$$$$$listOfLogIssueWrappers  : ', listOfLogIssueWrappers );
        console.log( '$$$$$$$$$newIssues : ', JSON.stringify(component.get("v.newIssues") ) );
        console.log( '$$$$$$$$$newIssuesWithStatus : ', JSON.stringify(component.get("v.newIssuesWithStatus") ) );
        
        /*var tab = event.getSource();
        component.set("v.logIssueCommonWrapper.selectedIssueType", tab.get('v.id'));*/
        
        
        if( !logIssueCommonWrapper ) {
            return;
        }
        var successMsgEle = component.find('successMsg_submit');
        var errorMsgEle = component.find('errorMsg_submit');
        $A.util.removeClass(successMsgEle, "slds-show");
        $A.util.addClass(successMsgEle, "slds-hide");
        $A.util.removeClass(errorMsgEle, "slds-show");
        $A.util.addClass(errorMsgEle, "slds-hide"); 
        component.set("v.submitErrorMessage", "");
        component.set( "v.listOfResponsibleEntities", logIssueCommonWrapper.listOfownershippicklist );
        if( logIssueCommonWrapper.selectedIssueType == 'IGU' ) {
            component.set( "v.listOfReasonForReplacements", logIssueCommonWrapper.listOfIGUReplacements );
            
        }
        else if( logIssueCommonWrapper.selectedIssueType == 'Control Hardware' ) {
            helper.getCSSRecTypes(component, event);
            component.set( "v.listOfReasonForReplacements", logIssueCommonWrapper.listOfCSSReplacements );
        }
    },
    handleissueTypeTabChangeHandler : function (component, event, helper) {
        var logIssueCommonWrapper = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" ) ) );
        var listOfLogIssueWrappers = JSON.parse(  JSON.stringify(component.get( "v.listOfLogIssueWrappers" )) );
        console.log( 'logIssueCommonWrapper', logIssueCommonWrapper );
        console.log( 'listOfLogIssueWrappers', listOfLogIssueWrappers );
        
        var tab = event.getSource();
        var selectedTabIssueType = tab.get('v.id');
        
        
        if( !logIssueCommonWrapper ) {
            return;
        }
        var successMsgEle = component.find('successMsg_submit');
        var errorMsgEle = component.find('errorMsg_submit');
        $A.util.removeClass(successMsgEle, "slds-show");
        $A.util.addClass(successMsgEle, "slds-hide");
        $A.util.removeClass(errorMsgEle, "slds-show");
        $A.util.addClass(errorMsgEle, "slds-hide"); 
        component.set("v.submitErrorMessage", "");
        component.set( "v.listOfResponsibleEntities", logIssueCommonWrapper.listOfownershippicklist );
        if( selectedTabIssueType == 'IGU' ) {
            component.set( "v.listOfReasonForReplacements", logIssueCommonWrapper.listOfIGUReplacements );
            
        }
        else if( selectedTabIssueType == 'Control Hardware' ) {
            helper.getCSSRecTypes(component, event);
            component.set( "v.listOfReasonForReplacements", logIssueCommonWrapper.listOfCSSReplacements );
        }
    },
    handleSubitandcontinue : function(component, event, helper) {
        var input = component.find("focusFooter"); 
        input.focus();
        helper.handleSubitandcontinue(component, event,1);
        
    },
    handleSubitandfinish : function(component, event, helper) {
        var input = component.find("focusFooter"); 
        input.focus();
        helper.handleSubitandcontinue(component, event,2);
    },
    handleSubitandcontinuecss : function(component, event, helper) {
        var input = component.find("focusFooter"); 
        input.focus();
        helper.handleSubitandcontinuecss(component, event,1);
        
    },
    handleSubitandfinishcss : function(component, event, helper) {
        var input = component.find("focusFooter"); 
        input.focus();
        helper.handleSubitandcontinuecss(component, event,2);
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
    handleMakeUpSel: function(component, event, helper) {
        helper.setIGUMakeUpFlags(component, event);
    },
    handleSave : function(component, event, helper) {
        helper.insertIssue(component, event,helper);
        //document.location.href = 'focusFooter';
        // component.find("focusFooter").getElement().focus();
        var input = component.find("focusFooter"); 
        input.focus();
    },
    handleSavecss : function(component, event, helper) {
        helper.insertcssIssue(component, event,helper);
        var input = component.find("focusFooter"); 
        input.focus();
    },
    handleCancel : function(component, event, helper) {
        //window.open('/lightning/r/Case/'+component.get("v.recordId")+'/view','_self');
        helper.cancel( component, helper );
    },
    submitDetails: function(component, event, helper) {
        
        var areHeaderFieldsValid = helper.validateHeaderFields( component );
        console.log('areHeaderFieldsValid---',areHeaderFieldsValid);
        if(areHeaderFieldsValid){
            component.set("v.isModalOpen", false);
        }
        
    },
    AddNewRow : function(component, event, helper){
        helper.validateproducts(component,helper);
    },
    AddNewRowCSS : function(component, event, helper){
        var logIssueCommonWrapper = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" ) ) );
        
        var listOfLogIssueWrappersCSS = JSON.parse( JSON.stringify( component.get( "v.listOfLogIssueWrappersCSS" ) ) );
        
        //*
        var arr = [];
        var obj = {};
        obj["Lite_Mockid"] = "";
        
        obj["Liteid"] = "";
        
        obj["Mockid"] = "";
        
        obj["markID"] = "";
        obj["prodQty"] = null;
        obj["cssProdListPrice"] = "";
        obj["reason_replacement"] = logIssueCommonWrapper.common_reason_replacement;
        obj["sel_Resp_Entity"] = logIssueCommonWrapper.common_sel_Resp_Entity;
        obj["requestedDate"]=logIssueCommonWrapper.requestDate;
        obj["recordTypeId"] = "";
        obj["failureComponent"] = "";
        obj["existingMakeUpID"] = "";
        obj["existingMakeUpDesc"] = "";
        obj["OrderExtMakeup"] = "";
        obj["height"] = "";
        obj["base"] = "";
        obj["shape"] = "";
        obj["newMakeUpID"]="";
        obj["newMakeUpname"]="";
        obj["productnamecss"] = "";
        obj["failureComponentOpts"]=arr;
        obj["showliteid"] =false;
        obj["Create_box_Folder"] =false;
        obj["listOfSelectedFailureModes"]=arr;
        obj["Lite_Damaged"] ="";
        obj["Replaced_SWC"] ="";
        obj["Replaced_WC"] ="";
        obj["Visible_BB_Damage"] ="";
        obj["Replaced_IGU_Cable"] ="";
        obj["Reflection_Color_Observed"] ="";
        obj["Reflection_Color_Degree"] ="";
        obj["rmaIs"] =false;
        //*/
        listOfLogIssueWrappersCSS.push(obj);
        console.log('list', listOfLogIssueWrappersCSS);
        component.set( "v.totalIssuescss", listOfLogIssueWrappersCSS.length );
        component.set( "v.listOfLogIssueWrappersCSS", listOfLogIssueWrappersCSS );
    },
    removeRow : function(component, event, helper){
        var index=event.target.id;
        console.log(index);
        var AllRowsList = component.get("v.listOfLogIssueWrappers");
        AllRowsList.splice(index, 1);
        component.set( "v.totalIssues", AllRowsList.length );
        component.set("v.listOfLogIssueWrappers", AllRowsList);
    }, 
    removeRowcss : function(component, event, helper){
        var index=event.target.id;
        console.log(index);
        var AllRowsList = component.get("v.listOfLogIssueWrappersCSS");
        AllRowsList.splice(index, 1);
        component.set( "v.totalIssuescss", AllRowsList.length );
        component.set("v.listOfLogIssueWrappersCSS", AllRowsList);
    },
    handleCSSRecTypeChange : function(component, event, helper) {
        var index = event.getSource().get("v.label");
        var indexval = event.getSource().get("v.Value");
        console.log('Controller Invoked '+index+'-'+indexval);
        helper.getFailureComps(component, event,index);
    },
    clearAssetSearchedKeyword : function( component, event, helper ) {
        
        //var index = event.target.id;
        // console.log( 'index', index );
        helper.clearAssetSearchedKeyword( component);
    },
    searchProducts : function( component, event, helper ) {
        
        var searchKeyword = event.target.value;
        console.log( 'searchKeyword', searchKeyword );
        
        var prodopenDropDown = JSON.parse( JSON.stringify( component.get( "v.prodopenDropDown" ) ) );
        console.log( 'prodopenDropDown', prodopenDropDown );
        
        if( searchKeyword && searchKeyword.length > 2 ) {
            var currentRowIndex = event.target.id;
            console.log( 'currentRowIndex', currentRowIndex );
            component.set( "v.currentRowIndex", currentRowIndex );
            
            var currentRowId = event.target.dataset.row;
            console.log( 'currentRowId', currentRowId );
            component.set( "v.currentRowId", currentRowId );
            
            helper.searchProducts( component, searchKeyword );
        }
        else if( prodopenDropDown ) {
            component.set( "v.prodopenDropDown", false );
        }
    },
    searchProductscss : function( component, event, helper ) {
        
        var searchKeyword = event.target.value;
        console.log( 'searchKeyword', searchKeyword );
        
        var prodopenDropDown = JSON.parse( JSON.stringify( component.get( "v.prodopenDropDown" ) ) );
        console.log( 'prodopenDropDown', prodopenDropDown );
        
        if( searchKeyword && searchKeyword.length > 2 ) {
            var currentRowIndex = event.target.id;
            console.log( 'currentRowIndex', currentRowIndex );
            component.set( "v.currentRowIndex", currentRowIndex );
            
            var currentRowId = event.target.dataset.row;
            console.log( 'currentRowId', currentRowId );
            component.set( "v.currentRowId", currentRowId );
            
            helper.searchProductscss( component, searchKeyword );
        }
        else if( prodopenDropDown ) {
            component.set( "v.prodopenDropDown", false );
        }
    },
    
    
    handleProductOptionClick : function( component, event, helper ) {
        
        var currentRowIndex = component.get( "v.currentRowIndex" );
        console.log( 'currentRowIndex', currentRowIndex );
        
        if( event.target && event.target.closest('li') && event.target.closest('li').dataset && 
           event.target.closest('li').dataset.id && event.target.closest('li').dataset.value
          ) {
            var selectedId = event.target.closest('li').dataset.id;
            console.log( 'selectedId', selectedId );
            
            var selectedValue = event.target.closest('li').dataset.value;
            console.log( 'selectedValue', selectedValue );
            
            var selectedListPrice = event.target.closest('li').dataset.price;
            console.log( 'selectedListPrice', selectedListPrice );
            
            helper.handleProductOptionClick( component, currentRowIndex, selectedId, selectedValue, selectedListPrice );
        }
    },
    handleProductOptionClickcss : function( component, event, helper ) {
        
        var currentRowIndex = component.get( "v.currentRowIndex" );
        console.log( 'currentRowIndex', currentRowIndex );
        
        if( event.target && event.target.closest('li') && event.target.closest('li').dataset && 
           event.target.closest('li').dataset.id && event.target.closest('li').dataset.value
          ) {
            var selectedId = event.target.closest('li').dataset.id;
            console.log( 'selectedId', selectedId );
            
            var selectedValue = event.target.closest('li').dataset.value;
            console.log( 'selectedValue', selectedValue );
            
            var selectedListPrice = event.target.closest('li').dataset.price;
            console.log( 'selectedListPrice', selectedListPrice );
            
            helper.handleProductOptionClickcss( component, currentRowIndex, selectedId, selectedValue, selectedListPrice );
        }
    },
    
    
    
    
    clearQuoteToContactSearchedKeyword : function( component, event, helper ) {
        
        //var index = event.target.id;
        // console.log( 'index', index );
        helper.clearQuoteToContactSearchedKeyword( component);
    },
    clearShipToContactSearchedKeyword : function( component, event, helper ) {
        
        //var index = event.target.id;
        // console.log( 'index', index );
        helper.clearShipToContactSearchedKeyword( component);
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
    searchAssets : function( component, event, helper ) {
        
        var searchKeyword = event.target.value;
        console.log( 'searchKeyword', searchKeyword );
        
        var assetOpenDropDown = JSON.parse( JSON.stringify( component.get( "v.assetOpenDropDown" ) ) );
        console.log( 'assetOpenDropDown', assetOpenDropDown );
        
        if( searchKeyword && searchKeyword.length > 2 ) {
            
            var currentLiteRowIndex = event.target.id;
            console.log( 'currentLiteRowIndex', currentLiteRowIndex );
            component.set( "v.currentLiteRowIndex", currentLiteRowIndex );
            
            var logIssueCommonWrapper = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" ) ) );
            console.log( 'before-searchAssets-logIssueCommonWrapper', logIssueCommonWrapper );
            var opportunityid=logIssueCommonWrapper.recordCase.Opportunity__c;
            if( logIssueCommonWrapper ) {
                var pmIssueWrapper = logIssueCommonWrapper;
                console.log( 'pmIssueWrapper', pmIssueWrapper );
                
                if( pmIssueWrapper  && (pmIssueWrapper.common_Lite_Mockid == 'Lite ID' || pmIssueWrapper.common_Lite_Mockid == 'Mock ID') ) {
                    
                    //var currentLiteRowId = event.target.dataset.row;
                    //console.log( 'currentLiteRowId', currentLiteRowId );
                    //component.set( "v.currentLiteRowId", currentLiteRowId );
                    
                    helper.searchAssets( component, searchKeyword,opportunityid );
                }
            }
        }
        else if( assetOpenDropDown ) {
            component.set( "v.assetOpenDropDown", false );
        }
    },
    handleAssetOptionClick: function( component, event, helper ) {
        
        //var currentLiteRowIndex = component.get( "v.currentLiteRowIndex" );
        //console.log( 'currentLiteRowIndex', currentLiteRowIndex );
        
        if( event.target && event.target.closest('li') && event.target.closest('li').dataset && 
           event.target.closest('li').dataset.id && event.target.closest('li').dataset.value
          ) {
            var selectedAssetId = event.target.closest('li').dataset.id;
            console.log( 'selectedAssetId', selectedAssetId );
            
            var selectedAssetSerialNumber = event.target.closest('li').dataset.value;
            console.log( 'selectedAssetSerialNumber', selectedAssetSerialNumber );
            
            var selectedAssetLiteHeight = event.target.closest('li').dataset.height;
            console.log( 'selectedAssetLiteHeight', selectedAssetLiteHeight );
            
            var selectedAssetLiteWidth = event.target.closest('li').dataset.width;
            console.log( 'selectedAssetLiteWidth', selectedAssetLiteWidth );
            
            var selectedAssetShape = event.target.closest('li').dataset.shape;
            console.log( 'selectedAssetShape', selectedAssetShape );
            
            var selectedExistingMakeUpId = event.target.closest('li').dataset.pid;
            console.log( 'selectedExistingMakeUpId', selectedExistingMakeUpId );
            
            var selectedExistingMakeUpName = event.target.closest('li').dataset.pname;
            console.log( 'selectedExistingMakeUpName', selectedExistingMakeUpName );
            helper.handleAssetOptionClick( component,  selectedAssetId,
                                          selectedAssetSerialNumber, selectedAssetLiteHeight,
                                          selectedAssetLiteWidth, selectedAssetShape,
                                          selectedExistingMakeUpId, selectedExistingMakeUpName
                                         );
            
        }
    },
    searchcontacts : function( component, event, helper ) {
        var contactid;
        var searchKeyword = event.target.value;
        console.log( 'searchKeyword', searchKeyword );
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
    openBoxModalFromcss : function( component, event, helper ) {
        
        var index = event.target.id;
        var issuelist=JSON.parse( JSON.stringify( component.get( "v.newIssuescss" ) ) );
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
    openRecordInNewConsoleTab : function( component, event, helper ) {
        
        if( event && event.target && event.target.id ) {
            helper.openRecordInNewConsoleTab( component, helper, event.target.id );
        }
    },
    
    disableBackspace : function(component, event, helper) {
        if(event.keyCode == 8 || event.keyCode === 46){
            event.preventDefault();
        }
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
            
            var logIssueCommonWrapper = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" ) ) );
            if( !logIssueCommonWrapper || !logIssueCommonWrapper.recordCase.Opportunity__c || !logIssueCommonWrapper.recordCase.Opportunity__r.Pricebook2Id ) {
                console.log( 'Pricebook missing', logIssueCommonWrapper.recordCase.Opportunity__r.Pricebook2Id);
                helper.showToastMessage( 'error', 'Pricebook missing', 'This Opportunity does not have a pricebook.' );
                return;
            }
            console.log('calling helper');
            if(logIssueCommonWrapper.selectedIssueType =="IGU"){
                helper.openProductLookupModal( component, helper, 'New Makeup Selection', recordIndex, searchKeyword,
                                              'IGU', 'listOfLogIssueWrappers', 'Product',
                                              logIssueCommonWrapper.recordCase.Opportunity__r.Pricebook2Id,
                                              logIssueCommonWrapper.recordCase.Opportunity__r.CurrencyIsoCode
                                             );
            }else{
                helper.openProductLookupModal( component, helper, 'Product Selection', recordIndex, searchKeyword,
                                              'CSS', 'listOfLogIssueWrappersCSS', 'Product',
                                              logIssueCommonWrapper.recordCase.Opportunity__r.Pricebook2Id,
                                              logIssueCommonWrapper.recordCase.Opportunity__r.CurrencyIsoCode
                                             );
            }
            
        }
    },
    handleSelectChangeEvt : function( component, event, helper ) {
        var values = event.getParam( "values" );
        var indexvar = event.getParam( "index" );
        console.log( 'handleSelectChangeEvt-index', indexvar );
        console.log( 'handleSelectChangeEvt-values', values );
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
        var namesOfSelectedFM = event.getParam( "NameOfFailureModesSelected" );
        
        wrapper.namesOfSFM = namesOfSelectedFM;
        wrapper.failuremodedeatils = false;
        /*for(var r in namesOfSelectedFM){
            if(!nameOfFM.includes(namesOfSelectedFM[r])){
                nameOfFM.push(namesOfSelectedFM[r]);
            }
            
        }*/
        component.set("v.NameOfFailureModesSelected",namesOfSelectedFM);
        
        console.log("===758=="+JSON.stringify(listOfIssueWrappers));
        component.set( "v." + listName, listOfIssueWrappers );
    },
    openScratchModal: function(component, event, helper){
       var recordIndex = event.target.id;
       var listName = event.target.dataset.title;
        var wrapData = component.get("v.issueWrapperdata");
            var wrapLst = component.get("v." +listName);
            var wrapper = wrapLst[ recordIndex ];
            var selectedFMN = wrapper.namesOfSFM;
        
        var namesOfSelectedFM = component.get("v.NameOfFailureModesSelected");
        if( selectedFMN !== undefined && ((selectedFMN.includes("OOS Scratches - S1/S4")) || (selectedFMN.includes("Non-Tinting - Intermittent Tinting")) 
           || (selectedFMN.includes("OOS Scratches - S3 / Other")) || (selectedFMN.includes("Obstruction in Field of View - Spontaneous Breakage"))
            || (selectedFMN.includes("Non-Tinting")) || (selectedFMN.includes("Non-Uniformity - Within Lite")) 
           || (selectedFMN.includes("Non-Uniformity - L2L")))){
             $A.createComponent('c:ScratchFailureMode', {
                'issueWrapperdata': component.get("v.issueWrapperdata"),
                'LogIssueWrapper': wrapper,
                'NameOfFailureModesSelected': selectedFMN,
                'recordIndex': recordIndex,
                 'ListName': listName
            },function (modalComponent, status, errorMessage) {
                if (status === "SUCCESS") {
                  
                    //component.set("v.provideDetails",true);
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
          //  console.log("===208==="+JSON.stringify(wrapData.issuesLst[recordIndex].issueRec));
        }
    },
    handleFailureModePDEvt: function(component, event, helper){
        
        var wrapRec = event.getParam("LogIssueWrapper");
        var listName = event.getParam("ListName");
        var recordIndex = event.getParam("recordIndex");
        var wrapData = component.get("v."+listName);
        var wrapper = wrapData[ recordIndex ];
        wrapRec.failuremodedeatils = true;
        wrapData[ recordIndex ] = wrapRec;
        /*var wrapIss = wrapData.chwIssueLst;
        for(var r in wrapIss){
            if(wrapIss[r].issueRec.Id === sRec.Id){
                wrapIss[r].issueRec = sRec; 
            }
        }
        wrapData.issuesLst = wrapIss;*/
        
        //component.set("v.listOfLogIssueWrappers",wrapData);
       // component.set("v.wrapData.failuremodedeatils",true);
        component.set( "v."+listName, wrapData );
        console.log('=====813==='+JSON.stringify(wrapData));
    },
    openFailureModeMultiSelectModal : function( component, event, helper ) {
        
        var recordIndex = event.target.id;
        console.log( 'openFailureModeMultiSelectModal-recordIndex', recordIndex );
        
        var listName = event.target.dataset.title;
        console.log( 'openFailureModeMultiSelectModal-listName', listName );
        if( !listName ) {
            return;
        }
        var logIssueCommonWrapper = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" ) ) );
        
        var listOfIssueWrappers = JSON.parse( JSON.stringify( component.get( "v." + listName ) ) );
        console.log( 'openFailureModeMultiSelectModal-listOfIssueWrappers', listOfIssueWrappers );
        if( !listOfIssueWrappers || listOfIssueWrappers.length < recordIndex ) {
            return;
        }
        
        var wrapper = listOfIssueWrappers[ recordIndex ];
        console.log( 'wrapper', wrapper );
        if(logIssueCommonWrapper.selectedIssueType =='Control Hardware'){
            if( !wrapper || !wrapper.failureComponent) {
                helper.showToastMessage( 'error', 'Failure Component Missing', 'Please select Failure Component first.' );
                return;
            }
        }
        
        /*if( !wrapper.reason_replacement) {
                helper.showToastMessage( 'error', 'Reason for Replacement', 'Please select Reason for Replacement first.' );
                return;
            }*/
        
        console.log('listOfSelectedFailureModes : ',wrapper.listOfSelectedFailureModes);
        if(logIssueCommonWrapper.selectedIssueType =='IGU'){
            helper.openFailureModeMultiSelectModal( component, helper, recordIndex, 'IGU',
                                                   listName, wrapper.listOfSelectedFailureModes,wrapper.reason_replacement
                                                  );
            
        }else{
            helper.openFailureModeMultiSelectModal( component, helper, recordIndex, wrapper.failureComponent,
                                                   listName, wrapper.listOfSelectedFailureModes,wrapper.reason_replacement
                                                  );
        }
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
    openAssetLookupModal : function( component, event, helper ) {
        
        var keyCode = event.which;
        console.log( 'openAssetLookupModal-key', keyCode );
        if( keyCode == 13 ) {
            
            
            
            var searchKeyword = event.target.value;
            console.log( 'openAssetLookupModal-searchKeyword', searchKeyword );
            
            var logIssueCommonWrapper = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" ) ) );
            if( !logIssueCommonWrapper || !logIssueCommonWrapper.recordCase.Opportunity__c ) {
                helper.showToastMessage( 'error', 'Opportunity missing', 'This Case does not have an Opportunity.' );
                return;
            }
            if( !logIssueCommonWrapper || !logIssueCommonWrapper.common_Lite_Mockid ) {
                helper.showToastMessage( 'error', 'IGU ID Provided missing', 'Please select IGU ID Provided.' );
                return;
            }
            helper.openAssetLookupModal( component, helper, 'Lite ID Selection', 1, searchKeyword,
                                        logIssueCommonWrapper.recordCase.Opportunity__c, 'listOfIGUIssueWrappers',
                                        'common_Liteid'
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
    openAddressSearchModalForCommonIssue : function( component, event, helper ) {
        
        var logIssueCommonWrapper = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" ) ) );
        helper.openAddressSearchModal( component, helper, null, null, 'logIssueCommonWrapper', logIssueCommonWrapper );
    },
    openQualityAnalysisModal : function( component, event, helper ) {
        
        var listOfLogIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfLogIssueWrappers" ) ) );
        if( !listOfLogIssueWrappers || listOfLogIssueWrappers.length == 0 ) {
            return;
        }
        
        var recordIndex = event.target.id;
        if( recordIndex < 0 ) {
            return;
        }
        
        var recordIssue = listOfLogIssueWrappers[ recordIndex ];
        helper.openQualityAnalysisModal( component, helper, recordIndex, 'listOfLogIssueWrappers', recordIssue );
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
        
        wrapper.Replaced_SWC = recordIssue.Replaced_SWC;
        wrapper.Lite_Damaged = recordIssue.Lite_Damaged;
        wrapper.Replaced_WC = recordIssue.Replaced_WC;
        wrapper.Visible_BB_Damage = recordIssue.Visible_BB_Damage;
        wrapper.Replaced_IGU_Cable = recordIssue.Replaced_IGU_Cable;
        wrapper.Reflection_Color_Observed = recordIssue.Reflection_Color_Observed;
        wrapper.Reflection_Color_Degree = recordIssue.Reflection_Color_Degree;
        
        component.set( "v." + listName, listOfIssueWrappers );
    },
    openQualityAnalysisModalcss : function( component, event, helper ) {
        
        var listOfLogIssueWrappersCSS = JSON.parse( JSON.stringify( component.get( "v.listOfLogIssueWrappersCSS" ) ) );
        if( !listOfLogIssueWrappersCSS || listOfLogIssueWrappersCSS.length == 0 ) {
            return;
        }
        
        var recordIndex = event.target.id;
        if( recordIndex < 0 ) {
            return;
        }
        
        var recordIssue = listOfLogIssueWrappersCSS[ recordIndex ];
        helper.openQualityAnalysisModal( component, helper, recordIndex, 'listOfLogIssueWrappersCSS', recordIssue );
    },
    populateRequestedDeliveryDateOnIssues : function( component, event, helper ) {
        var requestedDeliveryDate = event.getSource().get( "v.value" );
        console.log( 'populateRequestedDeliveryDateOnIssues-requestedDeliveryDate', requestedDeliveryDate );
        var logIssueCommonWrapper=JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper")));
        if(logIssueCommonWrapper.selectedIssueType == 'IGU'){
            helper.populateValueOnIssuesIGU( component, helper, 'requestedDate', requestedDeliveryDate );
        } 
        if(logIssueCommonWrapper.selectedIssueType == 'Control Hardware'){
            helper.populateValueOnIssuesCSS( component, helper, 'requestedDate', requestedDeliveryDate );
        } 
        
    },
    populateOwnershipOnIssues : function( component, event, helper ) {
        
        var ownershipValue = event.getSource().get( "v.value" );
        console.log( 'populateOwnershipOnIssues-ownershipValue', ownershipValue );
        var logIssueCommonWrapper=JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper")));
        if(logIssueCommonWrapper.selectedIssueType == 'IGU'){
            helper.populateOwnershipOnIssuesIGU( component, helper, 'sel_Resp_Entity', ownershipValue );
        } 
        if(logIssueCommonWrapper.selectedIssueType == 'Control Hardware'){
            helper.populateOwnershipOnIssuesCSS( component, helper, 'sel_Resp_Entity', ownershipValue );
        } 
        
    },
    populateRFROnIssues : function( component, event, helper ) {
        
        var ReasonforReplacementValue = event.getSource().get( "v.value" );
        console.log( 'populateOwnershipOnIssues-ReasonforReplacementValue', ReasonforReplacementValue );
        var logIssueCommonWrapper=JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper")));
        if(logIssueCommonWrapper.selectedIssueType == 'IGU'){
            helper.populateRFROnIssuesIGU( component, helper, 'Reason_for_Replacement', ReasonforReplacementValue );
        } 
        if(logIssueCommonWrapper.selectedIssueType == 'Control Hardware'){
            helper.populateRFROnIssuesCSS( component, helper, 'Reason_for_Replacement', ReasonforReplacementValue );
        } 
        
    },
    /*openUpdateIGUIssue : function (component, event, helper) {
        var recdid = component.get("v.recordId");
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef : "c:updateIGUIssue",
            componentAttributes: {
                recordId:recdid
            }
        });
        evt.fire();
    }*/
    
    handlermachecked : function (component, event, helper) {
        var checked = event.getSource().get("v.checked");
       	if (checked) {
            component.set("v.RMAChecked",false);
        }
    },
    handlermacsschecked : function (component, event, helper) {
        var checked = event.getSource().get("v.Value");
        if (checked) {
            component.set("v.RMACSSChecked", "false");
        }
    },
    handleHeaderRma : function (component, event, helper){
         var checked = event.getSource().get("v.checked");
       	if (checked) {
            component.set("v.RMAChecked",false);
        }
    },
    handleSparePart : function (component, event, helper) {
        var logIssueCommonWrapper=JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper")));
        
        var checkedValue = event.getSource().get("v.Value");
        
        if(logIssueCommonWrapper.selectedIssueType == 'IGU'){
            var rmaChecked = component.get("v.RMAChecked");
            if (logIssueCommonWrapper.orderReplacement && rmaChecked) {
              //  helper.showToastMessage('error', 'error!', 'Attic Stock cannot be replaced, Please contact Deal Desk to order for Attic Stock');
                
            }
        }
        if(logIssueCommonWrapper.selectedIssueType == 'Control Hardware'){
            var rmaChecked = component.get("v.RMACSSChecked");
            if (logIssueCommonWrapper.orderReplacement && rmaChecked) {
               // helper.showToastMessage('error', 'error!', 'Spare Parts cannot be replaced, Please contact Deal Desk to order for Spare Parts');
            }
        } 
    },
    
   onContinue: function(component, event, helper) {
       component.set("v.isOpenSubmitMessage", false);
       if(component.get("v.closeAndOpenCase")){
           helper.cancel(component, helper);
       }else{
           $A.get('e.force:refreshView').fire();
       }
   },
})