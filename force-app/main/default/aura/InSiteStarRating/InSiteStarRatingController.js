({
	init: function (component, event, helper) {
		var isModalView = component.get('v.isModalView');

		if (isModalView) {
			var starColContainer = component.find('starColContainer');
			$A.util.addClass(starColContainer, 'modalStarSizing');
		}

		var rating = component.get('v.rating');
		var starTypesList = helper.convertToStarRating(rating);
		component.set('v.stars', helper.getStarImageList(starTypesList));
	}
})