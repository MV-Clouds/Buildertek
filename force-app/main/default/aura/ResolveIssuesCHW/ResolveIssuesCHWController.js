({
    doInit: function (component, event, helper) {
        helper.fetchopenissuesdoinitCSS(component, event, helper);
    },
    openRecordInNewConsoleTab: function (component, event, helper) {
        
        if (event && event.target && event.target.id) {
            helper.openRecordInNewConsoleTab(component, helper, event.target.id);
        }
    },
    doSelectAllcss: function (component, event, helper) {
        var issuesAre = component.get('v.listOfLogIssueWrappersCSS');
        //   var issaveEnabled = false;
        issuesAre.forEach(function (each) {
            each.isSelected = component.find('selectAllcss').get('v.checked');
            
        });
        component.set('v.saveIssuescss', component.find('selectAllcss').get('v.checked'));
        component.set('v.listOfLogIssueWrappersCSS', issuesAre);
    },
    dosavecheckcss: function (component, event, helper) {
        var issuesAre = component.get('v.listOfLogIssueWrappersCSS');
        
        var issaveEnabled = false;
        issuesAre.forEach(function (each) {
            if (each.isSelected)
                issaveEnabled = true;
        });
        
        component.set('v.saveIssuescss', issaveEnabled);
    },
    dosaveCancelcss: function (component, event, helper) {
        var issuesAre = component.get('v.listOfLogIssueWrappersCSS');
        var issaveEnabled = false;
        issuesAre.forEach(function (each) {
            each.isSelected = false;
            
        });
        component.set('v.saveIssuescss', false);
        component.set('v.listOfLogIssueWrappersCSS', issuesAre);
        component.find("selectAllcss").set("v.checked",false);
    },
    dosaveIssuescss: function (component, event, helper) {
     
        var issuesAre = component.get('v.listOfLogIssueWrappersCSS');
        var issuesList = [];
        
        var validateissuelist;//helper.ValidateIgu( component,issuesList );
        
        var selectedIssues = [];
        var wrapDataCCCC = component.get("v.issueWrapperdata");
        var issLstCCC = wrapDataCCCC.chwIssueLst;
        for(var r in issuesAre){
            
            if(issuesAre[r].isSelected){
                 var recordIssue = issuesAre[r];
                if(recordIssue.Product_Return__c==true && recordIssue.Issue_Status__c=='Resolved' && (recordIssue.Reverse_Shipment_Info__c==undefined || recordIssue.RMA_FA_Status__c=='Select' ||recordIssue.RMA_FA_Status__c==''))
                {    for(var s in issLstCCC){
                        if(issLstCCC[s].issueRec.Id === recordIssue.Id){
                            recordIssue.Issue_Status__c = issLstCCC[s].issueRec.Issue_Status__c;
                           issuesAre[r].Issue_Status__c = issLstCCC[s].issueRec.Issue_Status__c;
                            issuesAre[r] = recordIssue;
                        }
                    }
                    helper.showToastMessage('error', 'Warning!', 'RMA / FA Status && Reverse Shipment Info cannot be blank when Issue Status equal to Resolved ');
                  validateissuelist=false;
                    component.set("v.listOfLogIssueWrappersCSS",issuesAre);
                          return;
                    }else{
                         selectedIssues.push(issuesAre[r]);
                        validateissuelist=true;
                    }
            }
            
        }
       //component.set("v.listOfLogIssueWrappersCSS",issuesAre);
        var issuesListNew = {};
        if (validateissuelist) {
            var issaveEnabled = false;
            
           // var selectedIssues = [];
            
            var fetchopenissuesAction = component.get("c.saveissues");
            
            fetchopenissuesAction.setParams({
                "issuesList": selectedIssues
            });
            fetchopenissuesAction.setCallback(this, function (response) {
                
                var state = response.getState();
                console.log('fetchopenissuesdoinitIGU-state-', state);
                if (state === "SUCCESS") {
                    helper.fetchopenissuesdoinitCSS(component, event, helper);
                    var newIssueRecds = component.get("v.newIssues");
                    var newIssueRecdsCopy = component.get("v.newIssues");
                    var refreshPmTableEvt = component.getEvent( "refreshPmTableEvt" );
                    if( refreshPmTableEvt ) {
                        refreshPmTableEvt.fire();
                        component.set( "v.showSpinner", false );
                    }
                    var updatedWrap = response.getReturnValue();
                    var updateIssueLst = updatedWrap.issuesLst;
                    var wrapData = component.get("v.issueWrapperdata");
                    var issLst = wrapData.chwIssueLst;
                    var openWrap = [];
                    var updateOpenIss = [];
                    
                    for(var i in updateIssueLst){
                        for(var r in issLst){
                            issLst[r].selected = false;
                            if(issLst[r].issueRec.Id == updateIssueLst[i].issueRec.Id){
                                if(updateIssueLst[i].issueRec.Issue_Status__c !== 'Open'){
                                    wrapData.chwIssueLst.splice(r, 1);
                                }else{
                                    issLst[r].issueRec = updateIssueLst[i].issueRec;
                                }
                                
                            }
                        }
                        if((updateIssueLst[i].issueRec.Issue_Status__c === 'Open')){
                            openWrap.push(updateIssueLst[i]);
                             updateOpenIss.push(updateIssueLst[i].issueRec);
                        }
                        for(var p in newIssueRecds){
                            if(newIssueRecds[p].Id == updateIssueLst[i].issueRec.Id){
                                if(updateIssueLst[i].issueRec.Issue_Status__c === 'Canceled'){
                                    newIssueRecdsCopy.splice(p, 1);
                                }
                            } 
                        }
                    }
                    
                    for(var r in openWrap){
                        issLst.push(openWrap[r]); 
                    }
                    
                    for(var r in updateOpenIss){
                        newIssueRecdsCopy.push(updateOpenIss[r]); 
                    }
                    
                    issuesAre.forEach(function (each) {
                        delete each.isSelected;
                        
                    });
                    wrapData.issuesLst = issLst;
                    component.set("v.issueWrapperdata",wrapData);
                    component.set("v.newIssues",newIssueRecdsCopy);
                    helper.showToastMessage(
                        "success",
                        "Success!",
                        "Updated successfully"
                    );
                    
                }
                else {
                 
                    let errors = response.getError();
                    let message = 'Unknown error';
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    // Display the message
                    console.error(message);
                    console.log('===151=='+JSON.stringify(component.get("v.newIssues")));
                    var cssIs = component.get('v.listOfLogIssueWrappersCSS');
                    var newIs = component.get("v.newIssues");
                    for(var r in cssIs){
                        for(var s in newIs){
                            if(cssIs[r].isSelected){
                                if(cssIs[r].Id === newIs[s].Id){
                                    cssIs[r].Issue_Status__c = newIs[s].Issue_Status__c;
                                }
                            }
                        }
                    }
                    
                    component.set('v.listOfLogIssueWrappersCSS',cssIs);
                    helper.showToastMessage('error', 'Error!', message);
                }
            });
            $A.enqueueAction(fetchopenissuesAction);
        }
        //   component.set('v.saveIssues',false); 
        // component.set('v.newIssues',issuesAre);
    },
    statusChangedcss: function (component, event, helper) {
        
        helper.statusChanged(component, event, helper, 'listOfLogIssueWrappersCSSClone');
    }
})