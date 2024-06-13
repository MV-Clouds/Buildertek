({
	MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB
	CHUNK_SIZE: 750000,      //Chunk Max size 750Kb

	uploadHelper: function (component, event) {
		// get the selected files using aura:id [return array of files]
		var fileInput = component.find("fuploader").get("v.files");

		// get the first file using array index[0]
		var file = fileInput[0];
		var self = this;

		// create a FileReader object
		var objFileReader = new FileReader();
		// set onload function of FileReader object
		objFileReader.onload = $A.getCallback(function () {
			var fileContents = objFileReader.result;
			var base64 = 'base64,';
			var dataStart = fileContents.indexOf(base64) + base64.length;

			fileContents = fileContents.substring(dataStart);
			// call the uploadProcess method
			self.uploadInChunk(component, file, fileContents);
		});

		objFileReader.readAsDataURL(file);
	},

	uploadInChunk: function (component, file, fileContents) {
		// call the apex method 'SaveFile'
		var Questions = component.get("v.Questions");
		var today = new Date();
		var dd = String(today.getDate()).padStart(2, '0');
		var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
		var yyyy = today.getFullYear();
		var getchunk = fileContents;

		today = dd + '/' + mm + '/' + yyyy;
		var nameDate = component.get("v.DynamiccheckListName");
		if (nameDate != undefined) {
			nameDate = nameDate + '-' + today;
		}
		else {
			nameDate = today;
		}
		component.set("v.DynamiccheckListName", nameDate)
		var action = component.get("c.createChecklistWithFilesAndQuestion");
		action.setParams({
			"QuestionString":JSON.stringify(Questions),
			"recordId": component.get("v.recordId"),
			"checkName": nameDate,
			"fileName": file.name,
			"base64Data": encodeURIComponent(getchunk),
			"contentType": file.type,
			"conId": component.get("v.contactId") || null,
			"checkListType": component.get("v.checkListType") || null
		});

		action.setCallback(this, function (a) {

			if (a.getState() === 'SUCCESS') {
				var result = a.getReturnValue();
				//alert(result);
				if (result == 'Success') {
					component.set("v.Spinner", false);
					component.set("v.SuccessMessage", true);
				} else {
					console.log("Error ", a.getError());
					component.set("v.Spinner", false);
				}
			} else {
				console.log("Error ", a.getError());
				component.set("v.Spinner", false);
			}
		});

		var getName1 = component.get("v.DynamiccheckListName");
		if (getName1 != undefined && getName1 != null && getName1 != "") {

			if (getName1.trim() != "") {
				component.set("v.ischecklistNameError", false);
				$A.enqueueAction(action);
			}
			else {
				component.set("v.isDisableButton", true);
				component.set("v.Spinner", false);
				component.set("v.ischecklistNameError", true);
			}
		} else {
			component.set("v.isDisableButton", true);
			component.set("v.Spinner", false);
			component.set("v.ischecklistNameError", true);
		}
	},

	handleSubmit: function (component, event, helper) {
		component.set("v.isDisableButton", false);
		component.set("v.Spinner", true);
		let files = component.find("fuploader").get("v.files");
		if (files && files.length > 0 && files[0].size < this.MAX_FILE_SIZE) {
			helper.uploadHelper(component, event);
		} else {
			helper.doSubmitHeloper(component, event, helper);
		}
	},

	doSubmitHeloper: function (component, event, helper) {
		var Questions = component.get("v.Questions");
		var today = new Date();
		var dd = String(today.getDate()).padStart(2, '0');
		var mm = String(today.getMonth() + 1).padStart(2, '0'); //January is 0!
		var yyyy = today.getFullYear();

		today = dd + '/' + mm + '/' + yyyy;
		var nameDate = component.get("v.DynamiccheckListName");
		if (nameDate != undefined) {
			nameDate = nameDate + '-' + today;
		}
		else {
			nameDate = today;
		}
		component.set("v.DynamiccheckListName", nameDate)
		var action = component.get("c.createchecklistquestion");
		action.setParams({
			"QuestionString": JSON.stringify(Questions),
			"recordId": component.get("v.recordId"),
			"checkName": nameDate,
			"conId": component.get("v.contactId") || null,
			"checkListType": component.get("v.checkListType") || null
		});

		action.setCallback(this, function (a) {

			if (a.getState() === 'SUCCESS') {
				var result = a.getReturnValue();
				//alert(result);
				if (result == 'Success') {
					component.set("v.Spinner", false);
					component.set("v.SuccessMessage", true);
				}
			}
			else {
				console.log("Error ", a.getError());
			}
		});
		var getName1 = component.get("v.DynamiccheckListName");
		if (getName1 != undefined && getName1 != null && getName1 != "") {

			if (getName1.trim() != "") {
				component.set("v.ischecklistNameError", false);
				$A.enqueueAction(action);
			}
			else {
				component.set("v.isDisableButton", true);
				component.set("v.Spinner", false);
				component.set("v.ischecklistNameError", true);
			}
		} else {
			component.set("v.isDisableButton", true);
			component.set("v.Spinner", false);
			component.set("v.ischecklistNameError", true);
		}
	},

	getParameterByName: function (name, url) {
		if (!url) url = window.location.href;
		name = name.replace(/[\[\]]/g, "\\$&");
		var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)"),
			results = regex.exec(url);
		if (!results) return null;
		if (!results[2]) return '';
		return decodeURIComponent(results[2].replace(/\+/g, " "));
	}
})