({
	MAX_FILE_SIZE: 4500000, //Max file size 4.5 MB
	CHUNK_SIZE: 750000,      //Chunk Max size 750Kb

	uploadHelper: function (component, event) {
		// get the selected files using aura:id [return array of files]
		var fileInput = component.find("fuploader").get("v.files");
		// get the first file using array index[0]
		var file = fileInput[0];
		var self = this;
		// check the selected file size, if select file size greter then MAX_FILE_SIZE,
		// then show a alert msg to user,hide the loading spinner and return from function
		if (file.size > self.MAX_FILE_SIZE) {
			component.set("v.fileName", 'Alert : File size cannot exceed ' + self.MAX_FILE_SIZE + ' bytes.\n' + ' Selected file size: ' + file.size);
			return;
		}

		// create a FileReader object
		var objFileReader = new FileReader();
		// set onload function of FileReader object
		objFileReader.onload = $A.getCallback(function () {
			var fileContents = objFileReader.result;
			var base64 = 'base64,';
			var dataStart = fileContents.indexOf(base64) + base64.length;

			fileContents = fileContents.substring(dataStart);
			// call the uploadProcess method
			self.uploadProcess(component, file, fileContents);
		});

		objFileReader.readAsDataURL(file);
	},

	uploadProcess: function (component, file, fileContents) {
		// set a default size or startpostiton as 0
		var startPosition = 0;
		// calculate the end size or endPostion using Math.min() function which is return the min. value
		var endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);

		// start with the initial chunk, and set the attachId(last parameter)is null in begin
		this.uploadInChunk(component, file, fileContents, startPosition, endPosition, '');
	},

	uploadInChunk: function (component, file, fileContents, startPosition, endPosition, attachId) {
		// call the apex method 'SaveFile'
		var getchunk = fileContents.substring(startPosition, endPosition);
		var action = component.get("c.SaveFile");
		action.setParams({
			parentId: component.get("v.parentId"),
			fileName: file.name,
			base64Data: encodeURIComponent(getchunk),
			contentType: file.type,
			fileId: attachId
		});

		// set call back
		action.setCallback(this, function (response) {
			// store the response / Attachment Id
			attachId = response.getReturnValue();
			var state = response.getState();
			if (state === "SUCCESS") {
				// update the start position with end postion
				startPosition = endPosition;
				endPosition = Math.min(fileContents.length, startPosition + this.CHUNK_SIZE);
				// check if the start postion is still less then end postion
				// then call again 'uploadInChunk' method ,
				// else, diaply alert msg and hide the loading spinner
				if (startPosition < endPosition) {
					this.uploadInChunk(component, file, fileContents, startPosition, endPosition, attachId);
				} else {
					alert('File has been uploaded successfully');
				}
				// handel the response errors
			} else if (state === "INCOMPLETE") {
				alert("From server: " + response.getReturnValue());
			} else if (state === "ERROR") {
				var errors = response.getError();
				if (errors) {
					if (errors[0] && errors[0].message) {
						console.log("Error message: " + errors[0].message);
					}
				} else {
					console.log("Unknown error");
				}
			}
		});
		// enqueue the action
		$A.enqueueAction(action);
	},

	handleSubmit: function (component, event, helper) {
		component.set("v.isDisableButton", false);
		component.set("v.Spinner", true);
		if (component.find("fuploader").get("v.files").length > 0) {
            helper.uploadHelper(component, event);
        }
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
			"checkName": nameDate
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
				debugger
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
	}
})