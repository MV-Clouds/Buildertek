({
	init: function (component, event, helper) {
		var rating = component.get('v.rating');
		var starTypesList = helper.convertToStarRating(rating);
		component.set('v.stars', helper.getStarImageList(starTypesList));
	}
})