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
    /*doInit: function (component, varissuetype) {

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
                console.log('======109====='+JSON.stringify(result));
                if (result.isSucceeded) {
                    
                    component.set("v.logIssueCommonWrapper", result.logIssueCommonWrapper);
                   	component.set( "v.listOfIssueWrappers", result.logIssueCommonWrapper );
                    component.set("v.logIssueCommonWrapperDupe", result.logIssueCommonWrapper);
                    component.set("v.listOfLogIssueWrappers", []);
                    component.set("v.listOfLogIssueWrappersCSS", result.listOfLogIssueWrappersCSS);
                    component.set("v.listOfFailureModeResults", result.logIssueCommonWrapper.listOfFailureModeResults);
                    component.set("v.lstFmodeData", result.logIssueCommonWrapper.listOfFailureModeResults);
                    component.set("v.recordTypeNameToListOfFailureComponents", result.recordTypeNameToListOfFailureComponents);


                    var successMsgEle = component.find('successMsg_submit');
                    var errorMsgEle = component.find('errorMsg_submit');
                    $A.util.removeClass(successMsgEle, "slds-show");
                    $A.util.addClass(successMsgEle, "slds-hide");
                    $A.util.removeClass(errorMsgEle, "slds-show");
                    $A.util.addClass(errorMsgEle, "slds-hide"); 
                    component.set("v.submitErrorMessage", "");
                    component.set( "v.listOfResponsibleEntities", result.logIssueCommonWrapper.listOfownershippicklist );
                    component.set( "v.listOfReasonForReplacements", result.logIssueCommonWrapper.listOfIGUReplacements );

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
    },*/
    
    
    updateIssue: function (component, event, helper) {
        var wrapData = component.get("v.issueWrapperdata");
        var issueList = [];
        var issueRecdsWrap = wrapData.issuesLst;
        var issuekey=[];
        var recordCommonIssue = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" )));
        
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
                var issueRecVal = issueRecdsWrap[r].issueRec;
                var fieldsMap = issueRecdsWrap[r].updateSfmMap;
                var selectedFM = issueRecdsWrap[r].selectedFailuresNames;
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
                     helper.showToastMessage('error', 'Missing!', 'Please enter Failure Mode details on row '+(Number(r)+1) +' to continue..');
						return;
                    }
                }
            }
               
               
                issueList.push(issueRecdsWrap[r].issueRec);
                issuekey.push(issueRecdsWrap[r].issueRec.Id); 
             }
        }
        var validateissuelist = helper.ValidateIGUrows(component, JSON.parse(JSON.stringify(issueList)));
        
        if (validateissuelist) {
           // console.log('===178==='+JSON.stringify(issueList));
            console.log('===179==='+JSON.stringify(issueRecdsWrap));
            
            component.set("v.spinner", true);
            var issuesare = [];
            issueList.forEach(function (each) {
                if (each.isSelected) {
                    delete each.isSelected;
                    issuesare.push(each);
                }
            });
           return;
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
                    var issueRecds = component.get("v.openShippedStatus");
                    
                    for(var i in issueRecds){
                        for(var r in updatedIssues){
                            if(updatedIssues[r].Id == issueRecds[i].Id){
                                issueRecds[i] = updatedIssues[r];
                            }
                        }
                        
                    }
                    
                    for(var r in issueRecdsWrap){
                        issueRecdsWrap[r].selected = false;
                        for(var i in updatedIssues){
                            
                            if(issueRecdsWrap[r].issueRec.Id == updatedIssues[i].Id){
                                issueRecdsWrap[r].issueRec = updatedIssues[i];
                                
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
                     component.set("v.newIssues",lgCmpIssue);
                    wrapData.issuesLst = issueRecdsWrap;
                    component.set("v.issueWrapperdata",wrapData);
                    component.set("v.openShippedStatus",issueRecds);
                    
                    //var issueslist = response.getReturnValue();
                    //   $A.get('e.force:refreshView').fire();
                    //component.set("v.newIssues", response.getReturnValue());
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
        }else{
            var wrapData = component.get("v.issueWrapperdata");
            component.set("v.issueWrapperdata",wrapData)
            
        }
        
    },
    
    handleSubitandcontinue: function (component, event, numbercode) {
        var helper = this;
        var caseId =  component.get("v.recordId");
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
        component.set("v.logIssueCommonWrapperDupe2", logIssueCommonWrapper);
        var newIssues = JSON.parse(JSON.stringify(component.get("v.newIssues")));
        var wrapData =  component.get("v.issueWrapperdata");
        var issueLst = wrapData.issuesLst;
        var issueRecs = [];
        var issuekey=[];
        
        //BM
        
        if(!logIssueCommonWrapper.Shipping_Street_1) {
			helper.showToastMessage( 'error', 'Error!', 'Please provide Shipping Information.');
			return false;
		}
        
        
        for (var index = 0; index < issueLst.length; index++) {
            //var wrapper = issueLst[index].issueRec;
            if(issueLst[index].selected){
                console.log('===309==='+JSON.stringify(issueLst[index]));
                if(issueLst[index].selectedFailures.length == 0){
                    helper.showToastMessage('Error', 'Missing!', 'Please add Failure mode to continue');
                    return;
                }
				console.log('===338===');                
                var issueRecVal = issueLst[index].issueRec;
                var fieldsMap = issueLst[index].updateSfmMap;
                var selectedFM = issueLst[index].selectedFailuresNames;
                var checkFields = [];
                console.log('===338==='); 
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
                     helper.showToastMessage('error', 'Missing!', 'Please enter Failure Mode details on row '+(Number(index)+1) +' to continue..');
						return;
                    }
                }
            }
                console.log('===338==='); 
                issuekey.push(issueLst[index].issueRec.Id); 
                issueLst[index].issueRec.Defect_Root_Causes__r = undefined;
                issueRecs.push(issueLst[index].issueRec);
                
            }
        }
        wrapData.issuesLst = issueLst;
        console.log('===249===='+JSON.stringify(issueLst));
        component.set("v.issueWrapperdata", wrapData);
        
        var validateissuelist = helper.ValidateIGUrows(component, JSON.parse(JSON.stringify(issueRecs)));
        if(validateissuelist){
            component.set("v.spinner", true);
            
            var arrayMapKeys = [];
            for(var key in issueLst){
                if(issuekey.indexOf(issueLst[key].issueRec.Id) !== -1)
                    arrayMapKeys.push({key: issueLst[key].issueRec.Id, value: issueLst[key].selectedFailures});
            }
            
            //Legacy Opp
        var legacyOpp = component.get('v.logIssueCommonWrapper.recordCase.Opportunity__r.IGU_Pigtail_Style__c');
        console.log('Opp Legacy? ',legacyOpp);
        if(legacyOpp == 'Legacy')
        {
           console.log('in If condition');
           // helper.showToastMessage('Info', 'Legacy Opportunity!', 'Since this is a site with legacy CSS, please create an Issue for any legacy adapter needed and submit for approval');
            var toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                'type': 'Info',
                'title': 'Legacy Opportunity!',
                'message': 'Since this is a site with legacy CSS, please create an Issue for any legacy adapter needed and submit for approval.',
                'duration': 10000
            });
            toastEvent.fire();
        }
            
            var submitrecordsforapproval = component.get("c.submitIssuesForApprovalAndOrder");
            submitrecordsforapproval.setParams({
                "issueRecsstr": JSON.stringify(issueRecs),
                "caseId": caseId,
                "issueLst": issueRecs,
                "selectedModeMap": JSON.stringify(arrayMapKeys),
                "issueCommonHeader": JSON.stringify(logIssueCommonWrapper),
            });
            submitrecordsforapproval.setCallback(this, function (response) {
                var state = response.getState();
                console.log('state : ', state);
                component.set("v.spinner", false);
                if (state === "SUCCESS") {
                    var issueidlist = [];
                    var openIssueRecdsCopy = component.get("v.openShippedStatus");;
                    var openIssueRecds = component.get("v.openShippedStatus");
                    var resposeWrap = response.getReturnValue();
                    var submittesIssLst = resposeWrap.updatedList;
                    var newIssueRecds = component.get("v.newIssues");
                    var newIssueRecdsCopy = component.get("v.newIssues");
                    for(var r in submittesIssLst){
                        issueidlist.push(submittesIssLst[r].Id);
                        for(var wrap in issueLst){
                            issueLst[wrap].selected = false;
                            if(issueLst[wrap].issueRec.Id == submittesIssLst[r].Id){
                                /* if(submittesIssLst[r].Issue_Status__c !== 'Open'){
                                wrapData.issuesLst.splice(wrap, 1);
                            }  */
                                if(submittesIssLst[r].In_Approval__c){
                                    wrapData.issuesLst.splice(wrap, 1);
                                }
                                
                            }
                        }
                        for(var o in openIssueRecds){
                            if(openIssueRecds[o].Id == submittesIssLst[r].Id){
                                /*if(submittesIssLst[r].Id !== 'Open' 
                               || submittesIssLst[r].Id !== 'Order Shipped'){
                                openIssueRecdsCopy.splice(o, 1);
                            }*/
                            if(submittesIssLst[r].In_Approval__c){
                                openIssueRecdsCopy.splice(wrap, 1);
                            }
                        }
                    }
                    
                    for(var p in newIssueRecds){
                        if(newIssueRecds[p].Id == submittesIssLst[r].Id){
                            /*if(submittesIssLst[p].Id !== 'Open' 
                               || submittesIssLst[p].Id !== 'Order Shipped'){
                                newIssueRecdsCopy.splice(p, 1);
                            }*/
                            if(submittesIssLst[r].In_Approval__c){
                                newIssueRecdsCopy.splice(wrap, 1);
                            }
                        }
                    }
                }
                component.set("v.issueWrapperdata",wrapData);
                component.set("v.newIssues",newIssueRecdsCopy);
                component.set("v.openShippedStatus",openIssueRecdsCopy);
                component.find("selectAll").set("v.checked",false);
                
                component.set("v.saveIssues",false);
                if (numbercode == 1) {
                    helper.DisplaysubmittedissueStatus(component, issueidlist, "IGU");
                     helper.showSubmittedIssuesModal(component, helper, issueidlist,1);
                    helper.showToastMessage('success', 'success!', 'Issues Submitted Successfully.');
                    
                } else if (numbercode == 2) {
                    helper.showSubmittedIssuesModal(component, helper, issueidlist,2);
                    component.set("v.closeAndOpenCase",true);
                    
                }
                if(resposeWrap.success === false){
                 //   component.set("v.isOpenSubmitMessage",true);
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
                    
                } /*else if (varfamily == "CSS") {
                    helper.showToastMessage('success', 'success!', 'Issues Submitted Successfully.');
                    currentlist = newIssuescssWithStatus;
                }
                */
                var updatedlist = currentlist.concat(issueidlist);
                console.log('response : ', JSON.stringify(response.getReturnValue()));
                if (varfamily == "IGU") {
                    component.set("v.newIssuesWithStatus", updatedlist);
                    //component.set("v.newIssues", []);
                    // helper.doInit(component, "IGU");
                } /*else if (varfamily == "CSS") {
                    component.set("v.newIssuescssWithStatus", updatedlist);
                    component.set("v.newIssuescss", []);
                    //helper.doInit(component, "CSS");
                    
                }*/
                
                
            }
        });
        $A.enqueueAction(Action);
    },
    
    ValidateIGUrows: function (component, issueList) {
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
            console.log(JSON.stringify(recordIssue));
            
            if (!recordIssue.Quantity__c || isNaN(recordIssue.Quantity__c)) {
                
                helper.showToastMessage('Error', 'Missing!', 'Provide Quantity for row  '+(index + 1));
                return false;
                break;
            } 
            
             
           
            
             else if ( recordIssue.Lite_ID_Mock_ID__c===undefined) {
            helper.showToastMessage('Error', 'Missing!', 'Provide Lite ID Mock Id for row  '+(index + 1));
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
                        helper.showToastMessage('Error', 'Missing!', $A.get("$Label.c.Requested_Delivery_Date_Is_Future_Date"));
                        return false;
                        break;
                    }
                    else if (dateValue == tomorrowDate && isThisPostMeridiem) {
                        helper.showToastMessage('Error', 'Missing!', $A.get("$Label.c.Requested_Delivery_Date_Cannot_Be_Tomorrow_s_Date") );
                        return false;
                        break;
                        
                    }
                }
            }
            
            
        }
        
        return true;
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
    fetchopenissuesdoinitIGU: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var fetchopenissuesAction = component.get("c.fetchopenissuesForIGU");
        component.set("v.selectedIssueType","IGU");
        fetchopenissuesAction.setParams({ "caseid": recordId });
        console.log('@@@@@@@recordId - ', recordId);
        fetchopenissuesAction.setCallback(this, function (response) {
            
            var state = response.getState();
            console.log('fetchopenissuesdoinitIGU-state-', state);
            if (state === "SUCCESS") {
                var responseiss = response.getReturnValue();
                console.log('@@@@@@@@fetchopenissuesdoinitIGU-responseiss-', responseiss);
                component.set("v.newIssues", response.getReturnValue());
                
                
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
               
                helper.openRecordInNewConsoleTab(component, helper, component.get("v.recordId"));
            }
            helper.closeFocusedTab(component);
        }
        else {
           
            var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
            if (logIssueCommonWrapper) {
              
                window.open('/' + component.get("v.recordId"), '_self');
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
                                               listName, listOfAlreadySelectedFailureModes,resonofrep								   
                                              ) {
        $A.createComponent( 'c:FailureModeModalCmp', {
            'recordIndex' : recordIndex,
            'failureComponent' : failureComponent,
            'listName' : listName,
            'resonforreplace': resonofrep,
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
    
    setIGUMakeUpFlags: function (component, event) {
        
        if (event.getSource().get("v.value") == "Lite ID") {
            console.log(event.getSource().get("v.value"));
            component.set("v.showheader", event.getSource().get("v.value"))
        } else {
            console.log(event.getSource().get("v.value"));
            component.set("v.showheader", event.getSource().get("v.value"))
        }
    },
    openAssetLookupModal: function (component, helper, headerText, recordIndex,
                                    searchKeyword, opportunityId, listName, fieldName
                                    
                                   ) {
        $A.createComponent('c:AssetLookupCmp', {
            'headerText': headerText,
            'recordIndex': recordIndex,
            'searchKeyword': searchKeyword,
            'opportunityId': opportunityId,
            'listName': listName,
            'fieldName': fieldName,
            'componentName':component.get("v.componentName")
        },
                           function (modalComponent, status, errorMessage) {
                               
                               if (status === "SUCCESS") {
                                   var showChildModalDiv = component.find('showAssetLookupModal');
                                   if (showChildModalDiv) {
                                       var body = showChildModalDiv.get("v.body");
                                       body.push(modalComponent);
                                       component.find('showAssetLookupModal').set("v.body", body);
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
    handleAssetSelectEvt: function (component, helper, recordIndex, listName, fieldName, recordAsset) {
        if (recordIndex < 0 || !recordAsset) {
            return;
        }
        
        var  wrapData = component.get("v.issueWrapperdata");
        var issuLst = wrapData.issuesLst;
        var selRecrdId = component.get("v.selectedAssestId");
        console.log('====recordAsset===='+JSON.stringify(recordAsset));
        var action = component.get("c.isproductactive");
        var validate;
        action.setParams({product:recordAsset.Name});
        action.setCallback(this,function(response){
            validate = response.getReturnValue();
            var state = response.getState();
            var prodname;
            if(state = "SUCCESS"){
                for(var r in issuLst){
                    if(issuLst[r].issueRec.Id === selRecrdId){
                        issuLst[r].issueRec.Lite_ID_Mock_ID__c = recordAsset.SerialNumber;
                        issuLst[r].issueRec.Asset__c = recordAsset.Id;
                        issuLst[r].issueRec.Mark_ID__c = recordAsset.Mark_Id__c;
                        issuLst[r].issueRec.Existing_Makeup__c = recordAsset.Product2Id;
                        issuLst[r].issueRec.Product__c = recordAsset.Product2Id;
                        issuLst[r].prodDescription = recordAsset.Product2.Name;
                        issuLst[r].issueRec.Height_in__c = String(recordAsset.Lite_Height__c); // Added BM
                        issuLst[r].issueRec.Base_in__c = String(recordAsset.Lite_Width__c); // Added BM
                        
                        if(validate=="true"){
                            issuLst[r].issueRec.Want_to_Order_Existing_Makeup__c = "Yes";
                        }
                        if(validate=="false"){
                            issuLst[r].issueRec.Want_to_Order_Existing_Makeup__c = "No";
                        }
                        
                    }
                }
                wrapData.issuesLst = issuLst;
                component.set("v.issueWrapperdata",wrapData);
            }
        });      
        $A.enqueueAction(action);
        
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
            'componentName':component.get("v.componentName")
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
        console.log("===678=="+JSON.stringify(recordProductWrapper));
        
        var  wrapData = component.get("v.issueWrapperdata");
        var issuLst = wrapData.issuesLst;
        var selRecrdId = component.get("v.selectedAssestId");
        
        issuLst[recordIndex].newMarkUp = recordProductWrapper.recordProduct.Id;
        issuLst[recordIndex].newMakeUpname = recordProductWrapper.recordProduct.Name;
        issuLst[recordIndex].newMakeUpProduct_SKU = recordProductWrapper.recordProduct.Product_SKU__c;
        issuLst[recordIndex].newMakeUpProductCode = recordProductWrapper.recordProduct.ProductCode;
      //  issuLst[recordIndex].issueRec.Existing_Makeup__c = recordProductWrapper.recordProduct.Id;
        issuLst[recordIndex].issueRec.Product__c = recordProductWrapper.recordProduct.Id;
        issuLst[recordIndex].issueRec.Product_SKU__c = recordProductWrapper.recordProduct.Product_SKU__c;
        issuLst[recordIndex].issueRec.Product_Code__c = recordProductWrapper.recordProduct.ProductCode;
        wrapData.issuesLst = issuLst;
        component.set("v.issueWrapperdata",wrapData);
        
    },
    
      showSubmittedIssuesModal : function( component, helper, listOfIssues,submitedtype ) {
		if( !listOfIssues || listOfIssues.length == 0 ) {
			return listOfIssues;
		}
		
		$A.createComponent( 'c:LogIssueApprovalIssue', {
            'listOfSubmittedIssues' : listOfIssues,
            'recordtype' :'IGU',
            'issueWrapperdata': component.get("v.issueWrapperdata"),
            'componentName':component.get("v.componentName"),'submitedtype':submitedtype
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