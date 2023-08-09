({
	convertToStarRating: function (rating) {
		var buffer = [];
		// Calculate the number of each type of star needed
		var full_stars = Math.floor(rating);
		var half_stars = Math.ceil(rating - full_stars);
		var empty_stars = 5 - full_stars - half_stars;

		for (var i = 0; i < full_stars; i++) {
			buffer.push("FULL");
		}

		for (var i = 0; i < half_stars; i++) {
			buffer.push("HALF");
		}

		for (var i = 0; i < empty_stars; i++) {
			buffer.push("EMPTY");
		}

		return buffer;
	},
	getStarImageList: function (typeList) {
		return typeList.map(function (type) {
			var img = null;
			switch (type) {
				case "EMPTY":
					img = $A.get('$Resource.insite') + '/insite/svg/star-empty-orange.svg';
					break;
				case "HALF":
					img = $A.get('$Resource.insite') + '/insite/svg/star-half-orange.svg';
					break;
				case "FULL":
					img = $A.get('$Resource.insite') + '/insite/svg/star-orange.svg';
					break;
				default:
					img = $A.get('$Resource.insite') + '/insite/svg/star-empty-orange.svg';
					break;
			}

			return img;
		});
	}
})