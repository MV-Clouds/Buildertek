({
    getClientSelections: function (cmp) {
        debugger
        var action = cmp.get("c.getClientSelections");
        var recId = cmp.get("v.recordId");
        action.setParams({
            "recordId": recId
        });
        action.setCallback(this, function (response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var data = response.getReturnValue();
                console.table('selection view data ',data);
                debugger
                //Change "related child records" key to "_children"
                for (var i = 0; i < data.length; i++) {
                    data[i]._children = data[i]['categories']; // set Client Selection Categories
                    delete data[i].categories;
                }

                for (var i = 0; i < data.length; i++) {
                    for (var ii = 0; ii < data[i]._children.length; ii++) {
                        for (var iii = 0; iii < data[i]._children[ii].cattypes.length; iii++) {
                            if (JSON.stringify(data[i]._children[ii].Id) === JSON.stringify(data[i]._children[ii].cattypes[iii].selectionid)) {
                                //console.log('***** keys match *****');
                                //data[i]._children[ii]._children = data[i]._children[ii].cattypes; // Set Category related Types
                                if (data[i]._children[ii]._children === undefined) {
                                    data[i]._children[ii]._children = [];
                                }
                                data[i]._children[ii]._children.push(data[i]._children[ii].cattypes[iii]);
                                //data[i]._children[ii]._children[data[i]._children[ii]._children.length -1]._children = data[i]._children[ii].cattypes[iii].options; // Set Types related Options
                                //data[i]._children[ii]._children[data[i]._children[ii]._children.length -1]._children = [];
                                for (var iv = 0; iv < data[i]._children[ii].cattypes[iii].options.length; iv++) {
                                    if (data[i]._children[ii].cattypes[iii].options[iv].relatedTypeId === data[i]._children[ii]._children[data[i]._children[ii]._children.length - 1].Id) {
                                        if (data[i]._children[ii]._children[data[i]._children[ii]._children.length - 1]._children === undefined) {
                                            data[i]._children[ii]._children[data[i]._children[ii]._children.length - 1]._children = []
                                        }
                                        data[i]._children[ii]._children[data[i]._children[ii]._children.length - 1]._children.push(data[i]._children[ii].cattypes[iii].options[iv]);
                                    }
                                }

                                // break;
                            }
                        }
                    }
                    delete data[i].cattypes;
                }
                console.table(data);
                cmp.set('v.gridData', data);
            }else{
                console.log('error ',response.getError());
            }
            // error handling when state is "INCOMPLETE" or "ERROR"
        });
        $A.enqueueAction(action);
    }
})