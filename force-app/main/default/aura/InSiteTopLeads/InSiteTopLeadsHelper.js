({
	applyFilters: function (dataArray, noteType, sortDesc) {
		var tmp = dataArray;

		// if note type is not null and is a valid ID, apply filtering
		if (noteType !== null && noteType > -1) {
			tmp = dataArray.filter(function (row) {
				var currentNoteStatus = parseInt(row.noteStatus);
				var passesFilter = currentNoteStatus === noteType;
				return passesFilter;
			});
		}

		// if sortDesc is an empty string, we are on the clear state
		if (sortDesc !== "") {
			tmp = this.applySortDesc(tmp, sortDesc);
		}

		return tmp;
	},
	applySortDesc: function (dataArray, sortDesc) {
		var sortedArray = dataArray;
		switch (sortDesc) {
			case "lastActiveAscending":
				sortedArray = this.sortLastActiveAscending(dataArray);
				break;
			case "lastActiveDescending":
				sortedArray = this.sortLastActiveDescending(dataArray);
				break;
			case "ratingAscending":
				sortedArray = this.sortRatingAscending(dataArray);
				break;
			case "ratingDescending":
				sortedArray = this.sortRatingDescending(dataArray);
				break;
			default:
				break;
		}

		return sortedArray;
	},
	sortLastActiveAscending: function (dataArray) {
		return dataArray.sort(function (a, b) {
			return a.timestamp - b.timestamp;
		});
	},
	sortLastActiveDescending: function (dataArray) {
		return dataArray.sort(function (a, b) {
			return b.timestamp - a.timestamp;
		});
	},
	sortRatingAscending: function (dataArray) {
		return dataArray.sort(function (a, b) {
			return a.rating - b.rating;
		});
	},
	sortRatingDescending: function (dataArray) {
		return dataArray.sort(function (a, b) {
			return b.rating - a.rating;
		});
	},
	showFailedToRedirectToEnquiryToast: function () {
		var toastEvent = $A.get("e.force:showToast");
		toastEvent.setParams({
			title: 'Cannot Open Enquiry',
			type: 'warning',
			message: 'InSite could not resolve this lead to an Enquiry within Salesforce, you may attempt to locate this lead by using the search box.'
		});
		toastEvent.fire();
	},
	navigateToRecordById: function (id) {
		var urlEvent = $A.get("e.force:navigateToURL");
		urlEvent.setParams({"url": "/" + id});
		urlEvent.fire();
	},
	convertSortToQueryString: function(sortValue) {
		var ret = null;

		switch (sortValue) {
			case "lastActiveAscending":
				ret = "last_active asc";
				break;
			case "lastActiveDescending":
				ret = "last_active desc";
				break;
			case "ratingAscending":
				ret = "rating asc";
				break;
			case "ratingDescending":
				ret = "rating desc";
				break;
			default:
				break;
		}

		if(ret !== null) { ret = encodeURI(ret); }

		return ret;
	}
})