({
    doInit: function (component, event, helper) {
        helper.fetchopenissuesdoinitIGU(component, event, helper);
    },
    openRecordInNewConsoleTab: function (component, event, helper) {
        if (event && event.target && event.target.id) {
            helper.openRecordInNewConsoleTab(component, helper, event.target.id);
        }
    },
    doSelectAll: function (component, event, helper) {
        var issuesAre = component.get("v.listOfIGUIssueWrappers");
        console.log(
            "component.find('selectAll').get('v.checked') ",
            component.find("selectAll").get("v.checked")
        );
        //   var issaveEnabled = false;
        issuesAre.forEach(function (each) {
            each.isSelected = component.find("selectAll").get("v.checked");
        });
        component.set("v.saveIssues", component.find("selectAll").get("v.checked"));
        component.set("v.listOfIGUIssueWrappers", issuesAre);
    },
    dosavecheck: function (component, event, helper) {
        var issuesAre = component.get("v.listOfIGUIssueWrappers");
        var issaveEnabled = false;
        issuesAre.forEach(function (each) {
            if (each.isSelected) issaveEnabled = true;
        });
        component.set("v.saveIssues", issaveEnabled);
    },
    dosaveCancel: function (component, event, helper) {
        var issuesAre = component.get("v.listOfIGUIssueWrappers");
        var issaveEnabled = false;
        issuesAre.forEach(function (each) {
            each.isSelected = false;
        });
        component.set("v.saveIssues", false);
        component.set("v.listOfIGUIssueWrappers", issuesAre);
        component.find("selectAll").set("v.checked",false);
    },
    dosaveIssues: function (component, event, helper) {
        var issuesAre = component.get("v.listOfIGUIssueWrappers");
        var issuesList = [];
        var recordIssue;
        var validateissuelist;
          var selectedIssues = [];
        validateissuelist = true;
         for (var index = 0; index < issuesAre.length; index++) {
            recordIssue = issuesAre[index];
             if(issuesAre[index].isSelected){
                 selectedIssues.push(issuesAre[index]);
                 if(recordIssue.RMA_Return_Product__c==true && recordIssue.Issue_Status__c=='Resolved' && (recordIssue.Reverse_Shipment_Info__c==undefined || recordIssue.RMA_FA_Status__c=='Select' ||recordIssue.RMA_FA_Status__c==''))
                 {
                     helper.showToastMessage( 'error', 'Warning!', 'Please fill Reverse shipment and RMA FA status at  row '+(index+1));
                     validateissuelist=false;
                 }
             }
         
         }
       
        var issuesListNew = {};
      
        if (validateissuelist) {
            var issaveEnabled = false;
            issuesAre.forEach(function (each) {
                delete (each.isSelected);
            });
            
            var fetchopenissuesAction = component.get("c.saveissues");
            fetchopenissuesAction.setParams({
                issuesList: selectedIssues
            });
            fetchopenissuesAction.setCallback(this, function (response) {
                var state = response.getState();
                console.log("fetchopenissuesdoinitIGU-state-", state);
                if (state === "SUCCESS") {
                    var newIssueRecds = component.get("v.newIssues");
                    var newIssueRecdsCopy = component.get("v.newIssues");
                    var updateIssueLst = response.getReturnValue();
                    var wrapData = component.get("v.issueWrapperdata");
                    var issLst = wrapData.issuesLst;
                    for(var i in updateIssueLst){
                        for(var r in issLst){
                            if(issLst[r].issueRec.Id == updateIssueLst[i].Id){
                                if((updateIssueLst[i].Issue_Status__c === 'Canceled') || (updateIssueLst[i].Issue_Status__c === 'Resolved')){
                                    wrapData.issuesLst.splice(r, 1);
                                }else{
                                    issLst[r].issueRec = updateIssueLst[i];
                                }
                                
                            }
                        }
                        for(var p in newIssueRecds){
                            if(newIssueRecds[p].Id == updateIssueLst[i].Id){
                                if((updateIssueLst[i].Issue_Status__c === 'Canceled') || (updateIssueLst[i].Issue_Status__c === 'Resolved')){
                                    newIssueRecdsCopy.splice(p, 1);
                                }
                            } 
                        }
                    }
                    wrapData.issuesLst = issLst;
                    component.set("v.issueWrapperdata",wrapData);
                    component.set("v.newIssues",newIssueRecdsCopy);
                    helper.fetchopenissuesdoinitIGU(component, event, helper);
                    component.set("v.saveIssues", false);
                    //          helper.fetchopenissuesdoinitIGU(component, event, helper );
                    helper.showToastMessage(
                        "success",
                        "Success!",
                        "Updated successfully"
                    );
                } else {
                    let errors = response.getError();
                    let message = "Unknown error";
                    if (errors && Array.isArray(errors) && errors.length > 0) {
                        message = errors[0].message;
                    }
                    helper.showToastMessage("error", "Error!", message); // 'Sorry, something went wrong; please contact Admin.');
                }
            });
            $A.enqueueAction(fetchopenissuesAction);
        }
        //   component.set('v.saveIssues',false);
        // component.set('v.newIssues',issuesAre);
    },
    statusChanged: function (cmp, event, helper) {
        helper.statusChanged(cmp, event, helper, "listOfIGUIssueWrappersClone");
    }
});