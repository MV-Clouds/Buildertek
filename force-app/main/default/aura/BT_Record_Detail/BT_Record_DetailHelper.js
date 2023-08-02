({
	getRecords : function(component) {
        var action = component.get("c.getsObjRecords");
        action.setParams({
            "objectAPI" : component.get("v.sObjectName"),
            "fSetName" : component.get("v.fieldSetName"),
            "recordId" : component.get("v.recordId"),
            'action' : component.get("v.layoutAction"),
            'whereCondition' : component.get("v.filterCondition")
            
        });
        action.setCallback(this, function(result) {
            var state=result.getState();
            if(state === "SUCCESS"){
                console.log(result.getReturnValue());
                var response = result.getReturnValue();
                
                var sObjlist = response["sObjlist"];
                var fSetlist = response["fieldSetlist"];
                
                console.log('--fSetlist---'+fSetlist);
                console.log(fSetlist);
                component.set("v.fieldlist", fSetlist);
                
                var objWrapperlist = [];
                
                for (var sObj=0; sObj<sObjlist.length; sObj++){
                    var objRec = [];
                    for (var fSet=0; fSet<fSetlist.length; fSet++){
                        var fAPIname = fSetlist[fSet].fAPIName;
                        var fValue = sObjlist[sObj].sObjRecord[fAPIname];
                        var jsonStr = JSON.parse(fSetlist[fSet].fSetMember);
                        var sObjRecord = sObjlist[sObj].sObjRecord;
                        objRec.push({"fvalue" : fValue,
                                     "fDetails" : jsonStr
                                    });
                    }
                    objWrapperlist.push(objRec);
                }
                console.log(objWrapperlist.length);
                component.set("v.sObjWrapperlist", objWrapperlist);
            }
        });
        $A.enqueueAction(action);
    }
})