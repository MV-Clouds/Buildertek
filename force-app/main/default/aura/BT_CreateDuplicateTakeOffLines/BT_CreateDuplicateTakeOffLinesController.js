({
    doInit: function(component, event, helper) {
        var myPageRef = component.get("v.pageReference");
        //var id = myPageRef.state.c__Id;
        var parentId = myPageRef.state.c__Id;
        console.log('parentId--'+parentId);
        console.log('myPageRef--'+JSON.stringify(myPageRef));
        //component.set("v.takeOffLineId", id);
        component.set("v.takeOffRecordId", parentId);

        helper.setTakeOffLineTableColumn(component, event, helper);
        helper.getTakeOffLineList(component, event, helper);
        //helper.cloneTakeOffLineRecordFromParent(component, event, helper);
    },
    closeScreen: function (component, event, helper) {
        var redirectUrl = '/one/one.app?#/sObject/' + component.get('v.takeOffRecordId') + '/view';
        window.open(redirectUrl, '_self');
    },
    saveRecord: function (component, event, helper){
        console.log('@@clonedRecord Save--'+JSON.stringify(component.get('v.clonedTakeOffLine')));
        helper.saveClonedRecord(component, event, helper);
    },
    handleOnSubmit : function(component, event, helper) {
         
    },
      
    handleOnSuccess : function(component, event, helper) {
        
    },
      
    handleOnError : function(component, event, helper) {
          
    },
    handleRowSelection: function (component, event,helper) {
        var selectedRows = event.getParam('selectedRows');
        console.log('@@selectedRows--'+JSON.stringify(selectedRows));

        if(selectedRows.length >0 )
        {
            component.set('v.showDuplicateButton',true);
            var TOLId = selectedRows[0].Id;
            component.set("v.takeOffLineId", TOLId);
        }
        else
        {
            component.set('v.showDuplicateButton',false);
        }
    },
    handleDuplicateClick: function (component, event,helper) 
    {
        helper.cloneTakeOffLineRecordFromParent(component, event, helper);
    },
})