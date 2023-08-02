({
    getDataFromFieldSet : function(component, event, helper) {
        
        component.set('v.wraaperValue', [
            {fieldLabel: 'TEAM MEMBER', fieldAPIName: 'Member.Name',displayURL: true,urlFieldAPI:'MemberId'},
            {fieldLabel: 'MEMBER ROLE', fieldAPIName: 'TeamRole.Name'},
            {fieldLabel: 'CASE ACCESS', fieldAPIName: 'TeamRole.AccessLevel'}
        ]);
    },
    getselectOptions : function(component, event, helper) {
        var getRoleDetails = component.get('c.getCaseTeamRoles');
        getRoleDetails.setParams({
        });
        getRoleDetails.setCallback(this, function(response) {
            var mapOfRoleDetails = response.getReturnValue();
            component.set("v.mapOfRoleDetails", mapOfRoleDetails);
            console.log(mapOfRoleDetails);
            var roleDetailList = [];            
            for(var key in mapOfRoleDetails){
                roleDetailList.push(mapOfRoleDetails[key]);
            }
            if(mapOfRoleDetails != []){                
                component.set("v.listOfRoles", roleDetailList);
            }
        });
        $A.enqueueAction(getRoleDetails);
        
    },
    getCaseTeamMembers : function(component, event, helper) {
        var recordId = component.get("v.recordId");
        
        var getCaseTeamMembers = component.get('c.getCaseTeamMembers');
        getCaseTeamMembers.setParams({
            "caseId" : recordId
        });
        getCaseTeamMembers.setCallback(this, function(response){
            var state = response.getState();
            if(component.isValid() && (state === 'SUCCESS' || state === 'DRAFT')){
                var numberOfRows = component.get("v.rowsDisplayed");
                var filteredRecord = component.get("v.filteredRecord");
                component.set("v.sObjectData",response.getReturnValue());
                if(response.getReturnValue().length == 0){
                    component.set("v.emptyList",true);
                }
                else{
                    component.set("v.emptyList",false);
                    if(response.getReturnValue().length > numberOfRows){
                        component.set("v.displayAll",false); 
                        for(var count=0;count<numberOfRows;count++){
                            filteredRecord.push(response.getReturnValue()[count]);
                        }
                        component.set("v.filteredRecord",filteredRecord); 
                    }
                    else{
                        for(var count=0;count<response.getReturnValue().length;count++){
                            filteredRecord.push(response.getReturnValue()[count]);
                        }
                        component.set("v.filteredRecord",filteredRecord);                         
                        component.set("v.displayAll",true); 
                    }
                }
                component.set("v.loadComponent",true); 
            }
        });
        $A.enqueueAction(getCaseTeamMembers);
    },
    validateData: function(component,event, helper){
        var selectedUserRecordId = component.get("v.selectedUserRecordId");   
        if(selectedUserRecordId){
            component.set("v.memberId",selectedUserRecordId);
            helper.getSelectedRecordType(component, event, helper);
        }
        else{
            helper.showMessage(component, true, "Please select user record.");
        }
        
    },
    getSelectedRecordType: function(component,event, helper){
        var selectedRole = component.find("roleNamePicklist").get("v.value");
        if(selectedRole != "" && selectedRole != undefined){
            var mapOfRoleDetails = component.get("v.mapOfRoleDetails");
            var selectedRecordId;
            //finding selected recordTypeId from recordTypeName
            for(var key in mapOfRoleDetails){
                if(selectedRole == mapOfRoleDetails[key].Name){
                    selectedRecordId = key;
                    break;
                }
            }
            if(selectedRecordId != null && selectedRecordId != undefined){
                helper.createCaseTeamMember(component, event, helper,selectedRecordId);
            }
        } else{
            alert('You did not select any record type');
        }
    },
    createCaseTeamMember: function(component, event, helper,selectedRecordId) {
        var action = component.get("c.createCaseTeamMembers");
        var memberId = component.get("v.memberId")[0];
        action.setParams({
            "caseId":component.get("v.recordId"),
            "memberId":memberId,
            "roleId":selectedRecordId
        });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                component.set("v.isOpen", false);  
                helper.getCaseTeamMembers(component, event, helper);
            } else if(state === 'ERROR'){
                var errors = action.getError();
                if (errors) {
                    helper.showMessage(component,true,errors[0].message);
                }           
            }        
        })
        $A.enqueueAction(action);   
    },
    showMessage: function(component, displayMessage, messageShown) {
        component.set("v.displayMessage" , true);
        component.set("v.messageShown" , messageShown);
    },
    deleteRecordsHelper: function(component, event, helper) {
        var selectedRecordList=component.get("v.selectedRecordList");
        if(selectedRecordList != undefined && selectedRecordList != null && selectedRecordList !=""){   
        console.log(selectedRecordList);
            var getRoleDetails = component.get('c.deleteCaseTeamRecords');
        getRoleDetails.setParams({
            "recordToDelete" : selectedRecordList
        });
        getRoleDetails.setCallback(this, function(response) {
            var state = response.getState();
            if(state === 'SUCCESS'){
                helper.getCaseTeamMembers(component, event, helper);
            }        
        });
        $A.enqueueAction(getRoleDetails);
        }else{
            alert("Please select at least one record for delete.");
        }
    },
})