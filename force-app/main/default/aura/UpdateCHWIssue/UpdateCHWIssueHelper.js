({
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
    openRecordInNewConsoleTab: function (component, helper, recordId) {

        if (recordId) {
            var isConsoleNavigation = component.get("v.isConsoleNavigation");
            if (isConsoleNavigation) {

                var workspaceAPI = component.find("workspace");
                if (workspaceAPI) {

                    workspaceAPI.openTab
                        ({
                            recordId: recordId,
                            focus: true
                        }).then(function (response) {
                            workspaceAPI.getTabInfo
                                ({
                                    tabId: response
                                }).then(function (tabInfo) {
                                    if (tabInfo) {
                                        console.log("The url for this tab is:", tabInfo.url);
                                    }
                                });
                        })
                        .catch(function (error) {
                            console.log('openRecordInNewConsoleTab-error', error);
                        });
                }
            }
            else {
                window.open('/' + recordId, '_blank');
            }
        }
    },
    setConsoleTabSettings: function (component) {

        var workspaceAPI = component.find("workspace");
        if (workspaceAPI) {
            workspaceAPI.isConsoleNavigation().then(function (response) {
                console.log('Are you in Console Navigation?', response);
                component.set("v.isConsoleNavigation", response);
            })
                .catch(function (error) {
                    console.log(error);
                });

            setTimeout(function () {
                workspaceAPI.getFocusedTabInfo().then(function (response) {
                    var focusedTabId = response.tabId;
                    if (focusedTabId) {
                        workspaceAPI.setTabLabel({
                            tabId: focusedTabId,
                            label: 'Log Issues'
                        });
                    }
                })
                    .catch(function (error) {
                        console.log(error);
                    });
            }, 2000);
        }
    },
    doInit: function (component, varissuetype) {

        var helper = this;
        var recordId = component.get("v.recordId");
        console.log('in doinit: recor case id');
        console.log('in doinit: varissuetype', varissuetype);
              
        if (!recordId) {
            helper.showToastMessage('error', 'Error!', 'Sorry, Case Id is not found. Please try again.');
            return;
        }

        var serverAction = component.get("c.getLogIssueDetails");
        if (!serverAction) {
            return;
        }

        component.set("v.spinner", true);

        serverAction.setParams({ "strCaseId": recordId });

        serverAction.setCallback(this, function (response) {

            component.set("v.spinner", false);

            var state = response.getState();
            if (state === "SUCCESS") {
                console.log('doinit state : ', state);
                var result = JSON.parse(response.getReturnValue());
                // console.log( result );
                console.log('doinit isSucceeded : ', result.isSucceeded);
                if (result.isSucceeded) {
                    
                    component.set("v.logIssueCommonWrapper", result.logIssueCommonWrapper);
                    component.set("v.logIssueCommonWrapperDupe", result.logIssueCommonWrapper);
                    component.set("v.listOfLogIssueWrappers", []);
                    component.set("v.listOfLogIssueWrappersCSS", result.listOfLogIssueWrappersCSS);
                    component.set("v.listOfFailureModeResults", result.logIssueCommonWrapper.listOfFailureModeResults);
                    component.set("v.lstFmodeData", result.logIssueCommonWrapper.listOfFailureModeResults);
                    component.set("v.recordTypeNameToListOfFailureComponents", result.recordTypeNameToListOfFailureComponents);

                    var logIssueCommonWrapper = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" ) ) ); 
                    var successMsgEle = component.find('successMsg_submit');
                    var errorMsgEle = component.find('errorMsg_submit');
                    $A.util.removeClass(successMsgEle, "slds-show");
                    $A.util.addClass(successMsgEle, "slds-hide");
                    $A.util.removeClass(errorMsgEle, "slds-show");
                    $A.util.addClass(errorMsgEle, "slds-hide"); 
                    component.set("v.submitErrorMessage", "");
                    component.set( "v.listOfResponsibleEntities", logIssueCommonWrapper.listOfownershippicklist );
                    component.set( "v.listOfReasonForReplacements", logIssueCommonWrapper.listOfCSSReplacements );
                }
                else {
                    helper.showToastMessage('error', 'Error!', result.message);
                }
            }
            else {
                helper.showToastMessage('error', 'Error!', 'Sorry, something went wrong; please contact Admin.');
            }
        });
        $A.enqueueAction(serverAction);
    },


    updatecssIssue: function (component, event, helper) {
       /* var issueList = JSON.parse(JSON.stringify(component.get("v.newIssuescss")));
        var validateissuelist = helper.ValidateCHrows(component, issueList);
        console.log('validateissuelist:' + validateissuelist);
        if (validateissuelist) {
            component.set("v.spinner", true);
            var issuesare = [];
            issueList.forEach(function (each) {
                if (each.isSelected) {
                    delete each.isSelected;
                    issuesare.push(each);
                }
            });
            var createIssueAction = component.get("c.updateIssue");
            createIssueAction.setParams({
                issuesList : issuesare
            });*/
        var wrapData = component.get("v.issueWrapperdata");
        var issueList = [];
        var issueRecdsWrap = wrapData.chwIssueLst;
          var issuekey=[];
        var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" ) ));
        
        // BM
        if(!recordCommonIssue.Shipping_Street_1) {
			helper.showToastMessage( 'error', 'Error!', 'Please provide Shipping Information.');
			return false;
		}
        
        for(var r in issueRecdsWrap){
            if(issueRecdsWrap[r].selected){
                
                issueRecdsWrap[r].issueRec.Shipping_Contact_Name__c =  recordCommonIssue.shipToContactname;
                issueRecdsWrap[r].issueRec.Shipping_Contact_Number__c = recordCommonIssue.shipToContactPhone;
                issueRecdsWrap[r].issueRec.Shipping_Contact_Email__c = recordCommonIssue.shipToContactEmail;
                issueRecdsWrap[r].issueRec.Customer_Contact__c = recordCommonIssue.shipToContactid;
                
                issueRecdsWrap[r].issueRec.Shipping_Street_1__c =  recordCommonIssue.Shipping_Street_1;
                issueRecdsWrap[r].issueRec.Shipping_Street_2__c = recordCommonIssue.Shipping_Street_2;
                issueRecdsWrap[r].issueRec.Shipping_City__c = recordCommonIssue.Shipping_City;
                issueRecdsWrap[r].issueRec.Shipping_State_Province__c = recordCommonIssue.Shipping_State_Province;
                issueRecdsWrap[r].issueRec.Shipping_Country__c = recordCommonIssue.Shipping_Country;
                issueRecdsWrap[r].issueRec.Shipping_Postal_Code__c = recordCommonIssue.Shipping_Postal_Code;
                issueRecdsWrap[r].issueRec.Product_Code__c = undefined;
                issueRecdsWrap[r].issueRec.Product_SKU__c = undefined;
                issueList.push(issueRecdsWrap[r].issueRec);
                issuekey.push(issueRecdsWrap[r].issueRec.Id);
            }
        }
        
        var validateissuelist = helper.ValidateCHrows(component, JSON.parse(JSON.stringify(issueList)));
        if (validateissuelist) {
            component.set("v.spinner", true);
            var issuesare = [];
            issueList.forEach(function (each) {
                if (each.isSelected) {
                    delete each.isSelected;
                    issuesare.push(each);
                }
            });
            
            //var createIssueAction = component.get("c.updateIssue");
            var createIssueAction = component.get("c.updateIssueWithModes");
            
            var arrayMapKeys = [];
                for(var key in issueRecdsWrap){
                    if(issuekey.indexOf(issueRecdsWrap[key].issueRec.Id) !== -1)
                    arrayMapKeys.push({key: issueRecdsWrap[key].issueRec.Id, value: issueRecdsWrap[key].selectedFailures});
                }
                        
            createIssueAction.setParams({
                issueLst : issueList, selectedModeMap : JSON.stringify(arrayMapKeys)
            });
            createIssueAction.setCallback(this, function (response) {

                var state = response.getState();
                console.log(state);
                if (state === "SUCCESS") {
                    var updatedIssues = response.getReturnValue();
                    component.set("v.isSuccess", false);
                     component.set("v.saveIssues", false);
                   
                    for(var r in issueRecdsWrap){
                        issueRecdsWrap[r].selected = false;
                        for(var i in updatedIssues){
                            if(issueRecdsWrap[r].issueRec.Id == updatedIssues[i].Id){
                                issueRecdsWrap[r].issueRec = updatedIssues[i];
                            }
                        }
                        
                    }
                    
                     var issueRecds = component.get("v.openCHWShippedStatus");
                    
                    for(var i in issueRecds){
                        for(var r in updatedIssues){
                            if(updatedIssues[r].Id == issueRecds[i].Id){
                                issueRecds[i] = updatedIssues[r];
                            }
                        }
                    }
                    
                    var lgCmpIssue = component.get("v.newIssues");
                     for(var i in lgCmpIssue){
                        for(var r in updatedIssues){
                            if(updatedIssues[r].Id == lgCmpIssue[i].Id){
                                lgCmpIssue[i] = updatedIssues[r];
                            }
                        }
                    }
                    
                    wrapData.issuesLst = issueRecdsWrap;
                    component.set("v.issueWrapperdata",wrapData);
                    component.set("v.openCHWShippedStatus",issueRecds);
                     component.set("v.newIssues",lgCmpIssue);
                    component.set("v.spinner", false);
                    helper.showToastMessage('success', 'success!', 'Issues updated successfully');
                } else if (response.getState() === "ERROR") {
                    component.set("v.spinner", false);
                    var errors = JSON.parse(JSON.stringify(response.getError()));
                    console.log('errors:-', errors);
                    if (errors) {
                        var allErrMsgs = '';
                        errors.forEach(function (error) {
                            console.log('error.message' + error.message);
                            //top-level error.  there can be only one
                            if (error.message) {
                                allErrMsgs = error.message;
                            }

                            //page-level errors (validation rules, etc)
                            if (error.pageErrors) {
                                error.pageErrors.forEach(function (pageError) {
                                    console.log('pageError' + pageError);
                                    allErrMsgs = allErrMsgs + pageError.message + '\n';
                                });
                            }

                            if (error.fieldErrors) {
                                //field specific errors--we'll say what the field is					
                                for (var fieldName in error.fieldErrors) {
                                    //each field could have multiple errors
                                    error.fieldErrors[fieldName].forEach(function (errorList) {
                                        allErrMsgs = allErrMsgs + "Field Error on " + fieldName + " : " + errorList.message + '\n';
                                    });
                                };  //end of field errors forLoop					
                            } //end of fieldErrors if
                        }); //end Errors forEach
                        console.log('allErrMsgs:' + allErrMsgs);
                        helper.showToastMessage('error', 'Error!', allErrMsgs);
                    }

                }
            });
            $A.enqueueAction(createIssueAction);
        }

    },
    getCSSRecTypes: function (component, event) {
        if (component.get("v.logIssueCommonWrapper.selectedIssueType") != "") {
            var getCSSRecTypesAction = component.get("c.getCSSRecordTypes");
            getCSSRecTypesAction.setCallback(this, function (response) {
                var state = response.getState();
                console.log('state:' + state);
                if (state === "SUCCESS") {
                    console.log('Success Get Failure Modes');
                    var allCSSRecTypes = [];
                    var cSSRecTypeEmpty = new Object();
                    cSSRecTypeEmpty.label = 'Select';
                    cSSRecTypeEmpty.value = '';
                    allCSSRecTypes.push(cSSRecTypeEmpty);
                    for (var i = 0; i < response.getReturnValue().length; i++) {
                        var eachCSSRecType = new Object();
                        eachCSSRecType.label = response.getReturnValue()[i].Name;
                        eachCSSRecType.value = response.getReturnValue()[i].Id;
                        allCSSRecTypes.push(eachCSSRecType);
                    }
                    console.log('allCSSRecTypes:' + allCSSRecTypes);
                    component.set("v.cssRecTypes", allCSSRecTypes);
                } else {
                    component.set("v.cssRecTypes", []);
                }
            });
            $A.enqueueAction(getCSSRecTypesAction);
        }
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


    handleSubitandcontinuecss: function (component, event, numbercode) {
        var helper = this;
     
		var caseId =  component.get("v.recordId");
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
        component.set("v.logIssueCommonWrapperDupe2", logIssueCommonWrapper);
        var newIssuescss = JSON.parse(JSON.stringify(component.get("v.newIssuescss")));
		var wrapData =  component.get("v.issueWrapperdata");
		var issueLst = wrapData.chwIssueLst;
		var issueRecs = [];
        var issuekey=[];
        
        //BM
        if(!logIssueCommonWrapper.Shipping_Street_1) {
			helper.showToastMessage( 'error', 'Error!', 'Please provide Shipping Information.');
			return false;
		}
        
        console.log('newIssues===', newIssuescss);
        for (var index = 0; index < issueLst.length; index++) {
            
             if(issueLst[index].selected)
			 {
                 if(issueLst[index].selectedFailures.length == 0){
                helper.showToastMessage('Error', 'Missing!', 'Please add Failure mode to continue');

                    return;
                }
            issueLst[index].issueRec.Defect_Root_Causes__r = undefined;
            issueRecs.push(issueLst[index].issueRec);
             issuekey.push(issueLst[index].issueRec.Id); 
			}

        }
		  var validateissuelist = helper.ValidateCHrows(component, JSON.parse(JSON.stringify(issueRecs)));
        if (validateissuelist) {
      
		wrapData.chwIssueLst = issueLst;
		component.set("v.issueWrapperdata", wrapData);
		component.set("v.spinner", true);
		component.set("v.spinner", true);
            
            var arrayMapKeys = [];
            for(var key in issueLst){
                if(issuekey.indexOf(issueLst[key].issueRec.Id) !== -1)
                    arrayMapKeys.push({key: issueLst[key].issueRec.Id, value: issueLst[key].selectedFailures});
            }

            
        var submitrecordsforapproval = component.get("c.submitIssuesForApprovalAndOrder");            
        submitrecordsforapproval.setParams({
            "issueRecsstr": JSON.stringify(issueRecs),
            "caseId": caseId,
            "issueLst": issueRecs,
            "selectedModeMap": JSON.stringify(arrayMapKeys),
            "issueCommonHeader":  JSON.stringify(logIssueCommonWrapper),
        });
		submitrecordsforapproval.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state : ', state);
            component.set("v.spinner", false);
            var openIssueRecdsCopy = component.get("v.openCHWShippedStatus");
            var openIssueRecds = component.get("v.openCHWShippedStatus");
            var newIssueRecds = component.get("v.newIssues");
            var newIssueRecdsCopy = component.get("v.newIssues");
            var resposeWrap = response.getReturnValue();
			var submittesIssLst = resposeWrap.updatedList;
            //var submittesIssLst = response.getReturnValue();
            if (state === "SUCCESS") {
               
                var issueidlist = [];
                var submIssues = submittesIssLst;
                for(var r in submIssues){
                    issueidlist.push(submIssues[r].Id);
                    for(var i in issueLst){
                        issueLst[i].selected = false;
                        if(issueLst[i].issueRec.Id == submIssues[r].Id){
                        
                            issueLst[i].newMakeUpname = submIssues[r].Product__r.Name;
                            wrapData.chwIssueLst[i].newMakeUpname = submIssues[r].Product__r.Name;
                            if(submIssues[r].In_Approval__c || submIssues[r].Issue_Status__c !== 'Open'){
                                wrapData.chwIssueLst.splice(i, 1);
                            }
                        }
                    }
                   
                    for(var o in openIssueRecds){
                        if(openIssueRecds[o].Id == submittesIssLst[r].Id){
                           /* if((submittesIssLst[r].Issue_Status__c !== 'Open') 
                               || (submittesIssLst[r].Issue_Status__c !== 'Order Shipped')
                              || (submittesIssLst[r].Issue_Status__c !== 'Order Processing') 
                               || (submittesIssLst[r].Issue_Status__c !== 'Fulfilled')){
                                openIssueRecdsCopy.splice(o, 1);
                            }*/
                            if(submittesIssLst[r].In_Approval__c || (submittesIssLst[r].Issue_Status__c !== 'Open')){
                                openIssueRecdsCopy.splice(o, 1);
                            }
                        }
                    }
                    
                    for(var p in newIssueRecds){
                        if(newIssueRecds[p].Id == submittesIssLst[r].Id){
                           /* if((submittesIssLst[r].Issue_Status__c !== 'Open') 
                               || (submittesIssLst[r].Issue_Status__c !== 'Order Shipped')
                              || (submittesIssLst[r].Issue_Status__c !== 'Order Processing') 
                               || (submittesIssLst[r].Issue_Status__c !== 'Fulfilled')){
                                newIssueRecdsCopy.splice(p, 1);
                            }*/
                            if(submittesIssLst[r].In_Approval__c || (submittesIssLst[r].Issue_Status__c !== 'Open')){
                                newIssueRecdsCopy.splice(o, 1);
                            }
                        }
                    }
                }
                component.set("v.saveIssues",false);
                console.log('====403===='+JSON.stringify(wrapData));
                component.set("v.issueWrapperdata",wrapData);
                component.set("v.openCHWShippedStatus",openIssueRecdsCopy);
                component.set("v.openCHWShippedStatusClone",openIssueRecdsCopy);
                
                 component.set("v.newIssues",newIssueRecdsCopy);
                if (numbercode == 1) {
                    helper.DisplaysubmittedissueStatus(component, issueidlist, "CSS");
                    helper.showSubmittedIssuesModal(component, helper, issueidlist,1);
                    helper.showToastMessage('success', 'success!', 'Issues Submitted Successfully.');

                } else if (numbercode == 2) {
                    helper.showSubmittedIssuesModal(component, helper, issueidlist,2);
                    component.set("v.closeAndOpenCase",true);
                }
                if(resposeWrap.success === false){
                 //  component.set("v.isOpenSubmitMessage",true);
                }
			 //$A.get('e.force:refreshView').fire();
            }
        });
        $A.enqueueAction(submitrecordsforapproval);
        }
    },
    DisplaysubmittedissueStatus: function (component, issueidlist, varfamily) {
        console.log('--issueidlist-', issueidlist);
        console.log('--varfamily-', varfamily);
        var helper = this;
        var newIssuesWithStatus = JSON.parse(JSON.stringify(component.get("v.newIssuesWithStatus")));
        var newIssuescssWithStatus = JSON.parse(JSON.stringify(component.get("v.newIssuescssWithStatus")));
        var Action = component.get("c.getprocessStatus");
        Action.setParams({
            "issueidslist": JSON.stringify(issueidlist)
        });
        Action.setCallback(this, function (response) {
            var state = response.getState();

            console.log('state : ', state);
            component.set("v.spinner", false);
            if (state === "SUCCESS") {
                var issueidlist = JSON.parse(JSON.stringify(response.getReturnValue()));
                var currentlist;
                if (varfamily == "IGU") {
                    helper.showToastMessage('success', 'success!', 'Issues Submitted Successfully.');

                    currentlist = newIssuesWithStatus;

                } else if (varfamily == "CSS") {
                    helper.showToastMessage('success', 'success!', 'Issues Submitted Successfully.');
                    currentlist = newIssuescssWithStatus;
                }

                var updatedlist = currentlist.concat(issueidlist);
                console.log('response : ', JSON.stringify(response.getReturnValue()));
                if (varfamily == "IGU") {
                    component.set("v.newIssuesWithStatus", updatedlist);
                    //component.set("v.newIssues", []);
                    helper.doInit(component, "IGU");
                } else if (varfamily == "CSS") {
                    component.set("v.newIssuescssWithStatus", updatedlist);
                    //component.set("v.newIssuescss", []);
                    helper.doInit(component, "CSS");

                }

            }
        });
        $A.enqueueAction(Action);
    },

    ValidateCHrows: function (component, issueList) {
        var helper = this;
        console.log('validateIssues', issueList);

        if (!issueList || issueList.length < 1) {
            return false;
        }
        var recordIssue;
        var dateValue;
        var todayDate = helper.parseDateToString(new Date());
        console.log('todayDate', todayDate);

        var tomorrowDate = new Date();
        tomorrowDate.setDate(tomorrowDate.getDate() + 1);
        tomorrowDate = helper.parseDateToString(tomorrowDate);
        console.log('tomorrowDate', tomorrowDate);

        var strDate = '' + $A.localizationService.formatDate(new Date(), "YYYY-MM-DD, hh:mm:ss a");
        console.log('strDate', strDate);

        var isThisPostMeridiem = strDate.includes('PM');
        console.log('isThisPostMeridiem', isThisPostMeridiem);
        for (var index = 0; index < issueList.length; index++) {
            recordIssue = issueList[index];
            
            if (!recordIssue.Quantity__c || isNaN(recordIssue.Quantity__c)) {

                helper.showToastMessage('warning', 'Missing!', 'Provide Quantity for row --> ' + (index + 1));

                return false;
            } 
            
             else if ( recordIssue.Product__c===undefined) {
            helper.showToastMessage('Error', 'Missing!', 'Provide Product for row  '+(index + 1));
                return false;
                break;
            
            }
            else if (recordIssue.Requested_Delivery_Date__c ===undefined) {
            
            helper.showToastMessage('Error', 'Missing!', 'Provide Requested delivery date for row  '+(index + 1));
                return false;
                break;
            }
            else if (recordIssue.Shipping_Container__c==='') {
            
            helper.showToastMessage('Error', 'Missing!', 'Provide shipping container for row  '+(index + 1));
                return false;
                break;
            }
            else if ( recordIssue.Reason_for_Replacement__c==='') {
            
            helper.showToastMessage('Error', 'Missing!', 'Provide Reason for replacement for row  '+(index + 1));
                return false;
                break;
            }
            else if (recordIssue.Ownership__c==='') {
            helper.showToastMessage('Error', 'Missing!', 'Provide Who Caused  Damage for row  '+(index + 1));
                return false;
                break;
            
            }
            
            else if (recordIssue.Requested_Delivery_Date__c) {
                dateValue = new Date(recordIssue.Requested_Delivery_Date__c);
                if (dateValue != 'Invalid Date' && isNaN(dateValue) == false) {

                    dateValue = recordIssue.Requested_Delivery_Date__c;
                    if (dateValue <= todayDate) {
                        helper.showToastMessage('warning', 'Missing!', $A.get("$Label.c.Requested_Delivery_Date_Is_Future_Date") + 'For row -->' + (index + 1));
                        return false;
                    }
                    else if (dateValue == tomorrowDate && isThisPostMeridiem) {
                        helper.showToastMessage('warning', 'Missing!', $A.get("$Label.c.Requested_Delivery_Date_Cannot_Be_Tomorrow_s_Date") + 'For row -->' + (index + 1));
                        return false;
                    }
                }
            }

        }

        return true;
    },

    fetchopenissuesdoinitCSS: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var fetchopenissuesAction = component.get("c.fetchopenCSSissuesForCHW");

        fetchopenissuesAction.setParams({ "caseid": recordId });
        fetchopenissuesAction.setCallback(this, function (response) {

            var state = response.getState();
            console.log('fetchopenissuesdoinitCSS-state-', state);
            if (state === "SUCCESS") {
                var responseiss = response.getReturnValue();
                console.log('fetchopenissuesdoinitCSS-responseiss-', responseiss);
                component.set("v.newIssuescss", response.getReturnValue());


            }
            else {
                helper.showToastMessage('error', 'Error!', 'Sorry, something went wrong; please contact Admin.');
            }
        });
        $A.enqueueAction(fetchopenissuesAction);
    },
    cancel: function (component, helper) {

        var isConsoleNavigation = component.get("v.isConsoleNavigation");
        if (isConsoleNavigation) {
            var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
            if (logIssueCommonWrapper) {
                helper.openRecordInNewConsoleTab(component, helper, logIssueCommonWrapper.recordCase.Id);
            }
            helper.closeFocusedTab(component);
        }
        else {
            var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
            if (logIssueCommonWrapper) {
                window.open('/' + logIssueCommonWrapper.recordCase.Id, '_self');
            }
        }
    },

    closeFocusedTab: function (component) {

        var workspaceAPI = component.find("workspace");
        if (workspaceAPI) {
            workspaceAPI.getFocusedTabInfo().then(function (response) {
                var focusedTabId = response.tabId;
                workspaceAPI.closeTab({ tabId: focusedTabId });
            })
                .catch(function (error) {
                    console.log('LogissuesCmpHelper-closeFocusedTab', error);
                });
        }
    },
    openFailureModeMultiSelectModal : function( component, helper, recordIndex, failureComponent,
												listName, listOfAlreadySelectedFailureModes								   
	) {
        $A.createComponent( 'c:FailureModeModalCmp', {
			'recordIndex' : recordIndex,
			'failureComponent' : failureComponent,
			'listName' : listName,
			'listOfAlreadySelectedFailureModes' : listOfAlreadySelectedFailureModes
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
    
    openProductLookupModal: function (component, helper, headerText, recordIndex,
                                      searchKeyword, productFamily, listName, fieldName,
                                      opportunityPricebook2Id, currencyIsoCode
                                     ) {
        $A.createComponent('c:ProductLookupCmp', {
            'headerText': headerText,
            'recordIndex': recordIndex,
            'searchKeyword': searchKeyword,
            'productFamily': productFamily,
            'listName': listName,
            'fieldName': fieldName,
            'opportunityPricebook2Id': opportunityPricebook2Id,
            'currencyIsoCode': currencyIsoCode,
            'componentName': component.get("v.componentName")
        },
                           function (modalComponent, status, errorMessage) {
                               
                               if (status === "SUCCESS") {
                                   
                                   var showChildModalDiv = component.find('showProductLookupModal');
                                   if (showChildModalDiv) {
                                       var body = showChildModalDiv.get("v.body");
                                       body.push(modalComponent);
                                       component.find('showProductLookupModal').set("v.body", body);
                                   }
                               }
                               else if (status === "INCOMPLETE") {
                                   helper.showToastMessage('error', 'Error!', 'Internal Server issue or client is offline.');
                               }
                                   else if (status === "ERROR") {
                                       helper.showToastMessage('error', 'Error!', 'Something went wrong. Please try again.');
                                   }
                           });
    },
      handleProductSelectEvt: function (component, helper, recordIndex, listName, fieldName, recordProductWrapper) {
        if (recordIndex < 0 || !listName || !fieldName || !recordProductWrapper || !recordProductWrapper.recordProduct) {
            return;
        }
          
        var  wrapData = component.get("v.issueWrapperdata");
        var issuLst = wrapData.chwIssueLst;
        var selRecrdId = component.get("v.selectedAssestId")
        
        issuLst[recordIndex].newMarkUp = recordProductWrapper.recordProduct.Id;
        issuLst[recordIndex].newMakeUpname = recordProductWrapper.recordProduct.Name;
        issuLst[recordIndex].newMakeUpProduct_SKU = recordProductWrapper.recordProduct.Product_SKU__c;
        issuLst[recordIndex].newMakeUpProductCode = recordProductWrapper.recordProduct.ProductCode;
        issuLst[recordIndex].issueRec.Existing_Makeup__c = recordProductWrapper.recordProduct.Id;
        issuLst[recordIndex].issueRec.Product__c = recordProductWrapper.recordProduct.Id;
        issuLst[recordIndex].issueRec.Product_SKU__c = recordProductWrapper.recordProduct.Product_SKU__c;
        issuLst[recordIndex].issueRec.Product_Code__c = recordProductWrapper.recordProduct.ProductCode;
        wrapData.chwIssueLst = issuLst;
        component.set("v.issueWrapperdata",wrapData);
    },
    
    showSubmittedIssuesModal : function( component, helper, listOfIssues,submitedtype ) {
	
		if( !listOfIssues || listOfIssues.length == 0 ) {
			return listOfIssues;
		}
		
		$A.createComponent( 'c:LogIssueApprovalIssue', {
			'listOfSubmittedIssues' : listOfIssues, 'recordtype' :'CHW','componentName':component.get("v.componentName"),
            'submitedtype':submitedtype
            
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
    openAddressSearchModal: function (component, helper, recordIndex, listName, objectName, recordCommonIssue) {
        
        if (!recordIndex && !listName && !objectName) {
            return;
        }
        
        
        $A.createComponent('c:GoogleAddressSearchCmp', {
            'recordIndex': recordIndex,
            'listName': listName,
            'objectName': objectName,
            'recordIssue': recordCommonIssue,
            'fromComponent': 'LogIssues',
            'googleAddressSearchModalEvt': component.getReference("c.handleGoogleAddressSearchModalEvt"),
            'componentName': component.get("v.componentName")
        },
                           function (modalComponent, status, errorMessage) {
                               
                               if (status === "SUCCESS") {
                                   
                                   var showChildModalDiv = component.find('showAddressSearchModal');
                                   if (showChildModalDiv) {
                                       var body = showChildModalDiv.get("v.body");
                                       body.push(modalComponent);
                                       component.find('showAddressSearchModal').set("v.body", body);
                                   }
                               }
                               else if (status === "INCOMPLETE") {
                                   helper.showToastMessage('error', 'Error!', 'Internal Server issue or client is offline.');
                               }
                                   else if (status === "ERROR") {
                                       helper.showToastMessage('error', 'Error!', 'Something went wrong. Please try again.');
                                   }
                           });
    },
     validateHeaderFields: function (component) {
        
        var helper = this;
        var isQuotetoCon = component.get("v.isQuotetoCon");
        var isShiptoCon = component.get("v.isShiptoCon");
        var isShippinginfo = component.get("v.isShippinginfo");
        
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
        if (isShippinginfo) {
            if (!logIssueCommonWrapper || !logIssueCommonWrapper.recordAccount.ShippingStreet ||
                !logIssueCommonWrapper.recordAccount.ShippingCity || !logIssueCommonWrapper.recordAccount.ShippingState
                || !logIssueCommonWrapper.recordAccount.ShippingCountry || !logIssueCommonWrapper.recordAccount.ShippingPostalCode) {
                
                helper.showToastMessage('warning', 'Missing!', 'Please fill all Address fields');
                return false;
            }
        }
        
        if (isQuotetoCon) {
            if (!logIssueCommonWrapper || !logIssueCommonWrapper.quoteToContactname) {
                helper.showToastMessage('warning', 'Missing!', 'Please select Quote to contact details ');
                
                return false;
            }
        }
        
        if (isShiptoCon) {
            if (!logIssueCommonWrapper || !logIssueCommonWrapper.shipToContactname
                || !logIssueCommonWrapper.shipToContactPhone
                || !logIssueCommonWrapper.shipToContactEmail) {
                helper.showToastMessage('warning', 'Missing!', 'Please select Ship to contact details');
                
                return false;
            } else if (logIssueCommonWrapper.shipToContactEmail) {
                var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
                if (!logIssueCommonWrapper.shipToContactEmail.match(regExpEmailformat)) {
                    helper.showToastMessage('error', $A.get("$Label.c.Error"), $A.get("$Label.c.Provide_Valid_Email_Address"));
                    return false;
                }
            }
        }
        
        return true;
        
    },
     clearShipToContactSearchedKeyword: function (component) {
        
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
        console.log('before-clearValueFromList-logIssueCommonWrapper', logIssueCommonWrapper);
        if (logIssueCommonWrapper) {
            var partRequestedWrapper = logIssueCommonWrapper;
            console.log('partRequestedWrapper', partRequestedWrapper);
            
            if (partRequestedWrapper) {
                component.set("v.consOpenDropDown", false);
                partRequestedWrapper.shipToContactname = null;
                partRequestedWrapper.shipToContactPhone = null;
                partRequestedWrapper.shipToContactEmail = null;
                console.log('after-clearValueFromList-logIssueCommonWrapper', logIssueCommonWrapper);
                component.set("v.logIssueCommonWrapper", partRequestedWrapper);
            }
        }
    },
     clearQuoteToContactSearchedKeyword: function (component) {
        
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
        console.log('before-clearValueFromList-logIssueCommonWrapper', logIssueCommonWrapper);
        if (logIssueCommonWrapper) {
            var partRequestedWrapper = logIssueCommonWrapper;
            console.log('logIssueCommonWrapper', partRequestedWrapper);
            
            if (partRequestedWrapper) {
                component.set("v.consOpenDropDown", false);
                partRequestedWrapper.quoteToContactname = null;
                
                console.log('after-clearValueFromList-logIssueCommonWrapper', logIssueCommonWrapper);
                component.set("v.logIssueCommonWrapper", partRequestedWrapper);
            }
        }
    },
    searchcontacts: function (component, strSearchKeyword, stroppid, strconid) {
        var helper = this;
        if (strSearchKeyword && strSearchKeyword.length > 2) {
            var serverAction = component.get("c.searchContactRecords");
            if (!serverAction) {
                return;
            }
            serverAction.setParams({
                "strSearchKeyword": strSearchKeyword,
                "strCaseId": stroppid,
                "conid": strconid
            });
            serverAction.setCallback(this, function (response) {
                
                component.set("v.spinner", false);
                
                var state = response.getState();
                console.log('state : ', state);
                if (state === "SUCCESS") {
                    
                    var result = JSON.parse(response.getReturnValue());
                    console.log("searchcontacts", result);
                    console.log("searchcontacts-LogIssueCommonWrapper-", result.listOfContactsSearchedResults);
                    
                    if (result.isSucceeded) {
                        component.set("v.consOpenDropDown", true);
                        console.log("consOpenDropDown", component.get("v.consOpenDropDown"));
                        console.log('listOfContactsSearchedResults===', result.listOfContactsSearchedResults);
                        component.set("v.listOfContatsSearchedResults", result.listOfContactsSearchedResults);
                        console.log('listOfContactsSearchedResults=2==', component.get("v.listOfContactsSearchedResults"));
                    }
                    else {
                        helper.showToastMessage('error', 'Error!', result.message);
                    }
                }
                else {
                    helper.showToastMessage('error', 'Error!', 'Sorry, something went wrong; please contact Admin.');
                }
            });
            
            $A.enqueueAction(serverAction);
        }
    },
    
    handleQContOptionClick: function (component, selectedcontactId, selectedcontactname,
                                      selectedcontactphone, selectedcontactemail) {
        console.log('--entered--');
        console.log('==JSON component=' + component.get("v.logIssueCommonWrapper"));
        console.log('==JSON==' + JSON.stringify(component.get("v.logIssueCommonWrapper")));
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
        console.log('before-handleQContOptionClick-LogIssueCommonWrapper', logIssueCommonWrapper);
        if (logIssueCommonWrapper && selectedcontactId && selectedcontactname) {
            var pmIssueWrapper = logIssueCommonWrapper;
            console.log('pmIssueWrapper', pmIssueWrapper);
            
            if (pmIssueWrapper) {
                component.set("v.consOpenDropDown", false);
                
                pmIssueWrapper.quoteToContactname = selectedcontactname;
                pmIssueWrapper.quoteToContactPhone = selectedcontactphone;
                
                pmIssueWrapper.quoteToContactEmail = selectedcontactemail;
                pmIssueWrapper.quoteToContactid = selectedcontactId;
                
                
                console.log('after-handleQContOptionClick-listOfPMIssueWrappers', pmIssueWrapper);
                component.set("v.logIssueCommonWrapper", pmIssueWrapper);
            }
        }
    },
     handleShipContOptionClick: function (component, selectedcontactId, selectedcontactname,
                                         selectedcontactphone, selectedcontactemail) {
        console.log('--entered--');
        console.log('==JSON component=' + component.get("v.logIssueCommonWrapper"));
        console.log('==JSON==' + JSON.stringify(component.get("v.logIssueCommonWrapper")));
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
        console.log('before-handleQContOptionClick-LogIssueCommonWrapper', logIssueCommonWrapper);
        if (logIssueCommonWrapper && selectedcontactId && selectedcontactname) {
            var pmIssueWrapper = logIssueCommonWrapper;
            console.log('pmIssueWrapper', pmIssueWrapper);
            
            if (pmIssueWrapper) {
                component.set("v.consOpenDropDown", false);
                
                pmIssueWrapper.shipToContactname = selectedcontactname;
                pmIssueWrapper.shipToContactPhone = selectedcontactphone;
                
                pmIssueWrapper.shipToContactEmail = selectedcontactemail;
                pmIssueWrapper.shipToContactid = selectedcontactId;
                
                
                console.log('after-handleQContOptionClick-listOfPMIssueWrappers', pmIssueWrapper);
                component.set("v.logIssueCommonWrapper", pmIssueWrapper);
            }
        }
    },
})