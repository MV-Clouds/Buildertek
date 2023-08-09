({
	 doInit: function(cmp, helper) {
		var action = cmp.get('c.getTrendingArticles');
		action.setCallback(this, function(response) {
  			var state = response.getState();
  			if (state === 'SUCCESS') {
				var result = response.getReturnValue();
				cmp.set('v.articles', result);
  			} else {
  			    console.log(response.getError());
     		}
  		})
  		$A.enqueueAction(action);
    },
    navigate :function(cmp, evt,helper) {
        var recId = evt.target.getAttribute("data-recId");
        var evt = $A.get("e.force:navigateToSObject");
      //  alert(evt);
        evt.setParams({
			"recordId": recId
		});
		evt.fire();
    }
})