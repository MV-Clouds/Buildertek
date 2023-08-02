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
        //component.set("v.newIssuescss",[]);
        // component.set("v.newIssues",[]);
        // helper.showToastMessage( 'error', 'Error!', 'Sorry, Case Id is not found. Please try again.' );       
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
                console.log('doinit isSucceeded :===111=== '+JSON.stringify(result));
                if (result.isSucceeded) {
                    /* var FailureMode=[];
					  console.log('FailureMode', ( FailureMode instanceof Array ) );
					 var listOfFailureMode=JSON.stringify( result.logIssueCommonWrapper.listOfFailureModeResults );
					 console.log('listOfFailureMode', ( listOfFailureMode instanceof Array ) );
					 FailureMode.push(listOfFailureMode);
					 console.log('FailureMode', FailureMode );
					 FailureMode.sort(function(a, b){
						  const bandA = a.Name.toUpperCase();
							  const bandB = b.Name.toUpperCase();
						let comparison = 0;
						   if (bandA > bandB) {
							 comparison = 1;
						   } else if (bandA < bandB) {
							 comparison = -1;
						   }
						   return comparison;
					 } );
					 console.log('listOfFailureMode sort', FailureMode );*/
                    component.set("v.opportunityId", result.logIssueCommonWrapper.recordCase.Opportunity__c);
                    component.set("v.priceBookId", result.logIssueCommonWrapper.recordCase.Opportunity__r.Pricebook2Id);
                    component.set("v.currencyISOcode", result.logIssueCommonWrapper.recordCase.Opportunity__r.CurrencyIsoCode);
                    component.set("v.sfmWrapMap",result.listOfLogIssueWrappersCSS[0].sfmMap);
                    
                    component.set("v.logIssueCommonWrapper", result.logIssueCommonWrapper);
                    component.set("v.logIssueCommonWrapperDupe", result.logIssueCommonWrapper);
                    component.set("v.listOfLogIssueWrappers", []);
                    component.set("v.listOfLogIssueWrappersCSS", result.listOfLogIssueWrappersCSS);
                    component.set("v.listOfFailureModeResults", result.logIssueCommonWrapper.listOfFailureModeResults);
                    component.set("v.lstFmodeData", result.logIssueCommonWrapper.listOfFailureModeResults);
                    component.set("v.recordTypeNameToListOfFailureComponents", result.recordTypeNameToListOfFailureComponents);
                    if (varissuetype == "CSS") {
                        console.log('varissuetype', varissuetype);
                        var logIssueCommonWrapperDupe2 = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapperDupe2")));
                        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
                        /* var commonWrapper=logIssueCommonWrapper;
						 commonWrapper.selectedIssueType='Control Hardware';
						 component.set( "v.logIssueCommonWrapper", commonWrapper );*/
                        component.set("v.logIssueCommonWrapper", logIssueCommonWrapperDupe2);
                    } else if (varissuetype == "IGU") {
                        console.log('varissuetype', varissuetype);
                        var logIssueCommonWrapperDupe2 = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapperDupe2")));
                        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
                        /* var igucommonWrapper=logIssueCommonWrapper;
						 igucommonWrapper.selectedIssueType='IGU';
						 component.set( "v.logIssueCommonWrapper", igucommonWrapper );*/
                        component.set("v.logIssueCommonWrapper", logIssueCommonWrapperDupe2);
                    }
                    
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
    
    setIGUMakeUpFlags: function (component, event) {
        
        if (event.getSource().get("v.value") == "Lite ID") {
            console.log(event.getSource().get("v.value"));
            component.set("v.showheader", event.getSource().get("v.value"))
        } else {
            console.log(event.getSource().get("v.value"));
            component.set("v.showheader", event.getSource().get("v.value"))
        }
    },
    clearProductSearchedKeyword: function (component, index) {
        
        var listOfLogIssueWrappers = JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappers")));
        console.log('before-clearValueFromList-listOfLogIssueWrappers', listOfLogIssueWrappers);
        if (listOfLogIssueWrappers && listOfLogIssueWrappers.length > index) {
            var partRequestedWrapper = listOfLogIssueWrappers[index];
            console.log('partRequestedWrapper', partRequestedWrapper);
            
            if (partRequestedWrapper) {
                component.set("v.assetOpenDropDown", false);
                partRequestedWrapper.newMakeUpname = "";
                partRequestedWrapper.newMakeUpID = "";
                console.log('after-clearValueFromList-listOfLogIssueWrappers', listOfLogIssueWrappers);
                component.set("v.listOfLogIssueWrappers", listOfLogIssueWrappers);
            }
        }
    },
    clearProductSearchedKeywordcss: function (component, index) {
        
        var listOfLogIssueWrappersCSS = JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappersCSS")));
        console.log('before-clearValueFromList-listOfLogIssueWrappersCSS', listOfLogIssueWrappersCSS);
        if (listOfLogIssueWrappersCSS && listOfLogIssueWrappersCSS.length > index) {
            var partRequestedWrapper = listOfLogIssueWrappersCSS[index];
            console.log('partRequestedWrapper', partRequestedWrapper);
            
            if (partRequestedWrapper) {
                component.set("v.prodopenDropDowncss", false);
                partRequestedWrapper.productnamecss = "";
                partRequestedWrapper.productidcss = "";
                partRequestedWrapper.cssProdListPrice = "";
                console.log('after-clearValueFromList-listOfLogIssueWrappersCSS', listOfLogIssueWrappersCSS);
                component.set("v.listOfLogIssueWrappersCSS", listOfLogIssueWrappersCSS);
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
    clearAssetSearchedKeyword: function (component) {
        
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
        console.log('before-clearValueFromList-logIssueCommonWrapper', logIssueCommonWrapper);
        if (logIssueCommonWrapper) {
            var partRequestedWrapper = logIssueCommonWrapper;
            console.log('partRequestedWrapper', partRequestedWrapper);
            
            if (partRequestedWrapper) {
                component.set("v.assetOpenDropDown", false);
                partRequestedWrapper.common_Liteid = "";
                partRequestedWrapper.common_Lite_Mockid = "";
                console.log('after-clearValueFromList-logIssueCommonWrapper', logIssueCommonWrapper);
                component.set("v.logIssueCommonWrapper", partRequestedWrapper);
            }
        }
    },
    insertIssue: function (component, event, helper) {
        
        var issueList = JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappers")));
        var obj = { "listOfAssetSearchedResults": JSON.parse(JSON.stringify(component.get("v.listOfAssetSearchedResults"))), "logIssueCommonWrapper": JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper"))), "listOfLogIssueWrappers": JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappers"))) };
        
        var logIssWr = obj.listOfLogIssueWrappers;
        var sfmMapWr = component.get("v.sfmWrapMap");
        for(var r in logIssWr){
            var logi = logIssWr[r];
            var selectedFM = logIssWr[r].namesOfSFM;
            var checkFields = [];
            for(var p in selectedFM){
                var fieldsVal = sfmMapWr[selectedFM[p]];
                for(var s in fieldsVal){
                    checkFields.push(fieldsVal[s]);
                }
                
            }
            
            if(checkFields.length>0){
                for(var k in checkFields){
                    if( (logi[checkFields[k]] == undefined)|| (logi[checkFields[k]] == '')
                       || (logi[checkFields[k]] == null)){
                     helper.showToastMessage('error', 'Missing!', 'Please enter Failure Mode details on row '+(Number(r)+1) +' to continue..');
						return;
                    }
                }
            }
        }
        console.log('====276==='+JSON.stringify(component.get("v.sfmWrapMap")));
        var allValid = helper.validateFields(component);
        var validateissuelist = helper.ValidateIGUrows(component, issueList);
        console.log('allValid:' + allValid);
        console.log('validateissuelist:' + validateissuelist);
        
        if (allValid && validateissuelist) {
            component.set("v.spinner", true);
            var createIssueAction = component.get("c.createIssue");
            createIssueAction.setParams({
                "issueWrapperObjStr": JSON.stringify(obj)
            });
            createIssueAction.setCallback(this, function (response) {
                
                var state = response.getState();
                console.log(state);
                //component.set("v.spinner", false);
                if (state === "SUCCESS") {
                    
                    component.set("v.isSuccess", true);
                    var issueslist = response.getReturnValue();
                    console.log('====289==='+JSON.stringify(issueslist));
                    //component.set("v.newIssues", response.getReturnValue());
                    component.set("v.listOfLogIssueWrappers", []);
                    //helper.showToastMessage( 'Info', 'Info!', 'Box Folder Updating');
                    /*window.setTimeout(
                        $A.getCallback(function () {*/
                            helper.fetchlatestRecsforBox(component, issueslist, 'IGU')
                       /* }), 5000
                    );*/
                    //setTimeout(helper.fetchlatestRecsforBox(component,issueslist), 3000)
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
    fetchlatestRecsforBox: function (component, newiisues, issuetype) {
        var helper = this;
        console.log('--newiisues--', newiisues);
        console.log('--issuetype--', issuetype);
        var obj = JSON.parse(JSON.stringify(newiisues));
        console.log('--fetchlatestRecs--', obj);
        //component.set("v.spinner", true);
        console.log('--fetchlatestRecs stringify--', JSON.stringify(obj));
        var fetchlatestRecsforBoxAction = component.get("c.fetchlatestRecsfromissue");
        fetchlatestRecsforBoxAction.setParams({
            "issueliststring": JSON.stringify(obj)
        });
        fetchlatestRecsforBoxAction.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state :', state);
            component.set("v.spinner", false);
            if (state === "SUCCESS") {
                if (issuetype === "IGU") {
                    var responseWrapper = response.getReturnValue();
                    var issueRecdsWrap = responseWrapper.issuesLst;
                    var issueRecds = [];
                    
                    var wrapperdata = component.get("v.issueWrapperdata");
                    var logWrapper = component.get("v.logIssueCommonWrapper");
                    wrapperdata.caseRec = logWrapper.recordCase;
                    var wrapIssueLst = wrapperdata.issuesLst;
                    for(var r in issueRecdsWrap){
                        wrapIssueLst.push(issueRecdsWrap[r]);
                        issueRecds.push(issueRecdsWrap[r].issueRec)
                    }
                    console.log('====376===='+wrapIssueLst);
                    wrapperdata.issuesLst = wrapIssueLst;
                    component.set("v.issueWrapperdata",wrapperdata);
                    var newIssues = JSON.parse(JSON.stringify(component.get("v.newIssues")));
                    var updatednewIssueslist = newIssues.concat(issueRecds);
                    var issueRec = [];
                    for(var r in updatednewIssueslist){
                        if(updatednewIssueslist[r].RecordType.Name === 'IGU (Halos, IGU Defects)' 
                           && ((updatednewIssueslist[r].Issue_Status__c === 'Open')
                               || (updatednewIssueslist[r].Issue_Status__c === 'Order Shipped') || updatednewIssueslist[r].Issue_Status__c ==='Replacement Rejected')){
                            issueRec.push(updatednewIssueslist[r]);
                        }
                    }
                    component.set("v.openShippedStatus", issueRec);
                    component.set("v.newIssues", updatednewIssueslist);
                    helper.showToastMessage('success', 'Success!', 'Issues have been saved successfully');
                }
                
                if (issuetype === "CSS") {
                    var responseWrapper = response.getReturnValue();
                    var issueRecdsWrap = responseWrapper.chwIssueLst;
                    var issueRecds = [];
                    var wrapperdata = component.get("v.chwIssueWrapperdata");
                    var wrapIssueLst = wrapperdata.chwIssueLst;
                    
                    for(var r in issueRecdsWrap){
                        
                        wrapIssueLst.push(issueRecdsWrap[r]);
                        issueRecds.push(issueRecdsWrap[r].issueRec)
                    }
                   
                    var newIssues = JSON.parse(JSON.stringify(component.get("v.newIssuescss")));
                    var updatednewIssueslist = newIssues.concat(issueRecds);
                    var issueRec = [];
                    //var chwIssueRec=[];
                    ////View Display and View Sense 3-Mar
                    for(var r in updatednewIssueslist){
                        if(((updatednewIssueslist[r].RecordType.Name === 'Cable') || (updatednewIssueslist[r].RecordType.Name === 'Control Panel') 
                            || (updatednewIssueslist[r].RecordType.Name === 'Controller & User Interface') || (updatednewIssueslist[r].RecordType.Name === 'Network') 
                            || (updatednewIssueslist[r].RecordType.Name === 'Sensor') || (updatednewIssueslist[r].RecordType.Name === 'RTLS') || (updatednewIssueslist[r].RecordType.Name === 'Mounting Hardware')) 
                           && ((updatednewIssueslist[r].Issue_Status__c === 'Open')
                               || (updatednewIssueslist[r].Issue_Status__c === 'Order Shipped') || (updatednewIssueslist[r].Issue_Status__c === 'Order Shipped')
                               || (updatednewIssueslist[r].Issue_Status__c === 'Order Processing'))){
                            //chwIssueRec.push(updatednewIssueslist[r]);
                            issueRec.push(updatednewIssueslist[r]);
                        }
                        
                    }
                    component.set("v.newIssuescss", issueRec);
                    component.set("v.openCHWShippedStatus", issueRec);
                    wrapperdata.chwIssueLst = wrapIssueLst;
                    component.set("v.chwIssueWrapperdata",wrapperdata);
                    helper.showToastMessage('success', 'Success!', 'Issues have been saved successfully');
                    /*var issueidlist = JSON.parse(JSON.stringify(component.get("v.newIssuescss")));
					console.log('CSS--', issueidlist);
					var currentlist = response.getReturnValue();
					var updatedlist = currentlist.concat(issueidlist);
					console.log('CSS-updatedlist-', updatedlist);
					component.set("v.newIssuescss", updatedlist);*/
                    //helper.doInit(component, "CSS");
                }
                
            }
        });
        $A.enqueueAction(fetchlatestRecsforBoxAction);
    },
    insertcssIssue: function (component, event, helper) {
        console.log('-insertcssIssue-listOfLogIssueWrappersCSS--', JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappersCSS"))));
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
        component.set("v.logIssueCommonWrapperDupe2", logIssueCommonWrapper);
        console.log('--logIssueCommonWrapperDupe2--', JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapperDupe2"))));
        
        var issueList = JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappersCSS")));
        var obj = { "logIssueCommonWrapper": JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper"))), "listOfLogIssueWrappersCSS": JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappersCSS"))) };
        console.log('==obj===' + JSON.stringify(obj));
        var allValid = helper.validateFields(component);
        var validateissuelist = helper.ValidateCHrows(component, issueList);
        console.log('allValid:' + allValid);
        console.log('validateissuelist:' + validateissuelist);
        if (allValid && validateissuelist) {
            component.set("v.spinner", true);
            var createIssueAction = component.get("c.createcssIssue");
            createIssueAction.setParams({
                "issueWrapperObjStr": JSON.stringify(obj)
            });
            createIssueAction.setCallback(this, function (response) {
                
                var state = response.getState();
                console.log(state);
                // component.set("v.spinner", false);
                if (state === "SUCCESS") {
                    
                    component.set("v.submitErrorMessage", "");
                    
                    var listOfLogIssueWrappersCSS = JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappersCSS")));
                    var obj = {};
                    obj["Lite_Mockid"] = "";
                    
                    obj["Liteid"] = "";
                    obj["Mockid"] = "";
                    obj["markID"] = "";
                    obj["prodQty"] = "";
                    obj["cssProdListPrice"] = "";
                    obj["reason_replacement"] = "";
                    obj["sel_Resp_Entity"] = "";
                    obj["recordTypeId"] = "";
                    obj["failureComponent"] = "";
                    obj["existingMakeUpID"] = "";
                    obj["existingMakeUpDesc"] = "";
                    obj["OrderExtMakeup"] = "";
                    obj["height"] = "";
                    obj["base"] = "";
                    obj["shape"] = "";
                    obj["newMakeUpID"] = "";
                    obj["newMakeUpname"] = "";
                    obj["productidcss"] = "";
                    obj["productnamecss"] = "";
                    obj["showliteid"] = false;
                    obj["listOfSelectedFailureModes"] = [];
                    obj["rmaIs"] =false;
                    listOfLogIssueWrappersCSS = [];
                    listOfLogIssueWrappersCSS.push(obj);
                    component.set("v.totalIssuescss", listOfLogIssueWrappersCSS.length);
                    component.set("v.listOfLogIssueWrappersCSS", listOfLogIssueWrappersCSS);
                    // helper.showToastMessage( 'Info', 'Info!', 'Box Folder Updating');
                    var issuelist = response.getReturnValue();
                    //window.setTimeout(
                        //$A.getCallback(function () {
                            helper.fetchlatestRecsforBox(component, issuelist, 'CSS')
                       // }), 5000
                    //);
                    //this.getCSSRecTypes( component ); 
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
    searchAssets: function (component, strSearchKeyword, opportunityid) {
        
        var helper = this;
        if (strSearchKeyword && strSearchKeyword.length > 2) {
            
            var serverAction = component.get("c.searchAssetRecords");
            if (!serverAction) {
                return;
            }
            component.set("v.spinner", true);
            
            serverAction.setParams({
                "strSearchKeyword": strSearchKeyword,
                "opportunityid": opportunityid
            });
            serverAction.setCallback(this, function (response) {
                
                component.set("v.spinner", false);
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    var result = JSON.parse(response.getReturnValue());
                    console.log("searchAssets", result);
                    console.log("searchAssets-LogIssueCommonWrapper-", result.listOfAssetSearchedResults);
                    
                    if (result.isSucceeded) {
                        component.set("v.assetOpenDropDown", true);
                        console.log("assetOpenDropDown", component.get("v.assetOpenDropDown"));
                        console.log('listOfAssetSearchedResults===', result.listOfAssetSearchedResults);
                        component.set("v.listOfAssetSearchedResults", result.listOfAssetSearchedResults);
                        console.log('listOfAssetSearchedResults=2==', component.get("v.listOfAssetSearchedResults"));
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
    handleAssetOptionClick: function (component, selectedAssetId,
                                      selectedAssetSerialNumber, selectedAssetLiteHeight,
                                      selectedAssetLiteWidth, selectedAssetShape,
                                      selectedExistingMakeUpId, selectedExistingMakeUpName
                                     ) {
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
        console.log('before-handleAssetOptionClick-logIssueCommonWrapper', logIssueCommonWrapper);
        if (logIssueCommonWrapper && selectedAssetId && selectedAssetSerialNumber) {
            var pmIssueWrapper = logIssueCommonWrapper;
            console.log('pmIssueWrapper', pmIssueWrapper);
            
            if (pmIssueWrapper) {
                component.set("v.assetOpenDropDown", false);
                
                pmIssueWrapper.common_Liteid = selectedAssetSerialNumber;
                pmIssueWrapper.common_height = selectedAssetLiteHeight;
                
                pmIssueWrapper.common_base = selectedAssetLiteWidth;
                pmIssueWrapper.common_shape = selectedAssetShape;
                
                pmIssueWrapper.common_existingMakeUpID = selectedExistingMakeUpId;
                pmIssueWrapper.common_existingMakeUpDesc = selectedExistingMakeUpName;
                
                //mIssueWrapper.OrderExtMakeup='Yes';
                
                
                console.log('after-handleAssetOptionClick-listOfPMIssueWrappers', pmIssueWrapper);
                component.set("v.logIssueCommonWrapper", pmIssueWrapper);
            }
        }
    },
    handleAssetSelectEvt: function (component, helper, recordIndex, listName, fieldName, recordAsset) {
        
        if (recordIndex < 0 || !recordAsset) {
            return;
        }
        
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
        console.log('handleAssetSelectEvt-logIssueCommonWrapper==650==='+JSON.stringify(logIssueCommonWrapper));
        var pmIssueWrapper = logIssueCommonWrapper;
        
        pmIssueWrapper.common_Liteid = recordAsset.SerialNumber;
        //pmIssueWrapper.common_height = recordAsset.H1__c;
        pmIssueWrapper.common_Mockid = recordAsset.Mark_Id__c;
        pmIssueWrapper.common_lite_height = recordAsset.Lite_Height__c;
        pmIssueWrapper.common_lite_width = recordAsset.Lite_Width__c;
        //pmIssueWrapper.common_base = recordAsset.W1__c;
        pmIssueWrapper.common_h1_B1 = recordAsset.H1_B1_in__c;
        pmIssueWrapper.common_Assetid = recordAsset.Id;
        pmIssueWrapper.common_existingMakeUpID = recordAsset.Product2Id;
        pmIssueWrapper.common_existingMakeUpDesc = recordAsset.Product2.Name;
        pmIssueWrapper.common_shape = recordAsset.AssetShape__c;
        /*var assetToIssueShape = JSON.parse( JSON.stringify( component.get( "v.assetToIssueShape" ) ) );
		if( assetToIssueShape ) {
			pmIssueWrapper.common_shape = assetToIssueShape[ recordAsset.Shape__c ];
		}*/
        
        /*recordIssueWrapper.recordIssue.Lite_ID_Mock_ID__c = recordAsset.SerialNumber;
		recordIssueWrapper.recordIssue.Existing_Makeup__c = recordAsset.Product2Id;
		recordIssueWrapper.recordIssue.H1__c = recordAsset.H1__c;
		recordIssueWrapper.recordIssue.W1__c = recordAsset.W1__c;
		recordIssueWrapper.recordIssue.H1_B1_in__c = recordAsset.H1_B1_in__c;
		recordIssueWrapper.recordIssue.Shape__c = recordAsset.Shape__c;*/
        
        component.set("v.logIssueCommonWrapper", pmIssueWrapper);
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
    getFailureComps: function (component, event, index) {
        console.log('--index--' + index);
        var listOfLogIssueWrappersCSS = component.get("v.listOfLogIssueWrappersCSS");
        for(var r in listOfLogIssueWrappersCSS){
            if(listOfLogIssueWrappersCSS[r].prodQty === null || listOfLogIssueWrappersCSS[r].prodQty === ''
               || listOfLogIssueWrappersCSS[r].prodQty === undefined){
                listOfLogIssueWrappersCSS[r].prodQty = 0;
            }
            
        }
        console.log('--listOfLogIssueWrappersCSS--' + JSON.stringify(listOfLogIssueWrappersCSS));
        // console.log('--stringtoparse--'+JSON.parse(stringtoparse));
        var getFailureComponentsAction = component.get("c.getFailureComponents");
        
        
        getFailureComponentsAction.setParams({
            "issueWrapperObjStr": JSON.stringify(listOfLogIssueWrappersCSS)
        });
        getFailureComponentsAction.setCallback(this, function (response) {
            var state = response.getState();
            
            console.log('state:' + state);
            if (state === "SUCCESS") {
                
                var stringtoparse = listOfLogIssueWrappersCSS[index];
                var result = JSON.parse(response.getReturnValue());
                console.log('Success Get Failure Modes', result);
                console.log('Success Get Failure Modes', result[index].failureComponentOpts);
                stringtoparse.failureComponentOpts = result[index].failureComponentOpts;
                stringtoparse.recordTypeId = result[index].recordTypeId;
                listOfLogIssueWrappersCSS[index] = stringtoparse;
                console.log('Success Get Failure Modes after', listOfLogIssueWrappersCSS);
                //component.set("v.listOfLogIssueWrappersCSS",response.getReturnValue());
                component.set("v.listOfLogIssueWrappersCSS", listOfLogIssueWrappersCSS);
                
            } else {
                console.log('Error Get Failure Components');
                
            }
        });
        $A.enqueueAction(getFailureComponentsAction);
        
    },
    searchProducts: function (component, strSearchKeyword) {
        
        var helper = this;
        if (strSearchKeyword && strSearchKeyword.length > 2) {
            
            var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
            console.log('searchProducts-logIssueCommonWrapper', logIssueCommonWrapper);
            
            if (!logIssueCommonWrapper || !logIssueCommonWrapper.recordCase.Opportunity__c || !logIssueCommonWrapper.recordCase.Opportunity__r.Pricebook2Id) {
                helper.showToastMessage('error', 'Opportunity Missing', 'This work order either does not have Opportunity or Pricebook selected');
                return;
            }
            var family = logIssueCommonWrapper.selectedIssueType;
            var strOpportunityPricebook2Id = logIssueCommonWrapper.recordCase.Opportunity__r.Pricebook2Id;
            console.log('strOpportunityPricebook2Id', strOpportunityPricebook2Id);
            
            var serverAction = component.get("c.searchProductRecords");
            if (!serverAction) {
                return;
            }
            component.set("v.spinner", true);
            
            serverAction.setParams({
                "strSearchKeyword": strSearchKeyword,
                "strOpportunityPricebook2Id": strOpportunityPricebook2Id,
                "pfamily": family
            });
            serverAction.setCallback(this, function (response) {
                
                component.set("v.spinner", false);
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    var result = JSON.parse(response.getReturnValue());
                    console.log("searchRecords", result);
                    
                    if (result.isSucceeded) {
                        component.set("v.prodopenDropDown", true);
                        console.log("prodopenDropDown", component.get("v.prodopenDropDown"));
                        component.set("v.listOfSearchedResults", result.listOfprodSearchedResults);
                        console.log('get', component.get("v.listOfSearchedResults"));
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
    searchProductscss: function (component, strSearchKeyword) {
        
        var helper = this;
        if (strSearchKeyword && strSearchKeyword.length > 2) {
            
            var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
            console.log('searchProductscss-logIssueCommonWrapper', logIssueCommonWrapper);
            
            if (!logIssueCommonWrapper || !logIssueCommonWrapper.recordCase.Opportunity__c || !logIssueCommonWrapper.recordCase.Opportunity__r.Pricebook2Id) {
                helper.showToastMessage('error', 'Opportunity Missing', 'This work order either does not have Opportunity or Pricebook selected');
                return;
            }
            var family = 'CSS';
            var strOpportunityPricebook2Id = logIssueCommonWrapper.recordCase.Opportunity__r.Pricebook2Id;
            console.log('strOpportunityPricebook2Id', strOpportunityPricebook2Id);
            
            var serverAction = component.get("c.searchProductRecords");
            if (!serverAction) {
                return;
            }
            component.set("v.spinner", true);
            
            serverAction.setParams({
                "strSearchKeyword": strSearchKeyword,
                "strOpportunityPricebook2Id": strOpportunityPricebook2Id,
                "pfamily": family
            });
            serverAction.setCallback(this, function (response) {
                
                component.set("v.spinner", false);
                
                var state = response.getState();
                if (state === "SUCCESS") {
                    
                    var result = JSON.parse(response.getReturnValue());
                    console.log("searchRecords", result);
                    
                    if (result.isSucceeded) {
                        component.set("v.prodopenDropDowncss", true);
                        console.log("prodopenDropDowncss", component.get("v.prodopenDropDowncss"));
                        component.set("v.listOfSearchedResults", result.listOfprodSearchedResults);
                        console.log('get', component.get("v.listOfSearchedResults"));
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
    handleProductOptionClick: function (component, currentRowIndex, selectedId, selectedValue, selectedListPrice) {
        
        if (!selectedListPrice) {
            selectedListPrice = 0.00;
        }
        
        var listOfLogIssueWrappers = JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappers")));
        console.log('before-handleOptionClick-listOfLogIssueWrappers', listOfLogIssueWrappers);
        if (listOfLogIssueWrappers && listOfLogIssueWrappers.length > currentRowIndex && selectedId && selectedValue) {
            var partRequestedWrapper = listOfLogIssueWrappers[currentRowIndex];
            console.log('partRequestedWrapper', partRequestedWrapper);
            
            if (partRequestedWrapper) {
                component.set("v.prodopenDropDown", false);
                partRequestedWrapper.newMakeUpID = selectedId;
                partRequestedWrapper.newMakeUpname = selectedValue;
                partRequestedWrapper.cssProdListPrice = selectedListPrice;
                console.log('after-handleOptionClick-listOfPartRequestedWrappers', listOfLogIssueWrappers);
                component.set("v.listOfLogIssueWrappers", listOfLogIssueWrappers);
            }
        }
    },
    handleProductOptionClickcss: function (component, currentRowIndex, selectedId, selectedValue, selectedListPrice) {
        
        if (!selectedListPrice) {
            selectedListPrice = 0.00;
        }
        //var listprice=selectedListPrice.toFixed(2);
        var listOfLogIssueWrappersCSS = JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappersCSS")));
        console.log('before-handleOptionClick-listOfLogIssueWrappersCSS', listOfLogIssueWrappersCSS);
        if (listOfLogIssueWrappersCSS && listOfLogIssueWrappersCSS.length > currentRowIndex && selectedId && selectedValue) {
            var partRequestedWrapper = listOfLogIssueWrappersCSS[currentRowIndex];
            console.log('partRequestedWrapper', partRequestedWrapper);
            
            if (partRequestedWrapper) {
                component.set("v.prodopenDropDowncss", false);
                partRequestedWrapper.productidcss = selectedId;
                partRequestedWrapper.productnamecss = selectedValue;
                partRequestedWrapper.cssProdListPrice = selectedListPrice;
                console.log('after-handleOptionClick-listOfPartRequestedWrappers', listOfLogIssueWrappersCSS);
                component.set("v.listOfLogIssueWrappersCSS", listOfLogIssueWrappersCSS);
            }
        }
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
    validateFields: function (component) {
        var helper = this;
        
        component.set("v.submitErrorMessage", '');
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
        var listOfLogIssueWrappers = JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappers")));
        if (!logIssueCommonWrapper.quoteToContactname) {
            helper.showToastMessage('warning', 'Missing!', 'Please select Quote to Contact details');
            
            return false;
        } else if (!logIssueCommonWrapper.shipToContactname || !logIssueCommonWrapper.shipToContactPhone
                   || !logIssueCommonWrapper.shipToContactEmail) {
            helper.showToastMessage('warning', 'Missing!', 'Please Fill Ship to Contact details');
            
            return false;
        } else if (!logIssueCommonWrapper || !logIssueCommonWrapper.Shipping_Street_1 ||
                   !logIssueCommonWrapper.Shipping_City || !logIssueCommonWrapper.Shipping_State_Province
                   || !logIssueCommonWrapper.Shipping_Country || !logIssueCommonWrapper.Shipping_Postal_Code) {
            
            helper.showToastMessage('warning', 'Missing!', 'Please Fill Shipping Information details');
            return false;
        }
        return true;
    },
    handleSubitandcontinue: function (component, event, numbercode) {
        var helper = this;
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
      	console.log('****IssueSubmitFromLog*** ',logIssueCommonWrapper);
        component.set("v.logIssueCommonWrapperDupe2", logIssueCommonWrapper);
        var newIssues = JSON.parse(JSON.stringify(component.get("v.newIssues")));
        for (var index = 0; index < newIssues.length; index++) {
            var wrapper = newIssues[index];
            
            wrapper.Defect_Root_Causes__r = undefined;
            
            
        }
        component.set("v.newIssues", newIssues);
        var strcaseid = logIssueCommonWrapper.recordCase.Id;
        console.log('newIssues===', newIssues);
        console.log('strcaseid===', strcaseid);
        component.set("v.spinner", true);
        
        //Legacy Opp
        var legacyOpp = component.get('v.logIssueCommonWrapper.recordCase.Opportunity__r.IGU_Pigtail_Style__c');
        console.log('Opp Legacy? ',legacyOpp);
        if(legacyOpp == 'Legacy')
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
        
        var submitrecordsforapproval = component.get("c.submitIssuesForApprovalAndOrder2");
        submitrecordsforapproval.setParams({
            "issueRecsstr": JSON.stringify(newIssues),
            "caseId": strcaseid,
            "isSetIGU": true
        });
        submitrecordsforapproval.setCallback(this, function (response) {
            var state = response.getState();
            console.log('state : ', state);
            component.set("v.spinner", false);
            if (state === "SUCCESS") {
                var resposeWrap = response.getReturnValue();
                var issueidlist = resposeWrap.updatedList;
                
                var issIDs = [];
                for(var r in issueidlist){
                    issIDs.push(issueidlist[r].Id);
                }
                if (numbercode == 1) {
                    helper.showSubmittedIssuesModal(component, helper, issIDs,1);
                    helper.DisplaysubmittedissueStatus(component, issIDs, "IGU", resposeWrap.success);
                } else if (numbercode == 2) {
                    component.set("v.closeAndOpenCase",true);
                      helper.showSubmittedIssuesModal(component, helper, issIDs,2);
                  
                    helper.DisplaysubmittedissueStatus(component, issIDs, "IGU", resposeWrap.success);
                
                  //  helper.cancel(component, helper);
                }
                if(resposeWrap.success === false){
               //     component.set("v.isOpenSubmitMessage",true);
                }
                
            }
            
        });
        $A.enqueueAction(submitrecordsforapproval);
    },
    handleSubitandcontinuecss: function (component, event, numbercode) {
        var helper = this;
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
      
        component.set("v.logIssueCommonWrapperDupe2", logIssueCommonWrapper);
        var newIssuescss = JSON.parse(JSON.stringify(component.get("v.newIssuescss")));
        var strcaseid = logIssueCommonWrapper.recordCase.Id;
        console.log('newIssues===', newIssuescss);
        for (var index = 0; index < newIssuescss.length; index++) {
            var wrapper = newIssuescss[index];
            
            wrapper.Defect_Root_Causes__r = undefined;
            
            
        }
        component.set("v.newIssuescss", newIssuescss);
        console.log('strcaseid===', strcaseid);
        component.set("v.spinner", true);
        var submitrecordsforapproval = component.get("c.submitIssuesForApprovalAndOrder2");
        submitrecordsforapproval.setParams({
            "issueRecsstr": JSON.stringify(newIssuescss),
            "caseId": strcaseid,
            "isSetIGU": true
        });
        submitrecordsforapproval.setCallback(this, function (response) {
            var state = response.getState();
            
            console.log('state : ', state);
            component.set("v.spinner", false);
            if (state === "SUCCESS") {
                var issueidlist = [];
                var resposeWrap = response.getReturnValue();
                var submittedIssues = resposeWrap.updatedList;
                
                for(var r in submittedIssues){
                    issueidlist.push(submittedIssues[r].Id);
                    
                }
               
                if (numbercode == 1) {
                   /* window.setTimeout(
                        $A.getCallback(function () {
                        }), 7000
                    );*/
                     helper.showSubmittedIssuesModal(component, helper, issueidlist,1);
                   
                   helper.DisplaysubmittedissueStatus(component, issueidlist, "CSS", resposeWrap.success)

                } else if (numbercode == 2) {
                    component.set("v.closeAndOpenCase",true);
                    helper.showSubmittedIssuesModal(component, helper, issueidlist,2);
                  //  helper.cancel(component, helper);
                }
                 if(resposeWrap.success === false){
                  //  component.set("v.isOpenSubmitMessage",true);
                }
                
            }
        });
        $A.enqueueAction(submitrecordsforapproval);
    },
    DisplaysubmittedissueStatus: function (component, issueidlist, varfamily,approvalReqStatus) {
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
                    component.set("v.newIssues", []);
                    helper.doInit(component, "IGU");
                } else if (varfamily == "CSS") {
                    component.set("v.newIssuescssWithStatus", updatedlist);
                    component.set("v.newIssuescss", []);
                    helper.doInit(component, "CSS");
                   
                    
                }
                if(approvalReqStatus === true){
                 //  $A.get('e.force:refreshView').fire();
                }
            }
        });
        $A.enqueueAction(Action);
    },
    ValidateAddNewRow: function (component, helper) {
        // var helper = this;
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
        var areallFieldsValid = true;
        console.log('common_Lite_Mockid', logIssueCommonWrapper.common_Lite_Mockid);
        console.log('common_Liteid', logIssueCommonWrapper.common_Liteid);
        if (!logIssueCommonWrapper.common_Lite_Mockid || !logIssueCommonWrapper.common_Liteid) {
            var areallFieldsValid = false;
            helper.showToastMessage('error', 'Error!', 'please select IGU id provided and Lite ID/Mock ID to add new Issue');
        }
        return areallFieldsValid;
    },
    
    
    
    validateproducts: function (component, helper) {
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
        var action = component.get("c.isproductactive");
        var validate;
        action.setParams({product:logIssueCommonWrapper.common_Liteid});
        var issWrap = component.get("v.logIssueCommonWrapper");
        action.setCallback(this,function(response)
                           {
                               var state = response.getState();
                               if(state = "SUCCESS")
                               {
                                   
                                   validate = response.getReturnValue();
                                   var validated = helper.ValidateAddNewRow(component, helper);
                                   
                                   
                                   var logIssueCommonWrapper1 = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" ) ) );
                                   
                                   console.log('-validated-',validated);
                                   
                                   if(validated){
                                       var logIssueCommonWrapper = JSON.parse( JSON.stringify( component.get( "v.logIssueCommonWrapper" ) ) );
                                       console.log('common_Liteid'+logIssueCommonWrapper.common_Liteid);
										var listOfLogIssueWrappers = JSON.parse( JSON.stringify( component.get( "v.listOfLogIssueWrappers" ) ) );
                                       // var newRecord = JSON.parse( JSON.stringify(listOfLogIssueWrappers[listOfLogIssueWrappers.length-1] ));
                                       // var newRecord = JSON.parse( JSON.stringify(component.get("v.newissueWrapperObj") ));
                                       var obj = {};
                                       var arr = [];
                                       obj["Lite_Mockid"] = logIssueCommonWrapper.common_Lite_Mockid;
                                       
                                       obj["Liteid"] = logIssueCommonWrapper.common_Liteid;
                                       
                                       obj["Mockid"] = logIssueCommonWrapper.common_Liteid;
                                       obj["markID"] = logIssueCommonWrapper.common_Mockid;
                                       obj["Assetid"] = logIssueCommonWrapper.common_Assetid;
                                       obj["prodQty"] = "";
                                       obj["cssProdListPrice"] = "";
                                       obj["reason_replacement"] = logIssueCommonWrapper.common_reason_replacement;
                                       obj["sel_Resp_Entity"] = logIssueCommonWrapper.common_sel_Resp_Entity;
                                       obj["recordTypeId"] = "";
                                       obj["failureComponent"] = "";
                                       obj["existingMakeUpID"] = logIssueCommonWrapper.common_existingMakeUpID;
                                       obj["existingMakeUpDesc"] = logIssueCommonWrapper.common_existingMakeUpDesc;
                                       //obj["failuremodedeatils"] =true;
                                       if(validate=="true")
                                       {
                                           obj["OrderExtMakeup"] = "Yes";
                                       }
                                       if(validate=="false")
                                       {
                                           obj["OrderExtMakeup"] = "No";
                                       }
                                       
                                       obj["height"] = logIssueCommonWrapper.common_height;
                                       obj["base"] = logIssueCommonWrapper.common_base;
                                       obj["shape"] = logIssueCommonWrapper.common_shape;
                                       obj["newMakeUpID"]="";
                                       obj["newMakeUpname"]="";
                                       obj["newMakeUpProduct_SKU"]="";
                                       obj["newMakeUpProductCode"]="";
                                       obj["Lite_height"]=logIssueCommonWrapper.common_lite_height;
                                       obj["Lite_width"]=logIssueCommonWrapper.common_lite_width;
                                       obj["H1_B1"]=logIssueCommonWrapper.common_h1_B1;
                                       obj["failurmodeid"]="";
                                       obj["requestedDate"]=logIssueCommonWrapper.requestDate;
                                       obj["Lite_Damaged"] ="";
                                       obj["Replaced_SWC"] ="";
                                       obj["Replaced_WC"] ="";
                                       obj["Visible_BB_Damage"] ="";
                                       obj["Replaced_IGU_Cable"] ="";
                                       obj["Reflection_Color_Observed"] ="";
                                       obj["Reflection_Color_Degree"] ="";
                                       obj["Create_box_Folder"] =false;
                                       obj["rmaIs"] =false;
                                       obj["listOfSelectedFailureModes"]=arr;
                                       listOfLogIssueWrappers.push(obj);
                                       
                                       console.log( 'listOfLogIssueWrappers', listOfLogIssueWrappers );
                                       console.log( 'listOfLogIssueWrappers .length', listOfLogIssueWrappers.length );
                                       component.set( "v.totalIssues", listOfLogIssueWrappers.length );
                                       
                                       component.set( "v.listOfLogIssueWrappers", listOfLogIssueWrappers );
                                       logIssueCommonWrapper.common_Liteid="";
                                       logIssueCommonWrapper.common_Lite_Mockid="";
                                       component.set( "v.logIssueCommonWrapper", logIssueCommonWrapper );
                                       
                                   }
                                   
                               }
                           }
                          )       
        $A.enqueueAction(action);
        
    },
    
    
    
    ValidateIGUrows: function (component, issueList) {
        var helper = this;
        console.log('validateIssues', issueList);
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")))
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
            
            if (recordIssue.OrderExtMakeup == 'No' && !recordIssue.newMakeUpname) {
                
                helper.showToastMessage('warning', 'Missing!', 'Provide New Makeup for row  --> ' + (index + 1));
                return false;
            }
            else if (!recordIssue.prodQty) {
                
                helper.showToastMessage('warning', 'Missing!', 'Provide Quantity for row  --> ' + (index + 1));
                return false;
            } 
                else if (!recordIssue.requestedDate && logIssueCommonWrapper.orderReplacement) {
                    helper.showToastMessage('warning', 'Missing!', 'Please provide Requested Delivery Date if Order Replacement is checked  for row -->' + (index + 1));
                    
                    return false;
                } 
                    else if ((!logIssueCommonWrapper.RMA && !recordIssue.rmaIs) && !recordIssue.reason_replacement) {
                        
                        helper.showToastMessage('warning', 'Missing!', 'Provide Reason for Replacement for row  --> ' + (index + 1));
                        return false;
                    } 
                        else if ((!logIssueCommonWrapper.RMA && !recordIssue.rmaIs) && !recordIssue.sel_Resp_Entity) {
                            
                            helper.showToastMessage('warning', 'Missing!', 'Provide Who caused the Damage? for row --> ' + (index + 1));
                            return false;
                        } else if (recordIssue.listOfSelectedFailureModes.length == 0) {
                            
                            helper.showToastMessage('warning', 'Missing!', 'Provide atleast one failure mode for row  --> ' + (index + 1));
                            return false;
                        } else if (recordIssue.requestedDate) {
                            dateValue = new Date(recordIssue.requestedDate);
                            if (dateValue != 'Invalid Date' && isNaN(dateValue) == false) {
                                
                                dateValue = recordIssue.requestedDate;
                                if (dateValue <= todayDate) {
                                    helper.showToastMessage('warning', 'Missing!', $A.get("$Label.c.Requested_Delivery_Date_Is_Future_Date") + 'For row -->' + (index + 1));
                                    return false;
                                }
                                else if (dateValue == tomorrowDate && isThisPostMeridiem) {
                                    helper.showToastMessage('warning', 'Missing!', $A.get("$Label.c.Requested_Delivery_Date_Cannot_Be_Tomorrow_s_Date") + ' For row -->' + (index + 1));
                                    return false;
                                }
                            }
                        }
            
        }
        
        return true;
    },
    ValidateCHrows: function (component, issueList) {
        var helper = this;
        var logIssueCommonWrapper = JSON.parse(JSON.stringify(component.get("v.logIssueCommonWrapper")));
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
            if (!recordIssue.recordTypeId) {
                helper.showToastMessage('warning', 'Missing!', 'Provide Record Type for row -->' + (index + 1));
                
                return false;
            } else if (!recordIssue.failureComponent) {
                
                helper.showToastMessage('warning', 'Missing!', 'Provide Failure Component for row -->' + (index + 1));
                return false;
            } else if (!recordIssue.productnamecss) {
                
                helper.showToastMessage('warning', 'Missing!', 'Provide Product for row -->' + (index + 1));
                return false;
            } else if ((!logIssueCommonWrapper.RMA && !recordIssue.rmaIs) && !recordIssue.reason_replacement) {
                
                helper.showToastMessage('warning', 'Missing!', 'Provide Reason for replacement for row -->' + (index + 1));
                return false;
            } else if ((!logIssueCommonWrapper.RMA && !recordIssue.rmaIs) && !recordIssue.sel_Resp_Entity) {
                
                helper.showToastMessage('warning', 'Missing!', 'Provide Who Caused the Damage? for row -->' + (index + 1));
                return false;
            } else if (recordIssue.listOfSelectedFailureModes.length == 0) {
                
                helper.showToastMessage('warning', 'Missing!', 'Provide atleast one failure mode for row  --> ' + (index + 1));
                return false;
            } else if (!recordIssue.prodQty) {
                
                helper.showToastMessage('warning', 'Missing!', 'Provide Quantity for row --> ' + (index + 1));
                
                return false;
            } else if (!recordIssue.requestedDate && logIssueCommonWrapper.orderReplacement) {
                helper.showToastMessage('warning', 'Missing!', 'Please provide Requested Delivery Date when Order Replacement Check box is Checked for row-->' + (index + 1));
                
                return false;
            } else if (recordIssue.requestedDate) {
                dateValue = new Date(recordIssue.requestedDate);
                if (dateValue != 'Invalid Date' && isNaN(dateValue) == false) {
                    
                    dateValue = recordIssue.requestedDate;
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
            'currencyIsoCode': currencyIsoCode
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
        
        var listOfIssueRecordWrappers = JSON.parse(JSON.stringify(component.get("v." + listName)));
        console.log('handleProductSelectEvt-listOfIssueRecordWrappers', listOfIssueRecordWrappers);
        
        if (!listOfIssueRecordWrappers || listOfIssueRecordWrappers.length < recordIndex) {
            return;
        }
        
        var recordIssueWrapper = listOfIssueRecordWrappers[recordIndex];
        console.log('handleProductSelectEvt-recordIssueWrapper', recordIssueWrapper)
        if (recordProductWrapper.recordProduct.Family == "IGU") {
            recordIssueWrapper.newMakeUpID = recordProductWrapper.recordProduct.Id;
            recordIssueWrapper.newMakeUpname = recordProductWrapper.recordProduct.Name;
            recordIssueWrapper.newMakeUpProduct_SKU = recordProductWrapper.recordProduct.Product_SKU__c;
            recordIssueWrapper.newMakeUpProductCode = recordProductWrapper.recordProduct.ProductCode;
        }
        if (recordProductWrapper.recordProduct.Family == "CSS") {
            console.log('recordProductWrapper.listPrice--', recordProductWrapper.listPrice)
            recordIssueWrapper.productidcss = recordProductWrapper.recordProduct.Id;
            recordIssueWrapper.productnamecss = recordProductWrapper.recordProduct.Name;
            recordIssueWrapper.cssProdListPrice = recordProductWrapper.listPrice;
        }
        
        //recordIssueWrapper.listPrice = recordProductWrapper.listPrice;
        
        component.set("v." + listName, listOfIssueRecordWrappers);
    },
    openFailureModeMultiSelectModal: function (component, helper, recordIndex, failureComponent,
                                               listName, listOfAlreadySelectedFailureModes, resonreplace
                                               
                                              ) {
        
        console.log('failureComponent :', failureComponent);
        console.log('resonforreplace :', resonreplace);
        $A.createComponent('c:FailureModeModalCmp', {
            'recordIndex': recordIndex,
            'failureComponent': failureComponent,
            'listName': listName,
            'listOfAlreadySelectedFailureModes': listOfAlreadySelectedFailureModes,
            'resonforreplace':resonreplace
        },
                           function (modalComponent, status, errorMessage) {
                               console.log('status :', status);
                               console.log('errorMessage :', errorMessage);
                               if (status === "SUCCESS") {
                                   
                                   var showChildModalDiv = component.find('showFailureModeMultiSelectModal');
                                   if (showChildModalDiv) {
                                       var body = showChildModalDiv.get("v.body");
                                       body.push(modalComponent);
                                       component.find('showFailureModeMultiSelectModal').set("v.body", body);
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
    openAssetLookupModal: function (component, helper, headerText, recordIndex,
                                    searchKeyword, opportunityId, listName, fieldName
                                    
                                   ) {
        $A.createComponent('c:AssetLookupCmp', {
            'headerText': headerText,
            'recordIndex': recordIndex,
            'searchKeyword': searchKeyword,
            'opportunityId': opportunityId,
            'listName': listName,
            'fieldName': fieldName
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
            'googleAddressSearchModalEvt': component.getReference("c.handleGoogleAddressSearchModalEvt")
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
    openQualityAnalysisModal: function (component, helper, recordIndex, listName, recordIssue) {
        
        if (!recordIndex && !listName && !recordIssue) {
            return;
        }
        
        $A.createComponent('c:QualityAnalysisCmp', {
            'recordIndex': recordIndex,
            'listName': listName,
            'recordIssue': recordIssue,
            'fromComponent': 'LogIssues',
            'qualityAnalysisModalEvt': component.getReference("c.handleQualityAnalysisModalEvt")
        },
                           function (modalComponent, status, errorMessage) {
                               
                               if (status === "SUCCESS") {
                                   
                                   var showChildModalDiv = component.find('showQualityAnalysisModal');
                                   if (showChildModalDiv) {
                                       var body = showChildModalDiv.get("v.body");
                                       body.push(modalComponent);
                                       component.find('showQualityAnalysisModal').set("v.body", body);
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
    setAssetToIssueShape: function (component) {
        
        var assetToIssueShape = {};
        
        assetToIssueShape['SH000'] = 'Rectangle - 0';
        assetToIssueShape['SH001'] = 'Trapezoid - 1';
        assetToIssueShape['SH002'] = 'Trapezoid - 2';
        assetToIssueShape['SH045'] = 'Triangle - 45';
        assetToIssueShape['SH046'] = 'Triangle - 46';
        assetToIssueShape['SH301'] = 'Trapezoid - 301';
        assetToIssueShape['SH302'] = 'Trapezoid - 302';
        console.log('setAssetToIssueShape-assetToIssueShape', assetToIssueShape);
        
        component.set("v.assetToIssueShape", assetToIssueShape);
    },
    populateValueOnIssuesIGU: function (component, helper, fieldName, fieldValue) {
        
        if (!fieldName) {
            return;
        }
        
        var listOfLogIssueWrappers = JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappers")));
        if (!listOfLogIssueWrappers || listOfLogIssueWrappers.length == 0) {
            return;
        }
        
        var anyRecordUpdated = false;
        
        for (var index = 0; index < listOfLogIssueWrappers.length; index++) {
            var wrapper = listOfLogIssueWrappers[index];
            
            wrapper.requestedDate = fieldValue;
            anyRecordUpdated = true;
            
        }
        console.log('populateOwnershipOnIssues-listOfLogIssueWrappers', listOfLogIssueWrappers);
        
        if (anyRecordUpdated) {
            component.set("v.listOfLogIssueWrappers", listOfLogIssueWrappers);
        }
    },
    
    populateValueOnIssuesCSS: function (component, helper, fieldName, fieldValue) {
        
        if (!fieldName) {
            return;
        }
        
        var listOfLogIssueWrappersCSS = JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappersCSS")));
        if (!listOfLogIssueWrappersCSS || listOfLogIssueWrappersCSS.length == 0) {
            return;
        }
        
        var anyRecordUpdated = false;
        
        for (var index = 0; index < listOfLogIssueWrappersCSS.length; index++) {
            var wrapper = listOfLogIssueWrappersCSS[index];
            
            wrapper.requestedDate = fieldValue;
            anyRecordUpdated = true;
            
        }
        console.log('populateOwnershipOnIssues-listOfLogIssueWrappersCSS', listOfLogIssueWrappersCSS);
        
        if (anyRecordUpdated) {
            component.set("v.listOfLogIssueWrappersCSS", listOfLogIssueWrappersCSS);
        }
    },
    populateOwnershipOnIssuesIGU: function (component, helper, fieldName, fieldValue) {
        
        if (!fieldName) {
            return;
        }
        
        var listOfLogIssueWrappers = JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappers")));
        if (!listOfLogIssueWrappers || listOfLogIssueWrappers.length == 0) {
            return;
        }
        
        var anyRecordUpdated = false;
        
        for (var index = 0; index < listOfLogIssueWrappers.length; index++) {
            var wrapper = listOfLogIssueWrappers[index];
            
            wrapper.sel_Resp_Entity = fieldValue;
            anyRecordUpdated = true;
            
        }
        console.log('populateOwnershipOnIssues-listOfLogIssueWrappers', listOfLogIssueWrappers);
        
        if (anyRecordUpdated) {
            component.set("v.listOfLogIssueWrappers", listOfLogIssueWrappers);
        }
    },
    
    populateOwnershipOnIssuesCSS: function (component, helper, fieldName, fieldValue) {
        
        if (!fieldName) {
            return;
        }
        
        var listOfLogIssueWrappersCSS = JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappersCSS")));
        if (!listOfLogIssueWrappersCSS || listOfLogIssueWrappersCSS.length == 0) {
            return;
        }
        
        var anyRecordUpdated = false;
        
        for (var index = 0; index < listOfLogIssueWrappersCSS.length; index++) {
            var wrapper = listOfLogIssueWrappersCSS[index];
            
            wrapper.sel_Resp_Entity = fieldValue;
            anyRecordUpdated = true;
            
        }
        console.log('populateOwnershipOnIssues-listOfLogIssueWrappersCSS', listOfLogIssueWrappersCSS);
        
        if (anyRecordUpdated) {
            component.set("v.listOfLogIssueWrappersCSS", listOfLogIssueWrappersCSS);
        }
    },
    populateRFROnIssuesIGU: function (component, helper, fieldName, fieldValue) {
        
        if (!fieldName) {
            return;
        }
        
        var listOfLogIssueWrappers = JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappers")));
        if (!listOfLogIssueWrappers || listOfLogIssueWrappers.length == 0) {
            return;
        }
        
        var anyRecordUpdated = false;
        
        for (var index = 0; index < listOfLogIssueWrappers.length; index++) {
            var wrapper = listOfLogIssueWrappers[index];
            
            wrapper.reason_replacement = fieldValue;
            anyRecordUpdated = true;
            
        }
        console.log('populateOwnershipOnIssues-listOfLogIssueWrappers', listOfLogIssueWrappers);
        
        if (anyRecordUpdated) {
            component.set("v.listOfLogIssueWrappers", listOfLogIssueWrappers);
        }
    },
    
    populateRFROnIssuesCSS: function (component, helper, fieldName, fieldValue) {
        
        if (!fieldName) {
            return;
        }
        
        var listOfLogIssueWrappersCSS = JSON.parse(JSON.stringify(component.get("v.listOfLogIssueWrappersCSS")));
        if (!listOfLogIssueWrappersCSS || listOfLogIssueWrappersCSS.length == 0) {
            return;
        }
        
        var anyRecordUpdated = false;
        
        for (var index = 0; index < listOfLogIssueWrappersCSS.length; index++) {
            var wrapper = listOfLogIssueWrappersCSS[index];
            
            wrapper.reason_replacement = fieldValue;
            anyRecordUpdated = true;
            
        }
        console.log('populateOwnershipOnIssues-listOfLogIssueWrappersCSS', listOfLogIssueWrappersCSS);
        
        if (anyRecordUpdated) {
            component.set("v.listOfLogIssueWrappersCSS", listOfLogIssueWrappersCSS);
        }
    },
    fetchopenissuesdoinitIGU: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var fetchopenissuesAction = component.get("c.fetchopenissues");
        
        fetchopenissuesAction.setParams({ "caseid": recordId });
        fetchopenissuesAction.setCallback(this, function (response) {
            
            var state = response.getState();
            console.log('fetchopenissuesdoinitIGU-state-', state);
            if (state === "SUCCESS") {
                var lstOfWrapper = component.get("v.logIssueCommonWrapper");
                var responseiss = response.getReturnValue();
                responseiss.IGUReasonsForReplacement = lstOfWrapper.listOfIGUReplacements;
                responseiss.caseRec = lstOfWrapper.recordCase;
                component.set("v.issueWrapperdata",responseiss);
                var issueRecdsWrap = responseiss.issuesLst;
                var issueRecds = [];
                for(var r in issueRecdsWrap){
                    issueRecds.push(issueRecdsWrap[r].issueRec)
                }
                responseiss.issuesLst = issueRecdsWrap;
                component.set("v.issueWrapperdata", responseiss);
                component.set("v.newIssues", issueRecds);
                
                
            }
            else {
                helper.showToastMessage('error', 'Error!', 'Sorry, something went wrong; please contact Admin.');
            }
        });
        $A.enqueueAction(fetchopenissuesAction);
    },
    fetchopenissuesdoinitCHW: function (component, event, helper) {
        var recordId = component.get("v.recordId");
        var fetchopenissuesAction = component.get("c.fetchopenCSSissuesForCHW");
        
        fetchopenissuesAction.setParams({ "caseid": recordId });
        fetchopenissuesAction.setCallback(this, function (response) {
            
            var state = response.getState();
            console.log('fetchopenissuesdoinitCSS-state-', state);
            if (state === "SUCCESS") {
                
                var responseiss = response.getReturnValue();
                var lstOfWrapper = component.get("v.logIssueCommonWrapper");
                responseiss.caseRec = lstOfWrapper.recordCase;
                //responseiss.IGUReasonsForReplacement = lstOfWrapper.listOfIGUReplacements;
                component.set("v.chwIssueWrapperdata",responseiss);
                
                var issueRecdsWrap = responseiss.chwIssueLst;
                var issueRecds = [];
                for(var r in issueRecdsWrap){
                    issueRecds.push(issueRecdsWrap[r].issueRec)
                }
                component.set("v.newIssuescss", issueRecds);
                
                //component.set("v.newIssuescss", response.getReturnValue());
                
                
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
    
       showSubmittedIssuesModal : function( component, helper, listOfIssues,submitedtype ) {
        if( !listOfIssues || listOfIssues.length == 0 ) {
			return listOfIssues;
		}
			$A.createComponent( 'c:LogIssueApprovalIssue', {
            'listOfSubmittedIssues' : listOfIssues,'recordtype' :'IGU','submitedtype':submitedtype
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
})